import { randomUUID } from "node:crypto";
import { NextResponse } from "next/server";
import { one } from "@/lib/db";
import {
  overlayQuote,
  detectReservedArea,
  DEFAULT_AREA,
  type Area,
} from "@/lib/overlay";
import { save, read } from "@/lib/storage";

export const dynamic = "force-dynamic";

type Body = {
  /** The generated page to letter. */
  assetId: string;
  /** Defaults to the item's quote_text. */
  text?: string;
  /** Defaults to the item's lettering_style, then Block Outline. */
  letteringStyle?: string;
  /** Overrides the oval measured off the page. */
  area?: Area;
  strokeWidth?: number;
};

/**
 * Lay a quote over a generated page (D23).
 *
 * The result is a new asset rather than a replacement: the unlettered page is
 * still the artwork, and a quote can be reset, restyled or translated against
 * it any number of times. The SVG is written beside the PNG and is the thing
 * that goes to print (D61) — the PNG exists to be looked at.
 */
export async function POST(req: Request) {
  try {
    const body = (await req.json()) as Body;
    if (!body.assetId) {
      return NextResponse.json({ error: "assetId is required." }, { status: 400 });
    }

    const asset = await one<{
      id: string;
      generation_job_id: string;
      category_id: string;
      collection_id: string | null;
      item_id: string | null;
      storage_path: string;
      asset_name: string;
      source_variant_index: number | null;
      quote_text: string | null;
      lettering_style: string | null;
      page_type: string | null;
    }>(
      `select a.id, a.generation_job_id, a.category_id, a.collection_id,
              a.item_id, a.storage_path, a.asset_name, a.source_variant_index,
              i.quote_text, i.lettering_style, i.page_type
         from generated_assets a
         left join items i on i.id = a.item_id
        where a.id = $1`,
      [body.assetId]
    );
    if (!asset) {
      return NextResponse.json({ error: "Asset not found." }, { status: 404 });
    }

    // D56 for lettering: Quote page is the only page type that carries words,
    // and lettering anything else lays type over the middle of a drawing. The
    // portrait that proved it came back with "Rest is not a reward." across
    // the figure's face. An asset with no item behind it is ad hoc and allowed
    // through — there is no page type to contradict.
    if (asset.page_type && asset.page_type !== "Quote page") {
      return NextResponse.json(
        {
          error:
            `This is a ${asset.page_type}, which reserves no area for type. ` +
            "Only a Quote page can be lettered.",
        },
        { status: 409 }
      );
    }

    const text = (body.text ?? asset.quote_text ?? "").trim();
    if (!text) {
      return NextResponse.json(
        {
          error:
            "No quote to lay down. Pass `text`, or set quote_text on the item.",
        },
        { status: 400 }
      );
    }

    const letteringStyle =
      body.letteringStyle ?? asset.lettering_style ?? "Block Outline";

    const page = await read(asset.storage_path);

    // The oval the model drew, not the one it was asked for. It differs on
    // every page, and fitting to a fixed area is what ran the last line of the
    // first real quote out into the pattern.
    const area = body.area ?? (await detectReservedArea(page)) ?? DEFAULT_AREA;

    const { png, svg, width, height } = await overlayQuote(page, {
      text,
      letteringStyle,
      area,
      strokeWidth: body.strokeWidth,
    });

    // A preview persists nothing. Settling on wording and a face takes several
    // attempts, and every attempt is an asset row and a pair of files under
    // D65 and D68 — so trying things would silently fill the library with
    // rejected drafts. Only the commit writes.
    if (new URL(req.url).searchParams.has("preview")) {
      return new NextResponse(new Uint8Array(png), {
        headers: {
          "Content-Type": "image/png",
          "Cache-Control": "no-store",
          "X-Lettering-Style": letteringStyle,
        },
      });
    }

    // Unique per lettering, not per page. Keying on the source page alone made
    // every re-letter overwrite the one before it: the older asset row survived
    // pointing at a file that now held different words, and since the SVG is
    // what goes to print (D61), that row would have printed the wrong quote.
    // D65 protects the art from being replaced; the letterings need the same.
    const base = asset.storage_path.replace(/\.png$/, "");
    const stamp = randomUUID().slice(0, 8);
    const pngKey = `${base}-quote-${stamp}.png`;
    const svgKey = `${base}-quote-${stamp}.svg`;
    const bytes = await save(pngKey, png);
    await save(svgKey, Buffer.from(svg, "utf8"));

    const created = await one(
      `insert into generated_assets
         (generation_job_id, category_id, collection_id, item_id, asset_name,
          storage_path, width, height, file_size_bytes, source_variant_index,
          metadata_json, derived_from_asset_id)
       values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)
       returning id, asset_name, storage_path, status, is_favorite,
                 source_variant_index`,
      [
        asset.generation_job_id,
        asset.category_id,
        asset.collection_id,
        asset.item_id,
        `${asset.asset_name}-quote`,
        pngKey,
        width,
        height,
        bytes,
        asset.source_variant_index,
        JSON.stringify({
          // area and strokeWidth are recorded because the print export re-lays
          // this type as vector against the original art (D61) rather than
          // printing the flattened PNG. Without them the PDF would re-measure
          // the page and could settle on a different oval than the SVG here.
          overlay: {
            text,
            letteringStyle,
            area,
            strokeWidth: body.strokeWidth ?? null,
            svgPath: svgKey,
            from: asset.id,
          },
        }),
        asset.id,
      ]
    );

    return NextResponse.json({ asset: created, svgPath: svgKey, letteringStyle });
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    return NextResponse.json({ error: message }, { status: 500 });
  }
}

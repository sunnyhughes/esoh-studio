import { NextResponse } from "next/server";
import { one } from "@/lib/db";
import { overlayQuote, DEFAULT_BOX, type Box } from "@/lib/overlay";
import { save, read } from "@/lib/storage";

export const dynamic = "force-dynamic";

type Body = {
  /** The generated page to letter. */
  assetId: string;
  /** Defaults to the item's quote_text. */
  text?: string;
  /** Defaults to the item's lettering_style, then Block Outline. */
  letteringStyle?: string;
  box?: Box;
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
    const { png, svg, width, height } = await overlayQuote(page, {
      text,
      letteringStyle,
      box: body.box ?? DEFAULT_BOX,
      strokeWidth: body.strokeWidth,
    });

    const base = asset.storage_path.replace(/\.png$/, "");
    const pngKey = `${base}-quote.png`;
    const svgKey = `${base}-quote.svg`;
    const bytes = await save(pngKey, png);
    await save(svgKey, Buffer.from(svg, "utf8"));

    const created = await one(
      `insert into generated_assets
         (generation_job_id, category_id, collection_id, item_id, asset_name,
          storage_path, width, height, file_size_bytes, source_variant_index,
          metadata_json)
       values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
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
          overlay: { text, letteringStyle, svgPath: svgKey, from: asset.id },
        }),
      ]
    );

    return NextResponse.json({ asset: created, svgPath: svgKey, letteringStyle });
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    return NextResponse.json({ error: message }, { status: 500 });
  }
}

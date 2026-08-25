import { NextResponse } from "next/server";
import { one } from "@/lib/db";
import { read } from "@/lib/storage";
import { exportNameForAsset } from "@/lib/export-name";
import { DEFAULT_AREA, type Area } from "@/lib/overlay";
import {
  buildPagePdf,
  buildPagePng,
  buildQuotePdf,
  buildQuotePng,
  type PrintOptions,
  type PrintResult,
} from "@/lib/print";

export const dynamic = "force-dynamic";

/**
 * Print export for one page (Stage F).
 *
 * GET /api/export/<assetId>?format=pdf|png[&margin=<inches>][&exact=1]
 *
 * Streams the file with its spelled-out export name attached (D42) rather than
 * writing it to storage. An export is a file leaving the studio, not another
 * asset to manage — `storage/` holds artwork, and a print master is derived
 * from artwork on demand and can always be rebuilt.
 *
 * The important behaviour is what happens for a lettered page. A quote asset
 * stores a flattened PNG for looking at and the type as SVG beside it (D65);
 * this route prints from neither. It goes back to the *original unlettered
 * art* recorded in `overlay.from` and re-lays the type as vector straight into
 * the PDF (D61). The flattened preview is never the thing that goes to press.
 *
 * A future book-level export merges the per-page documents this produces; the
 * page builders stay separate from the sheet geometry so that stays a merge.
 */

type Overlay = {
  text: string;
  letteringStyle: string;
  area?: Area | null;
  strokeWidth?: number | null;
  from: string;
};

type AssetRow = {
  id: string;
  storage_path: string;
  metadata_json: { overlay?: Overlay } | null;
};

const FORMATS = ["pdf", "png"] as const;
type Format = (typeof FORMATS)[number];

const TYPES: Record<Format, string> = {
  pdf: "application/pdf",
  png: "image/png",
};

export async function GET(
  req: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    const q = new URL(req.url).searchParams;

    const format = (q.get("format") ?? "pdf") as Format;
    if (!FORMATS.includes(format)) {
      return NextResponse.json(
        { error: `format must be one of: ${FORMATS.join(", ")}` },
        { status: 400 }
      );
    }

    const opts: PrintOptions = { exactColor: q.has("exact") };

    // D24 keeps the border out of the pipeline for now, but the margin is a
    // real dial: the pad already leaves ~0.58" left and right, and a page can
    // be inset further without regenerating it.
    const marginRaw = q.get("margin");
    if (marginRaw !== null) {
      const margin = Number(marginRaw);
      if (!Number.isFinite(margin) || margin < 0 || margin > 2) {
        return NextResponse.json(
          { error: "margin must be between 0 and 2 inches." },
          { status: 400 }
        );
      }
      opts.marginIn = margin;
    }

    const asset = await one<AssetRow>(
      "select id, storage_path, metadata_json from generated_assets where id = $1",
      [id]
    );
    if (!asset) {
      return NextResponse.json({ error: "Asset not found." }, { status: 404 });
    }

    const result = await render(asset, format, opts);

    const name = await exportNameForAsset(asset.id, format);
    const filename = name
      ? name.slice(name.lastIndexOf("/") + 1)
      : `${asset.id}.${format}`;

    return new NextResponse(new Uint8Array(result.bytes), {
      headers: {
        "Content-Type": TYPES[format],
        "Content-Length": String(result.bytes.byteLength),
        "Content-Disposition": `attachment; filename="${filename}"`,
        // Rebuilt from artwork on every request, so nothing downstream should
        // hold a copy that outlives a re-letter of the same page.
        "Cache-Control": "no-store",
        "X-Export-Sheet": `${result.width}x${result.height}`,
      },
    });
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    return NextResponse.json({ error: message }, { status: 500 });
  }
}

/**
 * A lettered asset prints as art plus vector type; anything else prints as it
 * stands. The overlay's own `area` and `strokeWidth` are read back so the
 * printed type lands exactly where the stored SVG put it — older assets
 * predate those being recorded and fall back to the default oval.
 */
async function render(
  asset: AssetRow,
  format: Format,
  opts: PrintOptions
): Promise<PrintResult> {
  const overlay = asset.metadata_json?.overlay;

  if (!overlay) {
    const art = await read(asset.storage_path);
    return format === "pdf" ? buildPagePdf(art, opts) : buildPagePng(art, opts);
  }

  const source = await one<{ storage_path: string }>(
    "select storage_path from generated_assets where id = $1",
    [overlay.from]
  );
  if (!source) {
    throw new Error(
      "The unlettered page this quote was set over is missing, so the type " +
        "cannot be re-laid as vector."
    );
  }

  const art = await read(source.storage_path);
  const quote = {
    text: overlay.text,
    letteringStyle: overlay.letteringStyle,
    area: overlay.area ?? DEFAULT_AREA,
    strokeWidth: overlay.strokeWidth ?? undefined,
  };

  return format === "pdf"
    ? buildQuotePdf(art, quote, opts)
    : buildQuotePng(art, quote, opts);
}

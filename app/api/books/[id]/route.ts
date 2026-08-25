import { NextResponse } from "next/server";
import { buildBook, planBook } from "@/lib/book";
import type { PrintOptions } from "@/lib/print";

export const dynamic = "force-dynamic";
// Fifteen pages each resample to 2550x3300 and encode; the whole interior is
// a minute of work, not a second.
export const maxDuration = 300;

/**
 * The interior of one book.
 *
 * GET /api/books/<collectionId>?format=json    what it is made of, built nothing
 * GET /api/books/<collectionId>?format=pdf     the file KDP takes
 *
 * `format=json` is the one worth reaching for first: of 180 planned pages only
 * a few have art, so "which pages are not ready" is the usual answer.
 */
export async function GET(
  req: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    const q = new URL(req.url).searchParams;

    if ((q.get("format") ?? "pdf") === "json") {
      const plan = await planBook(id);
      if (!plan) {
        return NextResponse.json({ error: "Collection not found." }, { status: 404 });
      }
      return NextResponse.json(plan);
    }

    const opts: PrintOptions & {
      blankBacks?: boolean;
      frontMatter?: boolean;
      draft?: boolean;
    } = {
      draft: q.has("draft"),
      blankBacks: q.get("blankBacks") !== "0",
      frontMatter: q.get("frontMatter") !== "0",
      exactColor: q.has("exact"),
    };

    const margin = Number(q.get("margin") ?? 0);
    if (!Number.isFinite(margin) || margin < 0 || margin > 2) {
      return NextResponse.json(
        { error: "margin must be between 0 and 2 inches." },
        { status: 400 }
      );
    }
    opts.marginIn = margin;

    const { bytes, pageCount, plan } = await buildBook(id, opts);

    const stem = [plan.collection.series, plan.collection.name]
      .filter(Boolean)
      .join(" ")
      .toLowerCase()
      .normalize("NFKD")
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-|-$/g, "");
    const filename = `${stem}-interior${opts.draft ? "-draft" : ""}.pdf`;

    return new NextResponse(new Uint8Array(bytes), {
      headers: {
        "Content-Type": "application/pdf",
        "Content-Length": String(bytes.byteLength),
        "Content-Disposition": `attachment; filename="${filename}"`,
        "Cache-Control": "no-store",
        "X-Book-Pages": String(pageCount),
        "X-Book-Ready": `${plan.ready}/${plan.total}`,
      },
    });
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    // A book that is not ready is a normal answer, not a failure.
    const status = /not ready|no pages planned/.test(message) ? 409 : 500;
    return NextResponse.json({ error: message }, { status });
  }
}

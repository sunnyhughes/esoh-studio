import { PDFDocument, rgb, type PDFPage } from "pdf-lib";
import { query, one } from "./db";
import { read } from "./storage";
import {
  addPage,
  addBlank,
  drawQuoteOn,
  finishPdf,
  LETTER,
  PRINT_DPI,
  type PrintOptions,
  type Quote,
} from "./print";
import { loadFace, lineToPath, DEFAULT_AREA, type Area } from "./overlay";

/**
 * Book assembly.
 *
 * `lib/print.ts` makes one page; this makes the file that goes to KDP. KDP
 * takes a single PDF for an entire paperback interior — separate page files
 * cannot be uploaded — so the assembly has to happen somewhere, and doing it
 * here is the difference between this tool and an evening in Acrobat.
 *
 * Pages are drawn into one document rather than built separately and merged.
 * Merging would encode, parse and re-encode every page, and would leave two
 * ways to make a printed page. `addPage` and `drawQuoteOn` are the same calls
 * the single-page export makes.
 */

const PT_PER_INCH = 72;

/** The interior font. Vendored, OFL, and the face the quote pages default to. */
const FRONT_MATTER_FACE = { file: "LibreBaskerville[wght].ttf", weight: 400 };

export type BookPage = {
  itemId: string;
  ref: string;
  title: string;
  pageType: string | null;
  assetId: string | null;
  storagePath: string | null;
  status: string | null;
  lettered: boolean;
  quote: { text: string; letteringStyle: string; area: Area; strokeWidth?: number } | null;
  /** Why this page cannot print, if it cannot. */
  blocked: string | null;
};

export type BookPlan = {
  collection: {
    id: string;
    name: string;
    series: string | null;
    description: string | null;
  };
  pages: BookPage[];
  ready: number;
  total: number;
  complete: boolean;
};

type ItemRow = {
  id: string;
  ref: string;
  title: string;
  page_type: string | null;
};

type PickRow = {
  item_id: string;
  id: string;
  storage_path: string;
  status: string;
  lettered: boolean;
  metadata_json: {
    overlay?: {
      text: string;
      letteringStyle: string;
      area?: Area | null;
      strokeWidth?: number | null;
      from: string;
    };
  } | null;
};

/**
 * Work out what the book is made of, without building anything.
 *
 * Separate from the build because the interesting answer is usually "which
 * pages are not ready yet" — of 180 planned pages only a handful have art, and
 * a builder that quietly produced a short PDF would be worse than one that
 * refuses.
 */
export async function planBook(collectionId: string): Promise<BookPlan | null> {
  const collection = await one<{
    id: string;
    name: string;
    series: string | null;
    description: string | null;
  }>(
    "select id, name, series, description from collections where id = $1",
    [collectionId]
  );
  if (!collection) return null;

  const items = await query<ItemRow>(
    `select id, ref, title, page_type
       from items where collection_id = $1
      order by ref`,
    [collectionId]
  );

  // One asset per item: an approved page beats a draft, a lettered Quote page
  // beats the bare art it was set over, and the most recent breaks the tie.
  const picks = await query<PickRow>(
    `select distinct on (a.item_id)
            a.item_id, a.id, a.storage_path, a.status, a.metadata_json,
            (a.metadata_json -> 'overlay') is not null as lettered
       from generated_assets a
       join items i on i.id = a.item_id
      where i.collection_id = $1
      order by a.item_id,
               (a.status = 'approved') desc,
               (i.page_type = 'Quote page'
                 and (a.metadata_json -> 'overlay') is not null) desc,
               a.created_at desc`,
    [collectionId]
  );

  const byItem = new Map(picks.map((p) => [p.item_id, p]));

  const pages: BookPage[] = items.map((item) => {
    const pick = byItem.get(item.id);
    const overlay = pick?.metadata_json?.overlay;

    let blocked: string | null = null;
    if (!pick) blocked = "No page has been generated yet.";
    else if (item.page_type === "Quote page" && !pick.lettered) {
      // The art alone is not the page. Printing it would ship a book with a
      // blank oval where the quote belongs.
      blocked = "Generated but not lettered — the quote is still missing.";
    }

    return {
      itemId: item.id,
      ref: item.ref,
      title: item.title,
      pageType: item.page_type,
      assetId: pick?.id ?? null,
      storagePath: pick?.storage_path ?? null,
      status: pick?.status ?? null,
      lettered: pick?.lettered ?? false,
      quote: overlay
        ? {
            text: overlay.text,
            letteringStyle: overlay.letteringStyle,
            area: overlay.area ?? DEFAULT_AREA,
            strokeWidth: overlay.strokeWidth ?? undefined,
          }
        : null,
      blocked,
    };
  });

  const ready = pages.filter((p) => !p.blocked).length;

  return {
    collection,
    pages,
    ready,
    total: pages.length,
    complete: ready === pages.length && pages.length > 0,
  };
}

export type BookOptions = PrintOptions & {
  /**
   * A blank leaf behind every page of art. On by default: KDP prints both
   * sides of every sheet, and a marker through the paper ruins whatever is on
   * the back. It also roughly doubles the interior, which matters because a
   * paperback has a minimum page count that fifteen pages alone would miss.
   */
  blankBacks?: boolean;
  /** Title, copyright and belongs-to pages. */
  frontMatter?: boolean;
  /**
   * Build a book that is not finished, marking each absent page in place.
   * For proofing the shape of the thing; never for upload.
   */
  draft?: boolean;
};

export type BookResult = {
  bytes: Buffer;
  pageCount: number;
  plan: BookPlan;
};

/**
 * Assemble the interior.
 *
 * Refuses an incomplete book unless `draft` is set, because a missing page in
 * a file bound for KDP is not a thing to discover after it prints.
 */
export async function buildBook(
  collectionId: string,
  opts: BookOptions = {}
): Promise<BookResult> {
  const plan = await planBook(collectionId);
  if (!plan) throw new Error("Collection not found.");
  if (plan.total === 0) throw new Error("This collection has no pages planned.");

  const blocked = plan.pages.filter((p) => p.blocked);
  if (blocked.length && !opts.draft) {
    const names = blocked.slice(0, 4).map((p) => p.ref).join(", ");
    throw new Error(
      `${blocked.length} of ${plan.total} pages are not ready (${names}` +
        `${blocked.length > 4 ? ", …" : ""}). ` +
        "Build a draft to proof the shape, or finish the pages first."
    );
  }

  const doc = await PDFDocument.create();
  const blanks = opts.blankBacks ?? true;

  if (opts.frontMatter ?? true) {
    await addFrontMatter(doc, plan, opts);
    // Art starts on a right-hand page. Front matter runs to an odd number of
    // pages, so without this the first drawing lands on the back of a leaf.
    if (blanks && doc.getPageCount() % 2 === 1) addBlank(doc, opts);
  }

  for (const page of plan.pages) {
    if (page.blocked) {
      await addPlaceholder(doc, page, opts);
    } else {
      const art = await read(await sourceFor(page));
      const { page: drawn, sheet } = await addPage(doc, art, opts);
      if (page.quote) await drawQuoteOn(drawn, sheet, page.quote as Quote);
    }
    if (blanks) addBlank(doc, opts);
  }

  doc.setTitle(bookTitle(plan));
  doc.setAuthor("Esoh Creations");
  doc.setSubject(plan.collection.description ?? "");

  const { bytes } = await finishPdf(doc, {
    width: Math.round(LETTER.widthIn * PRINT_DPI),
    height: Math.round(LETTER.heightIn * PRINT_DPI),
    art: { x: 0, y: 0, width: 0, height: 0 },
  });

  return { bytes, pageCount: doc.getPageCount(), plan };
}

/**
 * The file to print from.
 *
 * For a lettered page that is the *unlettered* art, because the type is drawn
 * into the PDF as vector rather than taken from the flattened preview (D61).
 * The overlay records where it came from.
 */
async function sourceFor(page: BookPage): Promise<string> {
  if (!page.storagePath) throw new Error(`${page.ref} has no stored page.`);
  if (!page.lettered) return page.storagePath;

  const source = await one<{ storage_path: string }>(
    `select b.storage_path
       from generated_assets a
       join generated_assets b on b.id = (a.metadata_json -> 'overlay' ->> 'from')::uuid
      where a.id = $1`,
    [page.assetId]
  );
  if (!source) {
    throw new Error(
      `${page.ref} is lettered but the art it was set over is missing.`
    );
  }
  return source.storage_path;
}

function bookTitle(plan: BookPlan): string {
  return plan.collection.series
    ? `${plan.collection.series} — ${plan.collection.name}`
    : plan.collection.name;
}

/** Glyphs as filled paths, centred. No font is embedded; see D64. */
function centred(
  page: PDFPage,
  text: string,
  sizePt: number,
  yFromTopIn: number,
  opts: { grey?: number; tracking?: number } = {}
) {
  const font = loadFace(FRONT_MATTER_FACE.file, FRONT_MATTER_FACE.weight);
  const scale = sizePt / font.unitsPerEm;
  const width = font.layout(text).advanceWidth * scale;
  const { width: pw } = page.getSize();

  const { d } = lineToPath(font, text, scale, (pw - width) / 2, 0);
  if (!d) return;

  page.drawSvgPath(d, {
    x: 0,
    y: page.getSize().height - yFromTopIn * PT_PER_INCH,
    color: rgb(opts.grey ?? 0, opts.grey ?? 0, opts.grey ?? 0),
    borderWidth: 0,
  });
}

async function addFrontMatter(
  doc: PDFDocument,
  plan: BookPlan,
  opts: PrintOptions
) {
  const paper = opts.paper ?? LETTER;
  const size = (): [number, number] => [
    paper.widthIn * PT_PER_INCH,
    paper.heightIn * PT_PER_INCH,
  ];

  const title = doc.addPage(size());
  if (plan.collection.series) {
    centred(title, plan.collection.series.toUpperCase(), 15, 3.4, { grey: 0.35 });
  }
  centred(title, plan.collection.name, 34, 4.4);
  centred(title, "A coloring book", 15, 5.2, { grey: 0.35 });

  // Copyright sits on the back of the title page, which is where a reader
  // expects it and where every printed book puts it.
  const rights = doc.addPage(size());
  const year = new Date().getFullYear();
  centred(rights, `Copyright © ${year} Esoh Creations`, 12, 9.6, { grey: 0.3 });
  centred(rights, "All rights reserved.", 12, 9.9, { grey: 0.3 });

  const belongs = doc.addPage(size());
  centred(belongs, "This book belongs to", 22, 4.6);
  const rule = (paper.heightIn - 5.6) * PT_PER_INCH;
  belongs.drawLine({
    start: { x: 2.1 * PT_PER_INCH, y: rule },
    end: { x: (paper.widthIn - 2.1) * PT_PER_INCH, y: rule },
    thickness: 1.1,
    color: rgb(0.2, 0.2, 0.2),
  });
}

/**
 * A page that is not ready, named in place.
 *
 * Draft builds only. Printing the gap is the point — a proof that silently
 * skipped it would read as a finished book that is simply shorter.
 */
async function addPlaceholder(
  doc: PDFDocument,
  page: BookPage,
  opts: PrintOptions
) {
  const paper = opts.paper ?? LETTER;
  const sheet = doc.addPage([
    paper.widthIn * PT_PER_INCH,
    paper.heightIn * PT_PER_INCH,
  ]);
  centred(sheet, page.ref, 20, 5.1, { grey: 0.45 });
  centred(sheet, page.pageType ?? "Page", 13, 5.5, { grey: 0.55 });
  centred(sheet, page.blocked ?? "Not ready", 11, 5.9, { grey: 0.55 });
}

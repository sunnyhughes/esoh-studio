import {
  LineCapStyle,
  LineJoinStyle,
  PDFDocument,
  rgb,
  setLineJoin,
  type PDFPage,
} from "pdf-lib";
import sharp from "sharp";
import {
  buildQuoteSvg,
  layoutQuote,
  type OverlayOptions,
} from "./overlay";

/**
 * Print output.
 *
 * `lib/overlay.ts` sets the type; this module puts it on paper. The split is
 * deliberate — one module knows about typography, the other about the sheet.
 *
 * D30: coloring pages pad, never crop. 1024x1536 is 0.667; letter is 0.773.
 * Cropping to letter would cut ~13% off the top and bottom and lose art.
 * Padding fits the art to 2200x3300 inside 2550x3300 and leaves ~0.58" of
 * white each side, which KDP wants for margin and gutter anyway. The margin
 * does double duty (direction.md 5.1).
 *
 * D61: the PDF is a composition of the raster art and the vector type, never
 * a flattened picture of both. The art is a photograph of ink and has to be
 * resampled to reach 300 DPI; the letters are geometry and are drawn as PDF
 * path operators, so they stay exact at any size the printer works at. That
 * difference is the whole reason the overlay was kept as paths.
 *
 * The type is re-laid here at print dimensions rather than read back from the
 * .svg the overlay saved. That file is a record of what was drawn, not the
 * print source. Embedding it would look like a saving and would not be one:
 * it was laid out against a 1024-wide page, so printing it means scaling
 * geometry that could simply be regenerated exact. The recorded `area` and
 * `strokeWidth` are what carry across, and they are enough to put the letters
 * in the same place at any size.
 */

export const PRINT_DPI = 300;
const PT_PER_INCH = 72;

/** Page pixels to PDF points. */
const PX_TO_PT = PT_PER_INCH / PRINT_DPI;

export type Paper = { widthIn: number; heightIn: number };

export const LETTER: Paper = { widthIn: 8.5, heightIn: 11 };

export type PrintOptions = {
  paper?: Paper;
  /**
   * White held back on every side, in inches. Zero by default: at letter the
   * art is narrower than the page in proportion, so containing it already
   * leaves 0.58" left and right, and the prompts generate borderless with
   * their own safe margin (D24). Set this only to inset further.
   */
  marginIn?: number;
  /**
   * Encode the raster exactly, at roughly three times the size. See
   * `PALETTE` below for why the default is not this.
   */
  exactColor?: boolean;
};

/**
 * The print raster is written as a 256-colour PNG.
 *
 * A generated page is black line work on white (D63), which uses a handful of
 * distinct values and a long tail of resampling noise. Quantising it measured
 * a mean error of 0.9/255 and put only 0.06% of samples more than 8 apart —
 * invisible on line art — and took one page from 18 MB to 6 MB. At 180 pages
 * that is the difference between 3.3 GB of print masters and 1.1 GB, which is
 * why it is the default rather than an option someone has to find. Pass
 * `exactColor` for the untouched encoding.
 *
 * `effort` here is genuinely CPU effort spent searching for a smaller file, not
 * a quality setting; `palette` is stated rather than left to the side effect
 * `effort` has of turning it on.
 */
const PALETTE = { compressionLevel: 9, palette: true, colours: 256, effort: 7 };
const EXACT = { compressionLevel: 9, palette: false };

/** Where the art sits on the sheet, in page pixels from the top-left. */
export type Placement = { x: number; y: number; width: number; height: number };

export type Sheet = { width: number; height: number; art: Placement };

/**
 * Fit the art inside the sheet without cropping, and centre it.
 *
 * Integers, in page pixels, computed once. The padded raster and the PDF both
 * read their geometry from here rather than each deriving its own — the same
 * reason `layoutQuote()` is the single source of truth for the type. A
 * half-pixel disagreement between the two would put the vector letters off the
 * reserved oval they were set to land in.
 */
export function placeOnPaper(
  source: { width: number; height: number },
  opts: PrintOptions = {}
): Sheet {
  const paper = opts.paper ?? LETTER;
  const width = Math.round(paper.widthIn * PRINT_DPI);
  const height = Math.round(paper.heightIn * PRINT_DPI);

  const inset = Math.round((opts.marginIn ?? 0) * PRINT_DPI);
  const boxW = width - inset * 2;
  const boxH = height - inset * 2;
  if (boxW <= 0 || boxH <= 0) throw new Error("Margin leaves no room for art.");

  const scale = Math.min(boxW / source.width, boxH / source.height);
  const artW = Math.round(source.width * scale);
  const artH = Math.round(source.height * scale);

  return {
    width,
    height,
    art: {
      x: Math.round((width - artW) / 2),
      y: Math.round((height - artH) / 2),
      width: artW,
      height: artH,
    },
  };
}

/**
 * Pad a generated page onto the print sheet: 1024x1536 becomes 2200x3300 of
 * art centred in 2550x3300 of paper (D30).
 *
 * The art is resampled up on the way — 1024px across 7.33" is 140 DPI, and
 * padding alone does not reach the 300 DPI a print file is expected to carry.
 * Lanczos is the right kernel for line work; the result is honest upsampling,
 * not new detail, which is exactly why the type is not treated the same way.
 *
 * Flattened onto white before anything else, so a page that arrived with an
 * alpha channel does not pad transparent and print as a grey box.
 */
export async function padToPrint(
  art: Buffer,
  opts: PrintOptions = {}
): Promise<{ png: Buffer; sheet: Sheet }> {
  const meta = await sharp(art).metadata();
  if (!meta.width || !meta.height) {
    throw new Error("Could not read the page dimensions.");
  }

  const sheet = placeOnPaper({ width: meta.width, height: meta.height }, opts);
  const { x, y, width, height } = sheet.art;

  const pipeline = sharp(art)
    .flatten({ background: "#ffffff" })
    .resize(width, height, { kernel: "lanczos3", fit: "fill" });

  const right = sheet.width - width - x;
  const bottom = sheet.height - height - y;
  if (x || y || right || bottom) {
    pipeline.extend({
      top: y,
      bottom,
      left: x,
      right,
      background: "#ffffff",
    });
  }

  const png = await pipeline
    .withDensity(PRINT_DPI)
    .png(opts.exactColor ? EXACT : PALETTE)
    .toBuffer();

  return { png, sheet };
}

/** "#rrggbb" to a pdf-lib colour. */
function toRgb(hex: string) {
  const m = /^#?([0-9a-f]{6})$/i.exec(hex.trim());
  if (!m) throw new Error(`Not a six-digit hex colour: "${hex}".`);
  const n = parseInt(m[1], 16);
  return rgb(((n >> 16) & 255) / 255, ((n >> 8) & 255) / 255, (n & 255) / 255);
}

export type Quote = Omit<OverlayOptions, "width" | "height">;

export type PrintResult = {
  bytes: Buffer;
  /** Sheet size in pixels at 300 DPI — 2550x3300 for letter. */
  width: number;
  height: number;
  sheet: Sheet;
};

/**
 * A print-ready PDF of one page: letter, 300 DPI, no type.
 *
 * The page is sized in points because that is the only unit a PDF has. The
 * raster is the full sheet, so the white margin is part of the image rather
 * than something the PDF has to draw.
 */
export async function buildPagePdf(
  art: Buffer,
  opts: PrintOptions = {}
): Promise<PrintResult> {
  const { doc, sheet } = await startPdf(art, opts);
  return finishPdf(doc, sheet);
}

/**
 * A print-ready PDF of a quote page: the art as raster, the words as vector.
 *
 * The type is laid out directly in PDF points rather than laid out in pixels
 * and scaled into place. A scaled path in a PDF also scales its own stroke
 * width, which is the workaround the SVG used to carry and 07041c5 removed;
 * setting the type against the art's size in points means the coordinates
 * pdf-lib receives are already the coordinates it draws, and the outline
 * weight means what it says. Proportionally this is the same layout the SVG
 * produces, because `layoutQuote()` derives everything from the oval it is
 * given.
 */
export async function buildQuotePdf(
  art: Buffer,
  quote: Quote,
  opts: PrintOptions = {}
): Promise<PrintResult> {
  const { doc, page, sheet } = await startPdf(art, opts);
  await drawQuoteOn(page, sheet, quote);
  return finishPdf(doc, sheet);
}

/**
 * A print-ready PNG of a quote page.
 *
 * This one does flatten the letters, because a PNG has nowhere else to put
 * them. That is a property of the export, not of the page: the SVG stored
 * beside the art is untouched, so the same quote can be re-set, restyled or
 * translated afterwards (D65). The PDF is the print file; this is for anywhere
 * that will not take one.
 */
export async function buildQuotePng(
  art: Buffer,
  quote: Quote,
  opts: PrintOptions = {}
): Promise<PrintResult> {
  const { png, sheet } = await padToPrint(art, opts);

  const svg = await buildQuoteSvg({
    ...quote,
    width: sheet.art.width,
    height: sheet.art.height,
  });

  const bytes = await sharp(png)
    .composite([
      { input: Buffer.from(svg), top: sheet.art.y, left: sheet.art.x },
    ])
    .withDensity(PRINT_DPI)
    .png(opts.exactColor ? EXACT : PALETTE)
    .toBuffer();

  return { bytes, width: sheet.width, height: sheet.height, sheet };
}

/** A print-ready PNG of one page, no type. */
export async function buildPagePng(
  art: Buffer,
  opts: PrintOptions = {}
): Promise<PrintResult> {
  const { png, sheet } = await padToPrint(art, opts);
  return { bytes: png, width: sheet.width, height: sheet.height, sheet };
}

/**
 * Add one padded page to a document that already exists.
 *
 * Exported so a book is assembled by drawing into a single document rather
 * than by building fifteen PDFs and merging them. Merging would mean encoding,
 * parsing and re-encoding every page, and would leave two ways to make a
 * printed page — the sheet geometry has one owner and this keeps it that way.
 */
export async function addPage(
  doc: PDFDocument,
  art: Buffer,
  opts: PrintOptions = {}
): Promise<{ page: PDFPage; sheet: Sheet }> {
  const { png, sheet } = await padToPrint(art, opts);

  const widthPt = sheet.width * PX_TO_PT;
  const heightPt = sheet.height * PX_TO_PT;

  const page = doc.addPage([widthPt, heightPt]);
  page.drawImage(await doc.embedPng(png), {
    x: 0,
    y: 0,
    width: widthPt,
    height: heightPt,
  });

  return { page, sheet };
}

/**
 * An empty sheet of the same size.
 *
 * A coloring book needs one behind every page of art: KDP prints both sides of
 * every leaf, and markers bleed, so art backed by art loses the page behind it.
 * Nothing is drawn — paper is already white.
 */
export function addBlank(doc: PDFDocument, opts: PrintOptions = {}): PDFPage {
  const paper = opts.paper ?? LETTER;
  return doc.addPage([
    paper.widthIn * PT_PER_INCH,
    paper.heightIn * PT_PER_INCH,
  ]);
}

/** Set the quote over a page already drawn by `addPage`. */
export async function drawQuoteOn(
  page: PDFPage,
  sheet: Sheet,
  quote: Quote
): Promise<void> {
  const { paths, stroke, color } = await layoutQuote({
    ...quote,
    width: sheet.art.width * PX_TO_PT,
    height: sheet.art.height * PX_TO_PT,
  });

  // drawSvgPath translates to (x, y) and then flips the y axis, so `y` is the
  // point on the page that the art's top edge sits at.
  const originX = sheet.art.x * PX_TO_PT;
  const originY = (sheet.height - sheet.art.y) * PX_TO_PT;

  // drawSvgPath has no line-join option and a PDF defaults to mitre, which
  // spikes at the sharp corners of a heavy outlined letter. Each call brackets
  // itself in push/popGraphicsState, and push preserves what is already set.
  page.pushOperators(setLineJoin(LineJoinStyle.Round));

  for (const d of paths) {
    page.drawSvgPath(d, {
      x: originX,
      y: originY,
      borderColor: toRgb(color),
      borderWidth: stroke,
      borderLineCap: LineCapStyle.Round,
    });
  }
}

async function startPdf(art: Buffer, opts: PrintOptions) {
  const doc = await PDFDocument.create();
  const { page, sheet } = await addPage(doc, art, opts);
  return { doc, page, sheet };
}

export async function finishPdf(doc: PDFDocument, sheet: Sheet): Promise<PrintResult> {
  doc.setProducer("Esoh Studio");
  doc.setCreator("Esoh Studio");
  return {
    bytes: Buffer.from(await doc.save()),
    width: sheet.width,
    height: sheet.height,
    sheet,
  };
}

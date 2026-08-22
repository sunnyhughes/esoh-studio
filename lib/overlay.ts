import path from "node:path";
import * as fontkit from "fontkit";
import type { Font } from "fontkit";
import sharp from "sharp";
import { one } from "./db";

/**
 * Quote overlay.
 *
 * D23: quote text is never drawn by the image model. The model reserves a
 * clear area in the middle of the page and is told to draw no letters; the
 * words are laid over afterwards as outlined vector type. That is what keeps
 * spelling and accents correct, and what keeps the letters hollow so they can
 * be coloured like everything else on the page.
 *
 * The type stays vector (D61). This module returns the SVG as well as the
 * composited preview, and the SVG is what gets stored beside the page —
 * flattening would fix the letters at 300 DPI forever, where paths stay sharp
 * at any size and can be restyled or translated without regenerating the art.
 */

const FONT_DIR = path.join(process.cwd(), "assets", "fonts");

export type Face = {
  lettering_style: string;
  family: string;
  weight: number;
  license: string;
  font_file: string;
};

/** Where the type lands, as fractions of the page. */
export type Box = { x: number; y: number; w: number; h: number };

/**
 * The composition block reserves an upright oval at the centre, about
 * two-thirds the page width and half the page height. This box is the largest
 * rectangle that sits comfortably inside that oval — a box matching the oval's
 * full width would put the first and last lines out in the pattern, which is
 * exactly what the first real Quote page did.
 */
export const DEFAULT_BOX: Box = { x: 0.19, y: 0.33, w: 0.62, h: 0.34 };

export type OverlayOptions = {
  text: string;
  letteringStyle: string;
  width: number;
  height: number;
  box?: Box;
  /** Outline weight in output pixels. Defaults to a ratio of the type size. */
  strokeWidth?: number;
  color?: string;
  /** Hard cap on type size, as a fraction of page height. */
  maxSizeRatio?: number;
};

const cache = new Map<string, Font>();

function load(file: string, weight: number): Font {
  const key = `${file}@${weight}`;
  const hit = cache.get(key);
  if (hit) return hit;

  const opened = fontkit.openSync(path.join(FONT_DIR, file));
  const font = "fonts" in opened ? opened.fonts[0] : opened;

  // A variable font renders its axis default unless an instance is cut, and
  // the defaults are wrong here — Montserrat's is Thin, not ExtraBold.
  const instanced =
    font.variationAxes && "wght" in font.variationAxes
      ? font.getVariation({ wght: weight })
      : font;

  cache.set(key, instanced);
  return instanced;
}

export async function getFace(letteringStyle: string): Promise<Face> {
  const face = await one<Face>(
    `select lettering_style, family, weight, license, font_file
       from lettering_faces where lettering_style = $1`,
    [letteringStyle]
  );
  if (!face) throw new Error(`No typeface recorded for "${letteringStyle}".`);
  return face;
}

/**
 * "Mixed Caps + Script" is a pairing rather than a face. With no markup in the
 * quote to say which words are which, the split is by line: the first line
 * takes the display face, the rest take the script.
 */
function facesFor(face: Face): { files: string[]; paired: boolean } {
  const files = face.font_file.split(" + ").map((f) => f.trim());
  return { files, paired: files.length > 1 };
}

/** Width of a string in font units, with kerning applied. */
function advance(font: Font, text: string): number {
  return font.layout(text).advanceWidth;
}

/** Greedy word wrap at a given type size. Returns null if any word overflows. */
function wrap(
  font: Font,
  text: string,
  size: number,
  maxWidth: number
): string[] | null {
  const scale = size / font.unitsPerEm;
  const words = text.split(/\s+/).filter(Boolean);
  const lines: string[] = [];
  let line = "";

  for (const word of words) {
    if (advance(font, word) * scale > maxWidth) return null; // unbreakable
    const candidate = line ? `${line} ${word}` : word;
    if (advance(font, candidate) * scale <= maxWidth) {
      line = candidate;
    } else {
      lines.push(line);
      line = word;
    }
  }
  if (line) lines.push(line);
  return lines;
}

/**
 * Height of a set block, measured from the top of the first line's ascenders
 * to the bottom of the last line's descenders.
 *
 * Counting whole line-heights instead — `lines * size * lineHeight` — measures
 * to a baseline and leaves the final descender hanging below the box. On a page
 * where the blank area is an oval that the pattern closes in around, the tail
 * of a "g" on the last line lands in the pattern.
 */
function blockHeight(font: Font, size: number, lines: number, lineHeight: number) {
  const scale = size / font.unitsPerEm;
  const ascent = font.ascent * scale;
  const descent = Math.abs(font.descent) * scale;
  return { height: (lines - 1) * size * lineHeight + ascent + descent, ascent };
}

/**
 * The largest type size at which the whole quote fits the reserved box.
 *
 * Bisection rather than a stepped search: type size is continuous, and landing
 * a point or two under the true maximum is visible as slack in the box.
 */
function fit(
  font: Font,
  text: string,
  boxW: number,
  boxH: number,
  lineHeight: number,
  maxSize: number
): { size: number; lines: string[] } {
  let lo = 8;
  let hi = maxSize;
  let best: { size: number; lines: string[] } = { size: lo, lines: [text] };

  for (let i = 0; i < 40; i++) {
    const mid = (lo + hi) / 2;
    const lines = wrap(font, text, mid, boxW);
    const fits =
      lines !== null &&
      blockHeight(font, mid, lines.length, lineHeight).height <= boxH;
    if (fits) {
      best = { size: mid, lines: lines! };
      lo = mid;
    } else {
      hi = mid;
    }
    if (hi - lo < 0.25) break;
  }
  return best;
}

/**
 * One line of type, already transformed into page coordinates: y down, origin
 * top-left, units the same pixels as `width` and `height`.
 *
 * Baking the transform into the path data rather than leaving it on a wrapping
 * <g> is what lets the PDF export reuse this. A PDF has no group transforms to
 * inherit, and a scaled group also scales its own stroke — the SVG had to
 * divide the stroke width back out to compensate. Absolute paths need neither
 * workaround, and both outputs draw identical geometry.
 */
function lineToPath(
  font: Font,
  text: string,
  scale: number,
  x: number,
  baseline: number
): { d: string; width: number } {
  const run = font.layout(text);
  let pen = 0;
  const parts: string[] = [];

  run.glyphs.forEach((glyph, i) => {
    const d = glyph.path
      .translate(pen, 0)
      .scale(scale, -scale)
      .translate(x, baseline)
      .toSVG();
    if (d) parts.push(d);
    pen += run.positions[i].xAdvance;
  });

  return { d: parts.join(" "), width: run.advanceWidth };
}

export type QuoteLayout = {
  /** Absolute path data in page coordinates, one entry per line. */
  paths: string[];
  /** Outline weight in the same page pixels. */
  stroke: number;
  size: number;
  lines: string[];
  color: string;
};

/**
 * Set the quote and return its geometry. The single source of truth for the
 * typography — the SVG and the PDF are two renderings of this, not two
 * implementations of it.
 */
export async function layoutQuote(opts: OverlayOptions): Promise<QuoteLayout> {
  const face = await getFace(opts.letteringStyle);
  const { files, paired } = facesFor(face);
  const primary = load(files[0], face.weight);
  const secondary = paired ? load(files[1], face.weight) : primary;

  const box = opts.box ?? DEFAULT_BOX;
  const boxX = box.x * opts.width;
  const boxY = box.y * opts.height;
  const boxW = box.w * opts.width;
  const boxH = box.h * opts.height;

  const lineHeight = 1.24;
  const maxSize = (opts.maxSizeRatio ?? 0.14) * opts.height;
  const { size, lines } = fit(primary, opts.text, boxW, boxH, lineHeight, maxSize);

  // Outline weight tracks type size so a short quote set large and a long one
  // set small carry the same visual line, and both sit in the same weight
  // family as the page's own contours.
  const stroke = opts.strokeWidth ?? Math.max(2, size * 0.036);
  const color = opts.color ?? "#000000";

  // Centre the inked block, not the run of baselines.
  const { height: block, ascent } = blockHeight(
    primary,
    size,
    lines.length,
    lineHeight
  );
  const top = boxY + (boxH - block) / 2;

  const paths = lines
    .map((text, i) => {
      const font = paired && i > 0 ? secondary : primary;
      const scale = size / font.unitsPerEm;
      const measured = font.layout(text).advanceWidth * scale;
      const x = boxX + (boxW - measured) / 2;
      const baseline = top + ascent + i * size * lineHeight;
      return lineToPath(font, text, scale, x, baseline).d;
    })
    .filter(Boolean);

  return { paths, stroke, size, lines, color };
}

/**
 * Build the overlay as standalone SVG. Nothing here depends on a font being
 * installed anywhere — the glyphs are already geometry by this point, which is
 * what makes accented Spanish safe rather than hopeful.
 */
export async function buildQuoteSvg(opts: OverlayOptions): Promise<string> {
  const { paths, stroke, color } = await layoutQuote(opts);

  const groups = paths.map(
    (d) =>
      `<path d="${d}" fill="none" stroke="${color}" ` +
      `stroke-width="${stroke.toFixed(2)}" ` +
      `stroke-linejoin="round" stroke-linecap="round"/>`
  );

  return (
    `<svg xmlns="http://www.w3.org/2000/svg" width="${opts.width}" ` +
    `height="${opts.height}" viewBox="0 0 ${opts.width} ${opts.height}">` +
    groups.join("") +
    `</svg>`
  );
}

/**
 * Lay the type over a generated page.
 *
 * Returns the composited PNG for review and the SVG that produced it. Store
 * both: the PNG is what gets looked at, the SVG is what gets printed (D61).
 */
export async function overlayQuote(
  page: Buffer,
  opts: Omit<OverlayOptions, "width" | "height"> &
    Partial<Pick<OverlayOptions, "width" | "height">>
): Promise<{ png: Buffer; svg: string; width: number; height: number }> {
  const meta = await sharp(page).metadata();
  const width = opts.width ?? meta.width;
  const height = opts.height ?? meta.height;
  if (!width || !height) throw new Error("Could not read page dimensions.");

  const svg = await buildQuoteSvg({ ...opts, width, height });
  const png = await sharp(page)
    .composite([{ input: Buffer.from(svg), top: 0, left: 0 }])
    .png()
    .toBuffer();

  return { png, svg, width, height };
}

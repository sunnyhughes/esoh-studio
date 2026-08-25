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

/**
 * The reserved area, as the bounding box of an upright ellipse, in fractions
 * of the page. The type is fitted to the ellipse, not to this rectangle.
 *
 * It used to be the rectangle, described as "the largest that sits comfortably
 * inside that oval". It was not: measured against a real page the rectangle
 * was half again as wide as the oval at its widest point, and centred lower,
 * so the last line ran out into the pattern — the failure §9 predicted.
 */
export type Area = { x: number; y: number; w: number; h: number };

/**
 * Fallback reserved area, measured off a generated Quote page rather than read
 * off the prompt. The composition block asks for "about two-thirds the page
 * width and half the page height"; the model drew an oval half the page wide
 * and 0.43 of it tall, centred a little above the middle. What the model does
 * is the fact that matters, so the measurement wins over the instruction.
 *
 * Only a fallback: `detectReservedArea` measures the real oval per page,
 * because the model draws a different one every time and any fixed area is a
 * guess that is wrong by a different amount on each page.
 */
export const DEFAULT_AREA: Area = { x: 0.25, y: 0.25, w: 0.5, h: 0.43 };

export type OverlayOptions = {
  text: string;
  letteringStyle: string;
  width: number;
  height: number;
  area?: Area;
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

/**
 * Greedy word wrap where the available width changes line by line.
 *
 * `widthAt` is consulted as each line opens, because the reserved area is an
 * ellipse: a line near the top or bottom has far less room than one across the
 * middle. Returns null when a single word cannot fit the line it lands on,
 * which is the signal to try a smaller size.
 */
function wrapVariable(
  font: Font,
  text: string,
  size: number,
  widthAt: (line: number) => number
): string[] | null {
  const scale = size / font.unitsPerEm;
  const words = text.split(/\s+/).filter(Boolean);
  const lines: string[] = [];
  let line = "";

  for (const word of words) {
    const candidate = line ? `${line} ${word}` : word;
    if (advance(font, candidate) * scale <= widthAt(lines.length)) {
      line = candidate;
      continue;
    }
    if (line) {
      lines.push(line);
      line = "";
    }
    // The word opens the next line down, which is a different width.
    if (advance(font, word) * scale > widthAt(lines.length)) return null;
    line = word;
  }
  if (line) lines.push(line);
  return lines.length ? lines : null;
}

type Ellipse = { cx: number; cy: number; rx: number; ry: number };

function ellipseOf(area: Area, width: number, height: number): Ellipse {
  return {
    cx: (area.x + area.w / 2) * width,
    cy: (area.y + area.h / 2) * height,
    rx: (area.w / 2) * width,
    ry: (area.h / 2) * height,
  };
}

/**
 * Vertical metrics of a set block: the height of the ink, and for each line the
 * baseline and the band it covers from ascender to descender.
 *
 * Measuring to the descender rather than counting whole line-heights is what
 * keeps the tail of a "g" on the last line off the pattern.
 */
function blockOf(
  font: Font,
  size: number,
  lines: number,
  lineHeight: number,
  e: Ellipse
) {
  const scale = size / font.unitsPerEm;
  const ascent = font.ascent * scale;
  const descent = Math.abs(font.descent) * scale;
  const height = (lines - 1) * size * lineHeight + ascent + descent;
  const top = e.cy - height / 2;

  const bands = Array.from({ length: lines }, (_, i) => {
    const baseline = top + ascent + i * size * lineHeight;
    return { baseline, top: baseline - ascent, bottom: baseline + descent };
  });

  return { height, bands };
}

/**
 * How wide a line may be, taken from the ellipse at whichever of its edges
 * sits furthest from the centre.
 *
 * The worst case is the honest one. An ascender at the top of a high line and
 * a descender at the bottom of a low one are exactly where the oval has closed
 * in, and measuring at the baseline instead is what let a descender through.
 */
function widthFor(e: Ellipse, band: { top: number; bottom: number }): number {
  const dy = Math.max(Math.abs(band.top - e.cy), Math.abs(band.bottom - e.cy));
  const t = dy / e.ry;
  return t >= 1 ? 0 : 2 * e.rx * Math.sqrt(1 - t * t);
}

/** Does this exact set of lines sit inside the ellipse at this size? */
function fitsEllipse(
  font: Font,
  lines: string[],
  size: number,
  lineHeight: number,
  e: Ellipse
): boolean {
  const { height, bands } = blockOf(font, size, lines.length, lineHeight, e);
  if (height > e.ry * 2) return false;
  const scale = size / font.unitsPerEm;
  return lines.every(
    (text, i) => advance(font, text) * scale <= widthFor(e, bands[i])
  );
}

/**
 * Wrap the quote inside the ellipse at a given size.
 *
 * How wide each line may be depends on where it sits, and where it sits
 * depends on how many lines there are — so this settles by iteration from a
 * one-line guess, re-wrapping until the line count stops moving. The result is
 * checked by `fitsEllipse` regardless, so a run that does not settle is
 * rejected rather than trusted.
 */
function wrapInEllipse(
  font: Font,
  text: string,
  size: number,
  lineHeight: number,
  e: Ellipse
): string[] | null {
  let n = 1;
  let lines: string[] | null = null;

  for (let i = 0; i < 8; i++) {
    const { height, bands } = blockOf(font, size, n, lineHeight, e);
    if (height > e.ry * 2) return null;

    const widths = bands.map((b) => widthFor(e, b));
    lines = wrapVariable(font, text, size, (l) =>
      widths[Math.min(l, widths.length - 1)]
    );
    if (!lines) return null;
    if (lines.length === n) return lines;
    n = lines.length;
  }

  return lines;
}

/**
 * The largest type size at which the whole quote fits the reserved oval.
 *
 * Bisection rather than a stepped search: type size is continuous, and landing
 * a point or two under the true maximum is visible as slack in the oval.
 */
function fit(
  font: Font,
  text: string,
  e: Ellipse,
  lineHeight: number,
  maxSize: number
): { size: number; lines: string[] } {
  let lo = 8;
  let hi = maxSize;
  let best: { size: number; lines: string[] } = { size: lo, lines: [text] };

  for (let i = 0; i < 40; i++) {
    const mid = (lo + hi) / 2;
    const lines = wrapInEllipse(font, text, mid, lineHeight, e);
    if (lines && fitsEllipse(font, lines, mid, lineHeight, e)) {
      best = { size: mid, lines };
      lo = mid;
    } else {
      hi = mid;
    }
    // Relative, not absolute. The SVG is laid out in page pixels and the PDF
    // in points, so a fixed tolerance stops at a different place in each and
    // the two settle on type sizes a pixel apart. Scaling it to the search
    // range makes both converge identically, which is what lets the PDF and
    // the stored SVG claim to be one geometry (D61).
    if (hi - lo < maxSize * 1e-4) break;
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

  const e = ellipseOf(opts.area ?? DEFAULT_AREA, opts.width, opts.height);

  const lineHeight = 1.24;
  const maxSize = (opts.maxSizeRatio ?? 0.14) * opts.height;
  const { size, lines } = fit(primary, opts.text, e, lineHeight, maxSize);

  // Outline weight tracks type size so a short quote set large and a long one
  // set small carry the same visual line, and both sit in the same weight
  // family as the page's own contours.
  const stroke = opts.strokeWidth ?? Math.max(2, size * 0.036);
  const color = opts.color ?? "#000000";

  // Centre the inked block on the oval, not the run of baselines.
  const { bands } = blockOf(primary, size, lines.length, lineHeight, e);

  const paths = lines
    .map((text, i) => {
      const font = paired && i > 0 ? secondary : primary;
      const scale = size / font.unitsPerEm;
      const measured = font.layout(text).advanceWidth * scale;
      return lineToPath(font, text, scale, e.cx - measured / 2, bands[i].baseline).d;
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
 * Measure the oval the model actually left blank.
 *
 * The prompt reserves a centre, but the model draws a different one every
 * time — so a fixed area is a guess that is wrong by a different amount on
 * every page. This reads the real one off the art: on each row, the run of
 * white through the page's vertical centreline; the longest unbroken stretch
 * of rows wide enough to be the reserved area gives its extent, and the widest
 * row in that stretch gives its width.
 *
 * The longest *contiguous* stretch matters rather than every qualifying row,
 * so a white band elsewhere on the page cannot stretch the measurement to meet
 * it. Returns null when nothing plausible is found — an unusually open page
 * can read as one enormous run — and the caller falls back to DEFAULT_AREA.
 */
export async function detectReservedArea(page: Buffer): Promise<Area | null> {
  const { data, info } = await sharp(page)
    .greyscale()
    .raw()
    .toBuffer({ resolveWithObject: true });

  const W = info.width;
  const H = info.height;
  const centre = W >> 1;
  const WHITE = 250;

  const rows: ({ l: number; r: number } | null)[] = [];
  for (let y = 0; y < H; y++) {
    if (data[y * W + centre] < WHITE) {
      rows.push(null);
      continue;
    }
    let l = centre;
    let r = centre;
    while (l > 0 && data[y * W + l - 1] >= WHITE) l--;
    while (r < W - 1 && data[y * W + r + 1] >= WHITE) r++;
    const run = r - l;
    // Too narrow is a gap in the pattern; too wide is a blank band, not an oval.
    rows.push(run >= W * 0.15 && run <= W * 0.92 ? { l, r } : null);
  }

  let start = -1;
  let bestStart = -1;
  let bestLen = 0;
  for (let y = 0; y <= H; y++) {
    const ok = y < H && rows[y] !== null;
    if (ok && start < 0) start = y;
    if (!ok && start >= 0) {
      if (y - start > bestLen) {
        bestLen = y - start;
        bestStart = start;
      }
      start = -1;
    }
  }
  if (bestLen === 0) return null;

  let widest = 0;
  let left = 0;
  for (let y = bestStart; y < bestStart + bestLen; y++) {
    const r = rows[y]!;
    if (r.r - r.l > widest) {
      widest = r.r - r.l;
      left = r.l;
    }
  }

  const w = widest / W;
  const h = bestLen / H;
  if (h < 0.15 || h > 0.75 || w < 0.15 || w > 0.85) return null;

  return { x: left / W, y: bestStart / H, w, h };
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

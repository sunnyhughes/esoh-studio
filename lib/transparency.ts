import sharp from "sharp";

/**
 * Does this artwork actually have a knocked-out background?
 *
 * D34/D38: apparel artwork must be isolated, because an enclosing background
 * locks the whole line to white and near-white garments. Four of the eight
 * live products only *look* clean — the box is there, hidden by white fabric,
 * and it will not be visible until the design is put on navy.
 *
 * That is the reason this is a check and not an eyeball. Three failures all
 * pass a visual glance:
 *
 *   1. No alpha channel at all. One reference image came back with the
 *      transparency checkerboard rendered into the pixels as opaque grey
 *      squares. It reads as transparent to a person and prints as a
 *      checkerboard.
 *   2. An alpha channel that is fully opaque — the file supports transparency
 *      and does not use it.
 *   3. Alpha present and used, but the design sits on an opaque panel, so the
 *      knockout is only around the outside of a rectangle. This is the one
 *      that hides best — `cleanserene` and `listenin` both carry a white box
 *      and both have clear space around it. The first VV-Styles generation
 *      produced the same defect in a shape that defeats a border test: an
 *      irregular cream blob with a soft feathered edge, floating clear of all
 *      four sides.
 *
 * Two measurements catch the panel, because one alone did not.
 *
 * How full the design's own bounding box is. Real cut-out artwork leaves gaps
 * between its elements: accepted references measure 60-72% opaque within
 * their bounds. A panel welds everything together — a full-canvas one
 * measures 100%, and the feathered blob measured 86%.
 *
 * How much of the alpha is neither clear nor opaque. A cut-out has hard
 * edges, so its partial alpha is antialiasing and nothing more: 0.7-1.6% on
 * the references. A feathered panel fades out over many pixels, and the blob
 * measured 4.9% — three times the worst honest value. This is the sharper
 * signal of the two.
 *
 * What this does NOT catch is a mockup — a photograph of the design already
 * on a shirt, knocked out around the garment. Its alpha is indistinguishable
 * from artwork's (a t-shirt silhouette fills about 65% of its own box, right
 * in the accepted range). The prompt excludes mockups by name; a person
 * catches the rest at review.
 *
 * A failing image is flagged, never discarded: it has already been paid for,
 * and the judgment about whether to rework or re-run is the user's.
 */

export type TransparencyReport = {
  ok: boolean;
  hasAlpha: boolean;
  /** Share of the image that is fully or nearly clear. */
  transparentFraction: number;
  /** Share of the outer edge that is opaque — high means an enclosing panel. */
  borderOpaqueFraction: number;
  /** How full the design's own bounding box is. ~1 means it is a solid panel. */
  boundsFillFraction: number;
  /** Share of pixels that are neither clear nor opaque. High means a soft edge. */
  softEdgeFraction: number;
  /** Empty when ok. Written for a person to read. */
  problems: string[];
};

/** Alpha at or below this reads as clear; at or above OPAQUE reads as ink. */
const CLEAR = 16;
const OPAQUE = 240;

/** Artwork with less clear space than this is not a cut-out. */
const MIN_TRANSPARENT = 0.05;
/** Above this share of opaque edge, the design is sitting on a panel. */
const MAX_BORDER_OPAQUE = 0.5;
/**
 * Above this share of its own bounding box filled, the design has no gaps
 * between its elements. References top out at 72% and the panelled
 * generation hit 86%, so the line sits between them.
 */
const MAX_BOUNDS_FILL = 0.8;
/**
 * Above this share of half-transparent pixels, the edge is fading rather than
 * cutting. References run 0.7-1.6%; the panelled generation ran 4.9%.
 */
const MAX_SOFT_EDGE = 0.03;

export async function inspectTransparency(
  image: Buffer
): Promise<TransparencyReport> {
  const meta = await sharp(image).metadata();
  const hasAlpha = Boolean(meta.hasAlpha);

  // ensureAlpha so an image with no alpha still yields a channel to measure —
  // it comes back fully opaque, which is exactly the finding we want.
  const { data, info } = await sharp(image)
    .ensureAlpha()
    .extractChannel(3)
    .raw()
    .toBuffer({ resolveWithObject: true });

  const { width, height } = info;
  let clear = 0;
  let soft = 0;
  let opaque = 0;
  let minX = width;
  let minY = height;
  let maxX = -1;
  let maxY = -1;

  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      const a = data[y * width + x];
      if (a <= CLEAR) clear++;
      else if (a < OPAQUE) soft++;
      if (a >= OPAQUE) {
        opaque++;
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }
  }

  const boundsArea = maxX < 0 ? 0 : (maxX - minX + 1) * (maxY - minY + 1);
  const boundsFillFraction = boundsArea ? opaque / boundsArea : 0;
  const softEdgeFraction = data.length ? soft / data.length : 0;

  // The outermost ring only. A cut-out design ends before the edge, so its
  // border is clear; a design on a panel fills the border with ink.
  let borderPixels = 0;
  let borderOpaque = 0;
  const at = (x: number, y: number) => data[y * width + x];

  for (let x = 0; x < width; x++) {
    for (const y of [0, height - 1]) {
      borderPixels++;
      if (at(x, y) >= OPAQUE) borderOpaque++;
    }
  }
  for (let y = 1; y < height - 1; y++) {
    for (const x of [0, width - 1]) {
      borderPixels++;
      if (at(x, y) >= OPAQUE) borderOpaque++;
    }
  }

  const transparentFraction = data.length ? clear / data.length : 0;
  const borderOpaqueFraction = borderPixels ? borderOpaque / borderPixels : 0;

  const problems: string[] = [];

  if (!hasAlpha) {
    problems.push(
      "No alpha channel — the background is baked into the pixels. If it " +
        "looks like a transparency checkerboard, that pattern will print."
    );
  } else if (transparentFraction < MIN_TRANSPARENT) {
    problems.push(
      `Only ${(transparentFraction * 100).toFixed(1)}% of the image is clear. ` +
        "The file carries an alpha channel but barely uses it."
    );
  }

  if (boundsFillFraction > MAX_BOUNDS_FILL) {
    problems.push(
      `The design fills ${(boundsFillFraction * 100).toFixed(0)}% of its own ` +
        "bounding box, leaving no clear space inside it. That is the shape of " +
        "a solid panel rather than a cut-out."
    );
  }

  if (softEdgeFraction > MAX_SOFT_EDGE) {
    problems.push(
      `${(softEdgeFraction * 100).toFixed(1)}% of the image is only ` +
        "half-transparent, which is a soft fading edge rather than a cut " +
        "one. Print treats it as a haze around the design."
    );
  }

  if (borderOpaqueFraction > MAX_BORDER_OPAQUE) {
    problems.push(
      `${(borderOpaqueFraction * 100).toFixed(0)}% of the outer edge is ` +
        "opaque — the design is sitting on an enclosing background, which " +
        "will print as a visible box on any garment that is not this colour."
    );
  }

  return {
    ok: problems.length === 0,
    hasAlpha,
    transparentFraction,
    borderOpaqueFraction,
    boundsFillFraction,
    softEdgeFraction,
    problems,
  };
}

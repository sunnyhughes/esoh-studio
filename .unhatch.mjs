// Lift hatching out of shaped regions of a page, keeping the outlines (D47).
// A median window wider than the hatch stroke deletes it as a local minority;
// a contour several times thicker survives. The region is an ellipse list so
// the correction stops at the object's own edge and leaves its neighbours
// alone — a rectangle ate the pinecones behind the mittens on the first try,
// and a greyscale mask composited with dest-in did nothing at all, because a
// greyscale PNG carries no alpha and the median then ran over the whole page.
// The mask has to be joined as an actual alpha channel. 073 and 087.
import sharp from "sharp";
const [src, out, shapes, med = 7] = process.argv.slice(2);
const { width: W, height: H } = await sharp(src).metadata();

const svg = Buffer.from(
  `<svg width="${W}" height="${H}"><rect width="${W}" height="${H}" fill="black"/>` +
  shapes.split(";").map((s) => {
    const [cx, cy, rx, ry] = s.split(",").map(Number);
    return `<ellipse cx="${cx*W}" cy="${cy*H}" rx="${rx*W}" ry="${ry*H}" fill="white"/>`;
  }).join("") + `</svg>`
);
const alphaRaw = await sharp(svg).greyscale().raw().toBuffer();

const cleaned = await sharp(src).greyscale().median(+med).threshold(200)
  .toColourspace("srgb").removeAlpha().png().toBuffer();
const masked = await sharp(cleaned)
  .joinChannel(alphaRaw, { raw: { width: W, height: H, channels: 1 } })
  .png().toBuffer();

await sharp(src).composite([{ input: masked }]).png().toFile(out);
console.log("->", out, "shapes:", shapes, "median", med);

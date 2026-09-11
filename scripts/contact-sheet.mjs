/**
 * Tile crops from several generations into one sheet, so a run of pages can be
 * looked at together rather than one at a time.
 *
 * The project's standing rule is that the picture decides and the numbers
 * only support (docs/direction.md §3.5, and the four investigations in D106
 * that each passed a check while the page was wrong). Comparing ten pages by
 * opening ten files invites judging them against memory instead of against
 * each other; a sheet puts them side by side.
 *
 *   node scripts/contact-sheet.mjs out.jpg x0 y0 x1 y1 img1.png img2.png ...
 *
 * The crop box is fractions of width/height, applied identically to every
 * input, and each tile is labelled with its index so a tile can be traced
 * back to its file.
 */
import sharp from "sharp";

const [out, x0, y0, x1, y1, ...files] = process.argv.slice(2);
if (!files.length) {
  console.error("usage: contact-sheet.mjs out.jpg x0 y0 x1 y1 img...");
  process.exit(1);
}

const TILE = 340;
const COLS = Math.min(5, files.length);
const ROWS = Math.ceil(files.length / COLS);
const PAD = 6;
const LABEL = 22;
const CELL_H = TILE + LABEL;

const tiles = await Promise.all(
  files.map(async (f, i) => {
    const { width: W, height: H } = await sharp(f).metadata();
    const buf = await sharp(f)
      .flatten({ background: "#ffffff" })
      .extract({
        left: Math.round(W * +x0), top: Math.round(H * +y0),
        width: Math.round(W * (+x1 - +x0)), height: Math.round(H * (+y1 - +y0)),
      })
      .resize(TILE, TILE, { fit: "contain", background: "#ffffff" })
      .toBuffer();
    return { buf, i };
  })
);

const sheetW = COLS * (TILE + PAD) + PAD;
const sheetH = ROWS * (CELL_H + PAD) + PAD;

const labels = tiles.map(({ i }) => {
  const col = i % COLS, row = Math.floor(i / COLS);
  return {
    input: Buffer.from(
      `<svg width="${TILE}" height="${LABEL}">
         <text x="4" y="16" font-family="monospace" font-size="14"
               fill="#000">#${i + 1}</text>
       </svg>`
    ),
    left: PAD + col * (TILE + PAD),
    top: PAD + row * (CELL_H + PAD) + TILE,
  };
});

await sharp({
  create: { width: sheetW, height: sheetH, channels: 3, background: "#bbbbbb" },
})
  .composite([
    ...tiles.map(({ buf, i }) => ({
      input: buf,
      left: PAD + (i % COLS) * (TILE + PAD),
      top: PAD + Math.floor(i / COLS) * (CELL_H + PAD),
    })),
    ...labels,
  ])
  .jpeg({ quality: 93 })
  .toFile(out);

console.log(`${files.length} tiles -> ${out}`);

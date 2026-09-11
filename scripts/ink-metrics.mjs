/**
 * Ink signature of a crop, for telling apart the three ways a coloring page
 * goes wrong in the same place (D110).
 *
 * A head-crop black fraction cannot distinguish an open outlined section from
 * fine hatching: 12.5%, 13.0% and 15.6% were measured on three pages whose
 * colourability was completely different. Black fraction answers "how much
 * ink", and the question that decides whether a page can be coloured is "how
 * is the ink arranged".
 *
 * Three numbers, scanned over the crop in both directions:
 *
 *   black      fraction of pixels below mid-grey — how much ink.
 *   crossings  black/white transitions per 1000 pixels scanned — how broken up
 *              the area is. Hatching is many strokes and scores high; an open
 *              section crossed by two outlines scores low; so does a solid
 *              mass, which is why this is read together with `black`.
 *   openrun    median length of a white run, in pixels. This is the one that
 *              matters for the product: it is roughly the width of the widest
 *              gap a coloured pencil has to work in.
 *
 * Read as a triple:
 *
 *   open outlined sections   low black,  low crossings,  long openrun
 *   fine hatching            low black,  HIGH crossings, short openrun
 *   solid fill               high black, low crossings,  short openrun
 *
 * The first and second are the pair that black fraction alone confuses, and
 * they are separated by `crossings` and `openrun`, not by `black`.
 */
import sharp from "sharp";

const THRESHOLD = 128;

function scanLines(get, nLines, lineLen) {
  let black = 0, total = 0, crossings = 0;
  const whiteRuns = [];
  for (let i = 0; i < nLines; i++) {
    let run = 0, prev = null;
    for (let j = 0; j < lineLen; j++) {
      const isBlack = get(i, j) < THRESHOLD;
      if (isBlack) black++;
      total++;
      if (prev !== null && isBlack !== prev) {
        crossings++;
        // A white run ends where ink starts. Runs that touch the crop edge are
        // not closed by ink and would inflate the median, so they are dropped.
        if (isBlack && run > 0) whiteRuns.push(run);
      }
      run = isBlack ? 0 : run + 1;
      prev = isBlack;
    }
  }
  return { black, total, crossings, whiteRuns };
}

export async function inkMetrics(file, box) {
  const [x0, y0, x1, y1] = box;
  const { width: W, height: H } = await sharp(file).metadata();
  const left = Math.round(W * x0), top = Math.round(H * y0);
  const w = Math.round(W * (x1 - x0)), h = Math.round(H * (y1 - y0));
  const { data } = await sharp(file)
    .flatten({ background: "#ffffff" })
    .extract({ left, top, width: w, height: h })
    .greyscale().raw().toBuffer({ resolveWithObject: true });

  const rows = scanLines((i, j) => data[i * w + j], h, w);
  const cols = scanLines((i, j) => data[j * w + i], w, h);

  const runs = [...rows.whiteRuns, ...cols.whiteRuns].sort((a, b) => a - b);
  const total = rows.total + cols.total;
  return {
    black: (100 * (rows.black + cols.black)) / total,
    crossings: (1000 * (rows.crossings + cols.crossings)) / total,
    openrun: runs.length ? runs[Math.floor(runs.length / 2)] : 0,
  };
}

if (process.argv[2]) {
  const [file, ...box] = process.argv.slice(2);
  const b = box.length === 4 ? box.map(Number) : [0.22, 0.10, 0.68, 0.38];
  const m = await inkMetrics(file, b);
  console.log(
    `${m.black.toFixed(1).padStart(5)}%  ` +
    `${m.crossings.toFixed(1).padStart(5)} cross/1k  ` +
    `${String(m.openrun).padStart(3)}px openrun   ${file}`
  );
}

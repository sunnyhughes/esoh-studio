import sharp from "sharp";
import { PRINT_DPI, placeOnPaper } from "./print";

/**
 * The export checklist from `page_design_system`, measured instead of hoped for.
 *
 * Six checks are listed there. Three are mechanical and are done here. Three are
 * not, and saying so is more useful than a metric that pretends:
 *
 *   1. No text closer than the safe margin      → `safeMarginInkFraction`
 *      (which found the pipeline violating it, and now guards the fix)
 *   2. No lines below 0.5 pt in print export    → **not measurable, see below**
 *   3. No muddy grey fills                      → `greyFillFraction`
 *   4. Reads clearly at 100% print size         → a person has to look
 *   5. Quote spelling and accents verified      → a person has to read it
 *   6. PNG and PDF outputs both tested          → the print pipeline's job
 *
 * **Why line weight is not measured.** 0.5 pt at 300 DPI is 2.08 px, and the
 * page arrives as a 1024-wide raster that the print pipeline resamples up to
 * 2200. Measuring stroke width after that upscale measures lanczos, not
 * draughtsmanship: every approved exemplar reads as 30-43% "hairline" purely
 * because its lines were interpolated, and a gate on that would fail all of
 * them. D110 is the standing warning here — a metric that cannot see the thing
 * it claims to is worse than no metric, because it gets believed. The line
 * weight rule belongs in the prompt, where 058 put it, until the pages are
 * vector.
 */

export type PageReport = {
  ok: boolean;
  /** Share of the page that is ink. Context for the rest. */
  inkFraction: number;
  /**
   * Grey that is **not** touching ink — a fill or a shaded passage rather than
   * an antialiased edge. Measured at native resolution, because resampling
   * manufactures grey at every contour and drowns the signal.
   */
  greyFillFraction: number;
  /** Share of the page's ink that falls inside the 0.375in safe margin. */
  safeMarginInkFraction: number;
  problems: string[];
};

/** At or below is ink; at or above is paper. Between the two is grey. */
const INK = 96;
const PAPER = 232;

/**
 * Calibrated against Esoh's own judgements on 105 pages, and set twice.
 *
 * The first attempt put the line at 6%, from a sample of eight: approved work
 * measured 0.00-4.00% and the two graphite-looking porch renders measured
 * 7.91% and 8.43%. Measured across every page in the library, that line flags
 * **four pages Esoh approved** — Multiracial Fall 01 at 9.4%, African American
 * Fall 01 at 8.4% and 7.9%, Fall 14 at 6.1%. A metric that calls a page a
 * failure after Esoh has kept it is D111 and D126 repeating, and the fault is
 * the threshold, not the judgement.
 *
 * The full distribution says there is no line below 12% that separates them at
 * all — approved and rejected overlap in every band from 0 to 10%. Above 12%
 * there are two pages, both rejected, at 47% and 50%. So that is where the line
 * goes: `ok: false` means **no page Esoh has ever kept looks like this**, which
 * is a claim the evidence supports.
 *
 * The number is recorded on every page either way. Rejected work averages 3.78%
 * against approved work's 1.88%, so the measure does carry signal — it is just
 * signal for watching drift across a season, not for judging one page. D110's
 * rule holds: the metric informs, Esoh decides.
 */
const MAX_GREY_FILL = 0.12;

/**
 * This measured 2-10% on approved pages and now measures 0.00% on all 105,
 * because the finding was acted on: `DEFAULT_MARGIN_IN` went from 0 to the
 * spec's 0.375 on 2026-09-14, so the art is inside the safe band by
 * construction.
 *
 * It is kept as a canary rather than deleted. It reads zero only while the
 * default holds; export a page at `marginIn: 0`, or change the sheet, and the
 * number climbs again. A check that found something once and now reads zero is
 * worth keeping precisely because zero is the answer we want to keep getting.
 */
const MAX_SAFE_MARGIN_INK = 0.05;
const SAFE_MARGIN_IN = 0.375;

export async function inspectPage(image: Buffer): Promise<PageReport> {
  // Grey is measured on the page as generated. Anything else measures the
  // resampler.
  const { data, info } = await sharp(image)
    .flatten({ background: "#ffffff" })
    .greyscale()
    .raw()
    .toBuffer({ resolveWithObject: true });

  const { width, height } = info;
  let ink = 0;
  let greyFill = 0;

  const isInk = (x: number, y: number) =>
    x >= 0 && y >= 0 && x < width && y < height && data[y * width + x] <= INK;

  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      const v = data[y * width + x];
      if (v <= INK) {
        ink++;
      } else if (v < PAPER) {
        let touchesInk = false;
        for (let dy = -1; dy <= 1 && !touchesInk; dy++) {
          for (let dx = -1; dx <= 1; dx++) {
            if (isInk(x + dx, y + dy)) {
              touchesInk = true;
              break;
            }
          }
        }
        if (!touchesInk) greyFill++;
      }
    }
  }

  const pixels = width * height;
  const greyFillFraction = greyFill / pixels;

  // The margin is a property of the sheet, not of the art, so it is measured
  // where the art will actually sit: `placeOnPaper` with the same defaults the
  // print pipeline uses.
  const sheet = placeOnPaper({ width, height });
  const band = Math.round(SAFE_MARGIN_IN * PRINT_DPI);
  const scaleX = sheet.art.width / width;
  const scaleY = sheet.art.height / height;

  let marginInk = 0;
  for (let y = 0; y < height; y++) {
    const sy = sheet.art.y + y * scaleY;
    const nearY = sy < band || sy >= sheet.height - band;
    for (let x = 0; x < width; x++) {
      if (data[y * width + x] > INK) continue;
      const sx = sheet.art.x + x * scaleX;
      if (nearY || sx < band || sx >= sheet.width - band) marginInk++;
    }
  }
  const safeMarginInkFraction = ink ? marginInk / ink : 0;

  const problems: string[] = [];
  if (greyFillFraction > MAX_GREY_FILL) {
    problems.push(
      `${(greyFillFraction * 100).toFixed(1)}% of the page is grey fill away ` +
        `from any contour — this reads as a shaded drawing rather than line art.`
    );
  }
  if (safeMarginInkFraction > MAX_SAFE_MARGIN_INK) {
    problems.push(
      `${(safeMarginInkFraction * 100).toFixed(0)}% of the ink falls inside the ` +
        `0.375in safe margin and may be trimmed.`
    );
  }

  return {
    // The margin finding is advisory; only grey fill decides `ok`.
    ok: greyFillFraction <= MAX_GREY_FILL,
    inkFraction: ink / pixels,
    greyFillFraction,
    safeMarginInkFraction,
    problems,
  };
}

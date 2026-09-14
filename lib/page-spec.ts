/**
 * The numbers from `page_design_system`, in one place with no dependencies.
 *
 * They are quoted by the print pipeline, the export checks and the print panel
 * — server and browser both — so they live apart from anything that imports
 * `sharp`. A client component pulling this from `lib/print.ts` dragged sharp
 * into the browser bundle and broke the page with "Can't resolve child_process".
 */

/** Interior trim, portrait. */
export const TRIM_IN = { widthIn: 8.5, heightIn: 11 } as const;

/** Export resolution for PNG and PDF. */
export const PRINT_DPI = 300;

/**
 * "Safe margin: 0.375 in minimum from trim on all sides."
 *
 * Zero until 2026-09-14, on the reasoning that a 2:3 page contained in a letter
 * sheet already leaves 0.58in left and right and the art carries its own margin
 * (D24). The sides were never the problem: **a 2:3 page scaled into 8.5x11 fills
 * the height exactly**, so every page ever exported had *zero* top and bottom
 * margin, and `lib/page-check.ts` measured 2-10% of the ink on approved pages
 * sitting inside the band a trimmer can take.
 *
 * Honouring it costs 13% of the art's area — 7.33x11in becomes 6.83x10.25in —
 * and widens the sides to 0.84in, because the only ways to buy vertical margin
 * without scaling are cropping, which D30 forbids, and stretching. Esoh's call,
 * 2026-09-14: honour the spec.
 *
 * Nothing is baked in. The margin is placement, not artwork, so any page can be
 * re-exported at any inset and the print panel still offers the control.
 */
export const DEFAULT_MARGIN_IN = 0.375;

/** Line weights the prompt asks for; not measurable on a raster (068). */
export const CONTOUR_PT = { primary: [0.75, 1.25], secondary: [0.5, 0.75] } as const;

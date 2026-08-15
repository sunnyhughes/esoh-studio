/**
 * Approximate per-image cost, used to populate generation_jobs.cost_usd.
 *
 * ⚠️  THESE NUMBERS NEED VERIFYING AGAINST CURRENT OPENAI PRICING.
 * They are a starting estimate so cost tracking exists from day one (D9), not
 * an authoritative rate card. gpt-image-1 actually bills per output token, so
 * these are the commonly published per-image equivalents. Check
 * https://openai.com/api/pricing and correct this table.
 *
 * Wrong-but-consistent numbers still answer the question that matters
 * six months out: "which collections are expensive?"
 */

type Rates = Record<string, Record<string, number>>;

const GPT_IMAGE_1: Rates = {
  // size          low      medium    high
  "1024x1024": { low: 0.011, medium: 0.042, high: 0.167 },
  "1024x1536": { low: 0.016, medium: 0.063, high: 0.25 },
  "1536x1024": { low: 0.016, medium: 0.063, high: 0.25 },
};

export function estimateCostUsd(
  model: string,
  size: string,
  quality: string,
  n: number
): number | null {
  if (model !== "gpt-image-1") return null;
  const perImage = GPT_IMAGE_1[size]?.[quality];
  if (perImage == null) return null;
  return Number((perImage * n).toFixed(4));
}

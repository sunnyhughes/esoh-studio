/**
 * Per-job cost for generation_jobs.cost_usd (D9).
 *
 * Two functions, because there are two different questions:
 *
 *   costFromUsage()   — what a finished job actually cost. Computed from the
 *                       token counts the provider returns. Exact.
 *   estimateCostUsd() — what a job will cost before it is run. Needed to price
 *                       a batch up front ("generate every High priority Fall
 *                       page"), where no usage exists yet. Approximate.
 *
 * Verified 2026-09-04 against 29 real jobs. gpt-image-1 bills per token, and
 * image output tokens are fixed per size and quality — 1024x1536 comes back at
 * 408 / 1584 / 6240 for low / medium / high, 1024x1024 at 272 / 1056 / 4160.
 * Every entry in the estimate table below is those counts at $40 per 1M, so
 * the two functions agree on output. They differ on input, which the estimate
 * cannot know and therefore ignores.
 */

/** USD per 1,000,000 tokens. */
const GPT_IMAGE_1_RATES = {
  textInput: 5.0,
  imageInput: 10.0,
  imageOutput: 40.0,
};

/** The shape gpt-image-1 returns. Every field is optional — never assume. */
type ProviderUsage = {
  input_tokens?: number;
  output_tokens?: number;
  input_tokens_details?: { text_tokens?: number; image_tokens?: number };
};

const num = (v: unknown): number | undefined =>
  typeof v === "number" && Number.isFinite(v) ? v : undefined;

/**
 * The provider interface types usage as `unknown` — deliberately, since each
 * provider returns its own shape. Narrowing belongs here, where the shape is
 * actually known.
 */
function asUsage(raw: unknown): ProviderUsage | null {
  if (typeof raw !== "object" || raw === null) return null;
  const u = raw as Record<string, unknown>;
  const d =
    typeof u.input_tokens_details === "object" && u.input_tokens_details !== null
      ? (u.input_tokens_details as Record<string, unknown>)
      : undefined;

  return {
    input_tokens: num(u.input_tokens),
    output_tokens: num(u.output_tokens),
    input_tokens_details: d
      ? { text_tokens: num(d.text_tokens), image_tokens: num(d.image_tokens) }
      : undefined,
  };
}

/**
 * Actual cost of a completed job, from the provider's own token counts.
 *
 * Counts input as well as output. Input is small today — about 1.5% across the
 * first 29 jobs — but reference images are billed as input image tokens, and
 * feeding reference images in is the whole premise of the Style Library, so
 * this line grows as the project does.
 *
 * Returns null when usage is missing or the model is unpriced; the caller
 * should fall back to estimateCostUsd rather than record a zero.
 */
export function costFromUsage(model: string, raw: unknown): number | null {
  if (model !== "gpt-image-1") return null;
  const usage = asUsage(raw);
  if (!usage) return null;

  const outputTokens = usage.output_tokens ?? 0;
  const details = usage.input_tokens_details;

  // Fall back to the undifferentiated input count and price it as text, which
  // is the cheaper of the two — better to under-report than to invent a split.
  const textInput = details?.text_tokens ?? usage.input_tokens ?? 0;
  const imageInput = details?.image_tokens ?? 0;

  if (!outputTokens && !textInput && !imageInput) return null;

  const usd =
    (outputTokens * GPT_IMAGE_1_RATES.imageOutput +
      textInput * GPT_IMAGE_1_RATES.textInput +
      imageInput * GPT_IMAGE_1_RATES.imageInput) /
    1_000_000;

  return Number(usd.toFixed(4));
}

type Rates = Record<string, Record<string, number>>;

/** Output tokens at $40/1M. Input is not knowable in advance and is omitted. */
const GPT_IMAGE_1: Rates = {
  // size          low      medium    high
  "1024x1024": { low: 0.011, medium: 0.042, high: 0.167 },
  "1024x1536": { low: 0.016, medium: 0.063, high: 0.25 },
  // No landscape row. D29 bars 1536x1024 and the categories CHECK constraint
  // makes it unconfigurable, so a rate for it is a shape that cannot occur.
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

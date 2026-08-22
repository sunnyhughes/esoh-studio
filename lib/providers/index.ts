/**
 * Provider abstraction.
 *
 * Deliberately small (see 6.6 in docs/review-and-recommendations.md). The point
 * is that swapping providers touches ONE file — not that this is an extensible
 * plugin system on day one. A second provider gets added at Stage 4/5, when
 * upscaling forces the issue.
 */

import { generateOpenAI } from "./openai";

export type GenerateRequest = {
  prompt: string;
  size: string;
  quality: string;
  n: number;
  model?: string;
  /**
   * Style exemplars passed as image input (D20). Feeding two or three approved
   * pages holds a style across a long run far better than describing it in
   * words — Stage 1 drifted within three generations on text alone.
   *
   * D31: only our own approved work belongs here. The watermarked third-party
   * scans inform how blocks are written and must never be sent to the model.
   */
  referenceImages?: Buffer[];
  /** Transparent background, for apparel (D34). */
  transparent?: boolean;
};

export type GeneratedImage = {
  /** Raw PNG bytes. Storage is the caller's problem, not the provider's. */
  data: Buffer;
  index: number;
};

export type GenerateResult = {
  images: GeneratedImage[];
  model: string;
  providerJobId: string | null;
  usage: unknown | null;
};

export type Provider = (req: GenerateRequest) => Promise<GenerateResult>;

const PROVIDERS: Record<string, Provider> = {
  openai: generateOpenAI,
};

export const DEFAULT_PROVIDER = process.env.IMAGE_PROVIDER ?? "openai";

export function getProvider(name: string = DEFAULT_PROVIDER): Provider {
  const provider = PROVIDERS[name];
  if (!provider) {
    throw new Error(
      `Unknown image provider "${name}". Available: ${Object.keys(PROVIDERS).join(", ")}`
    );
  }
  return provider;
}

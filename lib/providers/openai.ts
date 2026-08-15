import OpenAI from "openai";
import type { GenerateRequest, GenerateResult } from "./index";

export const OPENAI_DEFAULT_MODEL = "gpt-image-1";

let client: OpenAI | null = null;

function getClient(): OpenAI {
  if (!process.env.OPENAI_API_KEY) {
    throw new Error(
      "OPENAI_API_KEY is not set. Add it to .env.local and restart the dev server."
    );
  }
  client ??= new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
  return client;
}

export async function generateOpenAI(
  req: GenerateRequest
): Promise<GenerateResult> {
  const model = req.model ?? OPENAI_DEFAULT_MODEL;

  const res = await getClient().images.generate({
    model,
    prompt: req.prompt,
    n: req.n,
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    size: req.size as any,
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    quality: req.quality as any,
  });

  // gpt-image-1 always returns base64; there is no URL response mode.
  const images = (res.data ?? []).flatMap((img, index) =>
    img.b64_json ? [{ data: Buffer.from(img.b64_json, "base64"), index }] : []
  );

  if (images.length === 0) {
    throw new Error("Provider returned no image data.");
  }

  return {
    images,
    model,
    providerJobId: null,
    usage: res.usage ?? null,
  };
}

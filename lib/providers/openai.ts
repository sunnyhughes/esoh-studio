import OpenAI, { toFile } from "openai";
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

  const refs = req.referenceImages ?? [];

  // With exemplars this becomes an edit call, which is how gpt-image-1 accepts
  // image input; without them it is a plain generation. Same prompt either way.
  const res = refs.length
    ? await getClient().images.edit({
        model,
        prompt: req.prompt,
        n: req.n,
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        size: req.size as any,
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        quality: req.quality as any,
        image: await Promise.all(
          refs.map((buf, i) =>
            toFile(buf, `reference-${i + 1}.png`, { type: "image/png" })
          )
        ),
        // Asked for either way. Omitted, gpt-image-1 falls back to `auto` and
        // decides for itself — and on sparse line art it decides transparent:
        // three African American Spring pages came back 80% clear with a
        // greyish RGB underneath, which reads as a dark page in any viewer that
        // composites on anything but white. Print was never affected, because
        // `padToPrint` flattens onto white, which is also why it went unnoticed.
        background: req.transparent
          ? ("transparent" as const)
          : ("opaque" as const),
      })
    : await getClient().images.generate({
        model,
        prompt: req.prompt,
        n: req.n,
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        size: req.size as any,
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        quality: req.quality as any,
        // Asked for either way. Omitted, gpt-image-1 falls back to `auto` and
        // decides for itself — and on sparse line art it decides transparent:
        // three African American Spring pages came back 80% clear with a
        // greyish RGB underneath, which reads as a dark page in any viewer that
        // composites on anything but white. Print was never affected, because
        // `padToPrint` flattens onto white, which is also why it went unnoticed.
        background: req.transparent
          ? ("transparent" as const)
          : ("opaque" as const),
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

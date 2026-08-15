import { NextResponse } from "next/server";
import { one, query } from "@/lib/db";
import { buildPrompt } from "@/lib/prompt-engine";
import { getProvider, DEFAULT_PROVIDER } from "@/lib/providers";
import { OPENAI_DEFAULT_MODEL } from "@/lib/providers/openai";
import { estimateCostUsd } from "@/lib/pricing";
import { assetKey, save } from "@/lib/storage";

export const dynamic = "force-dynamic";
// Image generation is slow; don't let the platform cut it off mid-flight.
export const maxDuration = 300;

type Body = {
  templateId: string;
  brandId: string;
  projectId: string;
  inputs: Record<string, string>;
  title?: string;
  size?: string;
  quality?: string;
  n?: number;
};

export async function POST(req: Request) {
  let jobId: string | null = null;

  try {
    const body = (await req.json()) as Body;

    if (!body.templateId || !body.brandId || !body.projectId) {
      return NextResponse.json(
        { error: "templateId, brandId and projectId are all required." },
        { status: 400 }
      );
    }

    // 1. Compose the prompt from the template's ordered blocks.
    const { template, prompt } = await buildPrompt(
      body.templateId,
      body.inputs ?? {}
    );

    // 2. Check every required variable actually arrived.
    const missing = (template.variables_json ?? [])
      .filter((v) => v.required && !(body.inputs?.[v.name] ?? "").trim())
      .map((v) => v.label);

    if (missing.length > 0) {
      return NextResponse.json(
        { error: `Missing required field(s): ${missing.join(", ")}` },
        { status: 400 }
      );
    }

    const settings = template.default_settings ?? {};
    const size = body.size ?? settings.size ?? "1024x1536";
    const quality = body.quality ?? settings.quality ?? "medium";
    const n = body.n ?? settings.n ?? 4;
    const model = OPENAI_DEFAULT_MODEL;

    // 3. Record the request BEFORE calling out, so a failure still leaves a
    //    trace with the exact prompt that caused it.
    const job = await one<{ id: string }>(
      `insert into generation_jobs
         (brand_id, project_id, job_type_id, prompt_template_id, title,
          prompt_text, inputs_json, provider_name, provider_model,
          params_json, status)
       values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,'processing')
       returning id`,
      [
        body.brandId,
        body.projectId,
        template.job_type_id,
        template.id,
        body.title ?? null,
        prompt,
        JSON.stringify(body.inputs ?? {}),
        DEFAULT_PROVIDER,
        model,
        JSON.stringify({ size, quality, n }),
      ]
    );
    jobId = job!.id;

    // 4. Generate.
    const result = await getProvider()({ prompt, size, quality, n, model });

    // 5. Persist each image, then its row.
    const assets = [];
    for (const image of result.images) {
      const key = assetKey(jobId, image.index);
      const bytes = await save(key, image.data);

      const [w, h] = size.split("x").map((v) => parseInt(v, 10));

      const asset = await one(
        `insert into generated_assets
           (generation_job_id, brand_id, project_id, asset_name, storage_path,
            width, height, file_size_bytes, source_variant_index, metadata_json)
         values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
         returning id, asset_name, storage_path, status, is_favorite,
                   source_variant_index`,
        [
          jobId,
          body.brandId,
          body.projectId,
          `${template.slug}-${image.index + 1}`,
          key,
          Number.isFinite(w) ? w : null,
          Number.isFinite(h) ? h : null,
          bytes,
          image.index,
          JSON.stringify({ size, quality }),
        ]
      );
      assets.push(asset);
    }

    // 6. Close the job out with usage and cost (D9).
    await query(
      `update generation_jobs
          set status = 'succeeded',
              completed_at = now(),
              usage_json = $2,
              cost_usd = $3,
              provider_model = $4
        where id = $1`,
      [
        jobId,
        result.usage ? JSON.stringify(result.usage) : null,
        estimateCostUsd(result.model, size, quality, result.images.length),
        result.model,
      ]
    );

    return NextResponse.json({ jobId, prompt, assets });
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);

    if (jobId) {
      await query(
        `update generation_jobs
            set status = 'failed', error_message = $2, completed_at = now()
          where id = $1`,
        [jobId, message]
      ).catch(() => {});
    }

    return NextResponse.json({ error: message }, { status: 500 });
  }
}

import { NextResponse } from "next/server";
import { one, query } from "@/lib/db";
import { buildPrompt } from "@/lib/prompt-engine";
import { getProvider, DEFAULT_PROVIDER } from "@/lib/providers";
import { OPENAI_DEFAULT_MODEL } from "@/lib/providers/openai";
import { estimateCostUsd } from "@/lib/pricing";
import { assetKey, save, read } from "@/lib/storage";

export const dynamic = "force-dynamic";
// Image generation is slow; don't let the platform cut it off mid-flight.
export const maxDuration = 300;

type Body = {
  templateId: string;
  /** Optional — defaults to the template's own category. */
  categoryId?: string;
  /** Optional. Set when generating against a planned item (docs/direction.md §5). */
  collectionId?: string;
  itemId?: string;
  /** D26 — selects the base style block. Required unless the item carries one. */
  artStyle?: string;
  /** D27 — Open | Medium | Dense. Optional; the art style sets its own if absent. */
  density?: string;
  /** Pass approved exemplars as image input (D20). Ignored if none are usable. */
  useReferences?: boolean;
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

    if (!body.templateId) {
      return NextResponse.json(
        { error: "templateId is required." },
        { status: 400 }
      );
    }

    // 1. When generating against a planned item, the item's own brief supplies
    //    the subject (D39: the item says WHAT, the style blocks say HOW). Values
    //    posted in `inputs` still win, so a one-off tweak needs no row edit.
    const item = body.itemId
      ? await one<{
          brief: string | null;
          art_style: string | null;
          background_density: string | null;
          brand_mark: string | null;
          ethnicity_line: string | null;
          season: string | null;
          page_type: string | null;
          hair: string | null;
          facial_hair: string | null;
          visual_elements: string | null;
          collection_id: string;
        }>(
          `select brief, art_style, background_density, brand_mark,
                  ethnicity_line, season, page_type, hair, facial_hair,
                  visual_elements, collection_id
             from items where id = $1`,
          [body.itemId]
        )
      : null;

    // A page of pattern has no figure, so the ethnicity line would read as a
    // stray instruction about someone who is not there (D62).
    const hasPeople =
      (
        await one<{ has_people: boolean }>(
          `select has_people from prompt_templates where id = $1`,
          [body.templateId]
        )
      )?.has_people ?? true;

    const inputs = { ...(body.inputs ?? {}) };
    if (item && !inputs.subject?.trim()) {
      inputs.subject = [
        item.brief,
        hasPeople && item.ethnicity_line
          ? `The figure is ${item.ethnicity_line}.`
          : "",
        item.season ? `The season is ${item.season}.` : "",
      ]
        .filter(Boolean)
        .join(" ");
    }
    if (item?.brand_mark && !inputs.brand_mark?.trim()) {
      inputs.brand_mark = item.brand_mark;
    }

    // Hair is item data, not a style rule (D45) — a block that names no style
    // leaves the model to copy the exemplar's, which is how filled hair kept
    // coming back. Left blank, the hair blocks drop out and hair goes unstated.
    if (item?.hair && !inputs.hair?.trim()) inputs.hair = item.hair;
    if (item?.facial_hair && !inputs.facial_hair?.trim()) {
      inputs.facial_hair = item.facial_hair;
    }

    // What is in the room comes from the item (D39). Without this the
    // {{environment}} block was dropped from every item-driven generation and
    // the setting was left entirely to the model.
    if (item?.visual_elements && !inputs.environment?.trim()) {
      inputs.environment = item.visual_elements;
    }

    const artStyle = body.artStyle ?? item?.art_style ?? null;
    const density = body.density ?? item?.background_density ?? null;

    const { template, prompt } = await buildPrompt(
      body.templateId,
      inputs,
      artStyle,
      density
    );

    // 2. A Quote page drawn by the Solo Portrait template is a silently wrong
    //    page, not an error, so it has to be caught here. Items with no page
    //    type set are left alone.
    if (item?.page_type && template.page_type &&
        item.page_type !== template.page_type) {
      return NextResponse.json(
        {
          error:
            `This item is a ${item.page_type}, but "${template.name}" draws ` +
            `${template.page_type} pages. Pick the matching template, or ` +
            `clear the item to describe the page by hand.`,
        },
        { status: 400 }
      );
    }

    // 3. Check every required variable actually arrived.
    const missing = (template.variables_json ?? [])
      .filter((v) => v.required && !(inputs[v.name] ?? "").trim())
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

    // 4. Record the request BEFORE calling out, so a failure still leaves a
    //    trace with the exact prompt that caused it.
    const job = await one<{ id: string }>(
      `insert into generation_jobs
         (category_id, collection_id, item_id, prompt_template_id, title,
          prompt_text, inputs_json, provider_name, provider_model,
          params_json, status)
       values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,'processing')
       returning id`,
      [
        body.categoryId ?? template.category_id,
        body.collectionId ?? item?.collection_id ?? null,
        body.itemId ?? null,
        template.id,
        body.title ?? null,
        prompt,
        JSON.stringify(body.inputs ?? {}),
        DEFAULT_PROVIDER,
        model,
        JSON.stringify({ size, quality, n, artStyle, density }),
      ]
    );
    jobId = job!.id;

    // 5. Generate. Exemplars are opt-in and only ever our own approved work —
    //    reference_images.usable_as_input is false by default (D31).
    const references = body.useReferences
      ? await query<{ storage_path: string }>(
          `select storage_path from reference_images
            where usable_as_input
              and (category_id = $1 or category_id is null)
            order by created_at desc limit 3`,
          [body.categoryId ?? template.category_id]
        )
      : [];

    const referenceImages = await Promise.all(
      references.map((r) => read(r.storage_path))
    );

    const result = await getProvider()({
      prompt,
      size,
      quality,
      n,
      model,
      referenceImages: referenceImages.length ? referenceImages : undefined,
    });

    // 6. Persist each image, then its row.
    const assets = [];
    for (const image of result.images) {
      const key = assetKey(jobId, image.index);
      const bytes = await save(key, image.data);

      const [w, h] = size.split("x").map((v) => parseInt(v, 10));

      const asset = await one(
        `insert into generated_assets
           (generation_job_id, category_id, collection_id, item_id, asset_name,
            storage_path, width, height, file_size_bytes, source_variant_index,
            metadata_json)
         values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
         returning id, asset_name, storage_path, status, is_favorite,
                   source_variant_index`,
        [
          jobId,
          body.categoryId ?? template.category_id,
          body.collectionId ?? item?.collection_id ?? null,
          body.itemId ?? null,
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

    // 7. Close the job out with usage and cost (D9).
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

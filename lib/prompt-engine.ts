import { query, one } from "./db";

/**
 * The prompt engine.
 *
 * A template does not store a prompt. It stores an ordered list of blocks, and
 * each block may contain {{variable}} slots. Building a prompt means:
 *
 *   1. load the blocks in order
 *   2. substitute the form values into their slots
 *   3. drop any block whose required slots came back empty
 *   4. join what remains
 *
 * Step 3 is what keeps optional fields from leaving debris like
 * "The surrounding environment is ." in the final prompt.
 */

export type TemplateVariable = {
  name: string;
  label: string;
  type: "text" | "textarea" | "select";
  required?: boolean;
  placeholder?: string;
  options?: string[];
};

export type TemplateSettings = {
  size?: string;
  quality?: string;
  n?: number;
};

export type Template = {
  id: string;
  name: string;
  slug: string;
  description: string | null;
  job_type_id: string;
  job_type_code: string;
  variables_json: TemplateVariable[];
  default_settings: TemplateSettings;
};

export type Block = {
  slug: string;
  kind: string;
  body_text: string;
  position: number;
};

const SLOT = /\{\{\s*([a-z0-9_]+)\s*\}\}/gi;

export async function getTemplates(): Promise<Template[]> {
  return query<Template>(`
    select t.id, t.name, t.slug, t.description, t.job_type_id,
           j.code as job_type_code, t.variables_json, t.default_settings
      from prompt_templates t
      join job_types j on j.id = t.job_type_id
     where t.is_active
     order by t.name
  `);
}

export async function getTemplate(id: string): Promise<Template | null> {
  return one<Template>(
    `
    select t.id, t.name, t.slug, t.description, t.job_type_id,
           j.code as job_type_code, t.variables_json, t.default_settings
      from prompt_templates t
      join job_types j on j.id = t.job_type_id
     where t.id = $1
  `,
    [id]
  );
}

export async function getBlocks(templateId: string): Promise<Block[]> {
  return query<Block>(
    `
    select b.slug, b.kind, b.body_text, tb.position
      from template_blocks tb
      join prompt_blocks b on b.id = tb.block_id
     where tb.template_id = $1
       and b.is_active
     order by tb.position
  `,
    [templateId]
  );
}

/** Which {{slots}} does this block reference? */
function slotsIn(text: string): string[] {
  return [...text.matchAll(SLOT)].map((m) => m[1].toLowerCase());
}

export function composePrompt(
  blocks: Block[],
  inputs: Record<string, string>
): string {
  const normalized: Record<string, string> = {};
  for (const [k, v] of Object.entries(inputs)) {
    normalized[k.toLowerCase()] = (v ?? "").trim();
  }

  const parts: string[] = [];

  for (const block of blocks) {
    const slots = slotsIn(block.body_text);

    // A block that references a slot the user left blank is dropped entirely,
    // rather than emitting a sentence with a hole in it.
    const hasEmptySlot = slots.some((s) => !normalized[s]);
    if (slots.length > 0 && hasEmptySlot) continue;

    const rendered = block.body_text.replace(SLOT, (_m, name: string) =>
      normalized[String(name).toLowerCase()] ?? ""
    );

    const trimmed = rendered.trim();
    if (trimmed) parts.push(trimmed);
  }

  return parts.join(" ");
}

/** Load a template, compose its prompt, and hand back everything the job needs. */
export async function buildPrompt(
  templateId: string,
  inputs: Record<string, string>
): Promise<{ template: Template; prompt: string; blocks: Block[] }> {
  const template = await getTemplate(templateId);
  if (!template) throw new Error(`Template not found: ${templateId}`);

  const blocks = await getBlocks(templateId);
  if (blocks.length === 0) {
    throw new Error(`Template "${template.name}" has no blocks attached.`);
  }

  return { template, prompt: composePrompt(blocks, inputs), blocks };
}

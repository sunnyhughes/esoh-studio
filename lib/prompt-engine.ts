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
  /** `combo` offers options in a dropdown but still accepts anything typed. */
  type: "text" | "textarea" | "select" | "combo";
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
  category_id: string;
  category_code: string;
  page_type: string | null;
  variables_json: TemplateVariable[];
  default_settings: TemplateSettings;
};

export type Block = {
  slug: string;
  kind: string;
  body_text: string;
  position: number;
  art_style: string | null;
  background_density: string | null;
};

const SLOT = /\{\{\s*([a-z0-9_]+)\s*\}\}/gi;

export async function getTemplates(): Promise<Template[]> {
  return query<Template>(`
    select t.id, t.name, t.slug, t.description, t.category_id, t.page_type,
           c.code as category_code, t.variables_json, t.default_settings
      from prompt_templates t
      join categories c on c.id = t.category_id
     where t.is_active
     order by t.name
  `);
}

export async function getTemplate(id: string): Promise<Template | null> {
  return one<Template>(
    `
    select t.id, t.name, t.slug, t.description, t.category_id, t.page_type,
           c.code as category_code, t.variables_json, t.default_settings
      from prompt_templates t
      join categories c on c.id = t.category_id
     where t.id = $1
  `,
    [id]
  );
}

/**
 * Art style (D26) crosses page type (D17), so a template carries every
 * art-style variant of its base_style block and exactly one is chosen here.
 * Blocks with art_style null apply to every style.
 *
 * Passing no art style yields only the universal blocks — useful for seeing
 * what a template contributes on its own, but it will not produce a usable
 * page, since the base_style block is where the drawing style is described.
 */
export async function getBlocks(
  templateId: string,
  artStyle?: string | null,
  density?: string | null
): Promise<Block[]> {
  return query<Block>(
    `
    select b.slug, b.kind, b.body_text, tb.position,
           b.art_style, b.background_density
      from template_blocks tb
      join prompt_blocks b on b.id = tb.block_id
     where tb.template_id = $1
       and b.is_active
       and (b.art_style is null or b.art_style = $2)
       and (b.background_density is null or b.background_density = $3)
     order by tb.position
  `,
    [templateId, artStyle ?? null, density ?? null]
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
  inputs: Record<string, string>,
  artStyle?: string | null,
  density?: string | null
): Promise<{ template: Template; prompt: string; blocks: Block[] }> {
  const template = await getTemplate(templateId);
  if (!template) throw new Error(`Template not found: ${templateId}`);

  const blocks = await getBlocks(templateId, artStyle, density);
  if (blocks.length === 0) {
    throw new Error(`Template "${template.name}" has no blocks attached.`);
  }

  if (!blocks.some((b) => b.kind === "base_style")) {
    throw new Error(
      artStyle
        ? `No base style block for art style "${artStyle}".`
        : "An art style is required — it supplies the base style block."
    );
  }

  return { template, prompt: composePrompt(blocks, inputs), blocks };
}

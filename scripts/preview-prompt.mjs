// Compose a prompt and print it, without generating anything.
//
// The prompt is assembled from blocks at generation time, so the only way to
// read one used to be to pay for an image. This mirrors getBlocks() and
// composePrompt() from lib/prompt-engine.ts against the live database.
//
//   npm run prompt:preview -- <template-slug> "<Art Style>" key=value ...
//
// It reports which blocks were dropped for a blank slot, which is usually the
// thing that is wrong when a prompt comes out shorter than expected.

import pg from "pg";

const [, , templateSlug, artStyle, ...pairs] = process.argv;

if (!templateSlug || !artStyle) {
  console.error(
    'usage: npm run prompt:preview -- <template-slug> "<Art Style>" key=value ...'
  );
  process.exit(1);
}

const inputs = {};
for (const pair of pairs) {
  const eq = pair.indexOf("=");
  if (eq < 0) continue;
  inputs[pair.slice(0, eq).trim().toLowerCase()] = pair.slice(eq + 1).trim();
}

const client = new pg.Client({ connectionString: process.env.DATABASE_URL });
await client.connect();

const { rows } = await client.query(
  `select b.slug, b.kind, b.body_text, tb.position
     from template_blocks tb
     join prompt_blocks b on b.id = tb.block_id
     join prompt_templates t on t.id = tb.template_id
    where t.slug = $1
      and b.is_active
      and (b.art_style is null or b.art_style = $2)
      and b.background_density is null
    order by tb.position`,
  [templateSlug, artStyle]
);

await client.end();

if (rows.length === 0) {
  console.error(`No blocks for template "${templateSlug}" / "${artStyle}".`);
  process.exit(1);
}

const SLOT = /\{\{\s*([a-z0-9_]+)\s*\}\}/gi;
const parts = [];
const dropped = [];

for (const block of rows) {
  const slots = [...block.body_text.matchAll(SLOT)].map((m) =>
    m[1].toLowerCase()
  );
  if (slots.length > 0 && slots.some((s) => !inputs[s])) {
    dropped.push(`${block.slug} (${slots.filter((s) => !inputs[s]).join(", ")})`);
    continue;
  }
  const rendered = block.body_text
    .replace(SLOT, (_m, name) => inputs[String(name).toLowerCase()] ?? "")
    .trim();
  if (rendered) parts.push(rendered);
}

const prompt = parts.join(" ");

console.log(`${parts.length} blocks used, ${prompt.length} characters`);
if (dropped.length) console.log(`dropped for a blank slot: ${dropped.join("; ")}`);
console.log(`\n${prompt}\n`);

// Compose a prompt and print it, without generating anything.
//
// The prompt is assembled from blocks at generation time, so the only way to
// read one used to be to pay for an image.
//
//   npm run prompt:preview -- <template-slug> "<Art Style>" key=value ...
//
// It reports which blocks were dropped for a blank slot, which is usually the
// thing that is wrong when a prompt comes out shorter than expected.
//
// This calls composePrompt() itself rather than mirroring it. The .mjs version
// could not — a .mjs file cannot import a .ts module — so it carried a copy of
// the twenty lines that decide what prompt your money buys. The copy happened
// to agree, but a preview that reimplements the generator can drift from it
// silently, and there would be no reason to suspect the preview. Node strips
// types natively but not extensionless imports, and lib/ uses those, so tsx
// runs it — one dev dependency against a copy of the generator's core.

import { composePrompt, getBlocks, type Block } from "@/lib/prompt-engine";
import { one, pool } from "@/lib/db";

const [, , templateSlug, artStyle, ...pairs] = process.argv;

if (!templateSlug || !artStyle) {
  console.error(
    'usage: npm run prompt:preview -- <template-slug> "<Art Style>" key=value ...'
  );
  process.exit(1);
}

const inputs: Record<string, string> = {};
for (const pair of pairs) {
  const eq = pair.indexOf("=");
  if (eq < 0) continue;
  inputs[pair.slice(0, eq)] = pair.slice(eq + 1);
}

const template = await one<{ id: string }>(
  `select id from prompt_templates where slug = $1`,
  [templateSlug]
);

if (!template) {
  console.error(`No template with slug "${templateSlug}".`);
  process.exit(1);
}

const blocks: Block[] = await getBlocks(template.id, artStyle);

if (blocks.length === 0) {
  console.error(`No blocks for template "${templateSlug}" / "${artStyle}".`);
  process.exit(1);
}

const prompt = composePrompt(blocks, inputs);

// composePrompt drops a block silently, which is the right behaviour when
// generating and the wrong one when explaining. Re-derive what it dropped by
// composing each block alone: if a block survives on its own it was kept.
const dropped = blocks
  .filter((b) => composePrompt([b], inputs) === "")
  .map((b) => b.slug);

console.log(
  `${blocks.length - dropped.length} of ${blocks.length} blocks used, ` +
    `${prompt.length} characters`
);
if (dropped.length) {
  console.log(`dropped for a blank slot: ${dropped.join(", ")}`);
}
console.log(`\n${prompt}\n`);

await pool.end();

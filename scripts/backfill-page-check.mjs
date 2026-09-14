/**
 * Measure every coloring page already on disk against the export checklist
 * (`lib/page-check.ts`) and record the result beside the transparency report.
 *
 * Run once after 068. Existing pages were generated before the check existed,
 * and a metric with no history cannot say whether anything is getting better —
 * which is the whole reason the library was built (D128).
 */
import { readFileSync } from "node:fs";
import { execSync } from "node:child_process";
import path from "node:path";

const url = execSync("grep -E '^DATABASE_URL' .env.local").toString().split("=").slice(1).join("=").trim();
const { default: pg } = await import("pg");
const pool = new pg.Pool({ connectionString: url });

const { rows } = await pool.query(`
  select g.id, g.storage_path, i.ref
    from generated_assets g
    join categories c on c.id = g.category_id
    left join items i on i.id = g.item_id
   where c.code = 'coloring-books' and g.purged_at is null
     and (g.metadata_json -> 'pageCheck') is null
   order by g.created_at`);

const { inspectPage } = await import("../lib/page-check.ts").catch(() => ({}));
if (!inspectPage) { console.error("run with: npx tsx scripts/backfill-page-check.mjs"); process.exit(1); }

let done = 0, failed = 0;
for (const r of rows) {
  try {
    const buf = readFileSync(path.join("storage", r.storage_path));
    const report = await inspectPage(buf);
    await pool.query(
      `update generated_assets
          set metadata_json = jsonb_set(metadata_json, '{pageCheck}', $2::jsonb, true)
        where id = $1`,
      [r.id, JSON.stringify(report)]);
    done++;
    if (!report.ok) failed++;
  } catch (e) {
    console.error(`  ${r.ref ?? r.id}: ${e.message}`);
  }
}
console.log(`measured ${done} pages; ${failed} over the grey-fill line`);
await pool.end();

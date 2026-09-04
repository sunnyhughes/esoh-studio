// Delete image files for assets already judged, and keep their rows.
//
//   npm run storage:purge                                 dry run, rejected, 30d
//   npm run storage:purge -- --older-than 7d              narrower window
//   npm run storage:purge -- --status draft               a different verdict
//   npm run storage:purge -- --yes                        actually delete
//
// Dry run is the default and --yes is the only way past it. The point is to
// reclaim disk without losing the record: cost (D9), resolved prompt, lineage
// (D85) and the verdict all live on the row, and the row survives. What goes
// is the picture.
//
// Three things are never purged, and the third is the one that bites:
//
//   1. approved — the kept work, obviously.
//   2. anything a style reference points at — the exemplars teach every page
//      generated after them (D22, D91), and reference_images.storage_path is
//      not the only way in; an approved asset can be the reference itself.
//   3. any asset that has derivatives. The print pipeline re-lays quote type
//      against the ORIGINAL art it was overlaid on, reached through
//      overlay.from / derived_from_asset_id (D61, D99). Purge the parent and
//      the lettered child stops being printable — silently, until an export
//      is attempted months later.

import { promises as fs } from "node:fs";
import { query, pool } from "@/lib/db";
import { resolveKey } from "@/lib/storage";

type Row = {
  id: string;
  asset_name: string;
  storage_path: string;
  status: string;
  file_size_bytes: string | null;
  created_at: Date;
  protected_reason: string | null;
};

function arg(name: string, fallback: string): string {
  const i = process.argv.indexOf(`--${name}`);
  return i !== -1 && process.argv[i + 1] ? process.argv[i + 1] : fallback;
}

const status = arg("status", "rejected");
const olderThan = arg("older-than", "30d");
const commit = process.argv.includes("--yes");

if (!/^\d+d$/.test(olderThan)) {
  console.error(`--older-than takes a number of days like 30d, not "${olderThan}".`);
  process.exit(1);
}
const days = parseInt(olderThan, 10);

function mb(bytes: number): string {
  return `${(bytes / 1024 / 1024).toFixed(1)} MB`;
}

const rows = await query<Row>(
  `select a.id, a.asset_name, a.storage_path, a.status, a.file_size_bytes,
          a.created_at,
          case
            when a.status = 'approved' then 'approved'
            when exists (select 1 from reference_images r
                          where r.asset_id = a.id) then 'is a style reference'
            when exists (select 1 from generated_assets d
                          where d.derived_from_asset_id = a.id)
              then 'has derivatives that print against it'
          end as protected_reason
     from generated_assets a
    where a.status = $1
      and a.purged_at is null
      and a.created_at < now() - ($2 || ' days')::interval
    order by a.created_at`,
  [status, String(days)]
);

if (rows.length === 0) {
  console.log(`Nothing ${status} older than ${days} days is still on disk.`);
  await pool.end();
  process.exit(0);
}

const purgeable = rows.filter((r) => !r.protected_reason);
const held = rows.filter((r) => r.protected_reason);

const bytesOf = (rs: Row[]) =>
  rs.reduce((n, r) => n + Number(r.file_size_bytes ?? 0), 0);

console.log(
  `${rows.length} ${status} asset(s) older than ${days} days:\n` +
    `  ${purgeable.length} purgeable — ${mb(bytesOf(purgeable))}\n` +
    `  ${held.length} held back — ${mb(bytesOf(held))}\n`
);

for (const r of held) {
  console.log(`  HELD  ${r.asset_name.padEnd(28)} ${r.protected_reason}`);
}
if (held.length) console.log();

for (const r of purgeable) {
  const when = r.created_at.toISOString().slice(0, 10);
  console.log(
    `  purge ${r.asset_name.padEnd(28)} ${when}  ${mb(Number(r.file_size_bytes ?? 0))}`
  );
}

if (!commit) {
  console.log(
    `\nDry run. Nothing was deleted. Re-run with --yes to free ` +
      `${mb(bytesOf(purgeable))}.`
  );
  await pool.end();
  process.exit(0);
}

let freed = 0;
let gone = 0;
let missing = 0;

for (const r of purgeable) {
  try {
    await fs.unlink(resolveKey(r.storage_path));
    freed += Number(r.file_size_bytes ?? 0);
    gone++;
  } catch (err) {
    // A file already absent is not a failure — the row still needs marking, or
    // it will be offered for purging again on every future run.
    if ((err as NodeJS.ErrnoException).code !== "ENOENT") throw err;
    missing++;
  }
  await query(`update generated_assets set purged_at = now() where id = $1`, [
    r.id,
  ]);
}

console.log(
  `\nPurged ${gone} file(s), freed ${mb(freed)}.` +
    (missing ? ` ${missing} row(s) had no file on disk and were marked.` : "") +
    `\nEvery row survives — cost, prompt, lineage and verdict are unchanged.`
);

await pool.end();

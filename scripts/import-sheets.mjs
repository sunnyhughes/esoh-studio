#!/usr/bin/env node
/**
 * Imports the production spreadsheets into collections + items.
 *
 *   npm run db:import
 *
 * Both sheets are living documents (docs/direction.md §4), so this is written
 * to be re-run after every export: rows are matched on (collection, ref) and
 * updated in place. Re-running never duplicates.
 *
 * Columns filled in the app are NOT clobbered by re-import. Only fields the
 * sheet is authoritative for get overwritten, and then only when the sheet
 * actually has a value — so an art_style chosen in the app survives a re-import
 * from a sheet whose Art Style column is still blank.
 */

import { readFile } from "node:fs/promises";
import path from "node:path";
import pg from "pg";

const ROOT = process.cwd();
const REF = path.join(ROOT, "docs", "references");

const TRACKER = "recovery_coloring_book_tracker(1).xlsx - recovery_coloring_book_tracker.csv";
const VVSTYLES = "vv-styles-master.csv";

/**
 * RFC 4180 parser. direction.md §4 warns that quoted fields contain commas
 * ("Braids, flowers, hearts, doves...") — a split(",") would shred those rows.
 */
function parseCsv(text) {
  const rows = [];
  let row = [], field = "", quoted = false;

  for (let i = 0; i < text.length; i++) {
    const ch = text[i];
    if (quoted) {
      if (ch === '"') {
        if (text[i + 1] === '"') { field += '"'; i++; }
        else quoted = false;
      } else field += ch;
      continue;
    }
    if (ch === '"') quoted = true;
    else if (ch === ",") { row.push(field); field = ""; }
    else if (ch === "\r") continue;
    else if (ch === "\n") { row.push(field); rows.push(row); row = []; field = ""; }
    else field += ch;
  }
  if (field !== "" || row.length) { row.push(field); rows.push(row); }

  const header = rows.shift().map((h) => h.replace(/^﻿/, "").trim());
  return rows
    .filter((r) => r.some((c) => c.trim() !== ""))
    .map((r) => Object.fromEntries(header.map((h, i) => [h, (r[i] ?? "").trim()])));
}

const slugify = (s) =>
  s.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");

/**
 * D19: the Hispanic line carries Spanish quotes, and quote_lang decides which
 * overlay treatment a page gets. Derive it from the ethnicity line, not from
 * the text — only 3 of the 12 Spanish quotes contain an accented character
 * ("Un día a la vez" does, "Poco a poco" does not), so sniffing for accents
 * mislabels three quarters of them as English.
 */
const quoteLang = (ethnicityLine) => (ethnicityLine === "Hispanic" ? "es" : "en");

const STATUS = {
  "": "idea", idea: "idea", "brief ready": "brief_ready", "prompt ready": "prompt_ready",
  generated: "generated", "revision needed": "revision_needed", approved: "approved",
  "mockup ready": "mockup_ready", launched: "launched", archived: "archived",
};

if (!process.env.DATABASE_URL) {
  console.error("✗ DATABASE_URL is not set. Check .env.local");
  process.exit(1);
}

const client = new pg.Client({ connectionString: process.env.DATABASE_URL });
await client.connect();

const categoryId = async (code) => {
  const { rows } = await client.query("select id from categories where code = $1", [code]);
  if (!rows[0]) throw new Error(`category '${code}' missing — run db:migrate first`);
  return rows[0].id;
};

async function upsertCollection(catId, name) {
  const { rows } = await client.query(
    `insert into collections (category_id, slug, name) values ($1, $2, $3)
     on conflict (category_id, slug) do update set name = excluded.name
     returning id`,
    [catId, slugify(name), name]
  );
  return rows[0].id;
}

/**
 * coalesce(nullif(excluded.x,''), items.x) — the sheet wins when it has a
 * value, the existing row wins when the sheet's cell is blank.
 */
async function upsertItem(item) {
  const cols = [
    "collection_id", "category_id", "ref", "title", "brief", "page_type",
    "ethnicity_line", "season", "art_style", "lettering_style", "background_density",
    "quote_text", "quote_lang", "color_direction", "product_placement",
    "visual_elements", "priority", "status", "review_flag", "notes", "source_row",
  ];
  const keep = cols.filter(
    (c) => !["collection_id", "category_id", "ref", "title", "status", "source_row"].includes(c)
  );

  const sql = `
    insert into items (${cols.join(", ")})
    values (${cols.map((_, i) => `$${i + 1}`).join(", ")})
    on conflict (collection_id, ref) do update set
      title      = excluded.title,
      status     = excluded.status,
      source_row = excluded.source_row,
      ${keep.map((c) => `${c} = coalesce(nullif(excluded.${c}, ''), items.${c})`).join(",\n      ")}
    returning (xmax = 0) as inserted`;

  const { rows } = await client.query(sql, cols.map((c) => item[c] ?? null));
  return rows[0].inserted;
}

async function importTracker(catId) {
  const rows = parseCsv(await readFile(path.join(REF, TRACKER), "utf8"));
  const collections = new Map();
  let created = 0, updated = 0;

  for (const r of rows) {
    const line = r["ethnicity line"], season = r["season"];
    const name = `${line} — ${season}`;
    if (!collections.has(name)) collections.set(name, await upsertCollection(catId, name));

    const quote = r["quote text"] || null;
    const inserted = await upsertItem({
      collection_id: collections.get(name),
      category_id: catId,
      ref: r["title"],
      title: r["title"],
      brief: r["prompt notes"] || null,
      page_type: r["page type"] || null,
      ethnicity_line: line || null,
      season: season || null,
      quote_text: quote,
      quote_lang: quote ? quoteLang(line) : null,
      priority: r["commercial priority"] || null,
      status: "idea",
      source_row: JSON.stringify(r),
    });
    inserted ? created++ : updated++;
  }
  return { created, updated, collections: collections.size, rows: rows.length };
}

async function importVvStyles(catId) {
  const rows = parseCsv(await readFile(path.join(REF, VVSTYLES), "utf8"));
  const collections = new Map();
  let created = 0, updated = 0;

  for (const r of rows) {
    const name = r["Collection"] || "Unsorted";
    if (!collections.has(name)) collections.set(name, await upsertCollection(catId, name));

    const inserted = await upsertItem({
      collection_id: collections.get(name),
      category_id: catId,
      ref: r["Design ID"],
      title: r["Text / Quote"],
      // For apparel the quote IS the design; it is also the overlay text (D23).
      quote_text: r["Text / Quote"] || null,
      quote_lang: "en",
      brief: r["Visual Elements"] || null,
      visual_elements: r["Visual Elements"] || null,
      art_style: r["Art Style"] || null,
      lettering_style: r["Lettering Style"] || null,
      color_direction: r["Color Direction"] || null,
      product_placement: r["Product / Placement"] || null,
      priority: r["Priority"] || null,
      status: STATUS[(r["Status"] || "").toLowerCase()] ?? "idea",
      review_flag: r["Review Flag"] || null,
      notes: r["Notes"] || null,
      source_row: JSON.stringify(r),
    });
    inserted ? created++ : updated++;
  }
  return { created, updated, collections: collections.size, rows: rows.length };
}

try {
  await client.query("begin");
  const cb = await importTracker(await categoryId("coloring-books"));
  const vv = await importVvStyles(await categoryId("vv-styles"));
  await client.query("commit");

  const line = (n, s) =>
    `  ${n.padEnd(16)} ${String(s.rows).padStart(3)} rows  ->  ` +
    `${s.collections} collections, ${s.created} created, ${s.updated} updated`;
  console.log("✓ import complete");
  console.log(line("coloring-books", cb));
  console.log(line("vv-styles", vv));
} catch (err) {
  await client.query("rollback");
  console.error(`✗ ${err.message}`);
  process.exitCode = 1;
} finally {
  await client.end();
}

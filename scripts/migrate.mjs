#!/usr/bin/env node
/**
 * Minimal migration runner.
 *
 * Applies every .sql file in db/migrations in filename order exactly once,
 * recording what ran in schema_migrations. No framework, no config — the whole
 * point is that the SQL files stay readable as the source of truth.
 *
 *   npm run db:migrate      apply pending migrations
 *   npm run db:seed         apply db/seed.sql (idempotent, safe to re-run)
 */

import { readdir, readFile } from "node:fs/promises";
import path from "node:path";
import pg from "pg";

const MODE = process.argv[2] ?? "migrate";
const ROOT = process.cwd();

if (!process.env.DATABASE_URL) {
  console.error("✗ DATABASE_URL is not set. Check .env.local");
  process.exit(1);
}

const client = new pg.Client({ connectionString: process.env.DATABASE_URL });
await client.connect();

try {
  if (MODE === "seed") {
    const sql = await readFile(path.join(ROOT, "db", "seed.sql"), "utf8");
    await client.query(sql);
    console.log("✓ seed applied");
  } else {
    await client.query(`
      create table if not exists schema_migrations (
        filename   text primary key,
        applied_at timestamptz not null default now()
      )
    `);

    const dir = path.join(ROOT, "db", "migrations");
    const files = (await readdir(dir)).filter((f) => f.endsWith(".sql")).sort();

    const { rows } = await client.query("select filename from schema_migrations");
    const applied = new Set(rows.map((r) => r.filename));

    let count = 0;
    for (const file of files) {
      if (applied.has(file)) continue;
      const sql = await readFile(path.join(dir, file), "utf8");
      await client.query(sql);
      await client.query("insert into schema_migrations (filename) values ($1)", [
        file,
      ]);
      console.log(`✓ ${file}`);
      count++;
    }

    console.log(count === 0 ? "✓ already up to date" : `✓ ${count} migration(s) applied`);
  }
} catch (err) {
  console.error(`✗ ${err.message}`);
  process.exitCode = 1;
} finally {
  await client.end();
}

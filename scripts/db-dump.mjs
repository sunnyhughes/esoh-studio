// Dump the database to a timestamped file.
//
//   npm run db:dump            → backups/esoh-studio-YYYY-MM-DD-HHMM.sql
//   npm run db:dump -- /path   → somewhere else, ideally off this machine
//
// This runs in a Crostini container on a Chromebook, so "off this machine"
// starts one level out. The ChromeOS side is shared in at:
//
//   npm run db:dump -- "/mnt/chromeos/MyFiles/Esoh Backups/Esoh-studio backups"
//
// That survives the Linux container being reset, which is the likely failure
// and the one /backups does not cover. Dragging that folder into Google Drive
// from the Files app is what makes it survive the Chromebook.
//
// The schema is already in git as migrations and the seed data with it, so
// this is not for rebuilding the tool. It is for the judgments: which assets
// are approved, which are rejected, what each one cost, and what was derived
// from what. Nothing else records those, and Postgres here is as local and as
// unbacked as the container it runs in (D7, D89).
//
// Restore with:  psql "$DATABASE_URL" -f <file>

import { mkdir } from "node:fs/promises";
import { spawn } from "node:child_process";
import path from "node:path";

const url = process.env.DATABASE_URL;
if (!url) {
  console.error("DATABASE_URL is not set. Run through npm so .env.local loads.");
  process.exit(1);
}

const outDir = process.argv[2] ?? "backups";
await mkdir(outDir, { recursive: true });

const now = new Date();
const stamp =
  now.toISOString().slice(0, 10) +
  "-" +
  now.toISOString().slice(11, 16).replace(":", "");
const outFile = path.join(outDir, `esoh-studio-${stamp}.sql`);

// --clean --if-exists so a restore over an existing database replaces it
// rather than colliding. --no-owner because the role that restores may not be
// the role that dumped.
const args = ["--clean", "--if-exists", "--no-owner", "-f", outFile, url];

const child = spawn("pg_dump", args, { stdio: ["ignore", "inherit", "inherit"] });

child.on("error", (err) => {
  if (err.code === "ENOENT") {
    console.error("pg_dump not found. Install the postgresql client tools.");
    process.exit(1);
  }
  throw err;
});

child.on("exit", (code) => {
  if (code !== 0) {
    console.error(`pg_dump exited ${code}`);
    process.exit(code ?? 1);
  }
  console.log(`✓ ${outFile}`);
  console.log(
    "This file is gitignored on purpose — it is a copy, and a copy that only\n" +
      "lives beside the original is not a backup. Move it off this machine."
  );
});

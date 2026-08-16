# Session Notes

Handoff record. Written 2026-08-16 at the end of the first working session, so a
fresh session can pick up without re-deriving anything.

**Read `docs/direction.md` first.** It is the authority. This file only covers
what happened, what runs, and what will bite you.

---

## Where things stand in one paragraph

Esoh Studio is an internal image-production tool for Esoh Creations. A working
Stage 1 exists and has generated real images through OpenAI. Then the reference
images and production spreadsheets arrived and showed the design was aimed at
the wrong target, so **building stopped and the direction was rewritten**.
`docs/direction.md` is the result and supersedes the six earlier planning
documents. Nothing has been built against it yet. The next step is Stage A —
restructuring the schema and importing the spreadsheets.

---

## What exists and works

Verified end to end. Three real images generated, $0.048 total.

- Next.js 16.3 / React 19 / TypeScript, single app at `~/esoh-studio`
- PostgreSQL 15.19 local, database `esoh_studio`, 8 tables migrated and seeded
- Prompt engine: ordered block composition, `{{slot}}` substitution, and blocks
  with unfilled slots dropped whole rather than rendered with holes
- OpenAI `gpt-image-1` behind a one-file provider abstraction
- Jobs recorded **before** the provider call, so failures keep their prompt
- Cost and usage tracking per job
- Local disk storage behind an opaque key, served via `/api/files/[...path]`,
  ready to swap for R2
- Migration runner; seed upserts `prompt_blocks` so the Style Library re-tunes
  with `npm run db:seed` and no code change

## What is wrong with it

The machinery is sound. The **content loaded into it** was invented rather than
taken from Esoh's material, and the data model aims at the wrong shape. See
`direction.md` §2 and §4. Specifically:

- `brands` + `job_types` should collapse into one `categories` table
- no `collections` or `items` — so the 180-page plan has nowhere to live
- templates are keyed to "coloring page" rather than to the six **page types**
- Stage 1 assumed every page has a person; **half the page types have none**
- the seeded Style Library blocks are mine and produce generic results — discard

---

## Run it

```bash
sudo service postgresql start        # after a reboot
cd ~/esoh-studio
npm run dev                          # http://localhost:3000
npm run db:migrate                   # apply pending migrations
npm run db:seed                      # re-apply seed (idempotent, upserts blocks)
npm run typecheck
```

`.env.local` holds `DATABASE_URL`, `OPENAI_API_KEY` (set and working) and
`IMAGE_PROVIDER`. It is gitignored. `storage/` holds generated images and is
gitignored.

---

## Gotchas that cost time

| Trap | What happens | Do this |
|---|---|---|
| `pkill -f "next dev"` | The pattern matches the shell running it and kills your own command | Kill by PID from `ss -ltnp \| grep :3000` |
| Killing the dev server mid-request | `.next` cache corrupts; routes compile but return 404 | `rm -rf .next` and restart |
| Project on `/mnt/chromeos/MyFiles` | File watching is broken there, so hot reload never fires; writes are ~8x slower | Code stays on native ext4 at `~/esoh-studio` |
| Google Drive MCP | Authenticated as `sunshinehughes2011@gmail.com`; the sheets live in `esoh.email@esohcreations.com` | Cannot reach them. Use CSV exports in `docs/references/` |
| `git push` | SSH key has a passphrase, which cannot be typed non-interactively | The user runs the push themselves |
| Long negative prompt lists | Naming a thing makes image models *more* likely to draw it — "no borders" produced a border | State what is wanted, keep restrictions short |

---

## Loose ends

1. **Not pushed to GitHub.** Remote is set (`git@github.com:sunnyhughes/esoh-studio.git`,
   branch `main`, 5 commits). The user must run
   `git -C ~/esoh-studio push -u origin main` because of the key passphrase.
2. **`/mnt/chromeos/MyFiles/imagine` — everything worth keeping has been copied
   across.** The complete `build-plan.md` (12.5 KB; the copy first reviewed was
   truncated to 2.2 KB), `api-route-map.md`, and `continuationdiscussion.md` are
   all in `docs/` and committed. What remains there — 5 mock API route stubs and
   `packages/db/schema.sql` — is superseded by the working DB-backed build.
   The folder cannot be deleted from the Linux container (`/mnt/chromeos/MyFiles`
   is a ChromeOS-managed mount and denies permission); the user removes it via
   the ChromeOS Files app.
3. **The user is reading `direction.md`** and will report back on whether it
   matches their vision. Do not build against it until they confirm.

---

## How this session went wrong, so it does not repeat

Worth reading. The failure was not technical.

Stage 1 was built quickly and correctly, then the Style Library was seeded with
prompt text **written from scratch rather than taken from Esoh's own material**.
The images came out generic. Three tuning rounds followed, tuning invented text,
and each round introduced a new problem — flattening the subject's ethnicity in
one case, which mattered far more than the defect being fixed.

The user then supplied reference images and spreadsheets that had existed the
whole time. Measured against them, nearly every style rule written was inverted
(`direction.md` §3), and the data model was aimed at the wrong shape entirely.

Three lessons:

1. **Ask for existing material before generating substitutes.** The user had a
   180-row production plan and six reference images. They were never asked for.
2. **Placeholder content becomes the product if you tune it.** Three rounds of
   refinement made invented seed data look like a considered decision.
3. **The user's instinct to stop and review was right.** They said the direction
   felt wrong before there was evidence. There was.

---

## Next step

**Stage A — restructure and import.** No image generation.

1. Migrate `brands` + `job_types` → `categories`; add `collections`, `items`,
   `reference_images`
2. Import both CSVs — re-runnably, they are living documents
3. All 180 pages land as `items` with brief, page type, quote text and priority
4. Adopt `{data, meta, error}` envelope and `/api/v1` paths (D21)

**Done when** the production plan is queryable: *"show me every High priority
Fall quote page."*

Then Stage B builds the Style Library from the references and prompt notes, and
wires reference-image input — which `direction.md` §6 argues is the highest
-leverage unsolved problem, since 180 pages have to look like one book and style
drifted within three generations using text alone.

# Esoh Studio

Internal image production tool for Esoh Creations. Not a product — see
`docs/review-and-recommendations.md` §1.

Currently at **Stage 1**: one page, one coloring-page template, form → four
images → keep/reject/save.

## Setup

Requires Node 20+ and PostgreSQL 13+.

```bash
npm install
cp .env.example .env.local     # then add your OPENAI_API_KEY
npm run db:migrate
npm run db:seed
npm run dev                    # http://localhost:3000
```

### Postgres

Already installed and running locally. If it isn't running after a reboot:

```bash
sudo service postgresql start
```

The database, role and connection string were created during setup and are
already in `.env.local`.

### OpenAI key

`platform.openai.com` → **Billing** (add a payment method and credits) → **API
keys** → *Create new secret key*. A ChatGPT subscription does **not** cover API
usage; it is billed separately. New organizations may also need identity
verification before image models are enabled.

## Layout

```
app/
  page.tsx                 New Job form + results grid (the only screen)
  api/bootstrap/           form data: brands, projects, templates
  api/generate/            compose prompt → generate → store → record
  api/assets/[id]/         keep / reject
  api/files/[...path]/     serves stored images
lib/
  db.ts                    pg pool
  prompt-engine.ts         block composition + {{slot}} substitution
  providers/               provider abstraction (openai only, for now)
  pricing.ts               cost estimates — VERIFY AGAINST CURRENT PRICING
  storage.ts               local disk; swaps to R2 at Stage 3
db/
  migrations/              applied in filename order, tracked in schema_migrations
  seed.sql                 brands, job types, prompt blocks, first template
docs/                      PRD, design plan, build plan, schema notes, recommendations
storage/                   generated images (gitignored)
```

## How the prompt engine works

A template stores no prompt text. It stores an **ordered list of blocks**, and
each block may contain `{{variable}}` slots filled from the form.

```
cb-base         → "A black and white line art illustration…"
cb-subject      → "The subject is {{subject}}. The emotional tone is {{mood}}."
cb-composition  → "Full-page portrait composition…"
cb-environment  → "The surrounding environment is {{environment}}."
cb-linework     → "Clean, unbroken black outlines…"
cb-output       → "Pure white background. Pure black lines only."
cb-negative     → "Do not include: grey tones, shading, gradients…"
```

A block whose slots come back empty is **dropped whole**, so an unfilled
optional field never leaves a sentence with a hole in it.

Adding a template is a SQL insert — `variables_json` drives the form, so no
code changes are needed for new templates or fields.

## Reproducibility

Every job records the fully resolved prompt, the form inputs, the model, the
parameters, usage and estimated cost. `generation_jobs.prompt_text` is always
the exact string sent to the API — never the template. That is what makes a
result from six months ago reproducible.

Jobs are written **before** the provider is called, so failures leave a row
with the prompt that caused them.

## Scripts

| | |
|---|---|
| `npm run dev` | dev server |
| `npm run build` | production build |
| `npm run db:migrate` | apply pending migrations |
| `npm run db:seed` | apply seed data (idempotent) |
| `npm run typecheck` | `tsc --noEmit` |

## Known gaps

- **Print resolution.** Output tops out around 1024×1536. A KDP coloring page
  at 8.5×11 needs 2550×3300 @ 300 DPI. The upscale/DPI/bleed pipeline is
  Stage 4 — see §6.9 of the recommendations.
- **Cost figures in `lib/pricing.ts` are estimates** and need checking against
  current OpenAI pricing.
- No asset library yet. Generated images are reachable only from the results
  grid of the job that made them. That is Stage 3.

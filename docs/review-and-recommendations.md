# Review and Recommendations
## Project
Esoh Creations AI Image Studio

## Status
Draft v1

## Purpose
This document reviews the two planning sources produced so far — the Perplexity document set (`PRD.md`, `design-plan.md`, `build-plan.md`, `schema-notes.md`) and the ChatGPT architecture conversation — and consolidates them into a single direction for the project.

It states what each source got right, where they conflict, which decisions have been made, which remain open, and what the build order should be.

This document is the working direction. Where it conflicts with the earlier four documents, this document wins.

---

## 1. What This Project Is

The AI Image Studio is an **internal tool**, not a venture.

It exists to reduce the effort between "I need an image" and "I have a usable asset" for the businesses under Esoh Creations. It is not a product to be sold, licensed, or opened to clients.

This single constraint removes a large amount of scope that appears in the earlier documents:

**Removed from consideration entirely:**
- Stripe billing, paid credits, usage-based pricing
- Client request portal
- Public or client-facing views
- Team roles and granular permissions
- Multi-tenancy of any kind
- Marketing site, onboarding, signup

**Directly enabled by this constraint:**
- No authentication needed in early versions
- No `users` table needed until a second person uses the tool
- Localhost is a legitimate deployment target for a long time
- Design can prioritize speed of use over polish or explainability
- Breaking changes are cheap — there are no external users to migrate

The measure of success is simple: **does it save time on work that is already happening?** Nothing else needs to be optimized.

---

## 2. Summation — The Perplexity Documents

Four formal specification documents, written in the language of creative operations and digital asset management. The underlying thesis is that **this is an asset management system with a generator attached** — the value is in organization, metadata, retrieval, and approval state, not in generation itself.

### PRD.md
- V1 scope locked to six user outcomes: choose venture → start job from template → generate → save → set status → search/export
- Explicit non-goals section (no billing, no batch, no multi-provider, no client portal)
- 9 functional requirements, 6 acceptance criteria, 7 screens
- Assumes internal-only tool, one provider for V1

### design-plan.md
- Information architecture, navigation model, per-screen definitions
- Object hierarchy: Venture → Project → Generation Job → Generated Asset → Approval/Export state
- Four core user flows, interaction rules, empty-state requirements
- Sidebar app-shell layout, one dominant action per screen
- Calm, operational visual direction over decorative

### build-plan.md
- Phased hybrid approach: lock requirements → lean MVP → schema early → expand modules → advanced features last
- Stack: VS Code, GitHub, Netlify, Railway, PostgreSQL
- Monorepo: `apps/web`, `apps/api`, `packages/{db,ui,types}`, `docs/`
- **This file is incomplete.** It is truncated mid-code-block at the folder structure. Its own Purpose section promises development phases, technical modules, milestones, dependencies, and delivery order — none of which are present. Re-paste when convenient, though the build order in Section 7 of this document supersedes it.

### schema-notes.md
The strongest of the four documents. 12 tables with real reasoning behind them:

- `ventures`, `users`, `projects`, `job_types`, `prompt_templates`, `generation_jobs`, `generated_assets`, `asset_status_history`, `exports`, `tags`, `asset_tags`, `project_notes`
- `uuid` primary keys, `timestamptz` throughout, `text` + `check` constraints instead of Postgres enums (correct — enums are painful to evolve)
- Explicit foreign key indexing (Postgres does not index FKs automatically)
- Deletion strategy, migration order, seed data, naming conventions
- Sound `jsonb` guidance: use it for settings and provider responses, never for identity, status, paths, or timestamps

---

## 3. Summation — The ChatGPT Conversation

No documents — an architecture argument and a working philosophy. The underlying thesis is that **this is a control panel and a prompt compiler** — the value is in turning creative intent into consistent, repeatable production specifications.

Key positions:

- **Don't build a model.** Orchestrate existing image APIs. You are the orchestrator, not the model developer.
- **The Prompt Engine is the intellectual property.** Composable modules — `BASE_STYLE + SUBJECT + COMPOSITION + POSE + ENVIRONMENT + LIGHTING + COLOR + BRAND_RULES + PRINT_REQUIREMENTS + NEGATIVE_CONSTRAINTS + OUTPUT` — assembled by code rather than retyped each time.
- **Style Library.** Named, reusable instruction sets so that selecting "Adult Coloring → Summer → Cultural" already carries meaning the system understands.
- **Creative Director layer.** An LLM that converts loose intent into a structured production specification *before* any image is generated.
- **Provider abstraction.** `imageProvider.generate({ prompt, size, quality })` so OpenAI, FLUX, or Gemini are swappable without a rewrite.
- **Quality control layer.** An AI evaluates output against the brief and routes failures to revision.
- **n8n** for repetitive plumbing; **Canva** as a downstream output tool, never the brain.
- **Three modes:** Idea (messy input), Creative (controlled inputs), Production (output specifications).
- **Four stages:** Prototype → Production → Automation → ESOH Engine.
- Framing that matters: build this to reduce human effort between idea and asset, not to avoid paying for generation. The expensive resource is time, not API calls.
- The most useful single line: *"Don't build the spaceship first. Build the little machine that saves you 20 minutes every time you need an image."*

---

## 4. Where They Agree

Both independently arrived at the same foundation, which is strong evidence it is correct:

| Point | Status |
|---|---|
| Don't train or build an image model | Settled |
| PostgreSQL for structured data | Settled |
| Object storage for image files, never blobs in the database | Settled |
| Reusable prompt templates over retyping | Settled |
| Metadata is first-class, not an afterthought | Settled |
| One provider to start, don't hard-couple to it | Settled |
| Phased build, narrow first release | Settled |
| Build it yourself — don't hire out the core | Settled |

---

## 5. Where They Conflict

| Dimension | Perplexity | ChatGPT | Resolution |
|---|---|---|---|
| Center of gravity | Asset governance, retrieval, approval | Prompt construction, creative intent | **Both** — schema from Perplexity, prompt engine from ChatGPT |
| Prompt model | `template_text`, one flat string | Composable assembled modules | **ChatGPT** — see 6.1 |
| V1 size | 7 screens, 12 tables, monorepo | One form and a grid of results | **ChatGPT** — see 6.3 |
| Automation tooling | Not mentioned | n8n from stage 3 | **Defer** — see 6.4 |
| Provider strategy | One provider, hedged with `provider_name` column | Abstraction layer from day one | **Middle** — see 6.6 |
| Quality control | Human status: draft / approved / rejected | AI evaluation against brief | **Perplexity now, ChatGPT later** — see 6.8 |
| Project structure | Monorepo, separate web and api apps | Single frontend + Node backend | **Simplify further** — see 6.5 |

The prompt model conflict is the most important one, because it is the only disagreement that is expensive to fix later.

---

## 6. Recommendations

### 6.1 Perplexity's schema is the foundation. ChatGPT's prompt engine is the product.

Take `schema-notes.md` close to as-written — the conventions, constraints, indexing, and deletion strategy are all sound. But `prompt_templates.template_text` as a single flat string quietly discards ChatGPT's best idea. Fix it now; retrofitting composition after 200 templates exist is painful.

Add two tables:

```
prompt_blocks
  id            uuid primary key
  kind          text not null      -- see below
  slug          text not null
  label         text not null
  body_text     text not null
  venture_id    uuid null          -- null = global
  is_active     boolean not null default true
  created_at    timestamptz not null default now()
  updated_at    timestamptz not null default now()

  check (kind in ('base_style','subject','composition','environment',
                  'lighting','color','brand_rule','print_req',
                  'negative','output'))

template_blocks
  template_id   uuid not null references prompt_templates(id)
  block_id      uuid not null references prompt_blocks(id)
  position      integer not null
  primary key (template_id, block_id)
```

This is the Style Library. It is also the thing that makes this tool *yours* rather than a thin wrapper over an API.

**Keep `generation_jobs.prompt_text` exactly as Perplexity specified it** — the fully resolved string that actually hit the API, not the template. That one field is the difference between "I can recreate this" and "I have no idea what I did in March."

### 6.2 Ventures are business units. Job types are formats. Collections are groupings.

Both source documents leave this open, and it blocks the schema. Resolution:

- **Venture** = a real business unit with its own brand identity (Esoh Creations, VV-Styles)
- **Job type** = the production format (coloring page, social post, print design, brand concept)
- **Collection** = a thematic or seasonal grouping ("Fall Strength," "Summer Journaling")

Coloring Books and Social Content should **not** be ventures. If they are, "a social graphic for VV-Styles" has two possible homes and belongs properly to neither.

`collections` sits in Perplexity's future-expansion list. Pull it forward. It is a two-column table, it matches how the work is actually thought about ("make twelve for the Fall collection"), and it is the natural unit for batch generation later.

**Naming note:** because this tool is not itself a venture, the word `ventures` may read confusingly in the code. Consider renaming the table to `brands`. Functionally identical; `brands` states more plainly that the column answers "which of my businesses is this asset for?" Either choice is fine — decide once and stay consistent.

### 6.3 Cut V1 to three screens and six tables.

Perplexity's 7 screens and 12 tables are the right destination and the wrong starting point.

**Build now — 3 screens:**
1. New Job
2. Results Review
3. Asset Library

**Defer:**
- Dashboard — nothing to display yet; pure time-sink on day one
- Template Manager — seed templates directly in SQL until editing them by hand becomes annoying
- Project Workspace — the Library filtered by project covers this
- Settings — hardcode until something actually needs configuring

**Build now — 6 tables:**
`ventures` (or `brands`), `projects`, `job_types`, `prompt_templates` + `prompt_blocks` + `template_blocks`, `generation_jobs`, `generated_assets`

**Defer:**
`asset_status_history`, `exports`, `tags`, `asset_tags`, `project_notes`, `collections`, `users`

Every deferred table is purely additive — it bolts on without altering what exists, which is exactly why it can wait. Keep Perplexity's naming conventions so later migrations stack cleanly.

Skip `users` entirely for now. One person, one machine. Add it when a second human touches the system.

### 6.4 Skip n8n for V1.

This is a direct disagreement with the ChatGPT recommendation.

n8n is an **integration** tool, and V1 has nothing to integrate. Everything lives inside one Node process. Adding n8n now buys a second runtime, a second deploy target, webhook plumbing between them, and a second place to debug when an image fails to save.

The example given — "when an image is approved, save the file, create a thumbnail, update the database" — is roughly fifteen lines using `sharp`. It is not worth a second system.

n8n earns its place the moment work crosses system boundaries that aren't under this tool's control: Printful, Etsy, KDP, social scheduling, Canva. Bring it in at that point and it will clearly pay for itself.

### 6.5 Simplify the deployment story.

The `apps/web` + `apps/api` + `packages/{db,ui,types}` monorepo is a team structure applied to a solo build. It adds build configuration, cross-package imports, and version coordination in exchange for benefits that only appear with multiple contributors.

**Use one Next.js application** — UI and API routes in the same project, one repository, one deploy.

- App: Netlify or Vercel
- Database: Railway PostgreSQL
- Image storage: Cloudflare R2 — already familiar, and no egress fees, which matters when repeatedly pulling full-resolution print files

**Run it on localhost for the first several weeks.** No deploy, no auth, no CORS, no environment drift. Deploy when there is a concrete reason to — such as wanting it on a phone.

### 6.6 Provider abstraction: yes, but keep it small.

ChatGPT is right that provider lock-in is a real risk. Perplexity's schema already hedges correctly with a `provider_name` column.

Implement it as **one module** exposing `generate({ prompt, size, n, model })`, not an elaborate plugin architecture. One file, a switch, one implementation to start. The point is that swapping later touches one file — not that it is extensible on day one.

Add `provider_model` to `generation_jobs` alongside the existing `provider_name`. Model versions change more often than providers do.

### 6.7 Build the Creative Director as a compiler, not a chat.

The Creative Director layer is a genuinely good idea, but the implementation shape matters:

```
loose text  →  structured JSON specification  →  deterministic prompt string
```

Store the intermediate specification on the job. If it is a free-form conversation instead, results become non-reproducible and undebuggable — when one image comes out perfect and the next twenty don't, there is no way to find out why.

This is Stage 2 work, not Stage 1. Stage 1 uses hand-written templates.

### 6.8 Defer the AI quality-control loop.

It is the most exciting idea in the ChatGPT conversation and the least valuable right now.

LLM vision models are unreliable at exactly the judgments that matter here — "no gray shading," "large open coloring areas," "clean exterior lines." And a single person can evaluate four images visually in about ten seconds.

This becomes worth building when a batch is twenty or more images and each one is no longer being looked at individually. Revisit at Stage 5.

### 6.9 The gap neither source addressed: print output.

This is the issue most likely to cause real rework.

Image APIs return roughly 1024–1536px sRGB. A KDP coloring page at 8.5 × 11 inches requires **2550 × 3300 px at 300 DPI**. Apparel print files require more. Neither planning source contains a resolution, DPI, bleed, margin, or color-mode step anywhere in the pipeline — Perplexity's `exports` table records the format but nothing in the system produces it.

Plan a **preparation / derivative step**:
- Upscale to target print dimensions
- Set DPI metadata correctly
- Add bleed and safe margins per product
- Threshold line art to pure black and white (no anti-grey) for coloring pages
- Export PNG and print-ready PDF

Store results as `asset_derivatives` (already on Perplexity's future list) rather than overwriting originals. Always keep the original generation output untouched.

Discovering this at publish time means regenerating an entire collection.

### 6.10 Track reproducibility and cost from day one.

Neither source states this plainly, and it costs almost nothing to add now.

On every generation job, store: `provider_name`, `provider_model`, seed (where the provider supports it), the fully resolved prompt, the parameters json, the raw provider response, and **cost**.

Add `provider_model` and `cost_usd` to `generation_jobs`. Two columns. They answer the two questions that will actually come up months from now:

1. "How do I recreate that exact look?"
2. "What did this collection cost me?"

---

## 7. Build Order

### Stage 1 — The little machine
One page. One hardcoded coloring-page template. Form → image API → four results in a grid → save to disk and PostgreSQL. No authentication, no styling, localhost only.

**This is the stage that matters.** If it saves twenty minutes the first time it's used, everything after it is refinement. Scope: a weekend.

**Done when:** an image can go from idea to saved file without leaving the tool.

### Stage 2 — Make it yours
`prompt_blocks` and `template_blocks`. Seed the real Esoh styles. Add the remaining three job types. Introduce the Creative Director compiler.

**Done when:** prompts are no longer being retyped, and style is consistent across generations without effort.

### Stage 3 — Make it findable
Asset Library with venture, project, type, and status filters. Move image storage to Cloudflare R2. Add `asset_status_history`, `tags`, and `collections` when the need is actually felt.

**Done when:** a six-month-old asset can be located in under thirty seconds.

### Stage 4 — Make it printable
Derivative pipeline. DPI and dimension presets per product type. Print-ready export sets. `asset_derivatives` and `exports` tables.

**Done when:** an approved asset can go straight to KDP or a print vendor with no external processing.

### Stage 5 — Make it scale
Batch generation across a collection. Full provider abstraction with a second provider live. n8n for external integrations. AI quality-control evaluation loop.

**Done when:** "make twelve for the Fall collection" is a single action.

---

## 8. Decisions Made

| # | Decision | Rationale |
|---|---|---|
| D1 | Internal tool only — never a product | Removes billing, portal, permissions, multi-tenancy from all planning |
| D2 | Prompt blocks are composable, not flat strings | Expensive to retrofit; this is the core value of the tool |
| D3 | Ventures = business units; job types = formats; collections = groupings | Resolves an open question in both PRD and schema notes |
| D4 | V1 is 3 screens, 6 tables | Deferred items are purely additive |
| D5 | No n8n until external integrations exist | Second runtime with no integration work to justify it |
| D6 | Single Next.js app, not a monorepo | Monorepo overhead pays off only with multiple contributors |
| D7 | Localhost first, deploy later | No users to serve, no reason to add deployment complexity |
| D8 | No auth, no `users` table in V1 | Single operator |
| D9 | Store resolved prompt, model, seed, params, and cost on every job | Reproducibility and cost visibility; two columns now vs. impossible later |
| D10 | Print pipeline planned from the start, built at Stage 4 | Generation resolution does not meet print requirements |

---

## 9. Open Questions

Carried forward from the earlier documents, plus new ones. None of these block Stage 1.

**Naming and structure**
- `ventures` or `brands` as the table name? (See 6.2)
- What is the internal product name? "Esoh Creations AI Image Studio" is descriptive but long.

**Product**
- Does Results Review need side-by-side comparison, or is favorite/select sufficient?
- Should templates be global, venture-specific, or both? (Schema already supports both via nullable `venture_id`.)
- Which metadata must always be visible on an asset card?
- Should export be available from Results, Project, and Library — or only Library?

**Data**
- Should `generated_assets` support parent-child versioning (revisions of a specific image), or is a new job sufficient?
- Which metadata fields deserve first-class columns rather than `metadata_json`?
- File naming convention for exports — needs to be decided before Stage 4.

**Technical**
- Which image provider for Stage 1? Recommendation: whichever is already set up and paid for. It is one file to change later.
- Are print dimensions template-based or manually configurable?

---

## 10. What Carries Forward From Each Source

**Keep from Perplexity:**
- The entire schema conventions section — uuid, timestamptz, check constraints over enums, explicit FK indexes
- Deletion strategy and migration ordering
- `jsonb` guidance
- The `generation_jobs` / `generated_assets` split (request separated from outputs) — this is a genuinely good structural decision
- Screen definitions and empty-state requirements, as the destination
- The discipline of documented non-goals

**Keep from ChatGPT:**
- Composable prompt modules
- The Style Library concept
- Creative Director as an intent-to-specification layer
- Provider abstraction
- Idea / Creative / Production mode framing
- "Build the little machine first"
- The framing that time, not API cost, is what is being optimized

**Set aside for now:**
- n8n (until Stage 5)
- AI quality control (until Stage 5)
- Canva integration (useful later as an output destination, never as the brain)
- Monorepo structure
- Billing, portal, permissions — permanently, per D1

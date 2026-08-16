# Direction

## Project
Esoh Studio

## Status
Draft v1 — supersedes conflicting guidance in PRD.md, design-plan.md, build-plan.md, schema-notes.md, api-route-map.md and review-and-recommendations.md.

## Purpose
One document that consolidates the Perplexity document set, the ChatGPT architecture conversation, the working Stage 1 build, the reference images, and the two production spreadsheets into a single agreed direction.

Where this document conflicts with an earlier one, this document wins. Where it is silent, the earlier documents still apply.

---

## 1. What this is

An internal tool for producing images for Esoh Creations. Not a product, not a venture, not for sale.

### The actual problem

ChatGPT and Gemini cap image generation at roughly 3 per 24 hours. The Healing Seasons production plan is **180 pages**. At 3 a day that is two months of waiting, and the waiting is the bottleneck — not the generating.

The tool exists to remove that ceiling and to make 180 pages come out looking like one coherent book.

Two goals, in order:

1. **Generate on demand, at volume, without waiting.**
2. **Keep everything, organized, so it can be found and reused later.**

Export is a minor convenience. The library is the point.

---

## 2. Corrections to earlier documents

### 2.1 "Ventures" are output categories

Every earlier document treats `ventures` as business units and `job_types` as formats — two separate dimensions. That is wrong.

`vv-styles`, `coloring-books`, `print-designs`, `social-content` are **one dimension**: the kind of output being made, and therefore which presets, dimensions and templates apply.

- Choose **VV-Styles** → apparel dimensions and print options
- Choose **Coloring Book** → page dimensions, line-art templates
- Choose **Social Content** → platform aspect ratios

Decision: collapse `ventures` and `job_types` into a single table, **`categories`**.

This also retires the `brands` rename from the previous review. There is no brand dimension. There is one dimension, and it answers "what am I making?"

### 2.2 The Style Library must come from Esoh, not from me

Stage 1 seeded prompt blocks written from scratch. The results were generic because the prompts were generic. Three tuning rounds did not fix it, because the problem was authorship, not wording.

The Style Library is seeded from the spreadsheets and reference images. Nothing invented.

### 2.3 Asset Library moves up

The earlier plan put the library at Stage 3, behind style tuning. Storage and retrieval is the stated primary value, so it moves ahead of style refinement.

### 2.4 Batch generation is central, not deferred

Both earlier plans list batch as out of scope for V1. With a 180-page backlog and no rate limit, batch is a primary feature. It moves into the core.

### 2.5 Long negative prompt lists are counterproductive

Observed directly: a block reading "no decorative borders or page frames" produced a border. Removing the phrase entirely still produced one — because the reference style *has* borders and the model has learned that association.

Rule: state what is wanted. Keep restrictions short and specific. Do not enumerate fears.

---

## 3. What the reference images establish

Six reference pages define the target style. Measured against them, nearly every rule written in Stage 1 was inverted:

| Stage 1 rule | Reference reality |
|---|---|
| uniform line weight | bold on figures, fine on background — deliberate variation |
| no solid black areas | hair is dense intricate curl texture reading near-black |
| no text or lettering | "Healing Seasons" lettered on mugs — a brand signature |
| no borders or frames | every page has a black border; it is part of the style |
| centred subject, generous white space | dense environmental storytelling, edge to edge |
| simple interior detail only | cable-knit stitches, rug patterns, book spines, wood grain |

Confirmed style attributes:

- Dense, editorial line illustration with full environmental context
- Texture rendered as **pattern**, never as shading
- Recurring motifs: the Healing Seasons mug, seasonal foliage, candles, chunky knits, windows, books, lanterns
- Multiple figures and full scenes, not isolated portraits
- Black page border
- Ethnicity rendered specifically and respectfully, never generically

The references are 1024×1536 — exactly `gpt-image-1` output. The model is demonstrably capable of this style. The gap was entirely the prompt.

---

## 4. The real data model

The two spreadsheets reveal a structure no earlier document captured.

Both live in `docs/references/` as CSV exports. **Both are living documents** — incomplete and still being added to. Import must be re-runnable, never a one-time load.

### Spreadsheet A — book listing metadata
`keyword_listing_plan_african_american...csv` — 15 rows
`ethnicity_line | season | product_id | title | keywords | description`

Commercial data for store listings. **African American only so far**; Hispanic and Multiracial still to come.

### Spreadsheet B — page production plan
`recovery_coloring_book_tracker...csv` — 180 rows
`title | ethnicity_line | season | page_type | prompt_notes | quote_text | commercial_priority`

The production queue. 3 lines × 4 seasons × 15 pages = **180 pages**, verified.

Page type distribution:

| Page type | Count | Has figures |
|---|---|---|
| Solo portrait | 48 | yes |
| Community scene | 48 | yes |
| Quote page | 36 | no — decorative frame around open centre |
| Environment page | 24 | no |
| Symbol page | 12 | no |
| Decorative page | 12 | no |

Priority: 101 High, 51 Medium (remainder blank).

**Import note:** quoted fields contain commas ("Braids, flowers, hearts, doves, and healing motifs"). Use a real CSV parser.

**Ethnicity lines:** African American, Hispanic, **Multiracial** (the correct term — "Multicultural" appeared once in discussion and is not used)
**Seasons:** Spring, Summer, Fall, Winter
**Page types:** Solo portrait, Community scene, Quote page, Symbol page, Decorative page, Environment page
**Priority:** High / Medium

### 4.1 Page type is the template unit

This is the key insight. "Coloring page" is not a template — it is a category. The six **page types** are the templates, and each needs a different prompt structure:

| Page type | Needs |
|---|---|
| Solo portrait | one figure, environmental context, emotional tone |
| Community scene | multiple figures, interaction, shared space |
| Quote page | **rendered lettering** plus decorative border |
| Symbol page | motif cluster, no figures, no scene |
| Decorative page | pattern and object arrangement, no figures |
| Environment page | place as subject, no figures |

Half of these have **no human figure at all**. Stage 1 assumed every page had a person.

### 4.2 Quote pages require text rendering — in two languages

The Hispanic line carries Spanish quotes: *"Un día a la vez"*, *"Estoy creciendo con esperanza"*, *"Poco a poco"*.

Rendering accurate lettering is one of the harder things to ask of an image model, and accented Spanish is harder still. This deserves its own template treatment and probably its own quality check.

The Stage 1 blanket "no text" rule would have made every quote page fail.

### 4.3 Ethnicity is a data field, not a style setting

It varies per row and drives the subject. It belongs in the production data — never baked into a style block, and never applied as a global default.

---

## 5. Revised structure

```
categories          coloring-books, vv-styles, social-content, print-designs
   └── collections  a book, an apparel drop, a campaign
        └── items   one planned unit of work — a spreadsheet row
             └── generation_jobs
                  └── generated_assets
```

- **category** — what kind of output; carries dimension and format presets
- **collection** — a named body of work (e.g. "African American — Fall")
- **item** — one planned page/design, with its brief, priority and status
- **job** — one attempt at an item
- **asset** — one image returned

An item may have many jobs; a job many assets. That is how a page gets reworked without losing history.

Templates attach to a category and correspond to page types. The Style Library holds their blocks.

### What carries over from the Stage 1 build

Working and correct — kept as-is:
- generation pipeline, job-before-call recording, error capture
- provider abstraction, cost and usage tracking
- prompt-block composition with `{{slot}}` substitution and empty-block dropping
- local storage behind an opaque key, ready for R2
- migration runner and re-appliable seed

Needs migration:
- `brands` + `job_types` → `categories`
- add `collections`, `items`
- add `reference_images`
- templates keyed to page types

Adopted from `api-route-map.md`:
- `{data, meta, error}` response envelope
- `/api/v1` base path
- resource-oriented route naming

---

## 6. Style consistency is the core technical problem

180 pages must look like one book. Text prompts alone will not hold a style across 180 generations — Stage 1 demonstrated drift within *three*.

Planned approach, strongest first:

1. **Reference images as input.** `gpt-image-1` accepts image input. Feeding two or three approved pages as style exemplars is far more reliable than describing the style in words. Not mentioned in any earlier document; likely the highest-leverage change available.
2. **Style locked in blocks, subject varying per item.** Style blocks never mention ethnicity, subject or season.
3. **Approved pages become references.** Every approved page can be promoted to an exemplar, so the style tightens as the book progresses.

---

## 7. Revised build order

Stage numbering restarts here.

### Stage A — Restructure
Migrate to categories/collections/items. Import both spreadsheets. 180 items land in the database with briefs, page types, quotes and priorities.
**Done when:** the production plan is queryable — "show me every High priority Fall quote page."

### Stage B — Style Library from real material
Six page-type templates. Blocks derived from the reference images and prompt notes. Reference-image input wired in.
**Done when:** a generated Solo portrait is judged close enough to the references to use.

### Stage C — Library and retrieval
Asset library with filters across category, collection, item, page type, status, priority. Items show their attempts.
**Done when:** any page from any book is findable in seconds.

### Stage D — Batch
Generate a whole collection unattended. Review queue for the results.
**Done when:** "generate every High priority Fall page" is one action.

### Stage E — Print pipeline
Upscale to 300 DPI, page proportions, bleed and margins, print-ready PDF export.
**Done when:** an approved page can go straight to KDP.

### Stage F — Other categories
VV-Styles apparel, social content, print designs — with their own presets and templates.

Stage E may need to move earlier if publishing deadlines demand it.

---

## 8. Decisions

| # | Decision |
|---|---|
| D1 | Internal tool only. No billing, portal, permissions or multi-tenancy. |
| D2 | Prompts compose from ordered blocks, not flat strings. |
| D3 | **Superseded.** Ventures and job types collapse into one `categories` table. |
| D4 | Asset Library is a primary feature, ahead of style refinement. |
| D5 | No n8n until external integrations exist. |
| D6 | Single Next.js app. No monorepo. |
| D7 | Localhost first. |
| D8 | No auth, no `users` table. |
| D9 | Every job records resolved prompt, model, params, usage and cost. |
| D10 | Print pipeline planned from the start, built at Stage E. |
| D11 | **Superseded by D3.** |
| D12 | OpenAI `gpt-image-1` is the provider. |
| D13 | PostgreSQL runs locally. |
| D14 | Code lives at `~/esoh-studio`. |
| D15 | Git remote set up early; container files are not backed up. |
| D16 | Batch generation is a core feature, not deferred. |
| D17 | Page type is the template unit. Six templates for coloring books. |
| D18 | Ethnicity is production data, never a style setting or global default. |
| D19 | Quote pages render lettering, including accented Spanish. |
| D20 | Style consistency is driven by reference images, not longer prompts. |
| D21 | Adopt `{data, meta, error}` envelope and `/api/v1` paths. |
| D22 | Approved pages can be promoted to style references. |
| D23 | Quote text is overlaid as real type after generation, never drawn by the model. Guarantees correct spelling and accented Spanish, and allows restyling or translation without regenerating. Quote-page prompts must therefore **reserve clear empty space** for the type to land in. |
| D24 | **No page border at all.** Pages are borderless by design — the reference border was incidental, not wanted. Prompts generate borderless with a safe margin; the print pipeline adds nothing. Simpler than either earlier option. |
| D25 | The series is **3 lines × 4 seasons = 12 books, 180 pages.** Spreadsheet A is book-level listing metadata (title, keywords, description); its "flagship 1–4" rows are candidate listing copy, not separate books. |

---

## 9. Open questions

**Production**
- Are the 12 books published separately, or bundled as one series?
- Which font/treatment should overlaid quote type use? Needs to work for both English and accented Spanish.
- The keyword listing plan covers African American only. Hispanic and Multiracial listings are still to come.
- VV-Styles phrases and sayings are not yet recorded anywhere. A spreadsheet is planned, covering both in-production and new phrases.

**Style**
- Which references are canonical for each page type? Currently there are none for Symbol, Decorative or Quote pages.

**Structure**
- Do VV-Styles and social content need collections and items, or is coloring-book production the only planned workflow?
- Should the tool write back to the spreadsheets, or replace them?

**Technical**
- Verify the estimated rates in `lib/pricing.ts`.
- `gpt-image-1` offers 1024×1536 (2:3). A page is 8.5×11 (0.773:1). Crop, pad or outpaint?

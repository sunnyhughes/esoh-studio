# Healing Seasons — Project Outline

*Compiled 2026-08-16 from the files in this folder and the 38-page Perplexity thread.*
*Updated after rebuilding the template assignment matrix and prompt framework,*
*and again after the second batch of tracker files arrived.*

---

## 1. What the project is

**Healing Seasons** is a series of digital, printable adult coloring books built around
recovery — substance use, domestic violence, and mental illness — with culturally
specific representation and a seasonal rhythm.

The central creative rule, held consistently through the whole thread: the art is
**healing-centered, not crisis-centered**. No violence, no injury, no overdose or police
imagery. Support circles, journaling, gardens, porches, candles, quiet rooms,
affirmations.

Commercially it is **platform-neutral** by design — the listing copy was deliberately
kept free of Etsy-specific language so the same book sells on your own site, Gumroad,
Payhip, Shopify, or an Amazon-style storefront.

### Naming layer (proposed in the thread, not yet in any file)

- Master brand: **Healing Seasons Coloring Collection**
- African American line: **Rooted in Hope**
- Hispanic line: **Colores de Sanación**
- Multiracial line: **Many Shades of Healing**

Every title in `master_launch_sheet.csv` is descriptive instead
("African American Spring Flagship Recovery Coloring Book"). Open decision.

---

## 2. The shape of the catalog

**3 audience lines × 4 seasons × 15 pages = 12 books, 180 illustrations.**

All 180 pages already have a title, page type, written scene description, and priority
in `recovery_coloring_book_tracker.csv`.

### The 15-page formula (identical in every book)

| Count | Page type | Content |
|---|---|---|
| 4 | Solo portrait | One person in a healing moment — journaling, walking, breathwork, tea |
| 4 | Community scene | Support circles, family, mentors, friends — 2–5 people, never a crowd |
| 3 | Quote page | Short affirmation with seasonal border. **All 36 quotes are written.** |
| 2 | Environment page | Bedroom, reading nook, porch, wellness room — no people |
| 1 | Symbol page | Motif cluster — flowers, butterflies, doves, candles, hearts |
| 1 | Decorative page | Border-and-object page used as a pacing reset |

### Commercial layer on top

Four **product types** per line per season — Flagship (hero), Mindfulness, Renewal,
Self-Care — giving 48 catalog entries. 48 fully written listings exist.

Offer ladder: single book → season bundle → line bundle → master bundle.
Thread guidance: season bundle 2.5–3× a single book, line bundle 8–10×.
No actual dollar figures were ever set.

---

## 3. File inventory — five working groups

`[SOURCE]` marks the single source of truth for its group. When two files disagree,
that one wins.

### 00 · Strategy — what to build and how to sell it

| File | Rows | Holds | Status |
|---|---|---|---|
| `master_launch_sheet.csv` | 48 | Title, subtitle, slug, keywords, short/long description, audience, cover concept, priority | **[SOURCE]** |
| `catalog_structure_matrix.csv` | 48 | Priority, launch position, hero/core/support role | Ready |
| `bundle_matrix.csv` | 48 | Single / season / line / master bundle definitions | Conflict — see finding 1 |
| `pricing_tier_matrix.csv` | 48 | Offer ladder as $ / $$ / $$$ / $$$$ | No real prices |
| `release_calendar_matrix.csv` | 12 | Spring→Q1, Summer→Q2, Fall→Q3, Winter→Q4 | No dates |
| `keyword_listing_full_matrix.csv` | 48 | 4 alternate listing angles per line/season | Ad-copy bank |
| `keyword_listing_plan_african_american.csv` | 16 | First draft; warmer copy than the final matrix | Harvest, then archive |
| `keyword_listing_plan_hispanic_multiracial.csv` | 32 | Second draft | Archive |
| `Producttype-Purpose.csv` | 4 | Definitions of Flagship / Mindfulness / Renewal / Self-Care | Keep |

### 01 · Production — the 180 pages and the pipeline

| File | Rows | Holds | Status |
|---|---|---|---|
| `recovery_coloring_book_tracker.csv` | 180 | Every page: title, line, season, page type, scene, quote, priority | **[SOURCE]** |
| `template_page_assignment_matrix.csv` | 180 | Which of the 10 templates each page uses, plus page type, scene, detail load, assignment basis, repeat variant | **REBUILT** |
| `production_workflow_matrix.csv` | 12 | 8-phase pipeline, concept lock → launch prep | No dates or owners |
| `recovery_coloring_book_summary.csv` | 3 | A 3×4 grid of page counts | Redundant |
| `Productline-Seasonaleditions-...csv` | 3 | The 3 × 4 × 15 geometry | Reference |

### 02 · Design — how every page must look

| File | Rows | Holds | Status |
|---|---|---|---|
| `page_design_system.md` | — | Trim, bleed, margins, line weights, page types, trauma-informed rules, per-line representation, seasonal cues, export QA | **[SOURCE]** |
| `page_design_system.csv` | 38 | Same content as a checkable spec list | Ready |
| `page_template_library.md` | — | The 10 templates as design guidance, one per page type | **[SOURCE]** |
| `page_template_library.csv` | 10 | Layout formula, zones, white-space rule, detail load | **EXTENDED** |
| `art_direction_specs.csv` | 3 | Character/scene/line/detail/forbidden per line | All 3 rows identical |

### 03 · Prompts

| File | Rows | Holds | Status |
|---|---|---|---|
| `template_prompt_framework.csv` | 10 | Slotted prompt formula, composition and white-space directives, quote handling, negative list | **REBUILT** |
| `page_prompts_full.csv` | 180 | Every page's finished prompt, full and compact versions | **NEW** |
| `_archive_v1/` | 4 files | Pre-rebuild versions of the matrix, framework, and library | Backup |

### 04 · Reference

| File | Holds |
|---|---|
| `Rank-Platform-Bestfor-Whyitstandsout.csv` | Top 5 tools ranked with reasoning |
| `Platform-Quality-Speed-...csv` | Scored decision matrix, 6 criteria |
| `next_step_summary.md` | The 11-layer planning stack and where you stopped |
| `I want to make digital coloring books...pdf` | The complete thread — system of record |

### Referenced in the thread but missing from this folder

- `project_planning_index.md`
- `document_map.md`
- `page_template_production_system.md`

All three were indexes and maps. This document replaces them.

---

## 3b. The second batch

Ten more files arrived after the first review. Where batch one was *planning*, this is
*execution scaffolding* — every file is a tracker with status columns, an owner
(Sunshine), and blank cells waiting to be filled. Together they scope the Spring pilot
down to a buildable job. They come with their own priority order in
`Priority-Spreadsheet-Whyyouneedit.csv`, which is worth following.

| File | Rows | Scope | What it does |
|---|---|---|---|
| `illustration-production-tracker.csv` | 45 | Spring, 3 lines | Every page from prompt → draft → revision → cultural review → line art → PNG → PDF placement |
| `prompt-library-by-product-line.csv` | 45 | Spring, 3 lines | Hand-written prompt per page, split into base / representation / seasonal / page-specific / negative / print spec |
| `quote-and-affirmation-library.csv` | 36 | **All 4 seasons** | Every quote with language, category, motif, review status, translation status |
| `asset-and-file-naming-tracker.csv` | 45 | Spring, 3 lines | Source, line art, PNG, vector, PDF, folder path, version per page |
| `cover-and-thumbnail-tracker.csv` | 12 | Spring, 12 SKUs | Cover concept, character direction, colour direction, thumbnail layout, preview assets |
| `product-qa-checklist-tracker.csv` | 12 | Spring, 12 SKUs | 27 verification gates per product, incl. Spanish native review and trauma-informed review |
| `launch-asset-tracker.csv` | 12 | Spring, 12 SKUs | Description, keywords, cover, preview, mockup, pricing, email/social copy, publish status |
| `sales-and-feedback-tracker.csv` | 3 | Template | Empty structure with instructions for logging sales and feedback themes |
| `keyword-listing-plan-hispanic-multiracial.csv` | 16 | Hispanic + Multiracial, all seasons | Unique keywords, tags, descriptions per product |
| `Priority-Spreadsheet-Whyyouneedit.csv` | 8 | Index | The order to fill the eight trackers in, and why |

**The 12 Spring products now have real names:**

| | African American | Hispanic | Multiracial |
|---|---|---|---|
| Flagship | Rooted in Hope | Colores de Sanación | Many Shades of Healing |
| Mindfulness | Quiet Growth | Un Día a la Vez | Healing Has Many Faces |
| Renewal | Begin Again | Crecer con Esperanza | Safe to Grow |
| Self-Care | Gentle With Myself | Mi Paz Importa | My Joy Counts Too |

Product IDs follow `AA-SPR-FLAG` / `HSP-SPR-MIND` / `MUL-SPR-SC`. Titles and IDs agree
across all three product-level trackers — 12 of 12, no mismatches.

**Housekeeping done:** four files were downloaded twice (`… (1).csv`), byte-identical —
safe to delete. Three rows had unquoted commas that would have shifted columns on
import; those are repaired, with pre-fix copies in `_archive_v1/new_files_pre_fix/`.

---

## 4. Eight things that would have bitten you

Found by cross-checking the spreadsheets against each other and against the thread.
**Five are now closed** — two I rebuilt, three the second batch settled. Three remain
open, and one is new.

### 1. BLOCKING — The catalog is built for 48 products. The art is built for 12.

Every strategy file has 48 rows (4 product types per line per season). The tracker has
180 pages = 15 per line per season = **12 books**. There is no page content for a
separate Mindfulness, Renewal, or Self-Care edition. The bundle matrix quietly admits
this: its Master Bundle is described as "all 12 books," not 48.

Read literally, 4 product types × 12 books = **720 illustrations**. That is not the
project you designed.

**The second batch sharpens this rather than settling it.** The QA checklist gives all
four Spring products per line a `page_count_target` of **15** — but the illustration
tracker scopes only **15 pages per line** total. Four products each claiming the same
fifteen pages, or you owe yourself 60 pages per line per season. The cover tracker leans
the other way again, giving each of the four a distinct cover concept and preview set.

> **Recommended, unchanged:** keep 180 unique illustrations and make product types a
> *packaging* layer, not an art layer. Flagship = the full 15-page book. Mindfulness /
> Renewal / Self-Care = 8–10 page curated cuts from the same 15, each with its own cover
> and listing — which is exactly what the cover tracker has already designed.
> **Then change one number:** set `page_count_target` to 8–10 for the three non-Flagship
> products, so the QA gate stops asserting something you don't intend to build.
> This is now the single decision blocking everything else.

### 1b. NEW — Spring now exists twice, and the two versions disagree.

`illustration-production-tracker.csv` is **not** a re-sequencing of the old tracker. It is
a **re-authored Spring**: new page titles, new order, slightly different type mix.

- Old page 1: "Woman journaling by a rainy window" → New page 1: "Spring Renewal Journal"
- Old mix: 4 portrait / 4 community / 3 quote / 2 symbol / 2 environment
- New mix: 5 solo-type / 3 community / 3 quote / 2 interior / 2 symbol

So for the 45 Spring pages there are now two competing production sets — the new one, and
the 180-row matrix and prompt library I rebuilt from the old tracker. For the other 135
pages, only mine exists, and only the old tracker holds their scene descriptions.

> **Recommended split:** the **new Spring set wins** — better pacing, real page titles,
> richer per-page prompts, and it's the book you're about to build. Keep my 180-row files
> as the source for **Summer, Fall, and Winter only**, and convert each of those seasons
> into the new file's shape when you scope it.
>
> Two vocabularies need reconciling: the new files use `page_type` = template name
> ("Walking reflection"); the old ones use abstract types ("Solo portrait").

### 2. ~~BLOCKING~~ REBUILT — Roughly half the template assignments were wrong.

Joining `template_page_assignment_matrix.csv` to the tracker page by page: only
**84 of 180** rows got a template matching their page type. Templates had been rotated
by page number rather than chosen by content.

- All 12 Symbol pages → `TPL-04 Healing Room Interior` (a furniture-and-window layout)
- 24 of 36 Quote pages → `TPL-01 Solo Portrait` or `TPL-02 Support Circle`
- 36 of 48 Community scenes → quote, interior, and symbol layouts

**Rebuilt from the tracker's page type and scene text. All 180 rows now match**, and
assignment is content-aware rather than rotational — "Man walking at sunrise in a
neighborhood park" resolves to the walking template, "Woman journaling by a rainy
window" to the window template. New columns: `page type`, `scene`, `detail load`,
`assignment basis`, `repeat variant`.

**Two templates had to be added.** The original eight could not cover the content:
7 Environment pages are outdoor (patios, courtyards, community gardens) while TPL-04
is explicitly an interior, and the Decorative page type — 12 pages — had no template
defined anywhere.

- **TPL-09 Outdoor Sanctuary** — outdoor counterpart to TPL-04
- **TPL-10 Decorative Border & Pattern Page** — the missing Decorative template
- **TPL-07** renamed *Pair Conversation Scene* — what selects it is party size, not
  furniture (it now covers benches, tables, and walking pairs, not just porches)

> To stay at eight templates instead: fold TPL-09 into TPL-04 and TPL-10 into TPL-05.
> One find-and-replace in a single column.

### 3. ~~FIX FIRST~~ REBUILT — The prompt framework was a placeholder.

All 8 rows were the identical sentence with the template name swapped in. No season, no
audience line, no scene, no quote, no representation rule.

**Rebuilt as a slotted formula, and then run.** Two files:

- `template_prompt_framework.csv` — the formula plus per-template composition, white
  space, quote handling, line weight, and negative directives
- `page_prompts_full.csv` — **all 180 prompts fully assembled**, in a `full prompt`
  column and a `compact prompt` column for tools with short input fields

Each prompt carries: doc spec → scene → composition and zones → representation →
season cues → tone → line work → white space → text handling → negative list.

**Two things the assembly caught that a template alone would not:**

- Representation rules were going to pages that have no people on them — a reliable way
  to make an image tool put a person in your empty bedroom scene. The **84 people-free
  pages** (quote, symbol, decorative, environment) now carry an explicit no-figures
  directive instead.
- All **12 Hispanic quote pages** now carry an accent-verification instruction, since
  the quotes are Spanish and your export checklist already flags accents.

### 4. FIX FIRST — 48 listings share 4 keyword phrases.

Titles and slugs are all unique (48/48). But there are only **4 distinct primary-keyword
strings** and **4 distinct short descriptions** across all 48 products. Every Flagship
in the catalog carries the identical phrase and identical short description.

On your own site that's repetitive. On a search-driven storefront, 12 products competing
for one phrase suppress each other.

**Two-thirds solved.** `keyword-listing-plan-hispanic-multiracial.csv` now covers
Hispanic and Multiracial across all four seasons with genuinely unique primary keywords,
secondary keyword sets, 10-tag lists, and per-product descriptions written around the new
product names. A much better artifact than the launch-sheet columns it replaces.

> **What's left:** it covers two products per line per season, not four — so 16 rows
> covering 32 of 48 products, and the African American line is still on the old repeated
> phrases. Extend the same file to the AA line and the remaining two product types, then
> make it the keyword source of truth and stop maintaining those columns in
> `master_launch_sheet.csv`.

### 5. ~~FIX FIRST~~ SETTLED — The tracker's page order broke your own pacing rule.

The old tracker listed every book as 4 portraits → 4 community → 3 quote → symbol →
decorative → 2 environment: four straight group scenes in the middle of every book.

**The new illustration production tracker fixes this properly.** Spring is now
interleaved:

> solo · walking · window · community · **quote** · porch · interior · symbol ·
> **quote** · solo · community · interior · symbol · **quote** · window

Quote pages land at 5, 9, and 14. No two heavy pages sit back to back. All three lines
use the same rhythm.

> **Carry it forward:** Summer, Fall, and Winter still have the old block ordering. Reuse
> this exact 15-slot rhythm when you scope them rather than inventing a new one — that's
> what makes the books feel like a series.

### 6. ~~DECIDE~~ DECIDED — The Hispanic line's quotes are Spanish-only.

**You went Spanish, not bilingual, and put a gate on it.** The quote library marks all 12
Hispanic quotes *Spanish* with translation status *Needs Native Review*. The launch
tracker holds all four Hispanic products with "hold publishing until Spanish copy and
visible text have native-speaker review." The QA checklist has a dedicated
`spanish_native_review_verified` column.

The product titles went further than the quotes — the Hispanic covers are fully Spanish:
*Colores de Sanación: Libro de Colorear de Recuperación Primavera*. A real positioning
choice, and a clean one.

> **One thing to line up:** native review is now a blocking gate on 4 of your 12 Spring
> products. Find that reviewer before you reach phase 5, not during it.

### 7. TIDY (half closed) — Gaps in the design system.

- ~~The tracker uses **six** page types; the design system defines **five**.~~
  **Closed twice over.** I gave Decorative a home in TPL-10; the new Spring page set
  solved it more simply by dropping the Decorative type altogether and using two Symbol
  Cluster pages per book. **The new approach is better — take it, treat TPL-10 as a
  spare.**
- **Still open:** `art_direction_specs.csv` has 3 rows that are word-for-word identical
  except the line name. The real per-line guidance lives in `page_design_system.md`.

> **Fix:** either write real per-line direction into the art direction file, or delete
> it and let `page_design_system.md` be the single design source. Right now it is three
> copies of the same paragraph pretending to be three different briefs.

---

## 5. The build order

Your own conclusion in the thread was right: **do not launch twelve books at once.**
Build one completely, learn from it, then clone the rhythm.

### Phase 1 — Settle the five decisions — 3 of 5 DONE

Three the second batch answered by simply doing them. Two remain, and the first now
blocks everything downstream.

1. **STILL OPEN.** Are the four product types separate art, or separate packaging of the
   same art? The QA tracker claims 15 pages for each of 4 products drawn from a pool of 15.
2. ~~Is "Healing Seasons" the cover brand, and do the line names ship?~~ **Yes** — Rooted
   in Hope, Colores de Sanación, Many Shades of Healing, plus a distinct title for each of
   the 12 Spring products.
3. ~~Does the ethnic descriptor belong in the product title?~~ **No** — titles lead with
   the emotional promise; the audience lives in keywords and description.
4. ~~Spanish-only, bilingual, or dual-variant?~~ **Spanish, with a native-review gate.**
5. **STILL OPEN.** What are the four actual prices? Every `pricing_status` reads Not Started.

**Gate:** the product-type decision, in writing, before phase 2.

### Phase 2 — Repair the production files — 2 of 3 DONE

- ~~Rebuild `template_page_assignment_matrix.csv` from page type~~ — done, 180/180 matching
- ~~Rewrite `template_prompt_framework` as a slotted formula~~ — done, plus all 180 prompts assembled
- Add a book-sequence column to the tracker — **still open**, see finding 5

**Gate:** every one of the 15 pilot rows has a matching template and a complete prompt.
**Met.**

### Phase 3 — Draw three proof pages, not fifteen

Pick the three hardest page types from African American Spring — a solo portrait, a
community scene, and a quote page — and take those all the way to print-ready.

- Test against the export checklist: nothing below 0.5 pt, text inside safe margin, no gray fills
- Print all three at full size, then color one in
- Show them to two or three people in or close to recovery

**Gate:** the three pages look like they came from the same book. If not, revise the
design system and redraw before phase 4.

### Phase 4 — Complete the pilot: African American Spring Flagship

The remaining twelve pages. Same tool, same settings, same session rhythm — consistency
matters more than any individual page being perfect.

- Cover, title page, short how-to-use page
- Compile as one print-ready PDF plus individual 300 DPI PNGs
- Run the six-point export QA on the compiled book, not just loose pages

**Gate:** one complete, sellable book exists as a file.

### Phase 5 — Launch one product and watch it

Take that product's launch-sheet row, write the storefront page, price it, put it up.
Title, subtitle, slug, descriptions, audience, and cover concept are already written.

- Learn which title wording, thumbnail, and keywords actually pull
- Decide whether the facilitator / group-use license is a real second offer
- Feed what you learn back before writing 47 more listings

**Gate:** real buyer signal, however small.

### Phase 6 — Finish the African American line

Summer, Fall, Winter — 45 more pages. Layout logic stays fixed; only props, weather,
clothing, and seasonal mood change. Then package the Spring season bundle and the
four-season line bundle.

### Phase 7 — Clone into Hispanic, then Multiracial

Same formula, same templates, same seasonal cues. What changes: representation, cultural
setting detail, quote language. All 120 scene concepts are already written.

### Phase 8 — Master bundle and companion products

Affirmation cards, journal pages, planner inserts, and the facilitator / group-use
licensed edition — a genuinely different product at a genuinely different price, aimed
at counselors, peer groups, churches, and women's groups.

---

## 6. The per-page loop

The unit of work that repeats 180 times. Every input already exists in a file you have.

1. **Pull the row** — page type, scene notes, quote, priority
2. **Pull the template** — layout formula, zones, white-space rule
3. **Assemble the prompt** — template + scene + line + season + quote
4. **Generate or draw** — first-pass draft, composition only
5. **Clean and vectorize** — line weights, hands, faces, open space
6. **QA against the checklist** — margins, 0.5 pt floor, no gray, accents
7. **Place in sequence** — book slot, pacing check, export

---

## 7. Tool stack

Your research landed on a hybrid, and the reasoning holds. No single platform does all
three jobs well.

- **Concepts and first drafts** — an AI generator, or Procreate if you draw them
  yourself. Fast; cleanup expected either way.
- **Line art and print quality** — Adobe Illustrator (10/10 quality, 10/10 print
  readiness in your matrix). Affinity Designer is the strong non-subscription
  alternative at 9/10 and 9/10.
- **Assembly, quote pages, covers, export** — Canva (10/10 speed, 10/10 ease).

**If you only subscribe to one thing first: Canva.** It gets you covers, quote pages,
and a compiled PDF immediately — and quote pages are 3 of every 15, a fifth of the
catalog you can produce well without any vector tool. Add Illustrator or Affinity when
the proof pages in phase 3 tell you the line quality isn't holding up.

---

## 8. Start here tomorrow

1. **Answer the two remaining decisions** — product types and prices. The product-type
   one blocks the QA tracker, the cover tracker, and the bundle ladder at once.
2. **Delete the four `(1)` duplicates** and refile into the five folders — strategy,
   production, design, prompts, reference.
3. ~~**Rebuild the template assignment matrix.**~~ Done.
4. ~~**Rewrite the prompt framework.**~~ Done — and the new Spring prompt library
   supersedes it for those 45 pages.
5. **Draw the three proof pages** from the new Spring set — pages 1, 4, and 5 of
   *Rooted in Hope* give you a solo portrait, a community scene, and a quote page — and
   print them.

The honest summary: you have eleven layers of planning, 180 written page concepts, 36
written quotes, 48 written listings, a real design system, a real template library, and
now a fully scoped 45-page Spring pilot with named products, per-page prompts, file
naming, QA gates, and launch tracking. What you do not have yet is a single finished
page. Everything above is aimed at getting you to one.

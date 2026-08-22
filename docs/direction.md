# Direction

## Project
Esoh Studio

## Status
Draft v2 — supersedes conflicting guidance in PRD.md, design-plan.md, build-plan.md, schema-notes.md, api-route-map.md and review-and-recommendations.md.

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

**Observed a third time at Stage B.** A texture block ending "No hatching,
stippling or grey fill" produced a page stippled on every surface — skin, sky,
wall and tabletop. Removing the sentence and stating positively where pattern
belongs ("fabric shows its stitch, wood its grain... skin and sky stay clean and
unmarked") fixed it in one pass. Refined after two further occurrences at Stage B. Negatives about **content**
hold — "No people" and "No border or frame" were obeyed in every generation.
Negatives about **rendering technique** backfire: "no stippling" produced a
stippled page, and "never as shading" produced a hatched face.

**Law: technique is stated positively, never negatively. Content may be
excluded by name.**

---

## 3. What the reference images establish

Eight reference images and four scanned pages define the target style. Measured against them, nearly every rule written in Stage 1 was inverted:

| Stage 1 rule | Reference reality |
|---|---|
| uniform line weight | bold on figures, fine on background — deliberate variation |
| no solid black areas | **Stage 1 was right.** A coloring page has no filled areas at all — see §3.4 |
| no text or lettering | "Healing Seasons" lettered on a mug — an occasional name-drop, see §3.3 |
| no borders or frames | every page has a black border; it is part of the style |
| centred subject, generous white space | **Stage 1 was closer.** See §3.5 — the density premise was wrong |
| simple interior detail only | cable-knit stitches, rug patterns, book spines, wood grain |

Confirmed style attributes — **how** a page is drawn:

- Dense, editorial line illustration with full environmental context
- Form described by **outline**, never by shading, hatching or texture fill (§3.5)
- Line weight varies deliberately: bold on figures, fine on background
- Ethnicity rendered specifically and respectfully, never generically

### 3.5 Correction: the density premise was wrong

The single largest error in this document, and the root of most of the others.

§3 recorded "dense environmental storytelling, edge to edge" and "texture
rendered as pattern" as confirmed style attributes. Pages built on them read as
**seek-and-find puzzles** — every surface carrying marks, nowhere for the eye to
rest, no open area large enough to colour comfortably. The book exists to give
someone a calm hour with a pencil. Busy defeats it.

Measured against the two pages Esoh identified as closest to target
(`storage/exemplars/journaling-under-tree.png` and `walking-with-mug.png`):

| | Actual style |
|---|---|
| Subject | **Open.** Clothing and skin are large white areas described by outline alone — a seam, a cuff, a fold. The hoodie and sweatpants carry almost no interior line. |
| Background | **Countable shapes, not pattern.** Individual outlined leaves with white between them, each one colourable. |
| Page | **Breathing room.** Open sky, open ground, subject reads instantly. |

The distinction that was missing: *detail* and *fill* are not the same thing. A
page can carry a great many drawn elements and stay calm, as long as each is a
separate closed shape with white around it. What made the generated pages busy
was continuous surface texture — which is also, not coincidentally, the one kind
of mark that cannot be coloured.

Governing principle, replacing "texture as pattern": **form is described by
outline.** Nothing is filled, shaded, hatched or textured.

Density now describes how much of the page carries subject matter, not how
filled its surfaces are.

### 3.4 Correction: nothing on the page is filled in

An earlier draft listed "no solid black areas" as a Stage 1 rule that the
references had disproved, on the grounds that hair in them "reads near-black".

That inverted the product. **A coloring page has no filled, shaded or darkened
areas anywhere** — not hair, not background, not texture used as tone. Every
enclosed area is open white or there is nothing for the reader to colour. The
Stage 1 rule was correct and should not have been overturned.

Related, and more serious: the figure block carried "hair is rendered as dense
drawn curl", generalised from the same observation. Written as a style rule it
gives all 180 pages the same hair and forecloses locs, braids, twists, fades,
bantu knots, headwraps and everything else the subject might wear — a
stereotype encoded in the prompt engine, and a variety failure on top.

**Hair is content, not style.** It belongs in the item brief, which already
specifies it where it matters. Style blocks say only how hair is *drawn*:
outlined sections, left open inside. With the rule removed, three consecutive
generations produced an afro, braids and a short fade without being asked.

### 3.3 Correction: the motifs are not motifs

An earlier draft listed "recurring motifs: the Healing Seasons mug, seasonal
foliage, candles, chunky knits, windows, books, lanterns" as a confirmed style
attribute, and called the lettered mug a brand signature. **Both are wrong**, and
wrong in the way that matters most.

Those objects were the content of *those particular reference images*. A woman
happened to be wrapped in a knit blanket holding a mug by a window. That is what
that page is about — not a rule every Fall page inherits.

Promoted into a style block, the list would put candles, knits and a window into
all 180 pages. That is precisely the repetitiveness Stage 1 produced, arriving by
a new route: not from generic prompts this time, but from over-generalising six
specific images into a house style.

**The dividing line, and the core principle for Stage B:**

| Layer | Answers | Source | Varies |
|---|---|---|---|
| Style block | *How* is it drawn? | the reference images | per art style |
| Item brief | *What* is drawn? | the tracker's `prompt notes` | per page |

Every one of the 180 rows already carries its own subject — "Woman journaling by
a rainy window with plants", "Man walking at sunrise in a neighborhood park".
The motifs come from there, per page, written by Esoh. They must never be
hoisted into a style block.

The lettered mug is the same case: a name-drop wanted on a few pages, not a
signature. It is now `items.brand_mark`, null by default, and may carry
'Healing Seasons' or 'Esoh Creations'. Per item, opt-in, never in a style block.

### 3.1 Correction: the references are not all page-shaped

An earlier draft stated "the references are 1024×1536 — exactly `gpt-image-1` output." Only four of the eight are.

| Count | Size | Ratio | Note |
|---|---|---|---|
| 4 | 1024×1536 | 0.667 | page-shaped, thin black border present |
| 3 | 1408×768 | 1.833 | **landscape** — not page-shaped; one is a two-panel A/B variant sheet, not a finished page |
| 1 | 896×1200 | 0.747 | near letter |

This matters. Some of the strongest style evidence — the couch scene, the journaling page — came from landscape banner-ratio images that could never be a book page. Style notes drawn from them describe a composition the format cannot hold.

The border claim splits the same way: the portrait references have one, the landscape ones do not.

The model is still demonstrably capable of the style. The gap was the prompt. But the shape evidence was mixed, and only the scanned pages below are in true letter proportion.

### 3.2 Four scanned pages — quote, symbol and decorative

`more design references.pdf`, four pages at 0.73–0.77 — the first references in real letter proportion. They fill the gap named in §9: there were no references for Quote, Symbol or Decorative pages.

| Page | Type | Treatment |
|---|---|---|
| p1 | Quote | Bubble caps mixed with script, abstract geometric wedge background, border |
| p2 | Quote | Lettering interlocked with an edge-to-edge mandala/zentangle field, border |
| p3 | Quote | Huge outline caps in dotted rule-bands, mostly empty page, border |
| p4 | Symbol / Decorative | Zentangle cat on a sunburst, no text, no border, bleeds off the edge |

**The key finding is p2 against p3.** Same page type, same category, opposite density — one wall-to-wall pattern, one nearly empty. Density is therefore a per-item setting, not a house rule. An earlier draft canonized "dense environmental storytelling, edge to edge" as *the* style; that is one option among three, and applying it globally would have produced 36 identical dense quote pages.

The lettering on all three quote pages is **hollow outline art meant to be colored in** — on p2 physically interlocked with the pattern behind it. This refines D23 rather than reversing it: see the decision table.

Three of the four carry a `creativecolorlab.com` watermark and p4 shows colored-pencil marks. They are scans of another publisher's book. Fine as style study for authoring templates — see D31 for the limit.

---

## 4. The real data model

The two spreadsheets reveal a structure no earlier document captured.

Both live in `docs/references/` as CSV exports. **Both are living documents** — incomplete and still being added to. Import must be re-runnable, never a one-time load.

### Spreadsheet A — book listing metadata
`keyword_listing_plan_african_american...csv` — **16 rows**
`ethnicity line | season | product id | title | keywords | description`

Commercial data for store listings. **African American only so far**; Hispanic and Multiracial still to come.

### Spreadsheet B — page production plan
`recovery_coloring_book_tracker...csv` — 180 rows
`title | ethnicity line | season | page type | prompt notes | quote text | commercial priority`

**Header names use spaces, not underscores.** An earlier draft transcribed them with underscores; import code written from that would fail on every row. The spreadsheet is correct as it stands — nothing to fix on the sheet.

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

Priority: **103 High, 77 Medium, none blank.** (An earlier draft said 101/51 with a remainder — verified wrong against the file.)

All 180 rows carry prompt notes, and exactly 36 carry quote text — matching the 36 Quote pages precisely. The data is clean.

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

### 4.4 The missing dimension: Art Style

Nothing in any spreadsheet or any earlier document recorded **visual aesthetic**.

The VV-Styles sheet has `Category` (what the message is about) and `Style` (bold, sassy, supportive — the **tone of voice**). Neither says what the design *looks like*. "Sassy" does not distinguish 70s groovy from graffiti from retro comic — three completely different shirts carrying the same attitude. The two columns also overlap on six values (Sassy, Truth, Confident, Motivational, Boundaries, Accountability).

This is the root cause of generic output, and it applies to coloring pages as much as apparel — p1, p2 and p3 are three art styles of one page type.

**Decision: three new dimensions, orthogonal to category, tone and page type.**

**Art Style** — twelve values:

| Art Style | Look | Coloring | Apparel | Social |
|---|---|---|---|---|
| Editorial Scene | Full environment, figures in context, texture as pattern — the current house style | ✅ | | |
| Zentangle Pattern | Dense abstract pattern-fill, no scene | ✅ | ✅ | |
| Botanical Line | Flowers, foliage, vines — medium density | ✅ | ✅ | ✅ |
| Geometric Abstract | Rays, facets, wedges, arcs as structure | ✅ | ✅ | ✅ |
| Bold Minimal | One idea, huge scale, generous empty space | ✅ | ✅ | ✅ |
| Vintage Badge | Emblem, banner ribbon, clean-date slot | | ✅ | ✅ |
| Streetwear Graffiti | Spray and marker letterforms, drips, tags | | ✅ | ✅ |
| Retro Groovy | 70s bubble type, wavy baselines, sun rays | | ✅ | ✅ |
| Tattoo Linework | Heavy outline, flames, roses, daggers, banners | | ✅ | ✅ |
| Retro Comic | Halftone, burst panels, speech bubbles | | ✅ | ✅ |
| Editorial Typographic | The type is the design — restrained, magazine-like | | ✅ | ✅ |
| Celestial | Moon phases, stars, dawn | ✅ | ✅ | ✅ |
| Photoreal Composite | Photographic subject with rendered type over it | | ✅ | ✅ |
| Hand-Drawn Doodle | Marker lettering and simple drawn motifs, primary colors, playful | ✅ | ✅ | ✅ |

**Photoreal Composite** is included because it is in the live line (the phoenix shirt), not because it is recommended. Two cautions: photoreal art prints muddier on DTF than it appears on screen, and metallic gradients flatten. Reviewable.

**Lettering Style** — for any item carrying words: Bubble Caps · Brush Script · Block Outline · Serif Editorial · Hand-Marker · Mixed Caps + Script.

**Background Density** — Open · Medium · Dense. Derived from p3 / p1 / p2.

Twelve is deliberate. Enough that 129 designs need not repeat; few enough to choose from in seconds.

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

### 5.1 Output sizes

`gpt-image-1` offers exactly three shapes: 1024×1024, 1024×1536, 1536×1024. **Landscape (1536×1024) is never used** — it does not fit any planned product.

| Category | Generate | Deliver |
|---|---|---|
| Coloring books | 1024×1536 | pad to 2550×3300 (8.5×11 @ 300 DPI) |
| Social — feed | 1024×1024 | square |
| Social — Pinterest | 1024×1536 | 2:3 is already ideal |
| Social — stories/reels | 1024×1536 | pad to 9:16, compose inside a safe zone |
| VV-Styles apparel | 1024×1024, transparent background | upscale to 4500×5400 (15×18" @ 300 DPI) |

**Coloring pages pad, never crop.** 1024×1536 is 0.667; letter is 0.773. Cropping to letter cuts ~13% off top and bottom and loses art. Padding fits the art to 2200×3300 and leaves ~0.58" of white each side — which KDP requires anyway for margin and gutter. The margin does double duty.

This closes the open question in §9.

Apparel is raster, not vector. `gpt-image-1` supports transparent backgrounds, so 4500×5400 transparent PNG is genuinely print-ready for DTF. True vector would need a separate trace step — worth doing later, not a blocker.

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

### 4.5 What the live VV-Styles products show

Eight product images in `docs/references/` are the only finished VV-Styles designs in existence. Seven are `.png`; `feeldealheal.jpg` is the eighth.

| File | Garment | Design | Art Style | Background |
|---|---|---|---|---|
| `stillhere` | white | "Still here… Still CLEAN" — sun over water | Retro Groovy | box hidden by white fabric |
| `recoveringoutloud` | white | "RECOVERING OUT LOUD / EST. 1995" — arched collegiate | Vintage Badge | box hidden by white fabric |
| `worstidea` | white | "I SURVIVED MY OWN WORST IDEA" — stencil type, lightbulb | Bold Minimal | box hidden by white fabric |
| `recoveringest` | pink | "RECOVERING / est. 2006" — arched lettering, dice, flame | Vintage Badge | **knocked out correctly** |
| `cleanserene` | gray | "CLEAN & SERENE SINCE 1953" — Victorian filigree | Editorial Typographic | white square visible |
| `proud` | dark heather | "PROUD to be RECOVERING" — photoreal phoenix | Photoreal Composite | orange rectangle visible |
| `listenin` | red | "Listenin' for the GOOD E.S.H." — thin pink type | Editorial Typographic | white square, very visible |
| `feeldealheal` | white | "Feel / DEAL / Heal" — marker lettering, sine wave, daisies | Hand-Drawn Doodle | indeterminate on white fabric |

**The defect, stated correctly.** Only one of eight is verifiably knocked out. Four more *appear* clean solely because the garment is white and hides the box — on white fabric a white background and a transparent one are indistinguishable, so their true state is unknown until they are placed on a colored garment. The artwork is sound throughout — the enclosing background is not.

This is not primarily a cosmetic problem. **It locks the line to white and near-white garments.** An existing design cannot be offered in navy, forest, maroon or heather without the box appearing. Transparent artwork multiplies the catalogue without any new design work: 8 designs × 6 garment colors ≈ 48 products from art already owned. Given that the store needs product before launch, this is the highest-leverage single fix in the project, and it is what Stage C must deliver first.

The cause is designing inside the Printify editor, which could not produce a knocked-out background despite repeated attempts. `gpt-image-1` returns transparent PNGs directly (§5.1).

**Clean date is a template variable.** Three of the seven carry one — `est. 2006`, `SINCE 1953`, `EST. 1995` — and the library row reads "Clean & Serene since 1953 (or clean date)". It is a personalization slot, not decoration, and belongs in the prompt engine as `{{clean_date}}`.

**Print-quality notes.**
- `listenin` uses thin, light-weight pink type at low contrast — the two things DTF reproduces worst. Rework rather than reprint.
- `feeldealheal` has white daisy petals that vanish on white fabric. It needs a colored garment to read at all — a concrete instance of why the colour range matters.

**Vocabulary grew from real work, twice.** The live line required two lettering values the original list lacked (`Sans Display`, `Stencil`) and a fourteenth art style (`Hand-Drawn Doodle`). This is the §2.2 principle working as intended: the vocabulary is seeded by what Esoh actually makes, not by what was imagined in advance. Expect it to keep growing; validation rules warn rather than reject for this reason.

**Library gap.** Six of the seven exist as rows in the 129-quote library. `Listenin' for the GOOD E.S.H.` does not, and carries fellowship language (`E.S.H.`) that belongs with the other flagged rows. Every live product must exist as a row or the library is not the source of truth.

---

## 6. Style consistency is the core technical problem

180 pages must look like one book. Text prompts alone will not hold a style across 180 generations — Stage 1 demonstrated drift within *three*.

Planned approach, strongest first:

1. **Reference images as input.** `gpt-image-1` accepts image input. Feeding approved pages as style exemplars is far more reliable than describing the style in words. Two qualifications learned at Stage B, both the hard way:

   - **An exemplar transfers its faults along with its virtues.** `hoodie-on-sofa` is the right target for rendering and contemporary dress, and it also has near-black filled hair and leaves on every surface. Sent as image input it reproduced both — the two things Esoh had explicitly rejected. An exemplar has to be a page that would be accepted whole, not a page that is mostly right.
   - **Mixed exemplars average out.** Three were active at once: two sparse, one rich. The model split the difference and produced pages that were never open enough nor full enough. Exemplars must agree with each other.

   The consequence: **D20 cannot carry a style until one fully approved page exists.** Until then the Style Library is running on words alone, which is where the drift comes from.
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

### Stage C — VV-Styles apparel
The first real test of the engine on a whole category. Square transparent output, the twelve art styles, 129 items already written. No page-type templates, no 180-item queue, no bilingual lettering — the simplest path from prompt to sellable product.
**Done when:** a design goes from library row to print-ready transparent PNG without touching Printify's editor.

### Stage D — Library and retrieval
Asset library with filters across category, collection, item, page type, status, priority. Items show their attempts.
**Done when:** any page from any book is findable in seconds.

### Stage E — Batch
Generate a whole collection unattended. Review queue for the results.
**Done when:** "generate every High priority Fall page" is one action.

### Stage F — Print pipeline
Upscale to 300 DPI, page proportions, bleed and margins, print-ready PDF export.
**Done when:** an approved page can go straight to KDP.

### Stage G — Remaining categories
Social content and print designs, with their own presets and templates.

Stage F may need to move earlier if publishing deadlines demand it.

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
| D23 | **Refined.** Quote text is overlaid after generation as **outlined vector type** — a real font, stroked and unfilled — never drawn by the model. The scanned quote pages show lettering as hollow outline art meant to be colored in; flat filled type would sit on the page like a sticker and could not be colored. Outlined vector keeps the letters colorable *and* guarantees correct spelling and accented Spanish, and still allows restyling or translation without regenerating. Quote-page prompts must **reserve clear space** for the type to land in. |
| D24 | **The model never draws a border.** Seven of eight page-shaped references have one, so it is a genre convention rather than an accident — but a drawn border bakes in, varies page to page, and was the one Stage 1 instruction the model reliably ignored. Prompts generate borderless with a safe margin. The print pipeline *may* add a border as a vector rule at export: exact, identical on every page, removable. Default off. Same principle as D23 — generate the art, add the precise parts afterward. |
| D25 | The series is **3 lines × 4 seasons = 12 books, 180 pages.** Spreadsheet A is book-level listing metadata (title, keywords, description); its "flagship 1–4" rows are candidate listing copy, not separate books. |
| D26 | **Art Style is a first-class dimension**, separate from category and tone. Twelve values (§4.4). This is the mechanism for variety; without it the tool has no axis to vary. |
| D27 | **Background Density** (Open / Medium / Dense) is a per-item setting on any template with a background. Never a global rule. |
| D28 | **Lettering Style** applies to any item carrying words, coloring page or apparel. |
| D29 | Output sizes are fixed per category (§5.1). **Landscape 1536×1024 is never used.** |
| D30 | Coloring pages **pad, never crop**, from 1024×1536 to 8.5×11. The padding becomes the KDP margin. |
| D31 | Third-party reference scans (the watermarked pages) inform how templates are *written*, but are **never sent to the model as image input**. D20 style exemplars come only from our own approved pages, per D22. |
| D32 | **VV-Styles moves to Stage C**, ahead of library, batch and print. It is the simplest complete path through the engine and the store needs product before launch. |
| D34 | **Apparel artwork is generated with a transparent background and no enclosing shape.** Three of four live designs print a visible rectangle on the garment; this is the defect Stage C exists to remove. |
| D35 | **Clean date is a prompt slot** (`{{clean_date}}`), not baked into the design. Supports per-buyer personalization. |
| D36 | **Photoreal Composite** is a thirteenth art style, recorded because it is in the live line. Flagged for review on print quality, not endorsed. |
| D49 | **Nothing in the Style Library described the people or places as contemporary**, so the model produced dated figures in vague settings. The line is meant to mirror present-day life; that has to be stated. |
| D50 | **An exemplar must be a page acceptable in full.** Image input copies faults as faithfully as virtues, and mixed exemplars average into mush. |
| D51 | **Text cannot override a fault the exemplar demonstrates.** With `hoodie-on-sofa-v2` as the sole exemplar and the figure block rewritten to demand outlined, open hair, the page came back with hair filled solid anyway — the exemplar shows filled hair and the image wins. Corollary to D50: a residual fault is not something a stronger block can cover; the exemplar has to be corrected. |
| D52 | **Hair and facial hair are selectable per item** — `items.hair`, `items.facial_hair`, and a `combo` form field that offers current styles (braids, locs, fades, twist-outs, waves) but accepts anything typed. D45 said hair is item data; nothing implemented it, so `hs-figure-rendering` said hair follows "whatever style the person wears" — which names nothing, leaving the exemplar to decide. **A vague field is what an exemplar overrides.** The style block now carries only the rendering rule: outlined sections, never filled, colourable like any other area. |
| D53 | **Fullness is a density decision, never an art style.** `hs-style-editorial-scene` asserted "an uncluttered setting, with open sky and ground" — a content judgment buried in an art style where no form control could reach it. It contradicted `hs-density-dense` and `hs-furnishing` in the same prompt and, coming first, won: choosing **Dense** produced a bare room. "Open" means the figure is not crowded by their surroundings; it has never meant the room is scarce. |
| D54 | **`items.visual_elements` feeds the `{{environment}}` slot.** Nothing supplied it, so the one block that says what is in the room was silently dropped from every item-driven generation — an empty slot drops its block by design. Generic rooms were not the model guessing badly; they were the item never being asked. |
| D55 | **The form generates from a queue item.** It posted no `itemId`, no art style, no density and no exemplar flag — so `brief`, `hair`, `visual_elements`, `season` and `ethnicity_line` were unreachable from the app and every page came out of the blank-form path. Wiring the columns was never the missing piece; **nothing in the UI could select a row to wire them from.** Choosing an item now settles its template, art style and density, each still editable — the row is a starting point, not a lock. |
| D56 | **A page-type mismatch is refused, not drawn.** Generating a Quote page item against the Solo Portrait template produced a silently wrong page. With 180 items across six page types this had to fail loudly. |
| D57 | **`quote_text`, `quote_lang` and `lettering_style` are deliberately not prompt inputs.** D23 puts quote text on the page as overlaid outlined vector type; sending it to the model would produce misspelt, uncolourable lettering and break the reserved space the composition block creates. They are export-stage data, and the export stage does not exist yet. `color_direction` and `product_placement` are VV-Styles fields with no VV-Styles template (D32, Stage C). **Five of the six unused columns are unused correctly** — only `visual_elements` was a genuine defect. |
| D47 | **Form is described by outline; nothing is filled, shaded, hatched or textured.** Replaces "texture rendered as pattern", which produced seek-and-find pages (§3.5). Detail and fill are different: many separate outlined shapes with white between them stay calm and remain colourable. |
| D48 | **`journaling-under-tree` and `walking-with-mug` are the canonical Solo portrait exemplars**, registered with `usable_as_input = true`. Both are Esoh's own work, so D31 does not apply. |
| D44 | **Nothing on a coloring page is filled in.** Every enclosed area is open white. Hair included. |
| D45 | **Hair is item data, never a style block.** Encoding one texture as a rule stereotypes and removes variety. |
| D46 | **Technique is stated positively; only content is excluded by name.** Four occurrences of the §2.5 trap, all of them technique negatives. |
| D43 | **Density means the composition reaches every edge, not that every surface carries marks.** "Leaving no empty ground" left the model nowhere to stop and it textured skin and sky. A coloring page needs clean enclosed areas to put colour into. |
| D39 | **Style blocks describe how a page is drawn; item briefs describe what is in it.** Objects, props and settings come from the item's own brief and are never promoted into a style block. Over-generalising six reference images into a house motif list would make 180 pages repeat (§3.3). |
| D40 | **`Healing Seasons` is a series**, recorded on `collections.series`, sitting between category and collection so a second series never collides with the first. |
| D41 | **The in-scene name-drop is per-item and opt-in** — `items.brand_mark`, null by default, either 'Healing Seasons' or 'Esoh Creations'. An occasional touch, never a signature. |
| D42 | **Export filenames are spelled out in full**, including page type and art style: `african-american-fall-09-quote-page-zentangle-pattern-v2.png`. Internal storage keys stay opaque; the descriptive name is generated at export, because an exported file leaves the database behind and has to describe itself. |
| D37 | **Every live product exists as a library row.** `Listenin' for the GOOD E.S.H.` is currently live but unrecorded. |
| D38 | **Transparent artwork is the Stage C priority, ahead of new designs.** It unlocks the garment-colour range and multiplies the catalogue from existing art. |
| D33 | The VV-Styles master list is **`VV-Styles Designs Library Original`**. The two ChatGPT-expanded exports added no quotes — only one boilerplate visual string per category and a single templated prompt — and are retired. `vv-styles-master.csv` is its restructured form. |

---

## 9. Open questions

**Answered since the last draft**
- ~~VV-Styles phrases are not recorded anywhere~~ → 129 quotes exist; see D33.
- ~~No references for Symbol, Decorative or Quote pages~~ → four scanned pages, §3.2.
- ~~Crop, pad or outpaint?~~ → pad, D30.
- ~~Do VV-Styles and social need collections and items?~~ → yes. One VV-Styles item is one design; the 129 rows map onto category → collection → item with no model change. They need separate categories because the output ratios differ.

**Blocked on a missing stage, not on wiring** (D57)
- **Quote pages cannot complete.** The prompt reserves the centre and forbids drawn letters (D23), but no overlay step exists — no compositing library is installed and no font is chosen. 36 coloring-book items and 130 VV-Styles items carry `quote_text` with nothing to consume it. The font question below blocks this.
- **VV-Styles has 130 items and no template.** `lettering_style`, `color_direction` and `product_placement` have nowhere to land until Stage C builds one.

**Production**
- Are the 12 books published separately, or bundled as one series?
- Which font should overlaid quote type use? Must carry accented Spanish and read as outline at 300 DPI.
- The keyword listing plan covers African American only. Hispanic and Multiracial listings still to come.
- Should the 19 VV-Styles categories consolidate to the proposed 9? Listed in `vv-styles-lists.csv`, not applied.
- 14 VV-Styles quotes are recovery-fellowship-adjacent and pre-flagged `Brand / Legal Review`. Decide before printing.

**Current state of VV-Styles**
- Store is built but **not public**. 8 shirt styles live, one tester shirt ordered and approved. Designs are currently made by hand in the Printify web editor — slow, and the reason this tool exists.

**Style**
- All seven existing shirts are catalogued in §4.5.
- Photoreal Composite is **kept** (D36). Open: does the phoenix keep its poster rectangle, or get knocked out to phoenix-and-type only? One test print decides it.
- No approved in-house exemplars exist yet for Quote, Symbol or Decorative pages. Stage B must produce the first ones.

**Structure**
- Should the tool write back to the spreadsheets, or replace them?

**Technical**
- Verify the estimated rates in `lib/pricing.ts`.
- Vector trace step for apparel — later, not blocking.

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

ChatGPT and Gemini cap image generation at roughly 3 per 24 hours. The Healing Seasons production plan is **240 pages** (D80). At 3 a day that is over two months of waiting, and the waiting is the bottleneck — not the generating.

The tool exists to remove that ceiling and to make 240 pages come out looking like one coherent book.

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

Both earlier plans list batch as out of scope for V1. With a 240-page backlog and no rate limit, batch is a primary feature. It moves into the core.

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
gives all 240 pages the same hair and forecloses locs, braids, twists, fades,
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
all 240 pages. That is precisely the repetitiveness Stage 1 produced, arriving by
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

The production queue. 3 lines × 4 seasons × 15 pages = **180 pages**, verified — the sheet as it stands. D80 raises this to 20 pages per book, so 60 rows are still to be added and the counts below describe the original 180.

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
| VV-Styles apparel | 1024×1536, transparent background | pad into 3600×4800 (12×16" @ 300 DPI) |

**Coloring pages pad, never crop.** 1024×1536 is 0.667; letter is 0.773. Cropping to letter cuts ~13% off top and bottom and loses art. Padding fits the art to 2200×3300 and leaves ~0.58" of white each side — which KDP requires anyway for margin and gutter. The margin does double duty.

This closes the open question in §9.

**Apparel pads too, and for the same reason.** The category was square while the delivery note asked for 4500×5400 — two different shapes, and neither is what a front print is. `gpt-image-1` tops out at 1536 on the long edge, so 1024×1536 is the closest portrait it makes; it is also what every accepted reference is. The art is padded into the 12×16" front-print area rather than cropped to it, and because the artwork is transparent the padding costs nothing — the design floats in the print area instead of being cut to fit (D71).

Apparel is raster, not vector. `gpt-image-1` supports transparent backgrounds, so a transparent PNG is genuinely print-ready for DTF — but it is generated at 1024×1536 and has to be upscaled to reach 300 DPI at 12×16", which no amount of prompt work changes. Flat, hard-edged art is the most upscale-tolerant kind there is, which is lucky rather than planned. Only a test print settles whether it holds. True vector would need a separate trace step — worth doing later, not a blocker.

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

240 pages must look like one book. Text prompts alone will not hold a style across 240 generations — Stage 1 demonstrated drift within *three*.

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
Migrate to categories/collections/items. Import both spreadsheets. The 180 tracker rows land in the database with briefs, page types, quotes and priorities.
**Done when:** the production plan is queryable — "show me every High priority Fall quote page."

### Stage B — Style Library from real material
Six page-type templates. Blocks derived from the reference images and prompt notes. Reference-image input wired in.
**Done when:** a generated Solo portrait is judged close enough to the references to use.

### Stage C — VV-Styles apparel
The first real test of the engine on a whole category. Square transparent output, the twelve art styles, 129 items already written. No page-type templates, no 240-item queue, no bilingual lettering — the simplest path from prompt to sellable product.
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
| D4 | Asset Library is a primary feature. ~~ahead of style refinement~~ → it follows style; see D86, which also separates the three libraries. |
| D5 | No n8n. ~~until external integrations exist~~ → that condition was met and changed nothing; the trigger is replaced in D87. |
| D6 | Single Next.js app. No monorepo. Reaffirmed with its one cost paid off; see D88. |
| D7 | Localhost first. Reaffirmed; it no longer means a single copy, see D89. |
| D8 | No auth, no `users` table. |
| D9 | Every job records resolved prompt, model, params, usage and cost. |
| D10 | Print pipeline planned from the start, built at Stage E. |
| D11 | **Superseded by D3.** |
| D12 | OpenAI `gpt-image-1` is the provider. |
| D13 | PostgreSQL runs locally. |
| D14 | Code lives at `~/esoh-studio`. |
| D15 | Git remote set up early; container files are not backed up — **except the exemplars, which now are** (D89). |
| D16 | Batch generation is a core feature, not deferred. |
| D17 | Page type is the template unit. Six templates for coloring books. |
| D18 | Ethnicity is production data, never a style setting or global default. |
| D19 | Quote pages render lettering, including accented Spanish. |
| D20 | Style consistency is driven by reference images, not longer prompts. |
| D21 | Adopt `{data, meta, error}` envelope and `/api/v1` paths. |
| D22 | Approved pages can be promoted to style references. |
| D23 | **Refined.** Quote text is overlaid after generation as **outlined vector type** — a real font, stroked and unfilled — never drawn by the model. The scanned quote pages show lettering as hollow outline art meant to be colored in; flat filled type would sit on the page like a sticker and could not be colored. Outlined vector keeps the letters colorable *and* guarantees correct spelling and accented Spanish, and still allows restyling or translation without regenerating. Quote-page prompts must **reserve clear space** for the type to land in. |
| D24 | **The model never draws a border.** Seven of eight page-shaped references have one, so it is a genre convention rather than an accident — but a drawn border bakes in, varies page to page, and was the one Stage 1 instruction the model reliably ignored. Prompts generate borderless with a safe margin. The print pipeline *may* add a border as a vector rule at export: exact, identical on every page, removable. Default off. Same principle as D23 — generate the art, add the precise parts afterward. |
| D25 | The series is **3 lines × 4 seasons = 12 books.** ~~180 pages~~ → 240, D80. Spreadsheet A is book-level listing metadata (title, keywords, description); its "flagship 1–4" rows are candidate listing copy, not separate books. |
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
| D56 | **A page-type mismatch is refused, not drawn.** Generating a Quote page item against the Solo Portrait template produced a silently wrong page. With 240 items across six page types this had to fail loudly. |
| D57 | **`quote_text`, `quote_lang` and `lettering_style` are deliberately not prompt inputs.** D23 puts quote text on the page as overlaid outlined vector type; sending it to the model would produce misspelt, uncolourable lettering and break the reserved space the composition block creates. They are export-stage data, and the export stage does not exist yet. `color_direction` and `product_placement` are VV-Styles fields with no VV-Styles template (D32, Stage C). **Five of the six unused columns are unused correctly** — only `visual_elements` was a genuine defect. |
| D58 | **One default typeface per lettering style**, recorded in `lettering_faces`: Baloo 2 ExtraBold · Caveat Brush · Archivo Black · Libre Baskerville Bold · Permanent Marker · Montserrat ExtraBold · Big Shoulders Stencil Text Bold · Archivo Black + Caveat Brush. All verified against the font binaries for the full Spanish set; all OFL except Permanent Marker (Apache 2.0). An item may override its own. |
| D59 | **Hollow outline is a coloring-page rule, not a lettering rule.** D23 makes quote type hollow so it can be *coloured*. Apparel has nothing to colour, so VV-Styles type is filled or knocked out (D34) and the outline criteria — heavy weight, low contrast, open counters — do not govern it. Playfair Display, rejected for coloring pages because its hairlines collide when outlined, is perfectly usable on a shirt. **The two products need different type judgments and must not share one test.** |
| D60 | **The lettering default is per category.** The 36 Healing Seasons Quote pages default to Serif Editorial — it reads as a book rather than a poster, and Block Outline sets recovery affirmations like advertising. The 130 VV-Styles items are deliberately left null: no template exists for that category yet (D32), and defaulting them now would be 130 rows to correct after Stage C designs them. |
| D61 | **The overlay is kept as vector and never flattened.** Each quote page stores the type as SVG beside the raster art. Flattening bakes the letters to 300 DPI permanently; keeping them as paths makes the KDP PDF a composition of two files that already exist, and lets a quote be restyled or translated without regenerating the page. This is the decision that is expensive to reverse later, which is why it is made before the code is written. |
| D62 | **A page type records whether it has people** (`prompt_templates.has_people`). The Quote, Symbol and Decorative templates each carried `hs-environment`, `hs-furnishing`, `hs-seasonal-restraint` and all three density blocks, so a composition opening with *"No people"* was followed by *"the setting is complete and lived-in, built from real furniture, with the described subject as the clear focus."* The room won and the reserved centre never appeared. Those blocks are detached; the Environment page keeps them, because it has no people but does have a setting — two separate facts, which is why the flag is recorded rather than inferred. The ethnicity line is also gated on it: on a page of pattern it describes someone who is not there. |
| D63 | **A reserved area is specified in both dimensions, and the paper is stated in its own right.** "Roughly half the page height" said nothing about width, so the model chose its own and the type crossed into the pattern. And "pure black line work on white" was read as a description of the ink — the first Quote page came back on aged, speckled parchment. A tint costs ink on every page of the run and dirties every colour laid over it. |
| D64 | **The overlay renders through `fontkit`, not a font at render time.** Glyphs become geometry before anything is drawn, so no font needs to be installed anywhere downstream and accented Spanish is guaranteed rather than hoped for. Four of the eight faces are variable fonts whose axis default is wrong — Montserrat's is Thin — so the weight instance is cut explicitly. Font binaries and their licences are vendored in `assets/fonts/`. |
| D66 | **The reserved area is measured off each page, not assumed.** The prompt asks for an oval; the model draws a different one every time, so any fixed area is a guess wrong by a different amount on every page. The recorded box was half again as wide as the real oval at its widest point and centred lower, which is why the first real quote broke. `detectReservedArea()` reads the blank centre off the art — the longest contiguous run of rows whose white span through the centreline is wide enough to be the reserved area — and falls back to a measured default when a page has no clean centre to find. |
| D67 | **Type is fitted to the ellipse, line by line, at its widest point.** One width for the whole block is what put a descender in the pattern: the block is widest where the oval is narrowest. Each line's width now comes from the ellipse at whichever of its edges — ascender top or descender bottom — sits furthest from the centre, and the wrap settles by iteration because how wide a line may be depends on where it sits, which depends on how many lines there are. The size search uses a *relative* tolerance, so the SVG laid out in pixels and the PDF laid out in points converge on the same size rather than one a pixel apart. |
| D68 | **Every lettering gets its own storage key.** D65 protects the art from being replaced but said nothing about the letterings, and the key was derived from the source page — so each re-letter overwrote the previous one's PNG and SVG while its asset row survived, pointing at a file that now held different words. Since the SVG is what goes to print (D61), such a row would print the wrong quote. |
| D69 | **D56 applies to lettering, not only to generation.** Quote page is the only page type that reserves space for words; lettering any other lays type across the middle of a drawing, which a Solo portrait proved by coming back with "Rest is not a reward." over the figure's face. A mismatch is refused. An asset with no item behind it is ad hoc and allowed through — there is no page type to contradict. |
| D65 | **Lettering a page creates a new asset; it never replaces the original.** The unlettered art stays the artwork, so a quote can be reset, restyled or translated against it any number of times. The SVG is written beside the PNG and is what goes to print. |
| D47 | **Form is described by outline; nothing is filled, shaded, hatched or textured.** Replaces "texture rendered as pattern", which produced seek-and-find pages (§3.5). Detail and fill are different: many separate outlined shapes with white between them stay calm and remain colourable. |
| D48 | **`journaling-under-tree` and `walking-with-mug` are the canonical Solo portrait exemplars**, registered with `usable_as_input = true`. Both are Esoh's own work, so D31 does not apply. |
| D44 | **Nothing on a coloring page is filled in.** Every enclosed area is open white. Hair included. |
| D45 | **Hair is item data, never a style block.** Encoding one texture as a rule stereotypes and removes variety. |
| D46 | **Technique is stated positively; only content is excluded by name.** Four occurrences of the §2.5 trap, all of them technique negatives. |
| D43 | **Density means the composition reaches every edge, not that every surface carries marks.** "Leaving no empty ground" left the model nowhere to stop and it textured skin and sky. A coloring page needs clean enclosed areas to put colour into. |
| D39 | **Style blocks describe how a page is drawn; item briefs describe what is in it.** Objects, props and settings come from the item's own brief and are never promoted into a style block. Over-generalising six reference images into a house motif list would make 240 pages repeat (§3.3). |
| D40 | **`Healing Seasons` is a series**, recorded on `collections.series`, sitting between category and collection so a second series never collides with the first. |
| D41 | **The in-scene name-drop is per-item and opt-in** — `items.brand_mark`, null by default, either 'Healing Seasons' or 'Esoh Creations'. An occasional touch, never a signature. |
| D42 | **Export filenames are spelled out in full**, including page type and art style: `african-american-fall-09-quote-page-zentangle-pattern-v2.png`. Internal storage keys stay opaque; the descriptive name is generated at export, because an exported file leaves the database behind and has to describe itself. |
| D37 | **Every live product exists as a library row.** `Listenin' for the GOOD E.S.H.` is currently live but unrecorded. |
| D38 | **Transparent artwork is the Stage C priority, ahead of new designs.** It unlocks the garment-colour range and multiplies the catalogue from existing art. |
| D33 | The VV-Styles master list is **`VV-Styles Designs Library Original`**. The two ChatGPT-expanded exports added no quotes — only one boilerplate visual string per category and a single templated prompt — and are retired. `vv-styles-master.csv` is its restructured form. |
| D70 | **Apparel puts the phrase in the prompt; coloring pages do not.** D57 keeps `quote_text` out of a coloring-book prompt because D23 overlays it as hollow outlined type on a page whose words are meant to be coloured in. That reasoning does not reach a shirt. Apparel type is filled (D59) and drawn *into* the artwork — arched banners, offset comic caps, lettering that shares its contour weight with the image — and overlaying flat vector on top of such a design would throw away the thing that makes it read as apparel. The risk is misspelling, and the first generation located it precisely: the headline phrase came back exact while a small in-scene sign read "FFEINE" for CAFFEINE. **The phrase is safe; secondary text inside the scene is not.** Keep incidental lettering out of `visual_elements` unless it is worth checking by eye. |
| D71 | **Apparel generates at 1024×1536 and pads into a 12×16" front print.** Supersedes the 1024×1024 category setting and the 4500×5400 delivery note, which described two different shapes and neither of them a chest print. Padding not cropping, per D30 — and on transparent art the padding is free, since the design floats in the print area rather than being cut to fit it. |
| D72 | **Nothing sits behind an apparel design, and the block layer must say so by name.** Two generations produced the D34 defect in shapes a border test cannot see: an irregular cream blob with a feathered edge, then a rounded-rectangle poster card, both floating clear of all four sides. The cause was this project's own wording — "composed as one self-contained unit" and "every element locks into that one shape" meant *not scattered* and were read as *one silhouette*, so the model supplied one. Grouping is now described as an arrangement, and panel, card, badge field and rounded rectangle are excluded by name. That naming is consistent with D46, not a breach of it: D46 governs rendering *technique*, and a panel is an object. |
| D73 | **`background: "transparent"` is passed to the provider, not merely requested in prose.** The category carried the flag, the provider supported it, and nothing joined the two, so every apparel prompt asked for a knockout in words while the API parameter went unset. Setting it dropped the soft feathered edge from 4.9% of the image to 1.7%. It does not remove an enclosing panel — that is D72's job — so the two are needed together. |
| D74 | **The knockout is measured, never eyeballed, and the measurements are these.** Four of eight live products only look clean because white fabric hides the box. Three checks in `lib/transparency.ts`: an alpha channel must exist and be used; the design must fill no more than 80% of its own bounding box, since real cut-out artwork leaves gaps between its elements and a panel welds them together; and no more than 3% of the image may be half-transparent, since a cut edge is hard and a feathered one is not. Accepted references measure 60–72% fill and 0.7–1.6% soft edge; the two failed generations measured 86–92% and 4.9%. A failing image is flagged, never discarded — it has been paid for, and whether to rework or re-run is not the tool's call. What this cannot catch is a mockup: a t-shirt silhouette fills about 65% of its own box, squarely inside the accepted range. |
| D76 | **The phoenix is knocked out to artwork and type only — no poster rectangle.** Settles the D36 question. The flame at the base of the image is wanted and is the thing to watch: it is the element most likely to be lost or left with a feathered edge once the rectangle goes, so the test print is judged on whether the fire survives the knockout, not on whether the rectangle is gone. Measured against D74 like any other apparel file. |
| D77 | **The tool writes back to the spreadsheet; it does not replace it.** The sheet stays the record of what exists, so the plan is readable and revisable outside the tool and survives it. Answers the §9 structure question. Write-back covers the columns the tool can fill — status, asset link, and the four direction columns per D78 — and never silently overwrites a value entered by hand. |
| D78 | **The four direction columns are drafted by the tool and corrected by hand, not written from scratch.** 19 of 137 VV-Styles rows carry all four of Art Style, Lettering Style, Visual Elements and Color Direction (22 carry at least one); the rest carry Text/Quote, Category and Tone, which is the input a draft needs. The 19 briefed rows are the exemplars — a draft is generated against them so it inherits the house wording rather than inventing a new vocabulary per row. A drafted value is marked as drafted and is freely overwritten by the next draft; a hand-entered value never is (D77). **Stage C does not wait on this.** Its gate is one row reaching a print-ready transparent PNG, and 19 briefed rows are 18 more than that needs. Briefing the remaining 118 by hand ahead of the tool would be the manual work this project exists to remove. |
| D79 | **The 12 books publish separately — one book per line per season.** Confirms the D25 grid as the shipping unit: African American, Hispanic and Multiracial, each across all four seasons. `Healing Seasons` stays a series (D40) as a branding and shelf relationship, not a bundle: nothing is sold as a collected volume, so each book carries its own title, keywords, description and cover. The consequence for listings is that the keyword plan is needed three times over — the existing one covers African American only, and Hispanic and Multiracial listings are still outstanding. The consequence for production is that a book, not the series, is the unit that has to be complete before anything can ship, so the 240-page queue is really twelve 20-page queues and priority should be read that way. |
| D80 | **20 pages per book, not 15 — 240 pages total.** Supersedes the 180-page figure in D25 and §1. 15 pages per book was an artefact of the original tracker, and reads thin against KDP norms where buyers expect 30+. The increase is affordable precisely because of what this tool is for: 60 additional pages is roughly $45 of generation at three attempts each on the `lib/pricing.ts` estimates, against the hours of hand-work it would have cost before. **Per-book mix goes 5 Solo portrait / 5 Community scene / 4 Quote / 2 Environment / 2 Symbol / 2 Decorative.** Symbol and Decorative rise from one page to two on purpose — both lack an approved exemplar (§9), and a single specimen per book gives nothing to judge style consistency against. The one line item that does not scale for free is Quote: at 4 per book the series needs 48 bilingual quotes rather than 36, and Spanish copy is a judgment about tone and idiom, not a draftable column (§4.2, D78). |
| D81 | **All 15 brand/legal flags are cleared; three phrases were rewritten to get there.** The test applied was not "is this a recovery phrase" — it was **does this reproduce fellowship literature or imply official affiliation**. Nothing in the set names AA or NA or uses their marks, which is the line marketplaces actually enforce on, so the exposure was always narrower than the flag count suggested. Three rewrites: `Newcomer: The Most Important Person in a Meeting` → **`Newcomer- The Real M.I.P.`** (the original was near-verbatim AA text; the rewrite carries the same meaning as original wording); `H.O.W. Honesty, Openminded, Willingness` → **`H.O.W.`** (the acronym circulates freely, the spelled-out expansion is the literature phrasing); `Clean & Serene since 1953 (or clean date)` → **`Clean & Serene since (clean date)`** (1953 is NA's founding year and pointed at a specific fellowship; the date was only ever meant as a personal one). The remaining twelve are sayings in general circulation or Esoh's own words — `Not a dumptruck` is original, on sponsors and support networks not existing to be dumped into, and `Listenin' for the GOOD E.S.H.` is Esoh's own coinage, a rewrite of "the good ish" onto Experience, Strength and Hope. The seven newest rows, 0131–0137, were never triaged and are cleared as written from experience rather than drawn from any source. |
| D82 | **`(clean date)` is a fill-in-the-blank, and the tool has no concept of one.** VVS-0009 is the first personalised design in the library: the phrase is incomplete until a buyer's own date is set into it. That is a product capability — a variable field in the artwork, a buyer-supplied value, and a print file generated per order — and none of it exists. Until it does, the row is either produced with a blank rule to write on, or held. Not a Stage C blocker; it is one row, and it is recorded here so it is not discovered as a surprise at print time. |
| D83 | **Cost is computed from returned tokens, not looked up by size — and the rates are verified.** `lib/pricing.ts` carried a warning that its numbers were unverified guesses. They were not: checked against 29 real jobs, gpt-image-1's image output tokens are fixed per size and quality (1024×1536 returns 408 / 1584 / 6240 for low / medium / high), and every cell of the table was those counts at **$40 per 1M output tokens**. The table was right; what it *omitted* was input — text at $5/1M and reference images at $10/1M — which the function never saw because it took size and quality rather than usage. `costFromUsage()` now computes the actual figure from `usage_json` and `estimateCostUsd()` is kept for the one job it is genuinely needed for: pricing a batch **before** it runs (Stage E), where no usage exists yet. The 29 historical rows are backfilled: $5.8850 → $5.9697. Input is 1.5% of spend today and will grow, because feeding reference images in is the premise of the Style Library (§6). |
| D84 | **`Healings Seasons Workbook 1 - master_launch_sheet.csv` is the listing plan of record, and its 48 rows are 12 books × 4 candidate listings.** Supersedes `keyword_listing_plan_african_american...csv`, which covered one line in six columns. The workbook covers all three lines in twelve — title, subtitle, SEO slug, primary keywords, short and long description, target audience, cover concept and priority — with no empty cells. Within any one book slot the four rows carry an **identical subtitle and identical cover concept**, differing only in one word of the title and the keyword string, which settles what they are: keyword variants to choose between, exactly as D25 read the earlier "flagship 1–4" rows. **One ships per book, twelve in total.** Publishing all four would put 48 near-duplicate listings on KDP sharing covers and subtitles, which is keyword stuffing and is penalised. Ten of the twelve columns are listing metadata the generator never reads; `cover concept` and `commercial priority` are the two that touch production. |
| D85 | **Images are not shared across categories; they are derived, and the derivation is recorded.** `generated_assets.category_id` is NOT NULL and stays that way — the categories disagree on pixels, since social-content is 1024×1024 where the rest are 1024×1536 and vv-styles is transparent where the rest are not, so one file cannot be a shirt front and an Instagram square. Reuse therefore means a **new asset made from an approved one**: a lettered page, a transparent cut, a reframe for another category. The tool already derives at `/api/overlay`, which recorded its parent in `metadata_json.overlay.from` — real, but buried under an overlay-specific key that a transparency cut or a reframe would never write. Migration 028 promotes it to `derived_from_asset_id`, a nullable self-reference with `ON DELETE SET NULL`, because losing an original should orphan a derivative and never destroy it — the derivative was paid for separately and may be the one in print. The four existing lettered pages are backfilled. This is what makes D38's "multiplies the catalogue from existing art" and Stage G's promotion of apparel art into social content answerable rather than assumed. |
| D86 | **Three libraries, and D4's ordering did not survive contact.** The word "library" names three different things and they are routinely confused. **Design Library** — the spreadsheet's own name, now the `items` table, 310 rows of intent: what is going to be made. **Style Library** — `prompt_blocks`, `prompt_templates` and `reference_images`, 57 / 8 / 4: how a thing is drawn, kept separate from what is in it per D39. **Asset Library** — `generated_assets`, 36 rows: what was actually made, one row per image paid for. A Design Library row is a plan and costs nothing; an Asset Library row is an outcome and cost money. D4 put the Asset Library ahead of style refinement, and the build went the other way: Stage B is done and Stage D has not started. That inversion was correct — reference images turned out to be what drives quality (§6, D20), so style work had to come first — but D4 no longer describes the order that was followed. `/api/assets` currently returns the twelve most recent assets, newest first, with no filtering; its own comment names filtering across category, collection, page type, status and priority as Stage D. **D4 is amended: the Asset Library is a primary feature, but it follows style rather than preceding it.** |
| D87 | **n8n stays out, and D5's trigger is replaced.** D5 deferred n8n "until external integrations exist". That condition is now met — Printify was added at Stage F, read-only, a `catalog.read` token behind `scripts/printify-print-areas.mjs` — and meeting it changed nothing, which is the evidence the test was wrong. The integration is one script run by hand; putting a workflow engine behind it would add a second runtime, a second credential store and a second thing to debug in order to orchestrate a single command. **The replacement trigger: n8n when work must run unattended or span more than two services.** Neither holds. D7 is localhost-first, so nothing runs with the laptop shut; there are two services and both are called directly; and D1 makes this a single-user internal tool with nobody needing to edit workflows without code. Stage C will *write* to Printify and Stage E will batch — the usual moments for reaching at an orchestrator — but under D6 a direct call from a route is less machinery than a workflow engine, and it keeps resolved prompt, cost and asset lineage in one database instead of two systems. |
| D88 | **D6 stands — one Next.js app, no monorepo — and its one real cost is now paid off.** At 2,612 lines across `lib/` and the routes, a monorepo buys enforced package boundaries and build caching that nothing here needs, against workspace config, TypeScript project references and a structure this project's own `AGENTS.md` flags as a Next.js complication. The genuine cost of the single-package shape was narrower and worth naming: `scripts/preview-prompt.mjs` could not import `composePrompt()` because a `.mjs` file cannot load a `.ts` module, so it **carried a copy of the twenty lines that decide what prompt the money buys**. The copy agreed, and said openly that it mirrored the original — but a preview that reimplements the generator can drift from it silently, and nothing would suggest the preview was the thing that was wrong. The script is now `scripts/preview-prompt.mts` and calls the real `getBlocks()` and `composePrompt()`. `.mts` because top-level await needs ESM; `tsx` because Node strips types natively but not extensionless imports, and `lib/` uses those. One dev dependency against a duplicate of the engine's core. It is also now typechecked, which the `.mjs` never was, and reports dropped blocks by asking the real function rather than re-deriving the rule. |
| D89 | **Localhost-first stays; it stops meaning one copy.** D7 costs nothing — one user (D1), no unattended work (D87), nothing external needing to reach in — and hosting would buy auth, deploys and a bill for a tool only Esoh opens. What was underpriced is D15's "container files are not backed up". `/storage` was gitignored entirely: 90 MB, 40 files, every image ever paid for, in one place. The dollars are not the loss. `reference_images` points at four files — `journaling-under-tree`, `walking-with-mug`, `hoodie-on-sofa` and its correction — and §6 holds that the Style Library cannot carry a style until one fully approved page exists. **Those four files are that.** Losing them does not mean re-running a generation, it means re-deriving the house style. Second and quieter: the 4 approved and 12 rejected judgments live only in local Postgres, and nothing else records which way a page was called. Two fixes, both small. The exemplars are committed — `.gitignore` now excepts `/storage/exemplars`, since they change almost never and `direction.md` already cites them by name. And `npm run db:dump` writes a timestamped `pg_dump` to `/backups`, gitignored, because a copy beside the original is not a backup. Neither changes D7. |
| D75 | **Naming the garment colour in the prompt ties the artwork to that garment.** It is what makes light detail survive on dark fabric, and it is why the coffee design reads on natural sand and nearly disappears on black. It also cuts against the arithmetic in §4.5 — 8 designs × 6 colours ≈ 48 products assumes one file works on every garment. Both can be true, but not for the same file: a design is either colour-directed for one garment or built with contrast that holds on any, and which one it is has to be decided per design rather than assumed. |

---

## 9. Open questions

**Answered since the last draft**
- ~~VV-Styles phrases are not recorded anywhere~~ → 129 quotes exist; see D33.
- ~~No references for Symbol, Decorative or Quote pages~~ → four scanned pages, §3.2.
- ~~Crop, pad or outpaint?~~ → pad, D30.
- ~~Do VV-Styles and social need collections and items?~~ → yes. One VV-Styles item is one design; the 129 rows map onto category → collection → item with no model change. They need separate categories because the output ratios differ.

**~~Known limitation in the quote overlay~~ — Resolved.**
- ~~The type box is a rectangle; the reserved area the model draws is an oval.~~ It broke on the first real quote: the descender of "grow" ran out of the oval and across the pattern. Fixed per D66–D67 — the area is measured off each page and the type is fitted to the ellipse line by line.

**Blocked on a missing stage, not on wiring** (D57)
- ~~**Quote pages cannot complete.**~~ **Done.** The prompt reserves the centre and forbids drawn letters (D23), but no overlay step exists. `POST /api/overlay` letters a generated page (D64, D65). `fontkit` replaced `opentype.js` — it instances variable fonts, which four of the eight faces need.
- ~~VV-Styles has 130 items and no template~~ → built 2026-08-27 (migration 020). One template, nine apparel art styles, and `quote_text`, `visual_elements`, `lettering_style`, `color_direction` and `product_placement` all feed it. Twelve designs are art-directed; the other 118 have empty direction columns. They are drafted by the tool and corrected by hand (D78), not briefed by hand ahead of it, and they do not block Stage C.

**Production**
- ~~Are the 12 books published separately, or bundled as one series?~~ → separately, one per line per season, D79.
- ~~The keyword listing plan covers African American only. Hispanic and Multiracial listings still to come.~~ → all three lines are covered by the launch workbook, D84.
- ~~Should the 19 VV-Styles categories consolidate to the proposed 9?~~ → yes, applied 2026-08-27 (migration 021). The portfolio capsule's six collection names turned out to *be* six of the proposed nine under better wording, so the capsule's naming was taken where it existed and the proposed list used for the rest. All 130 items are sorted; one row with no `Category` at all stays in Unsorted. Two judgment calls stand flagged: `Love` went to Family & Faith as the nearest relational grouping, and `Self-Awareness` to Truth & Accountability as honest self-assessment rather than self-regard.
- ~~14 VV-Styles quotes are recovery-fellowship-adjacent and pre-flagged `Brand / Legal Review`. Decide before printing.~~ → there were 15, all cleared, three rewritten; D81. VVS-0094 `I survived what was supposed to break me.` carried a separate `Sensitive Content Review` and is cleared too. **All 137 rows now read `Clear`; no review flag is outstanding.**

**Current state of VV-Styles**
- Store is built but **not public**. 8 shirt styles live, one tester shirt ordered and approved. Designs are currently made by hand in the Printify web editor — slow, and the reason this tool exists.

**Style**
- All seven existing shirts are catalogued in §4.5.
- Photoreal Composite is **kept** (D36). ~~Does the phoenix keep its poster rectangle?~~ → knocked out to artwork and type, D76. The base flame is the element to check on the test print.
- No approved in-house exemplars exist yet for Quote, Symbol or Decorative pages. Stage B must produce the first ones.

**Structure**
- ~~Should the tool write back to the spreadsheets, or replace them?~~ → write back, D77.

**Technical**
- ~~Verify the estimated rates in `lib/pricing.ts`.~~ → verified and rewritten to compute from usage, D83. Confirmed against the OpenAI dashboard on 2026-09-04: the five days the app generated on (15, 22, 25, 27, 31 August) are the only days with spend, and each matches to within a couple of cents. The $0.14 between the database's $5.97 and the reported $6.11 is hand-run testing on the same key, not a rate error. **Real cost is $0.25 per high-quality page.**
- Vector trace step for apparel — later, not blocking.

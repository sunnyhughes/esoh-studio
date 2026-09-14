# The workbook, the tool, and where they disagree

> **SUPERSEDED 2026-09-13 by `docs/source-of-truth.md`.** Written before
> `docs/references/hs-folder/` was found — 50 files including 180 assembled
> prompts, a rebuilt 10-template framework, and Esoh's own project outline.
> Parts of this document are wrong. Kept for the record.

Written 2026-09-12, after the full *Healing Seasons — Creative System Rebuild*
workbook reached the repo for the first time. All 16 sheets are extracted to
`docs/references/workbook/`, alongside the original `.xlsx`.

This document exists because the tool and Esoh's own direction had drifted apart
without anyone being able to see it. It is a reconciliation, not a plan: for each
layer it records **what the workbook specifies**, **what the database contains**,
and **which of the two is authoritative**. The decisions at the end are Esoh's.

---

## 1. What arrived, and what had been missing

Six sheets were named; the workbook holds sixteen. Only two had ever been in the
repo.

| sheet | in repo before? | what it holds |
|---|---|---|
| `README_REBUILD` | ❌ | The rules of the system, in Esoh's words |
| `master_launch_sheet` | ✅ | 48 books: subtitle, keywords, descriptions, audience, cover concept |
| `Production_workflow` | ❌ | The 8-phase pipeline per book |
| `recovery_coloring_book_tracker` | ✅ | 180 pages: page type, prompt notes, priority |
| `keyword_listing_plan_african_am` | ✅ | Listing copy |
| `keyword_listing_plan_hispanic_m` | ❌ | Listing copy, Hispanic + Multiracial |
| `Product_Line_Structure` | ❌ | 3 lines × 4 seasons × 15 pages, with creative identity |
| **`page_template_library`** | ❌ | **8 templates: layout formula, zones, white-space rule** |
| **`page_design_system`** | ❌ | **Trim, bleed, line weights in points, export checklist, trauma-informed rules** |
| **`art_direction_specs`** | ❌ | **Per-line character/scene/style/forbidden guidance** |
| **`template_page_assignment_matrix`** | ❌ | **180 page-specific directions** |
| **`template_prompt_framework`** | ❌ | **A prompt formula per template** |
| `bundle_matrix`, `catalog_structure_matrix`, `release_calendar_matrix`, `pricing_tier_matrix` | ❌ | Business structure |

`direction.md` §2.2 states the Style Library is *"seeded from the spreadsheets and
reference images. Nothing invented."* Five sheets of creative direction never
arrived. The gaps were filled by the model, silently, in migrations 035–040.

---

## 2. The headline number

**0 of 180.** Not one brief in the database matches either source.

| source | mean length |
|---|---|
| tracker `prompt notes` | 40 chars |
| matrix page-specific direction | 191 chars |
| **database brief today** | **240 chars — none matching either** |

The symbol page that started this:

- **Tracker:** "Leaves, pumpkins, journals, and faith symbols."
- **Matrix:** "Autumn motif collection: layered leaves, steaming mug, candle, acorn, open book, small flower, heart, and journal; **arrange in intentional clusters with plenty of separation**."
- **Database:** "A centred cluster of separate autumn symbols **at large scale** — a broad leaf, a small pumpkin, a closed journal…, **each drawn as its own clean outlined shape with clear space between them**."

Esoh asked for eight motifs in intentional clusters. The database asks for five
objects at large scale, isolated. That is the whole difference between a
designed page and clip-art, and it was introduced by migration 040.

---

## 3. Esoh had already written the laws the project rediscovered expensively

From `README_REBUILD`, predating the tool:

> **Critical rule** — "A template is a composition scaffold, not a finished image
> prompt. The tracker prompt notes are the page-specific visual story."

That is D118, D120, D121 and D131 — *a block loses to a brief* — stated up front.

> **Quality check** — "If two generated pages look interchangeable, the problem is
> no longer solved by adding adjectives; revise the page-specific action,
> composition, props, relationship, or emotional story."

That is §2.5 and the whole of the tuning-by-wording dead end.

> **Generation goal** — "line identity + season + product theme + page-specific
> tracker prompt + template structure + global print rules."

Five inputs. The tool composes three of them. **Line identity** and **product
theme** are absent from every prompt it has ever built.

---

## 4. Layer by layer

### 4.1 Templates — the tool has 6, the workbook specifies 8

`page_template_library` defines eight composition scaffolds. The tool keyed one
template per page type and so collapsed the variants:

| workbook template | page type | in the tool? |
|---|---|---|
| TPL-01 Solo Portrait Calm Scene | Solo portrait | merged |
| TPL-06 Walking Reflection Scene | Solo portrait | **missing** |
| TPL-08 Window + Journal Reflection | Solo portrait | **missing** |
| TPL-02 Support Circle Scene | Community scene | merged |
| TPL-07 Porch or Patio Conversation | Community scene | **missing** |
| TPL-03 Quote Page Framed Border | Quote page | ✅ |
| TPL-04 Healing Room Interior | Environment page | ✅ |
| TPL-05 Symbol Cluster Page | Symbol page | ✅ (wrongly specified) |
| — | Decorative page | **tool-invented; no workbook template** |

**This is a direct cause of the sameness.** Esoh specified three distinct solo
compositions — seated calm scene, walking outdoors, seated at a window with a
journal. The tool has one. And *Window + Journal Reflection* is one of the three,
which is exactly why journaling reads as ubiquitous: a third of the solo pages
are supposed to be window-and-journal, and the other two thirds were never given
their own composition to be different in.

**Decorative page has no template in the workbook.** It exists in the tracker as
12 rows and the tool built `hs-decorative-page` for it from nothing.

### 4.2 Symbol pages — what TPL-05 actually asks for

| | workbook (TPL-05 + framework) | tool today |
|---|---|---|
| motif count | **8–15** | 4–6 in practice |
| structure | **one central anchor**, secondary motifs in **balanced clusters** | "a single centred group" |
| scale | **three visual scales — large, medium, small** | one scale, "at large scale" |
| separation | negative-space **channels** between clusters | "clear space between them" |
| stated goal | *"so the page feels designed rather than randomly filled"* | — |
| density axis | "Light to moderate" | `Open` |
| art style | — | `Bold Minimal` on 6 of 12 |

Esoh's spec anticipated the exact failure that occurred and named it. Nothing
about symbol pages was wrong as a concept; the tool's version of them was.

### 4.3 Art direction per line — the tool has one sentence

`art_direction_specs` gives each of the three lines nine columns: character
rules, scene rules, line style, detail level, quote page style, seasonal cues, an
explicit **forbidden** list, and a closing note on identity.

The tool's entire implementation of this is one generated sentence:
`The figure is African American.`

The forbidden lists have never reached a prompt. They include: stereotypes,
costume-like cultural props, trauma imagery, violence, drug use, visible injury,
police scenes, weapons, restraints, despair-centred compositions; for the
Hispanic line, pan-Latin stereotypes and forced national symbols; for the
Multiracial line, tokenised diversity and exaggerated mixed features.

For a trauma-informed recovery product this is the most serious gap in the list.

### 4.4 Print and line system — quantified, and never implemented

`page_design_system` specifies what the tool currently approximates in prose:

| spec | workbook | tool |
|---|---|---|
| trim | 8.5 × 11 portrait | ✅ matches (D30) |
| bleed | 0.125 in full bleed; none for digital | partial |
| safe margin | **0.375 in minimum** | padding-derived |
| primary contour | **0.75–1.25 pt** | "confident heavy contours" |
| secondary detail | **0.5–0.75 pt** | "finer lines" |
| contrast rule | **at least two visibly distinct weights** | implied |
| export check | **no line below 0.5 pt** | not checked |
| emotional pacing | **each book alternates social and quiet scenes** | not modelled |

The line weights are numbers. They could be measured on output the way
transparency and black-fraction already are, instead of being asked for in
adjectives.

### 4.5 The assignment matrix contradicts itself

`template_page_assignment_matrix` has 180 rows and two columns that disagree.

- Its **`notes`** — the page-specific directions — align perfectly with the
  **tracker's** page types. Slots 9–11 are quote-page borders, 12 is a symbol
  collection, 13 is a decorative flat-lay, 14–15 are room interiors.
- Its **`template id`** column follows a *different*, interleaved book structure
  that deliberately avoids putting four portraits in a row.

They diverge from slot 4 onward. Slot 4 is assigned *Support Circle* but its
direction describes one woman with a mug; slot 5 is assigned *Quote page* but its
direction describes four adults in a recovery circle.

**The notes are the reliable column.** They agree with the tracker, they are
specific, and they are 180 pieces of real direction. The template-id column is a
second, unfinished idea about book structure.

| structure | Solo | Community | Quote | Environment | Symbol | Decorative |
|---|---|---|---|---|---|---|
| tracker (grouped) | 48 | 48 | 36 | 24 | 12 | 12 |
| matrix template ids (interleaved) | 60 | 36 | 36 | 24 | 24 | 0 |

---

## 5. One genuine conflict between the workbook and measured evidence

`template_prompt_framework` gives every template the same negative prompt list:

> blurry, gray fill, grayscale, photorealistic, distorted anatomy, extra fingers,
> unreadable hands, overcrowded background, generic stock pose, stereotyped
> cultural props, trauma imagery, violence, weapons, drug use, visible injury,
> text artifacts

`direction.md` §2.5 records five measured cases where naming a thing to forbid it
produced that thing — "no decorative borders" produced a border, "no hatching or
stippling" produced a stippled page, a clause naming leaves twice produced leaves
in six of six renders, and furniture named to explain a rule got a room drawn
(D131).

The two are not reconcilable as written, and the distinction matters:

- **Content exclusions hold.** "No people" and "No border or frame" have been
  obeyed in every generation. The safety list — violence, weapons, drug use,
  visible injury, police — is content, and belongs in the prompt.
- **Technique and rendering negatives backfire.** "blurry", "gray fill",
  "grayscale", "distorted anatomy", "extra fingers" are the shapes that have
  misfired repeatedly. These should be stated positively, or measured on output
  rather than asked for.

Recommendation: keep the workbook's safety negatives verbatim; convert the
rendering negatives to positive statements. This is a change to §2.5, not an
exception to it.

---

## 6. Decisions needed before any rebuild

1. **Book structure.** Tracker's grouped 15, or the matrix's interleaved 15?
   The interleaved one is better reading — `page_design_system` itself says each
   book should alternate social and quiet scenes — but it drops Decorative pages
   and doubles Symbol pages.
2. **Does Decorative page survive?** It is in the tracker, has no template in the
   workbook, and its tool-built version is the one page type whose output Esoh
   has not objected to.
3. **Adopt all 8 templates?** Three solo variants and two community variants
   instead of one each. This is the single highest-value change for variety.
4. **Whose briefs?** The matrix's 180 page directions replace the model's 180
   briefs — with the Hispanic line's 031 revision, which Esoh supplied
   separately, taking precedence where they differ.
5. **Negative prompts:** split as recommended in §5, or keep the workbook's list
   whole and re-test?

## 7. Suggested order, once those are answered

1. Import the matrix's 180 page directions as briefs. No generation.
2. Build the missing templates (TPL-06, TPL-07, TPL-08) and re-specify TPL-05.
3. Put `art_direction_specs` into the prompt as a per-line block, forbidden lists
   included.
4. Retire `Bold Minimal` and `Hand-Drawn Doodle` from coloring books — Esoh's
   decision, 2026-09-12 — and reassign those 18 rows using the workbook's own
   detail-level language rather than the apparel style vocabulary.
5. Encode the `page_design_system` numbers as export checks.
6. Only then generate — one page per template, reviewed, before any batch.

Nothing above needs a single API call until step 6.

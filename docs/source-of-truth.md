# Healing Seasons — the source of truth

Written 2026-09-13. **Replaces `workbook-reconciliation.md` and
`workbook-versions.md`**, both of which were written before the richest material
was found and are wrong in places. They are kept for the record; this is the one
to read.

Everything referenced here is now in the repository. Nothing depends on Drive.

---

## 1. The corpus

| group | where it is now | what it is |
|---|---|---|
| **The production rebuild** | `docs/references/hs-folder/` | 50 files. The richest and most current set. Contains `00_PROJECT_OUTLINE.md`, `page_prompts_full.csv`, the rebuilt assignment matrix, the 10-template framework, the quote library, and the re-authored Spring tracker. |
| Workbook, lineage A (16 Aug) | `docs/references/workbook-aug16/` | 20 CSVs + `Healings Seasons Workbook 1.xlsx` |
| Workbook, lineage B (10 Sep) | `docs/references/workbook-sep10/` | `Healing_Seasons_Hispanic_Line_Revised.xlsx`, 15 sheets |
| Workbook, lineage C (13 Sep) | `docs/references/workbook/` | `Healing_Seasons_Master_Rebuild.xlsx`, 16 sheets |
| **Scope note** (31 Aug) | `docs/references/Esoh_Studio_Scope_Note_for_Claude.md` | A written decision about what the tool is |
| extractor | `scripts/xlsx2csv.py` | so any of this is repeatable |

`hs-folder` was on this machine from 16 August. A thinner copy of it lived in
the Linux home directory, and that is the one that had been read. The difference
between the two copies is most of this week.

---

## 2. The scope note contradicts D124, and the scope note is Esoh's

Dated **31 August**, written before any of this was built:

> I've decided to **drop "Print Designs" and "Social Content" as separate
> categories.** They are not product lines — they are **output formats /
> destinations** for an image that already exists… Build the two product-line
> pipelines plus the shared destinations/export layer. Do not build separate
> print or social generation modules.

The database has **four** categories. Two of them — `print-designs` and
`social-content` — are the ones Esoh had already decided should not exist as
categories. **D124, written 2026-09-12, formalised them as categories and gave
them definitions.** That decision was taken without this note and is wrong on
the architecture, however sound its descriptions were.

The note's model is *generate once, export many*: a Design belongs to one product
line (Coloring Books or VV-Styles) and has many Destinations — tee print,
sticker, poster, social story 9:16, social square, reel cover, listing mockup.

**The tool already has the right primitive and is using it for something else.**
D85's `derived_from_asset_id` — a new asset made from an approved one, with its
parentage recorded — is exactly a destination record. What is missing is the
destination *vocabulary* and the resize/reframe operations, not a category.

This also dissolves D93, which worried that `social-content` is square-only and
that Instagram wants 4:5 and stories want 9:16. Those are destinations of one
design, not shapes a category must be born with.

**Action:** D124 needs amending and D93 needs withdrawing. No migration should
create content under either empty category.

---

## 3. The authority map

| artifact | authoritative source | why |
|---|---|---|
| **180 assembled prompts** | `hs-folder/page_prompts_full.csv` | Full prompt + compact prompt + negative per page; doc spec → scene → composition → representation → season → tone → line work → white space → text handling. Page types match the tracker **180/180**. |
| **Template assignment** | `hs-folder/template_page_assignment_matrix.csv` | 13 columns incl. `scene`, `detail load`, `assignment basis`. Matches tracker page type **180/180**; the workbook's version matches it 34/180. |
| **Templates** | `hs-folder/template_prompt_framework.csv` | **10 templates**, with per-template composition, white-space, quote-handling, line-weight and negative directives. |
| Template use and pacing notes | `workbook-aug16/page_template_library.csv` | the 16 per-template values lineage C flattened |
| Template layout formula and zones | `workbook/page_template_library.csv` | lineage C's enrichment |
| **Per-line art direction** | `workbook/art_direction_specs.csv` | lineage C: 3,776 chars, no shared boilerplate; A had six of nine columns identical across the lines |
| **Spring, 45 pages** | `hs-folder/illustration-production-tracker.csv` | re-authored: real page titles, interleaved order, production gates |
| Summer / Fall / Winter, 135 pages | `hs-folder/page_prompts_full.csv` + the old tracker | the only source for their scenes |
| **Hispanic briefs, 60 rows** | `workbook-sep10` tracker | already in the database via migration 031 |
| **Quotes** | `hs-folder/quote-and-affirmation-library.csv` | 36 quotes — 24 English, 12 Spanish — with review status and motif |
| Print specs and export checks | any `page_design_system.csv` | byte-identical in every lineage |
| **Scope and architecture** | `Esoh_Studio_Scope_Note_for_Claude.md` | §2 above |

---

## 4. Decisions I was about to ask for that Esoh has already made

`00_PROJECT_OUTLINE.md` answers three of the five open questions from the
superseded document, and its reasoning is better than the options I drafted.

**Book structure — interleaved wins.** The outline names the old grouped order as
a defect: *"four straight group scenes in the middle of every book."* The new
rhythm is `solo · walking · window · community · quote · porch · interior ·
symbol · quote · solo · community · interior · symbol · quote · window`, with
quote pages landing at 5, 9 and 14, and no two heavy pages adjacent. All three
lines share it.

**Decorative page survives**, and gets TPL-10, a template it never had anywhere.

**There are ten templates, not eight.** TPL-09 Outdoor Sanctuary, because seven
Environment pages are outdoor while TPL-04 is explicitly an interior; TPL-10
Decorative Border & Pattern. TPL-07 is renamed *Pair Conversation Scene* because
what selects it is party size, not furniture. The outline offers a fold-back to
eight if preferred — one find-and-replace.

**Spring exists twice and the newer one wins.** `illustration-production-tracker`
is not a re-sequencing, it is a **re-authored Spring**: new page titles
("Spring Renewal Journal" rather than "Woman journaling by a rainy window"), a
different type mix, richer per-page prompts. Recommended split, which this
document adopts: **new Spring set for the 45 Spring pages; the 180-row files for
Summer, Fall and Winter**, converted into the new shape as each is scoped.

**Hispanic is Spanish-only, with a gate.** All 12 Hispanic quotes are Spanish and
marked *Needs Native Review*; the launch tracker holds all four Hispanic products
until a native speaker reviews them; the QA checklist has a
`spanish_native_review_verified` column. The covers are fully Spanish —
*Colores de Sanación*.

---

## 5. What this says about the tool

Measured against the material above, rather than against my own earlier guesses.

1. **Two empty categories exist that were decided against on 31 August.** §2.
2. **Every one of the 180 briefs in the database was written by the model.** None
   matches any source. There are now 180 fully assembled prompts that should
   replace them.
3. **Six templates where there should be ten.** The three solo variants and two
   pair/community variants were collapsed into one each — which is the direct
   cause of the sameness, and of journaling reading as ubiquitous, since
   *Window + Journal Reflection* is one of the three solo templates.
4. **The books are in the old grouped order.** The interleaved rhythm is not
   modelled anywhere in the database.
5. **Per-line art direction is one generated sentence** — `The figure is African
   American.` — against nine columns per line, including forbidden lists that
   have never reached a prompt. For a trauma-informed product this remains the
   most serious gap.
6. **The 84 people-free pages need an explicit no-figures directive.** The
   rebuild found this independently of D117 and fixed it in the prompt program.
7. **Quotes have no review state.** The database holds 36 quotes; the library
   marks them 6 Approved, 12 Pending, 18 Draft, and 12 of them are blocked on
   native Spanish review. The tool can currently letter and export a page whose
   quote is unapproved.
8. **Production gates are not modelled.** The Spring tracker carries
   `prompt_status`, `draft_status`, `revision_status`, `cultural_review_status`,
   `quote_approval`, `final_line_art_status`, `png_export_status`,
   `pdf_placement_status`, `overall_approval`, `owner`, `target_due_date`. The
   tool has one `status` column.
9. **Print specs are quantified and unimplemented** — 0.375 in safe margin,
   0.75–1.25 pt primary contour, 0.5–0.75 pt secondary, no line below 0.5 pt on
   export. These are measurable on output.

---

## 6. Still genuinely open

1. **Ten templates or fold back to eight?** The outline offers both.
2. **Negative prompts.** The assembled prompts carry a long list that includes
   rendering negatives — *gray shading, grayscale, distorted hands, extra
   fingers, childish cartoon style*. §2.5 has five measured cases of naming a
   thing producing it. Content exclusions have held in every generation;
   rendering negatives have backfired. Split, or adopt whole and re-measure?
3. **Convert Summer/Fall/Winter now, or one season at a time?** The outline's
   build order does African American Spring first, all the way to launch, before
   cloning.

## 7. Order of work

1. **Amend D124, withdraw D93**, and stop treating print/social as categories.
2. Import the **180 assembled prompts** and the **rebuilt template assignment**.
3. Add the **four missing templates** (TPL-06, TPL-07, TPL-08 variants) plus
   **TPL-09 and TPL-10**.
4. Put **`art_direction_specs`** into the prompt as a per-line block, forbidden
   lists included, and give the 84 people-free pages the no-figures directive.
5. Re-author **Spring** from `illustration-production-tracker` — page titles,
   interleaved order, production gates.
6. Add **quote review state** and block lettering on unapproved quotes.
7. Encode the **`page_design_system`** numbers as export checks.
8. Only then generate — one page per template, reviewed, before any batch.

Steps 1 through 7 need no API calls.

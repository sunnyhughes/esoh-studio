# Which version of the workbook is right

> **SUPERSEDED 2026-09-13 by `docs/source-of-truth.md`.** Written before
> `docs/references/hs-folder/` was found — 50 files including 180 assembled
> prompts, a rebuilt 10-template framework, and Esoh's own project outline.
> Parts of this document are wrong. Kept for the record.

Written 2026-09-13. Companion to `workbook-reconciliation.md`, which compares the
workbook against the database. This one compares the workbook against *itself*.

Five sources were found and compared sheet by sheet, content-hashed with line
endings normalised.

| # | source | where | date |
|---|---|---|---|
| 1 | 20 loose CSVs | `~/Healing Seasons Information/` | 16 Aug |
| 2 | `Healings Seasons Workbook 1.xlsx` | Drive · Healing Seasons | 11 Sep |
| 3 | `Healing_Seasons_Hispanic_Line_Revised.xlsx` | Drive + `Esoh Backups/` | 10–11 Sep |
| 4 | `Healing_Seasons_Master_Rebuild.xlsx` | Drive · Healing Seasons | 13 Sep |
| 5 | the shared link | downloaded 12 Sep | — |

**Sources 4 and 5 are identical on every sheet**, and the two copies of source 3
are identical to each other. So the five collapse to **three lineages**:

- **A** — 16 August (source 1, and source 2 on most sheets)
- **B** — early September (source 3, the Hispanic revision)
- **C** — the current rebuild (sources 4 and 5)

---

## 1. The verdict, sheet by sheet

| sheet | versions | authoritative | why |
|---|---|---|---|
| `page_design_system` | 1 | **any** | byte-identical in all three. No conflict. |
| `Production_workflow` | 1 | **any** | identical. |
| `bundle_matrix`, `pricing_tier_matrix` | 1 | **any** | identical. |
| `recovery_coloring_book_tracker` | 2 | **B**, for the Hispanic rows only | A and C are byte-identical; **B is the only file containing the revised Hispanic briefs.** |
| `art_direction_specs` | 3 | **C** | 3,776 chars vs 1,899 in A, and **0 constant columns** — each line finally has its own guidance in all nine columns. In A, six of nine were shared boilerplate. |
| `template_page_assignment_matrix` | 3 | **C** | In A and B the `notes` column is **one sentence repeated 180 times**. Only C holds real page directions. |
| `template_prompt_framework` | 3 | **C** | 7,006 chars vs 4,420; the three global columns are unchanged across all versions. |
| `page_template_library` | 2 | **split — see §3** | C enriches layout formula and zones, and **flattens two columns that A holds in full**. |
| `master_launch_sheet` | 3 | **C** | steadily enriched; business metadata, no creative impact. |
| `catalog_structure_matrix`, `release_calendar_matrix`, `keyword_*` | 2 | **C** | business sheets. |

Seven files exist **only** in the 16 August export and nowhere else:
`recovery_coloring_book_summary`, `keyword_listing_full_matrix`,
`Producttype-Purpose`, `Productline-Seasonaleditions…`, and three sheets of
print-platform research (`Rank-Platform-Bestfor…`, `Platform-Quality-Speed…`).
None affects page generation; all are worth keeping.

---

## 2. The one that would have cost real work

`recovery_coloring_book_tracker` is **byte-identical in the 16 August export and
in today's rebuild**. The revised Hispanic briefs exist in exactly one of the
five files.

```
Hispanic Fall 01 — prompt notes

A (16 Aug)   Woman in shawl journaling beside a window.
B (10 Sep)   Latina woman in her 40s with thick wavy dark hair wrapped in a
             textured shawl, seated beside a fall-lit window writing in a
             journal; a warm mug, leafy plant, and thoughtful gaze convey
             reflection and emotional release.
C (rebuild)  Woman in shawl journaling beside a window.

mean length, 60 Hispanic rows:   A 39    B 223    C 39
```

Importing "the newest workbook" wholesale would have destroyed the best-briefed
sixty rows in the library. They are safe only because migration 031 already
imported them, so **the database is currently ahead of every spreadsheet** on
that line. The rule this sets: *newest is not authoritative; authority is
per-sheet, and in one case per-column.*

---

## 3. What the rebuild dropped

`page_template_library` has eleven columns. C improves `layout formula` and
`composition zones` — but replaces two per-template columns with one repeated
sentence each, losing sixteen pieces of direction:

| template | `recommended use` (A only) | `notes` (A only) |
|---|---|---|
| TPL-01 Solo Portrait Calm | Healing, rest, journaling, breathwork, tea, window scenes | Best for emotionally intimate pages and cover-adjacent interiors |
| TPL-02 Support Circle | Meetings, support groups, peer conversations, family encouragement | No crowd scenes; emotional clarity matters more than realism |
| TPL-03 Quote Page Border | Affirmations, bilingual phrases, short recovery lines | Keep phrase short enough to colour around comfortably |
| TPL-04 Healing Room | Bedrooms, reading nooks, living rooms, meditation corners | Good for quiet pacing between social pages |
| TPL-05 Symbol Cluster | Flowers, candles, hearts, books, mugs, butterflies, stars, leaves | **Use as pacing reset pages and bonus printable pages** |
| TPL-06 Walking Reflection | Morning walks, recovery reflection, outdoor grounding | Great recurring template across all three lines |
| TPL-07 Porch Conversation | Friend support, elder guidance, family reconnection | Useful for warm relational scenes without crowding |
| TPL-08 Window + Journal | Quiet reflection, prayer, gratitude, self-kindness | A foundational template for all seasonal books |

C's replacements are not worthless — *"Choose props that explain the emotional
purpose of the page; never add objects only to fill space"* and *"A template is a
composition scaffold, not the finished prompt"* are both real rules. They are
**global rules wearing a column's clothes**, and belong in the block layer once,
not repeated eight times at the cost of what was there.

**TPL-05's note answers an open question.** Symbol pages are specified as *pacing
reset pages and bonus printables* — they are meant to be lighter than the pages
around them. That is not the same as being childish, which is what the tool's
version produced. The fix is "fewer marks, more design" — 8–15 motifs in three
scales, per TPL-05 — not "make them as dense as a decorative page".

---

## 4. How the five inputs are meant to compose

`README_REBUILD` states the program as *line identity + season + product theme +
page-specific prompt + template structure + global print rules*. The sheets now
show how those plug together, and the architecture is cleaner than the tool's:

- **The 60 page directions are deliberately line-agnostic.** There are 60 distinct
  directions across the 180 rows — 15 slots × 4 seasons — reused for all three
  lines, and **not one of them names an ethnicity**. Verified across every slot.
- **Line identity comes from `art_direction_specs`**, which in version C carries
  distinct character rules, scene rules, line style, detail level, quote style,
  seasonal cues and a forbidden list for each of the three lines.
- **The tracker's prompt notes** stay as the line-specific layer — which is
  exactly what the Hispanic revision did to sixty of them.

So a page's brief is not one field. It is: the shared page direction (what
happens), plus the line's art direction (who is in it and how they are drawn),
plus the tracker note where it adds something. The tool currently has one flat
`brief` and one generated sentence of line identity.

---

## 5. What to import, and from where

| into | from |
|---|---|
| 180 page directions (60 distinct) | **C** `template_page_assignment_matrix.notes` |
| Hispanic line briefs, 60 rows | **B** `recovery_coloring_book_tracker` — already in the database via 031 |
| other 120 tracker notes | A/C (identical) — thin, and superseded by the page directions |
| per-line art direction block | **C** `art_direction_specs`, all nine columns |
| 8 templates: formula, zones, white space | **C** `page_template_library` |
| per-template use and pacing notes | **A** `page_template_library` — the sixteen values C dropped |
| prompt formula per template | **C** `template_prompt_framework` |
| print specs and export checks | **any** `page_design_system` — identical everywhere |
| two global composition rules | **C**, promoted out of the column into the block layer |

Everything above is a read or a migration. No generation.

**Still Esoh's to decide** — unchanged from `workbook-reconciliation.md` §9: the
book structure, whether Decorative page survives, adopting all eight templates,
and how the negative-prompt lists are split.

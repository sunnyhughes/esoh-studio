# STOP HERE — 2026-09-28, end of day

Six commits today, `1aa2efc` to `3c4a981`. Working tree clean, migrations 091
to 095 applied, nothing half-finished.

## Pick up here: tone blocks

**The Tone column is filled on all 137 rows and the tool reads none of it.**
15 distinct values, zero effect on any prompt. This is the same shape as the
lettering defect fixed today — a column Sunshine already filled that nothing
consumes — and it is the agreed next step.

The mechanism to copy is migration 093: add `prompt_blocks.tone`, extend the
kind constraint with `'tone'`, write 15 blocks, wire them to `vvs-front-print`,
and thread a `tone` selector through `getBlocks` / `buildPrompt` / `generate.ts`
**in the same commit**. `items` has no `tone` column either, so that comes too.

Why it matters, from the evidence below: `Humorous` should mean *the design
shows the joke happening — a character, a hand, a moment caught mid-action —
rather than naming it*. That makes every humorous row livelier without
rewriting a single brief.

## Two defects found today, both open

**1. D74's 80% fill ceiling now fails good designs.** Four dense generations
measured 78%, 80%, 85%, 88%; the last two were flagged. D74 reasons that a
design filling its bounding box "is the shape of a solid panel rather than a
cut-out" — the same badge-versus-background conflation D141 removed from
`vvs-output`, surviving one layer down in `lib/transparency.ts`. There are now
four real dense designs to judge a new threshold against. Deliberately not
changed yet: moving a measurement and the thing it measures in one step leaves
nothing to check against.

**2. Secondary text garbles on label-heavy designs.** One variant produced
"CHOAT-CHOPFY" and "PUSHY-SHOVEY PFY" where four quadrant labels were needed.
D70 predicted exactly this — "the phrase is safe; secondary text inside the
scene is not". The sibling variant got all four right, so it is a per-generation
risk, not a certainty. Generating n=2 and choosing is the current mitigation.

## The finding that reframes the work

**Sunshine's hand-written briefs are more cautious than the model's own
instincts, and that is most of the quality gap — not the tool.**

Proved by isolation on VVS-0082: same blocks, same art style, same lettering,
same palette, only `visual_elements` changed. His text asks for "labeled buttons
and abstract impact shapes" and produced a pie chart. A brief describing the
action produced a cartoon with a fist, a slapping hand and two figures shoving.

Printify's livelier version almost certainly came from the quote alone, with no
brief constraining it. D78 argued these columns should be drafted by the tool
and corrected by hand; the hand-writing went the other way.

**This is Sunshine's art direction, not a defect to fix.** Whether "abstract
impact shapes" stays is his call and his comfort with depicting the joke. Do not
quietly rewrite his Visual Elements.

## Still open from earlier, lower priority

- **The clean script** has never been run on the real sheet. Verified today that
  its patterns *do* fire: 60 tail strips, 9 negative rewrites, 63 cells. It
  rewrites hand-entered text, so it is Sunshine's call. Two of its fixes were
  applied by hand to VVS-0082 for today's tests and are **not** in the sheet.
- **VVS-0050** Collection reads `Power Series`; he decided it becomes
  `Boundaries Series`, and `Power Series` comes off the Lists tab. Both are
  sheet edits only he can make — the Drive connector cannot see the file.
- **The import itself** — §3 below. Its one blocking decision is how the sheet's
  seven collection names map onto the database's nine.
- **D78's numbers are stale** (it says 19 of 137 rows carry all four direction
  columns; it is now ~77, with Visual Elements at 137). No hand-entered marker
  exists, so a drafting feature would overwrite his week of work.

## What was built today

| migration | what |
|---|---|
| 091 | the 13 missing art-style blocks |
| 092 | wiring them — 091 wrote blocks nothing could select |
| 093 | `prompt_blocks.lettering_style` + 25 lettering blocks + engine selector |
| 094 | 6 contemporary art styles |
| 095 | D141/D142 — badge-is-not-a-background, keyline, density |

31 art styles, 25 lettering styles, all wired. Stage C's gate — one design
reaching a print-ready transparent PNG — was met and passed.

Reference images in `docs/references/printify-examples/`. Note the fifth,
`Feelings Control Pie Chart Panel_tshirt.png`, is no longer on disk; its
measurements are recorded in D142 (100% fill, ~179 distinct tones, no alpha
channel).

---

# VV-Styles import — reviewed 2026-09-28, resume here

Still nothing written to the database. The tool is unchanged.

**The one source of truth is the Google Sheet
`VV-Styles Designs Library Original (My version)`, tab `vv-styles-master`.**
Everything else was a copy. On 2026-09-28 thirteen stale copies and forks were
deleted from this repo — see D33. Two files remain here:

- `db-snapshot-before-import.csv` — the 130 VV-Styles rows as the database held
  them before anything changed. **Diff against this, not against a fresh pull.**
- this document.

The sheet's only local copy is `docs/references/vv-styles-master.csv`, which is
the importer's input (`scripts/import-sheets.mjs:25`). It was refreshed from the
sheet on 2026-09-28 and now carries 137 rows. Refresh it by pulling; never edit
it by hand, and do not make a second copy.

**Source:** `https://docs.google.com/spreadsheets/d/1K-A31oJfcNEGtpHA-vcswj4nfw0RE20J_nqEiXTVwpE/edit`
The Drive MCP cannot see this file; `curl` on the export URL works:

```bash
ID=1K-A31oJfcNEGtpHA-vcswj4nfw0RE20J_nqEiXTVwpE
curl -sL -o sheet.xlsx "https://docs.google.com/spreadsheets/d/$ID/export?format=xlsx"
python3 scripts/xlsx2csv.py sheet.xlsx <outdir>
cp <outdir>/vv-styles-master.csv docs/references/vv-styles-master.csv
cp <outdir>/Lists.csv            docs/references/vv-styles-lists.csv
```

> **A rebuilt export once cost a session.** `VV-Styles_Completed_REBUILT_2026-09-23.xlsx`
> looked more complete — 136/137 on every art-direction column — but its art
> direction sat one row below its quotes on **62 rows**, running from VVS-0038
> down. It and its CSVs are deleted. Verified 2026-09-28 that none of its
> displaced text ever reached the real sheet. If a "completed" or "rebuilt"
> version of this library turns up again, check row alignment against the quotes
> before believing it.

---

## 1. What Sunshine finished between 09-22 and 09-28

- **Visual Elements is complete: 137/137**, up from 57. Median 265 characters,
  nothing stubbed, no row describing another row's quote.
- **Six of the seven off-list cells in §1 of the old doc are corrected.**
  VVS-0049, VVS-0133, VVS-0014, VVS-0134, VVS-0003 and VVS-0048 now conform.
- **Art direction grew to ~77 rows** on Art Style (78), Lettering Style (77),
  Color Direction (77) and Product / Placement (77) — up from 57.
- **Collection 66, Priority 67, Notes 48.**

Tone, Status, Priority, Review Flag and Category are fully on-list.

## 2. The one cell still off its own list

| Row | Column | Has | Lists tab allows |
|---|---|---|---|
| VVS-0050 | Collection | `Power Series` | the seven below |

Recovery Culture · Healing Out Loud · Boundaries Series · Confidence Series ·
Survivor Series · Legacy & Awareness · Sass & Survival

Was `Power Moves` on 09-21, so it has been edited but not onto the list.
**His call:** add `Power Series` to the Lists tab as an eighth collection, or
move VVS-0050 into one of the seven.

## 3. Two import hazards, both live

**Collection blanks would scatter 65 designs.** `scripts/import-sheets.mjs:166`
reads `r["Collection"] || "Unsorted"`. The live sheet leaves Collection blank on
71 rows; the database has 65 of those filed in real collections — 23 in Recovery
Culture, 9 in Everyday Sass, 7 each in Self-Respect and Motivation, and the
rest. An import as written files all 65 under **Unsorted**. This is the D133
shape. Either fill Collection on those rows or teach the importer to leave a
blank cell alone.

Note the database's collection names and the Lists tab's do not match — the
database has Self-Respect, Everyday Sass, Truth & Accountability, Motivation,
Survivor Strength, Love, Family & Faith; the Lists tab has none of them. That
mapping has to be settled before Collection is imported at all.

**21 rows carry production text in the Asset Link column.** VVS-0038, 0052,
0053, 0068, 0089, 0090, 0093, 0096–0099, 0101–0105, 0107, 0109, 0110, 0112,
0130. Each begins "Production: transparent background, …". Product / Placement
is filled correctly on all 21, so nothing is displaced — this is real output
guidance parked in the wrong column. The importer ignores Asset Link, so it
would be silently dropped. Decide whether it becomes a print-requirement block,
merges into Product / Placement, or is discarded.

## 4. Decisions already given — do not re-ask

- **Launched status does not matter.** Status may be imported as the sheet has
  it; the store is not public. Needs case mapping — sheet is Title Case
  (`Prompt Ready`), the CHECK constraint is snake_case (`prompt_ready`).
- **VVS-0034 "Strength is NOT a defect"** — the sheet is right, the database has
  the meaning-reversing typo.
- **VVS-0009 "(clean date)"** — a placeholder, correct as written. On VVS-0009,
  0036 and 0038 the clean date is inserted at generation, not prefilled. This is
  D103's last open variety dimension, `{{clean_date}}`.
- **VVS-0047 "FUQU"** — intentional spelling.
- Coloring-book styles in the apparel list were transferred by accident. They
  are a problem, and §5 says why.

## 5. The style blocks are written — migration 091, applied 2026-09-28

**Resolved.** `091_the_missing_styles_get_their_paragraphs.sql` added the
thirteen missing `base_style` blocks. `prompt_blocks` now holds **25 active
vv-styles base styles**, matching the Lists tab.

- **All 78 rows that name an art style are buildable** (was 41).
- **59 rows still name no art style at all.** They have Visual Elements but no
  style, so nothing selects a block for them. A style has to be chosen per row
  and that is Sunshine's call, not something a block can fix.

Six of the thirteen names also exist under `coloring-books` and **none were
reused**. Verified after applying: no vv-styles block contains "coloured by
hand", "open white" or "line illustration". Soft Botanical Line Art is the case
to watch — the coloring-book block leaves interiors "open white, ready to be
coloured", the apparel block leaves them "open to the garment", which is the
transparent knockout.

Wording was drafted from the Visual Elements and Color Direction on the rows
using each style, and is Sunshine's to correct. Two he flagged as worth a second
look: **Urban graffiti** must stay distinct from Streetwear Graffiti (aerosol
technique vs layered screen-print) and **Feminine** was read from just two rows,
both soft-heart-and-botanicals.

## 6. Where to pick up

1. Settle VVS-0050 (§2) — one cell.
2. ~~Write the 13 style blocks.~~ Done, migration 091.
3. Import the safe, additive data — art direction, Priority, Notes, the quote
   corrections, Status with case mapping. **Hold Collection** until §3 is
   settled.
4. `items.tone` is still not a column. The sheet fills Tone on all 137 rows,
   15 distinct values, all on-list.

`scripts/clean-vv-styles.py` was written on 09-24 to strip a repeated tail
sentence and rewrite fourteen negative phrasings positively (§2.5). It only ever
ran against the deleted rebuilt file, so **its output has never been seen against
the real sheet** and its match patterns may not fire at all. Point it at
`docs/references/vv-styles-master.csv`, write to a scratch copy, and read the
diff before letting it near the real file.

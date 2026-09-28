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

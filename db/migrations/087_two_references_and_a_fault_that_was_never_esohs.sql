-- 087_two_references_and_a_fault_that_was_never_esohs.sql
--
-- Esoh sourced two more on 2026-09-15 and asked me to look at what he had
-- accepted in the tool. The second half of that turns out to matter more than
-- the first.
--
-- ## The approvals
--
-- Of everything generated today: Solo portrait 5 approved 1 rejected, Community
-- scene 3 approved 0 rejected, Decorative 0 approved 1 rejected (the floating
-- swing), and **Symbol page 5 approved, 0 rejected.**
--
-- Every Symbol page he looked at, he accepted. All five are the even all-over
-- field that 077 tried to group from the brief, 078 from the blocks, and 084
-- from the style — three migrations and roughly $6 of generation spent on a
-- composition Esoh has never once complained about. D137's review named 08 and
-- 13 as "doodles" because they were *thin*, and the thinness is fixed: named
-- species, interior detail, a large anchor, three scales. The grouping was my
-- inference about what "doodle" meant, and it was wrong.
--
-- This is the second time. The memory reads: acceptance is Esoh's call, and I
-- once asserted a 90% failure rate on pages he judged fine. **The grouping
-- instruction stays in the briefs and blocks — it costs nothing and does no
-- harm — but nothing further should be spent chasing it.** If a future session
-- finds the even field and reaches for a fourth layer, this is the row that says
-- don't.
--
-- ## Environment page — pergola patio
--
-- The first outdoor reference this page type has ever had. Both existing ones,
-- `reading-nook` and `winter-living-room`, are interiors, and TPL-09 Outdoor
-- Sanctuary has been drawing from them for want of anything else. 11.2% black,
-- 13px open run — the most colourable reference in the set. Pergola with drawn
-- wood grain, bunting, cushioned seating, a monstera, a patterned rug, paving in
-- perspective across three depth planes. No people, no lettering, nothing
-- filled.
--
-- It does **not** answer the cloud complaint: its sky is plain white behind a
-- fence. That is its own small teaching — open sky left as paper — but 085's
-- fault is still open, and the shrubs in it are drawn with exactly the scalloped
-- bumpy outline that makes the clouds look cartoonish.
--
-- ## Symbol page — heritage motifs
--
-- What it teaches that `symbol-spring-wreath` cannot: **pattern inside objects**,
-- which is the gap D137 counted and 075 only half closed. Adinkra symbols banded
-- around the mug, geometric fill in the hearts, markings on the bird's wing, a
-- woven border around the whole page. And a heritage vocabulary in drawable
-- form — cowrie shells, Adinkra, cotton bolls — for the line that carries the
-- most pages.
--
-- **Corrected before registering, per §6 and 073's precedent.** The open book
-- carried a portrait of a person on one page and wavy lines standing in for
-- writing on the other. Both pages are blanked to white with the book's outline
-- left intact. Two reasons, either sufficient: `hs-no-figures` gives Symbol
-- pages "No people and no parts of people", and `hs-output` requires that "a
-- book cover, a journal, a mug, a sign, a label" be drawn blank — the rule 073
-- blanked five references to protect and 071 spent a whole migration on. The
-- portrait also read as a likeness of a specific real person, which is not
-- something this tool should be teaching itself to draw onto a colouring page.
-- Original kept in `source-received/`.
--
-- **The butterfly was measured rather than judged by eye, and the eye was
-- wrong.** It looks like a heavy black mass. It measures 29.9% black but **7px
-- open run** — identical to `walking-with-mug`, the approved exemplar. It is a
-- black field with genuine colourable cells knocked out of it, not a solid.
-- D110's openrun exists for exactly this distinction and it earned its keep in
-- the opposite direction this time. Whole page 19.8% black at 8px open run: over
-- the ink line, under no rule that matters, and colourable throughout.

begin;

insert into reference_images
  (item_id, asset_id, label, storage_path, kind, page_type, art_style,
   usable_as_input, notes)
values
  (null, null, 'Environment page — pergola patio',
   'exemplars/environment-pergola-patio.jpeg', 'exemplar', 'Environment page',
   null, true,
   'Sourced by Esoh 2026-09-15. The first outdoor reference this page type has '
   'had — reading-nook and winter-living-room are both interiors. Pergola with '
   'drawn wood grain, bunting, cushioned seating, a monstera, a patterned rug '
   'and paving in perspective across three depth planes. 11.2% black at 13px '
   'open run, the most colourable reference in the set. Its sky is plain white, '
   'so it teaches open sky as paper and does not answer 085''s cloud fault.'),
  (null, null, 'Symbol page — heritage motifs',
   'exemplars/symbol-heritage-motifs.png', 'exemplar', 'Symbol page', null, true,
   'Sourced by Esoh 2026-09-15. Teaches pattern inside objects — Adinkra banded '
   'on the mug, geometric fill in the hearts, markings on the bird — which is '
   'the D137 gap 075 only half closed, plus cowrie shells and cotton bolls as '
   'drawable heritage vocabulary. The open book carried a portrait and wavy '
   'writing and both pages were blanked before registering, per hs-no-figures '
   'and hs-output; original in source-received/. The butterfly reads as solid '
   'and is not: 29.9% black at 7px open run, the same open run as '
   'walking-with-mug. Whole page 19.8% at 8px.');

do $$
declare n int;
begin
  select count(*) into n from reference_images
   where usable_as_input and page_type = 'Environment page';
  if n <> 3 then raise exception 'expected 3 environment refs, got %', n; end if;

  select count(*) into n from reference_images
   where usable_as_input and page_type = 'Symbol page';
  if n <> 2 then raise exception 'expected 2 symbol refs, got %', n; end if;

  -- Every page type still has one of its own, and none lost any. This is the
  -- count 076 established for the first time in the project's history.
  select count(*) into n from (
    select page_type from reference_images
     where usable_as_input and page_type is not null
     group by page_type having count(*) >= 1
  ) t;
  if n <> 6 then raise exception 'only % page types have a reference', n; end if;

  -- The corrected symbol file is the one registered, not the original. If the
  -- uncorrected image is ever put back under this path, this will not catch it,
  -- so the note carries the detail as well.
  if not exists (
    select 1 from reference_images
     where storage_path = 'exemplars/symbol-heritage-motifs.png'
       and usable_as_input
       and notes like '%blanked before registering%'
  ) then raise exception 'the symbol reference lost its correction record'; end if;
end $$;

commit;

-- 074_symbol_pages_borrow_the_quote_references.sql
--
-- Esoh, 2026-09-14: "Re-run 08 and 13 now with the new quote exemplars."
--
-- Symbol page has no reference of its own and is the page type he has twice
-- called doodles. D122 narrowed cross-type fallback to pages with figures on
-- them, reasoning that "a Quote page and an Environment page share only the
-- absence of people" and that the best quote page yet was made with no
-- reference at all. **That reasoning was sound and is not what this changes.**
-- A living room still teaches a quote page nothing.
--
-- What D122 did not have is 073's three quote references: worked botanical
-- borders at three scales around an open centre, which is exactly the density a
-- symbol cluster is missing. A Symbol page and a Quote page are near relatives —
-- motifs, no people, no scene — and the fallback is written to lapse the moment
-- Symbol has a reference of its own.
--
-- **The symbol file Esoh supplied is registered as a study, not an exemplar.**
-- It is a four-quadrant reference chart — SPRING / SUMMER / FALL / WINTER, each
-- labelled with a line and a keyword list, a portrait in the middle, text
-- throughout. As an exemplar it would teach panels and lettering, which is §6's
-- law and 071's whole problem. As a record it is valuable and belongs nowhere
-- else: it is the only place the **symbol vocabulary per season and line** is
-- written down — ankh, triskelion, mandala, snowflake, lotus, sun, butterfly,
-- mountains, tree — and none of the sixteen workbook sheets carries it.
--
-- Measured result of the re-run, stated plainly: **13 improved, 08 less so.**
-- 13 came back with a central anchor and botanical growth radiating out at
-- three scales, which is the exemplar landing. 08 is still scattered objects at
-- one scale, with more of them and more interior line. Both briefs name an
-- anchor; only one page built around it.

begin;

insert into reference_images
  (item_id, asset_id, label, storage_path, kind, page_type, art_style,
   usable_as_input, notes)
values
  (null, null, 'Symbol vocabulary chart (study)',
   'exemplars/source-received/symbol-vocabulary-chart.png', 'study', 'Symbol page',
   null, false,
   'Supplied by Esoh 2026-09-14, with the warning that it is "nowhere near what '
   'we were making already" — correct, because it is a chart and not a page. '
   'Four labelled quadrants, keyword lists and a portrait. Never usable as '
   'input: it would teach panels and drawn text. Kept because it is the only '
   'record of the symbol vocabulary per season and line — ankh, triskelion, '
   'mandala, snowflake, lotus, sun, butterfly, mountains, tree — which appears '
   'in none of the sixteen workbook sheets.');

do $$
declare n int;
begin
  select count(*) into n from reference_images
   where usable_as_input and page_type = 'Symbol page';
  if n <> 0 then
    raise exception 'Symbol has % usable reference(s) — the quote fallback in '
      'lib/generate.ts lapses on its own, but say so deliberately', n;
  end if;

  select count(*) into n from reference_images
   where page_type = 'Symbol page' and kind = 'study';
  if n <> 1 then raise exception 'the vocabulary chart is not recorded'; end if;
end $$;

commit;

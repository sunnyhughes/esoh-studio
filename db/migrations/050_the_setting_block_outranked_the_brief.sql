-- 050_the_setting_block_outranked_the_brief.sql
--
-- D103 recorded four variety axes built with no data. Two have since been
-- filled — 038 gave every coloring row an art style, 039 a density. The third,
-- `items.visual_elements` feeding {{environment}}, is still set on exactly one
-- row of 180, and that one row is not merely unused. It is wrong, and it has
-- been overriding its own brief in front of us.
--
-- `African American Fall 01` carries the value "a lived-in living room — a
-- sectional sofa with cushions, a low table, floating shelves of books and
-- small objects, a trailing pothos, a floor lamp, a framed photo wall, a mug on
-- the table". Its brief puts her on a front porch. `hs-environment` sits at
-- position 40, after the subject, and says "The setting is {{environment}}."
-- Both 2026-09-11 renders went out with "porch step" and "a lived-in living
-- room" in the same prompt — confirmed against the stored prompt_text — and the
-- living room won outright. Every object in the page Esoh reviewed is an item
-- from that string. There is no porch in it.
--
-- D121 read those renders as a threshold problem: "'a porch step' is a
-- threshold and the model drew both sides of it, porch underfoot and living
-- room behind". The boots half of that was right and 045 fixed it. The setting
-- half was not. Nothing was ambiguous — the prompt asked for a living room in
-- plain words. 045's porch has never been rendered, and could not be while this
-- value stood.
--
-- The axis is retired rather than filled. The brief is the setting: all 180
-- briefs carry one, 179 pages have generated with this block dropped, and among
-- them are both exemplars approved in D121 and the quote page D119 called the
-- best of its run. A block that states the setting after the brief states it
-- can only agree or override, and agreeing adds nothing. This is the same law
-- D118, D120 and D121 each arrived at from a different direction: the subject
-- line wins, so the subject line is where the subject belongs.
--
-- `cb-environment` was already inactive for the same reason. This joins it.

begin;

update items
   set visual_elements = null,
       updated_at = now()
 where ref = 'African American Fall 01'
   and category_id = (select id from categories where code = 'coloring-books');

update prompt_blocks
   set is_active = false,
       updated_at = now()
 where slug = 'hs-environment';

do $$
declare n int;
begin
  select count(*) into n
    from items i
    join categories c on i.category_id = c.id
   where c.code = 'coloring-books'
     and nullif(trim(coalesce(i.visual_elements, '')), '') is not null;
  if n <> 0 then
    raise exception 'a coloring row still carries visual_elements (% rows)', n; end if;

  select count(*) into n
    from prompt_blocks b
    join categories c on b.category_id = c.id
   where c.code = 'coloring-books' and b.is_active
     and b.body_text like '%{{environment}}%';
  if n <> 0 then
    raise exception 'an active coloring block still reads {{environment}} (% rows)', n; end if;
end $$;

commit;

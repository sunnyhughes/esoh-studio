-- 057_two_spring_pages_stop_being_one_page.sql
--
-- 056 landed the re-authored Spring and made a duplicate visible. Slots 01 and
-- 10 were the same page: same template (TPL-01), same rainy window, same tea
-- mug, same journal, same plant, same blanket, same seated posture. The
-- hairstyles differ, which differentiates the figure and not the page.
--
-- Esoh's own README says what to do about it: "If two generated pages look
-- interchangeable, the problem is no longer solved by adding adjectives;
-- revise the page-specific action, composition, props, relationship, or
-- emotional story."
--
-- **Slot 10 keeps the rain.** Its title is *Rainy Window Reflection* and the
-- rain is promised there. Slot 01 is *Spring Renewal Journal*, which promises
-- a journal and no weather at all — so it is the one that moves.
--
-- Rain itself stays in the book. `page_design_system` defines Spring as
-- "Flowers, rain, fresh air, journals, new beginnings" and `art_direction_specs`
-- as "Spring growth and rain"; five of fifteen pages carry it, on the same
-- slots in all three lines. That is a designed rhythm, not repetition.
--
-- The replacement takes its seasonal cue from the other half of that
-- definition — new beginnings, growth — and drops the window entirely, since
-- seven of fifteen pages already have one. Written against what the project has
-- learned: the journal is "a journal" and not a titled object (D120), nothing
-- is described by a colour (D105), the season is carried by objects rather than
-- by light, which outline cannot draw (D118), and each object has a reason to
-- be where it is (D121).

begin;

update items set
  brief = 'African American woman with natural curls writing in a journal at a '
          'kitchen table, sleeves pushed back and a chair turned out beside her; '
          'a shallow tray of seedlings and a jar of cut blossoms set within reach '
          'where she can see them, calm reflective expression, clear focal '
          'figure, simple uncluttered room, coloring book line art.',
  updated_at = now()
 where ref = 'African American Spring 01' and ethnicity_line = 'African American';

do $$
declare a text; b text;
begin
  select brief into a from items where ref = 'African American Spring 01';
  select brief into b from items where ref = 'African American Spring 10';

  if a ~* 'rain' then
    raise exception 'slot 01 still carries rain'; end if;
  if a ~* 'window' then
    raise exception 'slot 01 still carries a window'; end if;
  if b !~* 'rain' then
    raise exception 'slot 10 lost the rain it is named for'; end if;

  -- The pair must no longer share their prop set.
  if a ~* 'mug|tea' and b ~* 'mug|tea' then
    raise exception 'both pages still hold a mug'; end if;

  -- Rain stays a Spring cue across the book, on its designed slots.
  if (select count(*) from items
       where ref like 'African American Spring%' and brief ~* 'rain') <> 4 then
    raise exception 'the seasonal rain rhythm changed unexpectedly'; end if;
end $$;

commit;

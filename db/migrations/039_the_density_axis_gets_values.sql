-- 039_the_density_axis_gets_values.sql
--
-- D103's second starved axis. `background_density` was set on 1 of 310 items.
-- The route reads `body.density ?? item.background_density ?? null`, and a null
-- drops the density block, so unless the form happened to pass a value the
-- prompt went out with nothing said about how full the page should be.
--
-- ASSIGNED BY PAGE TYPE, BECAUSE THAT IS WHAT DECIDES IT. A Quote page and a
-- Decorative page want opposite things and neither is a matter of taste:
--
--   Solo portrait     Dense   — every approved page was generated Dense, and
--                               both exemplars are richly furnished rooms.
--   Community scene   Medium  — several figures already fill the page; Dense
--                               on top of them is clutter, not richness.
--   Quote page        Open    — see below. This one is a contradiction, not a
--                               preference.
--   Symbol page       Open    — "a cluster of related symbolic objects" needs
--                               the space between them to read as separate.
--   Decorative page   Dense   — an ornamental arrangement is the page; there is
--                               no subject for density to compete with.
--   Environment page  Dense   — "the place itself is the subject", and a room
--                               that is the subject has to be furnished.
--
-- THE QUOTE PAGE CONFLICT IS REAL AND WAS UNGUARDED. `hs-comp-quote-page`
-- requires "an upright oval about two-thirds the page width and half the page
-- height, left completely blank with nothing drawn inside it and nothing
-- crossing into it". `hs-density-dense` requires that "the page is rich with
-- real objects". Both are attached to the Quote page template, so the form
-- would happily send both, and the prompt would then ask for a page that is
-- full and two-thirds empty at once. §2.5's law is about naming what you do not
-- want; this is its quieter cousin — two blocks that each make sense and cannot
-- both be obeyed. The value here settles it, and the check below stops the
-- combination being written again.

begin;

update items
   set background_density = case page_type
         when 'Solo portrait'    then 'Dense'
         when 'Community scene'  then 'Medium'
         when 'Quote page'       then 'Open'
         when 'Symbol page'      then 'Open'
         when 'Decorative page'  then 'Dense'
         when 'Environment page' then 'Dense'
       end,
       updated_at = now()
 where ethnicity_line is not null
   and page_type is not null;

-- Every coloring row carries a density, so the block stops dropping silently.
do $$
declare n int;
begin
  select count(*) into n from items
   where ethnicity_line is not null and background_density is null;
  if n <> 0 then raise exception '% coloring rows still have no density', n; end if;
end $$;

-- Every value names a density block that exists.
do $$
declare bad text;
begin
  select string_agg(distinct background_density, ', ') into bad from items
   where ethnicity_line is not null
     and background_density not in
         (select background_density from prompt_blocks where background_density is not null);
  if bad is not null then raise exception 'no density block answers to: %', bad; end if;
end $$;

-- The contradiction this migration exists to close: a page required to keep two
-- thirds of itself blank may not also be asked to be rich with objects.
do $$
declare bad text;
begin
  select string_agg(ref, ', ') into bad from items
   where ethnicity_line is not null
     and page_type in ('Quote page', 'Symbol page')
     and background_density = 'Dense';
  if bad is not null then raise exception 'dense page with a required open centre: %', bad; end if;
end $$;

commit;

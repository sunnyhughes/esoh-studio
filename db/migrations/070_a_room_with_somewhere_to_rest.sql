-- 070_a_room_with_somewhere_to_rest.sql
--
-- Esoh on the Dense render of African American Spring 01: "I love the last
-- image. It has just the right amount of busyness to it without being
-- overloaded. Its grey is at a colorable level."
--
-- 061 set every page's density from Esoh's own `detail load` column, which puts
-- TPL-01, TPL-07 and TPL-08 at Medium. Medium says fourteen words — "furnished
-- enough to feel real, with clear open areas between the objects" — and names
-- nothing, so 069's list of what a used kitchen holds was outvoted by TPL-01's
-- "light background context", its 35-45% open rule, and Medium's own call for
-- open areas. Five instructions asked for space and two for objects. At Dense
-- the coffee pot, the plant, the bowl, the backsplash and the cabinetry all
-- arrived, and the page still measures 3.42% grey against a 12% line and
-- approved work averaging 1.88%.
--
-- **A page with a room in it goes Dense; a page without does not.** TPL-06
-- stays Medium because its own white-space rule says to keep large sky and path
-- zones open, and it is the one figure template set outdoors. TPL-03, TPL-05 and
-- TPL-10 carry no density block at all.
--
-- **The flag against this, applied rather than noted.** `page_design_system`
-- says "moderate detail for adults; calming, not dense", and §3.5 is the largest
-- correction in `direction.md`: pages built on edge-to-edge density read as
-- seek-and-find puzzles with nowhere for the eye to rest, and the book exists to
-- give someone a calm hour with a pencil. Moving 61 pages to Dense on the
-- strength of one render is exactly how that happened the first time.
--
-- So Dense gains the guard §3.5 asks for, stated positively as §2.5 requires:
-- every object large enough to take a pencil, and a clear stretch of wall, floor
-- or table left between the groups. That is what made the page Esoh kept work —
-- the objects are separate and large — and it is now said rather than hoped for.

begin;

update prompt_blocks set body_text =
  'The setting is fully furnished and the page is rich with real objects — '
  'furniture, plants, things people actually keep in a room — each drawn as its '
  'own outlined shape with white space around it. The subject stays the clear '
  'focus, but the room around them is full. Every object is large enough to '
  'colour comfortably, and the eye is given somewhere to rest: a clear stretch '
  'of wall, floor or table is left between the groups of things, so the page '
  'reads as a room rather than as a puzzle to search.',
  updated_at = now()
 where slug = 'hs-density-dense';

update items i set background_density = 'Dense', updated_at = now()
  from prompt_templates t
 where t.id = i.prompt_template_id
   and t.slug in ('tpl-01-solo-portrait-calm',
                  'tpl-07-pair-conversation',
                  'tpl-08-window-journal')
   and i.background_density is distinct from 'Dense';

do $$
declare t text; n int;
begin
  select body_text into t from prompt_blocks where slug = 'hs-density-dense';
  if t !~ 'somewhere to rest' then raise exception 'the §3.5 guard is missing'; end if;
  if t !~ 'large enough to colour comfortably' then
    raise exception 'the colourability guard is missing'; end if;

  -- The outdoor figure template keeps its open sky.
  select count(*) into n from items i join prompt_templates t2 on t2.id = i.prompt_template_id
   where t2.slug = 'tpl-06-walking-reflection' and i.background_density <> 'Medium';
  if n <> 0 then raise exception '% walking pages left Medium', n; end if;

  -- Every page with a room in it is Dense.
  select count(*) into n from items i join prompt_templates t2 on t2.id = i.prompt_template_id
   where t2.slug in ('tpl-01-solo-portrait-calm','tpl-02-support-circle',
                     'tpl-04-healing-room','tpl-07-pair-conversation',
                     'tpl-08-window-journal','tpl-09-outdoor-sanctuary')
     and i.background_density <> 'Dense';
  if n <> 0 then raise exception '% room pages are not Dense', n; end if;

  -- A quote page must still be Open; its centre is reserved for lettering.
  select count(*) into n from items i join prompt_templates t2 on t2.id = i.prompt_template_id
   where t2.page_type = 'Quote page' and i.background_density <> 'Open';
  if n <> 0 then raise exception '% quote pages left Open', n; end if;
end $$;

commit;

-- 047_surfaces_get_their_own_decoration.sql
--
-- Esoh on the four environment candidates: env-1 and env-2 are "a good basis to
-- build from... because with a little coaxing I could add designs to the
-- furniture and floor that would add personalization", and env-4 is good
-- "despite it lacking in depth details such as the entire image looking flat".
--
-- Both notes point at blocks that are doing their job too broadly.
--
-- 1. DECORATION IS NOT SHADING, AND ONE BLOCK WAS BANNING BOTH.
--
--    `hs-texture-as-pattern` read "Form is described by outline alone. Every
--    element is a closed shape with clear white inside it, large enough to
--    colour comfortably." It was written against tone being used to describe
--    form, which is right and stays. But "outline alone" also rules out the rug
--    with a border, the quilt pieced into blocks, the grain along a floorboard —
--    decoration that a real object has and that a colourist wants, because each
--    motif is **another closed shape to colour**. The block was removing
--    colourable area in the name of colourability.
--
--    The distinction is now explicit: decoration is drawn as further closed
--    shapes, form is still described by outline. Note this also serves D96 —
--    two rooms with different rugs are two different pages.
--
-- 2. A ROOM NEEDS WALLS AND THINGS IN FRONT OF OTHER THINGS.
--
--    "Flat", and on the Hispanic candidate "the area that should be wall is
--    slightly off because it looks like the area is void of walls".
--    `hs-comp-environment-page` said only "No people. The place itself is the
--    subject." — nothing about the place having corners, or about objects
--    sitting in front of and behind one another.
--
--    Depth here has to come from what outline can carry: overlap, scale and the
--    lines of the room itself. §3.5 rules out the usual means, since there is no
--    tone on these pages and nothing casts a shadow.
--
-- The clause "No people" is kept and strengthened, because the Hispanic
-- candidate put a woman in the chair on a page whose block already forbade one.

begin;

update prompt_blocks set body_text =
  'Form is described by outline. Surfaces carry the decoration a real object '
  'would have — a rug with a border and a repeating motif, a quilt pieced into '
  'blocks, a cushion with a woven design, the grain running along floorboards, a '
  'pattern in the fabric of a chair. Decoration is drawn as further closed '
  'shapes to colour, each one large enough to take a pencil, and two rooms are '
  'furnished with different patterns from each other. Every element on the page, '
  'decoration included, is a closed shape with clear white inside it.',
  updated_at = now()
 where slug = 'hs-texture-as-pattern';

update prompt_blocks set body_text =
  'The place itself is the subject and nobody is in it — no figure, no person '
  'seated or standing anywhere in the room. The room is built as a room: its '
  'walls meet at a corner, the floor runs away from the viewer, and objects sit '
  'in front of and behind one another at their own sizes, so the space has depth '
  'rather than reading as a flat arrangement of furniture.',
  updated_at = now()
 where slug = 'hs-comp-environment-page';

-- Both landed.
do $$
declare n int;
begin
  select count(*) into n from prompt_blocks
   where slug in ('hs-texture-as-pattern','hs-comp-environment-page')
     and updated_at > now() - interval '1 minute';
  if n <> 2 then raise exception 'expected 2 blocks updated, got %', n; end if;
end $$;

-- Decoration is permitted and named, and form is still outline.
do $$
declare t text;
begin
  select body_text into t from prompt_blocks where slug = 'hs-texture-as-pattern';
  if t !~* 'decoration is drawn as further closed shapes to colour' then
    raise exception 'decoration is not framed as colourable shapes'; end if;
  if t !~* 'form is described by outline' then
    raise exception 'the rule against tone describing form was lost'; end if;
  if t !~* 'closed shape with clear white inside it' then
    raise exception 'the colourability guarantee was lost'; end if;
end $$;

-- The room has walls, depth, and still nobody in it.
do $$
declare t text;
begin
  select body_text into t from prompt_blocks where slug = 'hs-comp-environment-page';
  if t !~* 'nobody is in it' or t !~* 'no figure' then
    raise exception 'the no-people rule was weakened'; end if;
  if t !~* 'walls meet at a corner' or t !~* 'in front of and behind one another' then
    raise exception 'depth is not described'; end if;
end $$;

-- §2.5 and §3.5 hold in both: no technique negative, and no appeal to light.
do $$
declare bad text;
begin
  select string_agg(slug, ', ') into bad from prompt_blocks
   where slug in ('hs-texture-as-pattern','hs-comp-environment-page')
     and body_text ~* '(never|no|without|avoid)[ ]+(filled|fill|shaded|shading|hatch|hatching|stippl|tone|render)';
  if bad is not null then raise exception 'technique negative in: %', bad; end if;

  select string_agg(slug, ', ') into bad from prompt_blocks
   where slug in ('hs-texture-as-pattern','hs-comp-environment-page')
     and body_text ~* '\y(shadow|shading|sunlight|the light|dappled)\y';
  if bad is not null then raise exception 'appeal to light in: %', bad; end if;
end $$;

-- D22 requires an asset be approved before it can be used as input, and these
-- two are still draft. Esoh approved them in review — "a good basis to build
-- from" and "open and inviting" — so the record is brought into line with the
-- decision that was actually made. The summer pair in 046 were already approved
-- in the app and needed no equivalent.
update generated_assets set status = 'approved', updated_at = now()
 where id in ('ebba9024-70e9-49e4-82fa-154ae27e3aa2',
              '805c6612-08e2-437a-bc2a-bd4c4874af38');

do $$
declare n int;
begin
  select count(*) into n from generated_assets
   where id in ('ebba9024-70e9-49e4-82fa-154ae27e3aa2','805c6612-08e2-437a-bc2a-bd4c4874af38')
     and status = 'approved';
  if n <> 2 then raise exception 'expected 2 assets approved, got %', n; end if;
end $$;

-- The library's first references for a page type other than Solo portrait.
insert into reference_images
  (item_id, asset_id, label, storage_path, kind, page_type, art_style, usable_as_input, notes)
values
  ('fc92f060-2a22-4ef4-9888-07dd680971a6', 'ebba9024-70e9-49e4-82fa-154ae27e3aa2',
   'Reading nook', 'exemplars/reading-nook.png', 'exemplar',
   'Environment page', 'Editorial Scene', true,
   'Approved by Esoh 2026-09-11 as "a good basis to build from" — cozy, a '
   'steaming cup, a blanket. Approved as a basis rather than a finished look: '
   'the furniture and floor are meant to carry more decoration than this, which '
   'is what the hs-texture-as-pattern change in this migration permits.'),
  ('a90a67c1-ceed-4f13-b008-17e8162f173b', '805c6612-08e2-437a-bc2a-bd4c4874af38',
   'Winter living room', 'exemplars/winter-living-room.png', 'exemplar',
   'Environment page', 'Editorial Scene', true,
   'Approved by Esoh 2026-09-11 — "open and inviting", a good basic starting '
   'point. Same caveat as its pair.');

-- Six usable references now, across two page types. Four of six page types
-- still have none, which remains the open gap.
do $$
declare n int;
begin
  select count(*) into n from reference_images where usable_as_input;
  if n <> 6 then raise exception 'expected 6 usable references, got %', n; end if;

  select count(distinct page_type) into n from reference_images where usable_as_input;
  if n <> 2 then raise exception 'expected 2 page types covered, got %', n; end if;
end $$;

commit;

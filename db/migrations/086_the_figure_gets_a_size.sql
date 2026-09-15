-- 086_the_figure_gets_a_size.sql
--
-- The one thing owed from 081. Esoh, on the pages made by the templates I built
-- on a misreading and then withdrew: "the people in the last images are good
-- images of the way the people should look. The clothing styles and shaded areas
-- of the clothes." Those are the best figures the project has produced.
--
-- The only thing TPL-11's composition said about the figure that TPL-01 does not
-- is a **size**: "drawn from the waist or knees up and filling at least half the
-- height of the page". TPL-01 says "One focal person centered slightly off-axis"
-- and names no size at all; TPL-02 says "3-5 people in a curved or circular
-- arrangement" and names none either.
--
-- That is the shape that keeps working. D112's countable leaf limit held where
-- three worded instructions had failed. 078 wrote it down after the fact: a
-- named quantity lands where an adjective does not. And 081 recorded the same
-- thing from the other side — "centerpiece" is not a drawable instruction and
-- "half the height of the page" is.
--
-- It is also the right *kind* of change. Today's tally: every instruction that
-- changed **what is on the page** landed — named species, banded textile
-- geometry, a removed pattern background, the right template — and every
-- instruction that tried to change **how a familiar thing is drawn** did not:
-- the symbol grouping failed at the brief, the block and the style layers; the
-- hair block said "left white and open inside" and the page came back 47% black;
-- 085's clouds landed on one variant of two. A figure's size on the page is
-- composition, not rendering. This is in the category that works.
--
-- **Nothing else is ported.** Not the ground filled to all four edges, which is
-- what made those pages wrong; not the band of white around the figure, which
-- only exists because of that ground. One sentence each, added to what is
-- already there, with the existing zone directives left exactly as they are.
--
-- **This is the riskiest change of the day and is treated as one.** TPL-01 and
-- TPL-02 carry most of the book, and `walking-with-mug`, `summer-under-the-tree`
-- and `man-shovel-snow-v2` are approved exemplars from this family. Baselines
-- were generated immediately before this migration on two pages Esoh has already
-- judged acceptable — `African American Spring 10` on TPL-01 and `African
-- American Spring 04` on TPL-02, both named in D137's review — so the same two
-- pages can be compared across the change rather than against memory. If they
-- get worse, this migration is the thing to revert, and the baselines are jobs
-- 5d3ca255 and 1277b786.

begin;

update prompt_blocks set body_text =
  'One focal person centered slightly off-axis, drawn from the waist or knees '
  'up and filling at least half the height of the page. 2-3 supporting props, '
  'light background context, open lower corners. Top: seasonal cues; Center: '
  'face/body focal point; Mid-lower: hands/object; Edges: light framing motifs.',
  updated_at = now()
 where slug = 'hs-comp-tpl-01-solo-portrait-calm';

update prompt_blocks set body_text =
  '3-5 people in a curved or circular arrangement, drawn from the waist up and '
  'together filling at least half the height of the page, with one clear focal '
  'interaction and simple background geometry. Indoor variant uses simple room '
  'geometry; outdoor variant uses trees, park edge, or garden as a low-detail '
  'backdrop. Top: wall, window, banners, or tree line kept minimal; Center: '
  'group interaction; Bottom: chairs, floor, ground, grounding objects.',
  updated_at = now()
 where slug = 'hs-comp-tpl-02-support-circle';

do $$
declare t text;
begin
  select body_text into t from prompt_blocks
   where slug = 'hs-comp-tpl-01-solo-portrait-calm';
  if t !~* 'at least half the height of the page' then
    raise exception 'the solo figure still has no size'; end if;
  -- Everything that was already there stays there.
  if t !~* 'centered slightly off-axis' then
    raise exception 'TPL-01 lost its placement rule'; end if;
  if t !~* '2-3 supporting props' then
    raise exception 'TPL-01 lost its prop count'; end if;
  if t !~* 'Edges: light framing motifs' then
    raise exception 'TPL-01 lost its zone directives'; end if;
  -- None of TPL-11's ground came with it. That ground is why it was withdrawn.
  if t ~* 'all four edges|growing things|band of open white' then
    raise exception 'TPL-11''s patterned ground was ported into TPL-01'; end if;

  select body_text into t from prompt_blocks
   where slug = 'hs-comp-tpl-02-support-circle';
  if t !~* 'at least half the height of the page' then
    raise exception 'the group still has no size'; end if;
  if t !~* '3-5 people' then
    raise exception 'TPL-02 lost its head count'; end if;
  if t !~* 'low-detail backdrop' then
    raise exception 'TPL-02 lost its outdoor variant'; end if;
  if t ~* 'all four edges|growing things|band of open white' then
    raise exception 'TPL-11''s patterned ground was ported into TPL-02'; end if;

  -- The withdrawn templates stay withdrawn. The sentence was worth keeping;
  -- they were not.
  if exists (
    select 1 from prompt_templates
     where slug in ('tpl-11-figure-on-pattern','tpl-12-group-on-pattern')
       and is_active
  ) then raise exception 'a withdrawn template came back'; end if;
end $$;

commit;

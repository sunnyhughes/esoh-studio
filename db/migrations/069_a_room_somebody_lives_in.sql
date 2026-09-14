-- 069_a_room_somebody_lives_in.sql
--
-- Esoh on the first African American Spring 01: "The counter top is bare of
-- anything that says 'this is a lived in space'. Nothing. Like she is living in
-- an empty home, no coffee maker or counter clock or microwave or even a vase
-- or sink."
--
-- Three instructions in that prompt asked for lived-in and a fourth asked for
-- the opposite, and the fourth won:
--
--   art_direction_specs  "kitchens ... that feel recognizably lived in"
--   hs-furnishing        "complete and lived-in, built from real furniture and
--                         objects that belong in that room"
--   hs-density-medium    "furnished enough to feel real"
--   the brief (057)      "simple uncluttered room"        <- mine, and it won
--
-- **The subject line wins.** D118, D120, D121, D131 and now this. The phrase was
-- written into 057 yesterday while differentiating slot 01 from slot 10, and it
-- was the wrong lever — the pages were too alike in their *scene*, not too full.
--
-- The deeper cause is that the three blocks asking for lived-in name nothing
-- concrete between them. D131 established the mechanism from the other side: a
-- block's examples get drawn, whatever the naming was for, which is how a
-- furniture list meant to explain a rule about decoration put a rug and a quilt
-- on a symbol page. Used deliberately, that is exactly what is needed here.
--
-- **It cannot repeat D131.** `hs-furnishing` reaches the seven templates that
-- have a place in them and none of the three that do not — no quote page, no
-- symbol cluster, no decorative border. And the naming is conditioned on the
-- page being indoors, the shape 043 proved when the window stopped appearing in
-- outdoor scenes, so TPL-06's park path and TPL-09's courtyard are not handed a
-- kettle.

begin;

update prompt_blocks set body_text =
  'The setting is complete and lived-in, built from real furniture and objects '
  'that belong in that room, with the described subject as the clear focus. '
  'Where the page is set indoors, the counters, shelves and side tables carry '
  'the few things the person living there keeps out and uses — a kettle or a '
  'coffee pot, a clock, a bowl of fruit, a stack of mail, a jar of utensils, a '
  'plant, a cup set down and not yet washed — each drawn as its own outlined '
  'shape with space around it, so the room reads as one somebody lives in '
  'rather than one waiting to be photographed.',
  updated_at = now()
 where slug = 'hs-furnishing';

-- The phrase that beat all three of them.
update items set
  brief = replace(brief, ', simple uncluttered room,', ','),
  updated_at = now()
 where ref = 'African American Spring 01';

do $$
declare t text; n int;
begin
  select body_text into t from prompt_blocks where slug = 'hs-furnishing';
  if t !~ 'kettle' then raise exception 'the block still names nothing'; end if;
  if t !~ 'Where the page is set indoors' then
    raise exception 'the naming is not conditioned on being indoors'; end if;

  -- It must not reach a page with no place in it.
  select count(*) into n from template_blocks tb
    join prompt_templates t2 on t2.id = tb.template_id
    join prompt_blocks b on b.id = tb.block_id
   where b.slug = 'hs-furnishing' and t2.is_active
     and t2.page_type in ('Quote page','Symbol page','Decorative page');
  if n <> 0 then raise exception 'the furnishing block reaches % page(s) with no room', n; end if;

  select brief into t from items where ref = 'African American Spring 01';
  if t ~* 'uncluttered' then raise exception 'the brief still asks for empty'; end if;
end $$;

commit;

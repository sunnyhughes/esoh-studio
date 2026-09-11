-- 045_objects_get_a_reason_to_be_there.sql
--
-- Esoh on the D120 re-runs: "3 boots, 1 boot on her right foot and a pair of
-- boots next to her which is wrong because why are there random boots next to
-- her... she appears to be sitting on a porch but the background is inside of a
-- house and there's a random basket of apples sitting at her feet."
--
-- All three faults are in the brief, not the blocks, and the brief is mine —
-- written in 042 that same day to move the season off the window. It read:
-- "writing in a journal on a porch step with a blanket round her shoulders; a
-- mug beside her, a basket of apples on the step below and her boots set to one
-- side."
--
-- WHAT EACH PHRASE DID.
--
--   "on a porch step"          — a porch step is a threshold, and the model
--                                drew both sides of it: porch boards underfoot,
--                                living room behind. It was never told which
--                                side of the door she is on.
--   "her boots set to one side" — implies she took them off and never says so,
--                                so the model put boots on her feet *and* a
--                                spare pair beside her. Three boots.
--   "a basket of apples on the  — a position with no reason. Named objects that
--    step below"                 are placed but not motivated read as props set
--                                down at random, which is what "random basket
--                                of apples" means.
--
-- This is the third time in two days that a defect looked like a block problem
-- and was a subject-line problem (D118, D120). The pattern is now specific
-- enough to name: **an object needs a reason to be where it is, and a setting
-- needs a side of the door.** A brief that lists objects gets a page that looks
-- like a list.
--
-- The season still has to survive, so the same channels 041 named are kept —
-- what is worn, what is held, what is being eaten — with each object now doing
-- something rather than sitting somewhere.

begin;

update items set brief =
  'African American woman in her 30s with a twist-out framing her face, sitting '
  'on the top step of a front porch in an oversized cable-knit sweater with a '
  'blanket round her shoulders, writing in a journal balanced on her knees. She '
  'is in thick socks, having left her boots on the step below her, and a mug of '
  'something hot sits by her hip where she can reach it. The porch rail and the '
  'yard beyond are behind her; the front door is closed at her back.',
  updated_at = now()
 where ref = 'African American Fall 01' and ethnicity_line = 'African American';

-- The three faults are addressed by name.
do $$
declare t text;
begin
  select brief into t from items where ref = 'African American Fall 01';

  -- Three boots: she is in socks and the boots are off, stated.
  if t !~* 'in thick socks' or t !~* 'left her boots' then
    raise exception 'boots are still ambiguous — she may be drawn wearing them and beside them';
  end if;

  -- Which side of the door: the page has to commit to outdoors.
  if t !~* 'the front door is closed at her back' then
    raise exception 'setting does not say which side of the door she is on';
  end if;

  -- Every object does something rather than sitting somewhere.
  if t ~* 'basket of apples' then
    raise exception 'the unmotivated basket is still in the brief';
  end if;
  if t !~* 'where she can reach it' then
    raise exception 'the mug has no reason to be where it is';
  end if;
end $$;

-- The season still reads without a window: what is worn, and what is held.
do $$
declare t text;
begin
  select brief into t from items where ref = 'African American Fall 01';
  if t ~* '\ywindow|\yleaves\y|\yleaf\y' then
    raise exception 'the window or the leaves came back'; end if;
  if not (t ~* 'cable-knit sweater' and t ~* 'blanket' and t ~* 'thick socks') then
    raise exception 'season no longer legible'; end if;
end $$;

-- D104/D109/D105 all still hold on this row.
do $$
declare t text;
begin
  select brief into t from items where ref = 'African American Fall 01';
  if t !~* 'African American' then raise exception 'line not named'; end if;
  if t !~* 'twist-out' then raise exception 'hair no longer matches items.hair'; end if;
  if t ~* '\y(dark|black|white|brown|red|blue|green|golden|amber|silver|grey|gray|blonde|olive|tan|fair|pale)\y' then
    raise exception 'colour word introduced'; end if;
  if length(t) < 150 then raise exception 'brief too thin'; end if;
end $$;

-- D120's rule: no abstract noun touching a writing surface.
do $$
declare t text;
begin
  select brief into t from items where ref = 'African American Fall 01';
  if t ~* '\y(recovery|prayer|gratitude|affirmation)\s+(journal|notebook|card)' then
    raise exception 'titled object reintroduced'; end if;
end $$;

commit;

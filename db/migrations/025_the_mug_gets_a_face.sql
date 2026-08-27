-- 025_the_mug_gets_a_face.sql
--
-- Six generations of VVS-0070 fixed the knockout, freed the colour and
-- straightened the type, and every one of them still came back flatter than
-- the reference. The remaining gap was never a style setting.
--
-- The capsule document briefed this design as "a confident coffee mug
-- functioning like a warning beacon". The image made from that brief — the
-- one the user kept and called the kind of thing they want — has a mug with a
-- face: winking, grinning, a bow tie, one hand holding the sign and the other
-- giving a thumbs up, checkerboard trim and starbursts scattered round it.
-- None of that was written down anywhere. The model that drew the reference
-- invented it; ours had no reason to.
--
-- This is the item-brief ceiling, stated concretely. D39 puts objects, props
-- and personality in the item and keeps them out of the style blocks, which
-- is right — but it means a thin brief produces a thin design no matter how
-- good the block layer is. 118 of the 130 rows currently have no
-- `visual_elements` at all, and this is what that will cost each of them.
--
-- Only VVS-0070 is rewritten here. Whether the other designs want characters
-- is a decision per design, and inventing twelve of them from one success is
-- the generalising mistake the project has already paid for twice.

begin;

update items set visual_elements =
  'The coffee mug is a character with a face — one eye winking, a wide '
  'confident grin, a small bow tie at its base. One arm holds up a roadside '
  'warning sign reading "PROCEED WITH CAFFEINE"; the other gives a thumbs up. '
  'Steam rises from the mug in bold hazard-stripe shapes. Small starbursts '
  'and a run of checkerboard trim scatter around the arrangement.'
 where ref = 'VVS-0070'
   and category_id = (select id from categories where code = 'vv-styles');

commit;

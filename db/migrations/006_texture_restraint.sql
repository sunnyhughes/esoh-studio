-- 006_texture_restraint.sql
--
-- First real generation (job 7166191f, Editorial Scene / Dense) came back with
-- every surface stippled — skin, face, sky, wall and tabletop all covered in
-- fine dots. The line work, cable-knit pattern, wood grain and figure were
-- right; the page was close to uncolorable, because a coloring page needs
-- clean enclosed areas to put color into.
--
-- Two causes, both mine.
--
-- 1. The texture block ended "No hatching, stippling or grey fill." That is the
--    §2.5 trap, observed a third time now: naming the unwanted thing invokes it.
--    The sentence is removed rather than reworded.
--
-- 2. "Dense" said "filled edge to edge with drawn detail, leaving no empty
--    ground." Taken literally there is nowhere left to stop, so the model
--    textured skin and sky too. Dense should mean the composition reaches every
--    edge, not that every surface carries marks.
--
-- Replaced with a positive statement of where pattern belongs and where the
-- page stays open.

begin;

update prompt_blocks set body_text =
  'Texture is drawn as pattern: fabric shows its stitch, wood its grain, '
  'foliage its veining, hair its curl — each as closed drawn shapes. Skin, sky '
  'and other broad surfaces stay clean and unmarked, left as open white for '
  'coloring.'
 where slug = 'hs-texture-as-pattern';

update prompt_blocks set body_text =
  'The composition reaches every edge of the page, with detail carried '
  'throughout and no unused corners.'
 where slug = 'hs-density-dense';

update prompt_blocks set body_text =
  'Faces and skin are drawn with clean unbroken contours and no interior '
  'texture. Hair is rendered as dense drawn curl.'
 where slug = 'hs-figure-rendering';

commit;

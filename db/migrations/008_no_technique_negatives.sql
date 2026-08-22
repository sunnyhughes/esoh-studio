-- 008_no_technique_negatives.sql
--
-- 007 removed one technique negative and introduced another: the texture block
-- ended "never as shading, fill or scattered marks" and came back with the
-- subject's face and hands finely hatched. Fourth occurrence.
--
-- The pattern is now clear enough to state precisely, which 006's version of
-- the rule was too blunt to capture. Negatives about CONTENT hold: "No people"
-- and "No border or frame" were both obeyed in every generation. Negatives
-- about RENDERING TECHNIQUE backfire: naming stippling, hatching or shading is
-- apparently enough to render it. Technique is only ever stated positively.

begin;

update prompt_blocks set body_text =
  'Where a surface has visible structure, it is drawn as outlines that divide '
  'it into separate areas to colour. Skin, faces, sky and open ground are left '
  'as clear unmarked white.'
 where slug = 'hs-texture-as-pattern';

update prompt_blocks set body_text =
  'A black and white line illustration for an adult coloring book built '
  'entirely from dense abstract pattern — mandala petals, paisley, scallops, '
  'spirals — tiled across the whole page as outlined shapes to colour.'
 where slug = 'hs-style-zentangle';

commit;

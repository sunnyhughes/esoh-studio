-- 013_exemplar_zero.sql
--
-- Esoh corrected the exemplar by hand: framed leaf art, the pillow leaf, the
-- pine cone, the acorns, the leaf-embossed book and the loose couch leaves are
-- gone. Roughly ten autumn objects down to three, with the season now carried
-- by the view through the window.
--
-- Her articulation of the principle is better than the one in 011 and replaces
-- it: autumn atmosphere is not a room decorated with autumn objects. Seasonal
-- cues establish atmosphere; they do not repeat.
--
-- This becomes the sole exemplar. hoodie-on-sofa v1 is demoted to study — under
-- D50 it would carry its own leaf saturation straight back into every page.
--
-- One known fault remains in v2: the hair and beard are filled solid black,
-- which leaves nothing to colour. Rather than disqualify an otherwise-right
-- page, the figure block is strengthened to push against that single defect —
-- which also tests whether text can override one fault in a good exemplar.

begin;

update reference_images set usable_as_input = false, kind = 'study'
 where storage_path = 'exemplars/hoodie-on-sofa.png';

insert into reference_images
  (category_id, label, storage_path, kind, page_type, art_style, usable_as_input, notes)
values
  ((select id from categories where code='coloring-books'),
   'Hoodie on sofa, corrected', 'exemplars/hoodie-on-sofa-v2.png', 'exemplar',
   'Solo portrait', 'Editorial Scene', true,
   'Exemplar zero. Corrected by Esoh to remove seasonal saturation. Residual '
   'fault: hair and beard filled solid, countered in hs-figure-rendering.');

update prompt_blocks set body_text =
  'Season is carried by the view outside and by the light, not by seasonal '
  'objects placed around the room. At most one or two seasonal touches indoors.'
 where slug = 'hs-seasonal-restraint';

update prompt_blocks set body_text =
  'Clothing and skin are drawn as open white areas with only the lines that '
  'describe their form — a seam, a cuff, a fold. Faces are clean and unmarked. '
  'Hair and beards are drawn as outlined sections with white inside them, '
  'following whatever style the person wears, open enough to colour.'
 where slug = 'hs-figure-rendering';

commit;

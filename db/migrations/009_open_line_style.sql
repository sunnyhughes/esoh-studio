-- 009_open_line_style.sql
--
-- The density premise was wrong, and it came from direction.md §3, which this
-- migration's blocks were written to implement.
--
-- §3 recorded two things as confirmed style attributes: "dense environmental
-- storytelling, edge to edge" and "texture rendered as pattern, never as
-- shading". Generated pages built on those read as seek-and-find puzzles —
-- every surface carrying marks, nowhere for the eye to rest, and no open area
-- large enough to colour comfortably. The point of the book is a calm hour with
-- a pencil, not a hunt.
--
-- Measured against the two pages Esoh identified as closest to the target
-- (storage/exemplars/journaling-under-tree.png and walking-with-mug.png), the
-- actual style is:
--
--   * The subject is OPEN. Clothing and skin are large white areas described by
--     outline alone, with only structural lines — a seam, a cuff, a fold. The
--     hoodie and sweatpants in walking-with-mug carry almost no interior line
--     at all. This directly contradicts "texture rendered as pattern".
--
--   * The background is COUNTABLE SHAPES, not pattern. Individual outlined
--     leaves and flowers with white between them, each one colourable. What
--     made the generated pages busy was continuous surface texture, which is a
--     different thing entirely and cannot be coloured.
--
--   * There is BREATHING ROOM. Open sky, open ground, and a subject that reads
--     instantly.
--
-- The governing principle, replacing "texture as pattern": form is described by
-- outline. Nothing is filled, shaded, hatched or textured.

begin;

update prompt_blocks set body_text =
  'Form is described by outline alone. Every element is a closed shape with '
  'clear white inside it, large enough to colour comfortably.'
 where slug = 'hs-texture-as-pattern';

update prompt_blocks set label = 'Form by outline'
 where slug = 'hs-texture-as-pattern';

update prompt_blocks set body_text =
  'Clothing and skin are drawn as open white areas with only the lines that '
  'describe their form — a seam, a cuff, a fold. Faces are clean and unmarked. '
  'Hair is drawn as outlined sections following whatever style the subject '
  'wears, open inside.'
 where slug = 'hs-figure-rendering';

update prompt_blocks set body_text =
  'A black and white line illustration for an adult coloring book. The subject '
  'is drawn large and clear against an uncluttered setting, with open sky and '
  'ground giving the page room to breathe. Background elements are separate '
  'outlined shapes with white space between them.'
 where slug = 'hs-style-editorial-scene';

update prompt_blocks set label = 'Open Scene'
 where slug = 'hs-style-editorial-scene';

update prompt_blocks set body_text =
  'Pure black line work on white, printed at full page. Every area inside the '
  'outlines is open white, ready to be coloured by hand. No border or frame. '
  'Keep key subject matter clear of the outer edge.'
 where slug = 'hs-output';

-- Density now describes how much of the page carries subject matter, not how
-- filled its surfaces are. Dense no longer means "no unused corners".
update prompt_blocks set body_text =
  'A few large elements with generous white space around them.'
 where slug = 'hs-density-open';

update prompt_blocks set body_text =
  'The subject sits within a setting that is suggested rather than exhaustive, '
  'with clear open areas throughout.'
 where slug = 'hs-density-medium';

update prompt_blocks set body_text =
  'The setting is developed across the page, still built from separate outlined '
  'shapes with white space between them.'
 where slug = 'hs-density-dense';

-- Register the two pages Esoh identified as the style target. These are her own
-- work, so D31 does not apply and they may be used as model input (D20/D22).
insert into reference_images
  (category_id, label, storage_path, kind, page_type, art_style, usable_as_input, notes)
values
  ((select id from categories where code='coloring-books'),
   'Journaling under a tree', 'exemplars/journaling-under-tree.png', 'exemplar',
   'Solo portrait', 'Open Scene', true,
   'Identified as close to target: open dress and skin, sparse background accents, room to breathe.'),
  ((select id from categories where code='coloring-books'),
   'Walking with mug', 'exemplars/walking-with-mug.png', 'exemplar',
   'Solo portrait', 'Open Scene', true,
   'Identified as close to target: clean open hoodie and sweatpants, background as countable outlined leaves.');

commit;

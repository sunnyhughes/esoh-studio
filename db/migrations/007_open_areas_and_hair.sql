-- 007_open_areas_and_hair.sql
--
-- Three corrections from review of the second generation. All three are the
-- same underlying mistake as the motifs (§3.3, D39): style attributes were read
-- off six reference images and generalised into rules they were never meant to
-- carry.
--
-- 1. HAIR IS NOT A STYLE ATTRIBUTE.
--    The figure block said "hair is rendered as dense drawn curl", derived from
--    direction.md §3's "hair is dense intricate curl texture reading near-black".
--    Encoding one hair texture as a rule gives all 180 pages the same hair and
--    forecloses locs, braids, twists, fades, bantu knots, headwraps, straightened
--    and every other way the subject might actually wear it. That is a
--    stereotype written into the prompt engine.
--
--    Hair is content. It belongs in the item brief, which already specifies it
--    where it matters. Style blocks say only how hair is DRAWN.
--
-- 2. NOTHING IS FILLED IN.
--    "Reading near-black" means pre-coloured. A coloring page has no filled,
--    shaded or darkened areas anywhere — that is the entire product. §3 listed
--    "no solid black areas" as a Stage 1 error to be corrected; it was not an
--    error, it was correct.
--
-- 3. STYLE BLOCKS MUST NOT NAME MATERIALS.
--    006 replaced a prop list with another prop list: "fabric shows its stitch,
--    wood its grain, foliage its veining". Naming materials in a style block
--    steers every page toward knitwear and wooden tables — the same error D39
--    was written to prevent, committed while fixing something else. The method
--    is stated without naming anything.
--
-- Also adds a restraint block: the scene contains what the brief describes.
-- Phrased positively, since naming unwanted props would summon them (§2.5).

begin;

update prompt_blocks set body_text =
  'Where a surface has visible structure, it is drawn as outlines that divide '
  'it into separate areas to colour, never as shading, fill or scattered marks.'
 where slug = 'hs-texture-as-pattern';

update prompt_blocks set body_text =
  'Faces and hands are drawn with clean unbroken contours. Hair is drawn as '
  'outlined sections that follow whatever style the subject wears, left open '
  'inside so it can be coloured.'
 where slug = 'hs-figure-rendering';

update prompt_blocks set body_text =
  'Pure black line work on white. Every enclosed area is left open white so it '
  'can be coloured in by hand. No border or frame. Keep key subject matter '
  'clear of the outer edge.'
 where slug = 'hs-output';

update prompt_blocks set body_text =
  'The composition reaches every edge of the page, with the described subject '
  'and setting carried across the whole page.'
 where slug = 'hs-density-dense';

-- The scene contains what the brief describes, and nothing volunteered on top
-- of it. Without this the model reliably adds a mug, a window and a potted
-- plant to any quiet indoor scene, which is how 180 varied briefs would still
-- have produced 180 similar pages.
insert into prompt_blocks (kind, slug, label, body_text, category_id) values
('composition', 'hs-scene-restraint', 'Scene restraint',
 'The scene shows what is described above and is built from that alone.',
 (select id from categories where code='coloring-books'));

insert into template_blocks (template_id, block_id, position)
select t.id, b.id, 45
  from prompt_templates t cross join prompt_blocks b
 where t.slug like 'hs-%' and b.slug = 'hs-scene-restraint';

commit;

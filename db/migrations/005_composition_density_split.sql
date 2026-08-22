-- 005_composition_density_split.sql
--
-- Fixes a contradiction found by composing a real prompt against two art
-- styles. The Solo portrait composition block read "placed within a full
-- setting that surrounds them and fills the page", which is true of Editorial
-- Scene and directly contradicts Bold Minimal's "few elements and generous
-- empty space". Two instructions pulling opposite ways in one prompt is how
-- output turns to mush.
--
-- The composition block was written while thinking only of the house style.
-- Its job is to say WHO or WHAT is in frame. How densely the page is filled
-- belongs to the art style and to background density (D27) — the axis p2 and
-- p3 established, where one quote page is wall-to-wall mandala and the other is
-- nearly empty.
--
-- Also tightens the texture block. It listed "knit stitches, wood grain, woven
-- rug, brick" as examples of method, but naming objects in a style block risks
-- exactly what D39 forbids: the model helpfully adding a rug. Method is now
-- described without naming props.

begin;

alter table prompt_blocks
  add column background_density text null;

comment on column prompt_blocks.background_density is
  'When set, this block is only used at this density (D27). Null means any.';

alter table prompt_blocks add constraint prompt_blocks_density_check
  check (background_density is null
         or background_density in ('Open','Medium','Dense'));


-- Composition blocks state subject only, never density.
update prompt_blocks set body_text =
  'One person is the subject of the page.'
 where slug = 'hs-comp-solo-portrait';

update prompt_blocks set body_text =
  'Several people share the page and interact with one another.'
 where slug = 'hs-comp-community-scene';

update prompt_blocks set body_text =
  'No people. A decorative arrangement surrounds a clear open area at the centre of the page, roughly half the page height, left completely empty. Draw no letters, words or writing anywhere.'
 where slug = 'hs-comp-quote-page';

update prompt_blocks set body_text =
  'No people and no scene. A cluster of related symbolic objects arranged as a single centred group.'
 where slug = 'hs-comp-symbol-page';

update prompt_blocks set body_text =
  'No people. An ornamental arrangement rather than a narrative scene.'
 where slug = 'hs-comp-decorative-page';

update prompt_blocks set body_text =
  'No people. The place itself is the subject.'
 where slug = 'hs-comp-environment-page';


-- Method, without naming objects.
update prompt_blocks set body_text =
  'Texture is drawn as pattern rather than shading: surfaces carry their own repeating marks — stitch, grain, weave, veining, dense curl in hair — always as closed drawn shapes. No hatching, stippling or grey fill.'
 where slug = 'hs-texture-as-pattern';


-- Density blocks (D27). One is selected per job; null density selects none,
-- leaving the art style to set its own.
insert into prompt_blocks (kind, slug, label, body_text, category_id, background_density) values
('composition', 'hs-density-open', 'Open density',
 'The page is mostly open, with a few large elements and generous empty white space around them.',
 (select id from categories where code='coloring-books'), 'Open'),

('composition', 'hs-density-medium', 'Medium density',
 'The page is comfortably filled, with drawn detail and open areas in balance.',
 (select id from categories where code='coloring-books'), 'Medium'),

('composition', 'hs-density-dense', 'Dense density',
 'The page is filled edge to edge with drawn detail, leaving no empty ground.',
 (select id from categories where code='coloring-books'), 'Dense');

-- Attach the density blocks to every Healing Seasons template, just after
-- composition. The engine picks at most one.
insert into template_blocks (template_id, block_id, position)
select t.id, b.id, 25
  from prompt_templates t
  cross join prompt_blocks b
 where t.slug like 'hs-%'
   and b.slug in ('hs-density-open','hs-density-medium','hs-density-dense');

commit;

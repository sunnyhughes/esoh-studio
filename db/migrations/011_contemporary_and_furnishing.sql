-- 011_contemporary_and_furnishing.sql
--
-- Three rounds were spent adjusting density while the actual gap was elsewhere.
-- Naming it plainly: nothing in the Style Library said the people or the places
-- were contemporary. With no instruction either way the model produced generic
-- figures in shapeless long dresses and vague settings — dated, and nothing like
-- the line Esoh is building, which is meant to mirror present-day life.
--
-- The exemplar that shows the target (hoodie-on-sofa.png) has a modern fade with
-- a lineup, a groomed beard, a hoodie, joggers and ribbed socks, in a room with
-- a sectional, framed art, floating shelves, a trailing pothos and a candle in a
-- glass jar. Detailed and full — Esoh's words — while every element stays a
-- separate outlined shape. D47 holds; it was the furnishing that was missing.
--
-- 007's scene-restraint block made this worse. Written to stop the model
-- volunteering a mug and a window into every scene, "the scene is built from
-- that alone" instead stripped the setting out, producing bare pages. The fix
-- for unwanted props was never to remove the room.
--
-- The real failure in that exemplar is seasonal saturation: leaves on the framed
-- art, the book cover, the mug, the tray and the couch, plus a pumpkin and acorns
-- indoors. The season should be ambient, not applied to every surface.

begin;

-- Retire the block that emptied the room.
update prompt_blocks set is_active = false where slug = 'hs-scene-restraint';

insert into prompt_blocks (kind, slug, label, body_text, category_id) values
('subject', 'hs-contemporary', 'Contemporary',
 'The people are present-day and dressed as people dress now — current '
 'everyday clothing, current hair and grooming, relaxed natural posture. '
 'Settings are modern homes and places, furnished the way they really are.',
 (select id from categories where code='coloring-books')),

('environment', 'hs-furnishing', 'Furnishing',
 'The setting is complete and lived-in, built from real furniture and objects '
 'that belong in that room, with the described subject as the clear focus.',
 (select id from categories where code='coloring-books')),

('environment', 'hs-seasonal-restraint', 'Seasonal restraint',
 'Season shows through the window and in one or two touches within the room, '
 'the way it does in a real home.',
 (select id from categories where code='coloring-books'));

insert into template_blocks (template_id, block_id, position)
select t.id, b.id,
       case b.slug when 'hs-contemporary' then 32
                   when 'hs-furnishing' then 42
                   when 'hs-seasonal-restraint' then 43 end
  from prompt_templates t cross join prompt_blocks b
 where t.slug like 'hs-%'
   and b.slug in ('hs-contemporary','hs-furnishing','hs-seasonal-restraint')
   -- Pages with no people still get furnishing and season, not the figure rule.
   and not (b.slug = 'hs-contemporary'
            and t.page_type in ('Quote page','Symbol page','Decorative page'));

-- Density describes how furnished the page is, not how marked its surfaces are.
update prompt_blocks set body_text =
  'The setting is fully furnished and the page is rich with real objects, each '
  'drawn as its own outlined shape with white space around it.'
 where slug = 'hs-density-dense';

update prompt_blocks set body_text =
  'The setting is furnished enough to feel real, with clear open areas between '
  'the objects.'
 where slug = 'hs-density-medium';

insert into reference_images
  (category_id, label, storage_path, kind, page_type, art_style, usable_as_input, notes)
values
  ((select id from categories where code='coloring-books'),
   'Hoodie on sofa', 'exemplars/hoodie-on-sofa.png', 'exemplar',
   'Solo portrait', 'Editorial Scene', true,
   'Target for rendering, contemporary dress and believable furnishing. Its one '
   'fault is seasonal saturation — leaves on art, book, mug, tray and couch, plus '
   'an indoor pumpkin and acorns. Countered by hs-seasonal-restraint.');

commit;

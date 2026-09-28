-- 091 — The missing styles get their paragraphs
--
-- The Lists tab of `VV-Styles Designs Library Original (My version)` names 25
-- art styles. Migration 020 wrote twelve. A design naming one of the other
-- thirteen reached the model with **no style instruction at all**, so the model
-- chose a manner for itself and the sheet's Art Style column did nothing. Of
-- the 78 rows that now name a style, 41 could be built and 37 could not.
--
-- Counts of rows waiting on each, at the time of writing: Minimal Symbolic 9,
-- Emotional Illustrative 7, Architectural / Blueprint Editorial 5, Botanical
-- Editorial Illustration 4, Editorial Scene 2, Urban graffiti 2, Feminine 2,
-- and one each for Geometric Abstract, Soft Botanical Line Art, Split-Scene
-- Editorial Illustration, Retro Diner / Comic, Art Deco Editorial, Celestial.
--
-- **Six of these names already exist under `coloring-books` and were not
-- reused.** Those blocks read "black and white line illustration … every
-- enclosed area open white, ready to be coloured by hand." Pointed at a shirt
-- that produces line art to be coloured in rather than a print. Geometric
-- Abstract, Soft Botanical Line Art, Celestial, Minimal Symbolic, Editorial
-- Scene and Zentangle Pattern are the overlap; the five used by apparel rows
-- are written fresh below and say nothing about enclosed white areas. This is
-- D103's shape — a wrong slot overriding silently is worse than an empty one.
--
-- Drawing manner only. No object, prop or setting is named — that is what
-- `visual_elements` is for (D39). Where a motif is the style rather than the
-- subject (a blueprint's callouts, a Deco fan, a celestial crescent) it is
-- described as manner, the way 020 already allows Vintage Badge its arched
-- banners.
--
-- Drafted from the Visual Elements and Color Direction Sunshine wrote on the
-- rows that use each style, so the wording inherits the house vocabulary
-- rather than inventing one per style. Wording is his to correct.
--
-- `Modern Transit Poster` and `Zentangle Pattern` are on the Lists tab but no
-- apparel row uses them, so neither gets a block here. Tattoo Linework was
-- already written by 020.

insert into prompt_blocks (kind, slug, label, category_id, art_style, body_text)
select v.kind, v.slug, v.label, c.id, v.art_style, v.body
from categories c, (values

  ('base_style', 'vvs-style-minimal-symbolic', 'Minimal Symbolic', 'Minimal Symbolic',
   'Reduced symbolic artwork built from the fewest shapes that carry the idea. Forms are flat '
   'and geometric with clean even edges, set in generous open space so the silhouette reads at '
   'a glance. One restrained accent carries the emphasis while everything else holds a single '
   'quiet tone.'),

  ('base_style', 'vvs-style-emotional-illustrative', 'Emotional Illustrative', 'Emotional Illustrative',
   'Warm illustrated artwork in which the drawing itself carries the feeling. Solid shapes are '
   'softened by fine interior linework at a lighter weight, so a form reads as tender and sturdy '
   'at once. Colour is laid flat throughout and light is drawn as shape rather than blended.'),

  ('base_style', 'vvs-style-architectural-blueprint-editorial', 'Architectural / Blueprint Editorial', 'Architectural / Blueprint Editorial',
   'Drafting-table artwork in the manner of a working blueprint. Construction is left visible: '
   'hairline measure lines, section marks and numbered callouts sit alongside the main forms at '
   'one consistent fine weight. Solid areas stay flat and the linework carries all of the '
   'detail.'),

  ('base_style', 'vvs-style-botanical-editorial-illustration', 'Botanical Editorial Illustration', 'Botanical Editorial Illustration',
   'Composed botanical artwork drawn with editorial restraint. Growing forms are rendered as '
   'clean filled silhouettes carrying a few interior veins, arranged into deliberate structure — '
   'a border, an arch, a repeating run — at an even weight with generous space between them.'),

  ('base_style', 'vvs-style-editorial-scene', 'Editorial Scene', 'Editorial Scene',
   'A single staged scene drawn as one flat illustrated tableau. Every element is built from '
   'solid shapes with hard contours and grouped so the situation reads at a glance. Depth comes '
   'from overlap and scale, with the whole design sitting on one plane in flat colour.'),

  ('base_style', 'vvs-style-urban-graffiti', 'Urban graffiti', 'Urban graffiti',
   'Wall-painted artwork carried by aerosol technique. Forms are built with wide sprayed '
   'strokes and hard stencil edges, with a light overspray halo where the paint meets open '
   'ground. Surface wear reads as scattered flecks and broken fill across the solid areas.'),

  ('base_style', 'vvs-style-feminine', 'Feminine', 'Feminine',
   'Soft-edged artwork built from fine outlined forms. Curves lead and corners run round, with '
   'delicate detail drawn at hairline weight against larger open shapes. Colour stays gentle '
   'and close in value, lifted by a single warm metallic note.'),

  ('base_style', 'vvs-style-geometric-abstract', 'Geometric Abstract', 'Geometric Abstract',
   'Artwork constructed from pure geometry — straight runs, repeating angles, true circles and '
   'evenly weighted bars. Elements align to one shared grid and meet at consistent angles so '
   'the composition reads as a designed system. Every shape is one flat colour with no '
   'modelling.'),

  ('base_style', 'vvs-style-soft-botanical-line-art', 'Soft Botanical Line Art', 'Soft Botanical Line Art',
   'Artwork described almost entirely by a single continuous contour of even weight. Forms are '
   'given by outline alone and their interiors are left open to the garment. Curves are '
   'unhurried and the line holds one thickness from end to end.'),

  ('base_style', 'vvs-style-split-scene-editorial-illustration', 'Split-Scene Editorial Illustration', 'Split-Scene Editorial Illustration',
   'Artwork divided into two halves that share one composition. A single clean division runs '
   'through the design and both sides are drawn in the same flat technique at the same weight, '
   'so the contrast is carried by content rather than by styling.'),

  ('base_style', 'vvs-style-retro-diner-comic', 'Retro Diner / Comic', 'Retro Diner / Comic',
   'Mid-century roadside advertising artwork crossed with comic-panel energy. Bold rounded '
   'shapes carry thick uniform outlines, with motion marks, bursts and small stamped emblems '
   'drawn as solid shapes in their own right. Flat spot colours in a limited set.'),

  ('base_style', 'vvs-style-art-deco-editorial', 'Art Deco Editorial', 'Art Deco Editorial',
   'Artwork built on Deco symmetry and stepped geometry. Forms rise in graduated tiers about a '
   'strong central axis, framed by fine parallel rules and fanned repeats at an even hairline '
   'weight. Flat metallic-toned fills against a deep ground, with sharp mitred corners '
   'throughout.'),

  ('base_style', 'vvs-style-celestial', 'Celestial', 'Celestial',
   'Artwork built from celestial geometry arranged with deliberate symmetry. Discs and '
   'crescents are solid flat shapes, ringed by fine radiating lines and small punctuation at a '
   'lighter weight. Depth is suggested by overlap and graduated sizing rather than by shading.')

) as v(kind, slug, label, art_style, body)
where c.code = 'vv-styles';

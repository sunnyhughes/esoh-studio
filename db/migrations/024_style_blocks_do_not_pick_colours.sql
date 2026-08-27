-- 024_style_blocks_do_not_pick_colours.sql
--
-- 023 removed the two-to-four ink limit from the shared print block and the
-- same design came back monochrome orange. The limit had been written into
-- three of the nine base styles as well, and a hue constraint into a fourth,
-- so removing it once removed it from one place out of four.
--
--   Retro Groovy            "warm inks laid down as solid areas"
--   Editorial Typographic   "Two or three inks, held with restraint"
--   Vintage Badge           "built from a small number of inks"
--   Hand-Drawn Doodle       "Warm and handmade"
--
-- This is D39 one level down. A base style says HOW a design is drawn. How
-- many colours it uses and whether they run warm or cool is not that — it is
-- either the item's business through `color_direction` or the model's when
-- nothing is stated. A style block that names a temperature makes every
-- design in that style share a palette, which is the same fault as putting a
-- candle in a house style.
--
-- The evidence: with `color_direction` cleared the model chose 12 major
-- colours across one hue family, mean saturation 0.88. The reference for the
-- same design uses 19 across warm and cool together — red, teal and cream in
-- one image. "Warm inks" was doing that.
--
-- What is kept is manner. Restraint stays in Editorial Typographic, because
-- restraint is what that style is. The washed speckle stays in Vintage Badge,
-- because a vintage badge is distressed by definition — it is one style out
-- of nine, not a house rule, and nothing else carries it.

begin;

update prompt_blocks set body_text =
  'Flat 1970s printed artwork. Thick rounded contours, generous curves, and '
  'inks laid down as solid areas. Lettering and imagery sit in the same plane '
  'and share one outline weight, the way a period poster is printed in a '
  'single pass.'
 where slug = 'vvs-style-retro-groovy';

update prompt_blocks set body_text =
  'Refined typographic artwork in which the words are the image. '
  'High-contrast lettering set with generous space around it, supported by a '
  'few precise line elements drawn at hairline to medium weight. Held with '
  'restraint, in the manner of a fashion label rather than a poster.'
 where slug = 'vvs-style-editorial-typographic';

update prompt_blocks set body_text =
  'Flat screen-printed emblem artwork in the manner of an old athletic patch '
  'or tour shirt. Shapes are solid and hard-edged, arranged with arched '
  'banners and centred symmetry. Age is carried in the ink itself — the fill '
  'breaks up into fine speckle as though the print has been washed many '
  'times.'
 where slug = 'vvs-style-vintage-badge';

update prompt_blocks set body_text =
  'Hand-drawn illustration with visible marker-and-brush character. Lines are '
  'confident but imperfect, corners run round, and fills are solid colour '
  'laid a little loose against the outline. Handmade and unfussy, drawn by a '
  'steady adult hand.'
 where slug = 'vvs-style-hand-drawn-doodle';

commit;

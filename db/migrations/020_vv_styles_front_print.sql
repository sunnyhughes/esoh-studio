-- 020_vv_styles_front_print.sql
--
-- Stage C, first cut: VV-Styles gets a template and a block layer.
--
-- Until now choosing VV-Styles in the New Job form offered nothing. The
-- category had 130 items, 0 templates and 0 blocks, so `art_style`,
-- `color_direction` and `product_placement` had nowhere to land (D57). This
-- migration builds the missing layer.
--
-- The block set is derived from the twelve-design portfolio capsule written
-- for VV-Styles, with one correction applied throughout.
--
-- **The capsule's prompts break D46.** Every one of the twelve ends with an
-- "Avoid:" list, and those lists mix two kinds of exclusion. Excluding
-- *content* by name is safe and is kept — no mockup, no person, no logos, no
-- weapons. Excluding *technique* by name is what put stippling on every
-- coloring page six times running, so "avoid gradients" and "no background
-- rectangle" are not carried over as written. They are stated positively
-- instead: flat solid ink areas with hard edges, and an outline that is
-- itself the edge of the design with transparency on all sides. Same
-- instruction, stated in the direction the model actually renders.
--
-- **D39 is applied to the capsule's "Art style" line.** That line mixes
-- technique with content — "vintage diner safety poster" is a drawing manner
-- *and* a subject. Only the manner belongs in a base_style block; the diner,
-- the mug beacon and the hazard stripes are that one item's business and go
-- in its `visual_elements`. Nine base styles below describe how a design is
-- drawn and name no objects at all. All twelve capsule designs map onto them.
--
-- **Apparel puts the phrase in the prompt.** D57 keeps `quote_text` out of
-- coloring-book prompts because D23 overlays it as outlined vector type. That
-- reasoning is specific to a page meant to be coloured. Apparel type is
-- filled or knocked out (D59) and is drawn *into* the artwork — arched
-- banners, offset comic caps, lettering that shares its contour with the
-- image. Overlaying flat vector type on top of these designs would throw away
-- the thing that makes them read as shirts. So `quote` is a prompt input here
-- and only here. Proposed as D70.
--
-- **Output size changes.** The category was 1024x1024 square while the
-- delivery note asked for 4500x5400 — two different shapes, neither of which
-- is what a front print is. Set to 1024x1536, the closest portrait
-- `gpt-image-1` produces, delivered into a 3600x4800 (12x18" at 300 DPI)
-- front-print area by padding, never cropping (D30's law, already implemented
-- as `padToPrint`). Because the artwork is transparent, padding is free: the
-- design floats in the print area rather than being cut to fit it.

begin;

-- ---------------------------------------------------------------- category

update categories set
  output_width  = 1024,
  output_height = 1536,
  deliver_width  = 3600,
  deliver_height = 4800,
  deliver_note = 'Front print area 12x16" at 300 DPI. Art is padded into it, never cropped — transparency makes the padding free. Confirm against the actual Printify product before a production run; oversized placements use a larger area with the same art.'
 where code = 'vv-styles';

-- ---------------------------------------------------------------- template

insert into prompt_templates (name, slug, description, category_id, page_type, has_people, variables_json, default_settings)
select
  'VV-Styles — Front Print',
  'vvs-front-print',
  'One apparel design: a phrase and its own symbolic world, drawn as isolated cut-out artwork for screen print or DTF.',
  c.id,
  null,
  false,
  $json$[
    {
      "name": "quote",
      "label": "Phrase",
      "type": "text",
      "required": true,
      "placeholder": "The exact wording, as it should appear on the shirt."
    },
    {
      "name": "visual_elements",
      "label": "Visual elements",
      "type": "textarea",
      "required": true,
      "placeholder": "This design's own world — the objects, symbols and arrangement. From the item row, not shared with other designs."
    },
    {
      "name": "lettering",
      "label": "Lettering direction",
      "type": "combo",
      "required": false,
      "options": [
        "thick athletic serif for the opening words, condensed sans beneath",
        "slanted 1970s display lettering with a compact subtitle",
        "oversized compressed uppercase, stacked in blocks",
        "thick hand-marker lettering with warm imperfect linework",
        "high-contrast serif paired with wide-tracked sans",
        "tall elegant serif set with very wide spacing",
        "bold rounded display type with clean interface text beneath",
        "condensed display caps with one hand-script accent",
        "hand-lettered serif in gentle arches",
        "bold diner script paired with block warning-label type",
        "chunky comic bubble type, slightly offset"
      ],
      "placeholder": "how the words are set"
    },
    {
      "name": "palette",
      "label": "Palette",
      "type": "combo",
      "required": false,
      "options": [
        "ink black, aged cream, burnt orange, muted gold",
        "black, warm cream, tomato red, marigold yellow",
        "black, cream, electric cobalt blue, safety orange",
        "deep navy, rust red, moss green, soft peach",
        "espresso brown, bone, muted brass",
        "black, ivory, rich emerald green",
        "acid green, black, silver grey, white",
        "deep burgundy, tangerine, black, cream",
        "forest green, clay red, cream, antique gold",
        "deep purple, muted gold, charcoal, soft ivory",
        "coffee brown, warm cream, red-orange, vintage aqua",
        "cobalt blue, cream, red, charcoal black"
      ],
      "placeholder": "two to four inks"
    },
    {
      "name": "garment",
      "label": "Garment colour",
      "type": "combo",
      "required": true,
      "options": [
        "white",
        "natural sand",
        "ash grey",
        "dark heather grey",
        "vintage black",
        "black",
        "navy",
        "forest green",
        "maroon",
        "pink"
      ],
      "placeholder": "named in the prompt so light detail does not vanish into the fabric"
    },
    {
      "name": "clean_date",
      "label": "Clean date",
      "type": "text",
      "required": false,
      "placeholder": "e.g. EST. 1995 — leave blank to omit the ribbon entirely"
    }
  ]$json$::jsonb,
  '{"n": 2, "size": "1024x1536", "quality": "high"}'::jsonb
from categories c where c.code = 'vv-styles';

-- ------------------------------------------------------------ base styles
--
-- Drawing manner only. No object, prop or setting is named in any of these —
-- that is what `visual_elements` is for (D39).

insert into prompt_blocks (kind, slug, label, category_id, art_style, body_text)
select v.kind, v.slug, v.label, c.id, v.art_style, v.body
from categories c, (values

  ('base_style', 'vvs-style-vintage-badge', 'Vintage Badge', 'Vintage Badge',
   'Flat screen-printed emblem artwork in the manner of an old athletic patch or tour shirt. '
   'Shapes are solid and hard-edged, built from a small number of inks, arranged with arched '
   'banners and centred symmetry. Age is carried in the ink itself — the fill breaks up into '
   'fine speckle as though the print has been washed many times.'),

  ('base_style', 'vvs-style-retro-groovy', 'Retro Groovy', 'Retro Groovy',
   'Flat 1970s printed artwork. Thick rounded contours, generous curves, and warm inks laid '
   'down as solid areas. Lettering and imagery sit in the same plane and share one outline '
   'weight, the way a period poster is printed in a single pass.'),

  ('base_style', 'vvs-style-retro-comic', 'Retro Comic', 'Retro Comic',
   'Flat comic-book printed artwork. Heavy black contours of varying weight enclose bold inks '
   'filled solid, with a slight offset registration where one ink sits a fraction out of line '
   'with another. Bursts, motion marks and speed lines are drawn as solid shapes in their own '
   'right.'),

  ('base_style', 'vvs-style-streetwear-graffiti', 'Streetwear Graffiti', 'Streetwear Graffiti',
   'Layered screen-print poster artwork. Oversized compressed lettering stacked into blocks, '
   'shapes overprinting one another where they meet, and rough torn edges cut from solid ink. '
   'Every layer is one flat colour; depth comes from overlap and scale.'),

  ('base_style', 'vvs-style-editorial-typographic', 'Editorial Typographic', 'Editorial Typographic',
   'Refined typographic artwork in which the words are the image. High-contrast lettering set '
   'with generous space around it, supported by a few precise line elements drawn at hairline '
   'to medium weight. Two or three inks, held with restraint, in the manner of a fashion label '
   'rather than a poster.'),

  ('base_style', 'vvs-style-bold-minimal', 'Bold Minimal', 'Bold Minimal',
   'Bold reduced graphic artwork built from clean geometric shapes with hard edges. Few '
   'elements, large scale, high contrast, flat solid inks. Every form is carried down to its '
   'clearest silhouette.'),

  ('base_style', 'vvs-style-tattoo-linework', 'Tattoo Linework', 'Tattoo Linework',
   'Tattoo-flash linework. Confident black contours of deliberately varied weight describe '
   'every form, solid ink carries the accents, and depth is built from dense parallel line. '
   'Compositions are symmetrical and self-contained, in the manner of a traditional flash '
   'sheet.'),

  ('base_style', 'vvs-style-hand-drawn-doodle', 'Hand-Drawn Doodle', 'Hand-Drawn Doodle',
   'Hand-drawn illustration with visible marker-and-brush character. Lines are confident but '
   'imperfect, corners run round, and fills are solid colour laid a little loose against the '
   'outline. Warm and handmade, drawn by a steady adult hand.'),

  ('base_style', 'vvs-style-photoreal-composite', 'Photoreal Composite', 'Photoreal Composite',
   'Photographic imagery composited with graphic lettering. The photographic element is cut '
   'cleanly to its own silhouette and combined with flat typographic shapes that share its '
   'edge quality.')

) as v(kind, slug, label, art_style, body)
where c.code = 'vv-styles';

-- --------------------------------------------------------- shared blocks
--
-- One slot per optional block: composePrompt drops any block with an empty
-- slot, so a blank field removes its sentence rather than leaving a hole.

insert into prompt_blocks (kind, slug, label, category_id, body_text)
select v.kind, v.slug, v.label, c.id, v.body
from categories c, (values

  ('composition', 'vvs-comp-front-print', 'Front-print composition',
   'A single front-print graphic, composed as one self-contained unit and centred. It reads '
   'at arm''s length: the phrase lands first, the imagery second. Every element locks into '
   'that one shape, and the design ends where its own outermost marks end.'),

  ('subject', 'vvs-subject', 'Visual elements',
   '{{visual_elements}}'),

  ('subject', 'vvs-quote', 'The phrase',
   'The design carries the exact phrase "{{quote}}", spelled precisely as written and legible '
   'at a glance. The lettering is drawn as part of the artwork — it shares the same contour '
   'weight and ink as the imagery and is built into the composition rather than laid on top '
   'of it.'),

  ('subject', 'vvs-lettering', 'Lettering direction',
   'The words are set as {{lettering}}.'),

  ('color', 'vvs-palette', 'Palette',
   'Palette: {{palette}}.'),

  ('color', 'vvs-garment', 'Garment contrast',
   'The finished design will be printed onto {{garment}} fabric. Every colour in the design '
   'holds its own contrast against that fabric colour, and the outermost contour of the '
   'design stays clearly visible on it.'),

  ('brand_rule', 'vvs-clean-date', 'Clean date',
   'A small ribbon within the design carries the text "{{clean_date}}".'),

  ('print_req', 'vvs-flat-ink', 'Flat ink separation',
   'Built for screen print and DTF. Every area of colour is one flat, solid, evenly filled '
   'shape with a hard edge, and the design uses two to four inks in total. Colours meet each '
   'other cleanly along a definite boundary. All type is filled solid.'),

  ('print_req', 'vvs-edge-quality', 'Detail that survives printing',
   'Detail is kept at a weight that survives the press: the thinnest stroke stays heavy '
   'enough to hold ink, and the counters inside letters stay open.'),

  ('output', 'vvs-output', 'Isolated cut-out artwork',
   'Delivered as isolated cut-out artwork. The outline of the design is its edge, and empty '
   'transparency surrounds it on all four sides. Everywhere the design does not draw — around '
   'it and in the gaps between its shapes — is fully transparent, so the garment shows '
   'through.'),

  ('negative', 'vvs-exclusions', 'Excluded content',
   'The image shows the artwork by itself: no shirt, no mockup, no hanger, no draped or '
   'folded cloth, no person wearing the design, no photograph of a product. No brand logos '
   'or trademarks, no signature, no watermark. No recovery-fellowship logos or symbols. No '
   'drugs, no weapons, no injuries.')

) as v(kind, slug, label, body)
where c.code = 'vv-styles';

-- ------------------------------------------------------------------ wiring

insert into template_blocks (template_id, block_id, position)
select t.id, b.id, v.position
from prompt_templates t, prompt_blocks b, (values
  ('vvs-style-vintage-badge',        10),
  ('vvs-style-retro-groovy',         10),
  ('vvs-style-retro-comic',          10),
  ('vvs-style-streetwear-graffiti',  10),
  ('vvs-style-editorial-typographic',10),
  ('vvs-style-bold-minimal',         10),
  ('vvs-style-tattoo-linework',      10),
  ('vvs-style-hand-drawn-doodle',    10),
  ('vvs-style-photoreal-composite',  10),
  ('vvs-comp-front-print',           20),
  ('vvs-subject',                    30),
  ('vvs-quote',                      32),
  ('vvs-lettering',                  34),
  ('vvs-palette',                    40),
  ('vvs-garment',                    42),
  ('vvs-clean-date',                 50),
  ('vvs-flat-ink',                   60),
  ('vvs-edge-quality',               61),
  ('vvs-output',                     70),
  ('vvs-exclusions',                 80)
) as v(slug, position)
where t.slug = 'vvs-front-print' and b.slug = v.slug;

commit;

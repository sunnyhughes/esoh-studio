-- 097 — Composition stops being one instruction
--
-- `vvs-comp-front-print` is 434 characters and every one of the 130 designs got
-- the same ones. It is the largest single constant in the prompt after the art
-- style, and it decides the thing the eye notices first: whether a design is a
-- badge, a statement, a staged scene or a panel. 41f3766 named it as candidate
-- one for exactly that reason.
--
-- It was also arguing with the art styles it was glued to. The block says "the
-- space between elements is closed up, so the design reads as one dense
-- confident group", while seven of the 31 style blocks ask for the opposite in
-- their own words:
--
--   Luxury Editorial Typography   "held in generous empty space"
--   Minimal Symbolic              "set in generous open space"
--   Editorial Typographic         "generous space around it"
--   Botanical Editorial           "generous space between them"
--   Soft Botanical Line Art       "interiors are left open to the garment"
--   Bold Minimal                  "few elements, large scale"
--   Feminine                      "delicate detail ... against larger open shapes"
--
-- Both instructions were in every one of those prompts, and the model had to
-- pick. The same sentence also told all 130 designs that "bursts, arrows, sparks
-- and motion marks are welcome" — on a fashion-house serif as readily as on a
-- comic panel.
--
-- This is the shape 41f3766 said to look for: a rule written against one real
-- defect and then applied to everything forever. D142 measured our output at 35%
-- and 47% of its own bounding box against references at 60–72% and wrote the
-- density clause to fix it, one day before this. That finding stands and is not
-- undone here. What it actually requires is **footprint and scale** — the group
-- spans the print area and no element is a stray mark — and that stays in the
-- universal block, on every design. What varies is **internal spacing**, which
-- is a property of the kind of object the design is, and which the style already
-- names.
--
-- So: the constant keeps only what is true of every front print, and an
-- arrangement block keyed to the art style says how the elements are organised.
-- Thirty-one rows, seven archetypes — emblem, statement, scene, panel, open,
-- collage, split. The keying is `art_style`, not tone: tone says how an idea is
-- delivered, while the art style already says what kind of object the design is,
-- and `Collegiate / Varsity Emblem` is a crest whether the row is Bold or
-- Reflective.
--
-- Not verified by generation yet. Prompts compose correctly and every art style
-- resolves exactly one arrangement block; whether the open styles now come back
-- too sparse is a picture question, and `boundsFillFraction` on those seven is
-- where it will show.

-- ------------------------------------------------- the constant, cut back
--
-- Kept: one centred front print, legible at arm's length, phrase first, one
-- deliberate group with no strays. Removed: closed-up spacing, and the standing
-- invitation to bursts and sparks. Both now belong to the archetypes that want
-- them.

update prompt_blocks set body_text =
  'A single front-print graphic, centred in its area and large enough to read at arm''s length, '
  'with the phrase landing first and the imagery second. The group spans the print area rather '
  'than sitting small within it, and it is one deliberate arrangement — every element belongs '
  'to it and nothing is a stray mark left in an empty field.'
 where slug = 'vvs-comp-front-print';

-- ------------------------------------------------------- the 31 arrangements

insert into prompt_blocks (kind, slug, label, category_id, art_style, body_text)
select 'composition',
       'vvs-arr-' || m.slug,
       m.art_style || ' — arrangement',
       c.id,
       m.art_style,
       a.body
  from categories c
  cross join (values

  ('Vintage Badge',                          'vintage-badge',          'emblem'),
  ('Collegiate / Varsity Emblem',            'collegiate-emblem',      'emblem'),
  ('Tattoo Linework',                        'tattoo-linework',        'emblem'),
  ('Vintage Poster',                         'vintage-poster',         'emblem'),
  ('Art Deco Editorial',                     'art-deco-editorial',     'emblem'),
  ('Celestial',                              'celestial',              'emblem'),
  ('Retro Groovy',                           'retro-groovy',           'emblem'),

  ('Oversized Condensed Statement',          'oversized-condensed',    'statement'),
  ('Modern Script Statement',                'modern-script',          'statement'),
  ('Streetwear Graffiti',                    'streetwear-graffiti',    'statement'),
  ('Urban graffiti',                         'urban-graffiti',         'statement'),
  ('Modern Grunge Halftone',                 'modern-grunge-halftone', 'statement'),
  ('Chrome Y2K',                             'chrome-y2k',             'statement'),
  ('Photoreal Composite',                    'photoreal-composite',    'statement'),

  ('Editorial Scene',                        'editorial-scene',        'scene'),
  ('Retro Comic',                            'retro-comic',            'scene'),
  ('Retro Diner / Comic',                    'retro-diner-comic',      'scene'),
  ('Hand-Drawn Doodle',                      'hand-drawn-doodle',      'scene'),
  ('Emotional Illustrative',                 'emotional-illustrative', 'scene'),

  ('Neo-Brutalist Grid',                     'neo-brutalist-grid',     'panel'),
  ('Geometric Abstract',                      'geometric-abstract',    'panel'),
  ('Architectural / Blueprint Editorial',    'architectural-blueprint','panel'),

  ('Luxury Editorial Typography',            'luxury-editorial',       'open'),
  ('Editorial Typographic',                  'editorial-typographic',  'open'),
  ('Minimal Symbolic',                       'minimal-symbolic',       'open'),
  ('Bold Minimal',                           'bold-minimal',           'open'),
  ('Soft Botanical Line Art',                'soft-botanical-line',    'open'),
  ('Botanical Editorial Illustration',       'botanical-editorial',    'open'),
  ('Feminine',                               'feminine',               'open'),

  ('Collage Zine Cutout',                    'collage-zine-cutout',    'collage'),

  ('Split-Scene Editorial Illustration',     'split-scene-editorial',  'split')

  ) as m(art_style, slug, archetype)
  join (values

  ('emblem',
   'The design is built as one self-contained emblem. A central anchor — a figure, symbol, '
   'shield or monogram — holds the middle, the phrase is tiered above and below it on arched or '
   'straight baselines, and small repeating marks close off the corners of the group. It is '
   'symmetrical about a vertical axis, the parts sit tight against one another, and the outer '
   'silhouette reads as one deliberate shape.'),

  ('statement',
   'The words are the composition. The phrase is set as large as the area allows, stacked across '
   'two to four lines whose widths are worked to align with each other, and imagery is reduced to '
   'one or two supporting marks tucked into the spaces the lettering leaves. Nothing competes with '
   'the type for the eye — the scale is the design.'),

  ('scene',
   'The design stages one moment. Two or more elements are shown acting on each other — a figure '
   'and the thing it is reacting to — grouped so the situation reads before any single part of it '
   'does, with overlap and relative size carrying the depth. The phrase sits above or below the '
   'action as its caption rather than inside it. Motion marks, bursts and small accents are drawn '
   'where they carry what is happening.'),

  ('panel',
   'The design is built on an exposed structure. Elements align to one shared system of fields, '
   'rules or measured runs, each part sitting in its own compartment at a consistent interval, and '
   'the phrase occupies one of those compartments rather than floating across them. The structure '
   'is drawn as part of the artwork, not implied.'),

  ('open',
   'The design works with few elements at large scale, and the air between them is deliberate '
   'rather than left over. One focal mark and the phrase carry the whole thing, placed so the group '
   'still spans most of the print width — open, not small. Nothing is added to fill space, and '
   'nothing is drawn so fine that it would be lost at arm''s length.'),

  ('collage',
   'The design is assembled rather than drawn. Cut elements are layered slightly out of square, '
   'each overlapping its neighbour so the stack holds together as one mass, and the phrase is built '
   'from pieces sitting at their own angles within it. The edges of the group stay ragged and the '
   'overlap is the structure.'),

  ('split',
   'The design is divided once. A single clean division runs through it and each side carries its '
   'own half of the idea at the same weight and scale, so the two read as a pair rather than as a '
   'subject and its background. The phrase spans the division or is split across it, and both '
   'halves reach the outer edge of the group together.')

  ) as a(archetype, body) on a.archetype = m.archetype
 where c.code = 'vv-styles';

-- ------------------------------------------------------------------- wiring
--
-- Position 21, immediately after the universal composition block at 20, so the
-- general rule is read before the specific arrangement.

insert into template_blocks (template_id, block_id, position)
select t.id, b.id, 21
from prompt_templates t, prompt_blocks b
where t.slug = 'vvs-front-print'
  and b.kind = 'composition'
  and b.slug like 'vvs-arr-%';

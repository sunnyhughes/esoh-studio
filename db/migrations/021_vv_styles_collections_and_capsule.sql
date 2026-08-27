-- 021_vv_styles_collections_and_capsule.sql
--
-- Stage C, second cut: the VV-Styles library gets sorted, and the twelve
-- capsule designs get their direction.
--
-- **Nine collections, not six.** Three taxonomies were in play and they turn
-- out to be one.
--
--   * The spreadsheet's `Category` column has 19 values, six of which overlap
--     with `Tone` (D-open question in direction.md 7).
--   * `vv-styles-lists.csv` carries a proposed slimmer set of 9, never
--     applied.
--   * The portfolio capsule names 6 collections.
--
-- The capsule's six are six of the proposed nine under better names —
-- Recovery Culture, Healing Out Loud, Boundaries, Self-Respect, Survivor
-- Strength, Everyday Sass against Recovery, Healing, Boundaries, Self-Worth,
-- DV & Survivorship, Humor / Sass. The capsule simply had no design in the
-- other three. Taking the capsule's naming where it exists and the proposed
-- list for the remainder gives nine collections that hold all 130 items.
-- Six alone would have left Motivation, Truth and Family/Faith homeless.
--
-- Two judgment calls in the 19-to-9 mapping, both flagged rather than hidden:
-- `Love` has no home in the proposed nine and goes to Family & Faith as the
-- nearest relational grouping; `Self-Awareness` goes to Truth &
-- Accountability, since it is honest self-assessment rather than self-regard.
-- One item has no Category at all and stays in Unsorted.
--
-- **The capsule's twelve get their columns filled.** `visual_elements`,
-- `art_style`, `lettering_style`, `color_direction` and `product_placement`
-- come straight from the capsule document. What does NOT come from it is the
-- drawing manner: the capsule's "Art style" line mixes manner with subject,
-- so "vintage diner safety poster" resolves to art_style Retro Groovy with
-- the diner, the mug beacon and the hazard stripes in visual_elements, where
-- D39 puts them. The other 118 items keep empty direction columns — they have
-- not been art-directed yet, and inventing it here is exactly the mistake
-- that generalised six reference images into a house style.

begin;

-- --------------------------------------------------------- the nine

insert into collections (category_id, slug, name, description)
select c.id, v.slug, v.name, v.description
from categories c, (values
  ('recovery-culture', 'Recovery Culture',
   'Milestones, clean dates and recovery said out loud.'),
  ('healing-out-loud', 'Healing Out Loud',
   'Emotional work done in the open — honest rather than soothing.'),
  ('boundaries', 'Boundaries',
   'What is not up for discussion, stated plainly.'),
  ('self-respect', 'Self-Respect',
   'Self-worth, standards and being selective.'),
  ('survivor-strength', 'Survivor Strength',
   'Survivorship and domestic violence, told with dignity and no victim framing.'),
  ('everyday-sass', 'Everyday Sass',
   'Humour and personality. The giftable end of the line.'),
  ('truth-accountability', 'Truth & Accountability',
   'Honesty, self-awareness and owning it.'),
  ('motivation', 'Motivation',
   'Progress, persistence and beginning again.'),
  ('family-faith', 'Family & Faith',
   'Love, family and belief.')
) as v(slug, name, description)
where c.code = 'vv-styles'
  and not exists (
    select 1 from collections x
     where x.category_id = c.id and x.slug = v.slug
  );

-- ------------------------------------------------- sort all 130 items

update items i
   set collection_id = target.id
  from (
    select col.id, m.source_category
      from collections col
      join categories cat on cat.id = col.category_id
      join (values
        ('Recovery',        'recovery-culture'),
        ('Healing',         'healing-out-loud'),
        ('Self-Care',       'healing-out-loud'),
        ('Boundaries',      'boundaries'),
        ('Self-Esteem',     'self-respect'),
        ('Self-Respect',    'self-respect'),
        ('Confident',       'self-respect'),
        ('DV',              'survivor-strength'),
        ('Sassy',           'everyday-sass'),
        ('Humor',           'everyday-sass'),
        ('Truth',           'truth-accountability'),
        ('Accountability',  'truth-accountability'),
        ('Honesty',         'truth-accountability'),
        ('Self-Awareness',  'truth-accountability'),
        ('Motivational',    'motivation'),
        ('Love',            'family-faith'),
        ('Family',          'family-faith'),
        ('Faith',           'family-faith')
      ) as m(source_category, slug) on m.slug = col.slug
     where cat.code = 'vv-styles'
  ) as target
 where i.category_id = (select id from categories where code = 'vv-styles')
   and i.source_row->>'Category' = target.source_category;

-- ------------------------------------------ the twelve capsule designs

update items i set
  art_style         = coalesce(v.art_style, i.art_style),
  visual_elements   = v.visual_elements,
  lettering_style   = v.lettering,
  color_direction   = v.palette,
  product_placement = v.placement,
  status            = case when i.status = 'idea' then 'brief_ready' else i.status end
from (values

  ('VVS-0001', 'Vintage Badge',
   'An arched banner over a lower banner, with two strong hands holding a torn chain apart between them — held, not snapped. A small seven-point star above, and a slim ribbon below carrying a clean date.',
   'thick athletic serif for the opening words, condensed sans beneath',
   'ink black, aged cream, burnt orange, muted gold',
   'Vintage black tee, front center'),

  ('VVS-0002', 'Retro Comic',
   'A torn movie-poster edge with dramatic stage-light rays behind an oversized starburst. The victorious line sits inside the burst. A tiny crossed-out phrase reading THE END? hides in a corner as an easter egg.',
   'slanted 1970s display lettering with a compact subtitle',
   'black, warm cream, tomato red, marigold yellow',
   'Natural sand tee, front center'),

  ('VVS-0003', 'Streetwear Graffiti',
   'An abstract megaphone built from layered sound-wave lines, with torn-flyer texture and paste-up energy behind it. Small supporting text reads NO SHAME / ALL VOICE.',
   'oversized compressed uppercase, stacked in blocks',
   'black, cream, electric cobalt blue, safety orange',
   'Black tee, oversized front print'),

  ('VVS-0013', 'Hand-Drawn Doodle',
   'Three connected moments: an open heart beneath a small rain cloud; two hands sorting simple cards; and a heart growing roots and wildflowers. The ampersands run between them like a winding thread.',
   'thick hand-marker lettering with warm imperfect linework',
   'deep navy, rust red, moss green, soft peach',
   'Natural sand tee, front center'),

  ('VVS-0092', 'Editorial Typographic',
   'A small closed gate with a single key beneath it, set above a fine horizon line. A subtle round seal reads NON-NEGOTIABLE.',
   'high-contrast serif paired with wide-tracked sans',
   'espresso brown, bone, muted brass',
   'Black tee, left chest with coordinated back print'),

  ('VVS-0091', 'Editorial Typographic',
   'A single black chess queen moving toward one highlighted square on a minimal board, with a crown silhouette worked into the queen itself.',
   'tall elegant serif set with very wide spacing',
   'black, ivory, rich emerald green',
   'Natural sand tee, front center'),

  ('VVS-0119', 'Bold Minimal',
   'A simplified desktop pop-up window holding a broken key icon and an ACCESS DENIED button, with a small fictional system code reading ERR: BOUNDARY_001.',
   'bold rounded display type with clean interface text beneath',
   'acid green, black, silver grey, white',
   'Black tee, front center'),

  ('VVS-0102', 'Streetwear Graffiti',
   'A vintage microphone at the centre, its sound waves turning into wildflowers and rising birds, over torn-paper collage shapes.',
   'condensed display caps with one hand-script accent',
   'deep burgundy, tangerine, black, cream',
   'Vintage black tee, oversized front print'),

  ('VVS-0110', 'Tattoo Linework',
   'Two steady hands cupping a small house with one glowing window, ringed by a protective wreath of wildflowers, with a very subtle shield outline behind the whole arrangement.',
   'hand-lettered serif in gentle arches',
   'forest green, clay red, cream, antique gold',
   'Forest green tee, front center'),

  ('VVS-0094', 'Tattoo Linework',
   'A cracked stone arch opening into bright daylight, a flowering vine growing up through the cracks, and a small dignified back-facing silhouette walking forward through the opening.',
   'tall elegant serif set with very wide spacing',
   'deep purple, muted gold, charcoal, soft ivory',
   'Black tee, front center'),

  ('VVS-0070', 'Retro Groovy',
   'A confident coffee mug standing as a warning beacon, steam rising in hazard-stripe shapes, and a small roadside sign reading PROCEED WITH CAFFEINE.',
   'bold diner script paired with block warning-label type',
   'coffee brown, warm cream, red-orange, vintage aqua',
   'Natural sand tee, front center'),

  ('VVS-0074', 'Retro Comic',
   'A friendly, expressive retro robot with one small loose screw floating above its head, a scatter of bolts and nuts, comic starbursts and motion lines. The robot reads quirky and confident rather than broken.',
   'chunky comic bubble type, slightly offset',
   'cobalt blue, cream, red, charcoal black',
   'Dark heather grey tee, front center')

) as v(ref, art_style, visual_elements, lettering, palette, placement)
where i.ref = v.ref
  and i.category_id = (select id from categories where code = 'vv-styles');

-- No clean date is stored. D35 makes it a per-buyer personalization slot, so
-- it is entered at generation time and its block drops out when blank. Only
-- VVS-0001 is composed around one, and `brand_mark` is not the field for it —
-- that column is constrained to the two brand names.

commit;

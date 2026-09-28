-- 093 — Lettering gets a vocabulary
--
-- The entire lettering instruction in every apparel prompt was one sentence:
--
--     The words are set as {{lettering}}.
--
-- The sheet names 25 lettering styles and nothing described any of them, so
-- "Bold Sans" reached the model as two words while the art style beside it
-- carried 270 characters of specific technique. The art style won every time —
-- and several of them dictate lettering outright: Vintage Poster asks for
-- "heavy display lettering arched or stacked", Collegiate for "slab or block
-- lettering tiered above and below", Retro Groovy for lettering that "shares
-- one outline weight" with the imagery. Six of the twelve original art styles
-- are period pieces, so the lettering came out period whatever the sheet said.
--
-- Sunshine, 2026-09-28: "the lettering is almost always flat and old-timey
-- looking." Flat is deliberate — `vvs-flat-ink` requires all type filled solid
-- because DTF needs solid fills to hold ink. Old-timey was this gap.
--
-- `prompt_blocks` had no way to key a block to a lettering style; `getBlocks`
-- filtered on art_style, background_density and ethnicity_line only. This adds
-- the column and the twenty-five blocks. The engine change is in the same
-- commit — a column no query reads would be the 091 mistake again.
--
-- The generic block is retired rather than kept as a fallback: the filter is
-- `(b.lettering_style is null or b.lettering_style = $5)`, so a null block
-- matches every call and would render alongside the specific one. A row naming
-- no lettering style now gets no lettering block, which is what it already got
-- — `composePrompt` dropped the generic block on a blank slot anyway.
--
-- Two names carry typos from the sheet's Lists tab, `High-Constrast` and
-- `acents`. They are reproduced exactly here because the join is on the string.
-- Correct them in the sheet and this migration needs a follow-up.

-- `lettering` is a new block kind. The old generic block was filed under
-- `subject`, which was true when it was one sentence riding along with the
-- brief and is not true now that lettering is its own layer with 25 entries.

alter table prompt_blocks drop constraint if exists prompt_blocks_kind_check;
alter table prompt_blocks add constraint prompt_blocks_kind_check
  check (kind = any (array[
    'base_style', 'subject', 'composition', 'environment', 'lighting',
    'color', 'brand_rule', 'print_req', 'negative', 'output', 'lettering'
  ]));

alter table prompt_blocks add column if not exists lettering_style text;

comment on column prompt_blocks.lettering_style is
  'Selects a lettering block, the way art_style selects a base style. Null applies to every lettering style.';

-- ------------------------------------------------------------ retire generic

delete from template_blocks tb
 using prompt_blocks b, prompt_templates t
 where tb.block_id = b.id and tb.template_id = t.id
   and b.slug = 'vvs-lettering' and t.slug = 'vvs-front-print';

update prompt_blocks set is_active = false where slug = 'vvs-lettering';

-- ------------------------------------------------------------- the 25 blocks
--
-- Letterform technique only — weight, contrast, width, terminals, spacing,
-- case, and how two voices relate when a style names two. No objects, and no
-- colour: `vvs-palette` owns colour and `vvs-flat-ink` owns the fill.

insert into prompt_blocks (kind, slug, label, category_id, lettering_style, body_text)
select v.kind, v.slug, v.label, c.id, v.lettering_style, v.body
from categories c, (values

  ('lettering', 'vvs-let-bubble-caps', 'Bubble Caps', 'Bubble Caps',
   'The words are set in rounded display capitals with swollen cushioned counters. Strokes hold '
   'one uniform thickness and terminals close to soft points, and letters sit close enough to '
   'press against one another, held by a single clean contour.'),

  ('lettering', 'vvs-let-brush-script', 'Brush Script', 'Brush Script',
   'The words are set in a connected brush script that shows its stroke direction. Strokes swell '
   'on the pull and taper at the lift, entry and exit strokes carry the joins, and the baseline '
   'rides with a slight natural rhythm.'),

  ('lettering', 'vvs-let-block-outline', 'Block Outline', 'Block Outline',
   'The words are set in heavy block capitals described by a contour of even weight, their '
   'interiors left open to the garment. Letterforms are square-shouldered and closely spaced, so '
   'the run of open counters reads as one continuous band.'),

  ('lettering', 'vvs-let-serif-editorial', 'Serif Editorial', 'Serif Editorial',
   'The words are set in a book-weight serif at display size, with moderate stroke contrast and '
   'crisp bracketed serifs. Letterspacing is generous and even and the lines are set tight, '
   'carrying the authority of a printed page.'),

  ('lettering', 'vvs-let-hand-marker', 'Hand-Marker', 'Hand-Marker',
   'The words are set in capitals drawn with a chisel marker at speed. Stroke width shifts with '
   'the angle of the nib, corners overshoot a little where one stroke crosses another, and the '
   'baseline keeps a hand-set irregularity.'),

  ('lettering', 'vvs-let-mixed-caps-script', 'Mixed Caps + Script', 'Mixed Caps + Script',
   'The words are set in two voices: firm upright capitals carry the structural words while a '
   'connected script carries one emphasised word at a larger scale and contrasting angle. The '
   'script overlaps the capitals where they meet.'),

  ('lettering', 'vvs-let-sans-display', 'Sans Display', 'Sans Display',
   'The words are set in a contemporary grotesque at large size and tight spacing. Stroke weight '
   'stays even, terminals are cut square to the baseline, and the letters sit near-touching so '
   'the line reads as a single mass.'),

  ('lettering', 'vvs-let-stencil', 'Stencil', 'Stencil',
   'The words are set in stencil capitals with clean bridges interrupting the strokes. '
   'Letterforms are square and industrial and the breaks are deliberate and consistent in width, '
   'all at one heavy weight.'),

  ('lettering', 'vvs-let-soft-hand-drawn', 'Soft hand-drawn', 'Soft hand-drawn',
   'The words are set in gently irregular hand-drawn letterforms with rounded corners and '
   'slightly uneven stroke width. Each letter sits a little differently on the baseline, warm and '
   'unhurried, held by a calm single-weight contour.'),

  ('lettering', 'vvs-let-bold-geometric-sans', 'Bold Geometric Sans', 'Bold Geometric Sans',
   'The words are set in capitals built from circles and straight runs at a single heavy weight. '
   'Bowls are true circles, joints are clean, counters stay wide and open, and the spacing is '
   'tight and even so the geometry is the character.'),

  ('lettering', 'vvs-let-modern-typography', 'Modern typography', 'Modern typography',
   'The words are set as current display typography: a tight high-impact setting with one '
   'dominant weight played against a much lighter one, hard left alignment, and generous space '
   'above and below. Contemporary and unfussy.'),

  ('lettering', 'vvs-let-sophisticated-editorial', 'Sophisticated editorial', 'Sophisticated editorial',
   'The words are set with editorial restraint: a high-contrast serif for the phrase, one small '
   'all-caps sans line as counterpoint with wide letterspacing, and a single hairline rule. Quiet '
   'and confident.'),

  ('lettering', 'vvs-let-high-contrast-serif-small-sans', 'High-Constrast Serif + Small Sans', 'High-Constrast Serif + Small Sans',
   'The words are set in a high-contrast display serif — thin hairlines against heavy stems, '
   'sharp unbracketed serifs — at large size, with a small widely letterspaced sans line beneath '
   'it. The difference in scale between the two does the work.'),

  ('lettering', 'vvs-let-bold-sans', 'Bold Sans', 'Bold Sans',
   'The words are set in heavy sans capitals at one uniform weight, tight and square with flat '
   'terminals. Plain, direct and modern, reading at a distance with no ornament at all.'),

  ('lettering', 'vvs-let-bold-sans-script-accent', 'Bold Sans + Script accent', 'Bold Sans + Script accent',
   'The words are set in heavy sans capitals, with one word set instead in a connected script at '
   'a larger scale and slight angle. The script crosses in front of the capitals and the two '
   'share one ink.'),

  ('lettering', 'vvs-let-bold-sans-italic-accent', 'Bold Sans + Italic accent', 'Bold Sans + Italic accent',
   'The words are set in heavy upright sans capitals with a single emphasised word in a steeply '
   'sloped italic of the same family. The slope alone carries the emphasis; weight and spacing '
   'stay matched across both.'),

  ('lettering', 'vvs-let-bold-sans-technical-accent', 'Bold Sans + Technical accent', 'Bold Sans + Technical accent',
   'The words are set in heavy sans capitals with small monospaced annotation alongside — tiny '
   'widely spaced labels, tick marks and a rule or two at hairline weight. The contrast between '
   'the mass and the fine notation is the effect.'),

  ('lettering', 'vvs-let-serif-display-script', 'Serif Display + Script', 'Serif Display + Script',
   'The words are set in a large display serif with a connected script running across or beneath '
   'one word at a contrasting scale. Both are filled solid and share one ink, the script tapering '
   'into the serif''s counters.'),

  ('lettering', 'vvs-let-hand-marker-script', 'Hand-Marker Script', 'Hand-Marker Script',
   'The words are set in a connected script drawn with a marker at speed. Stroke width stays '
   'near-uniform with slight swelling at the turns, joins are quick and open, and the line keeps '
   'the forward lean of handwriting done in one pass.'),

  ('lettering', 'vvs-let-retro-display', 'Retro Display', 'Retro Display',
   'The words are set in display lettering with exaggerated proportions — tall shoulders, '
   'compressed counters, and swash terminals hooking back into the word. Letters nest tightly '
   'together with the character of hand-painted signwriting.'),

  ('lettering', 'vvs-let-soft-serif-label-maker', 'Soft hand-drawn serif + playful label-maker acents', 'Soft hand-drawn serif + playful label-maker acents',
   'The words are set in a gently irregular hand-drawn serif, with small accent words punched as '
   'though from a label maker: tight monospaced capitals reversed out of a solid rounded-corner '
   'bar. Warm main setting, crisp small counterpoint.'),

  ('lettering', 'vvs-let-bubble-caps-script-accent', 'Bubble Caps + handwritten script accent', 'Bubble Caps + handwritten script accent',
   'The words are set in rounded cushioned display capitals, with one accent word in loose '
   'handwritten script at smaller scale and a jaunty angle. The script sits in the gap the bubble '
   'letters leave and shares their ink.'),

  ('lettering', 'vvs-let-big-top-condensed', 'Big Top Display + playful condensed sans', 'Big Top Display + playful condensed sans',
   'The words are set in circus-poster display lettering — tall condensed capitals with heavy '
   'slab terminals on an arched or banner-set baseline — paired with a plain condensed sans for '
   'the secondary line.'),

  ('lettering', 'vvs-let-distressed-caps-strikeout', 'Distressed Block Caps + Handwritten Strikeout', 'Distressed Block Caps + Handwritten Strikeout',
   'The words are set in heavy block capitals whose fill breaks into fine speckle, with one word '
   'struck through by a fast handwritten line and a handwritten replacement beside it. The '
   'correction is drawn rather than typeset and is part of the design.'),

  ('lettering', 'vvs-let-elegant-serif-geometric-sans', 'Elegant Serif Display + Geometric Sans', 'Elegant Serif Display + Geometric Sans',
   'The words are set in a refined high-contrast serif at large size, with a geometric sans in '
   'small widely letterspaced capitals beneath. The serif carries the feeling and the sans '
   'carries the information, with generous space between them.')

) as v(kind, slug, label, lettering_style, body)
where c.code = 'vv-styles';

-- ------------------------------------------------------------------ wiring
--
-- Position 34, where the generic block sat. 091 wrote blocks and forgot this
-- step; a block with no template_blocks row is never selected.

insert into template_blocks (template_id, block_id, position)
select t.id, b.id, 34
from prompt_templates t, prompt_blocks b
where t.slug = 'vvs-front-print'
  and b.kind = 'lettering'
  and b.slug like 'vvs-let-%';

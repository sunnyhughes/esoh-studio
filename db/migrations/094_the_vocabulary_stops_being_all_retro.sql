-- 094 — The vocabulary stops being all retro
--
-- Sunshine, 2026-09-28: "They all seem too plain and don't match the feelings
-- of the quotes... I would like a more balanced availability of styles that
-- are more fitted or similar to the styles of the current ages."
--
-- He is reading the library correctly. Of the twelve art styles written in 020,
-- six are period pieces by their own text — Vintage Badge ("an old athletic
-- patch or tour shirt"), Vintage Poster ("mid-century"), Retro Comic, Retro
-- Groovy, Collegiate / Varsity Emblem, Tattoo Linework ("a traditional flash
-- sheet") — and two more, Hand-Drawn Doodle and Photoreal Composite, are used
-- by no design at all. The contemporary half was four blocks.
--
-- Meanwhile his own briefs had already moved: Editorial Typographic 14 rows,
-- Minimal Symbolic 9, Emotional Illustrative 7, Bold Minimal 6. He was writing
-- modern, restrained, feeling-led designs against a retro vocabulary. 091's
-- thirteen were era-neutral and helped; these six add registers the library had
-- no name for.
--
-- Nothing is removed. The period styles are not wrong, only over-represented,
-- and rebalancing is additive (his instruction: "leave the retro ones alone").
--
-- These are a first pass, written against the quotes in the library rather than
-- from a trend list, and to be corrected against the reference images he is
-- collecting. Every one respects `vvs-flat-ink` — all colour in flat solid
-- areas, all type filled solid — because DTF needs solid fills to hold ink.
-- Chrome Y2K is the one to watch there: it is described in stepped flat bands,
-- not gradients, which is how the look is actually screen-printed.
--
-- These six are not on the sheet's Lists tab. They do not need to be — art
-- style is chosen at generation time, not read from the row (`buildPrompt`
-- takes it as an argument), so they are selectable immediately. Adding them to
-- the Lists tab is only needed to set one as a row's stored default.

insert into prompt_blocks (kind, slug, label, category_id, art_style, body_text)
select v.kind, v.slug, v.label, c.id, v.art_style, v.body
from categories c, (values

  ('base_style', 'vvs-style-modern-grunge-halftone', 'Modern Grunge Halftone', 'Modern Grunge Halftone',
   'Contemporary grunge print artwork. Forms are built from coarse halftone dot fields and '
   'photocopied texture, with edges breaking up as though reproduced several times over. Heavy '
   'condensed type sits hard against the imagery, the whole thing carried in one or two inks.'),

  ('base_style', 'vvs-style-oversized-condensed-statement', 'Oversized Condensed Statement', 'Oversized Condensed Statement',
   'A single oversized statement filling the print area edge to edge. Letterforms are tall, '
   'narrow and tightly stacked across two or three lines, with imagery reduced to one small '
   'supporting mark. Scale is the whole design and the margins are deliberately tight.'),

  ('base_style', 'vvs-style-chrome-y2k', 'Chrome Y2K', 'Chrome Y2K',
   'Early-2000s chrome artwork rendered in flat banded tone. Forms are swollen and liquid with '
   'rounded bevels, and the metal is described by hard-edged bands of light and dark stepping '
   'across each shape rather than by blending. Cool greys lifted by one saturated accent.'),

  ('base_style', 'vvs-style-collage-zine-cutout', 'Collage Zine Cutout', 'Collage Zine Cutout',
   'Cut-and-paste zine artwork. Elements are torn or scissor-cut from flat colour and layered '
   'slightly out of square, with lettering assembled from mismatched flat letterforms. Rough '
   'edges and visible overlap carry the energy.'),

  ('base_style', 'vvs-style-neo-brutalist-grid', 'Neo-Brutalist Grid', 'Neo-Brutalist Grid',
   'Raw grid-built artwork. Heavy rules divide the area into hard rectangular fields, type is set '
   'flush into those fields at sharply contrasting weights, and one field carries a saturated '
   'flat colour against plain ground. The structure is left exposed.'),

  ('base_style', 'vvs-style-modern-script-statement', 'Modern Script Statement', 'Modern Script Statement',
   'A single fluid modern script carrying the phrase at large scale, drawn with a monoline or '
   'lightly swelling stroke and confident open joins. One or two small flat shapes support it. '
   'Contemporary hand-lettering rather than period signwriting.')

) as v(kind, slug, label, art_style, body)
where c.code = 'vv-styles';

-- Wiring, position 10 — the base_style slot. 091 skipped this step and the
-- blocks it wrote were unreachable until 092.

insert into template_blocks (template_id, block_id, position)
select t.id, b.id, 10
from prompt_templates t, prompt_blocks b
where t.slug = 'vvs-front-print'
  and b.slug in (
    'vvs-style-modern-grunge-halftone',
    'vvs-style-oversized-condensed-statement',
    'vvs-style-chrome-y2k',
    'vvs-style-collage-zine-cutout',
    'vvs-style-neo-brutalist-grid',
    'vvs-style-modern-script-statement'
  );

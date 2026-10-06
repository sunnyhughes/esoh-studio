-- 099 — A main style and a second voice
--
-- Sunshine, 2026-10-06, after reading the lettering instruction every design
-- receives: "I feel like that's creating a boxed in style." Four changes, all
-- asked for or approved that day.
--
-- 1. `vvs-quote` told every design that its lettering "shares the same contour
--    weight and ink as the imagery". With 25 lettering blocks behind it, that
--    sentence still made the drawing decide the letters. The lettering now
--    follows the lettering style; it stays part of the composition.
--
-- 2. `vvs-keyline` gave every design "one or more offset outlines", with "two
--    or three stacked contours" usual on display work — the sticker look on
--    all 130 designs. The styles built on stacked outlines already ask for them
--    in their own blocks (Collegiate's "layered offset outlines around each
--    letter", Retro Groovy's shared outline weight, Retro Comic's heavy
--    contours, Bubble Caps' "single clean contour"), and `vvs-garment` still
--    makes every design carry its own contrast. Retired, not edited: it was
--    400 of the ~2,600 characters every prompt repeats.
--
-- 3. Weapons: "symbols are allowed, acts are not", and only on Bold and
--    Confrontational designs, never Survivorship. The act ban moves into the
--    universal exclusions; whether a dagger may appear at all becomes a
--    selector, `emblem_rule`, decided in lib/generate.ts from tone and category.
--    Category is not a block selector, and two Survivorship rows (VVS-0002,
--    VVS-0109) are Bold, so tone alone could not express the rule.
--
-- 4. Main and secondary styles. Lettering gains an optional accent voice and
--    art style an optional secondary influence, each its own selector, each
--    dropping out when blank so every existing row is unchanged by it.
--    The 25 lettering blocks stay: a combined name like "Bold Sans + Script
--    accent" still works as a main style. Four single mains are added so every
--    combination on the sheet can be split into main + accent if he wants.
--
--    An art secondary is written as an accent, never as a second full style.
--    Two complete style paragraphs in one prompt contradict each other (Vintage
--    Badge's "small number of inks, washed speckle" against Celestial's fine
--    radiating lines), so each secondary names motifs and detail only and says
--    outright that the main style keeps its technique.

-- ------------------------------------------------------- 1. the phrase block

update prompt_blocks
   set body_text =
         'The design carries the exact phrase "{{quote}}", spelled precisely as '
         'written and legible at a glance. The lettering is part of the '
         'composition rather than laid on top of it, and its letterforms follow '
         'the lettering style rather than the artwork''s linework.',
       updated_at = now()
 where slug = 'vvs-quote';

-- -------------------------------------------------------------- 2. keyline

delete from template_blocks tb
 using prompt_blocks b
 where tb.block_id = b.id and b.slug = 'vvs-keyline';

update prompt_blocks set is_active = false, updated_at = now()
 where slug = 'vvs-keyline';

-- ------------------------------------------------------- 3. symbols, not acts

update prompt_blocks
   set body_text =
         'The image shows the artwork by itself: no shirt, no mockup, no hanger, '
         'no draped or folded cloth, no person wearing the design, no photograph '
         'of a product. No brand logos or trademarks, no signature, no watermark. '
         'No recovery-fellowship logos or symbols. No drugs. No blood, no wounds '
         'or injuries, no weapon held by or aimed at a person, and nothing that '
         'shows harm happening.',
       updated_at = now()
 where slug = 'vvs-exclusions';

alter table prompt_blocks add column if not exists emblem_rule text;
comment on column prompt_blocks.emblem_rule is
  'banned | symbolic. Chosen by lib/generate.ts from tone and category. Null applies to both.';

-- ------------------------------------------------------- 4. accent selectors

alter table prompt_blocks drop constraint if exists prompt_blocks_kind_check;
alter table prompt_blocks add constraint prompt_blocks_kind_check
  check (kind = any (array[
    'base_style', 'subject', 'composition', 'environment', 'lighting',
    'color', 'brand_rule', 'print_req', 'negative', 'output', 'lettering',
    'tone', 'art_accent', 'lettering_accent'
  ]));

alter table prompt_blocks add column if not exists art_accent text;
alter table prompt_blocks add column if not exists lettering_accent text;
comment on column prompt_blocks.art_accent is
  'Selects a secondary art-style block. Null applies to every secondary, including none.';
comment on column prompt_blocks.lettering_accent is
  'Selects an accent lettering block. Null applies to every accent, including none.';

alter table items add column if not exists art_accent text;
alter table items add column if not exists lettering_accent text;
comment on column items.art_accent is
  'Optional secondary art style. Adds motifs; the main art_style keeps its technique.';
comment on column items.lettering_accent is
  'Optional accent lettering for one word or line of the phrase.';

-- ------------------------------------------------------------ the new blocks

insert into prompt_blocks
  (kind, slug, label, category_id, emblem_rule, lettering_style,
   lettering_accent, art_accent, body_text)
select v.kind, v.slug, v.label, c.id, v.emblem_rule, v.lettering_style,
       v.lettering_accent, v.art_accent, v.body
from categories c, (values

  -- Emblems. Exactly one of these is selected on every design.

  ('negative', 'vvs-emblems-banned', 'No weapons', 'banned', null, null, null,
   'No weapons of any kind.'),

  ('negative', 'vvs-emblems-symbolic', 'Symbolic emblems only', 'symbolic', null, null, null,
   'A dagger, skull or length of barbed wire may appear only as a symbolic '
   'tattoo-flash emblem standing on its own — never held, never aimed, never '
   'touching a figure.'),

  -- Four single main lettering styles, so the combined names can be split.

  ('lettering', 'vvs-let-high-contrast-serif', 'High-Contrast Serif', null,
   'High-Contrast Serif', null, null,
   'The words are set in a high-contrast display serif — thin hairlines against '
   'heavy stems, sharp unbracketed serifs — at large size with generous, even '
   'letterspacing.'),

  ('lettering', 'vvs-let-serif-display', 'Serif Display', null,
   'Serif Display', null, null,
   'The words are set in a large display serif with strong bracketed serifs and '
   'moderate contrast, set tight and confident so the line reads as one shape.'),

  ('lettering', 'vvs-let-distressed-block-caps', 'Distressed Block Caps', null,
   'Distressed Block Caps', null, null,
   'The words are set in heavy block capitals whose fill breaks into fine speckle '
   'and worn gaps, as though printed and washed many times, while every letter '
   'stays fully legible.'),

  ('lettering', 'vvs-let-big-top-display', 'Big Top Display', null,
   'Big Top Display', null, null,
   'The words are set in circus-poster display lettering — tall condensed capitals '
   'with heavy slab terminals on an arched or banner-set baseline.'),

  -- Lettering accents. Strikeout is deliberately absent: striking a word
  -- through changes what the phrase says, so it stays inside its own combined
  -- style, chosen on purpose, rather than being added to any phrase.

  ('lettering_accent', 'vvs-acc-script', 'Script', null, null, 'Script', null,
   'Accent lettering: one short word or line of the phrase — never the whole '
   'phrase, and spelled exactly as written — is set in a connected script at a '
   'larger scale and a slight angle, crossing the main lettering. The main '
   'lettering carries everything else.'),

  ('lettering_accent', 'vvs-acc-handwritten-script', 'Handwritten Script', null, null,
   'Handwritten Script', null,
   'Accent lettering: one short word or line of the phrase — never the whole '
   'phrase, and spelled exactly as written — is set in loose handwritten script, '
   'smaller and at a jaunty angle, tucked into a gap the main lettering leaves. '
   'The main lettering carries everything else.'),

  ('lettering_accent', 'vvs-acc-brush-script', 'Brush Script', null, null,
   'Brush Script', null,
   'Accent lettering: one short word or line of the phrase — never the whole '
   'phrase, and spelled exactly as written — is set in a brush script that swells '
   'on the pull and tapers at the lift, sweeping across the main lettering. The '
   'main lettering carries everything else.'),

  ('lettering_accent', 'vvs-acc-italic', 'Italic', null, null, 'Italic', null,
   'Accent lettering: one short word of the phrase, spelled exactly as written, '
   'is set in a steeply sloped italic matched to the main lettering''s weight, so '
   'the slope alone carries the emphasis. The main lettering carries everything '
   'else.'),

  ('lettering_accent', 'vvs-acc-technical', 'Technical', null, null, 'Technical', null,
   'Accent lettering: one short word or line of the phrase — never the whole '
   'phrase, and spelled exactly as written — is set in small, widely spaced '
   'monospaced capitals with a tick mark or hairline rule beside it, like an '
   'annotation on a drawing. The main lettering carries everything else.'),

  ('lettering_accent', 'vvs-acc-small-sans', 'Small Sans', null, null, 'Small Sans', null,
   'Accent lettering: one short line of the phrase — never the whole phrase, and '
   'spelled exactly as written — is set in small sans capitals with very wide '
   'letterspacing above or beneath the main lettering, a quiet counterpoint to '
   'it. The main lettering carries everything else.'),

  ('lettering_accent', 'vvs-acc-condensed-sans', 'Condensed Sans', null, null,
   'Condensed Sans', null,
   'Accent lettering: one short line of the phrase — never the whole phrase, and '
   'spelled exactly as written — is set in a plain, tall condensed sans, compact '
   'and upright, as a secondary line. The main lettering carries everything else.'),

  ('lettering_accent', 'vvs-acc-label-maker', 'Label-Maker', null, null,
   'Label-Maker', null,
   'Accent lettering: one or two short words of the phrase, spelled exactly as '
   'written, are set in tight monospaced capitals reversed out of a solid '
   'rounded-corner bar, as though punched from a label maker. The main lettering '
   'carries everything else.'),

  ('lettering_accent', 'vvs-acc-hand-marker', 'Hand-Marker', null, null,
   'Hand-Marker', null,
   'Accent lettering: one short word or line of the phrase — never the whole '
   'phrase, and spelled exactly as written — is drawn fast with a marker, a little '
   'irregular, as though added by hand after the main lettering was set. The main '
   'lettering carries everything else.'),

  -- Art-style secondaries, one per base style. Motifs and detail only.

  ('art_accent', 'vvs-sec-blueprint', 'Architectural / Blueprint Editorial', null, null, null,
   'Architectural / Blueprint Editorial',
   'Secondary influence, blueprint: hairline measure lines, section marks and '
   'small numbered callouts annotate the main forms. These are added as detail; '
   'the main style keeps its own technique.'),

  ('art_accent', 'vvs-sec-art-deco', 'Art Deco Editorial', null, null, null,
   'Art Deco Editorial',
   'Secondary influence, Art Deco: stepped tiers, fanned sunburst repeats and fine '
   'parallel rules frame the central forms. These are added as detail; the main '
   'style keeps its own technique.'),

  ('art_accent', 'vvs-sec-bold-minimal', 'Bold Minimal', null, null, null,
   'Bold Minimal',
   'Secondary influence, bold minimal: one element is reduced to a large, clean '
   'geometric silhouette that anchors the rest. The main style keeps its own '
   'technique everywhere else.'),

  ('art_accent', 'vvs-sec-botanical-editorial', 'Botanical Editorial Illustration', null, null, null,
   'Botanical Editorial Illustration',
   'Secondary influence, botanical: leaves, stems and blooms drawn as clean filled '
   'silhouettes with a few interior veins run as a border, arch or sprig. These '
   'are added as detail; the main style keeps its own technique.'),

  ('art_accent', 'vvs-sec-celestial', 'Celestial', null, null, null,
   'Celestial',
   'Secondary influence, celestial: crescents, small stars and fine radiating '
   'lines are set around the main forms with deliberate symmetry. These are added '
   'as detail; the main style keeps its own technique.'),

  ('art_accent', 'vvs-sec-chrome-y2k', 'Chrome Y2K', null, null, null,
   'Chrome Y2K',
   'Secondary influence, Y2K chrome: one or two forms are rendered as swollen '
   'liquid chrome in hard-edged bands of light and dark, with small four-point '
   'sparkle stars. The main style keeps its own technique everywhere else.'),

  ('art_accent', 'vvs-sec-collage-zine', 'Collage Zine Cutout', null, null, null,
   'Collage Zine Cutout',
   'Secondary influence, zine collage: a few elements look torn or scissor-cut and '
   'are layered slightly out of square. These are added as detail; the main style '
   'keeps its own technique.'),

  ('art_accent', 'vvs-sec-collegiate', 'Collegiate / Varsity Emblem', null, null, null,
   'Collegiate / Varsity Emblem',
   'Secondary influence, varsity: an arched banner, block numerals or a layered '
   'offset outline around one key element. These are added as detail; the main '
   'style keeps its own technique.'),

  ('art_accent', 'vvs-sec-editorial-scene', 'Editorial Scene', null, null, null,
   'Editorial Scene',
   'Secondary influence, editorial scene: a small staged moment — a figure or '
   'object caught mid-action — is set within the design. The main style keeps its '
   'own technique.'),

  ('art_accent', 'vvs-sec-editorial-typographic', 'Editorial Typographic', null, null, null,
   'Editorial Typographic',
   'Secondary influence, editorial typography: a few precise hairline rules and '
   'small refined details are placed around the phrase. These are added as detail; '
   'the main style keeps its own technique.'),

  ('art_accent', 'vvs-sec-emotional-illustrative', 'Emotional Illustrative', null, null, null,
   'Emotional Illustrative',
   'Secondary influence, emotional illustration: a small warm illustrated figure '
   'or object, its solid shapes softened by fine interior linework. The main style '
   'keeps its own technique everywhere else.'),

  ('art_accent', 'vvs-sec-feminine', 'Feminine', null, null, null,
   'Feminine',
   'Secondary influence, feminine: fine hairline flourishes, rounded corners and '
   'one warm metallic note. These are added as detail; the main style keeps its '
   'own technique.'),

  ('art_accent', 'vvs-sec-geometric-abstract', 'Geometric Abstract', null, null, null,
   'Geometric Abstract',
   'Secondary influence, geometric: a repeating pattern of true circles and angled '
   'bars, aligned to one grid, fills a frame or background shape. The main style '
   'keeps its own technique everywhere else.'),

  ('art_accent', 'vvs-sec-doodle', 'Hand-Drawn Doodle', null, null, null,
   'Hand-Drawn Doodle',
   'Secondary influence, doodle: small loose marker doodles — stars, arrows, '
   'squiggles — gather around the main group. These are added as detail; the main '
   'style keeps its own technique.'),

  ('art_accent', 'vvs-sec-luxury-editorial', 'Luxury Editorial Typography', null, null, null,
   'Luxury Editorial Typography',
   'Secondary influence, luxury editorial: one hairline rule, a small refined mark '
   'and extra breathing room around the phrase. The main style keeps its own '
   'technique.'),

  ('art_accent', 'vvs-sec-minimal-symbolic', 'Minimal Symbolic', null, null, null,
   'Minimal Symbolic',
   'Secondary influence, minimal symbol: one reduced symbol, built from the fewest '
   'shapes that carry the idea, serves as a focal mark. The main style keeps its '
   'own technique everywhere else.'),

  ('art_accent', 'vvs-sec-grunge-halftone', 'Modern Grunge Halftone', null, null, null,
   'Modern Grunge Halftone',
   'Secondary influence, grunge halftone: coarse halftone dot fields sit inside a '
   'few of the larger shapes, their edges slightly broken. The main style keeps '
   'its own technique everywhere else.'),

  ('art_accent', 'vvs-sec-script-statement', 'Modern Script Statement', null, null, null,
   'Modern Script Statement',
   'Secondary influence, modern script: a single fluid swash or underline stroke '
   'sweeps through the design. The main style keeps its own technique.'),

  ('art_accent', 'vvs-sec-neo-brutalist', 'Neo-Brutalist Grid', null, null, null,
   'Neo-Brutalist Grid',
   'Secondary influence, neo-brutalist: one heavy rule and a hard rectangular '
   'field of saturated colour cut through the design. The main style keeps its own '
   'technique everywhere else.'),

  ('art_accent', 'vvs-sec-oversized', 'Oversized Condensed Statement', null, null, null,
   'Oversized Condensed Statement',
   'Secondary influence, oversized: one element is pushed to oversized scale and '
   'cropped by the edge of the design. The main style keeps its own technique.'),

  ('art_accent', 'vvs-sec-photoreal', 'Photoreal Composite', null, null, null,
   'Photoreal Composite',
   'Secondary influence, photo composite: one small photographic element is cut '
   'cleanly to its own silhouette and set among the drawn forms. The main style '
   'keeps its own technique everywhere else.'),

  ('art_accent', 'vvs-sec-retro-comic', 'Retro Comic', null, null, null,
   'Retro Comic',
   'Secondary influence, comic: action bursts, speed lines and halftone dots drawn '
   'as solid shapes. These are added as detail; the main style keeps its own '
   'technique.'),

  ('art_accent', 'vvs-sec-retro-diner', 'Retro Diner / Comic', null, null, null,
   'Retro Diner / Comic',
   'Secondary influence, retro diner: small stamped emblems, starbursts and a '
   'rounded mid-century sign shape. These are added as detail; the main style '
   'keeps its own technique.'),

  ('art_accent', 'vvs-sec-retro-groovy', 'Retro Groovy', null, null, null,
   'Retro Groovy',
   'Secondary influence, groovy: wavy bands, a rounded sunburst and soft 70s '
   'curves run behind the main forms. These are added as detail; the main style '
   'keeps its own technique.'),

  ('art_accent', 'vvs-sec-soft-botanical', 'Soft Botanical Line Art', null, null, null,
   'Soft Botanical Line Art',
   'Secondary influence, line botanical: a single continuous-line sprig with open '
   'interiors curls around the group. This is added as detail; the main style '
   'keeps its own technique.'),

  ('art_accent', 'vvs-sec-split-scene', 'Split-Scene Editorial Illustration', null, null, null,
   'Split-Scene Editorial Illustration',
   'Secondary influence, split scene: one clean division splits a key element into '
   'two contrasting halves. The main style keeps its own technique.'),

  ('art_accent', 'vvs-sec-streetwear', 'Streetwear Graffiti', null, null, null,
   'Streetwear Graffiti',
   'Secondary influence, streetwear: torn-edge blocks and overprinted layers sit '
   'behind the main group. These are added as detail; the main style keeps its own '
   'technique.'),

  ('art_accent', 'vvs-sec-tattoo', 'Tattoo Linework', null, null, null,
   'Tattoo Linework',
   'Secondary influence, tattoo flash: confident black contours of varied weight '
   'and dense parallel-line shading on the key forms, with flash motifs such as a '
   'rose, a swallow or a banner. The main style keeps its own technique '
   'everywhere else.'),

  ('art_accent', 'vvs-sec-urban-graffiti', 'Urban graffiti', null, null, null,
   'Urban graffiti',
   'Secondary influence, aerosol: overspray halos, drips and scattered paint '
   'flecks at the edges of the main shapes. These are added as detail; the main '
   'style keeps its own technique.'),

  ('art_accent', 'vvs-sec-vintage-badge', 'Vintage Badge', null, null, null,
   'Vintage Badge',
   'Secondary influence, vintage badge: arched banners and fine washed speckle in '
   'the fill, as on a well-worn patch. These are added as detail; the main style '
   'keeps its own technique.'),

  ('art_accent', 'vvs-sec-vintage-poster', 'Vintage Poster', null, null, null,
   'Vintage Poster',
   'Secondary influence, vintage poster: a plain rule frames the whole and a faint '
   'press texture shows where inks overlap. These are added as detail; the main '
   'style keeps its own technique.')

) as v(kind, slug, label, emblem_rule, lettering_style, lettering_accent,
       art_accent, body)
where c.code = 'vv-styles';

-- ------------------------------------------------------------------- wiring
--
-- Secondary art directly after the base style it modifies (10), accent
-- lettering directly after the main lettering (34), emblems directly after
-- the exclusions (80). 091's lesson: a block with no template_blocks row is
-- never selected, and nothing reports it.

insert into template_blocks (template_id, block_id, position)
select t.id, b.id,
       case b.kind
         when 'art_accent'       then 11
         when 'lettering'        then 34
         when 'lettering_accent' then 35
         else 81
       end
from prompt_templates t, prompt_blocks b
where t.slug = 'vvs-front-print'
  and b.slug in (
    'vvs-emblems-banned', 'vvs-emblems-symbolic',
    'vvs-let-high-contrast-serif', 'vvs-let-serif-display',
    'vvs-let-distressed-block-caps', 'vvs-let-big-top-display'
  )
   or (t.slug = 'vvs-front-print'
       and b.kind in ('art_accent', 'lettering_accent'));

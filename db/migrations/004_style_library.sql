-- 004_style_library.sql
-- Stage B — the Style Library, rebuilt from the reference images.
--
-- The Stage 1 blocks are retired rather than tuned. Measured against the
-- references they were inverted on almost every point: "clean flat vector",
-- "bold uniform black", "simple interior detail only", "generous negative
-- space", "no textured strokes". Three rounds of rewording could not fix that,
-- because the disagreement was with the description, not the wording (§2.2).
--
-- Structure follows D39. Style blocks say HOW a page is drawn and come from the
-- references. Subject and environment say WHAT is in it and come from the item's
-- own brief. Props never appear in a style block.
--
-- Art style (D26) is a second axis crossing page type (D17), so base_style
-- blocks carry an art_style tag and the engine selects one at build time.
-- Blocks with art_style null apply to every art style.

begin;

alter table prompt_blocks
  add column art_style text null,
  add column page_type text null;

comment on column prompt_blocks.art_style is
  'When set, this block is only used if the job selects this art style. '
  'Null means it applies to every art style.';
comment on column prompt_blocks.page_type is
  'When set, this block is only used for this page type. Null means any.';

create index prompt_blocks_art_style_idx on prompt_blocks(art_style);

-- Retire the Stage 1 library. The template survives; its blocks do not.
delete from template_blocks;
update prompt_blocks set is_active = false where slug like 'cb-%';


-- Universal coloring-book blocks ---------------------------------------------
-- True of every Healing Seasons page regardless of art style or page type.

insert into prompt_blocks (kind, slug, label, body_text, category_id, art_style, page_type) values
('print_req', 'hs-line-quality', 'Line quality',
 'Line weight varies deliberately: confident heavy contours on figures and foreground objects, finer lines for background and distant detail. Every shape is closed so it can be colored cleanly.',
 (select id from categories where code='coloring-books'), null, null),

('print_req', 'hs-texture-as-pattern', 'Texture as pattern',
 'Texture is drawn as pattern rather than shading — knit stitches, wood grain, woven rug, brick, foliage veins, hair rendered as dense drawn curl. Never hatching, stippling or grey fill.',
 (select id from categories where code='coloring-books'), null, null),

('output', 'hs-output', 'Output',
 'Pure black line work on white, printed at full page. No border or frame. Keep key subject matter clear of the outer edge.',
 (select id from categories where code='coloring-books'), null, null);


-- Art style blocks -----------------------------------------------------------
-- One base_style per art style. Exactly one is selected per job.

insert into prompt_blocks (kind, slug, label, body_text, category_id, art_style, page_type) values
('base_style', 'hs-style-editorial-scene', 'Editorial Scene',
 'A detailed black and white line illustration for an adult coloring book, drawn as a full environment with the scene continuing to every edge of the page. Dense editorial detail throughout, with interior and background surfaces carrying their own drawn pattern.',
 (select id from categories where code='coloring-books'), 'Editorial Scene', null),

('base_style', 'hs-style-zentangle', 'Zentangle Pattern',
 'A black and white line illustration for an adult coloring book built entirely from dense abstract pattern — mandala petals, paisley, scallops, spirals, dotted fills — tiled edge to edge with no empty ground.',
 (select id from categories where code='coloring-books'), 'Zentangle Pattern', null),

('base_style', 'hs-style-botanical', 'Botanical Line',
 'A black and white line illustration for an adult coloring book built from flowers, foliage and vines at a comfortable middle density, with open areas between the growth that are easy to color.',
 (select id from categories where code='coloring-books'), 'Botanical Line', null),

('base_style', 'hs-style-geometric', 'Geometric Abstract',
 'A black and white line illustration for an adult coloring book built from geometric structure — radiating rays, faceted wedges, concentric arcs — dividing the page into large clean areas.',
 (select id from categories where code='coloring-books'), 'Geometric Abstract', null),

('base_style', 'hs-style-bold-minimal', 'Bold Minimal',
 'A black and white line illustration for an adult coloring book at large scale with heavy confident outlines, few elements and generous empty space.',
 (select id from categories where code='coloring-books'), 'Bold Minimal', null),

('base_style', 'hs-style-celestial', 'Celestial',
 'A black and white line illustration for an adult coloring book in a celestial register — moon phases, stars, rays, drifting cloud and dawn light — drawn as clean outlined shapes.',
 (select id from categories where code='coloring-books'), 'Celestial', null),

('base_style', 'hs-style-hand-drawn-doodle', 'Hand-Drawn Doodle',
 'A black and white line illustration for an adult coloring book in a loose hand-drawn doodle register, playful and slightly irregular, drawn as if by marker.',
 (select id from categories where code='coloring-books'), 'Hand-Drawn Doodle', null);


-- Subject and environment ----------------------------------------------------
-- D39: these carry the item's own brief. Dropped automatically when empty.

insert into prompt_blocks (kind, slug, label, body_text, category_id, art_style, page_type) values
('subject', 'hs-subject', 'Subject',
 '{{subject}}',
 (select id from categories where code='coloring-books'), null, null),

('subject', 'hs-figure-rendering', 'Figure rendering',
 'Figures are drawn specifically and warmly, with real facial features and natural hair texture rendered as drawn pattern.',
 (select id from categories where code='coloring-books'), null, null),

('environment', 'hs-environment', 'Environment',
 'The setting is {{environment}}.',
 (select id from categories where code='coloring-books'), null, null),

('brand_rule', 'hs-brand-mark', 'In-scene name drop',
 'Somewhere in the scene, small and incidental, an object carries the lettering "{{brand_mark}}".',
 (select id from categories where code='coloring-books'), null, null);


-- Page-type composition blocks -----------------------------------------------
-- D17: page type is the template unit. Half of these have no human figure.

insert into prompt_blocks (kind, slug, label, body_text, category_id, art_style, page_type) values
('composition', 'hs-comp-solo-portrait', 'Solo portrait composition',
 'One person is the subject, placed within a full setting that surrounds them and fills the page.',
 (select id from categories where code='coloring-books'), null, 'Solo portrait'),

('composition', 'hs-comp-community-scene', 'Community scene composition',
 'Several people share the space and interact with each other, arranged across the page within a full setting.',
 (select id from categories where code='coloring-books'), null, 'Community scene'),

('composition', 'hs-comp-quote-page', 'Quote page composition',
 'No people. Decorative arrangement around a clear open area at the centre of the page, roughly half the page height, left completely empty. Draw no letters, words or writing anywhere.',
 (select id from categories where code='coloring-books'), null, 'Quote page'),

('composition', 'hs-comp-symbol-page', 'Symbol page composition',
 'No people and no scene. A cluster of related symbolic objects arranged as a single centred group.',
 (select id from categories where code='coloring-books'), null, 'Symbol page'),

('composition', 'hs-comp-decorative-page', 'Decorative page composition',
 'No people. An arrangement of pattern and objects across the whole page, ornamental rather than narrative.',
 (select id from categories where code='coloring-books'), null, 'Decorative page'),

('composition', 'hs-comp-environment-page', 'Environment page composition',
 'No people. The place itself is the subject, drawn as a full setting filling the page.',
 (select id from categories where code='coloring-books'), null, 'Environment page');


-- Templates: one per page type (D17) -----------------------------------------

insert into prompt_templates (category_id, page_type, name, slug, description,
                              variables_json, default_settings)
select (select id from categories where code='coloring-books'),
       t.page_type, t.name, t.slug, t.description,
       '[{"name":"subject","label":"Subject","type":"textarea","required":true,
          "placeholder":"From the item brief, e.g. Woman journaling by a rainy window with plants."},
         {"name":"environment","label":"Setting","type":"text","required":false},
         {"name":"brand_mark","label":"In-scene name drop","type":"text","required":false}]'::jsonb,
       '{"size":"1024x1536","quality":"high","n":2}'::jsonb
  from (values
    ('Solo portrait',    'Healing Seasons — Solo Portrait',    'hs-solo-portrait',    'One figure in a full setting.'),
    ('Community scene',  'Healing Seasons — Community Scene',  'hs-community-scene',  'Several figures sharing a space.'),
    ('Quote page',       'Healing Seasons — Quote Page',       'hs-quote-page',       'Decorative border around reserved empty centre. Text is overlaid later (D23).'),
    ('Symbol page',      'Healing Seasons — Symbol Page',      'hs-symbol-page',      'Motif cluster, no figures.'),
    ('Decorative page',  'Healing Seasons — Decorative Page',  'hs-decorative-page',  'Pattern and objects, no figures.'),
    ('Environment page', 'Healing Seasons — Environment Page', 'hs-environment-page', 'Place as subject, no figures.')
  ) as t(page_type, name, slug, description);


-- Attach blocks in order. Every art-style variant is attached; the engine
-- selects one at build time from the job's chosen art style.
insert into template_blocks (template_id, block_id, position)
select t.id, b.id, b.position
  from prompt_templates t
  join (
    select id, slug, page_type, art_style,
           case kind
             when 'base_style'   then 10
             when 'composition'  then 20
             when 'subject'      then 30
             when 'environment'  then 40
             when 'brand_rule'   then 50
             when 'print_req'    then 60
             when 'output'       then 70
           end
           + case when slug = 'hs-figure-rendering' then 1 else 0 end
           + case when slug = 'hs-texture-as-pattern' then 1 else 0 end as position
      from prompt_blocks
     where is_active and slug like 'hs-%'
  ) b on b.page_type is null or b.page_type = t.page_type
 where t.slug like 'hs-%'
   -- Pages with no people do not need the figure-rendering block.
   and not (b.slug = 'hs-figure-rendering'
            and t.page_type in ('Quote page','Symbol page','Decorative page','Environment page'));

commit;

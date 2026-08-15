-- seed.sql
-- Safe to re-run: every insert is guarded with ON CONFLICT DO NOTHING.

begin;

-- Brands ---------------------------------------------------------------------
-- Real business units only. Coloring books and social content are NOT brands —
-- they are job types (see D3 in docs/review-and-recommendations.md).
insert into brands (slug, name, description) values
  ('esoh-creations', 'Esoh Creations', 'Parent business. Coloring books, poetry, print and digital products.'),
  ('vv-styles',      'VV-Styles',      'Apparel and fashion line.')
on conflict (slug) do nothing;


-- Job types ------------------------------------------------------------------
insert into job_types (code, label, description) values
  ('coloring_page', 'Coloring Page',  'Full-page black and white line art for adult coloring books.'),
  ('social_post',   'Social Post',    'Square or vertical graphics for social channels.'),
  ('print_design',  'Print Design',   'Artwork destined for apparel or physical product printing.'),
  ('brand_concept', 'Brand Concept',  'Exploratory concept and mood imagery.')
on conflict (code) do nothing;


-- Prompt blocks — the Style Library -------------------------------------------
-- {{variable}} slots are filled from the New Job form at generation time.
insert into prompt_blocks (kind, slug, label, body_text) values

  ('base_style', 'cb-base', 'Coloring Book — Base Style',
   'A clean flat vector-style black and white line art illustration drawn for an adult coloring book page. The artwork fills the whole image edge to edge.'),

  ('subject', 'cb-subject', 'Coloring Book — Subject',
   'The subject is {{subject}}. The emotional tone of the scene is {{mood}}.'),

  ('composition', 'cb-composition', 'Coloring Book — Full Page Portrait',
   'Full-page portrait composition. The entire subject is visible inside the frame and is not cropped by any edge of the image. The subject is centered and clearly separated from the background, with a clear margin of empty white space around the outside of the composition. Balanced use of the full page with generous negative space.'),

  ('environment', 'cb-environment', 'Coloring Book — Environment',
   'The surrounding environment is {{environment}}.'),

  ('print_req', 'cb-linework', 'Coloring Book — Line Work Rules',
   'Every shape is enclosed by one smooth continuous vector path of bold uniform black, thick enough to print and color cleanly. Trees, grass, leaves and petals are drawn as simple closed outlined shapes. Large open uncluttered areas that are easy to color inside. Simple interior detail only. Hair is drawn as a few large outlined flowing sections, left white and open inside.'),

  ('output', 'cb-output', 'Coloring Book — Output',
   'Bold black vector outlines on a plain white background. Every enclosed area is left empty white so it can be colored in by hand. The illustration runs to all four edges of the image.'),

  -- Kept deliberately short. A long "do not" list performs WORSE with image
  -- models: naming a thing makes it more likely to appear. The border in the
  -- second test run was invited by the words "borders or page frames" in the
  -- previous version of this block. Say what you want, not what you fear.
  ('negative', 'cb-negative', 'Coloring Book — Restrictions',
   'Flat pure black and white only, with no grey, no shading, no gradients and no filled-in black areas. No pencil, sketch, hatched or textured strokes. No photorealism and no text.')

-- Re-running the seed refreshes block text. The Style Library is meant to be
-- tuned repeatedly — a style fix should be one edit here plus `npm run db:seed`,
-- never a code change.
on conflict (slug) do update set
  kind      = excluded.kind,
  label     = excluded.label,
  body_text = excluded.body_text;


-- Template: Adult Coloring — Clean Line ---------------------------------------
insert into prompt_templates (brand_id, job_type_id, name, slug, description, variables_json, default_settings)
select
  null,                                        -- global template
  (select id from job_types where code = 'coloring_page'),
  'Adult Coloring — Clean Line',
  'adult-coloring-clean-line',
  'Baseline full-page coloring illustration. Large open areas, no shading.',
  '[
    {"name":"subject","label":"Subject","type":"textarea","required":true,
     "placeholder":"an African-American woman journaling under a tree"},
    {"name":"mood","label":"Mood","type":"select","required":true,
     "options":["peaceful","hopeful","joyful","reflective","determined","celebratory"]},
    {"name":"environment","label":"Environment","type":"textarea","required":false,
     "placeholder":"a summer oak, wildflowers and butterflies"}
  ]'::jsonb,
  '{"size":"1024x1536","quality":"medium","n":4}'::jsonb
where not exists (
  select 1 from prompt_templates where slug = 'adult-coloring-clean-line'
);


-- Compose the template from ordered blocks ------------------------------------
insert into template_blocks (template_id, block_id, position)
select t.id, b.id, v.position
from prompt_templates t
join (values
    ('cb-base',        10),
    ('cb-subject',     20),
    ('cb-composition', 30),
    ('cb-environment', 40),
    ('cb-linework',    50),
    ('cb-output',      60),
    ('cb-negative',    70)
  ) as v(slug, position) on true
join prompt_blocks b on b.slug = v.slug
where t.slug = 'adult-coloring-clean-line'
on conflict (template_id, block_id) do nothing;


-- A starting project ----------------------------------------------------------
insert into projects (brand_id, name, slug, description)
select id, 'Sandbox', 'sandbox', 'Scratch space for testing generations.'
from brands where slug = 'esoh-creations'
on conflict (brand_id, slug) do nothing;

commit;

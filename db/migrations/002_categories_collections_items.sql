-- 002_categories_collections_items.sql
-- Stage A — restructure to the model in docs/direction.md §5
--
--   D3   ventures + job_types collapse into one `categories` table
--   D17  page type is the template unit
--   D18  ethnicity is production data, never a style setting
--   D26  art style is a first-class dimension
--   D27  background density is per-item
--   D28  lettering style applies to anything carrying words
--   D29  output sizes are fixed per category; no landscape
--   D31  third-party scans are study material, never model input
--
-- Existing generation_jobs and generated_assets are backfilled before the old
-- columns are dropped, so no generation history is lost.

begin;


-- 1. categories --------------------------------------------------------------
-- What kind of output is being made. Carries the size presets from §5.1:
-- output_* is what gpt-image-1 is asked for, deliver_* is the finished file.
create table categories (
  id             uuid        primary key default gen_random_uuid(),
  code           text        not null unique,
  label          text        not null,
  description    text        null,

  output_width   integer     not null,
  output_height  integer     not null,
  deliver_width  integer     null,
  deliver_height integer     null,
  deliver_note   text        null,
  transparent    boolean     not null default false,

  is_active      boolean     not null default true,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),

  -- D29: gpt-image-1 offers exactly three shapes and landscape is never used.
  constraint categories_output_size_check check (
    (output_width, output_height) in ((1024,1024), (1024,1536))
  )
);
create trigger categories_updated_at before update on categories
  for each row execute function set_updated_at();


-- 2. collections -------------------------------------------------------------
-- A named body of work: one book, one apparel drop, one campaign.
create table collections (
  id          uuid        primary key default gen_random_uuid(),
  category_id uuid        not null references categories(id) on delete restrict,
  slug        text        not null,
  name        text        not null,
  description text        null,
  status      text        not null default 'active',
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),

  constraint collections_status_check check (status in ('active','archived')),
  constraint collections_slug_unique  unique (category_id, slug)
);
create index collections_category_id_idx on collections(category_id);
create trigger collections_updated_at before update on collections
  for each row execute function set_updated_at();


-- 3. items -------------------------------------------------------------------
-- One planned unit of work — one spreadsheet row. An item may have many jobs.
--
-- Both source spreadsheets are living documents, so `ref` carries the key from
-- the sheet (tracker title, or VVS-0001) and `source_row` keeps the original
-- row verbatim. Re-import updates in place instead of duplicating.
create table items (
  id                 uuid        primary key default gen_random_uuid(),
  collection_id      uuid        not null references collections(id) on delete restrict,
  category_id        uuid        not null references categories(id)  on delete restrict,

  ref                text        not null,
  title              text        not null,
  brief              text        null,

  -- coloring-book production data (D18 — data, never style)
  page_type          text        null,
  ethnicity_line     text        null,
  season             text        null,

  -- style dimensions (D26, D27, D28)
  art_style          text        null,
  lettering_style    text        null,
  background_density text        null,

  -- D23: overlaid after generation as outlined vector type, never drawn
  quote_text         text        null,
  quote_lang         text        null,

  color_direction    text        null,
  product_placement  text        null,
  visual_elements    text        null,

  priority           text        null,
  status             text        not null default 'idea',
  review_flag        text        null,
  notes              text        null,

  source_row         jsonb       not null default '{}'::jsonb,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now(),

  constraint items_priority_check check (priority is null or priority in ('High','Medium','Low')),
  constraint items_status_check check (status in (
    'idea','brief_ready','prompt_ready','generated','revision_needed',
    'approved','mockup_ready','launched','archived'
  )),
  constraint items_density_check check (
    background_density is null or background_density in ('Open','Medium','Dense')
  ),
  constraint items_ref_unique unique (collection_id, ref)
);
create index items_collection_id_idx on items(collection_id);
create index items_category_id_idx   on items(category_id);
create index items_page_type_idx     on items(page_type);
create index items_art_style_idx     on items(art_style);
create index items_priority_idx      on items(priority);
create index items_status_idx        on items(status);
create index items_season_idx        on items(season);
create trigger items_updated_at before update on items
  for each row execute function set_updated_at();


-- 4. reference_images --------------------------------------------------------
-- D20 style exemplars and D22 promoted pages.
--
-- usable_as_input defaults false. D31: the watermarked third-party scans inform
-- how templates are written but must never be sent to the model as image input.
-- Only our own approved work gets flipped to true.
create table reference_images (
  id              uuid        primary key default gen_random_uuid(),
  category_id     uuid        null references categories(id)       on delete restrict,
  item_id         uuid        null references items(id)            on delete set null,
  asset_id        uuid        null references generated_assets(id) on delete set null,

  label           text        not null,
  storage_path    text        not null,
  kind            text        not null default 'study',
  page_type       text        null,
  art_style       text        null,
  usable_as_input boolean     not null default false,
  notes           text        null,

  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),

  constraint reference_images_kind_check check (kind in ('study','exemplar'))
);
create index reference_images_category_id_idx on reference_images(category_id);
create index reference_images_item_id_idx     on reference_images(item_id);
create index reference_images_usable_idx      on reference_images(usable_as_input);
create trigger reference_images_updated_at before update on reference_images
  for each row execute function set_updated_at();


-- 5. seed the four categories ------------------------------------------------
insert into categories (code, label, description, output_width, output_height,
                        deliver_width, deliver_height, deliver_note, transparent)
values
  ('coloring-books', 'Coloring Books',
   'Line-art pages for the Healing Seasons series.',
   1024, 1536, 2550, 3300,
   'Pad to 8.5x11 at 300 DPI. Never crop — the padding becomes the KDP margin (D30).', false),
  ('vv-styles', 'VV-Styles',
   'Apparel graphics. Transparent, no enclosing shape (D34).',
   1024, 1024, 4500, 5400,
   'Upscale to 15x18in at 300 DPI for DTF.', true),
  ('social-content', 'Social Content',
   'Feed, Pinterest and story graphics.',
   1024, 1024, null, null,
   'Square for feed. Use 1024x1536 for Pinterest; pad to 9:16 for stories.', false),
  ('print-designs', 'Print Designs',
   'Other printed matter. Not yet specified.',
   1024, 1536, null, null, null, false)
on conflict (code) do nothing;


-- 6. rewire the prompt engine ------------------------------------------------
alter table prompt_blocks
  add column category_id uuid null references categories(id) on delete restrict;
create index prompt_blocks_category_id_idx on prompt_blocks(category_id);

alter table prompt_templates
  add column category_id uuid null references categories(id) on delete restrict,
  add column page_type   text null;                      -- D17
create index prompt_templates_category_id_idx on prompt_templates(category_id);

update prompt_blocks    set category_id = (select id from categories where code = 'coloring-books');
update prompt_templates set category_id = (select id from categories where code = 'coloring-books');

alter table prompt_templates alter column category_id set not null;
alter table prompt_templates drop constraint prompt_templates_slug_unique;
alter table prompt_templates add  constraint prompt_templates_slug_unique
  unique (category_id, page_type, slug);


-- 7. rewire jobs and assets, backfilling before anything is dropped ----------
alter table generation_jobs
  add column category_id   uuid null references categories(id)  on delete restrict,
  add column collection_id uuid null references collections(id) on delete restrict,
  add column item_id       uuid null references items(id)       on delete set null;

alter table generated_assets
  add column category_id   uuid null references categories(id)  on delete restrict,
  add column collection_id uuid null references collections(id) on delete restrict,
  add column item_id       uuid null references items(id)       on delete set null;

-- Every existing job is a coloring_page test from Stage 1.
update generation_jobs g
   set category_id = c.id
  from categories c, job_types j
 where j.id = g.job_type_id
   and c.code = case j.code
                  when 'coloring_page' then 'coloring-books'
                  when 'social_post'   then 'social-content'
                  when 'print_design'  then 'print-designs'
                  else 'coloring-books'
                end;

update generated_assets a
   set category_id = g.category_id
  from generation_jobs g
 where g.id = a.generation_job_id;

alter table generation_jobs   alter column category_id set not null;
alter table generated_assets  alter column category_id set not null;

create index generation_jobs_category_id_idx    on generation_jobs(category_id);
create index generation_jobs_collection_id_idx  on generation_jobs(collection_id);
create index generation_jobs_item_id_idx        on generation_jobs(item_id);
create index generated_assets_category_id_idx   on generated_assets(category_id);
create index generated_assets_collection_id_idx on generated_assets(collection_id);
create index generated_assets_item_id_idx       on generated_assets(item_id);


-- 8. retire brands, job_types and projects (D3) ------------------------------
alter table generation_jobs
  drop column brand_id, drop column project_id, drop column job_type_id;
alter table generated_assets
  drop column brand_id, drop column project_id;
alter table prompt_blocks    drop column brand_id;
alter table prompt_templates drop column brand_id, drop column job_type_id;

drop table projects;
drop table job_types;
drop table brands;

commit;

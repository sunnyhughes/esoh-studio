-- 001_init.sql
-- Esoh Creations AI Image Studio — Stage 1 schema
--
-- Follows the conventions in docs/schema-notes.md:
--   uuid primary keys, timestamptz everywhere, text + check constraints
--   instead of Postgres enums, explicit indexes on foreign keys.
--
-- Per docs/review-and-recommendations.md:
--   D3 — business units are `brands`, not `ventures`
--   D2 — prompts compose from `prompt_blocks`, not a flat string
--   D8 — no `users` table yet (single operator)
--   D9 — jobs record the resolved prompt, model, seed, params and cost

begin;

-- gen_random_uuid() is built into Postgres 13+; no extension required.

create or replace function set_updated_at() returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;


-- 1. brands ------------------------------------------------------------------
-- A real business unit with its own identity. NOT a product line or format.
create table brands (
  id          uuid primary key default gen_random_uuid(),
  slug        text        not null unique,
  name        text        not null,
  description text        null,
  is_active   boolean     not null default true,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);
create trigger brands_updated_at before update on brands
  for each row execute function set_updated_at();


-- 2. job_types ---------------------------------------------------------------
-- The production format being made. Lookup table so it can grow without
-- a migration (schema-notes.md, section 4).
create table job_types (
  id          uuid primary key default gen_random_uuid(),
  code        text        not null unique,
  label       text        not null,
  description text        null,
  is_active   boolean     not null default true,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);
create trigger job_types_updated_at before update on job_types
  for each row execute function set_updated_at();


-- 3. projects ----------------------------------------------------------------
create table projects (
  id          uuid primary key default gen_random_uuid(),
  brand_id    uuid        not null references brands(id) on delete restrict,
  name        text        not null,
  slug        text        not null,
  description text        null,
  status      text        not null default 'active',
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),

  constraint projects_status_check check (status in ('active','archived')),
  constraint projects_brand_slug_unique unique (brand_id, slug)
);
create index projects_brand_id_idx on projects(brand_id);
create trigger projects_updated_at before update on projects
  for each row execute function set_updated_at();


-- 4. prompt_blocks -----------------------------------------------------------
-- The Style Library. Reusable fragments assembled into a full prompt.
-- body_text may contain {{variable}} slots filled from the job form.
create table prompt_blocks (
  id         uuid        primary key default gen_random_uuid(),
  kind       text        not null,
  slug       text        not null unique,
  label      text        not null,
  body_text  text        not null,
  brand_id   uuid        null references brands(id) on delete restrict,
  is_active  boolean     not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint prompt_blocks_kind_check check (kind in (
    'base_style','subject','composition','environment',
    'lighting','color','brand_rule','print_req','negative','output'
  ))
);
create index prompt_blocks_kind_idx     on prompt_blocks(kind);
create index prompt_blocks_brand_id_idx on prompt_blocks(brand_id);
create trigger prompt_blocks_updated_at before update on prompt_blocks
  for each row execute function set_updated_at();


-- 5. prompt_templates --------------------------------------------------------
-- brand_id null means the template is global.
-- variables_json drives the New Job form; shape is an array of:
--   { name, label, type: 'text'|'textarea'|'select', required, placeholder, options? }
create table prompt_templates (
  id               uuid        primary key default gen_random_uuid(),
  brand_id         uuid        null references brands(id) on delete restrict,
  job_type_id      uuid        not null references job_types(id) on delete restrict,
  name             text        not null,
  slug             text        not null,
  description      text        null,
  variables_json   jsonb       not null default '[]'::jsonb,
  default_settings jsonb       not null default '{}'::jsonb,
  is_active        boolean     not null default true,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),

  constraint prompt_templates_slug_unique unique (job_type_id, brand_id, slug)
);
create index prompt_templates_job_type_id_idx on prompt_templates(job_type_id);
create index prompt_templates_brand_id_idx    on prompt_templates(brand_id);
create trigger prompt_templates_updated_at before update on prompt_templates
  for each row execute function set_updated_at();


-- 6. template_blocks ---------------------------------------------------------
-- Ordered composition. This join table IS the prompt engine's source of truth.
create table template_blocks (
  template_id uuid    not null references prompt_templates(id) on delete cascade,
  block_id    uuid    not null references prompt_blocks(id)    on delete restrict,
  position    integer not null,

  primary key (template_id, block_id)
);
create index template_blocks_template_id_idx on template_blocks(template_id, position);
create index template_blocks_block_id_idx    on template_blocks(block_id);


-- 7. generation_jobs ---------------------------------------------------------
-- The request, kept separate from the images it returns.
create table generation_jobs (
  id                 uuid        primary key default gen_random_uuid(),
  brand_id           uuid        not null references brands(id)           on delete restrict,
  project_id         uuid        not null references projects(id)         on delete restrict,
  job_type_id        uuid        not null references job_types(id)        on delete restrict,
  prompt_template_id uuid        null     references prompt_templates(id) on delete set null,

  title              text        null,
  -- The fully resolved string that actually hit the API. Never the template.
  -- This single field is what makes a result reproducible six months later.
  prompt_text        text        not null,
  -- The form values the prompt was built from, so the job can be re-run/edited.
  inputs_json        jsonb       not null default '{}'::jsonb,

  provider_name      text        not null,
  provider_model     text        not null,
  provider_job_id    text        null,
  params_json        jsonb       not null default '{}'::jsonb,
  seed               bigint      null,

  status             text        not null default 'queued',
  error_message      text        null,

  usage_json         jsonb       null,
  cost_usd           numeric(10,4) null,

  submitted_at       timestamptz not null default now(),
  completed_at       timestamptz null,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now(),

  constraint generation_jobs_status_check
    check (status in ('queued','processing','succeeded','failed'))
);
create index generation_jobs_brand_id_idx    on generation_jobs(brand_id);
create index generation_jobs_project_id_idx  on generation_jobs(project_id);
create index generation_jobs_job_type_id_idx on generation_jobs(job_type_id);
create index generation_jobs_template_id_idx on generation_jobs(prompt_template_id);
create index generation_jobs_status_idx      on generation_jobs(status);
create index generation_jobs_created_at_idx  on generation_jobs(created_at desc);
create trigger generation_jobs_updated_at before update on generation_jobs
  for each row execute function set_updated_at();


-- 8. generated_assets --------------------------------------------------------
-- One row per image returned. storage_path stays provider/location agnostic so
-- the Stage 3 move to Cloudflare R2 does not require a schema change.
create table generated_assets (
  id                   uuid        primary key default gen_random_uuid(),
  generation_job_id    uuid        not null references generation_jobs(id) on delete restrict,
  brand_id             uuid        not null references brands(id)          on delete restrict,
  project_id           uuid        not null references projects(id)        on delete restrict,

  asset_name           text        not null,
  storage_path         text        not null,
  mime_type            text        not null default 'image/png',
  width                integer     null,
  height               integer     null,
  file_size_bytes      bigint      null,

  status               text        not null default 'draft',
  is_favorite          boolean     not null default false,
  source_variant_index integer     null,
  metadata_json        jsonb       not null default '{}'::jsonb,

  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now(),

  constraint generated_assets_status_check
    check (status in ('draft','approved','rejected'))
);
create index generated_assets_job_id_idx      on generated_assets(generation_job_id);
create index generated_assets_brand_id_idx    on generated_assets(brand_id);
create index generated_assets_project_id_idx  on generated_assets(project_id);
create index generated_assets_status_idx      on generated_assets(status);
create index generated_assets_is_favorite_idx on generated_assets(is_favorite);
create index generated_assets_created_at_idx  on generated_assets(created_at desc);
create trigger generated_assets_updated_at before update on generated_assets
  for each row execute function set_updated_at();

commit;

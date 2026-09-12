-- 052_a_season_is_one_action.sql
--
-- Stage E. §7's test for it is "generate every High priority Fall page is one
-- action", and until now the answer was fifteen visits to a form.
--
-- The cost of not having this is measured, not assumed. Of 94 renders made
-- against planned items, 57 were of two rows — `Multiracial Fall 01` alone
-- took 33 — because re-running one row was the only cheap thing to do. Nine of
-- the thirteen items ever generated have one or two renders to their name. The
-- library is 180 pages and the sample it has been judged on is two.
--
-- Two tables rather than one. A **run** is the instruction; its **items** are
-- the list, expanded and frozen at the moment the run is planned, so what is
-- about to be spent can be read before a penny of it goes. An item whose page
-- type has no template is marked `skipped` at expansion with a reason, because
-- "12 of 15 will run and here are the other 3" is a plan and a mid-run failure
-- is not.
--
-- Work is claimed one row at a time with `for update skip locked`: each unit
-- of work is one image call, the run survives a reload, a crash or a closed
-- laptop, and nothing is ever generated twice.

begin;

create table batch_runs (
  id             uuid        primary key default gen_random_uuid(),
  name           text        not null,
  category_id    uuid        not null references categories(id) on delete restrict,

  -- What was asked for, kept verbatim: a run that cannot say what it selected
  -- cannot be repeated or argued with.
  filter_json    jsonb       not null default '{}'::jsonb,
  settings_json  jsonb       not null default '{}'::jsonb,

  status         text        not null default 'planned',

  -- The account ran dry mid-session on 2026-09-12 with no warning. A run that
  -- can spend unattended gets a ceiling it cannot cross; null means no ceiling
  -- and is a deliberate choice rather than the default.
  max_spend_usd  numeric(10,4) null,

  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  started_at     timestamptz null,
  finished_at    timestamptz null,

  constraint batch_runs_status_check check (
    status in ('planned','running','paused','done','cancelled')
  )
);
create index batch_runs_status_idx on batch_runs(status);
create index batch_runs_created_at_idx on batch_runs(created_at desc);
create trigger batch_runs_updated_at before update on batch_runs
  for each row execute function set_updated_at();

create table batch_items (
  id                uuid        primary key default gen_random_uuid(),
  run_id            uuid        not null references batch_runs(id) on delete cascade,
  item_id           uuid        not null references items(id) on delete cascade,

  -- Null only on a row skipped before it could be matched to a template.
  template_id       uuid        null references prompt_templates(id) on delete restrict,
  position          integer     not null,
  status            text        not null default 'queued',

  -- D9's record of what was actually spent hangs off this.
  generation_job_id uuid        null references generation_jobs(id) on delete set null,
  error_message     text        null,
  attempts          integer     not null default 0,

  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),

  constraint batch_items_status_check check (
    status in ('queued','running','done','failed','skipped')
  ),
  -- A page appears once in a run. Asking for it twice is a mistake, and an
  -- expensive one.
  constraint batch_items_once unique (run_id, item_id)
);
create index batch_items_run_status_idx on batch_items(run_id, status, position);
create trigger batch_items_updated_at before update on batch_items
  for each row execute function set_updated_at();

do $$
begin
  if to_regclass('public.batch_runs') is null
     or to_regclass('public.batch_items') is null then
    raise exception 'the batch tables were not created'; end if;
end $$;

commit;

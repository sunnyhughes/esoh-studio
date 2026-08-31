-- 026_print_areas.sql
--
-- Where a design's real dimensions come from.
--
-- The apparel delivery size has been a guess twice over. 020 replaced
-- 4500x5400 with 3600x4800 on the reasoning that a 12x16" front print at 300
-- DPI is 3600x4800 — arithmetic that is correct and beside the point, because
-- Printify does not describe its products in inches. It publishes a printable
-- area in pixels per product, per print provider, per placement, and the
-- example in its own documentation is 3153x3995 — neither of the two numbers
-- this project has used.
--
-- So the number is not something to derive. It is something to fetch, from
-- the account the products actually live in:
--
--   GET /v1/shops.json                       which shops exist
--   GET /v1/shops/{id}/products.json         blueprint + provider per product
--   GET /v1/catalog/blueprints/{b}/print_providers/{p}/variants.json
--                                            placeholders, width and height
--
-- `scripts/printify-print-areas.mjs` walks that and fills this table. It
-- needs a Personal Access Token with catalog.read; there is no way to read a
-- private shop's products without one.
--
-- Rows are keyed on the triple that identifies a printable area, so re-running
-- the script refreshes rather than duplicates. `is_default` marks the one a
-- category delivers into — the front print of the shirt most of the line is
-- sold on — and nothing else in the app reads a size until one is set, which
-- is deliberate: a wrong number that looks authoritative is worse than none.

begin;

create table print_areas (
  id                uuid primary key default gen_random_uuid(),
  category_id       uuid references categories(id) on delete restrict,
  blueprint_id      integer not null,
  print_provider_id integer not null,
  blueprint_title   text not null,
  provider_title    text,
  placeholder       text not null,
  width_px          integer not null,
  height_px         integer not null,
  is_default        boolean not null default false,
  fetched_at        timestamptz not null default now(),
  unique (blueprint_id, print_provider_id, placeholder)
);

create index print_areas_category_idx on print_areas (category_id);

-- At most one default per category.
create unique index print_areas_one_default_per_category
  on print_areas (category_id) where is_default;

commit;

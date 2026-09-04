-- 028_where_an_asset_came_from.sql
--
-- An asset belongs to exactly one category and always will: `category_id` is
-- NOT NULL, and the categories disagree on pixels anyway — social-content is
-- 1024x1024 where the rest are 1024x1536, and vv-styles is transparent where
-- the rest are not. One file cannot be a shirt front and an Instagram square.
--
-- So reuse across categories was never going to mean sharing a row. It means
-- *derivation*: an approved image becomes the source for a new asset made for
-- somewhere else. The tool already derives in one place — /api/overlay reads a
-- generated page, letters it, and inserts a new asset — and four of the
-- nineteen coloring-book assets were made that way.
--
-- Nothing records the parent. Lineage is implied by a shared
-- generation_job_id, a copied source_variant_index, and a '-quote' suffix on
-- the name, and that is already ambiguous: two jobs currently have four and
-- two assets sharing a job id and variant index, so "which page did this
-- lettered version come from" cannot be answered from the data.
--
-- One nullable self-reference fixes it. Nullable because a generated asset has
-- no parent — only a derived one does. ON DELETE SET NULL rather than CASCADE:
-- losing an original should orphan the derivative, never destroy it, since the
-- derivative was paid for separately and may be the one in print.
--
-- Not backfilled. The information needed to do it automatically is precisely
-- the information that was missing; the four existing '-quote' assets can only
-- be linked by eye.

begin;

alter table generated_assets
  add column derived_from_asset_id uuid
    references generated_assets(id) on delete set null;

comment on column generated_assets.derived_from_asset_id is
  'The asset this one was made from — a lettered page, a transparent cut, a '
  'reframe for another category. Null when the image came straight from the '
  'model. Points across categories on purpose.';

-- The question this exists to answer is "what came from this?", so index the
-- parent, not the child. Partial: derivatives are the minority and always will
-- be.
create index generated_assets_derived_from_idx
  on generated_assets (derived_from_asset_id)
  where derived_from_asset_id is not null;

-- A row cannot be its own parent. Deeper cycles are not reachable: a
-- derivative is written at the moment it is created, from a parent that
-- already exists, and derived_from_asset_id is never updated afterwards.
alter table generated_assets
  add constraint generated_assets_not_self_derived
    check (derived_from_asset_id is distinct from id);

commit;

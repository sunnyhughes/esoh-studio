-- 003_series_and_brand_mark.sql
--
-- Two gaps found while reviewing the imported data.
--
-- 1. The series name was nowhere in the database. "Healing Seasons" is the
--    reason these 180 pages exist, but collections were identified only by
--    line and season ("African American — Fall"), which stops differentiating
--    as soon as a second series exists.
--
-- 2. The "Healing Seasons" lettering on a mug was recorded in direction.md as
--    a recurring motif and brand signature. It is neither — it is an occasional
--    name-drop, wanted on a few pages and not on the rest. As a style-block
--    motif it would have put a mug on every page. It becomes per-item data.

begin;

alter table collections
  add column series text null;

comment on column collections.series is
  'Book series this collection belongs to, e.g. Healing Seasons. Null for '
  'categories that do not run in series, such as one-off apparel drops.';

update collections c
   set series = 'Healing Seasons'
  from categories cat
 where cat.id = c.category_id
   and cat.code = 'coloring-books';

create index collections_series_idx on collections(series);


alter table items
  add column brand_mark text null;

comment on column items.brand_mark is
  'Optional subtle in-scene name-drop — lettering on a mug, a book spine. '
  'Deliberately per-item and null by default: it is an occasional touch, not '
  'a signature, and must never be promoted into a style block.';

alter table items add constraint items_brand_mark_check
  check (brand_mark is null or brand_mark in ('Healing Seasons', 'Esoh Creations'));

commit;

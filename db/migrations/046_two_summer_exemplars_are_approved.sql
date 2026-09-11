-- 046_two_summer_exemplars_are_approved.sql
--
-- Esoh on the two `African American Summer 01` renders that followed 044's
-- brief rewrite: "re-7 is a great image. Its drawn correctly and is a great
-- exemplar!" and "re-8 is a great image and a great exemplar."
--
-- The library has held approved references for one page type and one season
-- since the beginning — two autumn Solo portraits of the same seated man. These
-- are Solo portraits in summer, outdoors, of a different figure, and they are
-- the first references the project has that were produced by its own corrected
-- pipeline rather than shot ahead of it.
--
-- D117 selects `order by created_at desc limit 3`, so adding two would have
-- pushed `hoodie-on-sofa-v2` out of rotation silently. Esoh's call was to keep
-- all four and raise the limit, which the route change alongside this does. The
-- figure pages then see two autumn and two summer references, which also
-- answers the worry D118 recorded and withdrew — the set no longer has a single
-- season in it either way.
--
-- Files are copied into `storage/exemplars/` rather than referenced at their
-- generated path, so an exemplar does not disappear if the job that made it is
-- ever purged (D30 purges files and keeps records).

begin;

insert into reference_images
  (item_id, asset_id, label, storage_path, kind, page_type, art_style, usable_as_input, notes)
values
  ('8632d0cf-ef96-428b-85f6-dd7fd55a3001',
   '0bc4eadc-2cb9-4ae9-aea6-a48be59287a8',
   'Summer under the tree',
   'exemplars/summer-under-the-tree.png',
   'exemplar', 'Solo portrait', 'Editorial Scene', true,
   'Approved by Esoh 2026-09-11 — "a great exemplar". Generated after 044 '
   'removed the titled object from the brief, so the journal is blank. First '
   'summer reference in the library and the first produced by the pipeline '
   'itself.'),
  ('8632d0cf-ef96-428b-85f6-dd7fd55a3001',
   'caf8f714-9595-4a6f-894e-7453bbfe9de7',
   'Summer under the tree, second',
   'exemplars/summer-under-the-tree-v2.png',
   'exemplar', 'Solo portrait', 'Editorial Scene', true,
   'Approved by Esoh 2026-09-11 alongside its pair.');

-- Four usable references now, two seasons, and every one of them a Solo
-- portrait — the gap for the other five page types is unchanged and open.
do $$
declare n int;
begin
  select count(*) into n from reference_images where usable_as_input;
  if n <> 4 then raise exception 'expected 4 usable references, got %', n; end if;

  select count(distinct page_type) into n from reference_images where usable_as_input;
  if n <> 1 then raise exception 'reference page types changed unexpectedly: %', n; end if;
end $$;

-- The files are where the rows say they are.
do $$
declare bad text;
begin
  select string_agg(storage_path, ', ') into bad from reference_images
   where usable_as_input and storage_path not like 'exemplars/%';
  if bad is not null then
    raise exception 'reference not stored under exemplars/: %', bad; end if;
end $$;

commit;

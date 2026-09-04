-- 030_purge_the_file_keep_the_record.sql
--
-- 23 of 36 assets are rejected and they are 56 MB of 90 MB — more storage
-- spent on work that was turned down than on work that was kept. At Stage C
-- volume plus 240 coloring pages at roughly three attempts each, that is
-- somewhere near 1.8 GB, most of it images already said no to, inside a
-- Crostini container.
--
-- The file and the record are not the same thing. The row holds what the image
-- cost (D9), the prompt that made it, what it was derived from (D85) and the
-- verdict passed on it. Twenty-three rejections are a record of what Esoh does
-- not want, and nothing else in the system stores that. The file is 2.5 MB of
-- pixels already decided against.
--
-- So the file goes and the row stays, with purged_at marking which is which.
-- A purged row still answers "what did this cost", "what was it made from" and
-- "what did I think of it"; it just cannot show the picture any more.

begin;

alter table generated_assets
  add column purged_at timestamptz;

comment on column generated_assets.purged_at is
  'When the image file was deleted to reclaim disk. The row survives: cost, '
  'prompt, lineage and verdict outlive the pixels. Null means the file is '
  'still on disk at storage_path.';

create index generated_assets_purged_idx
  on generated_assets (purged_at)
  where purged_at is not null;

commit;

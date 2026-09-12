-- 053_the_reference_set_gets_a_winter_and_a_man.sql
--
-- Esoh, 2026-09-12, naming the four Solo portrait references to use:
-- `hoodie-on-sofa-v2`, `summer-under-the-tree`, `walking-with-mug`, and
-- `man-shovel-snow-v2`. That is a swap, not an addition — `summer-under-the-tree-v2`
-- comes out of rotation, and the count stays at four, so D117's
-- `order by created_at desc limit 4` still returns the whole set rather than
-- dropping the oldest one silently. That silent drop is exactly what D121
-- caught when the limit was 3, and it is the reason the size of this set is
-- decided rather than discovered.
--
-- What the new one adds is the first **winter** reference and the first **male**
-- figure in a set that was four seated women in autumn and summer. It is also
-- the second page the pipeline has produced for its own library.
--
-- It is the second attempt at the scene, and the first one is the reason it
-- exists. "A few flakes are still falling" came back as roughly forty outlined
-- ovals scattered over the whole page, including across the jacket and the
-- jeans — snow in the air has no outline, so the model invented one, forty
-- times. Rewriting it as snow that has *landed* — banked along the drive,
-- heaped on the car, capping the lamppost and hedges — gave it real closed
-- shapes to draw and left the figure unmarked. **A brief naming something the
-- medium cannot draw gets it drawn wrong rather than left out**, which is the
-- shape of D105, D120 and D121 in a fourth place.
--
-- D22 refuses to promote an asset that has not been approved, so the asset is
-- marked first. The file is copied into `storage/exemplars/` rather than
-- referenced where it was generated, so the exemplar survives a purge (D30).

begin;

update generated_assets
   set status = 'approved', updated_at = now()
 where id = '679fec60-9dae-4014-b755-5f267022d263';

insert into reference_images
  (item_id, asset_id, label, storage_path, kind, page_type, art_style,
   usable_as_input, notes)
values
  (null,
   '679fec60-9dae-4014-b755-5f267022d263',
   'Man shovelling snow',
   'exemplars/man-shovel-snow-v2.png',
   'exemplar', 'Solo portrait', 'Editorial Scene', true,
   'Approved by Esoh 2026-09-12 — "a great image minus the weird looking snow '
   'falling", then re-run without it. First winter reference and first male '
   'figure in the set. Generated ad-hoc with no item behind it, which is why '
   'item_id is null.');

-- Esoh''s four, and only those four.
update reference_images
   set usable_as_input = false, updated_at = now()
 where storage_path = 'exemplars/summer-under-the-tree-v2.png';

do $$
declare got text;
begin
  select string_agg(storage_path, ', ' order by storage_path) into got
    from reference_images where usable_as_input and page_type = 'Solo portrait';

  if got is distinct from
     'exemplars/hoodie-on-sofa-v2.png, exemplars/man-shovel-snow-v2.png, '
     'exemplars/summer-under-the-tree.png, exemplars/walking-with-mug.png' then
    raise exception 'the Solo portrait reference set is not Esoh''s four: %', got;
  end if;

  -- The selector takes four. More usable rows than that and the newest would
  -- push the oldest out without saying so.
  if (select count(*) from reference_images
       where usable_as_input and page_type = 'Solo portrait') > 4 then
    raise exception 'more than four Solo portrait references would be silently trimmed';
  end if;
end $$;

do $$
declare bad text;
begin
  select string_agg(storage_path, ', ') into bad from reference_images
   where usable_as_input and storage_path not like 'exemplars/%';
  if bad is not null then
    raise exception 'reference not stored under exemplars/: %', bad; end if;
end $$;

commit;

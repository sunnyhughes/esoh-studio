-- 054_the_falling_snow_version_is_kept_as_a_study.sql
--
-- The first attempt at the snow scene, recorded deliberately rather than left
-- lying in the asset table.
--
-- It is the same prompt as `man-shovel-snow-v2` but for one clause: "A few
-- flakes are still falling". That clause produced roughly forty outlined ovals
-- scattered across the whole page, jacket and jeans included, breaking up the
-- largest colourable areas on it. Rewriting the snow as something that has
-- **landed** — banked along the drive, heaped on the car, capping the lamppost
-- and hedges — removed every oval and left the figure clean.
--
-- The pair is the clearest evidence the project has for the rule in D130: a
-- brief that names something the medium cannot draw gets it drawn *wrong*
-- rather than left out. Snow in the air has no outline, so the model invented
-- one, forty times. Two images that differ by one clause are worth more than
-- the paragraph describing them, which is what `journaling-under-tree` and
-- `hoodie-on-sofa` already are — studies, kept for what they show, never sent
-- to the model.
--
-- `usable_as_input` stays false, which is the whole point of the kind. The
-- asset's own status is left exactly as Esoh set it.

begin;

insert into reference_images
  (item_id, asset_id, label, storage_path, kind, page_type, art_style,
   usable_as_input, notes)
values
  (null,
   '5f7cd338-7183-4c54-9f4f-592bf9e56027',
   'Man shovelling snow, with falling snow',
   'exemplars/man-shovel-snow.png',
   'study', 'Solo portrait', 'Editorial Scene', false,
   'Counter-example to exemplars/man-shovel-snow-v2.png, kept at Esoh''s '
   'request 2026-09-12. Same prompt but for "A few flakes are still falling", '
   'which produced ~40 outlined ovals across the page and over the figure. '
   'Never sent as input — it is here to be looked at.');

do $$
declare n int;
begin
  -- The set the model is actually handed must not have moved.
  select count(*) into n from reference_images
   where usable_as_input and page_type = 'Solo portrait';
  if n <> 4 then
    raise exception 'the Solo portrait reference set changed: % usable', n; end if;

  if exists (select 1 from reference_images
              where storage_path = 'exemplars/man-shovel-snow.png'
                and usable_as_input) then
    raise exception 'the study was made usable as input'; end if;
end $$;

commit;

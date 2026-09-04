-- 029_a_reference_earns_its_place.sql
--
-- D22 says approved pages can be promoted to style references. The table has
-- had the shape for that since the start — reference_images.asset_id points at
-- the generated asset a reference came from — and it has never been used. All
-- four rows carry asset_id NULL. They are loose files placed in
-- storage/exemplars/ by hand.
--
-- That includes the only row with usable_as_input = true, 'Hoodie on sofa,
-- corrected', which is the image steering every Solo portrait generation. It
-- got there by being copied into a folder. Meanwhile all four approved assets
-- sit unpromoted.
--
-- Two changes.
--
-- First, record the one link that can be proven: journaling-under-tree.png is
-- byte-identical to the output of asset 608ce084. The other three match
-- nothing in storage — they came from outside this tool and legitimately have
-- no asset to point at, since they predate it.
--
-- Second, enforce D22 where it can be enforced. A hand-placed seed cannot be
-- required to have an asset. But a reference that *does* name an asset must
-- name an approved one, and an asset already teaching cannot quietly stop
-- being approved underneath it. A bad reference is the failure that compounds:
-- it does not spoil one page, it teaches every page after it.

begin;

update reference_images
   set asset_id = '608ce084-1de6-4695-b0f1-5e9be26c2465'
 where label = 'Journaling under a tree'
   and asset_id is null;

create or replace function reference_input_must_be_approved()
returns trigger language plpgsql as $$
declare
  asset_status text;
begin
  if new.usable_as_input and new.asset_id is not null then
    select status into asset_status
      from generated_assets where id = new.asset_id;

    if asset_status is distinct from 'approved' then
      raise exception
        'Reference "%" cannot be usable_as_input: asset % is %, not approved (D22).',
        new.label, new.asset_id, coalesce(asset_status, 'missing');
    end if;
  end if;
  return new;
end;
$$;

create trigger reference_images_input_approved
  before insert or update on reference_images
  for each row execute function reference_input_must_be_approved();

-- The other direction. Rejecting a page that is already teaching would leave
-- it teaching, which is the same failure arriving later. Refuse the change and
-- name the reference, rather than silently demoting it — which of the two to
-- undo is a judgment, and the tool does not get to make it.
create or replace function approved_asset_in_use_stays_approved()
returns trigger language plpgsql as $$
declare
  ref_label text;
begin
  if old.status = 'approved' and new.status is distinct from 'approved' then
    select label into ref_label
      from reference_images
     where asset_id = new.id and usable_as_input
     limit 1;

    if ref_label is not null then
      raise exception
        'Asset % is the style reference "%" and cannot leave approved. '
        'Set that reference usable_as_input = false first (D22).',
        new.id, ref_label;
    end if;
  end if;
  return new;
end;
$$;

create trigger generated_assets_reference_stays_approved
  before update on generated_assets
  for each row execute function approved_asset_in_use_stays_approved();

commit;

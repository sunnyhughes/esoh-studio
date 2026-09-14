-- 064_one_answer_to_is_this_page_ready.sql
--
-- 063 added the production gates to `lib/book.ts` and immediately produced two
-- different answers to the same question: `/api/books` reported three pages
-- ready in African American Fall while the plan for that same book reported
-- every one of its fifteen blocked. The readiness rule lived in two places —
-- once in SQL for the list, once in TypeScript for the plan — and the comment
-- above the SQL said, correctly, "the two must agree on what ready means".
--
-- They cannot be made to agree by being written carefully twice. That is the
-- shape of D125 again, and of the thing 063's own header warned about: two
-- answers to one question drift, and the drift is invisible until something
-- expensive depends on it.
--
-- So the rule becomes a view, and both callers read it. A page is ready when
-- it has art, the art was kept, a quote page has been lettered, cultural review
-- has passed and it has been signed off — in that order, because that is the
-- order a person passes a page through and the first unmet gate is the one
-- worth naming.

begin;

create or replace view page_readiness as
select
  i.id            as item_id,
  i.collection_id,
  i.ref,
  i.title,
  i.page_type,
  a.id            as asset_id,
  a.storage_path,
  a.status        as asset_status,
  a.metadata_json as asset_metadata,
  (a.metadata_json -> 'overlay') is not null as lettered,
  case
    when a.id is null
      then 'No page has been generated yet.'
    when a.status <> 'approved'
      then 'Generated but not kept — the art has not been approved.'
    when i.page_type = 'Quote page' and (a.metadata_json -> 'overlay') is null
      then 'Generated but not lettered — the quote is still missing.'
    when i.cultural_review_status = 'Changes Requested'
      then 'Cultural review asked for changes.'
    when i.cultural_review_status <> 'Approved'
      then 'Cultural review is ' || lower(i.cultural_review_status) || '.'
    when i.overall_approval = 'Hold'
      then 'On hold.'
    when i.overall_approval <> 'Approved'
      then 'Not signed off — overall approval is still outstanding.'
    else null
  end as blocked
from items i
left join lateral (
  -- One asset per page: an approved page beats a draft, a lettered Quote page
  -- beats the bare art it was set over, and the most recent breaks the tie.
  select g.id, g.storage_path, g.status, g.metadata_json
    from generated_assets g
   where g.item_id = i.id and g.purged_at is null
   order by (g.status = 'approved') desc,
            (i.page_type = 'Quote page'
              and (g.metadata_json -> 'overlay') is not null) desc,
            g.created_at desc
   limit 1
) a on true;

do $$
declare n int; m int;
begin
  select count(*) into n from page_readiness;
  select count(*) into m from items;
  if n <> m then raise exception 'the view lost rows: % of %', n, m; end if;

  -- Nothing can be ready yet: no page has been through cultural review.
  select count(*) into n from page_readiness where blocked is null;
  if n <> 0 then raise exception '% pages read as ready before any review', n; end if;
end $$;

commit;

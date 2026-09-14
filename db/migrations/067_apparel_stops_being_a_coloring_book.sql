-- 067_apparel_stops_being_a_coloring_book.sql
--
-- Esoh, 2026-09-14, on reviewing the last eight migrations: "I just want to make
-- sure that the tool is being properly created and designed for usage with
-- multiple job types and not just the coloring book line." Three things had
-- leaked, and one gap predates them.
--
-- **Batch has never worked for apparel.** Not since it was built. `planRows`
-- joined `t.page_type = i.page_type`; the apparel template has no page type and
-- neither do apparel items, and in SQL `null = null` is never true, so zero of
-- 130 rows ever matched. 059 replaced that join with an assigned template and
-- only assigned the coloring pages, so the breakage survived under a new
-- message. D129 recorded batch as built without saying it served one category.
-- Apparel has exactly one template, so the assignment is one statement.
--
-- **The production gates landed on all 310 items.** 063 added
-- `cultural_review_status` and `overall_approval` to `items`, which both
-- categories share, so 130 apparel designs acquired a review workflow written
-- for three representation lines in a recovery colouring book. They become
-- nullable, and null on apparel, because "not started" is a claim and
-- "not applicable" is the truth.
--
-- **Readiness meant one thing.** `page_readiness` gated an apparel design on
-- cultural review it will never have. Apparel is ready when the art is approved
-- and the knockout measures as a knockout — D74's transparency check, which is
-- already run and recorded on every apparel asset and was doing nothing here.

begin;

-- 1. Every apparel design points at the apparel template.
update items i
   set prompt_template_id = t.id, updated_at = now()
  from prompt_templates t
 where t.slug = 'vvs-front-print' and t.is_active
   and i.category_id = (select id from categories where code = 'vv-styles')
   and i.prompt_template_id is null;

-- 2. The colouring-book gates stop making claims about apparel.
alter table items alter column cultural_review_status drop not null;
alter table items alter column overall_approval       drop not null;

update items set cultural_review_status = null, overall_approval = null,
                 updated_at = now()
 where category_id <> (select id from categories where code = 'coloring-books');

-- 3. Readiness is asked of the right thing per category.
--
-- Dropped and recreated rather than replaced: `create or replace view` cannot
-- add a column anywhere but the end, and `category_code` belongs beside the
-- other identifying columns rather than trailing after the verdict. Both
-- callers read it inside this transaction's lock, so nothing sees it missing.
drop view if exists page_readiness;
create view page_readiness as
select
  i.id            as item_id,
  i.collection_id,
  i.ref,
  i.title,
  i.page_type,
  c.code          as category_code,
  a.id            as asset_id,
  a.storage_path,
  a.status        as asset_status,
  a.metadata_json as asset_metadata,
  (a.metadata_json -> 'overlay') is not null as lettered,
  case
    when a.id is null then
      case when c.code = 'vv-styles'
        then 'No design has been generated yet.'
        else 'No page has been generated yet.' end
    when a.status <> 'approved'
      then 'Generated but not kept — the art has not been approved.'

    -- Apparel: the only gate that matters is whether it is really cut out.
    -- A background box hidden by white fabric is invisible until the design is
    -- put on navy (D34, D38, D74).
    when c.code = 'vv-styles' then
      case when (a.metadata_json -> 'transparency' ->> 'ok') = 'false'
        then 'The knockout failed — this does not measure as cut-out artwork.'
        else null end

    when i.page_type = 'Quote page' and q.id is null
      then 'No approved affirmation is assigned to this page.'
    when i.page_type = 'Quote page' and q.review_status <> 'Approved'
      then 'The affirmation is ' || lower(q.review_status) || ', not approved.'
    when i.page_type = 'Quote page' and q.translation_review_status = 'Needs Native Review'
      then 'The Spanish still needs a native-speaker review.'
    when i.page_type = 'Quote page' and (a.metadata_json -> 'overlay') is null
      then 'Generated but not lettered — the quote is still missing.'
    when i.cultural_review_status = 'Changes Requested'
      then 'Cultural review asked for changes.'
    when coalesce(i.cultural_review_status, 'Approved') <> 'Approved'
      then 'Cultural review is ' || lower(i.cultural_review_status) || '.'
    when i.overall_approval = 'Hold'
      then 'On hold.'
    when coalesce(i.overall_approval, 'Approved') <> 'Approved'
      then 'Not signed off — overall approval is still outstanding.'
    else null
  end as blocked
from items i
join categories c on c.id = i.category_id
left join quotes q on q.id = i.quote_id
left join lateral (
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
declare n int;
begin
  select count(*) into n from items i
   where i.category_id = (select id from categories where code = 'vv-styles')
     and i.prompt_template_id is null;
  if n <> 0 then raise exception '% apparel designs still have no template', n; end if;

  select count(*) into n from items i
   where i.category_id <> (select id from categories where code = 'coloring-books')
     and (i.cultural_review_status is not null or i.overall_approval is not null);
  if n <> 0 then raise exception '% non-colouring rows still carry a book gate', n; end if;

  select count(*) into n from items i
   where i.category_id = (select id from categories where code = 'coloring-books')
     and (i.cultural_review_status is null or i.overall_approval is null);
  if n <> 0 then raise exception '% colouring pages lost their gate', n; end if;

  -- An approved apparel design with a clean knockout is ready; nothing in a
  -- colouring book is, because none has been reviewed.
  select count(*) into n from page_readiness
   where category_code = 'coloring-books' and blocked is null;
  if n <> 0 then raise exception '% pages read as ready before any review', n; end if;
end $$;

commit;

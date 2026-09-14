-- 063_the_production_gates.sql
--
-- Step 4. `illustration-production-tracker.csv` carries eleven status columns
-- per page — prompt, draft, revision, cultural review, quote approval, final
-- line art, PNG export, PDF placement, overall approval, owner, due date — and
-- the tool has one `items.status`, which is 'idea' on all 180 rows and has never
-- moved.
--
-- **Only the human judgements are stored.** Five of the eleven are mechanical
-- and the tool already knows them better than a column would: whether a page
-- has art, whether that art is approved, whether a quote page has been lettered,
-- whether it has been exported. Storing those again creates two answers to one
-- question, and D125 is what that costs — a stale value that outranked its own
-- brief for a month because nothing could see the disagreement. What cannot be
-- derived is what a person decided, so that is what lands here.
--
-- **The one that blocks a launch is `cultural_review_status`.** Esoh's launch
-- tracker holds all four Hispanic products until a native speaker has reviewed
-- the Spanish copy and any visible text, and the QA checklist carries a
-- dedicated column for it. Until now the tool would have built and exported that
-- book without noticing.
--
-- `quote_approval` is added here as one of the gates but left unenforced: the
-- quote library and the lettering block are their own step.

begin;

alter table items
  add column if not exists cultural_review_status text not null default 'Not Started',
  add column if not exists quote_approval         text not null default 'N/A',
  add column if not exists overall_approval       text not null default 'Not Started',
  add column if not exists owner                  text null,
  add column if not exists target_due_date        date null;

alter table items drop constraint if exists items_cultural_review_check;
alter table items add constraint items_cultural_review_check check (
  cultural_review_status in ('Not Started','In Review','Approved','Changes Requested'));

alter table items drop constraint if exists items_quote_approval_check;
alter table items add constraint items_quote_approval_check check (
  quote_approval in ('N/A','Not Started','Pending','Approved','Changes Requested'));

alter table items drop constraint if exists items_overall_approval_check;
alter table items add constraint items_overall_approval_check check (
  overall_approval in ('Not Started','Approved','Hold'));

create index if not exists items_overall_approval_idx on items(overall_approval);

-- A page with a quote on it has a quote to approve; the rest do not, which is
-- how the tracker reads it and keeps 'Not Started' meaning something.
update items set quote_approval = 'Not Started'
 where page_type = 'Quote page' and quote_approval = 'N/A';

-- The tracker names an owner on all 45 Spring rows and no due dates.
update items set owner = 'Sunshine'
 where season = 'Spring'
   and category_id = (select id from categories where code = 'coloring-books');

do $$
declare n int;
begin
  select count(*) into n from items i join categories c on c.id = i.category_id
   where c.code = 'coloring-books' and i.page_type = 'Quote page'
     and i.quote_approval = 'N/A';
  if n <> 0 then raise exception '% quote pages have nothing to approve', n; end if;

  select count(*) into n from items i join categories c on c.id = i.category_id
   where c.code = 'coloring-books' and i.page_type <> 'Quote page'
     and i.quote_approval <> 'N/A';
  if n <> 0 then raise exception '% non-quote pages carry a quote gate', n; end if;

  -- Nothing is approved yet, and the book builder should say so rather than
  -- ship a book nobody has reviewed.
  select count(*) into n from items i join categories c on c.id = i.category_id
   where c.code = 'coloring-books' and i.overall_approval = 'Approved';
  if n <> 0 then raise exception '% pages are approved before anyone looked', n; end if;
end $$;

commit;

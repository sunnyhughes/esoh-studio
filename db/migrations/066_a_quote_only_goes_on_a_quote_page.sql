-- 066_a_quote_only_goes_on_a_quote_page.sql
--
-- 065 linked nine library affirmations to pages by their page number, and put
-- four of them on pages that are not quote pages: `Hispanic Spring 05` and
-- `Multiracial Spring 05` are Community scenes, `Hispanic Spring 14` and
-- `Multiracial Spring 14` are Environment pages. The mirror trigger then wrote
-- the affirmation text onto all four.
--
-- The cause is the one 065's own header describes and its SQL then ignored: the
-- library places quotes at slots 05, 09 and 14, which is the **interleaved**
-- book. Only African American Spring has been converted to that book (056).
-- Hispanic and Multiracial Spring are still grouped, where 05 is a community
-- scene, 14 is a room, and the quote pages are 09, 10 and 11. A comment saying
-- "these will link when their season is converted" is not a condition; this is.
--
-- Five links survive: the three African American Spring pages, and slot 09 on
-- each of the other two lines, which is a quote page in both books.

begin;

update items
   set quote_id = null, quote_text = null, updated_at = now()
 where quote_id is not null and page_type is distinct from 'Quote page';

update quotes set usage_status = 'Planned', updated_at = now()
 where usage_status = 'Assigned'
   and not exists (select 1 from items i where i.quote_id = quotes.id);

-- A CHECK cannot see another table, so the rule is a trigger. It fires on the
-- item because that is where the link is made. It guards every category: an
-- apparel design has no page type and carries its phrase in `quote_text`
-- directly (D70), so it must never acquire a library link either.
create or replace function quote_only_on_a_quote_page() returns trigger as $fn$
begin
  if new.quote_id is not null and new.page_type is distinct from 'Quote page' then
    raise exception
      'Page % is a %, not a Quote page — an affirmation cannot be assigned to it.',
      new.ref, coalesce(new.page_type, 'page with no type');
  end if;
  return new;
end $fn$ language plpgsql;

create trigger items_quote_page_only
  before insert or update of quote_id, page_type on items
  for each row execute function quote_only_on_a_quote_page();

do $$
declare n int;
begin
  select count(*) into n from items
   where quote_id is not null and page_type is distinct from 'Quote page';
  if n <> 0 then raise exception '% affirmations are still on the wrong page', n; end if;

  select count(*) into n from items where quote_id is not null;
  if n <> 5 then raise exception 'expected 5 assigned affirmations, got %', n; end if;

  -- Coloring books only: a VV-Styles design carries its phrase in `quote_text`
  -- and has no page type at all, which is the apparel pipeline working as D70
  -- intends and not a page with a stray affirmation on it.
  select count(*) into n from items i join categories c on c.id = i.category_id
   where c.code = 'coloring-books'
     and i.page_type is distinct from 'Quote page'
     and nullif(trim(coalesce(i.quote_text, '')), '') is not null;
  if n <> 0 then raise exception '% coloring pages still carry stray quote text', n; end if;

  -- The guard has to actually refuse.
  begin
    update items set quote_id = (select id from quotes limit 1)
     where ref = 'Hispanic Spring 05';
    raise exception 'the guard let an affirmation onto a community scene';
  exception when others then
    if sqlerrm like 'the guard let%' then raise; end if;
  end;
end $$;

commit;

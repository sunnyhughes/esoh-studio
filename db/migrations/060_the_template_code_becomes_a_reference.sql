-- 060_the_template_code_becomes_a_reference.sql
--
-- 056 gave `items.template_id` as a text code because TPL-06 to TPL-10 had no
-- `prompt_templates` row to point at. 058 built them, so the code can stop
-- being a code.
--
-- The code column stays. It is what the source spreadsheets say, it is what
-- Esoh reads, and losing it would mean translating back and forth every time
-- the assignment is checked against the matrix. What is added is the resolved
-- reference beside it, so application code joins on a key instead of slicing
-- six characters off a slug — which would have worked today and broken the
-- first time a template was renamed.

begin;

alter table items
  add column if not exists prompt_template_id uuid
    references prompt_templates(id) on delete restrict;
create index if not exists items_prompt_template_id_idx on items(prompt_template_id);

update items i
   set prompt_template_id = t.id,
       updated_at = now()
  from prompt_templates t
 where upper(left(t.slug, 6)) = i.template_id
   and t.is_active
   and i.prompt_template_id is distinct from t.id;

do $$
declare n int;
begin
  select count(*) into n from items i join categories c on c.id = i.category_id
   where c.code = 'coloring-books' and i.prompt_template_id is null;
  if n <> 0 then raise exception '% coloring pages did not resolve a template', n; end if;

  -- The resolved template must serve the page's own type, or D56's guard would
  -- refuse the generation later — one page at a time, mid-batch.
  select count(*) into n
    from items i
    join categories c on c.id = i.category_id
    join prompt_templates t on t.id = i.prompt_template_id
   where c.code = 'coloring-books' and t.page_type is distinct from i.page_type;
  if n <> 0 then raise exception '% pages point at a template for another page type', n; end if;

  -- The code and the reference must not be able to disagree.
  select count(*) into n
    from items i join prompt_templates t on t.id = i.prompt_template_id
   where upper(left(t.slug, 6)) <> i.template_id;
  if n <> 0 then raise exception 'code and reference disagree on % rows', n; end if;
end $$;

commit;

-- 083_the_form_stops_asking_for_what_it_cannot_use.sql
--
-- Esoh generated two pages on 2026-09-15 that cost $0.25 each and produced
-- nothing, because the form demanded a Subject and he had none to give. He
-- typed "none", and **the literal word "none" was sent to the image model as
-- the subject of the picture** — it is there in `generation_jobs.prompt_text`
-- for jobs 80fce1a8 and 10107267, sitting between the composition block and the
-- white-space block.
--
-- On a template whose own composition block already reads "No people and no
-- parts of people. The objects are the whole subject", a Subject is genuinely
-- optional: blank should mean "the blocks already say what this page is".
-- `lib/prompt-engine.ts` drops any block whose slots came back empty, so a
-- blank subject removes `hs-subject` cleanly and the rest of the prompt stands.
-- Nothing had to change in code — only the flag that says the field is required.
--
-- The same nine templates also ask for **Hairstyle** and **Facial hair**. None
-- of them can use either: `has_people` is false, so 062 withholds the line
-- identity, and `hs-hair` and `hs-facial-hair` are not in their block lists at
-- all. Two dropdowns on every people-free page, offering twenty-three
-- hairstyles for a page that may not contain a person. That is not a small
-- annoyance — it is the form telling you the page might have hair on it.
--
-- So: Subject becomes optional on every people-free **coloring-book** template,
-- and the fields that can never reach the prompt are removed from them. The
-- figure templates are untouched; there, hair is item data and required reading
-- (D45).
--
-- Scoped to coloring books deliberately. `vvs-front-print` is people-free too
-- and has no Subject at all — an apparel design is driven by its quote, visual
-- elements, lettering, palette and garment (D57, 067). A first draft of this
-- migration updated every `has_people = false` template and its own assertion
-- caught it, which is the assertion doing its job.

begin;

update prompt_templates set
  variables_json = (
    select coalesce(
      jsonb_agg(
        case
          when v->>'name' = 'subject' then
            jsonb_set(
              jsonb_set(v, '{required}', 'false'::jsonb),
              '{placeholder}',
              to_jsonb(
                'Optional — leave blank and the template decides. Name the '
                'objects if you want particular ones.'::text
              )
            )
          else v
        end
        order by ord
      ),
      '[]'::jsonb
    )
    from jsonb_array_elements(variables_json) with ordinality as t(v, ord)
    where v->>'name' not in ('hair', 'facial_hair', 'personal_details')
  ),
  updated_at = now()
 where not has_people
   and category_id = (select id from categories where code = 'coloring-books');

do $$
declare n int;
begin
  -- No people-free template still demands a subject.
  select count(*) into n from prompt_templates t
   join categories c on c.id = t.category_id
   where not t.has_people and c.code = 'coloring-books'
     and exists (
       select 1 from jsonb_array_elements(t.variables_json) v
        where v->>'name' = 'subject' and (v->>'required')::boolean
     );
  if n <> 0 then
    raise exception '% people-free template(s) still require a subject', n;
  end if;

  -- None of them offers a field that cannot reach the prompt.
  select count(*) into n from prompt_templates t
   join categories c on c.id = t.category_id
   where not t.has_people and c.code = 'coloring-books'
     and exists (
       select 1 from jsonb_array_elements(t.variables_json) v
        where v->>'name' in ('hair', 'facial_hair', 'personal_details')
     );
  if n <> 0 then
    raise exception '% people-free template(s) still ask about hair', n;
  end if;

  -- The subject field itself survives — optional, not deleted. A Decorative
  -- page with "a porch swing, lemonade pitcher and glasses" in it is exactly
  -- what the field is for.
  select count(*) into n from prompt_templates t
   join categories c on c.id = t.category_id
   where not t.has_people and c.code = 'coloring-books'
     and not exists (
       select 1 from jsonb_array_elements(t.variables_json) v
        where v->>'name' = 'subject'
     );
  if n <> 0 then raise exception 'the subject field was removed from %', n; end if;

  -- Every template that actually carries the hair block still offers the field
  -- to fill it. D45 stands: hair is item data, and a template wired for it with
  -- no way to supply it would leave the model copying the exemplar's — which is
  -- how filled hair kept coming back.
  --
  -- Matched on the block wiring rather than on `has_people`, because
  -- `adult-coloring-clean-line` has figures, has no hair field, and never had
  -- one: it predates Healing Seasons, carries no page type, and is inactive.
  -- The first draft asserted over `has_people` and this caught it.
  select count(*) into n from prompt_templates t
   where exists (
       select 1 from template_blocks tb
         join prompt_blocks b on b.id = tb.block_id
        where tb.template_id = t.id and b.slug = 'hs-hair'
     )
     and not exists (
       select 1 from jsonb_array_elements(t.variables_json) v
        where v->>'name' = 'hair'
     );
  if n <> 0 then
    raise exception '% template(s) draw hair with no way to say what it is', n;
  end if;
end $$;

commit;

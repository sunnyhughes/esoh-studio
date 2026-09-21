-- 089_the_subject_box_says_what_it_does.sql
--
-- The Subject field's placeholder told two different stories and neither was
-- true where it mattered.
--
--   TPL-03, 04, 05, 09, 10: "Optional — leave blank and the template decides.
--                             Name the objects if you want particular ones."
--   TPL-01, 02, 06, 07, 08: "From the item brief, e.g. Woman journaling by a
--                             rainy window with plants."
--
-- **"The template decides" is false whenever a page is selected from the
-- queue**, which is the normal way this tool is used. `lib/generate.ts` reads:
--
--     if (item && !inputs.subject?.trim()) {
--       inputs.subject = [item.brief, ...ethnicity, ...season].join(" ")
--     }
--
-- Blank plus a selected page means **the item's brief becomes the subject**.
-- The template contributes composition and style blocks around it and never
-- replaces it. The first wording denies that outright; the second describes it
-- without saying that typing in the box overrides it, which is the one thing
-- the box is for.
--
-- **This cost a real misdiagnosis today.** A Decorative page came back as a
-- cable-knit blanket, mugs, an acorn and a gourd on a plank against a tiled
-- paisley ground, and the report was that "the tool has been set up to
-- repeatedly use the same image base no matter what is chosen." No image was
-- used at all — the run recorded `useReferences: false` and an empty reference
-- list — and every object came from `Multiracial Fall 13`'s own brief, which
-- names knitwear, cable, ribbing, chevron bands, mugs, acorns and a small
-- gourd. Templates had been swapped looking for a different result, and
-- swapping them cannot change a subject that lives on the item row. The
-- placeholder said the template decides, so the template is what got changed.
--
-- One true sentence for all ten, replacing both variants. It states the default
-- and the override, because the override is the lever and nothing in the
-- interface said it existed.
--
-- The worked example is dropped rather than rewritten. It described a Solo
-- portrait and sat on five templates, three of which forbid drawing a person at
-- all — §2.5's trap in the mildest possible key, an example of the wrong thing
-- in front of someone about to type.
--
-- **All nineteen templates, not just the ten active ones.** Written first as an
-- `is_active` update, and the guard below refused it: nine inactive templates
-- carry the same false sentence, including TPL-11 and TPL-12, which 079 built
-- and 080 left inactive deliberately pending approval. They will be switched on
-- with the wrong wording otherwise, and the sentence is true regardless of
-- whether a template is currently running. A third variant on
-- `adult-coloring-clean-line` — "an African-American woman journaling under a
-- …" — is replaced by the same sentence for the same reason.

begin;

update prompt_templates t
   set variables_json = (
         select jsonb_agg(
                  case when v->>'name' = 'subject'
                       then jsonb_set(
                              v, '{placeholder}',
                              to_jsonb(
                                'Leave blank and the selected page''s own brief '
                                'becomes the subject — or the template''s blocks, '
                                'if no page is selected. Anything typed here '
                                'replaces that brief completely.'::text))
                       else v end
                  order by ord)
           from jsonb_array_elements(t.variables_json) with ordinality as e(v, ord)
       )
 where exists (select 1 from jsonb_array_elements(t.variables_json) v
                where v->>'name' = 'subject');

do $$
declare n int;
begin
  -- Nineteen templates carry a subject slot — ten active, nine not — and all
  -- nineteen now agree.
  select count(*) into n from prompt_templates t, lateral
         jsonb_array_elements(t.variables_json) v
   where v->>'name' = 'subject'
     and v->>'placeholder' like 'Leave blank and the selected page%';
  if n <> 19 then raise exception 'expected 19 subject placeholders, got %', n; end if;

  -- Neither old wording survives anywhere, including on inactive templates
  -- that could be reactivated later.
  if exists (
    select 1 from prompt_templates t, lateral
           jsonb_array_elements(t.variables_json) v
     where v->>'name' = 'subject'
       and (v->>'placeholder' like '%the template decides%'
         or v->>'placeholder' like '%From the item brief%')
  ) then raise exception 'an old subject placeholder is still in the library'; end if;

  -- The slot itself is untouched: rebuilding the array must not drop the other
  -- variables or change the subject's name, type or requiredness.
  -- Every subject slot is a textarea.
  select count(*) into n from prompt_templates t, lateral
         jsonb_array_elements(t.variables_json) v
   where v->>'name' = 'subject' and v->>'type' = 'textarea';
  if n <> 19 then raise exception 'a subject slot is not a textarea (%)', n; end if;

  -- Requiredness is deliberately split and must survive untouched: the ten
  -- templates that draw a figure require a subject, the nine pattern and
  -- place pages do not. Asserted because the first draft of this guard assumed
  -- every subject was optional, which is TPL-10's shape and not TPL-01's.
  select count(*) into n from prompt_templates t, lateral
         jsonb_array_elements(t.variables_json) v
   where v->>'name' = 'subject' and (v->>'required')::boolean;
  if n <> 10 then raise exception 'the required/optional split moved (%)', n; end if;

  -- And no template lost a sibling variable when the array was rebuilt: the
  -- five active figure templates carry five slots each and vvs-front-print
  -- carries six. TPL-11 and TPL-12 are not in this set — they carry fewer, and
  -- that is their shape as 079 built them, not damage from this migration.
  select count(*) into n from prompt_templates
   where jsonb_array_length(variables_json) >= 5;
  if n <> 6 then raise exception 'expected 6 five-slot templates, got %', n; end if;
end $$;

commit;

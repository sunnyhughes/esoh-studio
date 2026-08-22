-- 018_pages_without_people.sql
--
-- The Quote, Symbol and Decorative templates each carried the room blocks —
-- hs-environment, hs-furnishing, hs-seasonal-restraint — and all three density
-- blocks, none of which belong on a page whose composition block opens with
-- "No people."
--
-- The result was a prompt arguing with itself: "No people ... a clear open area
-- at the centre left completely empty" against "the setting is complete and
-- lived-in, built from real furniture, with the described subject as the clear
-- focus." The room won, the reserved centre never appeared, and the overlay had
-- nowhere to land.
--
-- Density goes too. On a pattern page the art style already says how dense the
-- pattern is; the density blocks only restate it in the language of furniture.
--
-- The Environment page keeps all of it: it has no people but it does have a
-- setting, and the setting is the subject. Those are separate facts, which is
-- why has_people is recorded rather than inferred from the composition.

begin;

alter table prompt_templates
  add column if not exists has_people boolean not null default true;

comment on column prompt_templates.has_people is
  'Whether this page type puts people on the page. Gates the ethnicity line, '
  'which is meaningless on a page of pattern and reads as a stray instruction.';

update prompt_templates set has_people = false
 where page_type in ('Quote page', 'Symbol page', 'Decorative page',
                     'Environment page');

delete from template_blocks tb
 using prompt_templates t, prompt_blocks b
 where tb.template_id = t.id
   and tb.block_id = b.id
   and t.page_type in ('Quote page', 'Symbol page', 'Decorative page')
   and b.slug in ('hs-environment', 'hs-furnishing', 'hs-seasonal-restraint',
                  'hs-density-open', 'hs-density-medium', 'hs-density-dense');

commit;

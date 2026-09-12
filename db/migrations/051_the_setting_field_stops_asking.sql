-- 051_the_setting_field_stops_asking.sql
--
-- 050 deactivated `hs-environment`, so nothing consumes {{environment}} any
-- more. Seven coloring-book templates still offer a **Setting** field in their
-- form — a combo with five room descriptions in its dropdown — which now
-- collects a value and throws it away without saying so.
--
-- That is the exact failure D103 is about, in a new place: the form asks a
-- question the engine has stopped listening to. Worse, the field's own
-- dropdown is where the living-room string in 050 came from, so leaving it up
-- invites someone to reintroduce the fault by choosing an option.
--
-- The setting belongs in the brief, which is what 050 decided. The field goes.

begin;

update prompt_templates
   set variables_json = (
         select coalesce(jsonb_agg(v order by ord), '[]'::jsonb)
           from jsonb_array_elements(variables_json) with ordinality as t(v, ord)
          where v ->> 'name' <> 'environment'
       ),
       updated_at = now()
 where category_id = (select id from categories where code = 'coloring-books')
   and variables_json::text like '%"environment"%';

do $$
declare n int;
begin
  select count(*) into n from prompt_templates
   where variables_json::text like '%"environment"%';
  if n <> 0 then
    raise exception 'a template still offers the Setting field (% rows)', n; end if;

  select count(*) into n from prompt_templates
   where jsonb_array_length(variables_json) = 0;
  if n <> 0 then
    raise exception 'a template was left with no variables at all (% rows)', n; end if;
end $$;

commit;

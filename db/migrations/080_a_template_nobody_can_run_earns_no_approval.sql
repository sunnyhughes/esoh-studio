-- 080_a_template_nobody_can_run_earns_no_approval.sql
--
-- 079 created TPL-11 and TPL-12 with `is_active = false`, reasoning that the
-- tool should not offer a kind of page nobody has approved, and that D31 makes
-- the approval Esoh's.
--
-- That is circular. `lib/prompt-engine.ts:64` serves only active templates, so
-- an inactive template cannot produce the page that would earn the approval it
-- is waiting for. The gate blocks the only thing that could open it.
--
-- It is also against precedent: 058 created all ten of TPL-01 to TPL-10 active
-- on the day they were written, before a single page had come out of any of
-- them. `is_active` in this schema means "offer this in the form", not "this
-- has been approved" — approval lives on the generated asset's own status, and
-- on `reference_images.usable_as_input` for anything promoted to an exemplar.
-- Those are the gates D31 actually asked for, and both still hold.
--
-- Active, then, on the same terms as the other ten. Whether the page is any
-- good is still Esoh's call and still gets made by looking at one.

begin;

update prompt_templates set is_active = true, updated_at = now()
 where slug in ('tpl-11-figure-on-pattern', 'tpl-12-group-on-pattern');

do $$
declare n int;
begin
  select count(*) into n from prompt_templates
   where slug in ('tpl-11-figure-on-pattern', 'tpl-12-group-on-pattern')
     and is_active;
  if n <> 2 then raise exception 'expected 2 active, got %', n; end if;

  -- The approval gates that do the work D31 asked for are untouched.
  select count(*) into n from reference_images
   where usable_as_input and page_type is not null;
  if n <> 14 then
    raise exception 'the exemplar set moved: % usable', n; end if;
end $$;

commit;

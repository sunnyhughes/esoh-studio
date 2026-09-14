-- 061_the_style_axes_follow_the_template.sql
--
-- 038 and 039 set `art_style` and `background_density` on all 180 rows against
-- the page types of the day. 056 re-authored African American Spring and moved
-- eleven of its fifteen pages to a different type, so those axes now describe
-- pages that no longer exist: slot 05 is a Quote page carrying Editorial Scene,
-- slot 14 a Quote page at Dense, slot 11 a Community scene rendered Celestial —
-- a register of "moon phases, stars, rays and drifting cloud" on a page of
-- people talking.
--
-- Two of the values are styles Esoh retired for the coloring books on
-- 2026-09-12: **Bold Minimal** and **Hand-Drawn Doodle**, both borrowed from the
-- VV-Styles apparel vocabulary in 038. "Few elements and generous empty space"
-- is right for a shirt that must read across a room and close to the opposite of
-- what an adult colourist wants from a page.
--
-- **Density now comes from Esoh's own `detail load`**, which `page_prompts_full`
-- assigns per template and holds constant within it — TPL-03 Light, TPL-01
-- Medium, TPL-02 Heavy, and so on. Four source values map onto the tool's three:
-- Light to Open, Light-Medium and Medium to Medium, Heavy to Dense. Nothing is
-- made sparser than Medium on a page with a figure on it; where a template wants
-- more openness than its density implies, its own white-space block from 058
-- says so in its own words.
--
-- Art style is not in the source material at all — it is the tool's axis, and
-- 038 filled it from the apparel library. It is set here by what the template
-- is: Editorial Scene wherever a page has a figure or a room in it (038's rule,
-- which D119 measured working), and a border register on the pages built from
-- motif and pattern, keeping whichever one a row already had unless it was
-- retired.

begin;

update items i set
  background_density = case t.slug
    when 'tpl-03-quote-border'       then 'Open'
    when 'tpl-02-support-circle'     then 'Dense'
    when 'tpl-04-healing-room'       then 'Dense'
    when 'tpl-09-outdoor-sanctuary'  then 'Dense'
    else 'Medium'
  end,
  art_style = case
    when t.has_people or t.page_type = 'Environment page' then 'Editorial Scene'
    when i.art_style in ('Botanical Line','Zentangle Pattern','Geometric Abstract','Celestial')
      then i.art_style
    else 'Botanical Line'
  end,
  updated_at = now()
 from prompt_templates t
where t.id = i.prompt_template_id
  and i.category_id = (select id from categories where code = 'coloring-books');

do $$
declare n int;
begin
  select count(*) into n from items i join categories c on c.id = i.category_id
   where c.code = 'coloring-books'
     and i.art_style in ('Bold Minimal','Hand-Drawn Doodle');
  if n <> 0 then raise exception '% rows still carry a retired apparel style', n; end if;

  -- A page with people on it is drawn as a scene, never as a border register.
  select count(*) into n
    from items i join prompt_templates t on t.id = i.prompt_template_id
   where t.has_people and i.art_style <> 'Editorial Scene';
  if n <> 0 then raise exception '% figure pages are not Editorial Scene', n; end if;

  -- A quote page needs its centre empty for the lettering that goes on later.
  select count(*) into n
    from items i join prompt_templates t on t.id = i.prompt_template_id
   where t.page_type = 'Quote page' and i.background_density <> 'Open';
  if n <> 0 then raise exception '% quote pages are not Open', n; end if;

  select count(*) into n from items i join categories c on c.id = i.category_id
   where c.code = 'coloring-books'
     and (i.art_style is null or i.background_density is null);
  if n <> 0 then raise exception '% rows lost an axis', n; end if;
end $$;

commit;

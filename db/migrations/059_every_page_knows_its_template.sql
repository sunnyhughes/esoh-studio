-- 059_every_page_knows_its_template.sql
--
-- 058 built ten templates where there had been six. Three of them serve Solo
-- portrait and two serve Community scene, so `page_type` alone no longer
-- identifies a template — a batch that selects on it would plan the same page
-- three times and pay for it three times.
--
-- Every page therefore carries its own `template_id`. 056 set the fifteen
-- African American Spring rows from the re-authored Spring library. The
-- remaining 165 come from `hs-folder/template_page_assignment_matrix.csv`, the
-- rebuilt assignment, which is content-aware rather than rotational: "Man
-- walking at sunrise in a neighborhood park" resolves to the walking template,
-- "Woman journaling by a rainy window" to the window template. It agrees with
-- the tracker's page type on 180 of 180 rows, where the workbook's version of
-- the same sheet agrees on 34.
--
-- African American Spring is left alone. Those fifteen rows were re-authored
-- against the interleaved book and their slots no longer mean what this matrix
-- thinks they mean.

begin;

update items set template_id = 'TPL-08', updated_at = now() where ref = 'African American Fall 01' and template_id is null;
update items set template_id = 'TPL-06', updated_at = now() where ref = 'African American Fall 02' and template_id is null;
update items set template_id = 'TPL-01', updated_at = now() where ref = 'African American Fall 03' and template_id is null;
update items set template_id = 'TPL-01', updated_at = now() where ref = 'African American Fall 04' and template_id is null;
update items set template_id = 'TPL-02', updated_at = now() where ref = 'African American Fall 05' and template_id is null;
update items set template_id = 'TPL-07', updated_at = now() where ref = 'African American Fall 06' and template_id is null;
update items set template_id = 'TPL-07', updated_at = now() where ref = 'African American Fall 07' and template_id is null;
update items set template_id = 'TPL-07', updated_at = now() where ref = 'African American Fall 08' and template_id is null;
update items set template_id = 'TPL-03', updated_at = now() where ref = 'African American Fall 09' and template_id is null;
update items set template_id = 'TPL-03', updated_at = now() where ref = 'African American Fall 10' and template_id is null;
update items set template_id = 'TPL-03', updated_at = now() where ref = 'African American Fall 11' and template_id is null;
update items set template_id = 'TPL-05', updated_at = now() where ref = 'African American Fall 12' and template_id is null;
update items set template_id = 'TPL-10', updated_at = now() where ref = 'African American Fall 13' and template_id is null;
update items set template_id = 'TPL-04', updated_at = now() where ref = 'African American Fall 14' and template_id is null;
update items set template_id = 'TPL-04', updated_at = now() where ref = 'African American Fall 15' and template_id is null;
update items set template_id = 'TPL-01', updated_at = now() where ref = 'African American Summer 01' and template_id is null;
update items set template_id = 'TPL-06', updated_at = now() where ref = 'African American Summer 02' and template_id is null;
update items set template_id = 'TPL-01', updated_at = now() where ref = 'African American Summer 03' and template_id is null;
update items set template_id = 'TPL-01', updated_at = now() where ref = 'African American Summer 04' and template_id is null;
update items set template_id = 'TPL-02', updated_at = now() where ref = 'African American Summer 05' and template_id is null;
update items set template_id = 'TPL-02', updated_at = now() where ref = 'African American Summer 06' and template_id is null;
update items set template_id = 'TPL-07', updated_at = now() where ref = 'African American Summer 07' and template_id is null;
update items set template_id = 'TPL-02', updated_at = now() where ref = 'African American Summer 08' and template_id is null;
update items set template_id = 'TPL-03', updated_at = now() where ref = 'African American Summer 09' and template_id is null;
update items set template_id = 'TPL-03', updated_at = now() where ref = 'African American Summer 10' and template_id is null;
update items set template_id = 'TPL-03', updated_at = now() where ref = 'African American Summer 11' and template_id is null;
update items set template_id = 'TPL-05', updated_at = now() where ref = 'African American Summer 12' and template_id is null;
update items set template_id = 'TPL-10', updated_at = now() where ref = 'African American Summer 13' and template_id is null;
update items set template_id = 'TPL-09', updated_at = now() where ref = 'African American Summer 14' and template_id is null;
update items set template_id = 'TPL-09', updated_at = now() where ref = 'African American Summer 15' and template_id is null;
update items set template_id = 'TPL-08', updated_at = now() where ref = 'African American Winter 01' and template_id is null;
update items set template_id = 'TPL-06', updated_at = now() where ref = 'African American Winter 02' and template_id is null;
update items set template_id = 'TPL-01', updated_at = now() where ref = 'African American Winter 03' and template_id is null;
update items set template_id = 'TPL-01', updated_at = now() where ref = 'African American Winter 04' and template_id is null;
update items set template_id = 'TPL-02', updated_at = now() where ref = 'African American Winter 05' and template_id is null;
update items set template_id = 'TPL-07', updated_at = now() where ref = 'African American Winter 06' and template_id is null;
update items set template_id = 'TPL-07', updated_at = now() where ref = 'African American Winter 07' and template_id is null;
update items set template_id = 'TPL-07', updated_at = now() where ref = 'African American Winter 08' and template_id is null;
update items set template_id = 'TPL-03', updated_at = now() where ref = 'African American Winter 09' and template_id is null;
update items set template_id = 'TPL-03', updated_at = now() where ref = 'African American Winter 10' and template_id is null;
update items set template_id = 'TPL-03', updated_at = now() where ref = 'African American Winter 11' and template_id is null;
update items set template_id = 'TPL-05', updated_at = now() where ref = 'African American Winter 12' and template_id is null;
update items set template_id = 'TPL-10', updated_at = now() where ref = 'African American Winter 13' and template_id is null;
update items set template_id = 'TPL-04', updated_at = now() where ref = 'African American Winter 14' and template_id is null;
update items set template_id = 'TPL-04', updated_at = now() where ref = 'African American Winter 15' and template_id is null;
update items set template_id = 'TPL-08', updated_at = now() where ref = 'Hispanic Fall 01' and template_id is null;
update items set template_id = 'TPL-06', updated_at = now() where ref = 'Hispanic Fall 02' and template_id is null;
update items set template_id = 'TPL-01', updated_at = now() where ref = 'Hispanic Fall 03' and template_id is null;
update items set template_id = 'TPL-01', updated_at = now() where ref = 'Hispanic Fall 04' and template_id is null;
update items set template_id = 'TPL-02', updated_at = now() where ref = 'Hispanic Fall 05' and template_id is null;
update items set template_id = 'TPL-02', updated_at = now() where ref = 'Hispanic Fall 06' and template_id is null;
update items set template_id = 'TPL-07', updated_at = now() where ref = 'Hispanic Fall 07' and template_id is null;
update items set template_id = 'TPL-07', updated_at = now() where ref = 'Hispanic Fall 08' and template_id is null;
update items set template_id = 'TPL-03', updated_at = now() where ref = 'Hispanic Fall 09' and template_id is null;
update items set template_id = 'TPL-03', updated_at = now() where ref = 'Hispanic Fall 10' and template_id is null;
update items set template_id = 'TPL-03', updated_at = now() where ref = 'Hispanic Fall 11' and template_id is null;
update items set template_id = 'TPL-05', updated_at = now() where ref = 'Hispanic Fall 12' and template_id is null;
update items set template_id = 'TPL-10', updated_at = now() where ref = 'Hispanic Fall 13' and template_id is null;
update items set template_id = 'TPL-04', updated_at = now() where ref = 'Hispanic Fall 14' and template_id is null;
update items set template_id = 'TPL-04', updated_at = now() where ref = 'Hispanic Fall 15' and template_id is null;
update items set template_id = 'TPL-08', updated_at = now() where ref = 'Hispanic Spring 01' and template_id is null;
update items set template_id = 'TPL-06', updated_at = now() where ref = 'Hispanic Spring 02' and template_id is null;
update items set template_id = 'TPL-01', updated_at = now() where ref = 'Hispanic Spring 03' and template_id is null;
update items set template_id = 'TPL-01', updated_at = now() where ref = 'Hispanic Spring 04' and template_id is null;
update items set template_id = 'TPL-02', updated_at = now() where ref = 'Hispanic Spring 05' and template_id is null;
update items set template_id = 'TPL-07', updated_at = now() where ref = 'Hispanic Spring 06' and template_id is null;
update items set template_id = 'TPL-02', updated_at = now() where ref = 'Hispanic Spring 07' and template_id is null;
update items set template_id = 'TPL-07', updated_at = now() where ref = 'Hispanic Spring 08' and template_id is null;
update items set template_id = 'TPL-03', updated_at = now() where ref = 'Hispanic Spring 09' and template_id is null;
update items set template_id = 'TPL-03', updated_at = now() where ref = 'Hispanic Spring 10' and template_id is null;
update items set template_id = 'TPL-03', updated_at = now() where ref = 'Hispanic Spring 11' and template_id is null;
update items set template_id = 'TPL-05', updated_at = now() where ref = 'Hispanic Spring 12' and template_id is null;
update items set template_id = 'TPL-10', updated_at = now() where ref = 'Hispanic Spring 13' and template_id is null;
update items set template_id = 'TPL-04', updated_at = now() where ref = 'Hispanic Spring 14' and template_id is null;
update items set template_id = 'TPL-09', updated_at = now() where ref = 'Hispanic Spring 15' and template_id is null;
update items set template_id = 'TPL-01', updated_at = now() where ref = 'Hispanic Summer 01' and template_id is null;
update items set template_id = 'TPL-06', updated_at = now() where ref = 'Hispanic Summer 02' and template_id is null;
update items set template_id = 'TPL-01', updated_at = now() where ref = 'Hispanic Summer 03' and template_id is null;
update items set template_id = 'TPL-01', updated_at = now() where ref = 'Hispanic Summer 04' and template_id is null;
update items set template_id = 'TPL-02', updated_at = now() where ref = 'Hispanic Summer 05' and template_id is null;
update items set template_id = 'TPL-02', updated_at = now() where ref = 'Hispanic Summer 06' and template_id is null;
update items set template_id = 'TPL-07', updated_at = now() where ref = 'Hispanic Summer 07' and template_id is null;
update items set template_id = 'TPL-07', updated_at = now() where ref = 'Hispanic Summer 08' and template_id is null;
update items set template_id = 'TPL-03', updated_at = now() where ref = 'Hispanic Summer 09' and template_id is null;
update items set template_id = 'TPL-03', updated_at = now() where ref = 'Hispanic Summer 10' and template_id is null;
update items set template_id = 'TPL-03', updated_at = now() where ref = 'Hispanic Summer 11' and template_id is null;
update items set template_id = 'TPL-05', updated_at = now() where ref = 'Hispanic Summer 12' and template_id is null;
update items set template_id = 'TPL-10', updated_at = now() where ref = 'Hispanic Summer 13' and template_id is null;
update items set template_id = 'TPL-09', updated_at = now() where ref = 'Hispanic Summer 14' and template_id is null;
update items set template_id = 'TPL-09', updated_at = now() where ref = 'Hispanic Summer 15' and template_id is null;
update items set template_id = 'TPL-08', updated_at = now() where ref = 'Hispanic Winter 01' and template_id is null;
update items set template_id = 'TPL-06', updated_at = now() where ref = 'Hispanic Winter 02' and template_id is null;
update items set template_id = 'TPL-01', updated_at = now() where ref = 'Hispanic Winter 03' and template_id is null;
update items set template_id = 'TPL-01', updated_at = now() where ref = 'Hispanic Winter 04' and template_id is null;
update items set template_id = 'TPL-02', updated_at = now() where ref = 'Hispanic Winter 05' and template_id is null;
update items set template_id = 'TPL-07', updated_at = now() where ref = 'Hispanic Winter 06' and template_id is null;
update items set template_id = 'TPL-07', updated_at = now() where ref = 'Hispanic Winter 07' and template_id is null;
update items set template_id = 'TPL-02', updated_at = now() where ref = 'Hispanic Winter 08' and template_id is null;
update items set template_id = 'TPL-03', updated_at = now() where ref = 'Hispanic Winter 09' and template_id is null;
update items set template_id = 'TPL-03', updated_at = now() where ref = 'Hispanic Winter 10' and template_id is null;
update items set template_id = 'TPL-03', updated_at = now() where ref = 'Hispanic Winter 11' and template_id is null;
update items set template_id = 'TPL-05', updated_at = now() where ref = 'Hispanic Winter 12' and template_id is null;
update items set template_id = 'TPL-10', updated_at = now() where ref = 'Hispanic Winter 13' and template_id is null;
update items set template_id = 'TPL-04', updated_at = now() where ref = 'Hispanic Winter 14' and template_id is null;
update items set template_id = 'TPL-04', updated_at = now() where ref = 'Hispanic Winter 15' and template_id is null;
update items set template_id = 'TPL-08', updated_at = now() where ref = 'Multiracial Fall 01' and template_id is null;
update items set template_id = 'TPL-06', updated_at = now() where ref = 'Multiracial Fall 02' and template_id is null;
update items set template_id = 'TPL-01', updated_at = now() where ref = 'Multiracial Fall 03' and template_id is null;
update items set template_id = 'TPL-01', updated_at = now() where ref = 'Multiracial Fall 04' and template_id is null;
update items set template_id = 'TPL-02', updated_at = now() where ref = 'Multiracial Fall 05' and template_id is null;
update items set template_id = 'TPL-02', updated_at = now() where ref = 'Multiracial Fall 06' and template_id is null;
update items set template_id = 'TPL-07', updated_at = now() where ref = 'Multiracial Fall 07' and template_id is null;
update items set template_id = 'TPL-07', updated_at = now() where ref = 'Multiracial Fall 08' and template_id is null;
update items set template_id = 'TPL-03', updated_at = now() where ref = 'Multiracial Fall 09' and template_id is null;
update items set template_id = 'TPL-03', updated_at = now() where ref = 'Multiracial Fall 10' and template_id is null;
update items set template_id = 'TPL-03', updated_at = now() where ref = 'Multiracial Fall 11' and template_id is null;
update items set template_id = 'TPL-05', updated_at = now() where ref = 'Multiracial Fall 12' and template_id is null;
update items set template_id = 'TPL-10', updated_at = now() where ref = 'Multiracial Fall 13' and template_id is null;
update items set template_id = 'TPL-04', updated_at = now() where ref = 'Multiracial Fall 14' and template_id is null;
update items set template_id = 'TPL-04', updated_at = now() where ref = 'Multiracial Fall 15' and template_id is null;
update items set template_id = 'TPL-01', updated_at = now() where ref = 'Multiracial Spring 01' and template_id is null;
update items set template_id = 'TPL-06', updated_at = now() where ref = 'Multiracial Spring 02' and template_id is null;
update items set template_id = 'TPL-08', updated_at = now() where ref = 'Multiracial Spring 03' and template_id is null;
update items set template_id = 'TPL-01', updated_at = now() where ref = 'Multiracial Spring 04' and template_id is null;
update items set template_id = 'TPL-02', updated_at = now() where ref = 'Multiracial Spring 05' and template_id is null;
update items set template_id = 'TPL-02', updated_at = now() where ref = 'Multiracial Spring 06' and template_id is null;
update items set template_id = 'TPL-07', updated_at = now() where ref = 'Multiracial Spring 07' and template_id is null;
update items set template_id = 'TPL-07', updated_at = now() where ref = 'Multiracial Spring 08' and template_id is null;
update items set template_id = 'TPL-03', updated_at = now() where ref = 'Multiracial Spring 09' and template_id is null;
update items set template_id = 'TPL-03', updated_at = now() where ref = 'Multiracial Spring 10' and template_id is null;
update items set template_id = 'TPL-03', updated_at = now() where ref = 'Multiracial Spring 11' and template_id is null;
update items set template_id = 'TPL-05', updated_at = now() where ref = 'Multiracial Spring 12' and template_id is null;
update items set template_id = 'TPL-10', updated_at = now() where ref = 'Multiracial Spring 13' and template_id is null;
update items set template_id = 'TPL-04', updated_at = now() where ref = 'Multiracial Spring 14' and template_id is null;
update items set template_id = 'TPL-04', updated_at = now() where ref = 'Multiracial Spring 15' and template_id is null;
update items set template_id = 'TPL-01', updated_at = now() where ref = 'Multiracial Summer 01' and template_id is null;
update items set template_id = 'TPL-06', updated_at = now() where ref = 'Multiracial Summer 02' and template_id is null;
update items set template_id = 'TPL-01', updated_at = now() where ref = 'Multiracial Summer 03' and template_id is null;
update items set template_id = 'TPL-01', updated_at = now() where ref = 'Multiracial Summer 04' and template_id is null;
update items set template_id = 'TPL-02', updated_at = now() where ref = 'Multiracial Summer 05' and template_id is null;
update items set template_id = 'TPL-02', updated_at = now() where ref = 'Multiracial Summer 06' and template_id is null;
update items set template_id = 'TPL-07', updated_at = now() where ref = 'Multiracial Summer 07' and template_id is null;
update items set template_id = 'TPL-07', updated_at = now() where ref = 'Multiracial Summer 08' and template_id is null;
update items set template_id = 'TPL-03', updated_at = now() where ref = 'Multiracial Summer 09' and template_id is null;
update items set template_id = 'TPL-03', updated_at = now() where ref = 'Multiracial Summer 10' and template_id is null;
update items set template_id = 'TPL-03', updated_at = now() where ref = 'Multiracial Summer 11' and template_id is null;
update items set template_id = 'TPL-05', updated_at = now() where ref = 'Multiracial Summer 12' and template_id is null;
update items set template_id = 'TPL-10', updated_at = now() where ref = 'Multiracial Summer 13' and template_id is null;
update items set template_id = 'TPL-09', updated_at = now() where ref = 'Multiracial Summer 14' and template_id is null;
update items set template_id = 'TPL-09', updated_at = now() where ref = 'Multiracial Summer 15' and template_id is null;
update items set template_id = 'TPL-08', updated_at = now() where ref = 'Multiracial Winter 01' and template_id is null;
update items set template_id = 'TPL-06', updated_at = now() where ref = 'Multiracial Winter 02' and template_id is null;
update items set template_id = 'TPL-01', updated_at = now() where ref = 'Multiracial Winter 03' and template_id is null;
update items set template_id = 'TPL-01', updated_at = now() where ref = 'Multiracial Winter 04' and template_id is null;
update items set template_id = 'TPL-02', updated_at = now() where ref = 'Multiracial Winter 05' and template_id is null;
update items set template_id = 'TPL-02', updated_at = now() where ref = 'Multiracial Winter 06' and template_id is null;
update items set template_id = 'TPL-07', updated_at = now() where ref = 'Multiracial Winter 07' and template_id is null;
update items set template_id = 'TPL-07', updated_at = now() where ref = 'Multiracial Winter 08' and template_id is null;
update items set template_id = 'TPL-03', updated_at = now() where ref = 'Multiracial Winter 09' and template_id is null;
update items set template_id = 'TPL-03', updated_at = now() where ref = 'Multiracial Winter 10' and template_id is null;
update items set template_id = 'TPL-03', updated_at = now() where ref = 'Multiracial Winter 11' and template_id is null;
update items set template_id = 'TPL-05', updated_at = now() where ref = 'Multiracial Winter 12' and template_id is null;
update items set template_id = 'TPL-10', updated_at = now() where ref = 'Multiracial Winter 13' and template_id is null;
update items set template_id = 'TPL-04', updated_at = now() where ref = 'Multiracial Winter 14' and template_id is null;
update items set template_id = 'TPL-04', updated_at = now() where ref = 'Multiracial Winter 15' and template_id is null;

do $$
declare n int;
begin
  select count(*) into n from items i join categories c on i.category_id = c.id
   where c.code = 'coloring-books' and i.template_id is null;
  if n <> 0 then raise exception '% coloring pages still have no template', n; end if;

  -- A page's template must serve that page's type, or D56's guard will refuse
  -- the generation later, one page at a time, in the middle of a batch.
  select count(*) into n
    from items i
    join categories c on c.id = i.category_id
    join prompt_templates t on upper(left(t.slug, 6)) = i.template_id and t.is_active
   where c.code = 'coloring-books' and t.page_type is distinct from i.page_type;
  if n <> 0 then raise exception '% pages point at a template for another page type', n; end if;
end $$;

commit;

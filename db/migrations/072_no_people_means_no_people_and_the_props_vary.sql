-- 072_no_people_means_no_people_and_the_props_vary.sql
--
-- Esoh's review of the first African American Spring book, three findings.
--
-- **1. "12 is just wrong. It looks like a sketch drawing of a caucasian woman."**
-- `African American Spring 12` is an Environment page. TPL-04's composition
-- opens "No people." and there is a person on it. The `reading-nook` exemplar it
-- copied — armchair, lamp, window branches, bookshelf, side table, rug — has
-- nobody in it, so the figure is the model's own addition. And because 062
-- withholds the line-identity block from people-free templates, which is D117's
-- finding and still right, nothing said who she was, so she came out white.
--
-- 062 gave `hs-no-figures` to TPL-05 and TPL-10 only, reasoning that TPL-03,
-- TPL-04 and TPL-09 already open with "No people" and that saying it twice was
-- D123's mistake. **D123 was about leaves** — the one object the model most
-- associates with the season, named in a prohibition. "No people" is not that,
-- and it has held in every generation on record until this one. Once was not
-- enough here, so all five people-free templates now carry it.
--
-- **2. "Every image has the same un-unique leaf plant and a form of blanket."**
-- Counted: six active blocks name a plant, three name a blanket or quilt, and
-- every exemplar contains both. D131's mechanism — what a block names gets
-- drawn — applied six times over.
--
-- Esoh's correction matters: "The plant and blanket aren't bad items per se,
-- they just should have more variations such as flower types (roses, tulips,
-- daisies) and the blanket (printed throw, crocheted, shawl)." So they are not
-- removed. **Four of the six mentions are Esoh's own template zone directives**
-- from `template_prompt_framework` — TPL-04's "Lower: rug, books, slippers,
-- plants", TPL-07's "Top: plants, string lights", TPL-08's "Lower: blanket,
-- book, mug, plant", TPL-09's "plus plants and seating" — and those stay.
-- The variation goes into `hs-furnishing`, which is the model's own block and
-- reaches all seven scene templates, phrased the way 041 gave the season five
-- channels: a menu with "one of these" rather than a list that gets drawn whole.
--
-- **3. Personal details have never existed and were asked for.** Esoh: earrings,
-- jewellery, tattoos, moles — "it would be at my discretion of what those
-- details are". Nothing in `direction.md`, the memory or the workbook records
-- that request, so it is recorded now. The shape is D45's, already proven on
-- hair: a per-item column, a combo in the form that accepts anything typed, and
-- a block whose slot drops the whole block when the field is empty — so a page
-- Esoh has not annotated is unchanged, and one he has carries exactly what he
-- wrote.

begin;

-- 1 ---------------------------------------------------------------------
insert into template_blocks (template_id, block_id, position)
select t.id, b.id, 21
  from prompt_templates t, prompt_blocks b
 where b.slug = 'hs-no-figures'
   and t.is_active
   and t.slug in ('tpl-03-quote-border','tpl-04-healing-room','tpl-09-outdoor-sanctuary')
   and not exists (select 1 from template_blocks x
                    where x.template_id = t.id and x.block_id = b.id);

-- 2 ---------------------------------------------------------------------
update prompt_blocks set body_text = body_text ||
  ' Greenery and textiles change from page to page rather than repeating: the '
  'growing thing may be a trailing vine, a spiky succulent, a fern, a herb in a '
  'kitchen pot, or cut stems in a jar — tulips, roses, daisies, branches — and '
  'the textile may be a crocheted blanket, a printed throw, a pieced quilt, a '
  'woven shawl over the back of a chair. One of each is enough, and the next '
  'page picks a different one.',
  updated_at = now()
 where slug = 'hs-furnishing';

-- 3 ---------------------------------------------------------------------
alter table items add column if not exists personal_details text;

insert into prompt_blocks (kind, slug, label, body_text, category_id)
select 'subject', 'hs-personal-details', 'Personal details',
       'The figure carries {{personal_details}}, drawn in outline and left open '
       'inside so they can be coloured like any other area of the page.',
       id from categories where code = 'coloring-books'
   and not exists (select 1 from prompt_blocks where slug = 'hs-personal-details');

-- Beside hair and facial hair, which it belongs with.
insert into template_blocks (template_id, block_id, position)
select t.id, b.id, 35
  from prompt_templates t, prompt_blocks b
 where b.slug = 'hs-personal-details'
   and t.is_active and t.has_people
   and t.category_id = (select id from categories where code = 'coloring-books');

-- The form has to offer it, or it can only be set by hand in SQL.
update prompt_templates set
  variables_json = variables_json || jsonb_build_array(jsonb_build_object(
    'name', 'personal_details',
    'label', 'Personal details',
    'type', 'combo',
    'required', false,
    'placeholder', 'e.g. small gold hoops, a nose stud, a forearm tattoo, a beauty mark',
    'options', jsonb_build_array(
      'small gold hoop earrings', 'a pair of studs', 'a nose stud',
      'a beaded necklace', 'a pendant on a fine chain', 'stacked bangles',
      'a wedding band', 'a wristwatch', 'reading glasses',
      'a forearm tattoo', 'a small wrist tattoo', 'a beauty mark on one cheek',
      'freckles across the nose', 'painted nails'))),
  updated_at = now()
 where is_active and has_people
   and category_id = (select id from categories where code = 'coloring-books')
   and not variables_json::text like '%personal_details%';

do $$
declare n int;
begin
  select count(*) into n from prompt_templates t
   where t.is_active and not t.has_people
     and t.category_id = (select id from categories where code = 'coloring-books')
     and not exists (select 1 from template_blocks tb join prompt_blocks b on b.id = tb.block_id
                      where tb.template_id = t.id and b.slug = 'hs-no-figures');
  if n <> 0 then raise exception '% people-free templates still say it only once', n; end if;

  select count(*) into n from prompt_templates t
   where t.is_active and t.has_people
     and t.category_id = (select id from categories where code = 'coloring-books')
     and (not variables_json::text like '%personal_details%'
          or not exists (select 1 from template_blocks tb join prompt_blocks b on b.id = tb.block_id
                          where tb.template_id = t.id and b.slug = 'hs-personal-details'));
  if n <> 0 then raise exception '% figure templates cannot take personal details', n; end if;

  -- A page nobody has annotated must be unchanged: an empty slot drops its
  -- whole block, which is the behaviour D103 relies on.
  select count(*) into n from items where personal_details is not null;
  if n <> 0 then raise exception 'personal details were filled in without Esoh'; end if;
end $$;

commit;

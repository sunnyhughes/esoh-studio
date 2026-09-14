-- 056_african_american_spring_is_re_authored.sql
--
-- Step 1 of the source-of-truth rebuild (D133), scoped to the fifteen pages
-- Esoh chose to finish first.
--
-- The source is `docs/references/hs-folder/prompt-library-by-product-line.csv`
-- — 45 rows, 15 pages x 3 lines, Spring only. It is the only file that composes
-- the five inputs per page AND per line: base prompt, representation direction,
-- seasonal direction, page-specific prompt, negative prompt and print spec.
--
-- **This is not a merge, because the slots do not line up.** The database is
-- still on the old grouped book — 4 solo, 4 community, 3 quote, 1 symbol, 1
-- decorative, 2 environment. The re-authored Spring is interleaved, so slot 05
-- stops being a seven-adult community scene and becomes a quote page, slot 12
-- stops being a symbol cluster and becomes a reading nook, and slot 13 moves
-- the other way. Merging field by field would paste a community brief onto a
-- quote page. The fifteen rows are replaced wholesale; the old briefs remain in
-- git history.
--
-- Nothing is lost by that. The database's Spring briefs describe a book
-- structure that D133 retired.
--
-- Two vocabularies are reconciled here, as `00_PROJECT_OUTLINE.md` asked. The
-- library names a page by its template — "Window + journal reflection" — and
-- the tool names it by its abstract type. `items.page_type` keeps the abstract
-- type, because D56's mismatch guard and the composition blocks are keyed to
-- it, and the finer choice lands in the new `items.template_id`.

begin;

-- The plan, not yet the wiring: TPL-06 to TPL-10 have no prompt_templates row
-- until step 2, so this records the intended template as its code rather than a
-- foreign key that cannot yet resolve.
alter table items add column if not exists template_id text;
alter table items drop constraint if exists items_template_id_check;
alter table items add constraint items_template_id_check check (
  template_id is null or template_id in
    ('TPL-01','TPL-02','TPL-03','TPL-04','TPL-05',
     'TPL-06','TPL-07','TPL-08','TPL-09','TPL-10'));

-- 01  Spring Renewal Journal  [TPL-01 Solo portrait -> Solo portrait]
update items set
    title       = 'Spring Renewal Journal',
    page_type   = 'Solo portrait',
    template_id = 'TPL-01',
    brief       = 'African American woman with natural curls journaling beside a rainy window, potted plants and spring flowers nearby, tea mug and blanket, calm reflective expression, clear focal figure, simple cozy interior, coloring book line art.',
    quote_text  = null,
    updated_at  = now()
  where ref = 'African American Spring 01' and ethnicity_line = 'African American';

-- 02  Morning Path of Hope  [TPL-06 Walking reflection -> Solo portrait]
update items set
    title       = 'Morning Path of Hope',
    page_type   = 'Solo portrait',
    template_id = 'TPL-06',
    brief       = 'African American man walking peacefully on a spring morning path in a neighborhood park, sunrise behind budding trees, relaxed shoulders, hands comfortable at sides, simple path and open sky, coloring book line art.',
    quote_text  = null,
    updated_at  = now()
  where ref = 'African American Spring 02' and ethnicity_line = 'African American';

-- 03  Quiet Growth by the Window  [TPL-08 Window + journal reflection -> Solo portrait]
update items set
    title       = 'Quiet Growth by the Window',
    page_type   = 'Solo portrait',
    template_id = 'TPL-08',
    brief       = 'African American young adult seated near an open spring window, holding a journal and pen, plants on the sill, blanket and book nearby, relaxed breathing posture, simple background, coloring book line art.',
    quote_text  = null,
    updated_at  = now()
  where ref = 'African American Spring 03' and ethnicity_line = 'African American';

-- 04  Circle of Support  [TPL-02 Community scene -> Community scene]
update items set
    title       = 'Circle of Support',
    page_type   = 'Community scene',
    template_id = 'TPL-02',
    brief       = 'Four African American adults seated in a supportive circle in a bright community room, one person speaking while others listen with open body language, simple chairs, spring light through windows, no text on signs, coloring book line art.',
    quote_text  = null,
    hair        = null,   -- the hair block describes one figure
    updated_at  = now()
  where ref = 'African American Spring 04' and ethnicity_line = 'African American';

-- 05  Healing One Day at a Time  [TPL-03 Quote page -> Quote page]
update items set
    title       = 'Healing One Day at a Time',
    page_type   = 'Quote page',
    template_id = 'TPL-03',
    brief       = 'Centered hand-lettered phrase: Healing one day at a time. Surround with an open spring floral border of blossoms, butterflies, leaves, and small raindrops; generous white space around words; coloring book line art.',
    quote_text  = 'Healing one day at a time.',
    hair        = null,   -- the hair block describes one figure
    updated_at  = now()
  where ref = 'African American Spring 05' and ethnicity_line = 'African American';

-- 06  Porch Talk and Tea  [TPL-07 Porch or patio conversation -> Community scene]
update items set
    title       = 'Porch Talk and Tea',
    page_type   = 'Community scene',
    template_id = 'TPL-07',
    brief       = 'Two African American women seated on a porch having a gentle supportive conversation over tea, potted spring flowers nearby, relaxed facial expressions, simple porch railing and open background, coloring book line art.',
    quote_text  = null,
    hair        = null,   -- the hair block describes one figure
    updated_at  = now()
  where ref = 'African American Spring 06' and ethnicity_line = 'African American';

-- 07  Restful Room  [TPL-04 Healing room interior -> Environment page]
update items set
    title       = 'Restful Room',
    page_type   = 'Environment page',
    template_id = 'TPL-04',
    brief       = 'Cozy bedroom sanctuary with a neatly made bed, open curtain showing simple spring branches, potted plant, books, candle, folded blanket, and journal on a side table, uncluttered coloring book line art.',
    quote_text  = null,
    hair        = null,   -- the hair block describes one figure
    updated_at  = now()
  where ref = 'African American Spring 07' and ethnicity_line = 'African American';

-- 08  Spring Hope Symbols  [TPL-05 Symbol cluster -> Symbol page]
update items set
    title       = 'Spring Hope Symbols',
    page_type   = 'Symbol page',
    template_id = 'TPL-05',
    brief       = 'Balanced spring symbol cluster with a central butterfly, surrounding flowers, dove, heart, journal, tea mug, small sunrise, and leaves; each object separated by white space; coloring book line art.',
    quote_text  = null,
    hair        = null,   -- the hair block describes one figure
    updated_at  = now()
  where ref = 'African American Spring 08' and ethnicity_line = 'African American';

-- 09  Peace Grows Here  [TPL-03 Quote page -> Quote page]
update items set
    title       = 'Peace Grows Here',
    page_type   = 'Quote page',
    template_id = 'TPL-03',
    brief       = 'Centered hand-lettered phrase: Peace grows here. Surround with a light spring garden border of leaves, flowers, and gentle raindrops; generous open coloring space; coloring book line art.',
    quote_text  = 'Peace grows here.',
    hair        = null,   -- the hair block describes one figure
    updated_at  = now()
  where ref = 'African American Spring 09' and ethnicity_line = 'African American';

-- 10  Rainy Window Reflection  [TPL-01 Solo portrait -> Solo portrait]
update items set
    title       = 'Rainy Window Reflection',
    page_type   = 'Solo portrait',
    template_id = 'TPL-01',
    brief       = 'African American woman sitting in a comfortable chair by a rainy spring window, holding a tea mug with a journal on her lap, simple plant and folded blanket nearby, peaceful expression, coloring book line art.',
    quote_text  = null,
    -- Esoh, 2026-09-14. D45: a blank hair field lets the model copy the
    -- exemplar's, which is how filled hair kept arriving.
    hair        = 'knotless braids',
    updated_at  = now()
  where ref = 'African American Spring 10' and ethnicity_line = 'African American';

-- 11  Community Encouragement  [TPL-02 Community scene -> Community scene]
update items set
    title       = 'Community Encouragement',
    page_type   = 'Community scene',
    template_id = 'TPL-02',
    brief       = 'Three African American adults offering encouragement in a calm meeting room, one standing with open hands while two people listen, a small table with tea cups, spring daylight through window, no readable signs, coloring book line art.',
    quote_text  = null,
    hair        = null,   -- the hair block describes one figure
    updated_at  = now()
  where ref = 'African American Spring 11' and ethnicity_line = 'African American';

-- 12  Reading Nook Reset  [TPL-04 Healing room interior -> Environment page]
update items set
    title       = 'Reading Nook Reset',
    page_type   = 'Environment page',
    template_id = 'TPL-04',
    brief       = 'Peaceful reading nook with a comfortable chair, folded blanket, stack of books, tea mug, small plant, open window with simple spring branches, and a journal on a side table, coloring book line art.',
    quote_text  = null,
    hair        = null,   -- the hair block describes one figure
    updated_at  = now()
  where ref = 'African American Spring 12' and ethnicity_line = 'African American';

-- 13  Flowers and Freedom  [TPL-05 Symbol cluster -> Symbol page]
update items set
    title       = 'Flowers and Freedom',
    page_type   = 'Symbol page',
    template_id = 'TPL-05',
    brief       = 'Central open journal with flowers flowing outward, small birds, hearts, leaves, and sunlight rays; balanced objects with open coloring spaces; coloring book line art.',
    quote_text  = null,
    hair        = null,   -- the hair block describes one figure
    updated_at  = now()
  where ref = 'African American Spring 13' and ethnicity_line = 'African American';

-- 14  I Am Allowed to Begin Again  [TPL-03 Quote page -> Quote page]
update items set
    title       = 'I Am Allowed to Begin Again',
    page_type   = 'Quote page',
    template_id = 'TPL-03',
    brief       = 'Centered hand-lettered phrase: I am allowed to begin again. Surround with a light border of butterflies, sprouting leaves, flower buds, and gentle rain; spacious composition; coloring book line art.',
    quote_text  = 'I am allowed to begin again.',
    hair        = null,   -- the hair block describes one figure
    updated_at  = now()
  where ref = 'African American Spring 14' and ethnicity_line = 'African American';

-- 15  Fresh Air and Grace  [TPL-08 Window + journal reflection -> Solo portrait]
update items set
    title       = 'Fresh Air and Grace',
    page_type   = 'Solo portrait',
    template_id = 'TPL-08',
    brief       = 'African American man sitting beside an open window, taking a slow breath with an open journal nearby, spring branches outside, light blanket and tea mug nearby, calm posture, coloring book line art.',
    quote_text  = null,
    -- Esoh, 2026-09-14: this page is a man. The library said "adult", which is
    -- the kind of blank the model fills with whatever the exemplars hold, and
    -- every approved Spring exemplar is a woman.
    hair        = 'cornrows',
    updated_at  = now()
  where ref = 'African American Spring 15' and ethnicity_line = 'African American';

do $$
declare n int;
begin
  select count(*) into n from items
   where ref like 'African American Spring%' and template_id is null;
  if n <> 0 then raise exception '% Spring rows have no template', n; end if;

  -- The re-authored Spring has no Decorative page and two Symbol pages.
  select count(*) into n from items
   where ref like 'African American Spring%' and page_type = 'Decorative page';
  if n <> 0 then raise exception 'a Decorative page survived the re-author'; end if;

  select count(*) into n from items
   where ref like 'African American Spring%' and page_type = 'Quote page'
     and nullif(trim(coalesce(quote_text,'')),'') is null;
  if n <> 0 then raise exception '% quote pages carry no quote', n; end if;

  -- Hair belongs only to pages with one figure on them, and every such page
  -- must carry one: a blank field lets the model copy the exemplar's (D45).
  select count(*) into n from items
   where ref like 'African American Spring%' and page_type <> 'Solo portrait'
     and hair is not null;
  if n <> 0 then raise exception 'hair survives on % non-portrait rows', n; end if;

  select count(*) into n from items
   where ref like 'African American Spring%' and page_type = 'Solo portrait'
     and hair is null;
  if n <> 0 then raise exception '% solo portraits carry no hairstyle', n; end if;
end $$;

commit;

-- 065_the_quote_library.sql
--
-- Step 5. `quote-and-affirmation-library.csv` holds all 36 affirmations — three
-- per line per season — each with a language, a category, a design motif, a
-- review status and, for the Spanish ones, a translation review status. The
-- tool held the quote text on the item and nothing else: no review state, no
-- language, and therefore nothing able to stop an unapproved quote being
-- lettered onto a page and exported into a book.
--
-- **It arrives as a table rather than more columns on `items`, because the
-- source models it as a library.** Nine of the 36 are `Assigned` to a page;
-- the other 27 are `Planned` and belong to no slot yet. A quote that can be
-- written before it is placed, and moved without rewriting the page, is a row
-- of its own.
--
-- **`items.quote_text` stays, and a trigger makes it impossible for it to
-- disagree with the library.** Twenty-one places read that column — the overlay
-- route, the prompt engine, the asset list, the form — and rewriting all of
-- them to join was the larger risk. 064 is the reason this is a trigger and not
-- a comment asking two copies to agree: they do not agree because someone asks
-- them to, they agree because nothing can write them apart.
--
-- **`items.quote_approval` from 063 is dropped.** The judgement belongs to the
-- quote, not to the page that borrows it, and holding it in both places is the
-- mistake 064 had to undo two commits ago. The gate now reads through the link.
--
-- **Spanish blocks.** All 12 Hispanic quotes are marked *Needs Native Review*,
-- and Esoh's launch tracker holds those four products until a native speaker has
-- seen them. That is now a condition a page cannot print without, rather than a
-- note in a spreadsheet.

begin;

create table quotes (
  id                        uuid        primary key default gen_random_uuid(),
  affirmation_id            text        not null unique,
  ethnicity_line            text        not null,
  season                    text        not null,
  page_title                text        null,
  quote_text                text        not null,
  language                  text        not null,
  quote_category            text        null,
  design_motif              text        null,
  review_status             text        not null default 'Draft',
  translation_review_status text        not null default 'N/A',
  usage_status              text        not null default 'Planned',
  notes                     text        null,
  created_at                timestamptz not null default now(),
  updated_at                timestamptz not null default now(),

  constraint quotes_review_check check (
    review_status in ('Draft','Pending','Approved','Changes Requested')),
  constraint quotes_translation_check check (
    translation_review_status in ('N/A','Needs Native Review','Reviewed')),
  constraint quotes_usage_check check (usage_status in ('Planned','Assigned','Retired'))
);
create index quotes_line_season_idx on quotes(ethnicity_line, season);
create trigger quotes_updated_at before update on quotes
  for each row execute function set_updated_at();

insert into quotes (affirmation_id, ethnicity_line, season, page_title, quote_text,
  language, quote_category, design_motif, review_status, translation_review_status,
  usage_status, notes) values
  ('AA-SPR-01', 'African American', 'Spring', 'Healing One Day at a Time',
   'Healing one day at a time.', 'English', 'Recovery progress', 'Spring blossoms, butterflies, leaves',
   'Approved', 'N/A', 'Assigned',
   'Use with TPL-03; place final editable text in Canva, Illustrator, or Affinity.');
insert into quotes (affirmation_id, ethnicity_line, season, page_title, quote_text,
  language, quote_category, design_motif, review_status, translation_review_status,
  usage_status, notes) values
  ('AA-SPR-02', 'African American', 'Spring', 'Peace Grows Here',
   'Peace grows here.', 'English', 'Peace and grounding', 'Garden leaves, small flowers, raindrops',
   'Approved', 'N/A', 'Assigned',
   'Use with TPL-03; keep border light and spacious.');
insert into quotes (affirmation_id, ethnicity_line, season, page_title, quote_text,
  language, quote_category, design_motif, review_status, translation_review_status,
  usage_status, notes) values
  ('AA-SPR-03', 'African American', 'Spring', 'I Am Allowed to Begin Again',
   'I am allowed to begin again.', 'English', 'Renewal', 'Butterflies, sprouting leaves, flower buds',
   'Approved', 'N/A', 'Assigned',
   'Use with TPL-03; center text with generous margins.');
insert into quotes (affirmation_id, ethnicity_line, season, page_title, quote_text,
  language, quote_category, design_motif, review_status, translation_review_status,
  usage_status, notes) values
  ('HSP-SPR-01', 'Hispanic', 'Spring', 'Un Día a la Vez',
   'Un día a la vez.', 'Spanish', 'Recovery progress', 'Spring blossoms, butterflies, leaves',
   'Pending', 'Needs Native Review', 'Assigned',
   'English meaning: One day at a time. Confirm accent marks and preferred audience phrasing with a fluent reviewer.');
insert into quotes (affirmation_id, ethnicity_line, season, page_title, quote_text,
  language, quote_category, design_motif, review_status, translation_review_status,
  usage_status, notes) values
  ('HSP-SPR-02', 'Hispanic', 'Spring', 'Mi Paz Importa',
   'Mi paz importa.', 'Spanish', 'Peace and grounding', 'Garden leaves, small flowers, raindrops',
   'Pending', 'Needs Native Review', 'Assigned',
   'English meaning: My peace matters. Confirm translation and cultural tone with a fluent reviewer.');
insert into quotes (affirmation_id, ethnicity_line, season, page_title, quote_text,
  language, quote_category, design_motif, review_status, translation_review_status,
  usage_status, notes) values
  ('HSP-SPR-03', 'Hispanic', 'Spring', 'Estoy Creciendo con Esperanza',
   'Estoy creciendo con esperanza.', 'Spanish', 'Renewal', 'Butterflies, sprouting leaves, flower buds',
   'Pending', 'Needs Native Review', 'Assigned',
   'English meaning: I am growing with hope. Confirm translation and cultural tone with a fluent reviewer.');
insert into quotes (affirmation_id, ethnicity_line, season, page_title, quote_text,
  language, quote_category, design_motif, review_status, translation_review_status,
  usage_status, notes) values
  ('MUL-SPR-01', 'Multiracial', 'Spring', 'New Beginnings Belong to Me',
   'New beginnings belong to me.', 'English', 'Renewal', 'Spring blossoms, butterflies, leaves',
   'Approved', 'N/A', 'Assigned',
   'Use inclusive visual motifs with no person required.');
insert into quotes (affirmation_id, ethnicity_line, season, page_title, quote_text,
  language, quote_category, design_motif, review_status, translation_review_status,
  usage_status, notes) values
  ('MUL-SPR-02', 'Multiracial', 'Spring', 'Healing Has Many Faces',
   'Healing has many faces.', 'English', 'Representation and belonging', 'Garden leaves, small flowers, raindrops',
   'Approved', 'N/A', 'Assigned',
   'Use a visually inclusive motif system; text remains editable.');
insert into quotes (affirmation_id, ethnicity_line, season, page_title, quote_text,
  language, quote_category, design_motif, review_status, translation_review_status,
  usage_status, notes) values
  ('MUL-SPR-03', 'Multiracial', 'Spring', 'I Am Safe to Grow',
   'I am safe to grow.', 'English', 'Safety and renewal', 'Butterflies, sprouting leaves, flower buds',
   'Approved', 'N/A', 'Assigned',
   'Use soft, spacious composition.');
insert into quotes (affirmation_id, ethnicity_line, season, page_title, quote_text,
  language, quote_category, design_motif, review_status, translation_review_status,
  usage_status, notes) values
  ('AA-SUM-01', 'African American', 'Summer', 'Future quote 1',
   'Joy is part of healing.', 'English', 'Joy and recovery', 'Sunflowers, sunlight, gentle waves',
   'Draft', 'N/A', 'Planned',
   'Summer quote candidate.');
insert into quotes (affirmation_id, ethnicity_line, season, page_title, quote_text,
  language, quote_category, design_motif, review_status, translation_review_status,
  usage_status, notes) values
  ('AA-SUM-02', 'African American', 'Summer', 'Future quote 2',
   'I choose freedom today.', 'English', 'Recovery choice', 'Sun rays, open path, flowers',
   'Draft', 'N/A', 'Planned',
   'Summer quote candidate.');
insert into quotes (affirmation_id, ethnicity_line, season, page_title, quote_text,
  language, quote_category, design_motif, review_status, translation_review_status,
  usage_status, notes) values
  ('AA-SUM-03', 'African American', 'Summer', 'Future quote 3',
   'My future is brighter than my past.', 'English', 'Hope and future', 'Sunlight, horizon, open sky',
   'Draft', 'N/A', 'Planned',
   'Summer quote candidate.');
insert into quotes (affirmation_id, ethnicity_line, season, page_title, quote_text,
  language, quote_category, design_motif, review_status, translation_review_status,
  usage_status, notes) values
  ('HSP-SUM-01', 'Hispanic', 'Summer', 'Future quote 1',
   'La sanación también puede tener alegría.', 'Spanish', 'Joy and recovery', 'Sunflowers, sunlight, gentle waves',
   'Pending', 'Needs Native Review', 'Planned',
   'English meaning: Healing can also have joy.');
insert into quotes (affirmation_id, ethnicity_line, season, page_title, quote_text,
  language, quote_category, design_motif, review_status, translation_review_status,
  usage_status, notes) values
  ('HSP-SUM-02', 'Hispanic', 'Summer', 'Future quote 2',
   'Sigo adelante.', 'Spanish', 'Recovery progress', 'Sun rays, open path, flowers',
   'Pending', 'Needs Native Review', 'Planned',
   'English meaning: I keep moving forward.');
insert into quotes (affirmation_id, ethnicity_line, season, page_title, quote_text,
  language, quote_category, design_motif, review_status, translation_review_status,
  usage_status, notes) values
  ('HSP-SUM-03', 'Hispanic', 'Summer', 'Future quote 3',
   'Hoy elijo calma.', 'Spanish', 'Peace and grounding', 'Sunlight, horizon, open sky',
   'Pending', 'Needs Native Review', 'Planned',
   'English meaning: Today I choose calm.');
insert into quotes (affirmation_id, ethnicity_line, season, page_title, quote_text,
  language, quote_category, design_motif, review_status, translation_review_status,
  usage_status, notes) values
  ('MUL-SUM-01', 'Multiracial', 'Summer', 'Future quote 1',
   'Freedom can look like peace.', 'English', 'Peace and recovery', 'Sunflowers, sunlight, gentle waves',
   'Draft', 'N/A', 'Planned',
   'Summer quote candidate.');
insert into quotes (affirmation_id, ethnicity_line, season, page_title, quote_text,
  language, quote_category, design_motif, review_status, translation_review_status,
  usage_status, notes) values
  ('MUL-SUM-02', 'Multiracial', 'Summer', 'Future quote 2',
   'My joy counts too.', 'English', 'Joy and worth', 'Sun rays, open path, flowers',
   'Draft', 'N/A', 'Planned',
   'Summer quote candidate.');
insert into quotes (affirmation_id, ethnicity_line, season, page_title, quote_text,
  language, quote_category, design_motif, review_status, translation_review_status,
  usage_status, notes) values
  ('MUL-SUM-03', 'Multiracial', 'Summer', 'Future quote 3',
   'I am becoming.', 'English', 'Growth', 'Sunlight, horizon, open sky',
   'Draft', 'N/A', 'Planned',
   'Summer quote candidate.');
insert into quotes (affirmation_id, ethnicity_line, season, page_title, quote_text,
  language, quote_category, design_motif, review_status, translation_review_status,
  usage_status, notes) values
  ('AA-FAL-01', 'African American', 'Fall', 'Future quote 1',
   'Let go and grow.', 'English', 'Release and growth', 'Autumn leaves, tea mug, acorns',
   'Draft', 'N/A', 'Planned',
   'Fall quote candidate.');
insert into quotes (affirmation_id, ethnicity_line, season, page_title, quote_text,
  language, quote_category, design_motif, review_status, translation_review_status,
  usage_status, notes) values
  ('AA-FAL-02', 'African American', 'Fall', 'Future quote 2',
   'Rest is recovery too.', 'English', 'Rest and recovery', 'Blanket, candle, falling leaves',
   'Draft', 'N/A', 'Planned',
   'Fall quote candidate.');
insert into quotes (affirmation_id, ethnicity_line, season, page_title, quote_text,
  language, quote_category, design_motif, review_status, translation_review_status,
  usage_status, notes) values
  ('AA-FAL-03', 'African American', 'Fall', 'Future quote 3',
   'My story is still unfolding.', 'English', 'Hope and future', 'Leaves, journal, open path',
   'Draft', 'N/A', 'Planned',
   'Fall quote candidate.');
insert into quotes (affirmation_id, ethnicity_line, season, page_title, quote_text,
  language, quote_category, design_motif, review_status, translation_review_status,
  usage_status, notes) values
  ('HSP-FAL-01', 'Hispanic', 'Fall', 'Future quote 1',
   'Puedo descansar.', 'Spanish', 'Rest and recovery', 'Autumn leaves, tea mug, acorns',
   'Pending', 'Needs Native Review', 'Planned',
   'English meaning: I can rest.');
insert into quotes (affirmation_id, ethnicity_line, season, page_title, quote_text,
  language, quote_category, design_motif, review_status, translation_review_status,
  usage_status, notes) values
  ('HSP-FAL-02', 'Hispanic', 'Fall', 'Future quote 2',
   'Estoy aprendiendo a soltar.', 'Spanish', 'Release and growth', 'Blanket, candle, falling leaves',
   'Pending', 'Needs Native Review', 'Planned',
   'English meaning: I am learning to let go.');
insert into quotes (affirmation_id, ethnicity_line, season, page_title, quote_text,
  language, quote_category, design_motif, review_status, translation_review_status,
  usage_status, notes) values
  ('HSP-FAL-03', 'Hispanic', 'Fall', 'Future quote 3',
   'Todavía hay luz para mí.', 'Spanish', 'Hope and future', 'Leaves, journal, open path',
   'Pending', 'Needs Native Review', 'Planned',
   'English meaning: There is still light for me.');
insert into quotes (affirmation_id, ethnicity_line, season, page_title, quote_text,
  language, quote_category, design_motif, review_status, translation_review_status,
  usage_status, notes) values
  ('MUL-FAL-01', 'Multiracial', 'Fall', 'Future quote 1',
   'I release what no longer holds me.', 'English', 'Release and growth', 'Autumn leaves, tea mug, acorns',
   'Draft', 'N/A', 'Planned',
   'Fall quote candidate.');
insert into quotes (affirmation_id, ethnicity_line, season, page_title, quote_text,
  language, quote_category, design_motif, review_status, translation_review_status,
  usage_status, notes) values
  ('MUL-FAL-02', 'Multiracial', 'Fall', 'Future quote 2',
   'I can rest without guilt.', 'English', 'Rest and recovery', 'Blanket, candle, falling leaves',
   'Draft', 'N/A', 'Planned',
   'Fall quote candidate.');
insert into quotes (affirmation_id, ethnicity_line, season, page_title, quote_text,
  language, quote_category, design_motif, review_status, translation_review_status,
  usage_status, notes) values
  ('MUL-FAL-03', 'Multiracial', 'Fall', 'Future quote 3',
   'Change does not erase my worth.', 'English', 'Worth and change', 'Leaves, journal, open path',
   'Draft', 'N/A', 'Planned',
   'Fall quote candidate.');
insert into quotes (affirmation_id, ethnicity_line, season, page_title, quote_text,
  language, quote_category, design_motif, review_status, translation_review_status,
  usage_status, notes) values
  ('AA-WIN-01', 'African American', 'Winter', 'Future quote 1',
   'Hope lives here.', 'English', 'Hope', 'Snowflakes, candle, stars',
   'Draft', 'N/A', 'Planned',
   'Winter quote candidate.');
insert into quotes (affirmation_id, ethnicity_line, season, page_title, quote_text,
  language, quote_category, design_motif, review_status, translation_review_status,
  usage_status, notes) values
  ('AA-WIN-02', 'African American', 'Winter', 'Future quote 2',
   'I can be gentle with myself.', 'English', 'Self-compassion', 'Blanket, mug, winter window',
   'Draft', 'N/A', 'Planned',
   'Winter quote candidate.');
insert into quotes (affirmation_id, ethnicity_line, season, page_title, quote_text,
  language, quote_category, design_motif, review_status, translation_review_status,
  usage_status, notes) values
  ('AA-WIN-03', 'African American', 'Winter', 'Future quote 3',
   'Light returns.', 'English', 'Hope and resilience', 'Candle, stars, winter branches',
   'Draft', 'N/A', 'Planned',
   'Winter quote candidate.');
insert into quotes (affirmation_id, ethnicity_line, season, page_title, quote_text,
  language, quote_category, design_motif, review_status, translation_review_status,
  usage_status, notes) values
  ('HSP-WIN-01', 'Hispanic', 'Winter', 'Future quote 1',
   'La esperanza regresa.', 'Spanish', 'Hope', 'Snowflakes, candle, stars',
   'Pending', 'Needs Native Review', 'Planned',
   'English meaning: Hope returns.');
insert into quotes (affirmation_id, ethnicity_line, season, page_title, quote_text,
  language, quote_category, design_motif, review_status, translation_review_status,
  usage_status, notes) values
  ('HSP-WIN-02', 'Hispanic', 'Winter', 'Future quote 2',
   'Merezco ternura.', 'Spanish', 'Self-compassion', 'Blanket, mug, winter window',
   'Pending', 'Needs Native Review', 'Planned',
   'English meaning: I deserve tenderness.');
insert into quotes (affirmation_id, ethnicity_line, season, page_title, quote_text,
  language, quote_category, design_motif, review_status, translation_review_status,
  usage_status, notes) values
  ('HSP-WIN-03', 'Hispanic', 'Winter', 'Future quote 3',
   'Poco a poco.', 'Spanish', 'Recovery progress', 'Candle, stars, winter branches',
   'Pending', 'Needs Native Review', 'Planned',
   'English meaning: Little by little.');
insert into quotes (affirmation_id, ethnicity_line, season, page_title, quote_text,
  language, quote_category, design_motif, review_status, translation_review_status,
  usage_status, notes) values
  ('MUL-WIN-01', 'Multiracial', 'Winter', 'Future quote 1',
   'Warmth can begin within.', 'English', 'Inner comfort', 'Snowflakes, candle, stars',
   'Draft', 'N/A', 'Planned',
   'Winter quote candidate.');
insert into quotes (affirmation_id, ethnicity_line, season, page_title, quote_text,
  language, quote_category, design_motif, review_status, translation_review_status,
  usage_status, notes) values
  ('MUL-WIN-02', 'Multiracial', 'Winter', 'Future quote 2',
   'I am still here, and that matters.', 'English', 'Resilience', 'Blanket, mug, winter window',
   'Draft', 'N/A', 'Planned',
   'Winter quote candidate.');
insert into quotes (affirmation_id, ethnicity_line, season, page_title, quote_text,
  language, quote_category, design_motif, review_status, translation_review_status,
  usage_status, notes) values
  ('MUL-WIN-03', 'Multiracial', 'Winter', 'Future quote 3',
   'Gentleness is strength.', 'English', 'Self-compassion', 'Candle, stars, winter branches',
   'Draft', 'N/A', 'Planned',
   'Winter quote candidate.');

alter table items add column if not exists quote_id uuid
  references quotes(id) on delete set null;
create index if not exists items_quote_id_idx on items(quote_id);

-- The nine the library has actually placed. Its page numbers follow the
-- interleaved book (05, 09, 14), which is the book African American Spring now
-- is after 056; the other lines' Spring pages still sit on the grouped slots and
-- will link when their season is converted.
update items i
   set quote_id = q.id, updated_at = now()
  from quotes q
 where q.usage_status = 'Assigned'
   and q.ethnicity_line = i.ethnicity_line
   and q.season = i.season
   and i.ref = q.ethnicity_line || ' ' || q.season || ' ' ||
       (select page_number from (values
         ('AA-SPR-01','05'),('AA-SPR-02','09'),('AA-SPR-03','14'),
         ('HSP-SPR-01','05'),('HSP-SPR-02','09'),('HSP-SPR-03','14'),
         ('MUL-SPR-01','05'),('MUL-SPR-02','09'),('MUL-SPR-03','14')
       ) as m(aid, page_number) where m.aid = q.affirmation_id);

-- Nothing can write the mirror and the library apart.
create or replace function items_quote_text_follows_library() returns trigger as $fn$
begin
  if new.quote_id is not null then
    select quote_text into new.quote_text from quotes where id = new.quote_id;
  end if;
  return new;
end $fn$ language plpgsql;

create trigger items_quote_text_mirror
  before insert or update of quote_id, quote_text on items
  for each row execute function items_quote_text_follows_library();

update items set quote_id = quote_id where quote_id is not null;

alter table items drop constraint if exists items_quote_approval_check;
alter table items drop column if exists quote_approval;

create or replace view page_readiness as
select
  i.id            as item_id,
  i.collection_id,
  i.ref,
  i.title,
  i.page_type,
  a.id            as asset_id,
  a.storage_path,
  a.status        as asset_status,
  a.metadata_json as asset_metadata,
  (a.metadata_json -> 'overlay') is not null as lettered,
  case
    when a.id is null
      then 'No page has been generated yet.'
    when a.status <> 'approved'
      then 'Generated but not kept — the art has not been approved.'
    when i.page_type = 'Quote page' and q.id is null
      then 'No approved affirmation is assigned to this page.'
    when i.page_type = 'Quote page' and q.review_status <> 'Approved'
      then 'The affirmation is ' || lower(q.review_status) || ', not approved.'
    when i.page_type = 'Quote page' and q.translation_review_status = 'Needs Native Review'
      then 'The Spanish still needs a native-speaker review.'
    when i.page_type = 'Quote page' and (a.metadata_json -> 'overlay') is null
      then 'Generated but not lettered — the quote is still missing.'
    when i.cultural_review_status = 'Changes Requested'
      then 'Cultural review asked for changes.'
    when i.cultural_review_status <> 'Approved'
      then 'Cultural review is ' || lower(i.cultural_review_status) || '.'
    when i.overall_approval = 'Hold'
      then 'On hold.'
    when i.overall_approval <> 'Approved'
      then 'Not signed off — overall approval is still outstanding.'
    else null
  end as blocked
from items i
left join quotes q on q.id = i.quote_id
left join lateral (
  select g.id, g.storage_path, g.status, g.metadata_json
    from generated_assets g
   where g.item_id = i.id and g.purged_at is null
   order by (g.status = 'approved') desc,
            (i.page_type = 'Quote page'
              and (g.metadata_json -> 'overlay') is not null) desc,
            g.created_at desc
   limit 1
) a on true;

do $$
declare n int;
begin
  select count(*) into n from quotes;
  if n <> 36 then raise exception 'expected 36 quotes, got %', n; end if;

  select count(*) into n from quotes where language = 'Spanish'
     and translation_review_status <> 'Needs Native Review';
  if n <> 0 then raise exception '% Spanish quotes are not gated on review', n; end if;

  select count(*) into n from items where quote_id is not null;
  if n <> 9 then raise exception 'expected 9 assigned quotes, got %', n; end if;

  -- The mirror cannot disagree with the library.
  select count(*) into n from items i join quotes q on q.id = i.quote_id
   where i.quote_text is distinct from q.quote_text;
  if n <> 0 then raise exception 'the quote mirror drifted on % rows', n; end if;

  -- And the trigger holds against a direct write.
  update items set quote_text = 'tampered'
   where quote_id is not null and ref = 'African American Spring 05';
  select count(*) into n from items i join quotes q on q.id = i.quote_id
   where i.quote_text is distinct from q.quote_text;
  if n <> 0 then raise exception 'the mirror could be written apart'; end if;
end $$;

commit;

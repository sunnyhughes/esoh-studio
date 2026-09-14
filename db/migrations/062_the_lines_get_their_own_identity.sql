-- 062_the_lines_get_their_own_identity.sql
--
-- Step 3 of the source-of-truth rebuild. The most serious gap on the list, and
-- the oldest: `art_direction_specs` gives each of the three lines nine columns
-- of guidance including an explicit **forbidden** list, and the tool's entire
-- implementation of it has been one generated sentence — "The figure is African
-- American." The forbidden lists have never reached a prompt. For a
-- trauma-informed recovery product that is the gap worth closing first.
--
-- The lineage C text is used: 3,776 characters against 1,899 in August, and no
-- column shared between the lines, where the August version had six of nine
-- identical across all three.
--
-- **What the block carries, and what it deliberately leaves alone.** Character
-- rules, scene rules, the forbidden list and the closing identity note. Not
-- `line style` or `detail level`, which the existing global blocks already
-- state and which have been measured working; not `seasonal cues`, because
-- `hs-seasonal-restraint` is the product of 041, 043, 048 and 049 and a second
-- seasonal voice would be the D125 shape — two blocks describing one thing,
-- the later one winning silently. Not `quote page style`, which belongs on
-- TPL-03 and is left for its own migration.
--
-- **The forbidden list goes in verbatim.** §2.5's law is that *technique* is
-- stated positively and never negatively, while *content may be excluded by
-- name* — "No people" and "No border or frame" have been obeyed in every
-- generation on record. Stereotypes, trauma imagery, violence, drug use,
-- visible injury, police scenes, weapons and restraints are content.
--
-- **The line block reaches figure templates only.** `00_PROJECT_OUTLINE.md`
-- found this independently of D117 and put it plainly: representation rules
-- going to pages with no people on them are "a reliable way to make an image
-- tool put a person in your empty bedroom scene." Five templates have figures;
-- those five get it.
--
-- Selection works the way `art_style` and `background_density` already do — a
-- nullable column on the block, matched in `getBlocks`. A block naming no line
-- applies to every line, which is the shape a general rule would take.

begin;

alter table prompt_blocks add column if not exists ethnicity_line text;
alter table prompt_blocks drop constraint if exists prompt_blocks_line_check;
alter table prompt_blocks add constraint prompt_blocks_line_check check (
  ethnicity_line is null
  or ethnicity_line in ('African American','Hispanic','Multiracial'));
create index if not exists prompt_blocks_ethnicity_line_idx
  on prompt_blocks(ethnicity_line);

-- African American
insert into prompt_blocks (kind, slug, label, body_text, category_id, ethnicity_line)
select 'subject', 'hs-line-african-american', 'African American line identity',
       'African American adults with varied skin tones and contemporary features; natural curls, locs, braids, twists, afros, silk presses, and protective styles may appear across the collection. Avoid repeating one hairstyle. Homes, porches, neighborhood parks, community rooms, gardens, libraries, kitchens, and family spaces that feel recognizably lived in. Favor ordinary moments of dignity, connection, and progress. The line should feel contemporary, warm, dignified, and distinctly Black American without implying one single Black experience. Do not draw: Stereotypes, costume-like cultural props, trauma imagery, violence, drug use, visible injury, police scenes, weapons, restraints, or despair-centered compositions.',
       id, 'African American' from categories where code = 'coloring-books';

insert into template_blocks (template_id, block_id, position)
select t.id, b.id, 35
  from prompt_templates t, prompt_blocks b
 where b.slug = 'hs-line-african-american'
   and t.is_active and t.has_people
   and t.category_id = (select id from categories where code = 'coloring-books');

-- Hispanic
insert into prompt_blocks (kind, slug, label, body_text, category_id, ethnicity_line)
select 'subject', 'hs-line-hispanic', 'Hispanic line identity',
       'Hispanic American adults with varied skin tones, facial structures, hair textures, curls, waves, straight styles, braids, and contemporary everyday hairstyles. Vary ages, body types, and presentation. Use lived-in apartments, kitchens, patios, courtyards, gardens, community centers, neighborhood walks, family tables, and quiet personal spaces. Small details such as handmade ceramics, woven textiles, potted herbs, family photos, or simple tile can appear selectively. Hispanic identity should be visible through believable people, relationships, homes, and selective cultural details—not a checklist of clichés. Do not assume one nationality. Do not draw: Pan-Latin stereotypes, costume-like clothing, forced flags or national symbols, exaggerated features, trauma imagery, violence, drug use, visible injury, police scenes, weapons, or crisis-centered scenes.',
       id, 'Hispanic' from categories where code = 'coloring-books';

insert into template_blocks (template_id, block_id, position)
select t.id, b.id, 35
  from prompt_templates t, prompt_blocks b
 where b.slug = 'hs-line-hispanic'
   and t.is_active and t.has_people
   and t.category_id = (select id from categories where code = 'coloring-books');

-- Multiracial
insert into prompt_blocks (kind, slug, label, body_text, category_id, ethnicity_line)
select 'subject', 'hs-line-multiracial', 'Multiracial line identity',
       'Multiracial adults with visibly varied complexions, hair textures, facial features, and contemporary styles; representation should include different combinations rather than one repeated look. Blended families, mixed-background friendships, apartments, parks, community rooms, kitchens, porches, and personal retreats. Make belonging and everyday connection visually central. The line should communicate that multiracial identity is ordinary, complex, and whole—not an aesthetic effect added to a generic character. Do not draw: Tokenized diversity, exaggerated mixed features, stereotypes, crisis imagery, violence, drug use, visible injury, police scenes, weapons, or distress-centered compositions.',
       id, 'Multiracial' from categories where code = 'coloring-books';

insert into template_blocks (template_id, block_id, position)
select t.id, b.id, 35
  from prompt_templates t, prompt_blocks b
 where b.slug = 'hs-line-multiracial'
   and t.is_active and t.has_people
   and t.category_id = (select id from categories where code = 'coloring-books');

-- TPL-05 and TPL-10 are the two people-free templates whose composition
-- directive does not already say so; TPL-03, TPL-04 and TPL-09 each open with
-- "No people" and saying it twice is the shape that failed in D123.
insert into prompt_blocks (kind, slug, label, body_text, category_id)
select 'composition', 'hs-no-figures', 'No figures on this page',
       'No people and no parts of people. The objects are the whole subject.',
       id from categories where code = 'coloring-books';

insert into template_blocks (template_id, block_id, position)
select t.id, b.id, 21
  from prompt_templates t, prompt_blocks b
 where b.slug = 'hs-no-figures'
   and t.slug in ('tpl-05-symbol-cluster','tpl-10-decorative-border');

do $$
declare n int;
begin
  select count(*) into n from prompt_blocks
   where ethnicity_line is not null and is_active;
  if n <> 3 then raise exception 'expected 3 line blocks, got %', n; end if;

  -- Every figure template carries all three; the engine picks one by line.
  select count(*) into n from prompt_templates t
   where t.is_active and t.has_people
     and t.category_id = (select id from categories where code = 'coloring-books')
     and (select count(*) from template_blocks tb
            join prompt_blocks b on b.id = tb.block_id
           where tb.template_id = t.id and b.ethnicity_line is not null) <> 3;
  if n <> 0 then raise exception '% figure templates are missing a line block', n; end if;

  -- And no page without people is offered one.
  select count(*) into n from prompt_templates t
    join template_blocks tb on tb.template_id = t.id
    join prompt_blocks b on b.id = tb.block_id
   where t.is_active and not t.has_people and b.ethnicity_line is not null;
  if n <> 0 then raise exception 'a people-free template carries a line block'; end if;

  -- The forbidden lists actually arrived.
  select count(*) into n from prompt_blocks
   where ethnicity_line is not null and body_text not like '%Do not draw:%';
  if n <> 0 then raise exception '% line blocks carry no forbidden list', n; end if;
end $$;

commit;

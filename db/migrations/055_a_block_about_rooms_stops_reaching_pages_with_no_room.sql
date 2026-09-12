-- 055_a_block_about_rooms_stops_reaching_pages_with_no_room.sql
--
-- From the first batch run (D129's own first use). Three Winter Symbol pages,
-- byte-identical prompts outside their briefs. Two came back as symbol
-- clusters. `Multiracial Winter 12` came back as a **living room** — a fringed
-- rug with a border, a quilt pieced into blocks, a cushion with a woven
-- design, floorboards and a chair — with the symbols floating over it, on a
-- page whose own composition block reads "No people and no scene."
--
-- It drew the block's examples. `hs-texture-as-pattern` was written by 047 for
-- D122, to give Environment and Solo pages the decoration a real surface
-- carries, and it names a rug, a quilt, a cushion, floorboards, a chair and
-- "two rooms" in order to illustrate a rule about *decoration*. On a page with
-- no scene in it those examples are the only concrete nouns in the block, and
-- the model drew all five. **§2.5 again, a fifth time: what a block names, a
-- page may well contain, whatever the naming was for.** D123 was the same shape
-- from the opposite direction — leaves named in order to be forbidden.
--
-- The block was attached to all six templates, so Quote and Decorative pages
-- carry the same loaded gun and have simply not fired it yet.
--
-- **Removing it outright would have been wrong**, which is why this is a split
-- and not a delete. The block opens with "Form is described by outline" — §3.5,
-- the single most load-bearing sentence in the library — and closes with every
-- element being a closed shape with white inside it. Both belong on all six
-- page types. Only the furniture belongs to pages that have furniture.
--
-- So: the universal half becomes its own block on all six, and
-- `hs-texture-as-pattern` keeps its name, keeps its examples, and reaches only
-- the three templates that have a room in them.

begin;

insert into prompt_blocks (kind, slug, label, body_text, category_id)
select 'output', 'hs-form-in-outline', 'Form is outline',
       'Form is described by outline. Every element on the page is a closed '
       'shape with clear white inside it.',
       id
  from categories where code = 'coloring-books';

-- Position 60, immediately before the decoration block at 61, so the rule
-- still reads ahead of the examples on the pages that keep both.
insert into template_blocks (template_id, block_id, position)
select t.id,
       (select id from prompt_blocks where slug = 'hs-form-in-outline'),
       60
  from prompt_templates t
 where t.category_id = (select id from categories where code = 'coloring-books')
   and t.page_type is not null;

update prompt_blocks set body_text =
  'Surfaces carry the decoration a real object would have — a rug with a '
  'border and a repeating motif, a quilt pieced into blocks, a cushion with a '
  'woven design, the grain running along floorboards, a pattern in the fabric '
  'of a chair. Decoration is drawn as further closed shapes to colour, each '
  'one large enough to take a pencil, and two rooms are furnished with '
  'different patterns from each other.',
  label = 'Surfaces carry decoration',
  updated_at = now()
 where slug = 'hs-texture-as-pattern';

-- A page with no scene does not get the furniture.
delete from template_blocks tb
 using prompt_templates t, prompt_blocks b
 where tb.template_id = t.id
   and tb.block_id = b.id
   and b.slug = 'hs-texture-as-pattern'
   and t.page_type in ('Quote page', 'Symbol page', 'Decorative page');

do $$
declare n int; body text;
begin
  select count(*) into n from template_blocks tb
    join prompt_blocks b on b.id = tb.block_id
   where b.slug = 'hs-texture-as-pattern';
  if n <> 3 then
    raise exception 'the decoration block reaches % templates, expected 3', n; end if;

  select count(*) into n from template_blocks tb
    join prompt_blocks b on b.id = tb.block_id
   where b.slug = 'hs-form-in-outline';
  if n <> 6 then
    raise exception 'the outline rule reaches % templates, expected 6', n; end if;

  -- §3.5 must not have been lost on the way through.
  select body_text into body from prompt_blocks where slug = 'hs-form-in-outline';
  if body not like 'Form is described by outline.%' then
    raise exception 'the outline rule did not survive the split'; end if;

  -- And no template may carry the furniture without a room to put it in.
  if exists (
    select 1 from template_blocks tb
      join prompt_templates t on t.id = tb.template_id
      join prompt_blocks b on b.id = tb.block_id
     where b.slug = 'hs-texture-as-pattern'
       and t.page_type in ('Quote page','Symbol page','Decorative page')) then
    raise exception 'a no-scene page still carries the furniture examples'; end if;
end $$;

commit;

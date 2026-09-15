-- 079_a_figure_on_a_patterned_ground.sql
--
-- Esoh, looking at the two Decorative pages from 077's re-runs:
--
--   "I looked at the two images that have end to end drawing and I was
--    wondering how that would look on a solo or group image. ... I do like the
--    backgrounds but its the fact that the background pattern of the image is
--    geometric and repetitive as well as a coffee cup is the centerpiece of the
--    image. That's really off."
--
-- Three separate judgments in that, and they pull apart cleanly:
--
--   1. **The edge-to-edge ground is right.** Keep it.
--   2. **A repeating geometric tile is wrong.** The ground should grow and
--      change across the page, not repeat one motif in rows.
--   3. **A mug cannot be the centrepiece.** TPL-10 is a pattern page with
--      comfort objects set into it, so a mug is exactly what it draws. The page
--      he is describing is a *figure* on that ground, and no template makes one.
--
-- So this is a new kind of page rather than a fix. TPL-11 and TPL-12 stand
-- beside TPL-01 and TPL-02, they do not replace them.
--
-- **It has to be a template and not a brief.** TPL-01 says "light background
-- context, open lower corners" and "Leave 35-45 percent open colorable space";
-- TPL-02 says "Keep background under 30 percent detail". Asking a brief for a
-- filled ground against those is the exact arrangement 078 just measured
-- failing 6 of 6 — one brief clause bracketed by two block clauses saying the
-- opposite. The blocks have to be the ones that say it.
--
-- Three things the composition blocks do deliberately:
--
--   * **The figure is given a size.** "At least half the height of the page."
--     078's finding was that a named quantity lands where an adjective does
--     not; D112's countable limit is the same shape. "Centerpiece" is not a
--     drawable instruction and "half the page" is.
--   * **The ground is told to vary.** "Changing across the page rather than
--     repeating one motif in rows or tiles" answers the repetition complaint
--     directly, and names the failure mode rather than hoping for variety.
--   * **A clear band follows the figure's outline.** This is the craft problem
--     underneath the request: a figure on a filled ground stops reading as a
--     figure unless something separates it. Without this the line work merges
--     and the page becomes the seek-and-find that §3.5 and D47 exist to
--     prevent.
--
-- The white space blocks carry the risk this design creates. Asking for a full
-- ground is the shortest route to the D110 failure — hatching, stippling and
-- shading, which measure as "detail" and cannot be coloured. Named and excluded
-- by content, per D46, and the ground is required to be closed shapes with
-- white between them, each big enough to take a pencil.
--
-- No density block is attached. `hs-density-open|medium|dense` all describe how
-- full a *room* is — furniture, side tables, things people keep out — and these
-- pages have no room in them. The composition block sets the density itself.
--
-- Both are `is_active = false` until Esoh has looked at a page from each. The
-- tool should not offer a kind of page nobody has approved, and D31 makes the
-- approval his.

begin;

-- ----------------------------------------------------------------- the blocks

insert into prompt_blocks (kind, slug, label, body_text, category_id)
select 'composition', 'hs-comp-tpl-11-figure-on-pattern',
       'Figure on Patterned Ground composition',
       'One person large in the frame, drawn from the waist or knees up and '
       'filling at least half the height of the page, as the unmistakable '
       'centre of the picture. Behind them the page is filled to all four '
       'edges with growing things — ferns, leaves, blossoms, trailing stems, '
       'seed heads — at several different scales, changing across the page '
       'rather than repeating one motif in rows or tiles. A clear band of open '
       'white follows the outline of the figure and separates them from the '
       'growth behind, so the person reads first and the ground reads second.',
       id from categories where code = 'coloring-books';

insert into prompt_blocks (kind, slug, label, body_text, category_id)
select 'composition', 'hs-space-tpl-11-figure-on-pattern',
       'Figure on Patterned Ground white space',
       'The figure, their clothing, their hair and anything they hold stay '
       'open and uncluttered inside their outlines — the pattern is behind '
       'them, never on them. The ground is built from many separate outlined '
       'shapes with white between them, each one large enough to take a '
       'pencil. No hatching, no stippling, no shading and no filled areas '
       'anywhere on the page.',
       id from categories where code = 'coloring-books';

insert into prompt_blocks (kind, slug, label, body_text, category_id)
select 'composition', 'hs-comp-tpl-12-group-on-pattern',
       'Group on Patterned Ground composition',
       'Three or four people together in a curved arrangement across the '
       'middle of the page, drawn from the waist up and filling at least half '
       'its height, with one clear interaction between them as the centre of '
       'the picture. Behind and between them the page is filled to all four '
       'edges with growing things — ferns, leaves, blossoms, trailing stems, '
       'seed heads — at several different scales, changing across the page '
       'rather than repeating one motif in rows or tiles. A clear band of open '
       'white follows the outline of the group and separates them from the '
       'growth behind, so the people read first and the ground reads second.',
       id from categories where code = 'coloring-books';

insert into prompt_blocks (kind, slug, label, body_text, category_id)
select 'composition', 'hs-space-tpl-12-group-on-pattern',
       'Group on Patterned Ground white space',
       'The figures, their clothing, their hair and anything they hold stay '
       'open and uncluttered inside their outlines — the pattern is behind '
       'them, never on them. The ground is built from many separate outlined '
       'shapes with white between them, each one large enough to take a '
       'pencil. No hatching, no stippling, no shading and no filled areas '
       'anywhere on the page.',
       id from categories where code = 'coloring-books';

-- -------------------------------------------------------------- the templates

insert into prompt_templates
  (slug, name, description, category_id, page_type, has_people,
   variables_json, default_settings, is_active)
select 'tpl-11-figure-on-pattern', 'Figure on Patterned Ground',
       'TPL-11 — Figure on Patterned Ground. Serves Solo portrait pages. '
       'A single figure large in the frame against growth filling the page to '
       'every edge. Held inactive until a page from it is approved.',
       s.category_id, 'Solo portrait', true,
       s.variables_json, s.default_settings, false
  from prompt_templates s where s.slug = 'hs-solo-portrait';

insert into prompt_templates
  (slug, name, description, category_id, page_type, has_people,
   variables_json, default_settings, is_active)
select 'tpl-12-group-on-pattern', 'Group on Patterned Ground',
       'TPL-12 — Group on Patterned Ground. Serves Community scene pages. '
       'Three or four figures against growth filling the page to every edge. '
       'Held inactive until a page from it is approved.',
       s.category_id, 'Community scene', true,
       s.variables_json, s.default_settings, false
  from prompt_templates s where s.slug = 'hs-community-scene';

-- Inherit the wiring of the template each one stands beside, minus every
-- composition block: the density blocks and the old background rules are the
-- two things this page type is defined by not having.
insert into template_blocks (template_id, block_id, position)
select n.id, tb.block_id, tb.position
  from prompt_templates n, template_blocks tb
  join prompt_templates s on s.id = tb.template_id
  join prompt_blocks b on b.id = tb.block_id
 where n.slug = 'tpl-11-figure-on-pattern' and s.slug = 'hs-solo-portrait'
   and b.kind <> 'composition';

insert into template_blocks (template_id, block_id, position)
select n.id, tb.block_id, tb.position
  from prompt_templates n, template_blocks tb
  join prompt_templates s on s.id = tb.template_id
  join prompt_blocks b on b.id = tb.block_id
 where n.slug = 'tpl-12-group-on-pattern' and s.slug = 'hs-community-scene'
   and b.kind <> 'composition';

insert into template_blocks (template_id, block_id, position)
select n.id, b.id, 20 from prompt_templates n, prompt_blocks b
 where n.slug = 'tpl-11-figure-on-pattern'
   and b.slug = 'hs-comp-tpl-11-figure-on-pattern';
insert into template_blocks (template_id, block_id, position)
select n.id, b.id, 46 from prompt_templates n, prompt_blocks b
 where n.slug = 'tpl-11-figure-on-pattern'
   and b.slug = 'hs-space-tpl-11-figure-on-pattern';
insert into template_blocks (template_id, block_id, position)
select n.id, b.id, 20 from prompt_templates n, prompt_blocks b
 where n.slug = 'tpl-12-group-on-pattern'
   and b.slug = 'hs-comp-tpl-12-group-on-pattern';
insert into template_blocks (template_id, block_id, position)
select n.id, b.id, 46 from prompt_templates n, prompt_blocks b
 where n.slug = 'tpl-12-group-on-pattern'
   and b.slug = 'hs-space-tpl-12-group-on-pattern';

-- ------------------------------------------------------------------ assertions

do $$
declare n int; t text;
begin
  for t in select unnest(array['tpl-11-figure-on-pattern',
                               'tpl-12-group-on-pattern'])
  loop
    -- The line identity block must reach these pages. 062 gives it only to
    -- templates with figures, and D137 recorded what happens when a page with
    -- a person on it does not get one: the figure reads as white.
    select count(*) into n from prompt_templates where slug = t and has_people;
    if n <> 1 then raise exception '% would not carry a line identity', t; end if;

    -- Exactly one composition and one white space block, and no density block.
    select count(*) into n
      from template_blocks tb
      join prompt_templates pt on pt.id = tb.template_id
      join prompt_blocks b on b.id = tb.block_id
     where pt.slug = t and b.kind = 'composition';
    if n <> 2 then
      raise exception '% has % composition blocks, expected 2', t, n; end if;

    select count(*) into n
      from template_blocks tb
      join prompt_templates pt on pt.id = tb.template_id
      join prompt_blocks b on b.id = tb.block_id
     where pt.slug = t and b.slug like 'hs-density-%';
    if n <> 0 then raise exception '% picked up a room density block', t; end if;

    -- Inactive until Esoh has seen one (D31).
    select count(*) into n from prompt_templates where slug = t and is_active;
    if n <> 0 then raise exception '% went live unapproved', t; end if;
  end loop;

  -- The three things Esoh asked for, stated in the blocks rather than hoped for.
  select body_text into t from prompt_blocks
   where slug = 'hs-comp-tpl-11-figure-on-pattern';
  if t !~* 'at least half the height' then
    raise exception 'the figure has no size'; end if;
  if t !~* 'rather than repeating one motif' then
    raise exception 'the ground is not told to vary'; end if;
  if t !~* 'all four edges' then
    raise exception 'the ground does not reach the edges'; end if;
  if t !~* 'band of open white follows the outline' then
    raise exception 'nothing separates the figure from the ground'; end if;

  -- The failure this design invites, excluded by name (D46, D110).
  select body_text into t from prompt_blocks
   where slug = 'hs-space-tpl-11-figure-on-pattern';
  if t !~* 'no hatching' or t !~* 'stippling' or t !~* 'shading' then
    raise exception 'the dense ground is not held to outline'; end if;
end $$;

commit;

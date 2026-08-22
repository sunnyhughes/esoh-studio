-- 014_hair_is_data.sql
--
-- Three corrections from Esoh, all of them the same mistake in different
-- places: style blocks were deciding things that belong to the request.
--
-- 1. HAIR IS ITEM DATA (D45, never implemented).
--    hs-figure-rendering said hair follows "whatever style the person wears",
--    which names no style at all — so the model took the exemplar's. Filled
--    hair will keep coming back for as long as nothing says what the hair is.
--    Hairstyle and facial hair become item columns and form fields, chosen
--    per page: braids, afro, short fade, locs, twists, and so on. The style
--    block keeps only the rendering rule, which is that they are drawn open
--    enough to colour — hair and beard are colourable areas like any other.
--
-- 2. "OPEN" MEANT UNCROWDED, NOT UNFURNISHED.
--    hs-style-editorial-scene asserted "an uncluttered setting, with open sky
--    and ground" — a fullness decision sitting inside an art style, where no
--    form control can reach it. It fought hs-density-dense and hs-furnishing
--    in the same prompt and, being first, it won. That is why choosing Dense
--    produced a bare room. Fullness now belongs to the density blocks only.
--
-- 3. THE ITEM COULD NEVER DESCRIBE ITS OWN SETTING.
--    hs-environment needs {{environment}}; nothing supplied it from the item,
--    so the one block that says what is in the room was dropped from every
--    item-driven generation. items.visual_elements now feeds it.

begin;

alter table items add column if not exists hair text;
alter table items add column if not exists facial_hair text;

comment on column items.hair is
  'Hairstyle for the figure, e.g. "box braids", "short fade with a lineup". '
  'Per-item because encoding one texture as a style rule stereotypes (D45).';
comment on column items.facial_hair is
  'Facial hair, e.g. "full beard", "clean-shaven". Null leaves it unstated.';

-- 1. Hair -------------------------------------------------------------------

update prompt_blocks set body_text =
  'Clothing and skin are drawn as open white areas with only the lines that '
  'describe their form — a seam, a cuff, a fold. Faces are clean and unmarked. '
  'Hair and facial hair are drawn as outlined sections with white inside them, '
  'never filled in and never shaded, so they can be coloured like any other '
  'area of the page.'
 where slug = 'hs-figure-rendering';

insert into prompt_blocks (kind, slug, label, body_text)
values
  ('subject', 'hs-hair', 'Hairstyle',
   'The hair is {{hair}}, drawn as outlined sections with white inside.'),
  ('subject', 'hs-facial-hair', 'Facial hair',
   'The facial hair is {{facial_hair}}, drawn in outline with white inside.')
on conflict (slug) do update set body_text = excluded.body_text;

insert into template_blocks (template_id, block_id, position)
select t.id, b.id, p.position
  from prompt_templates t
  cross join (values ('hs-hair', 33), ('hs-facial-hair', 34)) as p(slug, position)
  join prompt_blocks b on b.slug = p.slug
 where t.page_type is not null
   and exists (select 1 from template_blocks tb
                join prompt_blocks fb on fb.id = tb.block_id
               where tb.template_id = t.id and fb.slug = 'hs-figure-rendering')
on conflict do nothing;

-- 2. Fullness is a density decision, not an art style -----------------------

update prompt_blocks set body_text =
  'A black and white line illustration for an adult coloring book. The subject '
  'is drawn large and clear, and everything around them is built from separate '
  'outlined shapes with white space between them.'
 where slug = 'hs-style-editorial-scene';

update prompt_blocks set body_text =
  'The setting is fully furnished and the page is rich with real objects — '
  'furniture, plants, things people actually keep in a room — each drawn as '
  'its own outlined shape with white space around it. The subject stays the '
  'clear focus, but the room around them is full.'
 where slug = 'hs-density-dense';

-- The season stops saturating; it does not empty the room. Esoh: "the image
-- isn't overwhelmed by the surroundings of the individual, not that they
-- would be scarce."
update prompt_blocks set body_text =
  'Seasonal cues establish atmosphere; they do not repeat. The season shows in '
  'the view outside and in the light rather than in seasonal objects set out on '
  'every surface. This limits how often the season is echoed, not how furnished '
  'the room is.'
 where slug = 'hs-seasonal-restraint';

commit;

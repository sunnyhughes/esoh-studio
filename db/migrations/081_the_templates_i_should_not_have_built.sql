-- 081_the_templates_i_should_not_have_built.sql
--
-- Esoh asked, looking at two Decorative pages: "I was wondering how that would
-- look on a solo or group image." I read that as *put the edge-to-edge ground
-- behind a figure* and built TPL-11 and TPL-12 to do it. He meant the opposite:
--
--   "When I asked for solo and group images I wasn't asking to be made in a
--    decorative frame or symbol picture. I was asking for those types of
--    pictures to be generated in their own categories."
--
-- He was asking whether the *drawing quality* he liked could appear in Solo and
-- Community pages, which already have templates. TPL-11 and TPL-12 answer a
-- question nobody asked, and the pages prove it — "they look like they are
-- framed by random flowers", and the solo has "flowers growing inside her house
-- from the walls", which is exactly what happens when a composition block
-- demanding growth to all four edges meets an item whose `visual_elements` is a
-- kitchen. Both are withdrawn.
--
-- **What the mistake bought is worth keeping, and it is not the templates.**
-- Esoh on the same pages: "the people in the last images are good images of the
-- way the people should look. The clothing styles and shaded areas of the
-- clothes." Those are the best figures the project has produced, and the only
-- thing TPL-11 said about the figure that TPL-01 does not is a **size**:
-- "drawn from the waist or knees up and filling at least half the height of the
-- page". TPL-01 says "One focal person centered slightly off-axis" and names no
-- size at all. That is the same shape as D112's countable limit and 079's own
-- note — a named quantity lands where an adjective does not. Porting that one
-- sentence into TPL-01 and TPL-02 is proposed, not done here: it changes the
-- two templates that draw most of the book, and that is Esoh's call to make
-- with a page in front of him, not a side effect of withdrawing my own error.
--
-- The generated pages are deliberately left in place. They are the evidence for
-- that proposal and the record of what he approved.
--
-- ----------------------------------------------------------------------------
--
-- The second half is a defect he found himself, paying for it:
--
--   "The image where I introduced the porch swing was almost acceptable until
--    it filled the area behind the swing with small childlike flowers."
--
-- Job 62197946, TPL-10, subject "A porch swing, lemonade pitcher and glasses
-- with ice inside them". The swing, the pitcher and the glasses came out well.
-- Behind them the wall is sprinkled with dozens of tiny five-petal daisies far
-- too small to take a pencil. The instruction that produced them is in the
-- composition block, in as many words:
--
--   "Background: restrained **repeating pattern** or open white."
--
-- The model took the pattern branch and filled it from the base style's own
-- vocabulary, which for Botanical Line is flowers. "Restrained" is an adjective
-- and controls nothing — the same failure as "centerpiece" against "half the
-- height of the page". The white-space block's "pattern supports, never fills"
-- is contradicted by the composition block offering a pattern ground two
-- sentences earlier, and loses.
--
-- The fix keeps what works. `African American Winter 13` and `Hispanic Fall 13`
-- both carry full patterned grounds and both are good — but that pattern is the
-- *border and its compartments*, drawn at a colourable size. The defect is
-- specifically small scattered motifs behind the centre objects, so that is
-- what gets excluded, by content, per D46. A size floor is stated for every
-- shape on the page rather than left to "restrained".

begin;

-- --------------------------------------------- withdraw TPL-11 and TPL-12

update prompt_templates set
  is_active = false,
  description = description ||
    ' WITHDRAWN 2026-09-15 (081): built on a misreading of what Esoh asked '
    'for. He wanted Solo and Community pages in their own categories, not '
    'figures set on a decorative ground. Kept inactive rather than deleted so '
    'the pages it made stay traceable — their figures are the best the project '
    'has produced and are the evidence for porting a figure size into TPL-01 '
    'and TPL-02.',
  updated_at = now()
 where slug in ('tpl-11-figure-on-pattern', 'tpl-12-group-on-pattern');

-- --------------------------------------------- stop the sprinkled ground

update prompt_blocks set body_text =
  'Seasonal border or repeating pattern frame with 4-8 comfort objects set '
  'inside it; flatter and more graphic than a symbol cluster. The border or '
  'corner frames carry the pattern, divided into compartments large enough to '
  'colour. Center: the object grouping, standing on open white. The ground '
  'behind and between the centre objects is left open — it is never filled '
  'with small scattered motifs, sprinkled tiny flowers, dots or loose leaves. '
  'Every shape on the page, in the border and in the centre alike, is large '
  'enough to colour with a pencil.',
  updated_at = now()
 where slug = 'hs-comp-tpl-10-decorative-border';

do $$
declare t text; n int;
begin
  select count(*) into n from prompt_templates
   where slug in ('tpl-11-figure-on-pattern','tpl-12-group-on-pattern')
     and is_active;
  if n <> 0 then raise exception 'a withdrawn template is still offered'; end if;

  select body_text into t from prompt_blocks
   where slug = 'hs-comp-tpl-10-decorative-border';
  if t ~* 'background:.*repeating pattern' then
    raise exception 'the background still offers a repeating pattern'; end if;
  if t !~* 'never filled with small scattered motifs' then
    raise exception 'the sprinkled ground is not excluded'; end if;
  if t !~* 'large enough to colour with a pencil' then
    raise exception 'no size floor was set'; end if;
  -- What worked on AA Winter 13 and Hispanic Fall 13 must survive.
  if t !~* 'border or corner frames carry the pattern' then
    raise exception 'the patterned border was lost'; end if;

  -- The white-space block no longer contradicts the composition block.
  select body_text into t from prompt_blocks
   where slug = 'hs-space-tpl-10-decorative-border';
  if t !~* 'never fills' then
    raise exception 'the white space rule changed unexpectedly'; end if;
end $$;

commit;

-- 082_the_objects_stop_floating.sql
--
-- Esoh rejected the 081 re-run:
--
--   "it was supposed to be a calming porch setting with lemonade and glasses
--    with ice and a quiet serene look around the porch. On the images the swing
--    and lemonade are just floating in air in the middle of a flower themed
--    border. Those entire images make no sense."
--
-- Correct, and I reported that page as a success because I checked the defect I
-- had fixed instead of looking at the page. The sprinkled daisies were gone.
-- Everything else about it was wrong, and **081 made one part of it worse**: the
-- tiny flowers at least implied a wall behind the swing, and "the ground behind
-- and between the centre objects is left open" removed the only thing the
-- objects had to sit against. The over-correction is the finding.
--
-- Two faults, and only the second is the block's.
--
-- **1. The page was made on a template that cannot draw what he described.**
-- A porch is a *place*. TPL-10 draws "a seasonal border or repeating pattern
-- frame with 4-8 comfort objects set inside it" — an ornament, not a setting,
-- and no wording will make it one. TPL-09 Outdoor Sanctuary is the template for
-- this: "One outdoor retreat space with a strong built anchor (patio,
-- courtyard, balcony, garden bed) plus plants and seating ... Lower: paving,
-- path, pots, ground plants."
--
-- **Nothing stopped him picking the wrong one.** D56's mismatch guard in
-- `lib/generate.ts` compares `item.page_type` against `template.page_type`, and
-- it is explicit that "items with no page type set are left alone". He was
-- generating ad hoc, with no item, so no guard could fire. Every safety this
-- project has built for page type runs through the item row, and the form lets
-- you generate without one. That gap is named here and not fixed here — it is
-- code, not data, and it deserves its own change.
--
-- **2. The centre objects do not form a group.** This is the block's fault and
-- 081's. `African American Winter 13` works because its centre objects — the
-- hat, the mug, the gifts — overlap and sit on a common line, reading as one
-- arrangement. The porch swing, the pitcher and the glasses are stacked up the
-- page with white gaps between them and nothing underneath, so each floats
-- separately. 081 said "the object grouping, standing on open white" and said
-- nothing about the objects touching or resting on anything.
--
-- That is 078's lesson exactly, and I did not carry it across: **a group only
-- reads as a group if the things in it may touch.** 078 learned it for Symbol
-- pages and wrote it into `hs-space-tpl-05`; the same sentence was needed here
-- and was not written. So the centre now gets a shared surface to stand on and
-- permission to overlap, and the ground stays free of sprinkled motifs.

begin;

update prompt_blocks set body_text =
  'Seasonal border or repeating pattern frame with 4-8 comfort objects set '
  'inside it; flatter and more graphic than a symbol cluster. The border or '
  'corner frames carry the pattern, divided into compartments large enough to '
  'colour. Center: the objects are arranged as one grouping, overlapping each '
  'other and resting together on a single drawn surface — a step, a tabletop '
  'edge, a line of boards, a low shelf — so they belong to each other rather '
  'than floating apart up the page. The ground behind them stays open; it is '
  'never filled with small scattered motifs, sprinkled tiny flowers, dots or '
  'loose leaves. Every shape on the page, in the border and in the centre '
  'alike, is large enough to colour with a pencil.',
  updated_at = now()
 where slug = 'hs-comp-tpl-10-decorative-border';

do $$
declare t text;
begin
  select body_text into t from prompt_blocks
   where slug = 'hs-comp-tpl-10-decorative-border';

  -- 082's fix: the objects touch, and they stand on something.
  if t !~* 'overlapping each other' then
    raise exception 'the centre objects still cannot touch'; end if;
  if t !~* 'resting together on a single drawn surface' then
    raise exception 'the centre objects still float'; end if;

  -- 081's fix must survive it.
  if t ~* 'background:.*repeating pattern' then
    raise exception 'the sprinkled background came back'; end if;
  if t !~* 'never filled with small scattered motifs' then
    raise exception 'the sprinkled ground is no longer excluded'; end if;
  if t !~* 'large enough to colour with a pencil' then
    raise exception 'the size floor was lost'; end if;
  if t !~* 'border or corner frames carry the pattern' then
    raise exception 'the patterned border was lost'; end if;

  -- The same sentence 078 wrote for Symbol pages, for the same reason. If one
  -- is ever reworded without the other, this is where it shows.
  select body_text into t from prompt_blocks
   where slug = 'hs-space-tpl-05-symbol-cluster';
  if t !~* 'touch and overlap' then
    raise exception 'the symbol page lost its permission to group'; end if;
end $$;

commit;

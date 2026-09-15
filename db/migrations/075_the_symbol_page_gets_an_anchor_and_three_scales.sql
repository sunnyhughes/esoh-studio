-- 075_the_symbol_page_gets_an_anchor_and_three_scales.sql
--
-- 074 gave Symbol pages the three quote references and re-ran 08 and 13. 13
-- improved markedly — a central anchor with botanical growth radiating out at
-- three scales. 08 barely moved, and the reason is in its own brief:
--
--   "Balanced spring symbol cluster with a central butterfly, surrounding
--    flowers, dove, heart, journal, tea mug, small sunrise, and leaves;
--    **each object separated by white space**; coloring book line art."
--
-- **"Each object separated by white space" is an instruction to scatter.** It is
-- the same shape as 057's "simple uncluttered room", which beat three separate
-- instructions asking for a lived-in kitchen (D135) — a brief clause that
-- quietly contradicts the block layer and wins, for the seventh time after
-- D118, D120, D121, D131, D135 and D136.
--
-- TPL-05 asks for separation **between clusters**: "8-15 related motifs grouped
-- in balanced clusters with breathing room between forms." The brief asked for
-- it between every object, so nothing grouped and nothing anchored.
--
-- The replacement does four things the old one did not. It names the anchor and
-- says it is **large**. It establishes **three scales** in so many words. It
-- names **species** rather than "flowers" — D131's mechanism used deliberately,
-- and the vocabulary comes from the chart Esoh supplied, which 074 registered as
-- the only record of it. And it asks for **interior detail positively** — veins,
-- stamens, markings — rather than hoping density arrives on its own.
--
-- The original objects are kept: a dove, a heart, a journal and a mug were
-- Esoh's, from the tracker's own "Braids, flowers, hearts, doves, and healing
-- motifs."

begin;

update items set brief =
  'A large butterfly at the centre of the page, drawn big enough to carry its '
  'own detail — veined wings with patterned markings — with the spring motifs '
  'gathered around it in three or four groups rather than spread evenly across '
  'the page. Each group mixes scales: a magnolia or hellebore bloom opened wide '
  'with its stamens and petal veins drawn, medium sprays of new leaves and '
  'blossom behind it, and fine stems, buds and raindrops filling in between. A '
  'dove, a heart, an open journal and a tea mug sit among the groups at their '
  'own sizes. Clear channels of white run between the groups so each can be '
  'coloured on its own. Coloring book line art.',
  updated_at = now()
 where ref = 'African American Spring 08';

do $$
declare t text;
begin
  select brief into t from items where ref = 'African American Spring 08';
  if t ~* 'each object separated' then
    raise exception 'the scatter instruction survived'; end if;
  if t !~* 'three or four groups' then
    raise exception 'the brief does not group the motifs'; end if;
  if t !~* 'stamens' then
    raise exception 'the brief asks for no interior detail'; end if;
  if t !~* 'magnolia|hellebore' then
    raise exception 'the brief names no species'; end if;
end $$;

commit;

-- 077_the_symbol_pages_stop_scattering.sql
--
-- 075 found the scatter instruction in `African American Spring 08` and replaced
-- it. Reading the other twenty-two Symbol and Decorative briefs afterwards, it
-- is in **eleven of the twelve remaining Symbol pages**, in eight different
-- wordings:
--
--   "each drawn as its own clean outlined shape with clear space between them"
--   "each drawn as its own outlined shape with generous space between them"
--   "arranged as separate colorable motifs ... without visual clutter"
--   "use distinct shapes and generous spacing for easy coloring"
--   "arrange each motif distinctly with ... balanced spacing"
--   "use clean separate motifs with plenty of white space"
--
-- Same defect, same layer, eleven more times. TPL-05 asks for separation
-- *between clusters*; every one of these asks for it between every object, so
-- nothing groups and nothing anchors. That is D131/D135's brief-beats-block
-- mechanism — now at seven findings — operating across a whole page type rather
-- than on one page. 075 fixed one instance of a systematic fault.
--
-- The second half is vocabulary. Only 08 names a species. The rest say "an open
-- flower", "two open flowers", "a flower", "simple botanical motifs" — and the
-- four Hispanic briefs hedge on top of that: "hibiscus-**like** flower", "a
-- **subtle Hispanic-inspired** tile pattern", "hand-painted-**style** tile",
-- "non-stereotyped". A hedge is not a thing the model can draw. Hispanic and
-- Multiracial had the thinnest drawable vocabulary in the system; these briefs
-- are why.
--
-- **The brief is the only layer that can carry this.** 062 withholds the line
-- identity block from people-free templates and `lib/generate.ts` does not even
-- append `ethnicity_line` to the subject when `has_people` is false (D117,
-- D137). For Symbol and Decorative pages there is no block that knows the line.
-- A per-season block is not expressible either — `prompt_blocks` has
-- `ethnicity_line` but no `season`. So it goes in the brief, which is also the
-- layer that has won all seven times.
--
-- The vocabulary is taken from the chart Esoh supplied, which 074 registered as
-- the only record of it and 073 barred from ever being used as an image input.
-- Its four quadrants are per-season and per-line: magnolia and dogwood with an
-- ankh for Spring African American; hibiscus, palm and a triskelion for Summer
-- Black/Multiracial; maple, oak, marigolds and a banded ceramic pot for Fall
-- Hispanic; pine, pinecones and hellebore for Winter. Cropping it into four
-- could not make it usable as a picture — every quadrant still carries four
-- lines of drawn label, a cut-through neighbour panel, and in one case a 50.8%
-- black afro against D44 — but its *words* carry across with none of that.
--
-- Two things deliberately not done:
--
--   * **The quadrants' little framed landscapes are left out.** 076 praised the
--     vignette inside the wreath, but `hs-comp-symbol-page` reads "No people and
--     no scene", and a landscape is a scene. Contradicting the block from the
--     brief is the exact move this migration exists to undo.
--   * **Nationality is named nowhere.** `hs-line-hispanic` says "Do not assume
--     one nationality" and warns off "forced flags or national symbols". So the
--     pot is "a glazed ceramic pot with a banded geometric pattern", described
--     rather than labelled. The species stay species.
--
-- Every object Esoh named is kept, as 075 kept the dove, heart, journal and mug.
-- What changes is the arrangement, the scale and the interior detail.
--
-- `African American Spring 13` is **left alone**. Its brief is the mildest of
-- the twelve and 076 recorded it taking the reference's teaching in full — an
-- open journal anchor, a sunrise vignette, magnolias with stamens, a butterfly
-- drawn as outlined cells. It is the best Symbol page there is. Rewriting the
-- brief of the one page that works, to match pages that do not, is not a fix.

begin;

-- ---------------------------------------------------------------- Symbol pages

update items set brief =
  'A large maple leaf at the centre of the page, drawn big enough to carry its '
  'own veining and turning edge, with the autumn motifs gathered around it in '
  'three or four groups rather than spread evenly across the page. Each group '
  'mixes scales: a small pumpkin with its ribs and curled stem drawn, medium '
  'oak leaves and seed heads behind it, and fine acorns, stems and grasses '
  'filling in between. A closed journal with a ribbon marker, a pair of praying '
  'hands and a simple cross sit among the groups at their own sizes. Clear '
  'channels of white run between the groups so each can be coloured on its own.',
  updated_at = now()
 where ref = 'African American Fall 12';

update items set brief =
  'A large sunflower head at the centre of the page, drawn big enough to carry '
  'its own seed spiral and petal veins, with the summer motifs gathered around '
  'it in three or four groups rather than spread evenly across the page. Each '
  'group mixes scales: a tall glass of lemonade with a citrus slice on the rim, '
  'its segments drawn, medium black-eyed susans and broad leaves behind it, and '
  'fine stems, buds and short rays filling in between. A pair of flat sandals '
  'and a heart sit among the groups at their own sizes. Clear channels of white '
  'run between the groups so each can be coloured on its own.',
  updated_at = now()
 where ref = 'African American Summer 12';

update items set brief =
  'A large dove in flight at the centre of the page, drawn big enough to carry '
  'its own feather rows and wing markings, with the winter motifs gathered '
  'around it in three or four groups rather than spread evenly across the page. '
  'Each group mixes scales: a pillar candle in a holder with its flame and '
  'run of wax drawn, medium bare branches with their buds and holly with veined '
  'leaves and berries behind it, and fine twigs, seed heads and snowflakes '
  'filling in between. A pair of mittens joined by a cord, their knitted cable '
  'drawn, a heart and two stars sit among the groups at their own sizes. Clear '
  'channels of white run between the groups so each can be coloured on its own.',
  updated_at = now()
 where ref = 'African American Winter 12';

update items set brief =
  'A large hummingbird at the centre of the page, drawn big enough to carry its '
  'own feather rows and the barring on its tail, with the spring motifs '
  'gathered around it in three or four groups rather than spread evenly across '
  'the page. Each group mixes scales: a dahlia or amaryllis opened wide with '
  'its stamens and petal veins drawn, medium sprays of new leaves and blossom '
  'behind it, and fine stems, buds and unfurling fern crosiers filling in '
  'between. A heart and a sun with short rays sit among the groups at their own '
  'sizes. Clear channels of white run between the groups so each can be '
  'coloured on its own.',
  updated_at = now()
 where ref = 'Hispanic Spring 12';

update items set brief =
  'A large sun at the centre of the page with long and short rays alternating, '
  'its face drawn as concentric bands rather than left plain, with the summer '
  'motifs gathered around it in three or four groups rather than spread evenly '
  'across the page. Each group mixes scales: a hibiscus opened wide with its '
  'long stamen column and petal veins drawn, medium palm and banana leaves with '
  'their ribs behind it, and fine buds, tendrils and citrus slices with their '
  'segments filling in between. A butterfly with veined wings and patterned '
  'cells, and a heart, sit among the groups at their own sizes. Clear channels '
  'of white run between the groups so each can be coloured on its own.',
  updated_at = now()
 where ref = 'Hispanic Summer 12';

update items set brief =
  'A large marigold at the centre of the page, drawn big enough to carry its '
  'own layered petals and packed centre, with the autumn motifs gathered around '
  'it in three or four groups set in a broad arc rather than spread evenly '
  'across the page. Each group mixes scales: a glazed ceramic mug with a banded '
  'geometric pattern around its belly, medium maple and oak leaves with their '
  'veins and turning edges behind it, and fine acorns, stems and seed heads '
  'filling in between. A pillar candle in a low holder and an open journal sit '
  'among the groups at their own sizes. Clear channels of white run between the '
  'groups so each can be coloured on its own.',
  updated_at = now()
 where ref = 'Hispanic Fall 12';

update items set brief =
  'A large eight-point star at the centre of the page, drawn big enough to '
  'carry its own inner rings and pierced centre, with the winter motifs '
  'gathered around it in three or four groups set in a broad circle rather than '
  'spread evenly across the page. Each group mixes scales: a pillar candle in a '
  'holder with its flame and run of wax drawn, medium pine boughs and pinecones '
  'with their open scales behind it, and fine needles, berries and snowflakes '
  'filling in between. A knitted mitten with its cable drawn, a glazed ceramic '
  'mug with a banded pattern and a heart sit among the groups at their own '
  'sizes. Clear channels of white run between the groups so each can be '
  'coloured on its own.',
  updated_at = now()
 where ref = 'Hispanic Winter 12';

update items set brief =
  'A large pair of cupped hands holding a seedling at the centre of the page, '
  'drawn big enough to carry the creases of the palms and the leaves of the '
  'seedling, with the spring motifs gathered around them in three or four '
  'groups rather than spread evenly across the page. Each group mixes scales: a '
  'dogwood or magnolia bloom opened wide with its stamens and petal veins '
  'drawn, medium sprays of new leaves and blossom behind it, and fine stems, '
  'buds and raindrops filling in between. A butterfly with open wings, veined '
  'and patterned, and a heart sit among the groups at their own sizes. Clear '
  'channels of white run between the groups so each can be coloured on its own.',
  updated_at = now()
 where ref = 'Multiracial Spring 12';

update items set brief =
  'A large hibiscus at the centre of the page, drawn big enough to carry its '
  'own long stamen column and petal veins, with the summer motifs gathered '
  'around it in three or four groups rather than spread evenly across the page. '
  'Each group mixes scales: a sun with short rays and a face drawn as '
  'concentric bands, medium palm fronds with their ribs and broad leaves behind '
  'it, and fine buds, tendrils and curling wave lines filling in between. A '
  'heart sits among the groups at its own size. Clear channels of white run '
  'between the groups so each can be coloured on its own.',
  updated_at = now()
 where ref = 'Multiracial Summer 12';

update items set brief =
  'A large turning oak leaf at the centre of the page, drawn big enough to '
  'carry its own veining and lobed edge, with the autumn motifs gathered around '
  'it in three or four groups rather than spread evenly across the page. Each '
  'group mixes scales: a pillar candle in a low holder with its flame and run '
  'of wax drawn, medium maple keys and rosehips on their stems behind it, and '
  'fine acorns, twigs and grasses filling in between. A closed journal with a '
  'ribbon marker and a heart sit among the groups at their own sizes. Clear '
  'channels of white run between the groups so each can be coloured on its own.',
  updated_at = now()
 where ref = 'Multiracial Fall 12';

update items set brief =
  'A large hellebore opened wide at the centre of the page, drawn big enough to '
  'carry its own stamen boss and petal veins, with the winter motifs gathered '
  'around it in three or four groups rather than spread evenly across the page. '
  'Each group mixes scales: a pillar candle in a holder with its flame and run '
  'of wax drawn, medium eucalyptus sprays and seed pods behind it, and fine '
  'needles, berries and snowflakes filling in between. A pair of mittens joined '
  'by a cord, their knitted cable drawn, a heart and two stars sit among the '
  'groups at their own sizes. Clear channels of white run between the groups so '
  'each can be coloured on its own.',
  updated_at = now()
 where ref = 'Multiracial Winter 12';

-- ------------------------------------------------- Hispanic Decorative pages
--
-- These four have no scatter instruction — the Decorative briefs are structured
-- edge to edge and mostly good. Their fault is the hedge: every one of them
-- describes a quality ("subtle", "-inspired", "-style", "non-stereotyped",
-- "warm, elegant") where the African American and Multiracial Decorative briefs
-- name a thing (a plaid grid, a quilt panel, cable and ribbing). Naming the
-- geometry is what makes it drawable, and it is also what stops the model
-- reaching for a cliché to fill the gap the hedge leaves.

update items set brief =
  'An ornamental spring panel built on a tile border of glazed squares — each '
  'square carrying a painted geometric figure, an eight-point star, a '
  'quatrefoil, a scalloped fan — running edge to edge around the page, with a '
  'closed notebook, a glazed ceramic cup with a banded pattern and a leafy stem '
  'set into the open centre; every compartment large enough to colour.',
  updated_at = now()
 where ref = 'Hispanic Spring 13';

update items set brief =
  'An ornamental autumn panel built on woven textile geometry — banded rows of '
  'zigzag, diamond and stepped fret with the weave drawn — with a garland of '
  'maple and oak leaves swagged across it and a glazed ceramic cup and marigold '
  'heads set into the bands; structured edge to edge, every compartment large '
  'enough to colour.',
  updated_at = now()
 where ref = 'Hispanic Fall 13';

update items set brief =
  'An ornamental summer panel — a woven basket with its weave drawn, a folded '
  'textile showing its banded pattern, a tall glass with citrus slices and '
  'their segments, wildflowers with their stamens and petal veins, and a small '
  'journal — arranged on a blanket whose border and motif run to the edges of '
  'the page; open shapes throughout, every one large enough to colour.',
  updated_at = now()
 where ref = 'Hispanic Summer 13';

update items set brief =
  'An ornamental winter panel built on banded textile geometry — zigzag, '
  'diamond and stepped fret rows with the weave drawn — with folded blankets '
  'showing their stripes, glazed ceramic mugs, a lantern with its panes and '
  'pierced top, evergreen branches with their needles, and snowflakes set into '
  'and across the bands; structured edge to edge, every compartment large '
  'enough to colour.',
  updated_at = now()
 where ref = 'Hispanic Winter 13';

-- ------------------------------------------------------------------ assertions

do $$
declare n int; t text; r record;
begin
  -- The scatter instruction, in every wording it was found in.
  select count(*) into n from items
   where page_type = 'Symbol page'
     and brief ~* 'each object separated'
                  '|clear space between'
                  '|generous spac'
                  '|balanced spacing'
                  '|plenty of white space'
                  '|separate colorable motifs'
                  '|separated by white space';
  if n <> 0 then
    raise exception '% symbol brief(s) still scatter', n; end if;

  -- Every rewritten Symbol brief groups, names a scale set and asks for
  -- interior detail. Spring 13 is exempt by name — see the header.
  for r in
    select ref, brief from items
     where page_type = 'Symbol page'
       and ref <> 'African American Spring 13'
  loop
    if r.brief !~* 'three or four groups' then
      raise exception '% does not group its motifs', r.ref; end if;
    if r.brief !~* 'mixes scales' then
      raise exception '% establishes no scale set', r.ref; end if;
    if r.brief !~* 'veins|veined|veining|stamen|markings|scales drawn|cable' then
      raise exception '% asks for no interior detail', r.ref; end if;
    if r.brief !~* 'channels of white' then
      raise exception '% leaves no channels between groups', r.ref; end if;
  end loop;

  -- The hedges, across both page types.
  select count(*) into n from items
   where page_type in ('Symbol page', 'Decorative page')
     and brief ~* 'hibiscus-like|-inspired|-style tile|non-stereotyped'
                  '|subtle Hispanic';
  if n <> 0 then
    raise exception '% brief(s) still hedge instead of naming', n; end if;

  -- D131: name the species, not the category. Every rewritten Symbol brief
  -- does. `African American Spring 13` is exempt with the rest of its row, and
  -- the exemption is worth reading rather than waving through: **it is the best
  -- Symbol page there is and it names no species at all** — "flowers ... leaves"
  -- is as far as it goes. What it has instead is the reference, which 076
  -- registered the day it started working. That is evidence the exemplar
  -- carries vocabulary better than the brief does, and a caution against
  -- reading any improvement below as proof the words did it.
  select count(*) into n from items
   where page_type = 'Symbol page'
     and ref <> 'African American Spring 13'
     and brief !~* 'magnolia|hellebore|dogwood|dahlia|amaryllis|hibiscus'
                   '|marigold|sunflower|maple|oak|holly|eucalyptus'
                   '|black-eyed susans|pine|palm';
  if n <> 0 then raise exception '% symbol brief(s) name no species', n; end if;

  -- Esoh's objects survive the rewrite. Spot-checked where they are his own
  -- and not the chart's, as 075 kept the dove, heart, journal and mug.
  select brief into t from items where ref = 'African American Fall 12';
  if t !~* 'praying hands' or t !~* 'cross' or t !~* 'pumpkin' then
    raise exception 'African American Fall 12 lost an object of Esoh''s'; end if;
  select brief into t from items where ref = 'Hispanic Winter 12';
  if t !~* 'mitten' or t !~* 'candle' or t !~* 'mug' then
    raise exception 'Hispanic Winter 12 lost an object of Esoh''s'; end if;

  -- Left deliberately untouched.
  select brief into t from items where ref = 'African American Spring 13';
  if t !~* 'Central open journal with flowers flowing outward' then
    raise exception 'the one symbol page that works was edited'; end if;

  -- The chart stays barred as an image input (073), whatever its words feed.
  select count(*) into n from reference_images
   where label like 'Symbol vocabulary chart%' and usable_as_input;
  if n <> 0 then raise exception 'the chart became usable as input'; end if;

  -- No scene on a page whose block says there is none.
  select count(*) into n from items
   where page_type = 'Symbol page'
     and brief ~* 'vignette|horizon|sunrise over|landscape';
  if n <> 0 then raise exception '% symbol brief(s) ask for a scene', n; end if;
end $$;

commit;

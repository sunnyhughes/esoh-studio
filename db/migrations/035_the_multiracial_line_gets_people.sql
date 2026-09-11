-- 035_the_multiracial_line_gets_people.sql
--
-- D104's data half, for the Multiracial line. The same move 031 made for the
-- Hispanic 60, with one difference that is the whole point of the decision.
--
-- The Hispanic briefs could lean on a word that names something. "Multiracial"
-- does not: D104 records that the bare sentence `The figure is Multiracial.`
-- asks the model for an appearance the word does not describe, which is why
-- that line came back unmarked. Two things are therefore true at once and both
-- are honoured here.
--
-- 1. EACH FIGURE IS GIVEN A HERITAGE THAT IS ANSWERABLE. Not "mixed" in the
--    abstract — Nigerian and Puerto Rican, Dominican and Japanese, Cape Verdean
--    and Swedish. A named origin is something the model has seen people from.
--
-- 2. NO TWO PAGES CARRY THE SAME ONE. Across the 32 figure rows the pairings
--    do not repeat, so the line is defined by its range rather than by a type.
--    That is also D96: these are the pages that must not look repetitive.
--
-- HERITAGE IS NAMED BY ORIGIN, NEVER BY COLOUR. No brief here says "Black" or
-- "white". Under D105 a colour word in a prompt comes back as a filled shape,
-- and those two terms would be sitting in the subject line of a page with no
-- tone to put them in. Whether the model reads them as identity or as an
-- instruction to fill is not a question worth answering at the cost of 32
-- pages, and naming the origin is more specific in any case. For the same
-- reason no brief describes skin: the Hispanic 60 carry their specificity on
-- hair, age, dress and naming, 0 of 60 mention tone, and that is why they work.
--
-- SCOPE IS 32 ROWS, NOT 60. Of the 15 pages per season, 4 are Solo portraits
-- and 4 are Community scenes; the remaining 7 — Quote, Symbol, Decorative and
-- Environment — have no figure on them, so ethnicity does not apply and the
-- route already drops the sentence for them (D62). Those 28 rows need
-- composition detail instead, which is D103's work and not this migration's.
--
-- `silver-streaked` is deliberately not used for the two older women here,
-- though it fit both. It is one of the three cases D105 left for Esoh rather
-- than a regex, and it stays unused until that call is made. Age is carried by
-- naming the decade and by the cut.

begin;

create temporary table mr_briefs (ref text primary key, brief text) on commit drop;

insert into mr_briefs (ref, brief) values

-- FALL ---------------------------------------------------------------------
('Multiracial Fall 01',
 'Multiracial woman in her 30s, African American and Filipina, with loose '
 'spiralling curls gathered off her face, wrapped in a chunky knit cardigan and '
 'writing in a journal beside a framed window where leaves drift past; a mug '
 'and a trailing plant on the sill keep the room quiet.'),
('Multiracial Fall 02',
 'Multiracial man in his 40s, Jamaican and Korean, with a short coiled fade and '
 'a neatly trimmed beard, walking a tree-lined path with both hands around a tea '
 'cup; a scarf turned once at the neck and an unhurried, steady stride.'),
('Multiracial Fall 03',
 'Multiracial young adult, Mexican and Vietnamese, with long straight hair '
 'pushed behind one ear, curled sideways into a deep armchair reading a small '
 'book with knees drawn up under a woven throw; a lamp and a stack of books at '
 'their elbow.'),
('Multiracial Fall 04',
 'Multiracial woman in her 50s, Ethiopian and Italian, with coils cropped close '
 'to the head, seated at a low table with her eyes closed and both palms resting '
 'open; a single candle and a folded pair of glasses in front of her.'),
('Multiracial Fall 05',
 'A support circle of six adults of mixed heritage in a warm room — tight coils, '
 'loose waves, locs and straight hair among them — one woman speaking with an '
 'open hand while the others turn toward her; mugs on the side tables, a framed '
 'print and a low shelf of books behind.'),
('Multiracial Fall 06',
 'A blended family of four cooking at a kitchen island — a Nigerian and Puerto '
 'Rican father with a short coiled fade, a mother with long waves tied back, two '
 'children with looser curls between them — one child up on a stool to reach the '
 'bowl, a wooden spoon and a dusting of flour in play.'),
('Multiracial Fall 07',
 'Two close friends at a small table writing gratitude notes to each other, one '
 'Haitian and Chinese with braids gathered at the nape, one Colombian and '
 'Lebanese with a loose wavy bob; index cards, a pot of pens and two mugs '
 'between them, both mid-laugh.'),
('Multiracial Fall 08',
 'A peer-support check-in between two women — one in her 50s, Trinidadian and '
 'Portuguese, with cropped coils; one in her 20s, Somali and Irish, with long '
 'spiral curls — seated at an angle in soft armchairs, a notebook closed on one '
 'lap, the other leaning in with a steady, attentive gaze.'),

-- SPRING -------------------------------------------------------------------
('Multiracial Spring 01',
 'Multiracial woman in her 20s, Dominican and Japanese, with a high curly puff '
 'and small hoop earrings, writing in a journal on a balcony surrounded by '
 'blooming potted plants; a watering can at her feet and a light cardigan '
 'slipping off one shoulder.'),
('Multiracial Spring 02',
 'Multiracial man in his 30s, Ghanaian and Polish, with short twists and a '
 'close-trimmed beard, walking a city park path early with his jacket open and '
 'his hands loose at his sides; low railings, new leaves on the trees and an '
 'empty bench behind him.'),
('Multiracial Spring 03',
 'Multiracial young adult, Filipino and Mexican, with straight hair tied in a '
 'low knot, sitting cross-legged by an open window with both hands resting on '
 'the knees and the shoulders drawn back mid-breath; a thin curtain lifting and '
 'a potted fern on the ledge.'),
('Multiracial Spring 04',
 'Multiracial woman in her 40s, Cape Verdean and Swedish, with shoulder-length '
 'waves held back by a wide headband, sitting wrapped to the chin in a quilted '
 'blanket with one hand flat over her heart; a cup cooling on the table and new '
 'growth at the window beyond.'),
('Multiracial Spring 05',
 'A support circle of seven adults of mixed heritage in a community room — box '
 'braids, a curly bob, locs, a shaved head and straight hair among them — seated '
 'on folding chairs with one man mid-sentence and a woman beside him nodding; a '
 'flip chart and a table of cups at the side.'),
('Multiracial Spring 06',
 'A blended family of four planting flowers in a raised bed — a Tanzanian mother '
 'with long braids, a Croatian father with a curly undercut, a teenager with a '
 'high puff and a small child with soft ringlets — trowels, seedling trays and '
 'loose soil between them, all four kneeling.'),
('Multiracial Spring 07',
 'Two friends on a low garden wall sharing encouragement, one Eritrean and '
 'Guyanese with locs tied back, one Peruvian and Ukrainian with a thick braid '
 'over one shoulder; one has a hand on the other''s forearm, and two bicycles '
 'lean against the wall behind them.'),
('Multiracial Spring 08',
 'A mentor and a participant walking out of a workshop together — the mentor in '
 'her 50s, Bajan and Greek, with coils under a headwrap; the participant in her '
 '20s, Hmong and Nigerian, with a long straight ponytail — folders under her arm '
 'and a propped door behind them.'),

-- SUMMER -------------------------------------------------------------------
('Multiracial Summer 01',
 'Multiracial man in his 30s, Sudanese and Brazilian, with short locs gathered '
 'at the back, sitting cross-legged under a broad tree with his hands resting on '
 'his knees and his eyes closed; roots breaking the grass and layered leaf '
 'shapes overhead.'),
('Multiracial Summer 02',
 'Multiracial woman in her 40s, Puerto Rican and Chinese, with a long layered '
 'cut lifted by the wind, standing at a railing above open water with her '
 'forearms on the rail; small boats out beyond her and gulls in the distance.'),
('Multiracial Summer 03',
 'Multiracial young adult, Kenyan and Danish, with a high-top of tight coils, '
 'mid-stretch on a rooftop mat with one arm reaching across the body; potted '
 'plants along the parapet and a low skyline behind.'),
('Multiracial Summer 04',
 'Multiracial woman in her 60s, Panamanian and Indian, with a long plait over '
 'one shoulder, sitting on a front stoop with a glass of lemonade on the step '
 'beside her and a folded fan in her lap; railings and a screen door behind.'),
('Multiracial Summer 05',
 'An outdoor support group of six adults of mixed heritage seated in a loose '
 'ring of folding chairs under a shade tree — twists, a curly bob, a headwrap, '
 'straight hair and a fade among them — one woman speaking with her palms turned '
 'up, a cooler and cups on the grass.'),
('Multiracial Summer 06',
 'A blended family of five at a picnic blanket in a park — a Barbadian '
 'grandmother with a headwrap, a Senegalese father with a fade, a Thai mother '
 'with a long braid, two children with loose curls — a basket, cut fruit and a '
 'spread of plates between them, one child reaching across.'),
('Multiracial Summer 07',
 'Four friends of mixed heritage walking a path together after group, their hair '
 'ranging from locs to a curly bob to a straight bob to a shaved head, one with a '
 'folder under an arm and another mid-laugh with a hand raised; low hedges and a '
 'lamp post along the way.'),
('Multiracial Summer 08',
 'Two people in peer-support conversation on a city bench, one Haitian and '
 'Portuguese in his 40s with a close fade and a trimmed beard, one Laotian and '
 'Jamaican in her 30s with a curly bob; both turned inward, a bag between them '
 'and a bus shelter beyond.'),

-- WINTER -------------------------------------------------------------------
('Multiracial Winter 01',
 'Multiracial woman in her 30s, Congolese and Norwegian, with two-strand twists '
 'pinned up, writing in a journal at a table beside a framed window with snow '
 'falling past the panes; a mug, a candle and a folded blanket over the chair '
 'back.'),
('Multiracial Winter 02',
 'Multiracial man in his 50s, Cuban and Filipino, with a short crop and a full '
 'trimmed beard, walking a quiet street in a heavy coat with his hands in his '
 'pockets and his collar turned up; bare branches and a low fence along the way.'),
('Multiracial Winter 03',
 'Multiracial young adult, Ghanaian and Korean, with a curly bob tucked behind '
 'both ears, lying propped on their elbows under a heavy blanket colouring in a '
 'book; pencils fanned out on the floor and a lamp reaching into the corner.'),
('Multiracial Winter 04',
 'Multiracial woman in her 20s, Salvadoran and Somali, with a long spiral-curled '
 'ponytail, curled into the corner of a sofa with both hands around a large mug '
 'and a knitted throw across her knees; a lamp and a low shelf behind her.'),
('Multiracial Winter 05',
 'An indoor support circle of six adults of mixed heritage on soft chairs in a '
 'lamplit room — locs, a headwrap, twists, a fade and long waves among them — '
 'one man speaking with his hands open and the rest turned toward him; mugs and '
 'a box of tissues on a low table.'),
('Multiracial Winter 06',
 'A blended family of four at a kitchen table exchanging folded notes — a Malian '
 'father with short twists, a Scottish mother with a long straight bob, two '
 'children with loose curls — a jar of paper slips in the middle, all four '
 'leaning in, one child unfolding a note.'),
('Multiracial Winter 07',
 'Two people standing at a wide framed window watching snow fall, one '
 'Trinidadian and Vietnamese with a high bun, one Nigerian and Mexican with a '
 'close fade; their shoulders just touching, two mugs on the sill and a blanket '
 'over the chair behind them.'),
('Multiracial Winter 08',
 'A visit between two friends in a small sitting room, one in her 60s, Jamaican '
 'and Lebanese, with coils under a headwrap, one in her 30s, Eritrean and Irish, '
 'with box braids gathered back; a tray of tea between them, one reaching to '
 'take the other''s hand.');

update items i
   set brief = m.brief, updated_at = now()
  from mr_briefs m
 where i.ref = m.ref
   and i.ethnicity_line = 'Multiracial';

-- All 32 landed, and only the figure rows were touched.
do $$
declare n int;
begin
  select count(*) into n from items
   where ethnicity_line = 'Multiracial' and updated_at > now() - interval '1 minute';
  if n <> 32 then raise exception 'expected 32 briefs updated, got %', n; end if;

  select count(*) into n from items
   where ethnicity_line = 'Multiracial'
     and updated_at > now() - interval '1 minute'
     and page_type not in ('Solo portrait', 'Community scene');
  if n <> 0 then raise exception '% non-figure rows were touched', n; end if;
end $$;

-- D105. These are subject lines on a page with no tone. A colour word here is
-- an instruction to fill a shape, and that includes the two ethnonyms that are
-- also colours — which is why heritage is named by origin throughout.
do $$
declare bad text;
begin
  select string_agg(ref, ', ') into bad from items
   where ethnicity_line = 'Multiracial'
     and page_type in ('Solo portrait', 'Community scene')
     and brief ~* '\y(dark|black|white|brown|red|blue|green|golden|amber|silver|grey|gray|blonde|olive|tan|fair|pale)\y';
  if bad is not null then
    raise exception 'colour word in Multiracial brief: %', bad;
  end if;
end $$;

-- D105 again, narrower: nothing describes skin. The Hispanic 60 carry their
-- specificity without it (0 of 60), and that is the half that works.
do $$
declare bad text;
begin
  select string_agg(ref, ', ') into bad from items
   where ethnicity_line = 'Multiracial'
     and brief ~* '\y(skin|complexion|skin tone)\y';
  if bad is not null then raise exception 'brief describes skin: %', bad; end if;
end $$;

-- D96. The line is defined by its range, so no two briefs may be the same.
do $$
declare n int;
begin
  select count(*) into n from (
    select brief from items
     where ethnicity_line = 'Multiracial'
       and page_type in ('Solo portrait', 'Community scene')
     group by brief having count(*) > 1) d;
  if n <> 0 then raise exception '% duplicated briefs', n; end if;
end $$;

-- The gap this migration exists to close: the line was unmarked. Every figure
-- row now names a heritage or a mixed group, and every one describes hair.
do $$
declare bad text;
begin
  select string_agg(ref, ', ') into bad from items
   where ethnicity_line = 'Multiracial'
     and page_type in ('Solo portrait', 'Community scene')
     -- Heritage is carried either collectively ("six adults of mixed
     -- heritage") or per person ("a Nigerian and Puerto Rican father").
     -- The second form is the more specific one, so both count.
     and not (brief ~* 'Multiracial|mixed heritage|African American|Filipina|Filipino|Jamaican|Korean|Mexican|Vietnamese|Ethiopian|Italian|Nigerian|Puerto Rican|Haitian|Chinese|Colombian|Lebanese|Trinidadian|Portuguese|Somali|Irish|Dominican|Japanese|Ghanaian|Polish|Cape Verdean|Swedish|Eritrean|Guyanese|Peruvian|Ukrainian|Bajan|Greek|Hmong|Sudanese|Brazilian|Kenyan|Danish|Panamanian|Indian|Laotian|Congolese|Norwegian|Cuban|Salvadoran|Tanzanian|Croatian|Barbadian|Senegalese|Thai|Malian|Scottish');
  if bad is not null then raise exception 'no heritage named: %', bad; end if;

  select string_agg(ref, ', ') into bad from items
   where ethnicity_line = 'Multiracial'
     and page_type in ('Solo portrait', 'Community scene')
     and not (brief ~* 'hair|curls|coils|locs|braids|twists|fade|bob|puff|plait|ponytail|crop|headwrap|bun|ringlets|undercut|shaved|waves|wavy|layered');
  if bad is not null then raise exception 'no hair described: %', bad; end if;
end $$;

commit;

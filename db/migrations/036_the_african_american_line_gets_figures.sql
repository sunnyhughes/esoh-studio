-- 036_the_african_american_line_gets_figures.sql
--
-- The last of D104's data half. 031 revised the Hispanic 60, 035 wrote the
-- Multiracial 32, and this line was left as the thin one — 47 characters
-- against 230 and 252.
--
-- THIS LINE IS NOT UNMARKED, AND THAT CHANGES THE JOB. The Multiracial briefs
-- had to be given a subject as well as a figure; "Person journaling with leaves
-- outside window" said nothing about anyone. These say plenty. A recovery home,
-- a sponsor-style conversation, a prayer journal, a church fellowship hall, a
-- barber shop or beauty shop, faith symbols — the situations carry more
-- cultural specificity than anything else in the library, and they are the
-- author's own. **Every one is kept.** What is added is the figure: age, hair,
-- dress, and what the hands and eyes are doing. Nothing is replaced.
--
-- HAIR IS DRAWN FROM THE MENU THAT ALREADY EXISTS. D45 built 23 options on the
-- figure templates and D104 observed that all 23 are African American styles
-- serving a line that was never briefed to use them. The 16 Solo portraits now
-- name one each — a twist-out, wash-and-go coils, locs, a silk press, 360
-- waves, a high-top fade, sponge curls, a high puff — and no style repeats
-- within a season. `items.hair` is set to match, so the hs-hair block fires
-- with the same words the subject line uses rather than leaving the model to
-- invent it.
--
-- D110 IS NOT SETTLED AND THIS DOES NOT PRETEND OTHERWISE. Tight-texture hair
-- is exactly what has been coming back as hatching or as a filled mass, and
-- this line's whole vocabulary is tight-texture. Writing vaguer hair to dodge a
-- rendering bug would flatten the line in precisely the way D104 objects to, so
-- the briefs name the real styles and the rendering question stays where it
-- belongs — in the variance work D110 calls for.
--
-- No colour word appears in any of these, including for the two older women
-- where greying hair was the natural phrase (D105). Nothing describes skin.

begin;

create temporary table aa_briefs (ref text primary key, brief text, hair text, facial_hair text)
  on commit drop;

insert into aa_briefs (ref, brief, hair, facial_hair) values

-- FALL ---------------------------------------------------------------------
('African American Fall 01',
 'African American woman in her 30s with a twist-out framing her face, wrapped '
 'in an oversized cable-knit sweater and writing in a journal beside a framed '
 'window where leaves drift past; a mug and a folded throw on the seat beside '
 'her.', 'a twist-out', null),
('African American Fall 02',
 'African American man in his 40s with a short fade and a lineup and a neatly '
 'trimmed beard, walking a tree-lined sidewalk with both hands around a coffee '
 'cup; his jacket zipped halfway, his collar up against the morning and an easy, '
 'unhurried stride.', 'a short fade with a lineup', 'a neatly trimmed beard'),
('African American Fall 03',
 'African American young adult with wash-and-go coils, resting sideways into the '
 'corner of a couch under a soft blanket with one arm tucked beneath a cushion; '
 'a lamp low beside them and a book face-down on the arm.',
 'wash-and-go coils', null),
('African American Fall 04',
 'African American woman in her 50s with locs gathered back in a low wrap, '
 'leaning to light a candle at a side table where a gratitude notebook lies '
 'open, one hand steadying the table edge.', 'locs', null),
('African American Fall 05',
 'A small indoor support circle of six African American adults in a warmly '
 'furnished room — box braids, a high-top fade, locs, a headwrap and a short '
 'tapered afro among them — one woman speaking with her hand open while the '
 'others turn toward her; mugs on the side tables and a shelf of books behind.',
 null, null),
('African American Fall 06',
 'An African American parent and teenager baking together in the kitchen of a '
 'recovery home — the '
 'mother in her 40s with two-strand twists pinned up, the teenager with a high '
 'puff — a mixing bowl between them, flour across the counter, the teenager '
 'laughing at something just said.', null, null),
('African American Fall 07',
 'Two African American siblings reconnecting across a kitchen table, the '
 'brother with 360 '
 'waves and a trimmed beard, the sister with knotless braids gathered over one '
 'shoulder; two mugs, a plate pushed aside, and one reaching a hand halfway '
 'across the table.', null, null),
('African American Fall 08',
 'An African American sponsor and sponsee talking on a park bench, the older '
 'man in his 50s with a '
 'short tapered afro and a close-trimmed beard, the younger man with cornrows; '
 'both leaning forward with their forearms on their knees and a folded meeting '
 'schedule in one hand.', null, null),

-- SPRING -------------------------------------------------------------------
('African American Spring 01',
 'African American woman in her 20s with a curly bob tucked behind one ear, '
 'writing in a journal at a table by a framed window streaked with rain; potted '
 'plants crowding the sill and a mug at her elbow.', 'a curly bob', null),
('African American Spring 02',
 'African American man in his 30s with a high-top fade, walking a neighbourhood '
 'park path early with his jacket open and his hands loose at his sides; new '
 'leaves on the trees, a low fence and an empty bench behind him.',
 'a high-top fade', null),
('African American Spring 03',
 'African American young adult with a full afro, sitting cross-legged on a mat '
 'with both hands resting on the knees and the shoulders drawn back mid-breath; '
 'an open window, a curtain lifting and a fern on the ledge.', 'a full afro', null),
('African American Spring 04',
 'African American woman in her 40s with a silk press turned under at the ends, '
 'sitting wrapped to the chin in a quilted blanket with a cup of tea held in '
 'both hands and a stack of affirmation cards fanned on the table.',
 'a silk press', null),
('African American Spring 05',
 'A small recovery circle of seven African American adults on folding chairs in '
 'a community room — cornrows, faux locs, a shaved head, a headwrap and sponge '
 'curls among them — one man mid-sentence and a woman beside him nodding; a '
 'table of cups and a flip chart at the side.', null, null),
('African American Spring 06',
 'An African American mother and her adult daughter planting flowers in a '
 'raised bed, the mother '
 'with a headwrap tied back and the daughter with Fulani braids; trowels, '
 'seedling trays and loose soil between them, both kneeling with their sleeves '
 'pushed up.', null, null),
('African American Spring 07',
 'Three African American friends on a front porch sharing encouragement, one '
 'with box braids '
 'gathered up, one with a short tapered afro and one with a silk press; a '
 'pitcher and glasses on a side table, and one resting a hand on another''s '
 'forearm.', null, null),
('African American Spring 08',
 'An African American mentor and a newcomer talking after a meeting, the '
 'mentor in her 50s with '
 'locs wrapped at the nape and the newcomer in her 20s with a twist-out; folding '
 'chairs stacked behind them and a propped door letting light into the room.',
 null, null),

-- SUMMER -------------------------------------------------------------------
('African American Summer 01',
 'African American woman in her 30s with knotless braids gathered over one '
 'shoulder, sitting against the trunk of a broad tree with a recovery journal '
 'open on her knees and a pen held still; roots breaking the grass around her.',
 'knotless braids', null),
('African American Summer 02',
 'African American man in his 40s with locs tied back and a close-trimmed beard, '
 'standing at the end of a lakefront dock with his hands in his pockets; posts '
 'and rope along the edge and small boats out on the water.',
 'locs', 'a close-trimmed beard'),
('African American Summer 03',
 'African American young adult with sponge curls, mid-stretch on a mat with one '
 'arm reaching across the body; potted plants along a low wall and an open '
 'doorway behind.', 'sponge curls', null),
('African American Summer 04',
 'African American woman in her 60s with a high puff held by a wide band, '
 'sitting on a porch swing with a glass of tea on the rail beside her and one '
 'foot tucked under; chains, railings and a screen door behind her.',
 'a high puff', null),
('African American Summer 05',
 'An outdoor support group of six African American adults seated in a loose ring '
 'of folding chairs under a shade tree — cornrows, a headwrap, a high-top fade, '
 'faux locs and a curly bob among them — one woman speaking with her palms '
 'turned up, a cooler and cups on the grass.', null, null),
('African American Summer 06',
 'An African American family at a picnic blanket in a park — a grandmother '
 'with a headwrap, two '
 'parents with a short fade and long layered curls, two children with Bantu '
 'knots and a small afro — a basket, cut fruit and plates spread between them, '
 'one child reaching across.', null, null),
('African American Summer 07',
 'Two African American friends walking a neighbourhood trail after group, one '
 'with box braids and '
 'one with a short fade and a lineup, one carrying a water bottle and the other '
 'mid-laugh with a hand raised; low hedges and a lamp post along the way.',
 null, null),
('African American Summer 08',
 'An African American beauty shop scene of encouragement — a stylist with faux '
 'locs part-way through braiding a seated client''s cornrows, another client '
 'under the dryer with a silk press looking up from a magazine, a third waiting '
 'with her coat still on and box braids gathered up — mirrors, stations and '
 'rows of bottles along the wall, all of them mid-conversation.', null, null),

-- WINTER -------------------------------------------------------------------
('African American Winter 01',
 'African American woman in her 30s with two-strand twists pinned up, sitting at '
 'a table beside a framed window with snow falling past the panes, a prayer '
 'journal open in front of her and both hands folded on it.',
 'two-strand twists', null),
('African American Winter 02',
 'African American man in his 50s with a short tapered afro under a knit cap and '
 'a full trimmed beard, walking a quiet street in a heavy coat with his hands in '
 'his pockets and his collar turned up; bare branches and a low fence along the '
 'way.', 'a short tapered afro', 'a full trimmed beard'),
('African American Winter 03',
 'African American young adult with a twist-out, lying propped on their elbows '
 'under a heavy blanket colouring in a book; pencils fanned out on the floor and '
 'two candles on a low table.', 'a twist-out', null),
('African American Winter 04',
 'African American woman in her 40s with a curly bob, curled into the corner of '
 'a sofa with both hands around a mug of cocoa and a knitted throw across her '
 'knees; a lamp and a low shelf behind her.', 'a curly bob', null),
('African American Winter 05',
 'An indoor support group of six African American adults on soft chairs in a '
 'lamplit room — locs, a headwrap, cornrows, a high-top fade and long layered '
 'curls among them — one man speaking with his hands open and the rest turned '
 'toward him; mugs and a box of tissues on a low table.', null, null),
('African American Winter 06',
 'An African American grandmother and her adult grandchild sharing quiet '
 'encouragement at a '
 'kitchen table, the grandmother with a headwrap and the grandchild with '
 'knotless braids; a teapot between them and one reaching to take the other''s '
 'hand.', null, null),
('African American Winter 07',
 'An African American couple sitting at an angle on a sofa working through a '
 'conversation, one '
 'with a short fade and a trimmed beard, one with a twist-out held back by a '
 'band; a blanket over the arm, two mugs on the table and both leaning slightly '
 'in.', null, null),
('African American Winter 08',
 'An African American woman answering her door to a friend dropping off soup, '
 'the friend holding a covered pot out in both hands, the woman in a cardigan '
 'with a headwrap tied back; a hallway light behind her and snow on the step.', null, null);

update items i
   set brief = a.brief,
       hair = coalesce(a.hair, i.hair),
       facial_hair = coalesce(a.facial_hair, i.facial_hair),
       updated_at = now()
  from aa_briefs a
 where i.ref = a.ref
   and i.ethnicity_line = 'African American';

-- All 32 landed, and only the figure rows were touched.
do $$
declare n int;
begin
  select count(*) into n from items
   where ethnicity_line = 'African American' and updated_at > now() - interval '1 minute';
  if n <> 32 then raise exception 'expected 32 rows updated, got %', n; end if;

  select count(*) into n from items
   where ethnicity_line = 'African American'
     and updated_at > now() - interval '1 minute'
     and page_type not in ('Solo portrait', 'Community scene');
  if n <> 0 then raise exception '% non-figure rows were touched', n; end if;
end $$;

-- The situations this line already carried are the point of it. If an expansion
-- dropped one, the migration has flattened the most specific material in the
-- library and must not commit.
do $$
declare missing text := '';
begin
  if not exists (select 1 from items where ref = 'African American Fall 06' and brief ~* 'recovery home')
    then missing := missing || 'Fall 06 recovery home; ' ; end if;
  if not exists (select 1 from items where ref = 'African American Fall 08' and brief ~* 'sponsor')
    then missing := missing || 'Fall 08 sponsor; ' ; end if;
  if not exists (select 1 from items where ref = 'African American Spring 05' and brief ~* 'recovery')
    then missing := missing || 'Spring 05 recovery; ' ; end if;
  if not exists (select 1 from items where ref = 'African American Summer 01' and brief ~* 'recovery journal')
    then missing := missing || 'Summer 01 recovery journal; ' ; end if;
  if not exists (select 1 from items where ref = 'African American Summer 08' and brief ~* 'beauty shop|barber')
    then missing := missing || 'Summer 08 beauty shop; ' ; end if;
  if not exists (select 1 from items where ref = 'African American Winter 01' and brief ~* 'prayer journal')
    then missing := missing || 'Winter 01 prayer journal; ' ; end if;
  if missing <> '' then raise exception 'situation dropped: %', missing; end if;
end $$;

-- D105. No colour word in a subject line, and nothing describing skin. The two
-- older women here had greying hair as the natural phrase and do not get it.
do $$
declare bad text;
begin
  select string_agg(ref, ', ') into bad from items
   where ethnicity_line = 'African American'
     and page_type in ('Solo portrait', 'Community scene')
     and brief ~* '\y(dark|black|white|brown|red|blue|green|golden|amber|silver|grey|gray|blonde|olive|tan|fair|pale)\y';
  if bad is not null then raise exception 'colour word in brief: %', bad; end if;

  select string_agg(ref, ', ') into bad from items
   where ethnicity_line = 'African American'
     and brief ~* '\y(skin|complexion)\y';
  if bad is not null then raise exception 'brief describes skin: %', bad; end if;
end $$;

-- D45/D104. The 16 Solo portraits name a hair style, and every value is one the
-- form's own menu offers — a brief that invents a style the menu cannot produce
-- would put the two out of step again.
do $$
declare n int; bad text;
begin
  select count(*) into n from items
   where ethnicity_line = 'African American'
     and page_type = 'Solo portrait' and hair is not null;
  if n <> 16 then raise exception 'expected hair on 16 Solo portraits, got %', n; end if;

  select string_agg(ref || ' = ' || hair, ', ') into bad from items
   where ethnicity_line = 'African American' and hair is not null
     and hair not in (
       'a short tapered afro','a full afro','a twist-out','wash-and-go coils',
       'box braids','knotless braids','cornrows','Fulani braids',
       'two-strand twists','Bantu knots','locs','faux locs','a high puff',
       'a silk press','a curly bob','long layered curls','a short fade',
       'a short fade with a lineup','a high-top fade','360 waves','sponge curls',
       'a shaved head','a headwrap');
  if bad is not null then raise exception 'hair value not in the menu: %', bad; end if;
end $$;

-- D96. No hair style repeats within a season's four Solo portraits.
do $$
declare bad text;
begin
  select string_agg(season || ':' || hair, ', ') into bad from (
    select season, hair from items
     where ethnicity_line = 'African American' and page_type = 'Solo portrait'
     group by season, hair having count(*) > 1) d;
  if bad is not null then raise exception 'hair repeats within a season: %', bad; end if;
end $$;

-- The gap this closes: every figure row names the line and describes hair.
do $$
declare bad text;
begin
  select string_agg(ref, ', ') into bad from items
   where ethnicity_line = 'African American'
     and page_type in ('Solo portrait', 'Community scene')
     and not (brief ~* 'African American');
  if bad is not null then raise exception 'line not named: %', bad; end if;

  select string_agg(ref, ', ') into bad from items
   where ethnicity_line = 'African American'
     and page_type in ('Solo portrait', 'Community scene')
     and not (brief ~* 'hair|afro|coils|locs|braids|twists|cornrows|fade|bob|puff|knots|curls|headwrap|silk press|waves|shaved|twist');
  if bad is not null then raise exception 'no hair described: %', bad; end if;
end $$;

commit;

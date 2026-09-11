-- 040_the_pages_without_people_get_briefs.sql
--
-- The last thin briefs in the coloring library. 031 revised all 60 Hispanic
-- rows including its 28 without people; 035 and 036 did the 32 figure rows on
-- the other two lines and deliberately left these. They average 88 to 106
-- characters against Hispanic's 250, and they are 56 of the 180 pages.
--
-- THESE PAGES HAVE NOWHERE ELSE TO GET THEIR CONTENT. A Solo portrait brief can
-- be thin and still come back sane, because the figure blocks, the hair value
-- and the exemplars all say something. A Quote page brief that reads "Change
-- and worth theme" is the only instruction on the page that is not boilerplate:
-- strip it and nothing remains but "a decorative arrangement around a clear
-- open area". That is why 038 could assign a style from these briefs but they
-- cannot generate from them.
--
-- WRITTEN TO THE STYLE AND DENSITY EACH ROW NOW CARRIES. 038 and 039 gave every
-- row an `art_style` and a `background_density`, so a Zentangle Pattern row is
-- briefed as tiled pattern, a Bold Minimal row as a few large shapes and a lot
-- of nothing, an Open row keeps its centre clear and a Dense Environment row is
-- furnished to the edges. A brief that fights its own style block is how the
-- two rejected Community Scenes happened.
--
-- TWO CONTRADICTIONS ARE FIXED RATHER THAN COPIED FORWARD.
--
-- 1. `hs-comp-quote-page` ends "Draw no letters, words or writing anywhere",
--    because the quote is set afterwards by the print pipeline and not drawn by
--    the model. Two briefs asked for the opposite — `Multiracial Winter 11`
--    ("bold lettering") and `Multiracial Summer 11` ("bold text space") — and
--    would have put the model to work drawing the one thing the block forbids.
--    Both are rewritten to describe what surrounds the blank centre instead.
--
-- 2. D105 left five uses of "bright" flagged for Esoh rather than stripped by
--    regex. Two of them are in rows this migration rewrites — `African American
--    Summer 09` and `Multiracial Summer 10` — and the replacement text simply
--    does not need the word. **That is a decision being made here and it should
--    be visible**: the other three uses are untouched and still Esoh's call.
--
-- Every existing motif is kept. The African American line's own register is the
-- reason to be careful — "faith symbols" becomes praying hands and a cross,
-- "Braids, flowers, hearts, doves" keeps the braid running through the cluster,
-- and the church fellowship hall stays a church fellowship hall.

begin;

create temporary table nf_briefs (ref text primary key, brief text) on commit drop;

insert into nf_briefs (ref, brief) values

-- AFRICAN AMERICAN ---------------------------------------------------------
('African American Fall 09',
 'Autumn border of turning oak and maple leaves on curving stems, with a few '
 'acorns and a seed pod, drawn as separate outlined shapes; the leaves gather at '
 'the corners and thin as they travel inward so the centre of the page stays '
 'clear and unhurried.'),
('African American Fall 10',
 'Border built from knit texture — rows of cable, seed stitch and ribbing tiled '
 'into bands — wrapping a simple outlined mug and the folded cuff of a blanket '
 'at the lower corner; the pattern is dense at the margins and stops well short '
 'of the open centre.'),
('African American Fall 11',
 'A spare arrangement of five or six leaves at generous scale, two at the upper '
 'corner and the rest drifting along the lower edge, each drawn with a single '
 'confident outline; nothing else on the page, and the middle left entirely '
 'empty.'),
('African American Fall 12',
 'A centred cluster of separate autumn symbols at large scale — a broad leaf, a '
 'small pumpkin, a closed journal with a ribbon marker, a pair of praying hands '
 'and a simple cross — each drawn as its own clean outlined shape with clear '
 'space between them.'),
('African American Fall 13',
 'An ornamental autumn panel built on a plaid grid of crossed bands of varying '
 'width, with outlined leaves, a pillar candle, a wheat sheaf and simple harvest '
 'shapes set into the squares; structured edge to edge, every compartment large '
 'enough to colour.'),
('African American Fall 14',
 'A reading nook with nobody in it — a deep armchair with a knitted blanket over '
 'one arm, a footstool, a floor lamp leaning in, a side table stacked with books '
 'and a mug, shelves behind and a plant on the sill — each object its own '
 'outlined shape with space around it.'),
('African American Fall 15',
 'A kitchen table set for no one in particular — a pie with a latticed top on a '
 'board, two cups and a teapot, a folded cloth and a small jug of stems — with '
 'the chairs pushed in, a window above the sink and open shelving behind, every '
 'item drawn as a separate outlined shape.'),
('African American Spring 09',
 'Spring border of open blossoms on slim branching stems, unfurling leaves and a '
 'few closed buds, growing inward from the four corners and thinning as it goes; '
 'the flowers stay large and separate and the middle of the page is left clear.'),
('African American Spring 10',
 'A loose hand-drawn border of butterflies at different sizes, looping flight '
 'lines, small garden sprigs and a watering can tipped at one corner, drawn '
 'slightly irregular as if with a marker; playful around the edges and empty '
 'through the middle.'),
('African American Spring 11',
 'Rain-and-sky border with drifting cloud shapes along the top, falling droplet '
 'strokes, a few blossoms catching them below and small ripple rings at the '
 'base; all drawn in clean open outline, with the centre of the page kept still '
 'and empty.'),
('African American Spring 12',
 'A centred cluster of separate healing symbols — a length of braided hair '
 'curving through the group, an open flower, a heart, a dove in flight and a '
 'pair of cupped hands — each drawn as its own outlined shape with generous '
 'space between them.'),
('African American Spring 13',
 'An ornamental spring wreath of leaves, blossoms and looping stems filling the '
 'page, with a mug, a closed journal and a pen tucked into the lower part of the '
 'ring; the growth runs right to the edges and every leaf is left open enough to '
 'colour.'),
('African American Spring 14',
 'A bedroom with nobody in it — a made bed with layered pillows and a folded '
 'quilt, a bedside table holding books, a candle and a small clock, a trailing '
 'plant on a shelf and curtains drawn back from the window — each piece outlined '
 'separately with room to breathe.'),
('African American Spring 15',
 'A church fellowship hall set up before anyone arrives: a ring of folding '
 'chairs, a long table with a coffee urn, stacked cups and a covered plate, an '
 'upright piano against the wall, high windows and a noticeboard — all drawn as '
 'separate outlined shapes.'),
('African American Summer 09',
 'Summer border of sunflowers at three sizes with broad leaves and thick stems, '
 'a few seed heads and a trailing vine, massed along two opposite corners and '
 'tapering away; the blooms stay large and separate and the middle of the page '
 'is left clear.'),
('African American Summer 10',
 'A sunburst border of long straight rays radiating from the upper corner, cut '
 'by concentric arcs and faceted wedges that divide the surrounding space into '
 'large clean compartments; the rays stop short of the middle, leaving the '
 'centre of the page open.'),
('African American Summer 11',
 'A few long rays sweeping in from one corner at large scale, with two or three '
 'simple curved shapes at the opposite edge and nothing else; heavy confident '
 'outlines, very few elements, and the greater part of the page left empty.'),
('African American Summer 12',
 'A centred cluster of separate summer symbols — a sunflower head, a pair of '
 'flat sandals, a tall glass of lemonade with a slice on the rim, a heart and a '
 'small fan of rays — each drawn as its own outlined shape with clear space '
 'between them.'),
('African American Summer 13',
 'An ornamental porch panel — turned railing posts and a hanging basket framing '
 'the arrangement, with open flowers, two folding hand fans and radiating lines '
 'filling the ground between them; growth and pattern run to the edges, every '
 'shape left open.'),
('African American Summer 14',
 'A backyard patio with nobody in it — two chairs and a low table under a run of '
 'string lights, potted plants crowded along the paving, a trellis of climbing '
 'growth behind and a watering can by the step — the planting dense, the '
 'furniture drawn in clear outline.'),
('African American Summer 15',
 'A community garden between visits: raised beds thick with growth, staked '
 'tomatoes and climbing beans, a wheelbarrow, tools leaning on a shed, a hose '
 'coiled by a standpipe and a row marker pushed into the soil — the planting '
 'fills the page, each bed clearly outlined.'),
('African American Winter 09',
 'Winter border of snowflakes at varying sizes drifting down two edges, a pillar '
 'candle with a clean flame shape at the lower corner and a scatter of small '
 'stars above; drawn as clean outlined shapes, with the middle of the page kept '
 'clear.'),
('African American Winter 10',
 'Border built from quilt and blanket pattern — tiled squares, scallops, running '
 'stitch and folded edges — banked along the sides and lower edge with a paned '
 'window shape set into the upper corner; dense at the margins and stopping '
 'short of the open centre.'),
('African American Winter 11',
 'A single large candle in a holder at one side with a few long rays lifting '
 'from the flame, drawn with heavy confident outlines and nothing else on the '
 'page; the rest of the sheet is left open and the middle entirely clear.'),
('African American Winter 12',
 'A centred cluster of separate winter symbols at large scale — a pair of '
 'mittens joined by a cord, a candle in a holder, a dove in flight, a heart and '
 'two stars — each drawn as its own clean outlined shape with clear space '
 'between them.'),
('African American Winter 13',
 'An ornamental quilt panel tiled across the page — patchwork squares filled '
 'with scallops, spirals, chevrons and running stitch — with hanging ornaments '
 'and simple stars set into some of the blocks; pattern runs edge to edge, every '
 'compartment large enough to colour.'),
('African American Winter 14',
 'A bedroom retreat with nobody in it — a bed under a heavy comforter with the '
 'corner turned back, a lamp on a bedside table beside a book and a glass, a '
 'chair with a robe over it, a rug and a window with the curtains half drawn — '
 'each object separately outlined.'),
('African American Winter 15',
 'A living room between uses: a sofa with the cushions pushed into the corners, '
 'a low table holding a tea tray and stacked books, a floor lamp, a full '
 'bookshelf, a plant and a window showing bare branches — every piece drawn as '
 'its own outlined shape.'),

-- MULTIRACIAL --------------------------------------------------------------
('Multiracial Fall 09',
 'Release-and-growth border: a slim branch along the upper edge with leaves '
 'loosening from it, the leaves drifting down one side and giving way at the '
 'base to new shoots and a small unfurling frond; the motion runs around the '
 'margin and the centre stays clear.'),
('Multiracial Fall 10',
 'Border of tiled blanket pattern — woven bands, seed stitch, scallops and a '
 'fringed edge — massed along the lower half with a simple outlined cup and '
 'saucer resting against it; the pattern is dense at the margins and stops well '
 'short of the open centre.'),
('Multiracial Fall 11',
 'Two or three very large leaf shapes caught in mid-turn at one corner and a '
 'single seed pod opposite, drawn with heavy confident outlines and nothing '
 'between them; the emptiness of the rest of the page is the composition.'),
('Multiracial Fall 12',
 'A centred cluster of separate autumn symbols at large scale — a broad turning '
 'leaf, a candle in a low holder, a closed journal with a ribbon marker and a '
 'heart — each drawn as its own clean outlined shape with clear space between '
 'them.'),
('Multiracial Fall 13',
 'An ornamental autumn panel tiled with knitwear pattern — cable, ribbing, '
 'chevron bands and a folded cuff — filling the ground, with outlined mugs, '
 'acorns and a small gourd set into the bands; pattern runs edge to edge, each '
 'compartment left open to colour.'),
('Multiracial Fall 14',
 'A window seat with nobody in it — a cushioned bench under a paned window, a '
 'blanket folded along one end, cushions banked in the corner, potted plants '
 'crowding the sill and a stack of books on the floor — each object drawn as a '
 'separate outlined shape.'),
('Multiracial Fall 15',
 'A dining table between meals — a bowl of fruit at the centre, two place '
 'settings left out, a folded cloth and a small jug of stems — with the chairs '
 'drawn up, a sideboard behind holding plates and a plant, and a window beyond; '
 'every item its own outlined shape.'),
('Multiracial Spring 09',
 'Spring border of open flowers on curving stems with three butterflies lifting '
 'away from them at different heights and leaves and small buds filling between; '
 'the growth banks along two corners and thins toward the middle, leaving the '
 'centre clear.'),
('Multiracial Spring 10',
 'A loose hand-drawn border of cupped hands at the lower edge holding soil and a '
 'seedling, with a trowel, a seed packet, small sprigs and looping stems '
 'scattered around the margin, drawn slightly irregular as if with a marker; the '
 'middle left empty.'),
('Multiracial Spring 11',
 'Sky border with drifting cloud shapes along the top and one corner, a low '
 'horizon line at the base and a few small birds between; everything drawn in '
 'clean open outline, very little of it, and the greater part of the page left '
 'as sky.'),
('Multiracial Spring 12',
 'A centred cluster of separate spring symbols — a butterfly with open wings, a '
 'pair of cupped hands, a heart and two open flowers on short stems — each drawn '
 'as its own outlined shape with generous space between them.'),
('Multiracial Spring 13',
 'An ornamental spring arrangement filling the page — a ring of leaves, blossoms '
 'and looping stems enclosing a pair of rain boots with a sprig in one, a closed '
 'journal and a pen; growth runs to the edges and each shape is left open enough '
 'to colour.'),
('Multiracial Spring 14',
 'A small apartment corner with nobody in it — a low sofa with a woven throw, a '
 'floor cushion, a rug, shelves of books and pots, plants trailing from a high '
 'shelf and a window with a fire escape beyond — each object drawn as its own '
 'outlined shape.'),
('Multiracial Spring 15',
 'A wellness room set up before anyone arrives: a loose ring of soft chairs, a '
 'low table with a water jug and cups, framed art on the wall, a floor lamp, a '
 'shelf of folded blankets and a plant in the corner — all drawn as separate '
 'outlined shapes.'),
('Multiracial Summer 09',
 'A single large bird in flight at the upper corner with two long sweeping lines '
 'trailing from it and one small cloud opposite, drawn with heavy confident '
 'outlines; nothing else, and most of the page left open.'),
('Multiracial Summer 10',
 'Sun border with a full disc at one corner throwing long rays across the upper '
 'edge, a scatter of small stars and two drifting clouds below; drawn as clean '
 'outlined shapes, sparse, with the middle of the page left clear.'),
('Multiracial Summer 11',
 'A geometric sky border — a low horizon line, concentric arcs rising from it '
 'and faceted wedges radiating outward — dividing the upper and lower margins '
 'into large clean compartments while the centre of the page stays a single open '
 'area.'),
('Multiracial Summer 12',
 'A centred cluster of separate summer symbols — a small sun with short rays, '
 'two open flowers, a run of curling wave lines and a heart — each drawn as its '
 'own outlined shape with clear space between them.'),
('Multiracial Summer 13',
 'An ornamental summer arrangement filling the page — a wreath of leaves, citrus '
 'slices and open flowers enclosing a pair of flat sandals, a halved melon and a '
 'stacked pair of notebooks; growth runs to the edges, each shape left open to '
 'colour.'),
('Multiracial Summer 14',
 'A balcony corner with nobody in it — a single chair and a small table under a '
 'canopy of hanging plants, pots crowded along the rail, a watering can and a '
 'mat underfoot — the planting dense across the page, the furniture drawn in '
 'clear outline.'),
('Multiracial Summer 15',
 'An urban garden between visits: raised beds thick with growth against a wall, '
 'climbing beans on canes, a water barrel, tools leaning by a shed, crates '
 'stacked at one side and a bench along the path — the planting fills the page, '
 'each bed clearly outlined.'),
('Multiracial Winter 09',
 'Winter light border — a candle at the lower corner with long rays lifting from '
 'it, a scatter of small stars across the upper edge and two drifting cloud '
 'shapes between; clean outlined shapes only, and the middle of the page kept '
 'clear.'),
('Multiracial Winter 10',
 'Border of tiled pattern banked along all four edges — interlocking scallops, '
 'spirals, chevrons and running stitch, worked tight at the margin and easing '
 'inward — enclosing a single large open area at the centre with nothing drawn '
 'into it.'),
('Multiracial Winter 11',
 'Three or four very large snowflakes at one corner and a single bare branch '
 'entering from the opposite edge, drawn with heavy confident outlines and '
 'nothing else; the wide emptiness through the middle is the composition.'),
('Multiracial Winter 12',
 'A centred cluster of separate winter symbols at large scale — two stars, a '
 'candle in a holder, a pair of mittens joined by a cord and a heart — each '
 'drawn as its own clean outlined shape with clear space between them.'),
('Multiracial Winter 13',
 'An ornamental winter panel tiled across the page — patchwork quilt blocks '
 'filled with scallops, spirals and running stitch — with snowflakes, a stack of '
 'books and two mugs set into some of the squares; pattern runs edge to edge, '
 'every compartment large enough to colour.'),
('Multiracial Winter 14',
 'A living room with nobody in it — a sofa under layered throws and cushions, a '
 'rug over floorboards, a low table with a tray and books, a floor lamp, a full '
 'shelf and a window showing bare branches — each object drawn as its own '
 'outlined shape.'),
('Multiracial Winter 15',
 'A meditation corner in a bedroom with nobody in it — a floor cushion on a '
 'folded mat, a low shelf with a candle and a small bowl, a blanket over a '
 'stool, plants by a paned window with snow beyond and a made bed behind — each '
 'piece separately outlined.');

update items i
   set brief = n.brief, updated_at = now()
  from nf_briefs n
 where i.ref = n.ref
   and i.ethnicity_line in ('African American', 'Multiracial');

-- All 56 landed, and no figure row was touched.
do $$
declare n int;
begin
  select count(*) into n from items
   where ethnicity_line in ('African American','Multiracial')
     and updated_at > now() - interval '1 minute';
  if n <> 56 then raise exception 'expected 56 rows updated, got %', n; end if;

  select count(*) into n from items
   where ethnicity_line in ('African American','Multiracial')
     and updated_at > now() - interval '1 minute'
     and page_type in ('Solo portrait','Community scene');
  if n <> 0 then raise exception '% figure rows were touched', n; end if;
end $$;

-- D105, on pages made almost entirely of decoration — the place a colour word
-- has the least anywhere to go.
do $$
declare bad text;
begin
  select string_agg(ref, ', ') into bad from items
   where ethnicity_line in ('African American','Multiracial')
     and page_type not in ('Solo portrait','Community scene')
     and brief ~* '\y(dark|black|white|brown|red|blue|green|golden|amber|silver|grey|gray|blonde|olive|tan|fair|pale|bright)\y';
  if bad is not null then raise exception 'colour word in brief: %', bad; end if;
end $$;

-- hs-comp-quote-page ends "Draw no letters, words or writing anywhere". No
-- Quote page brief may ask for the thing the composition block forbids.
--
-- Scoped to the two lines this migration owns. Run across all three it also
-- catches `Hispanic Spring 09` and `Hispanic Spring 11`, which say "space in
-- the center for the quote" and "so the quote feels like a quiet declaration".
-- Those name the lettering in a prompt that forbids drawing it, which is the
-- §2.5 shape in a milder key — but they are Esoh's revised text from 031 and
-- are flagged in D115 rather than rewritten here.
do $$
declare bad text;
begin
  select string_agg(ref, ', ') into bad from items
   where ethnicity_line in ('African American','Multiracial') and page_type = 'Quote page'
     and brief ~* '\y(letter|lettering|letters|text|word|words|writing|type|quote|caption)\y';
  if bad is not null then raise exception 'quote brief asks for lettering: %', bad; end if;
end $$;

-- The pages required to keep a clear centre have to say so, or the brief is
-- describing a full page and the composition block is describing an empty one.
do $$
declare bad text;
begin
  select string_agg(ref, ', ') into bad from items
   where ethnicity_line in ('African American','Multiracial')
     and page_type in ('Quote page','Symbol page')
     and not (brief ~* 'centre|center|middle|open area|empty|emptiness|clear|space between|left open|left as|greater part of the page|most of the page');
  if bad is not null then raise exception 'no open centre described: %', bad; end if;
end $$;

-- The African American line's own register survives the rewrite. These are the
-- motifs the original briefs carried and the reason to be careful with them.
do $$
declare missing text := '';
begin
  if not exists (select 1 from items where ref='African American Fall 12' and brief ~* 'praying hands|cross')
    then missing := missing || 'Fall 12 faith symbols; '; end if;
  if not exists (select 1 from items where ref='African American Spring 12' and brief ~* 'braid')
    then missing := missing || 'Spring 12 braids; '; end if;
  if not exists (select 1 from items where ref='African American Spring 12' and brief ~* 'dove')
    then missing := missing || 'Spring 12 doves; '; end if;
  if not exists (select 1 from items where ref='African American Spring 15' and brief ~* 'church fellowship hall')
    then missing := missing || 'Spring 15 church fellowship hall; '; end if;
  if not exists (select 1 from items where ref='African American Winter 12' and brief ~* 'dove')
    then missing := missing || 'Winter 12 doves; '; end if;
  if missing <> '' then raise exception 'motif dropped: %', missing; end if;
end $$;

-- No page without people acquires one. hs-comp for these four types opens with
-- "No people", and a brief that describes a person contradicts it.
do $$
declare bad text;
begin
  select string_agg(ref, ', ') into bad from items
   where ethnicity_line is not null
     and page_type in ('Quote page','Symbol page','Decorative page','Environment page')
     -- Nouns only. A pronoun is not evidence of a person here: "the leaves
     -- gather at the corners and thin as they travel inward" is the page
     -- doing exactly what it should.
     and brief ~* '\y(woman|man|person|people|adult|child|children|teenager|figure|friends|family|grandmother|parent|sibling)\y';
  if bad is not null then raise exception 'figure described on a page with no people: %', bad; end if;
end $$;

-- The gap this closes. Nothing is left at sketch length.
do $$
declare bad text;
begin
  select string_agg(ref || ' (' || length(brief) || ')', ', ') into bad from items
   where ethnicity_line in ('African American','Multiracial')
     and page_type not in ('Solo portrait','Community scene')
     and length(brief) < 150;
  if bad is not null then raise exception 'brief still too thin: %', bad; end if;
end $$;

commit;

-- 048_the_season_stops_naming_the_leaves.sql
--
-- Two hypotheses about why leaves keep landing on indoor floors, both of which
-- this migration acts on.
--
-- 1. THE BLOCK MAY BE SUMMONING THEM. 043 added "Fallen leaves and other loose
--    natural material belong outdoors on the ground, and do not collect on
--    floors, furniture or surfaces indoors" — and leaves went on collecting
--    indoors, on the rug, in both renders of the decoration test. §2.5 records
--    this shape three times over: "no hatching, stippling or grey fill"
--    produced a stippled page, "never as shading" produced a hatched face, a
--    negative about borders produced a border. **The clause names leaves
--    twice.** It is written as a content negative, which §2.5 permits, but the
--    permission was inferred from cases about objects a page might reasonably
--    contain — a pumpkin on a shelf — not about the single thing the model most
--    associates with the word "autumn".
--
--    The clause is removed and replaced with a positive description of the
--    floor it wants: clear, swept, ready to walk on.
--
-- 2. TWO OF THE FIVE CHANNELS NEED A PERSON. 041 gave the season five places to
--    go: what is worn, what is held or being done, what the room is dressed
--    with, what is growing or cut, what is being eaten. On an Environment page
--    nobody is in the room — the composition block says so — so **the first two
--    are unavailable and the season has three channels instead of five.** The
--    block was written while only figure pages were being generated, which is
--    the same way the hair menus came to serve one line of three (D104).
--
--    A sentence now names what carries the season in an empty room.
--
-- Everything D107 showed working is kept: the restraint on seasonal objects,
-- the countable limit from 043, and the conditional window containment.

begin;

update prompt_blocks set body_text =
  'The season is carried by the things in the room and on the people, and it is '
  'carried differently from one page to the next. It can show in what is worn — '
  'layers, a heavy knit, bare arms, boots left by the door; in what is held or '
  'being done — a warm drink, a hand fan, a full basket, a rake against a wall; '
  'in what the room is dressed with — a quilt folded back, a coat over a chair, '
  'a lamp lit early; in what is growing or cut — bare branches, full leaf, stems '
  'in a jar; and in what is being eaten — soup and bread, filled preserving '
  'jars, cut fruit. One of these is enough to place the page. Where nobody is in '
  'the room, the season is carried by the room alone — what has been folded and '
  'left, what is growing in a pot or cut into a jar, what waits on a table — and '
  'the floor is clear, swept and ready to walk on. Everything that carries the '
  'season is an object someone owns and has put where it is. Where the page is '
  'set indoors and shows a view out, that view is seen through a window drawn as '
  'an enclosed frame with its own panes, so the view stays inside them. Seasonal '
  'objects stay to two or three across the whole page and are not set out on '
  'every surface.',
  updated_at = now()
 where slug = 'hs-seasonal-restraint';

-- The prohibition that named leaves is gone.
do $$
declare t text;
begin
  select body_text into t from prompt_blocks where slug = 'hs-seasonal-restraint';
  if t ~* 'do not collect|belong outdoors|fallen leaves' then
    raise exception 'the block still names leaves in order to forbid them';
  end if;
  if t !~* 'the floor is clear, swept and ready to walk on' then
    raise exception 'the floor is not described positively';
  end if;
end $$;

-- An empty room has its own channels now.
do $$
declare t text;
begin
  select body_text into t from prompt_blocks where slug = 'hs-seasonal-restraint';
  if t !~* 'where nobody is in the room' then
    raise exception 'no channel is named for a page with no people'; end if;
end $$;

-- Everything previously shown to work is still here.
do $$
declare t text;
begin
  select body_text into t from prompt_blocks where slug = 'hs-seasonal-restraint';
  if t !~* 'two or three across the whole page' then raise exception 'countable limit lost'; end if;
  if t !~* 'not set out on every surface'      then raise exception 'D107 restraint lost'; end if;
  if t !~* 'where the page is set indoors'     then raise exception 'window condition lost'; end if;
  if t !~* 'enclosed frame with its own panes' then raise exception 'window containment lost'; end if;
end $$;

-- §2.5 and §3.5.
do $$
declare t text;
begin
  select body_text into t from prompt_blocks where slug = 'hs-seasonal-restraint';
  if t ~* '(never|no|without|avoid)[ ]+(filled|fill|shaded|shading|hatch|stippl|render)' then
    raise exception 'technique negative present'; end if;
  if t ~* '\y(shadow|sunlight|the light|dappled)\y' then
    raise exception 'season asked to live in light'; end if;
end $$;

commit;

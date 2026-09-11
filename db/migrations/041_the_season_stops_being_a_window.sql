-- 041_the_season_stops_being_a_window.sql
--
-- Raised by Esoh on 2026-09-11, looking at three contact sheets: "the leaves
-- and window are really starting to bother me because it seems to be a set in
-- stone ideal of an autumn scene which really isn't true at all. Leaves falling
-- outside a window isn't all that autumn looks like."
--
-- That is correct, and the cause is this block rather than the briefs — only
-- 10 of the 45 Fall rows name a window at all.
--
-- `hs-seasonal-restraint` offered the season exactly two channels, "what the
-- room is dressed with" and "what is visible through the window", and 033 then
-- added "Anything outside is seen through a window drawn as an enclosed frame
-- with its own panes". **That sentence is mine.** It was written to stop leaves
-- scattering across the wall plane, which it does, and its side effect was to
-- make the window compulsory for any outdoor view at all. Two channels, one of
-- them mandatory in shape — so the same picture kept arriving.
--
-- THE REPLACEMENT CHANNELS HAVE TO BE DRAWABLE. The original block's first
-- version offered "the light", and 033 already recorded why that failed: §3.4
-- and §3.5 put every page in outline with nothing shaded, so there is no light
-- on these pages for a season to live in. Every channel named below is a thing
-- that can be outlined — worn, held, folded, grown, cooked, set down.
--
-- WHAT IS KEPT. The clause against seasonal objects on every surface stays:
-- it is a content negative, permitted by name under §2.5, and it is the half
-- that has been working — no pumpkin has appeared on a generated page under it
-- (D107). The window containment rule stays too, but conditionally: it now
-- applies where a page has an outdoor view rather than requiring that any
-- outdoor view exist.
--
-- STILL OPEN, AND NOT FIXED HERE. Both approved exemplars are autumn scenes —
-- `hoodie-on-sofa-v2` is leaves through a window, `walking-with-mug` is leaf
-- scatter under autumn trees — and since D117 they are supplied to every figure
-- page in all four seasons. A Summer page is shown two autumn references as the
-- thing to imitate. No block can out-argue that; it needs season-matched
-- references, which means generating and approving new ones. Recorded as D118.

begin;

update prompt_blocks set body_text =
  'The season is carried by the things in the room and on the people, and it is '
  'carried differently from one page to the next. It can show in what is worn — '
  'layers, a heavy knit, bare arms, boots left by the door; in what is held or '
  'being done — a warm drink, a hand fan, a full basket, a rake against a wall; '
  'in what the room is dressed with — a quilt folded back, a coat over a chair, '
  'a lamp lit early; in what is growing or cut — bare branches, full leaf, stems '
  'in a jar; and in what is being eaten — soup and bread, filled preserving '
  'jars, cut fruit. One of these is enough to place the page. A view to the '
  'outside is one of these choices and takes its turn with the others; where a '
  'page has one, it is seen through a window drawn as an enclosed frame with its '
  'own panes, so the view stays inside them. Seasonal objects stay to a few and '
  'are not set out on every surface.',
  updated_at = now()
 where slug = 'hs-seasonal-restraint';

-- The block updated.
do $$
declare n int;
begin
  select count(*) into n from prompt_blocks
   where slug = 'hs-seasonal-restraint' and updated_at > now() - interval '1 minute';
  if n <> 1 then raise exception 'expected 1 block updated, got %', n; end if;
end $$;

-- §2.5. A content negative about objects is permitted; a technique negative is
-- what summons the thing it forbids.
do $$
declare bad text;
begin
  select slug into bad from prompt_blocks
   where slug = 'hs-seasonal-restraint'
     and body_text ~* '(never|no|without|avoid)[ ]+(filled|fill|shaded|shading|hatch|hatching|stippl|grey|gray|render)';
  if bad is not null then raise exception 'technique negative in %', bad; end if;
end $$;

-- D105. This text reaches every figure page and every environment page.
do $$
declare bad text;
begin
  select slug into bad from prompt_blocks
   where slug = 'hs-seasonal-restraint'
     and body_text ~* '\y(dark|black|white|brown|red|blue|green|golden|amber|silver|grey|gray|olive|tan|pale)\y';
  if bad is not null then raise exception 'colour word in %', bad; end if;
end $$;

-- §3.5. The season may not be asked to live in light, which these pages do not
-- have. This is the failure the block's first version made.
do $$
declare bad text;
begin
  select slug into bad from prompt_blocks
   where slug = 'hs-seasonal-restraint'
     and body_text ~* '\y(the light|lighting|sunlight|glow|shadow|shade|dappled)\y';
  if bad is not null then raise exception 'season asked to live in light: %', bad; end if;
end $$;

-- The point of the migration: the window is one option among several, so there
-- have to be several. Count the channel separators.
do $$
declare channels int;
begin
  select array_length(string_to_array(body_text, ' in what '), 1) - 1 into channels
    from prompt_blocks where slug = 'hs-seasonal-restraint';
  if channels < 4 then
    raise exception 'season has only % channels; the window will win again', channels;
  end if;
end $$;

-- What 033 got right is still there: a view outside is still contained.
do $$
declare ok bool;
begin
  select body_text ~* 'enclosed frame with its own panes' into ok
    from prompt_blocks where slug = 'hs-seasonal-restraint';
  if not ok then raise exception 'window containment lost'; end if;
end $$;

-- And the clause that has been holding: no pumpkin on every surface.
do $$
declare ok bool;
begin
  select body_text ~* 'not set out on every surface' into ok
    from prompt_blocks where slug = 'hs-seasonal-restraint';
  if not ok then raise exception 'seasonal-object restraint lost'; end if;
end $$;

commit;

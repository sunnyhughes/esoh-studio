-- 043_leaves_stay_outside_and_books_stay_blank.sql
--
-- Three defects from the five-page run (D119), two of them in the block 041
-- rewrote and one that has been open since the beginning.
--
-- 1. THE LEAVES MOVED TO THE FLOOR. 041 stopped the season owning the window
--    and it relocated: eight maple leaves scattered across the floor *inside*
--    `African American Fall 14`, a reading nook, and ten more across the porch
--    boards of `African American Fall 01`. Neither brief mentions a leaf. This
--    is Esoh's original complaint in a new place — the season still escaping as
--    loose scatter — and the clause "stay to a few" was too vague to stop it.
--
--    Two changes. Everything carrying the season is now **something a person
--    owns and put there**, which loose debris is not; and the limit becomes
--    **countable**. D112 observed that nothing in this block layer is countable
--    — every size and quantity instruction is qualitative — and that a
--    countable constraint was the one kind never tried. "Two or three across
--    the whole page" is that, in the place it is most needed.
--
-- 2. A WINDOW APPEARED IN AN OUTDOOR SCENE. `African American Summer 01` puts
--    her against a tree trunk outdoors with a framed window floating behind her,
--    a tree visible through it. 041 reads "where a page has one, it is seen
--    through a window", and on a page with no indoors that is an instruction to
--    invent a wall. The clause is now conditioned on the page being set indoors,
--    which is the only situation a window makes sense in.
--
-- 3. NOTHING STOPPED STRAY LETTERING OUTSIDE QUOTE PAGES. `African American
--    Summer 01` came back with `RECOVERY JOURHAL` written on the journal — a
--    misspelling baked into the artwork of a page meant for sale.
--    `hs-comp-quote-page` ends "Draw no letters, words or writing anywhere" and
--    it works: the quote page in the same run came back clean. But that block
--    is on one template of six, so the other five had nothing.
--
--    The rule goes into `hs-output`, which is on all six at position 70, and is
--    written to defer to `hs-brand-mark` at position 50 — the one place the
--    project deliberately *wants* lettering (D35). The check below proves that
--    ordering holds on every template, because "apart from any lettering named
--    above" is only true if the brand mark really is above.

begin;

update prompt_blocks set body_text =
  'The season is carried by the things in the room and on the people, and it is '
  'carried differently from one page to the next. It can show in what is worn — '
  'layers, a heavy knit, bare arms, boots left by the door; in what is held or '
  'being done — a warm drink, a hand fan, a full basket, a rake against a wall; '
  'in what the room is dressed with — a quilt folded back, a coat over a chair, '
  'a lamp lit early; in what is growing or cut — bare branches, full leaf, stems '
  'in a jar; and in what is being eaten — soup and bread, filled preserving '
  'jars, cut fruit. One of these is enough to place the page. Everything that '
  'carries the season is an object someone owns and has put where it is — set '
  'down, worn, folded, filled. Fallen leaves and other loose natural material '
  'belong outdoors on the ground, and do not collect on floors, furniture or '
  'surfaces indoors. Where the page is set indoors and shows a view out, that '
  'view is seen through a window drawn as an enclosed frame with its own panes, '
  'so the view stays inside them. Seasonal objects stay to two or three across '
  'the whole page and are not set out on every surface.',
  updated_at = now()
 where slug = 'hs-seasonal-restraint';

update prompt_blocks set body_text =
  'Pure black line work on clean white paper, printed at full page. The paper '
  'itself is plain bright white — no tint, no ageing, no speckling, no paper '
  'grain. Every area inside the outlines is open white, ready to be coloured by '
  'hand. Surfaces that could carry writing — a book cover, a journal, a mug, a '
  'sign, a label — are drawn blank, apart from any lettering named above. No '
  'border or frame. Keep key subject matter clear of the outer edge.',
  updated_at = now()
 where slug = 'hs-output';

-- Both landed.
do $$
declare n int;
begin
  select count(*) into n from prompt_blocks
   where slug in ('hs-seasonal-restraint','hs-output')
     and updated_at > now() - interval '1 minute';
  if n <> 2 then raise exception 'expected 2 blocks updated, got %', n; end if;
end $$;

-- 1. The season has a countable limit, and loose material is named as belonging
--    outdoors rather than merely discouraged.
do $$
declare t text;
begin
  select body_text into t from prompt_blocks where slug = 'hs-seasonal-restraint';
  if t !~* 'two or three across the whole page' then
    raise exception 'seasonal limit is not countable'; end if;
  if t !~* 'do not collect on floors, furniture or surfaces indoors' then
    raise exception 'loose material is not kept outdoors'; end if;
  if t !~* 'an object someone owns and has put where it is' then
    raise exception 'seasonal objects are not tied to ownership'; end if;
end $$;

-- 2. The window is conditional on the page being indoors, and still contained.
do $$
declare t text;
begin
  select body_text into t from prompt_blocks where slug = 'hs-seasonal-restraint';
  if t !~* 'where the page is set indoors and shows a view out' then
    raise exception 'window clause is not conditioned on being indoors'; end if;
  if t !~* 'enclosed frame with its own panes' then
    raise exception 'window containment lost'; end if;
end $$;

-- 3. The lettering rule exists and defers to the brand mark.
do $$
declare t text;
begin
  select body_text into t from prompt_blocks where slug = 'hs-output';
  if t !~* 'are drawn blank, apart from any lettering named above' then
    raise exception 'lettering rule missing or does not defer to the brand mark'; end if;
end $$;

-- "Named above" has to be true. hs-brand-mark must sit before hs-output on
-- every template that carries both, or the carve-out refers to nothing.
do $$
declare bad text;
begin
  select string_agg(t.slug, ', ') into bad
    from prompt_templates t
    join template_blocks tbo on tbo.template_id = t.id
    join prompt_blocks bo on bo.id = tbo.block_id and bo.slug = 'hs-output'
    join template_blocks tbm on tbm.template_id = t.id
    join prompt_blocks bm on bm.id = tbm.block_id and bm.slug = 'hs-brand-mark'
   where tbm.position >= tbo.position;
  if bad is not null then
    raise exception 'brand mark is not above output on: %', bad; end if;
end $$;

-- §2.5 still holds in both, and D105.
do $$
declare bad text;
begin
  select string_agg(slug, ', ') into bad from prompt_blocks
   where slug in ('hs-seasonal-restraint','hs-output')
     and body_text ~* '(never|no|without|avoid)[ ]+(filled|fill|shaded|shading|hatch|hatching|stippl|render)';
  if bad is not null then raise exception 'technique negative in: %', bad; end if;

  select slug into bad from prompt_blocks
   where slug = 'hs-seasonal-restraint'
     and body_text ~* '\y(dark|black|brown|red|blue|green|golden|amber|silver|grey|gray|olive|tan|pale)\y';
  if bad is not null then raise exception 'colour word in %', bad; end if;
end $$;

-- §3.5: the season still may not be asked to live in light.
do $$
declare bad text;
begin
  select slug into bad from prompt_blocks
   where slug = 'hs-seasonal-restraint'
     and body_text ~* '\y(the light|lighting|sunlight|glow|shadow|dappled)\y';
  if bad is not null then raise exception 'season asked to live in light: %', bad; end if;
end $$;

commit;

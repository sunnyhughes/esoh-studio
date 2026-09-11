-- 038_the_style_axis_gets_values.sql
--
-- D103's first starved axis. `art_style` was set on 1 of 180 coloring rows, so
-- the dimension D26 names as the mechanism for variety was switched off on
-- exactly the pages D96 says must not repeat.
--
-- WHAT THE GAP ACTUALLY WAS. Not simply "nobody filled the column". All seven
-- style blocks are attached to all six templates, so the mechanism will accept
-- any style on any page, and **that permissiveness is the real defect**. The
-- combinations are not interchangeable and there is evidence on file:
-- `Hispanic Spring 06` was generated as a Community Scene under Bold Minimal
-- and under Botanical Line, and both were rejected — the figures came back
-- crude and unmarked. Zentangle Pattern is "dense abstract pattern tiled across
-- the whole page", which would take a portrait apart. So the column is not a
-- free axis; it is constrained by page type, and this migration writes that
-- constraint down as data.
--
-- FIGURE PAGES GET ONE STYLE, AND THAT IS THE FINDING. All 96 Solo portraits
-- and Community scenes get Editorial Scene. Every page approved to date used
-- it, and the two rejections are the only recorded attempts at anything else.
-- **The variety axis therefore does almost nothing for the figure pages** — their
-- variety has to come from the briefs, which is where 031, 035 and 036 put it
-- (224 and 256 characters, all distinct). D103 read as though 180 rows were
-- waiting for a variety setting; 96 of them are not, and saying so is worth
-- more than filling them in.
--
-- THE 84 NON-FIGURE ROWS ARE WHERE THE AXIS LIVES. Quote, Symbol, Decorative
-- and Environment pages have no figure to protect, and the style block is the
-- main thing distinguishing one from another. These are assigned individually
-- from what each brief already describes — a floral border gets Botanical Line,
-- a snowflake-and-candle border gets Celestial, a knit or woven or tiled
-- surface gets a pattern style — rather than rotated, because a style that
-- fights its own brief is how the two rejections happened.

begin;

-- 1. Figure pages. One style, on the evidence.
update items
   set art_style = 'Editorial Scene', updated_at = now()
 where ethnicity_line is not null
   and page_type in ('Solo portrait', 'Community scene');

-- 2. Environment pages. Rooms of furniture and objects are what Editorial
--    Scene describes — "everything built from separate outlined shapes with
--    white space between them". The outdoor ones are growth before they are
--    furniture, so they go to Botanical Line.
update items
   set art_style = case
         when brief ~* '\y(garden|courtyard|patio|backyard|balcony)\y'
           then 'Botanical Line'
         else 'Editorial Scene'
       end,
       updated_at = now()
 where ethnicity_line is not null
   and page_type = 'Environment page';

-- 3. Quote, Symbol and Decorative pages, assigned from their own briefs.
create temporary table style_calls (ref text primary key, art_style text) on commit drop;

insert into style_calls (ref, art_style) values
  -- Quote pages: a border around open central space. Matched to the motif the
  -- brief already names, and varied within each season so three quote pages in
  -- one book do not arrive as three versions of the same border.
  ('African American Fall 09',   'Botanical Line'),     -- autumn leaves
  ('African American Fall 10',   'Zentangle Pattern'),  -- soft knit accents
  ('African American Fall 11',   'Bold Minimal'),       -- leaves and open space
  ('African American Spring 09', 'Botanical Line'),     -- floral border
  ('African American Spring 10', 'Hand-Drawn Doodle'),  -- butterflies, garden
  ('African American Spring 11', 'Celestial'),          -- rain and soft linework
  ('African American Summer 09', 'Botanical Line'),     -- sunflowers
  ('African American Summer 10', 'Geometric Abstract'), -- bold sun rays
  ('African American Summer 11', 'Bold Minimal'),       -- warm rays, open space
  ('African American Winter 09', 'Celestial'),          -- snowflakes, candle glow
  ('African American Winter 10', 'Zentangle Pattern'),  -- blanket texture
  ('African American Winter 11', 'Bold Minimal'),       -- candle and light
  ('Hispanic Fall 09',   'Botanical Line'),     -- curling leaves, acorns
  ('Hispanic Fall 10',   'Bold Minimal'),       -- spacious centre, letting go
  ('Hispanic Fall 11',   'Celestial'),          -- sunbeams entering from one side
  ('Hispanic Spring 09', 'Botanical Line'),     -- blossoms, vines, hummingbirds
  ('Hispanic Spring 10', 'Hand-Drawn Doodle'),  -- butterflies from flowering stems
  ('Hispanic Spring 11', 'Celestial'),          -- droplets, ripples, rain
  ('Hispanic Summer 09', 'Botanical Line'),     -- open flowers, curved leaves
  ('Hispanic Summer 10', 'Geometric Abstract'), -- long clean sunburst rays
  ('Hispanic Summer 11', 'Bold Minimal'),       -- open sky, abundant white space
  ('Hispanic Winter 09', 'Celestial'),          -- candle, stars, trail of light
  ('Hispanic Winter 10', 'Zentangle Pattern'),  -- folded woven textile
  ('Hispanic Winter 11', 'Bold Minimal'),       -- minimal, a winding path
  ('Multiracial Fall 09',   'Botanical Line'),     -- release and growth
  ('Multiracial Fall 10',   'Zentangle Pattern'),  -- soft blanket and tea
  ('Multiracial Fall 11',   'Bold Minimal'),       -- change and worth
  ('Multiracial Spring 09', 'Botanical Line'),     -- butterflies and floral
  ('Multiracial Spring 10', 'Hand-Drawn Doodle'),  -- hands and garden accents
  ('Multiracial Spring 11', 'Celestial'),          -- soft sky and open space
  ('Multiracial Summer 09', 'Bold Minimal'),       -- freedom and peace
  ('Multiracial Summer 10', 'Celestial'),          -- sun and bright accents
  ('Multiracial Summer 11', 'Geometric Abstract'), -- open sky, bold text space
  ('Multiracial Winter 09', 'Celestial'),          -- warmth and light
  ('Multiracial Winter 10', 'Zentangle Pattern'),  -- quiet strength border
  ('Multiracial Winter 11', 'Bold Minimal'),       -- winter calm, bold lettering

  -- Symbol pages: separate motifs with space around them, which is Bold
  -- Minimal's description almost word for word. The floral-led ones go to
  -- Botanical Line instead.
  ('African American Fall 12',   'Bold Minimal'),
  ('African American Spring 12', 'Botanical Line'),
  ('African American Summer 12', 'Botanical Line'),
  ('African American Winter 12', 'Bold Minimal'),
  ('Hispanic Fall 12',   'Bold Minimal'),
  ('Hispanic Spring 12', 'Botanical Line'),
  ('Hispanic Summer 12', 'Botanical Line'),
  ('Hispanic Winter 12', 'Bold Minimal'),
  ('Multiracial Fall 12',   'Bold Minimal'),
  ('Multiracial Spring 12', 'Botanical Line'),
  ('Multiracial Summer 12', 'Botanical Line'),
  ('Multiracial Winter 12', 'Bold Minimal'),

  -- Decorative pages: these are pattern pages by definition, and the briefs
  -- say so — plaid, woven textile geometry, tile borders, quilts. Geometric
  -- Abstract where the brief names structure, Zentangle Pattern where it names
  -- density, Botanical Line where it names growth.
  ('African American Fall 13',   'Geometric Abstract'), -- plaid patterns
  ('African American Spring 13', 'Botanical Line'),     -- spring wreath
  ('African American Summer 13', 'Botanical Line'),     -- flowers, radiant lines
  ('African American Winter 13', 'Zentangle Pattern'),  -- quilts, ornaments
  ('Hispanic Fall 13',   'Geometric Abstract'), -- woven textile geometry, tile
  ('Hispanic Spring 13', 'Geometric Abstract'), -- hand-painted tile border
  ('Hispanic Summer 13', 'Botanical Line'),     -- wildflowers, woven basket
  ('Hispanic Winter 13', 'Zentangle Pattern'),  -- folded blankets, textile
  ('Multiracial Fall 13',   'Zentangle Pattern'),  -- sweaters, harvest detail
  ('Multiracial Spring 13', 'Botanical Line'),     -- spring border
  ('Multiracial Summer 13', 'Botanical Line'),     -- fruit, sandals
  ('Multiracial Winter 13', 'Zentangle Pattern');  -- snowflakes, quilts

update items i
   set art_style = s.art_style, updated_at = now()
  from style_calls s
 where i.ref = s.ref and i.ethnicity_line is not null;

-- Every coloring row now carries a style; the axis is no longer silent.
do $$
declare n int;
begin
  select count(*) into n from items where ethnicity_line is not null and art_style is null;
  if n <> 0 then raise exception '% coloring rows still have no art_style', n; end if;
end $$;

-- Every value names a style block that exists, on a template that carries it.
-- A style the engine cannot resolve raises "No base style block" at generation
-- time, which is a failure discovered one page at a time.
do $$
declare bad text;
begin
  select string_agg(distinct i.art_style, ', ') into bad
    from items i
   where i.ethnicity_line is not null
     and i.art_style not in (select art_style from prompt_blocks where art_style is not null);
  if bad is not null then raise exception 'no style block answers to: %', bad; end if;
end $$;

-- The two rejected experiments are written down as a rule: no figure page
-- carries anything but Editorial Scene.
do $$
declare bad text;
begin
  select string_agg(ref || ' = ' || art_style, ', ') into bad from items
   where ethnicity_line is not null
     and page_type in ('Solo portrait', 'Community scene')
     and art_style <> 'Editorial Scene';
  if bad is not null then raise exception 'figure page on a non-Editorial style: %', bad; end if;
end $$;

-- No figure page carries a style that tiles pattern across the whole page.
do $$
declare bad text;
begin
  select string_agg(ref, ', ') into bad from items
   where ethnicity_line is not null and page_type in ('Solo portrait', 'Community scene')
     and art_style in ('Zentangle Pattern', 'Geometric Abstract');
  if bad is not null then raise exception 'pattern style on a figure page: %', bad; end if;
end $$;

-- D96, where the axis actually applies. Within one line and one season the
-- three Quote pages must not all land on the same style.
do $$
declare bad text;
begin
  select string_agg(ethnicity_line || ' ' || season, ', ') into bad from (
    select ethnicity_line, season from items
     where ethnicity_line is not null and page_type = 'Quote page'
     group by ethnicity_line, season
    having count(distinct art_style) = 1) d;
  if bad is not null then raise exception 'all three quote pages share a style: %', bad; end if;
end $$;

-- The axis has to be genuinely used on the non-figure pages, or this migration
-- has written 84 rows of the same answer in a longer form.
do $$
declare n int;
begin
  select count(distinct art_style) into n from items
   where ethnicity_line is not null
     and page_type not in ('Solo portrait', 'Community scene');
  if n < 5 then raise exception 'only % styles used across the non-figure pages', n; end if;
end $$;

commit;

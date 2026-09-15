-- 084_six_styles_from_esohs_own_list.sql
--
-- Esoh's VV-Styles spreadsheet lists 23 style names and asked whether they
-- would benefit Healing Seasons. Twelve already exist — six as coloring-book
-- styles, six as apparel styles. Four are near-duplicates of those (Urban
-- Graffiti ≈ Streetwear Graffiti, Retro Diner ≈ Retro Comic, Editorial
-- Typographic Poster ≈ Editorial Typographic). Seven are genuinely new.
--
-- **The nine apparel styles cannot be pointed at a coloring book.** Every one
-- of them is defined by solid fill — "flat solid inks", "fills are solid
-- colour", "bold inks filled solid", "inks laid down as solid areas", "solid
-- ink carries the accents", "shapes are solid and hard-edged". That is D44
-- exactly, in reverse: *nothing on a coloring page is filled in*. Four are also
-- lettering-first, and D23 keeps drawn lettering off a coloring page — 071
-- existed solely to stop the model writing its own quote text. Tattoo Linework
-- is the near miss: "confident black contours of deliberately varied weight"
-- would transfer, but it continues "depth is built from dense parallel line",
-- which is the hatching that measured 1px open runs on the figure pages.
--
-- So the names transfer and the blocks do not, and each new style is authored
-- for the category it belongs to.
--
-- Three for coloring books, each aimed at a page type that is short of them
-- rather than at the menu in general:
--
-- (The Architectural block first read "depth is built from overlap ... never
-- from shading". The assertion below rejected it, correctly and for the second
-- reason: D46 says technique is stated positively and only content is excluded
-- by name, and "never from shading" is a technique negative — §2.5's trap, for
-- the sixth time. The clause is simply gone; what depth *is* built from was
-- already said.)
--
--   * **Architectural / Blueprint Editorial** for Environment pages, which
--     have two references and keep coming back as rooms nobody lives in. A
--     blueprint is line-only by nature, so nothing has to be held back.
--   * **Minimal Symbolic** for Symbol pages, which have one reference and whose
--     standing fault, through 075, 078 and every render since, is that the
--     motifs never group. A style whose whole premise is few large forms
--     attacks that from the style layer instead of the composition layer.
--   * **Soft Botanical Line Art** as a genuine lighter variant of Botanical
--     Line, which carries 38 pages and produced the heaviest grounds this week.
--
-- Three for VV-Styles, where solid ink and drawn type are correct rather than
-- forbidden: Collegiate / Varsity Emblem, Luxury Editorial Typography and
-- Vintage Poster.
--
-- **"Feminine" is deliberately not here.** Reading the list, it describes what
-- is in the picture rather than how it is drawn. That belongs in a brief.
-- "Emotional Illustrative" is also held back: it may be an Editorial Scene
-- variant, but nobody has said what it means yet, and §2.2 is explicit that the
-- Style Library comes from Esoh and nothing is invented.
--
-- **The caution this is applied under, recorded because it outlives the
-- migration.** Of the seven coloring styles that already exist, two — Bold
-- Minimal and Hand-Drawn Doodle — are used by **zero** of the 180 Healing
-- Seasons pages, and 158 of the 180 run on Editorial Scene and Botanical Line
-- alone. The menu was never the constraint; D137 measured what was, and it was
-- exemplars. Each style added here multiplies a grid that is already short of
-- references, and D122's finding stands: with nothing to imitate the model
-- falls back on its own idea of a coloring page, which is a children's one.
-- **Architectural / Blueprint is being tested first against an Environment
-- page. If it does not earn its place, the other two should be reconsidered
-- rather than assumed.**
--
-- Wiring is mirrored from an existing style in the same category rather than
-- listed by hand, so a new style reaches exactly the templates its neighbours
-- reach and cannot drift. The form needs no code change — `/api/bootstrap`
-- reads the vocabulary from `prompt_blocks` itself.

begin;

-- ------------------------------------------------------- coloring-book styles

insert into prompt_blocks (kind, slug, label, body_text, category_id, art_style)
select 'base_style', 'hs-style-architectural',
       'Architectural / Blueprint Editorial',
       'A black and white line illustration for an adult coloring book drawn '
       'as an architectural elevation: even measured line of a single weight, '
       'true verticals and horizontals, and the edges where one plane meets '
       'another drawn as their own lines. Depth is built from overlap and from '
       'the outlines of built forms. Broad plain surfaces are left open '
       'between the drawn members.',
       id, 'Architectural / Blueprint'
  from categories where code = 'coloring-books';

insert into prompt_blocks (kind, slug, label, body_text, category_id, art_style)
select 'base_style', 'hs-style-minimal-symbolic', 'Minimal Symbolic',
       'A black and white line illustration for an adult coloring book built '
       'from a few emblematic forms drawn large and plainly — one clear '
       'contour each, and no interior detail beyond what the object needs to '
       'be recognised. Wide open paper is left between the forms, and every '
       'enclosed area is big enough to fill in one sweep of a pencil.',
       id, 'Minimal Symbolic'
  from categories where code = 'coloring-books';

insert into prompt_blocks (kind, slug, label, body_text, category_id, art_style)
select 'base_style', 'hs-style-soft-botanical', 'Soft Botanical Line Art',
       'A black and white line illustration for an adult coloring book built '
       'from flowers and foliage drawn with a light even line and generous '
       'space around every stem. Petals and leaves are simply outlined, a vein '
       'or two suggested rather than the whole structure drawn, and the page '
       'is left open and airy.',
       id, 'Soft Botanical Line Art'
  from categories where code = 'coloring-books';

-- -------------------------------------------------------------- apparel styles

insert into prompt_blocks (kind, slug, label, body_text, category_id, art_style)
select 'base_style', 'vvs-style-collegiate-emblem',
       'Collegiate / Varsity Emblem',
       'Flat screen-printed collegiate artwork in the manner of a varsity '
       'chenille patch or an athletics crest. A shield, arch or block monogram '
       'anchors the design, with slab or block lettering tiered above and '
       'below it and layered offset outlines around each letter. Symmetrical, '
       'centred, and built from a small number of flat solid inks.',
       id, 'Collegiate / Varsity Emblem'
  from categories where code = 'vv-styles';

insert into prompt_blocks (kind, slug, label, body_text, category_id, art_style)
select 'base_style', 'vvs-style-luxury-editorial-typography',
       'Luxury Editorial Typography',
       'Refined fashion-house typography. A short phrase set large in a '
       'high-contrast serif with wide letterspacing, held in generous empty '
       'space, with a single hairline rule or small mark as the only ornament. '
       'Solid ink, no texture and no distressing — the restraint is the '
       'design.',
       id, 'Luxury Editorial Typography'
  from categories where code = 'vv-styles';

insert into prompt_blocks (kind, slug, label, body_text, category_id, art_style)
select 'base_style', 'vvs-style-vintage-poster', 'Vintage Poster',
       'Mid-century printed poster artwork. A bold central image built from '
       'flat solid shapes in a few inks, with heavy display lettering arched '
       'or stacked around it and a plain rule containing the whole. The inks '
       'sit as solid areas with a slight overprint where they meet, and carry '
       'a faint press texture.',
       id, 'Vintage Poster'
  from categories where code = 'vv-styles';

-- --------------------------------------------------------------------- wiring

insert into template_blocks (template_id, block_id, position)
select tb.template_id, n.id, tb.position
  from template_blocks tb
  join prompt_blocks src on src.id = tb.block_id
  join prompt_blocks n
    on n.slug in ('hs-style-architectural', 'hs-style-minimal-symbolic',
                  'hs-style-soft-botanical')
 where src.slug = 'hs-style-botanical';

insert into template_blocks (template_id, block_id, position)
select tb.template_id, n.id, tb.position
  from template_blocks tb
  join prompt_blocks src on src.id = tb.block_id
  join prompt_blocks n
    on n.slug in ('vvs-style-collegiate-emblem',
                  'vvs-style-luxury-editorial-typography',
                  'vvs-style-vintage-poster')
 where src.slug = 'vvs-style-bold-minimal';

-- ------------------------------------------------------------------ assertions

do $$
declare n int; expected int; s text;
begin
  -- Each new coloring style reaches exactly the templates Botanical Line does.
  select count(*) into expected from template_blocks tb
    join prompt_blocks b on b.id = tb.block_id
   where b.slug = 'hs-style-botanical';
  foreach s in array array['hs-style-architectural',
                           'hs-style-minimal-symbolic',
                           'hs-style-soft-botanical']
  loop
    select count(*) into n from template_blocks tb
      join prompt_blocks b on b.id = tb.block_id where b.slug = s;
    if n <> expected then
      raise exception '% reaches % templates, Botanical Line reaches %',
        s, n, expected;
    end if;
  end loop;

  -- And each apparel style reaches exactly what Bold Minimal does.
  select count(*) into expected from template_blocks tb
    join prompt_blocks b on b.id = tb.block_id
   where b.slug = 'vvs-style-bold-minimal';
  foreach s in array array['vvs-style-collegiate-emblem',
                           'vvs-style-luxury-editorial-typography',
                           'vvs-style-vintage-poster']
  loop
    select count(*) into n from template_blocks tb
      join prompt_blocks b on b.id = tb.block_id where b.slug = s;
    if n <> expected then
      raise exception '% reaches % templates, Bold Minimal reaches %',
        s, n, expected;
    end if;
  end loop;

  -- **No coloring style may describe filled ink.** This is the whole reason
  -- the apparel blocks were re-authored rather than copied, and it is the one
  -- mistake that would be invisible until a page came back solid black.
  select count(*) into n from prompt_blocks b
    join categories c on c.id = b.category_id
   where b.kind = 'base_style' and c.code = 'coloring-books' and b.is_active
     and b.body_text ~* 'solid (ink|colour|color|shape|area)'
                        '|filled solid|flat ink|fills are';
  if n <> 0 then
    raise exception '% coloring style(s) describe filled ink — see D44', n;
  end if;

  -- Nor drawn lettering, which D23 and 071 keep off the page.
  select count(*) into n from prompt_blocks b
    join categories c on c.id = b.category_id
   where b.kind = 'base_style' and c.code = 'coloring-books' and b.is_active
     and b.body_text ~* 'lettering|typograph|monogram|display type';
  if n <> 0 then
    raise exception '% coloring style(s) ask for lettering — see D23', n;
  end if;

  -- Nor hatching, which passes an ink check and cannot be coloured (D110).
  select count(*) into n from prompt_blocks b
    join categories c on c.id = b.category_id
   where b.kind = 'base_style' and c.code = 'coloring-books' and b.is_active
     and b.body_text ~* 'hatch|stipple|parallel line|shading';
  if n <> 0 then
    raise exception '% coloring style(s) ask for hatching — see D110', n;
  end if;

  -- Ten coloring styles and twelve apparel styles, counted so a later
  -- migration that drops one has to say so.
  select count(*) into n from prompt_blocks b
    join categories c on c.id = b.category_id
   where b.kind = 'base_style' and c.code = 'coloring-books' and b.is_active;
  if n <> 10 then raise exception 'expected 10 coloring styles, got %', n; end if;

  select count(*) into n from prompt_blocks b
    join categories c on c.id = b.category_id
   where b.kind = 'base_style' and c.code = 'vv-styles' and b.is_active;
  if n <> 12 then raise exception 'expected 12 apparel styles, got %', n; end if;
end $$;

commit;

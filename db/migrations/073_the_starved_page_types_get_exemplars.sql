-- 073_the_starved_page_types_get_exemplars.sql
--
-- D137 measured the gap D122 left open: Solo portrait and Community scene are
-- shown 4 references, Environment page 2, and **Quote, Symbol and Decorative
-- none at all**. Esoh's review of the first book mapped onto that exactly —
-- the pages with no exemplar are the ones he called doodles. With nothing to
-- imitate the model falls back on its own idea of a colouring page, which is a
-- children's one.
--
-- Esoh sourced candidates from ChatGPT, Gemini and Perplexity and put them in
-- the exemplar folder. Nine files, two of which held two pages side by side and
-- were split on a 100% white gutter column.
--
-- **Four carried drawn lettering and were blanked before registering.** §6's law
-- is that an exemplar transfers its faults along with its virtues, and 071 had
-- just stopped the model drawing its own quote text — registering a reference
-- with a phrase in it would teach the habit straight back, and a drawn phrase
-- cannot be spell-checked or held pending the Spanish native review (065). The
-- text area is painted white, which also teaches the thing the quote page most
-- needs: a border around a clear open centre.
--
-- A fifth had lettering in an unexpected place — `solo-garden-journal` has "New
-- Season Same Me Bigger Dreams" written on the mug, which is D120's exact
-- defect in an exemplar. Blanked too.
--
-- **Registered as usable, by page type:**
--
--   Quote page      3 — botanical border, hibiscus corners, wildflower and
--                       stones. They agree with each other, which §6 requires:
--                       every one is a worked border around an open centre.
--   Decorative page 1 — a wrought-iron garden gate with stone arches, a
--                       fountain and cobbles. Three depth planes and ornament
--                       with structure, which is what the tool's decorative
--                       pages have been missing.
--   Community scene 3 — Community had no reference of its own and was borrowing
--                       Solo portraits through D122's has-figures fallback.
--
-- **Registered as studies, deliberately not usable:**
--
--   `quote-arch-and-hands` — an arch with cupped hands and a sunrise. Good, and
--   structurally unlike the other three; §6 warns that mixed exemplars average
--   out, so it is kept to look at rather than to teach.
--   `solo-garden-journal`, `solo-balcony-sunset` — both excellent, both Solo
--   portrait, and **D130 recorded Esoh's four by name**. Promoting either is
--   Esoh's call, not a side effect of this migration.
--
-- **Symbol page still has nothing.** None of the nine is a motif cluster. Esoh
-- is making one.

begin;

insert into reference_images
  (item_id, asset_id, label, storage_path, kind, page_type, art_style,
   usable_as_input, notes)
values
  (null, null, 'Quote page — botanical border',
   'exemplars/quote-botanical-border.png', 'exemplar', 'Quote page', null, true,
   'Sourced by Esoh 2026-09-14. Magnolia, eucalyptus, fern, olive, yarrow and '
   'stacked river stones at three scales around an open centre. Lettering '
   'blanked before registering (071).'),
  (null, null, 'Quote page — hibiscus corners',
   'exemplars/quote-hibiscus-corners.png', 'exemplar', 'Quote page', null, true,
   'Sourced by Esoh 2026-09-14. Corner clusters rather than an even band, with '
   'stamens, veins and buds drawn inside each form. Lettering blanked.'),
  (null, null, 'Quote page — wildflower and stones',
   'exemplars/quote-wildflower-stones.png', 'exemplar', 'Quote page', null, true,
   'Sourced by Esoh 2026-09-14. Organic border, sun rays, a fern spiral and a '
   'run of flat stones. Lettering blanked.'),
  (null, null, 'Decorative page — garden gate',
   'exemplars/decorative-garden-gate.png', 'exemplar', 'Decorative page', null, true,
   'Sourced by Esoh 2026-09-14. The first reference this page type has ever '
   'had. Wrought-iron scrollwork, stone arch, tiered fountain, cobbles, '
   'magnolias and ferns across three depth planes.'),
  (null, null, 'Community scene — around the table',
   'exemplars/group-around-the-table.png', 'exemplar', 'Community scene', null, true,
   'Sourced by Esoh 2026-09-14. Four adults, four different hairstyles, and the '
   'personal effects 072 built a field for — statement earrings, layered '
   'necklaces, bracelets, glasses. Pattern on every surface: mugs, vase, bowl, '
   'planter, table runner.'),
  (null, null, 'Community scene — workshop',
   'exemplars/group-workshop.png', 'exemplar', 'Community scene', null, true,
   'Sourced by Esoh 2026-09-14. Four adults at a work table, framed art, plants '
   'and a window behind, patterned knitwear.'),
  (null, null, 'Community scene — potting bench',
   'exemplars/group-potting-bench.png', 'exemplar', 'Community scene', null, true,
   'Sourced by Esoh 2026-09-14. Split from a two-page sheet.'),
  (null, null, 'Quote page — arch and hands (study)',
   'exemplars/quote-arch-and-hands.png', 'study', 'Quote page', null, false,
   'Sourced by Esoh 2026-09-14. Structurally unlike the other three quote '
   'references — an arch, a sunrise and cupped hands. Kept to look at, not to '
   'teach, because §6 says mixed exemplars average out.'),
  (null, null, 'Solo portrait — garden journal (study)',
   'exemplars/solo-garden-journal.png', 'study', 'Solo portrait', null, false,
   'Sourced by Esoh 2026-09-14. Earrings, necklaces, bracelets, a patterned '
   'kimono and real garden depth. Not usable only because D130 recorded Esoh''s '
   'four Solo portrait references by name; promoting this is his call. The mug '
   'lettering was blanked (D120).'),
  (null, null, 'Solo portrait — balcony sunset (study)',
   'exemplars/solo-balcony-sunset.png', 'study', 'Solo portrait', null, false,
   'Sourced by Esoh 2026-09-14, split from a two-page sheet. Headwrap, hoop '
   'earrings, fringed shawl, patterned pots. Same reason as above.');

do $$
declare n int;
begin
  select count(*) into n from reference_images
   where usable_as_input and page_type = 'Quote page';
  if n <> 3 then raise exception 'expected 3 quote references, got %', n; end if;

  select count(*) into n from reference_images
   where usable_as_input and page_type = 'Decorative page';
  if n <> 1 then raise exception 'expected 1 decorative reference, got %', n; end if;

  select count(*) into n from reference_images
   where usable_as_input and page_type = 'Community scene';
  if n <> 3 then raise exception 'expected 3 community references, got %', n; end if;

  -- D130's four stand untouched.
  select count(*) into n from reference_images
   where usable_as_input and page_type = 'Solo portrait';
  if n <> 4 then raise exception 'Esoh''s four Solo portrait references changed: % usable', n; end if;

  -- Symbol page is still the open gap, and saying so is the point.
  select count(*) into n from reference_images
   where usable_as_input and page_type = 'Symbol page';
  if n <> 0 then raise exception 'a Symbol reference appeared unannounced'; end if;
end $$;

commit;

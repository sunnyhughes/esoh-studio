-- 071_the_quote_page_stops_asking_for_its_own_lettering.sql
--
-- The first African American Spring quote page came back with "Healing one day
-- at a time" drawn across it in script. Three instructions met in that prompt:
--
--   TPL-03 composition   "Top-third: quote"
--   hs-comp-quote-page   "Draw no letters, words or writing anywhere."
--   the brief            "Centered hand-lettered phrase: Healing one day at a
--                         time. ... generous white space around words"
--
-- **The brief won. Sixth time** — D118, D120, D121, D131, D135 and now this.
--
-- The cause is not a mistake in the source. `prompt-library-by-product-line.csv`
-- was written for a workflow where the image carries its own lettering, and
-- Esoh's own TPL-03 spec says as much: "Set the quote from the tracker's quote
-- text column in a clean serif". 056 imported those briefs whole, and they now
-- sit against a tool that letters a page afterwards as SVG (D23, D61).
--
-- **The tool's way has to win here, and not because it was first.** The lettering
-- is vector, so it prints at the device's resolution rather than the raster's;
-- it can be restyled, re-set or translated against the same art any number of
-- times; and it is the only reason 065's gate works at all — a phrase drawn into
-- the pixels cannot be held back pending a native-speaker review, which is the
-- launch condition on all four Hispanic products. A drawn phrase also cannot be
-- spell-checked, and `RECOVERY JOURHAL` in D120 is what that looks like.
--
-- Three rows, all African American Spring: 056 only re-authored that season, so
-- the other 33 quote pages still carry briefs that describe a border and no
-- phrase. The replacements say what D119's best-ever quote page said — a border,
-- and a clean blank oval — and name the motifs the library chose for each.

begin;

update items set brief =
  'An open spring floral border of blossoms, butterflies, leaves and small '
  'raindrops filling the page around a clear upright oval at the centre, left '
  'completely blank. Coloring book line art.',
  updated_at = now()
 where ref = 'African American Spring 05';

update items set brief =
  'A light spring garden border of leaves, flowers and gentle raindrops around '
  'a clear upright oval at the centre, left completely blank, with generous open '
  'space to colour between the growth. Coloring book line art.',
  updated_at = now()
 where ref = 'African American Spring 09';

update items set brief =
  'A light border of butterflies, sprouting leaves, flower buds and gentle rain '
  'around a clear upright oval at the centre, left completely blank; a spacious '
  'composition with room between every element. Coloring book line art.',
  updated_at = now()
 where ref = 'African American Spring 14';

do $$
declare n int;
begin
  select count(*) into n from items
   where page_type = 'Quote page'
     and brief ~* 'hand-lettered|phrase:|around words';
  if n <> 0 then raise exception '% quote briefs still ask for lettering', n; end if;

  -- The blank centre is what the overlay is set into; without it there is
  -- nowhere for the type to land (D23).
  select count(*) into n from items
   where ref like 'African American Spring%' and page_type = 'Quote page'
     and brief !~* 'oval';
  if n <> 0 then raise exception '% quote briefs reserve no centre', n; end if;

  -- And the quotes themselves are untouched: they live in the library now (065).
  select count(*) into n from items i join quotes q on q.id = i.quote_id
   where i.ref like 'African American Spring%' and i.quote_text is distinct from q.quote_text;
  if n <> 0 then raise exception 'the quote mirror drifted'; end if;
end $$;

commit;

-- 076_the_symbol_page_gets_its_first_reference.sql
--
-- Symbol page has had no reference since the project began. D122 named it part
-- of the open gap, D137 measured it against a whole book — the page types with
-- no exemplar are the ones Esoh called doodles — and 074 lent it the quote
-- references as a stopgap, written to lapse the moment it had one of its own.
--
-- **This is that moment.** Esoh sourced it 2026-09-14. No text, no panels, no
-- preparation needed.
--
-- What it teaches that the stopgap could not:
--
--   * **A composed wreath rather than an even field.** The motifs ring a clear
--     centre. 075 asked for "three or four groups with clear channels of white
--     between them" and got a uniform all-over field instead; this is what the
--     words were reaching for.
--   * **A vignette inside the ring** — a sunrise over hedgerowed fields — which
--     gives a motif page the depth a flat sheet of objects cannot have.
--   * **Pattern inside objects**: a floral band on the watering can, visible
--     weave on the basket, an embroidered geometric on the ribbon. This is the
--     gap D137 counted and 047 only half closed.
--   * **Butterflies drawn as outlined cells rather than solid black.** 075's
--     monarch carried filled wing margins; D126 accepts filled areas, but on a
--     page made entirely of motifs it is colourable area given away.
--   * **Adinkra-style emblems** at the edges, which connect to the symbol
--     vocabulary recorded in 074's chart — ankh, triskelion, mandala — and are
--     the first sign of that vocabulary in a drawable form.
--
-- Registering it ends the borrow: `lib/generate.ts` only lends Quote references
-- to a Symbol page "while it has none of its own", so the fallback expires here
-- without any code change. That was the point of writing it that way.

begin;

insert into reference_images
  (item_id, asset_id, label, storage_path, kind, page_type, art_style,
   usable_as_input, notes)
values
  (null, null, 'Symbol page — spring wreath',
   'exemplars/symbol-spring-wreath.png', 'exemplar', 'Symbol page', null, true,
   'Sourced by Esoh 2026-09-14. The first reference this page type has ever '
   'had. A ring of magnolia, dogwood, tulips and pussy willow around a sunrise '
   'vignette and cupped hands holding a seedling; a patterned watering can, a '
   'woven basket, an embroidered ribbon, butterflies drawn as outlined cells, '
   'and Adinkra-style emblems at the edges. No lettering, so nothing was '
   'blanked.');

do $$
declare n int;
begin
  select count(*) into n from reference_images
   where usable_as_input and page_type = 'Symbol page';
  if n <> 1 then raise exception 'expected 1 symbol reference, got %', n; end if;

  -- Every page type that has figures or motifs now has something of its own.
  -- Only Environment keeps its two; nothing here should have moved it.
  select count(*) into n from reference_images
   where usable_as_input and page_type = 'Environment page';
  if n <> 2 then raise exception 'the environment references changed'; end if;
end $$;

commit;

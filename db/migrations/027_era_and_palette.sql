-- 027_era_and_palette.sql
--
-- Two things the user identified by looking at output, both traced to text
-- written in 020 and both narrower than they appeared.
--
-- **The era line.** `vvs-style-retro-groovy` opened "Flat 1970s printed
-- artwork" and closed "the way a period poster is printed in a single pass".
-- It reads in every image the user has generated because every image they
-- have generated is VVS-0070, the only item in 130 whose art style is Retro
-- Groovy. It is in one block of nine and has never touched anything else.
--
-- Still worth fixing: it asks for a period *artifact* rather than a design in
-- a period manner, and the difference is fading. Retro Groovy keeps its
-- character — thick rounded contours, generous curves, solid areas — and the
-- ink is now described as fresh. Stated positively, since D46 governs: naming
-- fading in a negative is how you get fading.
--
-- The era number goes. A style block that names a decade dates every design
-- drawn in it, and the decade was never the point — the shapes were.
--
-- **The palette list.** Twelve options lifted verbatim from the twelve
-- designs in the portfolio capsule. Seven carry an explicit ageing or muting
-- word — aged cream, muted gold, warm cream, soft peach, muted brass, antique
-- gold, vintage aqua, soft ivory — so the menu reads as one register with no
-- way out of it visible. That is what the user saw.
--
-- The replacement spans both registers: eight built on saturated colour, four
-- deliberately restrained, because Editorial Typographic and Tattoo Linework
-- want restraint and a menu that cannot express it is no better than one that
-- cannot express brightness.
--
-- Two things about this field that are worth stating, since neither is
-- obvious from looking at it:
--
--   * It is a `combo`, not a `select`. The list suggests; anything typed is
--     accepted, and only `select` fields are seeded with their first option.
--     Nothing was ever limiting a design to these twelve.
--   * Left empty the block drops out and the model chooses. On this design
--     that produced more colour than any named palette did — 12 to 14 major
--     colours against 9. An empty palette is a legitimate setting, not an
--     unfinished one.

begin;

update prompt_blocks set body_text =
  'Flat retro-inspired printed artwork. Thick rounded contours, generous '
  'curves, and inks laid down as solid areas. Lettering and imagery sit in '
  'the same plane and share one outline weight. The shapes carry the period; '
  'the ink itself is fresh and fully saturated, as though the shirt has just '
  'come off the press.'
 where slug = 'vvs-style-retro-groovy';

update prompt_templates t
   set variables_json = (
     select jsonb_agg(
              case when v->>'name' = 'palette'
                   then jsonb_set(v, '{options}', $opts$[
                     "hot coral, cream, deep teal, sunshine yellow",
                     "electric cobalt, white, safety orange, black",
                     "acid lime, hot pink, white, black",
                     "cherry red, bright gold, cream, jet black",
                     "tangerine, turquoise, off-white, dark chocolate",
                     "magenta, deep violet, peach, cream",
                     "kelly green, cherry red, cream, black",
                     "sky blue, sunny yellow, white, navy",
                     "black, ivory, rich emerald green",
                     "espresso brown, bone, muted brass",
                     "forest green, clay red, cream, antique gold",
                     "deep purple, muted gold, charcoal, soft ivory"
                   ]$opts$::jsonb)
                   else v
              end
              order by ord
            )
       from jsonb_array_elements(t.variables_json) with ordinality as e(v, ord)
   )
 where t.slug = 'vvs-front-print';

update prompt_templates
   set variables_json = jsonb_set(
         variables_json,
         '{3,placeholder}',
         '"two to four named colours, or leave blank and let the design choose"'
       )
 where slug = 'vvs-front-print'
   and variables_json->3->>'name' = 'palette';

commit;

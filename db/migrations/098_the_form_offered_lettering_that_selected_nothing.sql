-- 098 — The form offered lettering that selected nothing
--
-- 093 gave lettering 25 blocks keyed on `prompt_blocks.lettering_style` and
-- retired the one generic block that read `{{lettering}}`. What it did not do
-- was revisit the form, which has offered the same eleven hand-written prose
-- descriptions since the template was written:
--
--     "thick athletic serif for the opening words, condensed sans beneath"
--     "slanted 1970s display lettering with a compact subtitle"
--     ...
--
-- Those are descriptions, not names. None of them equals a block's
-- `lettering_style`, and no block reads the `{{lettering}}` slot any more, so
-- since 093 an ad-hoc apparel job — one generated from the form without an item
-- row behind it — has reached the model with **no lettering instruction at all**,
-- and the operator had no way to tell. Item-driven jobs were unaffected: they
-- resolve from `items.lettering_style`, which holds the sheet's own names.
--
-- The form now carries a Lettering style select and a Tone select, both filled
-- from the blocks themselves through the per-category vocabulary that already
-- serves art style — so adding a block in SQL adds it to the form, and a
-- category with no such blocks shows no field. That makes this variable both
-- dead and duplicated, so it goes.
--
-- Kept, deliberately: `generate.ts` still accepts `inputs.lettering` as the last
-- fallback for `letteringStyle`. Nothing in the app sends it now, but a script
-- or a saved request might, and a string that happens to name a real style
-- should still select its block.

update prompt_templates
   set variables_json = (
         select jsonb_agg(v order by ord)
           from jsonb_array_elements(variables_json::jsonb)
                with ordinality as e(v, ord)
          where v->>'name' <> 'lettering'
       )::json
 where slug = 'vvs-front-print';

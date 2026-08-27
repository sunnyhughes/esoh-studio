-- 023_colour_has_to_live.sql
--
-- The first accepted design was correct on every measurement and dull to look
-- at. The user's words: boring, stiff, neutral, outdated — and "the coffee
-- images I placed in reference are colorful and can be used on any color
-- shirt." Both halves of that are the fault of two blocks written in 020.
--
-- **The ink limit was wrong, not merely tight.** `vvs-flat-ink` said the
-- design uses two to four inks in total. That is a *screen printing*
-- constraint, where each colour is a separate physical screen. This line
-- prints DTF through Printify, which is full colour and has no such limit.
-- The capsule document's "3-4 ink spot-color design; ideal for screen print
-- or DTF" conflated the two methods and the conflation was carried into a
-- block that governs all 130 designs.
--
-- Measured, quantised to 24 levels per channel and counting only colours
-- covering more than 1% of the opaque area: the two accepted ChatGPT
-- references carry 19 and 15 major colours. The generation made under this
-- block carries 9. The constraint was halving the palette on every design.
--
-- What stays is flatness — solid areas with hard edges. That is real, it is
-- what the references do, it is what survives upscaling, and it is not what
-- was making the work dull.
--
-- **Contrast belongs to the artwork, not to the shirt.** `vvs-garment` asked
-- every colour to hold contrast against the fabric, which is how the coffee
-- design ended up legible on natural sand and nearly invisible on black. The
-- references solve this the way apparel actually solves it: dark contours and
-- light fills inside them, so the design carries its own contrast and reads on
-- any garment. That also restores the arithmetic in section 4.5 — one file
-- across six garment colours — which D75 had written off. The garment is still
-- named, but as the context it is, not as a palette to match.
--
-- **Colour is now asked for positively.** Nothing in the block layer ever said
-- the work should be bright. Flatness, limited inks and print-safety were all
-- stated; liveliness was left to chance and did not arrive.

begin;

update prompt_blocks set body_text =
  'Built for DTF, which prints full colour: use as many colours as the design '
  'wants. Every area of colour is one flat, solid, evenly filled shape with a '
  'hard edge, and colours meet each other cleanly along a definite boundary. '
  'All type is filled solid.'
 where slug = 'vvs-flat-ink';

update prompt_blocks set body_text =
  'The design carries its own contrast so it reads on any garment colour: '
  'shapes are held by dark contours with lighter fills inside them, and the '
  'design does not rely on the fabric behind it to separate one element from '
  'another. It will first be printed on {{garment}} fabric.'
 where slug = 'vvs-garment';

insert into prompt_blocks (kind, slug, label, category_id, body_text)
select 'color', 'vvs-colour-life', 'Colour has to live', c.id,
  'Colour is bright, saturated and cheerful. Light, mid and dark values are '
  'all present, so the design has depth and lift rather than sitting in one '
  'register. Where a palette is named, take it at its most vivid reading.'
from categories c where c.code = 'vv-styles';

insert into template_blocks (template_id, block_id, position)
select t.id, b.id, 41
from prompt_templates t, prompt_blocks b
where t.slug = 'vvs-front-print' and b.slug = 'vvs-colour-life';

-- ------------------------------------------------------------------ Love
--
-- Love went to Family & Faith in 021 as "the nearest relational grouping".
-- The user's correction is right and the reasoning was thin: love is not a
-- subset of family or of faith, and filing it under either narrows what the
-- designs can say before a single one is drawn. It gets its own collection.

insert into collections (category_id, slug, name, description)
select c.id, 'love', 'Love',
       'Love in its own right — romantic, self-directed, chosen family, grief.'
from categories c
where c.code = 'vv-styles'
  and not exists (
    select 1 from collections x where x.category_id = c.id and x.slug = 'love'
  );

update items i set collection_id = (
    select col.id from collections col
    join categories cat on cat.id = col.category_id
    where cat.code = 'vv-styles' and col.slug = 'love'
  )
 where i.category_id = (select id from categories where code = 'vv-styles')
   and i.source_row->>'Category' = 'Love';

commit;

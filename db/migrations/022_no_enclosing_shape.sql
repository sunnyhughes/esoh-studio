-- 022_no_enclosing_shape.sql
--
-- Two faults visible on the first two VV-Styles generations. Both were mine,
-- introduced in 020.
--
-- 1. The composition block asked for the panel. "Composed as one
--    self-contained unit" and "every element locks into that one shape" were
--    written to mean *not scattered*, and the model read them the only other
--    way they can be read: one shape. It supplied a shape to lock everything
--    into — first an irregular cream blob, then a rounded-rectangle poster
--    card. Both are the D34 defect, which is the single thing Stage C exists
--    to remove. The grouping is now described as an arrangement, and nothing
--    asks for one silhouette.
--
-- 2. The output block described the surrounding transparency but never said
--    that nothing sits behind the design. "Empty transparency surrounds it on
--    all four sides" was satisfied exactly — the panel had clear space on all
--    four sides. The enclosing shape is now excluded by name.
--
--    Naming it is consistent with D46, not a breach of it. D46 is about
--    rendering *technique*: naming hatching or stippling in a negative makes
--    the model render it. Content excluded by name holds fine, and a panel, a
--    card and a badge field are objects. The capsule document's own prompts
--    exclude "a visible rectangular background block" this way, and the
--    generations made from them came back correctly knocked out.
--
-- Separately and not in this migration: `background: "transparent"` was never
-- being passed to the provider. The category carried the flag, the provider
-- supported it, and the route did not join them, so both of these prompts ran
-- without it. Setting it dropped the soft feathered edge from 4.9% of the
-- image to 1.7%. The panel survived it, which is what this migration is for.

begin;

update prompt_blocks set body_text =
  'A single front-print graphic, centred, with its elements arranged into one '
  'balanced group. It reads at arm''s length: the phrase lands first, the '
  'imagery second. Nothing drifts loose at the margins.'
 where slug = 'vvs-comp-front-print';

update prompt_blocks set body_text =
  'Delivered as isolated cut-out artwork. Nothing sits behind the design: no '
  'background panel, no card, no badge field, no rounded rectangle, no circle '
  'or banner shape holding the artwork. Each element ends at its own outline, '
  'and everywhere the design does not draw — around it and in the gaps '
  'between its shapes — is fully transparent, so the garment shows through.'
 where slug = 'vvs-output';

commit;

-- 095 — A badge is not a background
--
-- Sunshine generated five designs in Printify's tool from this library's own
-- spreadsheet text and they read better than ours. Four of the five are built
-- on a shape `vvs-output` forbids by name:
--
--   Fathers Matter          a shield crest with a banner ribbon
--   Wheel of Feelings       a circle
--   Feelings Control Panel  a rounded rectangle inside a rounded rectangle
--   Built Different         banner scrolls above and below
--
-- The block said: "Nothing sits behind the design: no background panel, no
-- card, no badge field, no rounded rectangle, no circle or banner shape holding
-- the artwork."
--
-- D72 wrote that to kill a real defect — two generations produced an opaque
-- cream blob and a poster card floating behind the artwork, which print as a
-- visible box on any garment that is not white. The defect was real. The rule
-- was written as a ban on **shapes** when the requirement is about
-- **transparency**, and those are not the same thing. A shield that *is* the
-- design carries its own contour, colour and detail; a panel *behind* the
-- design is undrawn ground. The prompt could not tell them apart, so it
-- forbade both.
--
-- It also fought this library's own vocabulary: `Vintage Badge` and
-- `Collegiate / Varsity Emblem` ask for a patch and a crest in one block while
-- another block forbids a badge field. Three art styles were arguing with the
-- output rule on every generation.
--
-- Three changes here, all from that comparison:
--
-- 1. `vvs-output` is reframed around transparency. The enforcement was never
--    the wording anyway — `lib/transparency.ts` measures it (D74).
-- 2. `vvs-keyline` is new. Every one of the five reference designs carries two
--    or three offset contours around its lettering, which is what makes type
--    pop off fabric. Nothing in this library ever asked for it; `vvs-flat-ink`
--    says "all type is filled solid" and we stopped there.
-- 3. `vvs-comp-front-print` is rewritten for density. Measured: the Printify
--    panel covers 100% of its own area, our two generations covered 35% and
--    47%, and D74 records this project's own accepted references at 60-72%.
--    "Nothing drifts loose at the margins" was producing timid, sparse layouts
--    and suppressing the bursts and arrows that carry the energy in all five.
--
-- **Watch D74 after this.** Its `boundsFillFraction` check fails a design
-- filling more than 80% of its own bounding box, on the reasoning that "real
-- cut-out artwork leaves gaps between its elements and a panel welds them
-- together". That is the same conflation this migration is removing, one layer
-- down. A legitimate dense shield may now trip it. The threshold is left alone
-- until there is real output to judge it against — changing a measurement and
-- the thing it measures in one step would leave nothing to check against.

update prompt_blocks set body_text =
  'Delivered as isolated cut-out artwork standing on nothing. A badge, shield, '
  'circle, banner or panel belongs in the design whenever it is drawn as artwork '
  'in its own right, carrying its own contour, its own colour and its own '
  'detail. Outside that artwork the file is empty: around the whole design, and '
  'inside every gap between its shapes, the ground is fully transparent and the '
  'garment shows through.'
where slug = 'vvs-output';

update prompt_blocks set body_text =
  'A single front-print graphic, centred, worked up to fill its area. The '
  'arrangement reaches the edges of its own footprint and the space between '
  'elements is closed up, so the design reads as one dense confident group '
  'rather than a few marks in a large field. It reads at arm''s length, the '
  'phrase landing first and the imagery second. Small accents — bursts, arrows, '
  'sparks, motion marks — are welcome where they tie the group together.'
where slug = 'vvs-comp-front-print';

insert into prompt_blocks (kind, slug, label, category_id, body_text)
select 'print_req', 'vvs-keyline', 'Keyline', c.id,
  'Type and the focal shapes are separated from the fabric by contour rather '
  'than by luck: they carry one or more offset outlines in a contrasting ink, '
  'each following the form exactly and sitting a consistent distance outside '
  'the one before it. Two or three stacked contours are usual on bold display '
  'work; refined editorial work takes one, or leaves the form bare where the '
  'style is built on restraint.'
from categories c where c.code = 'vv-styles';

insert into template_blocks (template_id, block_id, position)
select t.id, b.id, 62
from prompt_templates t, prompt_blocks b
where t.slug = 'vvs-front-print' and b.slug = 'vvs-keyline';

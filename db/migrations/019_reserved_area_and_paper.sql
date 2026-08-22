-- 019_reserved_area_and_paper.sql
--
-- Two faults visible on the first real Quote page.
--
-- 1. The reserved centre came back as a rough oval narrower than the type box,
--    so the first and last lines crossed into the pattern. "Roughly half the
--    page height" says nothing about width, and the model chose its own. Both
--    dimensions are now stated, and the overlay's default box was tightened to
--    sit inside what is actually asked for.
--
-- 2. The page printed on aged, speckled parchment rather than white. The output
--    block said "pure black line work on white", which the model read as a
--    description of the ink and not of the paper. A coloring page has to be
--    white — a tint costs ink on every page of the print run and dirties every
--    colour laid over it. The paper is now stated in its own right.

begin;

update prompt_blocks set body_text =
  'No people. A decorative arrangement fills the page around a clear open area '
  'at the centre — an upright oval about two-thirds the page width and half the '
  'page height, left completely blank with nothing drawn inside it and nothing '
  'crossing into it. Draw no letters, words or writing anywhere.'
 where slug = 'hs-comp-quote-page';

update prompt_blocks set body_text =
  'Pure black line work on clean white paper, printed at full page. The paper '
  'itself is plain bright white — no tint, no ageing, no speckling, no paper '
  'grain. Every area inside the outlines is open white, ready to be coloured by '
  'hand. No border or frame. Keep key subject matter clear of the outer edge.'
 where slug = 'hs-output';

commit;

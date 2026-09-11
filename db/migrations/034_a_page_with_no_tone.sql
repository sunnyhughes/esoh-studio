-- 034_a_page_with_no_tone.sql
--
-- The word "dark" comes out of the prompt, and the rule behind it is written
-- down.
--
-- A coloring page has no tone. Every area inside the outlines is white until a
-- reader puts colour there (§3.4). So a colour word in the prompt names the one
-- thing the page cannot carry, and the model resolves it the only way it can --
-- by filling the shape.
--
-- Measured on 2026-09-10, on `Hispanic Fall 01`, same prompt but for the colour
-- word: 35.8% black in the head crop with "dark", 18.4% without, and the waves
-- came back with white inside them instead of reading as one mass.
--
-- Three earlier attempts on the same defect failed, and they are recorded here
-- so nobody spends the money again:
--
--   * 032 named the hair per item (D45). Still filled.
--   * 033 removed the technique negative from hs-figure-rendering. Still filled.
--   * Generating with reference images switched off. Still filled, slightly
--     flatter -- so the exemplars, which do carry filled hair, were not the
--     cause of it here.
--
-- This is a sibling of the law in §2.5, not a restatement. §2.5 is about
-- technique negatives backfiring -- naming the failure summons it. This is
-- about colour words having nowhere to land. Both surface the same way, an
-- area that should be open coming back filled, which is most likely why four
-- separate investigations walked past it.
--
-- ONLY THE UNAMBIGUOUS CASES ARE CHANGED HERE. "dark" modifying hair or a
-- braid is tone applied to a surface the reader is meant to colour, it is the
-- exact string that was measured, and it is removed in all sixteen places --
-- eight briefs and eight `items.hair` values. The colour word arrives twice
-- because D-keep-both (2026-09-10) holds the brief as a faithful copy of the
-- workbook, so fixing the hair column alone would leave "dark" in the subject
-- line and change nothing.
--
-- FLAGGED, NOT CHANGED. Each of these needs Esoh, not a regex:
--
--   * `Hispanic Summer 08` -- "silver-streaked hair". Greying hair is age and
--     identity, not decoration, and stripping the word would flatten an older
--     woman into an unmarked one. It is also genuinely undrawable in tone. The
--     structural fix -- a few streaks drawn as their own outlined sections --
--     keeps the meaning and obeys the rule, but it is a rewrite of Esoh's text.
--   * `Hispanic Fall 03` -- "amber window light". §3.5 already established
--     there is no light on an outline page; this asks for light and a colour.
--   * Five uses of "bright" (AA Summer 09, Hispanic Spring 04, Spring 07,
--     Summer 02, Multiracial Summer 10). "Bright" reads as airy rather than as
--     a colour and has not been observed to fill anything. Left alone pending
--     evidence rather than changed on suspicion.
--
-- PROTECTED. "white space" in `Hispanic Summer 11` and `Hispanic Winter 12` is
-- a composition term and white is what the page already is. A broad sweep for
-- colour words would have eaten both. They are asserted below.

begin;

update items set brief = 'Latina woman in her 40s with thick wavy hair wrapped in a textured shawl, seated beside a fall-lit window writing in a journal; a warm mug, leafy plant, and thoughtful gaze convey reflection and emotional release.', updated_at = now() where ref = 'Hispanic Fall 01';
update items set brief = 'Latina woman in her 40s with long braid preparing herbal tea in a tidy kitchen, hands relaxed and expression content; warm wood, ceramic dishes, leafy plant, and autumn light turn an ordinary routine into intentional self-care.', updated_at = now() where ref = 'Hispanic Fall 04';
update items set brief = 'Latina woman in her 30s with long wavy hair, seated at a sunlit table beside open curtains, writing in a recovery journal as potted spring flowers frame the scene; relaxed shoulders and a quietly hopeful expression convey new beginnings.', updated_at = now() where ref = 'Hispanic Spring 01';
update items set brief = 'Latino man in his 30s with short textured hair, walking a tree-lined neighborhood path just after sunrise, hands relaxed and gaze forward; fresh leaves and damp pavement reinforce steady progress and a clear new direction.', updated_at = now() where ref = 'Hispanic Spring 02';
update items set brief = 'Hispanic young adult with curly hair, seated cross-legged on a tiled patio practicing slow grounding breaths, one hand over the heart; potted herbs, small blossoms, and open sky create a calm scene of self-awareness.', updated_at = now() where ref = 'Hispanic Spring 03';
update items set brief = 'Latino man in his 30s with short curly hair, walking slowly along a waterfront boardwalk with sleeves rolled up and relaxed hands; bright water, palms or riverside trees, and a wide horizon create a visual sense of forward movement.', updated_at = now() where ref = 'Hispanic Summer 02';
update items set brief = 'Latina woman in her 40s with loose wavy hair, seated beside a winter window writing in a journal with one hand near a small candle; layered sweater, houseplant, and quiet posture convey inward reflection and hope.', updated_at = now() where ref = 'Hispanic Winter 01';
update items set brief = 'Hispanic young adult with curly hair seated at a table coloring a mandala-style page, wrapped in a soft blanket beside a warm lamp; books and a mug create a focused winter retreat for mindful self-expression.', updated_at = now() where ref = 'Hispanic Winter 03';

update items set hair = regexp_replace(hair, '\mdark\s+', '', 'gi'), updated_at = now()
 where hair ~* '\mdark\M';

-- No "dark" survives anywhere in a coloring-book prompt input.
do $$
declare n int;
begin
  select count(*) into n from items
   where category_id = (select id from categories where code = 'coloring-books')
     and (brief ~* '\mdark\M' or hair ~* '\mdark\M');
  if n > 0 then
    raise exception '% rows still carry "dark"', n;
  end if;
end $$;

-- The two composition uses of "white space" are untouched.
do $$
declare n int;
begin
  select count(*) into n from items
   where ref in ('Hispanic Summer 11', 'Hispanic Winter 12')
     and brief ilike '%white space%';
  if n <> 2 then
    raise exception 'white space was damaged: % of 2 intact', n;
  end if;
end $$;

-- The flagged rows are deliberately unchanged and should still be findable.
do $$
declare n int;
begin
  select count(*) into n from items
   where ref = 'Hispanic Summer 08' and brief ilike '%silver-streaked%';
  if n <> 1 then
    raise exception 'Summer 08 was changed; it was meant to be flagged, not fixed';
  end if;
end $$;

commit;

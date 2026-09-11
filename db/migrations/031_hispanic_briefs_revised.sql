-- 031_hispanic_briefs_revised.sql
--
-- The Hispanic line gets the briefs it should have had.
--
-- All 180 briefs came in at Stage A from the production tracker. The African
-- American rows were written at 44 characters on average -- "Woman in sweater
-- journaling with falling leaves outside." -- and the Hispanic rows matched
-- them in length and in kind. Esoh ran the workbook back through ChatGPT to
-- fill the Hispanic line out and brought the result back as
-- `Healing_Seasons_Hispanic_Line_Revised.xlsx`.
--
-- The revision is surgical and was verified before this file was written:
-- 180 rows in, 180 rows out, same seven columns, no rows added or removed,
-- the African American and Multiracial lines byte-identical, and exactly 60
-- rows changed in exactly one field -- `prompt notes`, which is `items.brief`.
-- The database was byte-identical to the pre-revision tracker for all 180
-- briefs, so nothing written here overwrites local editing.
--
-- Briefs go from a mean of 44 characters to 223. That is the point rather
-- than a side effect: D97 established that the setting is already answering
-- in `{{subject}}` rather than in the `{{environment}}` slot that asks for
-- it, and these briefs carry setting, posture and expression in the subject
-- line where the engine already reads them.
--
-- **What this migration deliberately does not do.** 18 of the 60 name hair --
-- "long wavy dark hair", "short textured dark hair", "a long braid". Hair is
-- item data under D45, and `items.hair` feeds a block carrying the technique
-- guarantee that hair is drawn as outlined sections with white inside, never
-- filled and never shaded. A hair phrase that lives only in the brief reaches
-- `{{subject}}` and leaves that guarantee dropped -- which is the filled-black
-- hair D45 exists to prevent. Extracting those 18 into `items.hair` is a
-- judgment call per row, not a regex, and is held for review rather than
-- guessed at here.
--
-- This does not close D104. The hair menu still offers 23 African American
-- styles and nothing else, and no ethnicity-aware block exists. Richer briefs
-- make the Hispanic line describable; they do not make it selectable.

begin;

update items set brief = 'Latina woman in her 30s with long wavy dark hair, seated at a sunlit table beside open curtains, writing in a recovery journal as potted spring flowers frame the scene; relaxed shoulders and a quietly hopeful expression convey new beginnings.', updated_at = now()
 where ref = 'Hispanic Spring 01';
update items set brief = 'Latino man in his 30s with short textured dark hair, walking a tree-lined neighborhood path just after sunrise, hands relaxed and gaze forward; fresh leaves and damp pavement reinforce steady progress and a clear new direction.', updated_at = now()
 where ref = 'Hispanic Spring 02';
update items set brief = 'Hispanic young adult with curly dark hair, seated cross-legged on a tiled patio practicing slow grounding breaths, one hand over the heart; potted herbs, small blossoms, and open sky create a calm scene of self-awareness.', updated_at = now()
 where ref = 'Hispanic Spring 03';
update items set brief = 'Latina woman in her 40s with shoulder-length curls, wrapped in a light woven throw while holding a warm cup of tea near a bright window; spring greenery and gentle posture communicate permission to rest without guilt.', updated_at = now()
 where ref = 'Hispanic Spring 04';
update items set brief = 'Four Hispanic adults in a welcoming community room seated in a loose circle, one woman speaking while others listen with open, supportive body language; spring flowers on a side table and uncluttered chairs create a safe sense of belonging.', updated_at = now()
 where ref = 'Hispanic Spring 05';
update items set brief = 'Hispanic mother and adult daughter kneeling together in a small garden, planting flowering seedlings and sharing a warm smile; practical gardening tools, tiled edging, and fresh growth symbolize nurturing a relationship and growing together.', updated_at = now()
 where ref = 'Hispanic Spring 06';
update items set brief = 'Hispanic family gathered around a breakfast table in a bright home, passing fruit and warm drinks while sharing easy conversation; patterned ceramic dishes, open curtains, and spring plants create a feeling of peaceful reconnection.', updated_at = now()
 where ref = 'Hispanic Spring 07';
update items set brief = 'Two Hispanic women seated outside after a wellness meeting, leaning toward one another in honest conversation; one holds a notebook while spring blossoms and a simple community building behind them suggest trust, reflection, and mutual encouragement.', updated_at = now()
 where ref = 'Hispanic Spring 08';
update items set brief = 'Elegant spring border built from open blossoms, curling vines, small hummingbirds, and a few unfurling leaves, leaving generous clean space in the center for the quote; airy composition symbolizes taking life one day at a time.', updated_at = now()
 where ref = 'Hispanic Spring 09';
update items set brief = 'Spring renewal border with two butterflies emerging from flowering stems, delicate new leaves, and scattered buds around generous central space; the upward movement of the butterflies visually reinforces growth with hope.', updated_at = now()
 where ref = 'Hispanic Spring 10';
update items set brief = 'Rain-kissed spring border featuring droplets on blossoms, curved stems, small leaves, and soft puddle ripples; keep the center open and peaceful so the quote feels like a quiet declaration of self-worth.', updated_at = now()
 where ref = 'Hispanic Spring 11';
update items set brief = 'Balanced spring symbol cluster of hummingbird, open flower, heart, sun, and unfurling leaf arranged as separate colorable motifs; each symbol represents life, connection, warmth, and renewal without visual clutter.', updated_at = now()
 where ref = 'Hispanic Spring 12';
update items set brief = 'Decorative spring journal composition with a closed notebook, ceramic cup, leafy stem, and subtle hand-painted-style tile border inspired by warm Hispanic home décor; keep motifs geometric and open for easy coloring.', updated_at = now()
 where ref = 'Hispanic Spring 13';
update items set brief = 'Peaceful Hispanic bedroom sanctuary with a neatly made bed, textured woven throw, leafy houseplants, small ceramic lamp, and journal on a bedside table; soft window light and orderly space communicate safety and restoration.', updated_at = now()
 where ref = 'Hispanic Spring 14';
update items set brief = 'Hispanic courtyard sanctuary with tiled floor, comfortable chair, potted citrus or flowering plant, simple woven textile, and an open gate toward the garden; inviting negative space makes the scene feel restorative and free.', updated_at = now()
 where ref = 'Hispanic Spring 15';
update items set brief = 'Latina woman in her 30s with shoulder-length curls, seated beneath a leafy summer tree with a sketchbook resting on her lap, relaxed posture and a gentle smile; dappled sunlight, wildflowers, and open sky express creative freedom and renewed joy.', updated_at = now()
 where ref = 'Hispanic Summer 01';
update items set brief = 'Latino man in his 30s with short curly dark hair, walking slowly along a waterfront boardwalk with sleeves rolled up and relaxed hands; bright water, palms or riverside trees, and a wide horizon create a visual sense of forward movement.', updated_at = now()
 where ref = 'Hispanic Summer 02';
update items set brief = 'Hispanic young adult with thick curly hair stretching beside a backyard garden in early morning, arms reaching overhead and face lifted toward the sun; potted herbs, flowering plants, and a simple chair support a feeling of energy and self-care.', updated_at = now()
 where ref = 'Hispanic Summer 03';
update items set brief = 'Latina woman in her 40s with long braid and simple summer clothing, seated on a shaded porch swing holding a cool drink, laughing softly with eyes closed; flowering pots and gentle breeze lines make joy feel safe and unforced.', updated_at = now()
 where ref = 'Hispanic Summer 04';
update items set brief = 'Five Hispanic adults gathered outdoors beneath a broad shade tree, seated in a loose support circle with one person speaking and others listening attentively; notebooks and water bottles ground the scene in peer support, trust, and community.', updated_at = now()
 where ref = 'Hispanic Summer 05';
update items set brief = 'Hispanic family sharing a relaxed backyard cookout, adults and older children preparing food and talking around a simple table; woven placemats, fresh fruit, flowering plants, and open body language emphasize reconnection rather than celebration for its own sake.', updated_at = now()
 where ref = 'Hispanic Summer 06';
update items set brief = 'Two Hispanic friends seated at a shaded outdoor table, sharing tall glasses of aguas frescas and talking with genuine smiles; citrus slices, flowering plants, and relaxed posture create a scene of friendship, presence, and everyday joy.', updated_at = now()
 where ref = 'Hispanic Summer 07';
update items set brief = 'Older Hispanic woman with silver-streaked hair offering calm encouragement to a younger adult seated beside her on a garden bench; their eye contact and open hands convey wisdom, trust, and support across generations.', updated_at = now()
 where ref = 'Hispanic Summer 08';
update items set brief = 'Summer border of radiant sun rays, open flowers, curved leaves, small fruit, and butterflies surrounding generous central space; upward, flowing shapes visually connect healing with genuine joy.', updated_at = now()
 where ref = 'Hispanic Summer 09';
update items set brief = 'Bold summer sunburst border with long clean rays, small wildflowers, open leaves, and a distant horizon line; keep the center spacious so the short affirmation reads as a confident step forward.', updated_at = now()
 where ref = 'Hispanic Summer 10';
update items set brief = 'Open-sky summer composition with a simple horizon, drifting clouds, flowering stems, and a calm butterfly near the lower corner; abundant white space creates a visual pause and reinforces choosing calm.', updated_at = now()
 where ref = 'Hispanic Summer 11';
update items set brief = 'Summer symbol cluster featuring a radiant sun, hibiscus-like flower, sliced citrus, leafy stem, butterfly, and heart; arrange each motif distinctly with clean outlines and balanced spacing for an uplifting coloring page.', updated_at = now()
 where ref = 'Hispanic Summer 12';
update items set brief = 'Summer picnic vignette with woven basket, fruit, folded textile, lemonade-style glass, wildflowers, and a small journal arranged on a blanket; use open shapes and flowing border elements to suggest relaxed connection.', updated_at = now()
 where ref = 'Hispanic Summer 13';
update items set brief = 'Hispanic patio sanctuary with patterned tile floor, comfortable chair, potted flowering plants, hanging lanterns, and a small side table with a journal; the open doorway and uncluttered layout suggest safety and personal freedom.', updated_at = now()
 where ref = 'Hispanic Summer 14';
update items set brief = 'Community-center courtyard with several Hispanic adults gathered around small tables and potted plants, sharing conversation after a wellness activity; tiled walkway, shade canopy, and welcoming open space create a grounded community setting.', updated_at = now()
 where ref = 'Hispanic Summer 15';
update items set brief = 'Latina woman in her 40s with thick wavy dark hair wrapped in a textured shawl, seated beside a fall-lit window writing in a journal; a warm mug, leafy plant, and thoughtful gaze convey reflection and emotional release.', updated_at = now()
 where ref = 'Hispanic Fall 01';
update items set brief = 'Latino man in his 40s with short textured hair and neatly trimmed facial hair, walking beneath mature autumn trees with a warm coffee cup; fallen leaves and a steady stride symbolize moving forward while carrying less.', updated_at = now()
 where ref = 'Hispanic Fall 02';
update items set brief = 'Hispanic young adult with curly hair seated in a deep chair, reading a small affirmation card with a peaceful half-smile; woven throw, ceramic mug, houseplant, and amber window light create a cozy space for self-encouragement.', updated_at = now()
 where ref = 'Hispanic Fall 03';
update items set brief = 'Latina woman in her 40s with long dark braid preparing herbal tea in a tidy kitchen, hands relaxed and expression content; warm wood, ceramic dishes, leafy plant, and autumn light turn an ordinary routine into intentional self-care.', updated_at = now()
 where ref = 'Hispanic Fall 04';
update items set brief = 'Five Hispanic adults in a warm indoor support circle, seated comfortably with notebooks and mugs while one person speaks and the others listen; simple autumn branches, woven textiles, and soft lamps create belonging without clutter.', updated_at = now()
 where ref = 'Hispanic Fall 05';
update items set brief = 'Hispanic family preparing a comforting meal together in a home kitchen, with an adult stirring a pot while another chops vegetables and others set the table; warm ceramic dishes and shared eye contact emphasize teamwork and reconnection.', updated_at = now()
 where ref = 'Hispanic Fall 06';
update items set brief = 'Two Hispanic sisters seated across a kitchen table, speaking honestly with relaxed shoulders and attentive eye contact; mugs, a small vase of autumn flowers, and an open notebook create an intimate scene of trust and truth.', updated_at = now()
 where ref = 'Hispanic Fall 07';
update items set brief = 'Hispanic mentor and younger adult seated on a park bench after a class, talking with calm focus; the mentor listens while the younger adult holds a notebook, surrounded by autumn trees and a clear walking path representing continued growth.', updated_at = now()
 where ref = 'Hispanic Fall 08';
update items set brief = 'Autumn border with a steaming cup, curling leaves, acorns, simple woven-texture motifs, and generous central space; falling leaves move downward while the open center creates a visual permission to pause and rest.', updated_at = now()
 where ref = 'Hispanic Fall 09';
update items set brief = 'Release-and-renewal border featuring leaves drifting from branches, an open hand motif, new buds, and a butterfly transitioning upward; keep the center spacious to visually separate letting go from becoming.', updated_at = now()
 where ref = 'Hispanic Fall 10';
update items set brief = 'Autumn window-light composition with a narrow branch, glowing sunbeams, a small candle, and leaves framing a large open center; the light should visually enter from one side to symbolize hope that remains.', updated_at = now()
 where ref = 'Hispanic Fall 11';
update items set brief = 'Fall symbol cluster of layered leaves, ceramic mug, candle, flower, small acorn, and open journal arranged in a balanced arc; use distinct shapes and generous spacing for easy coloring.', updated_at = now()
 where ref = 'Hispanic Fall 12';
update items set brief = 'Decorative fall composition using woven textile geometry, leaf garland, ceramic cup, simple botanical motifs, and a subtle Hispanic-inspired tile pattern; keep patterns structured, spacious, and non-stereotyped.', updated_at = now()
 where ref = 'Hispanic Fall 13';
update items set brief = 'Cozy Hispanic reading corner with an upholstered chair, layered woven blanket, floor lamp, houseplants, stacked books, and a small side table; autumn light through the window creates a protected retreat for reflection.', updated_at = now()
 where ref = 'Hispanic Fall 14';
update items set brief = 'Warm Hispanic dining-room sanctuary with a wooden table, simple ceramic place settings, woven runner, potted plant, candle, and soft window light; orderly surfaces and open pathways communicate peace, stability, and home.', updated_at = now()
 where ref = 'Hispanic Fall 15';
update items set brief = 'Latina woman in her 40s with loose wavy dark hair, seated beside a winter window writing in a journal with one hand near a small candle; layered sweater, houseplant, and quiet posture convey inward reflection and hope.', updated_at = now()
 where ref = 'Hispanic Winter 01';
update items set brief = 'Latino man in his 30s with short curly hair, bundled in a textured coat and scarf on a quiet winter morning walk; bare trees, light frost, and a clear path frame his steady stride and sense of purpose.', updated_at = now()
 where ref = 'Hispanic Winter 02';
update items set brief = 'Hispanic young adult with curly dark hair seated at a table coloring a mandala-style page, wrapped in a soft blanket beside a warm lamp; books and a mug create a focused winter retreat for mindful self-expression.', updated_at = now()
 where ref = 'Hispanic Winter 03';
update items set brief = 'Latina woman in her 40s with a long braid seated comfortably near a window, holding cocoa while gentle music plays from a small speaker; candlelight, folded textile, and relaxed shoulders make the scene feel tender and restorative.', updated_at = now()
 where ref = 'Hispanic Winter 04';
update items set brief = 'Five Hispanic adults gathered indoors in a welcoming support room, seated in a comfortable circle with notebooks and warm drinks; simple winter textiles, a small plant, and soft lamps create safety, connection, and attentive listening.', updated_at = now()
 where ref = 'Hispanic Winter 05';
update items set brief = 'Hispanic parent and adult child seated together on a living-room sofa, leaning toward one another during a calm healing conversation; mugs on a low table, family photos, and a woven throw create warmth without implying conflict.', updated_at = now()
 where ref = 'Hispanic Winter 06';
update items set brief = 'Three Hispanic friends gathered in a cozy living room during winter, checking in with one another over warm drinks; relaxed smiles, open posture, blankets, and a softly lit window make care and friendship the visual focus.', updated_at = now()
 where ref = 'Hispanic Winter 07';
update items set brief = 'Hispanic family enjoying a quiet winter game night around a dining table, adults and younger family members laughing and reaching for game pieces; warm drinks, simple snacks, and layered textiles emphasize safe connection and shared joy.', updated_at = now()
 where ref = 'Hispanic Winter 08';
update items set brief = 'Winter border with a glowing candle, small stars, evergreen sprigs, delicate snowflakes, and an upward trail of light around generous central space; the composition should feel hopeful rather than cold.', updated_at = now()
 where ref = 'Hispanic Winter 09';
update items set brief = 'Tender winter border built from a candle flame, folded woven textile, small flowers, stars, and gentle curved lines; keep the center open and soft, visually reinforcing the right to receive care and tenderness.', updated_at = now()
 where ref = 'Hispanic Winter 10';
update items set brief = 'Minimal winter composition with a winding path, small snowflakes, tiny footprints, evergreen sprigs, and a rising sun near the horizon; generous open space emphasizes steady progress one step at a time.', updated_at = now()
 where ref = 'Hispanic Winter 11';
update items set brief = 'Winter symbol cluster of stars, candle, knitted mitten, heart, evergreen sprig, mug, and small snowflake arranged in a balanced circle; use clean separate motifs with plenty of white space.', updated_at = now()
 where ref = 'Hispanic Winter 12';
update items set brief = 'Decorative winter arrangement featuring folded woven blankets, ceramic mugs, lantern, evergreen branches, simple geometric textile patterns, and snowflake accents; structured shapes keep the page warm, elegant, and easy to color.', updated_at = now()
 where ref = 'Hispanic Winter 13';
update items set brief = 'Cozy Hispanic bedroom retreat with layered woven blankets, upholstered chair, bedside lamp, books, small candle, and a potted plant near the window; the room is orderly, quiet, and intentionally designed as a safe place to recharge.', updated_at = now()
 where ref = 'Hispanic Winter 14';
update items set brief = 'Peaceful Hispanic living room with a comfortable sofa, books, warm mugs, woven throw, houseplants, floor lamp, and winter view through the window; balanced furniture and open floor space create a grounded sanctuary for reflection.', updated_at = now()
 where ref = 'Hispanic Winter 15';

-- Every Hispanic row carries a brief, and all 60 are the revised long form.
do $$
declare n int;
begin
  select count(*) into n from items
   where ethnicity_line = 'Hispanic' and length(brief) < 100;
  if n > 0 then
    raise exception 'Hispanic briefs not fully applied: % rows still short', n;
  end if;
end $$;

commit;

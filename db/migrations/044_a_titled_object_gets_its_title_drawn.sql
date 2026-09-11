-- 044_a_titled_object_gets_its_title_drawn.sql
--
-- D120 found this by accident and it is a sibling of D105. Two pages generated
-- twice each under identical blocks:
--
--   `African American Summer 01`  brief says "a recovery journal open on her
--   knees"  →  the model wrote **"Recovery Journal"** on the cover. Twice.
--   Once as `RECOVERY JOURHAL`, misspelled, baked into the artwork.
--
--   `African American Fall 01`  brief says "writing in a journal"
--   →  blank cover. Twice.
--
-- Same template, same blocks, same run. **An abstract noun placed directly
-- against a writing surface reads as the title printed on it.** 043 added a
-- rule to `hs-output` — "surfaces that could carry writing are drawn blank" —
-- and it did not survive contact with the subject line, exactly as D118 found
-- for the window: a block describes the rules, a brief describes the page, and
-- the page wins.
--
-- This is the D105 shape. There the word named a colour the page could not
-- hold and came back as fill; here the word names a title and comes back as
-- lettering. Both are a brief asking for something the medium renders
-- literally.
--
-- THE MEANING IS THE POINT AND IS KEPT. "Recovery", "prayer", "gratitude" and
-- "affirmation" are the African American line's own register, protected
-- deliberately in D115. Stripping them would flatten the thing that makes that
-- line specific. So each phrase is reworded rather than removed: the abstract
-- noun stays in the sentence and stops sitting against the object.
--
-- TWO HISPANIC ROWS ARE CHANGED, WHICH D115 DECLINED TO DO. That decision left
-- Esoh's 031 text alone where the risk was a guess. This is not a guess — it is
-- a measured 2-of-2 failure with a mechanism — and the alternative is shipping
-- a page with a misspelt title printed on it. The wording of the direction is
-- untouched; only the noun phrase is loosened.

begin;

create temporary table retitle (ref text primary key, old_phrase text, new_brief text) on commit drop;

insert into retitle (ref, old_phrase, new_brief) values
('African American Fall 04', 'gratitude notebook',
 'African American woman in her 50s with locs gathered back in a low wrap, '
 'leaning to light a candle at a side table where an open notebook lies, the '
 'one she keeps for gratitude, one hand steadying the table edge.'),
('African American Spring 04', 'affirmation cards',
 'African American woman in her 40s with a silk press turned under at the ends, '
 'sitting wrapped to the chin in a quilted blanket with a cup of tea held in '
 'both hands and a stack of small cards fanned on the table, their faces plain, '
 'each one an affirmation she reads in the morning.'),
('African American Summer 01', 'recovery journal',
 'African American woman in her 30s with knotless braids gathered over one '
 'shoulder, sitting against the trunk of a broad tree with an open journal on '
 'her knees, the one she keeps through recovery, and a pen held still; roots '
 'breaking the grass around her.'),
('African American Winter 01', 'prayer journal',
 'African American woman in her 30s with two-strand twists pinned up, sitting at '
 'a table beside a framed window with snow falling past the panes, an open '
 'journal in front of her and both hands folded on it in prayer.'),
('African American Fall 08', 'meeting schedule',
 'An African American sponsor and sponsee talking on a park bench, the older man '
 'in his 50s with a short tapered afro and a close-trimmed beard, the younger '
 'man with cornrows; both leaning forward with their forearms on their knees and '
 'a folded sheet of paper from the meeting in one hand.'),
('African American Spring 05', 'flip chart',
 'A small recovery circle of seven African American adults on folding chairs in '
 'a community room — cornrows, faux locs, a shaved head, a headwrap and sponge '
 'curls among them — one man mid-sentence and a woman beside him nodding; a '
 'table of cups and a large paper pad on a stand at the side.'),
('African American Spring 15', 'noticeboard',
 'A church fellowship hall set up before anyone arrives: a ring of folding '
 'chairs, a long table with a coffee urn, stacked cups and a covered plate, an '
 'upright piano against the wall, high windows and a board with papers pinned to '
 'it — all drawn as separate outlined shapes.'),
('African American Summer 15', 'row marker',
 'A community garden between visits: raised beds thick with growth, staked '
 'tomatoes and climbing beans, a wheelbarrow, tools leaning on a shed, a hose '
 'coiled by a standpipe and a wooden stake pushed into the soil — the planting '
 'fills the page, each bed clearly outlined.'),
('Multiracial Spring 05', 'flip chart',
 'A support circle of seven adults of mixed heritage in a community room — box '
 'braids, a curly bob, locs, a shaved head and straight hair among them — seated '
 'on folding chairs with one man mid-sentence and a woman beside him nodding; a '
 'large paper pad on a stand and a table of cups at the side.'),
('Multiracial Spring 10', 'seed packet',
 'A loose hand-drawn border of cupped hands at the lower edge holding soil and a '
 'seedling, with a trowel, a small paper envelope of seeds, small sprigs and '
 'looping stems scattered around the margin, drawn slightly irregular as if with '
 'a marker; the middle left empty.'),
('Hispanic Fall 03', 'affirmation card',
 'Hispanic young adult with curly hair seated in a deep chair, reading from a '
 'small plain card with a peaceful half-smile, the words on it an affirmation '
 'for the day; woven throw, ceramic mug, houseplant, and amber window light '
 'create a cozy space for self-encouragement.'),
('Hispanic Spring 01', 'recovery journal',
 'Latina woman in her 30s with long wavy hair, seated at a sunlit table beside '
 'open curtains, writing in an open journal she keeps through recovery, as '
 'potted spring flowers frame the scene; relaxed shoulders and a quietly hopeful '
 'expression convey new beginnings.');

update items i set brief = r.new_brief, updated_at = now()
  from retitle r where i.ref = r.ref and i.ethnicity_line is not null;

-- All twelve landed.
do $$
declare n int;
begin
  select count(*) into n from items i join retitle r on r.ref = i.ref
   where i.updated_at > now() - interval '1 minute';
  if n <> 12 then raise exception 'expected 12 rows updated, got %', n; end if;
end $$;

-- No brief in the library still puts one of these abstract nouns directly
-- against a writing surface. This is the shape that printed a title.
do $$
declare bad text;
begin
  select string_agg(ref, ', ') into bad from items
   where ethnicity_line is not null
     and brief ~* '\y(recovery|prayer|gratitude|affirmation|meeting|seed|row)\s+(journal|notebook|card|cards|packet|marker|schedule|chart)s?\y';
  if bad is not null then raise exception 'titled object still present: %', bad; end if;
end $$;

-- The meaning survives. Each abstract noun is still somewhere in its brief.
do $$
declare bad text := '';
begin
  if not exists (select 1 from items where ref='African American Fall 04'   and brief ~* 'gratitude')   then bad := bad||'Fall 04 gratitude; '; end if;
  if not exists (select 1 from items where ref='African American Spring 04' and brief ~* 'affirmation') then bad := bad||'Spring 04 affirmation; '; end if;
  if not exists (select 1 from items where ref='African American Summer 01' and brief ~* 'recovery')    then bad := bad||'Summer 01 recovery; '; end if;
  if not exists (select 1 from items where ref='African American Winter 01' and brief ~* 'prayer')      then bad := bad||'Winter 01 prayer; '; end if;
  if not exists (select 1 from items where ref='African American Spring 05' and brief ~* 'recovery')    then bad := bad||'Spring 05 recovery; '; end if;
  if not exists (select 1 from items where ref='Hispanic Fall 03'           and brief ~* 'affirmation') then bad := bad||'H Fall 03 affirmation; '; end if;
  if not exists (select 1 from items where ref='Hispanic Spring 01'         and brief ~* 'recovery')    then bad := bad||'H Spring 01 recovery; '; end if;
  if bad <> '' then raise exception 'meaning lost: %', bad; end if;
end $$;

-- Nothing collapsed to a sketch, and D105 still holds.
do $$
declare bad text;
begin
  select string_agg(i.ref || ' (' || length(i.brief) || ')', ', ') into bad
    from items i join retitle r on r.ref = i.ref where length(i.brief) < 150;
  if bad is not null then raise exception 'brief too thin after rewrite: %', bad; end if;

  select string_agg(i.ref, ', ') into bad from items i join retitle r on r.ref = i.ref
   where i.brief ~* '\y(dark|black|white|brown|red|blue|green|golden|silver|grey|gray|blonde|olive|tan|fair|pale)\y';
  if bad is not null then raise exception 'colour word introduced: %', bad; end if;
end $$;

commit;

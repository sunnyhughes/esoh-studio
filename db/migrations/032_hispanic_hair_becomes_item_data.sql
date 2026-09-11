-- 032_hispanic_hair_becomes_item_data.sql
--
-- The Hispanic line's hair moves out of the brief and into the field that
-- carries the technique guarantee.
--
-- 031 brought in the revised Hispanic briefs, and 16 of them name hair --
-- "thick wavy dark hair", "short textured dark hair", "a long braid". Left
-- there, those phrases reach `{{subject}}` and nothing else. `items.hair` is
-- what fires the hair block (D45), and the hair block is where the rule lives:
-- hair is drawn as outlined sections with white inside them, never filled in
-- and never shaded. A page whose hair is described only in the subject line
-- gets the description without the rule, and comes back with hair filled solid
-- black -- the exact failure D45 was written to prevent, observed again on
-- 2026-09-10 in the with-environment arm of the D97 test.
--
-- Extracted by hand, not by pattern. A regex over the same 60 rows returned
-- "curly hair seated in a deep chair" and "an upholstered chair" among its
-- matches, which is why it was not trusted.
--
-- **Solo portraits only.** All 16 Hispanic Solo portraits name hair and all 16
-- are set here. The 16 Community scenes are left null on purpose: a group of
-- four to five people cannot be described by one hair value, and Summer 08's
-- "silver-streaked hair" belongs to one figure of two. Filling it would state
-- a single style for everyone in the room.
--
-- The brief keeps its hair phrase (Esoh's call, 2026-09-10). The database brief
-- stays a faithful copy of the workbook so a future re-import does not diverge,
-- and the repetition reinforces the hair rather than contradicting it.
--
-- Still does not close D104. These 16 rows are now describable because their
-- briefs happen to name hair. The `hair` menu on the form still offers 23
-- African American styles and nothing else, so a Hispanic or Multiracial page
-- composed by hand still has nothing to pick, and the Multiracial line's 60
-- briefs name no hair at all.

begin;

update items set hair = 'long wavy dark hair',      updated_at = now() where ref = 'Hispanic Spring 01';
update items set hair = 'short textured dark hair', updated_at = now() where ref = 'Hispanic Spring 02';
update items set hair = 'curly dark hair',          updated_at = now() where ref = 'Hispanic Spring 03';
update items set hair = 'shoulder-length curls',    updated_at = now() where ref = 'Hispanic Spring 04';

update items set hair = 'shoulder-length curls',    updated_at = now() where ref = 'Hispanic Summer 01';
update items set hair = 'short curly dark hair',    updated_at = now() where ref = 'Hispanic Summer 02';
update items set hair = 'thick curly hair',         updated_at = now() where ref = 'Hispanic Summer 03';
update items set hair = 'a long braid',             updated_at = now() where ref = 'Hispanic Summer 04';

update items set hair = 'thick wavy dark hair',     updated_at = now() where ref = 'Hispanic Fall 01';
update items set hair = 'short textured hair',
                 facial_hair = 'a neatly trimmed short beard',
                 updated_at = now() where ref = 'Hispanic Fall 02';
update items set hair = 'curly hair',               updated_at = now() where ref = 'Hispanic Fall 03';
update items set hair = 'a long dark braid',        updated_at = now() where ref = 'Hispanic Fall 04';

update items set hair = 'loose wavy dark hair',     updated_at = now() where ref = 'Hispanic Winter 01';
update items set hair = 'short curly hair',         updated_at = now() where ref = 'Hispanic Winter 02';
update items set hair = 'curly dark hair',          updated_at = now() where ref = 'Hispanic Winter 03';
update items set hair = 'a long braid',             updated_at = now() where ref = 'Hispanic Winter 04';

-- Every Hispanic Solo portrait has hair; no Community scene does.
do $$
declare missing int; group_rows int;
begin
  select count(*) into missing from items
   where ethnicity_line = 'Hispanic' and page_type = 'Solo portrait' and hair is null;
  if missing > 0 then
    raise exception 'Hispanic Solo portraits still missing hair: %', missing;
  end if;

  select count(*) into group_rows from items
   where ethnicity_line = 'Hispanic' and page_type = 'Community scene' and hair is not null;
  if group_rows > 0 then
    raise exception 'Community scenes must not carry one hair value: % rows', group_rows;
  end if;
end $$;

commit;

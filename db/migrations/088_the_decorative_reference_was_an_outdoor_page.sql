-- 088_the_decorative_reference_was_an_outdoor_page.sql
--
-- D137 counted Decorative page at one usable reference and treated that as the
-- thinnest of the six. The count was right and the reading was wrong: the one
-- reference is not a Decorative page at all.
--
-- **TPL-10 Decorative Border & Pattern, verbatim from 058:**
--
--   "Seasonal border or repeating pattern frame with 4-8 comfort objects set
--    inside it; flatter and more graphic than a symbol cluster. Full-page
--    border or corner frames; Center: object grouping; Background: restrained
--    repeating pattern or open white."
--
-- `decorative-garden-gate` is a wrought-iron gate standing open on a path that
-- recedes to a fountain, with a bench, a planted border and a stone wall behind
-- it. There is no border frame in it and no object grouping. It is a place,
-- built in three depth planes, and "flatter and more graphic" is the clause it
-- contradicts most directly. What it actually matches is **TPL-09 Outdoor
-- Sanctuary** — "a strong built anchor (patio, courtyard, balcony, garden bed)
-- plus plants and seating ... Lower: paving, path, pots, ground plants" — which
-- is a list of what the page contains, item for item.
--
-- 073 registered it and praised it in these words: "Three depth planes and
-- ornament with structure, which is what the tool's decorative pages have been
-- missing." The virtue was real and it was filed under the wrong page type.
-- Depth planes are what an Environment page is graded on; a Decorative page is
-- graded on being flat.
--
-- **Every Decorative page generated since 2026-09-14 has been shown it.**
-- `lib/generate.ts` prefers an exact page-type match and bars the cross-type
-- fallback for pages with no figures (D122), so the Decorative selection is
-- this one row and nothing else. This is not offered as the cause of 081's
-- floating objects or 082's porch — 082's job was run ad hoc with no item, so
-- D56's guard never fired and no reference was selected — but it is the same
-- fault in the same place, and the two migrations that fought over the centre
-- object grouping were fighting for a composition no reference has ever shown.
--
-- **Esoh's call, 2026-09-21: re-type it to Environment page.** It is a good
-- outdoor reference and Environment had only one — 087 called `pergola-patio`
-- "the first outdoor reference this page type has had", and this was sitting
-- one row away, mislabelled, the whole time. Environment goes to 4, the count
-- D130 fixed for Solo portrait and the limit the selection query takes.
--
-- **This deliberately breaks the invariant 087 asserted.** That migration ended
-- by proving all six page types had at least one usable reference, "the count
-- 076 established for the first time in the project's history". Decorative now
-- has none, and that is the honest number rather than a regression: it had none
-- before this migration too, and one page pointing the wrong way. D119 and D131
-- both found page types with no exemplar coming back fine; D137 found the
-- opposite. The evidence is genuinely split and the gap is now named correctly,
-- which is what makes it sourceable.
--
-- ---
--
-- **The four `Ornate Seasonal Heritage Mandala` files are not Decorative pages
-- either.** They arrived 2026-09-14 22:34, in the middle of the symbol push,
-- and were passed over then without a reason being written down. They are a set
-- of four season/line title cards — Fall/Hispanic, Spring/African American,
-- Summer/Black-Multiracial, Winter/Other Ethnicities — each an ornate botanical
-- frame around a lettered centre carrying a season, a line and four theme
-- words.
--
-- Not registrable as usable, on four counts:
--
--   1. **All four carry drawn lettering**, which is 071's fault and the reason
--      073 blanked four references before registering them.
--   2. **Mandala2 has a cropped person's afro** rendered as a near-solid mass:
--      61.9% black at **2px openrun**. 087 defended the heritage butterfly at
--      29.9% / 7px as a black field with colourable cells knocked out of it.
--      This is twice the ink at a quarter of the gap — a solid by D110's own
--      triple, on the one subject D44, D104 and D105 have all been spent on.
--   3. **Mandala3 has a full face** in profile, with tonal shading on the cheek
--      and jaw: D47 and `hs-no-figures` together.
--   4. Two of them name lines this project does not have — "BLACK /
--      MULTIRACIAL" and "OTHER ETHNICITIES" appear nowhere in the workbook.
--
-- **Blanking would not save the two clean ones.** Mandala1 and Mandala4 have no
-- people and 073's procedure would lift their lettering cleanly. What remains
-- is an ornate border around an open centre, which is the **Quote page**
-- composition — §4 gives Quote "rendered lettering plus decorative border" and
-- Decorative "pattern and object arrangement". Registering them would teach a
-- Decorative page to leave an oval waiting for a quote, and would teach nothing
-- about the centre object grouping, which is the single thing TPL-10 most needs
-- shown. §6's law cuts both ways: an exemplar transfers its composition as
-- surely as its faults.
--
-- Esoh's call: **register Mandala1 and Mandala4 as studies**, 073's precedent
-- for `quote-arch-and-hands` — kept in the library to look at, never sent to
-- the model. They are good ornamental border work and the next Decorative or
-- Quote sourcing round should start by looking at them. Mandala2 and Mandala3
-- get no row; their measurements are recorded above so the next pass does not
-- have to re-derive why.
--
-- `page_type` is left **null** on both, because a title card is not one of the
-- six. Null plus `usable_as_input = false` is inert — the selection query filters
-- on usable first — but null plus usable would be a general style plate applying
-- to every page in the library, so the guard below pins them to false by name.
--
-- **Not available, and worth stating so it is not proposed again:** p4 of the
-- scanned set (the Zentangle cat on a sunburst) is the one unambiguous
-- decorative page on this machine, and D31 bars the watermarked scans from ever
-- being sent to the model as image input. Decorative needs new material, not a
-- better search of the old.

begin;

-- The file is renamed alongside this, so the path stops saying "decorative".
-- storage/exemplars is outside git's reach (`/storage` is ignored and the
-- `!/storage/exemplars` negations below it cannot re-include a directory git
-- never descends into), so this row is the only durable record of either name.
update reference_images
   set storage_path = 'exemplars/environment-garden-gate.png',
       label        = 'Environment page — garden gate',
       page_type    = 'Environment page',
       notes        = 'Sourced by Esoh 2026-09-14, registered by 073 as the '
                      'Decorative page reference and re-typed by 088. A gate '
                      'standing open on a path receding to a fountain, with a '
                      'bench, a planted border and a stone wall behind: three '
                      'depth planes, which is what an Environment page is '
                      'graded on and the opposite of TPL-10''s "flatter and '
                      'more graphic". Outdoor, so it serves TPL-09 Outdoor '
                      'Sanctuary, whose zone list it matches item for item. '
                      '18.1% black at 5px open run. Was file '
                      'decorative-garden-gate.png until 2026-09-21.',
       updated_at   = now()
 where storage_path = 'exemplars/decorative-garden-gate.png';

insert into reference_images
  (item_id, asset_id, label, storage_path, kind, page_type, art_style,
   usable_as_input, notes)
values
  (null, null, 'Study — season title card, Fall / Hispanic',
   'exemplars/study-title-card-fall-hispanic.png', 'study', null, null, false,
   'Sourced by Esoh 2026-09-14 as "Ornate Seasonal Heritage Mandala1", '
   'unexamined until 088. A season/line title card, not a page type: a layered '
   'botanical frame at three scales around a centre carrying FALL, HISPANIC, a '
   'sun rosette medallion and STRENGTH COURAGE FAMILY TRADITION, with a '
   'roundel band along the foot and a church-and-mountain vignette at the top. '
   'No people. 17.4% black, 106.1 cross/1k, 9px open run. Study and not an '
   'exemplar because the lettering is 071''s fault and because blanking it '
   'leaves the Quote page composition — an ornate border around an open '
   'centre — on the page type that most needs a grouped object cluster shown. '
   'Good border work; start here when Decorative or Quote is sourced again.'),
  (null, null, 'Study — season title card, Winter',
   'exemplars/study-title-card-winter.png', 'study', null, null, false,
   'Sourced by Esoh 2026-09-14 as "Ornate Seasonal Heritage Mandala4", '
   'unexamined until 088. The same title-card set: conifer, pinecone and '
   'hellebore frame around WINTER, OTHER ETHNICITIES, a snowflake medallion '
   'and REFLECTION INNER PEACE RENEWAL HOPE, with mountain and tree roundels '
   'along the foot. No people. The densest and tightest of the four at 22.3% '
   'black, 128.6 cross/1k, 5px open run — the same open run as the garden '
   'gate. "OTHER ETHNICITIES" is not one of this project''s three lines, which '
   'is part of why the set reads as exploratory rather than as source '
   'material. Study for the same reason as the Fall card.');

do $$
declare n int;
begin
  select count(*) into n from reference_images
   where usable_as_input and page_type = 'Environment page';
  if n <> 4 then raise exception 'expected 4 environment refs, got %', n; end if;

  -- Stated rather than assumed: Decorative has none, and 087's all-six
  -- invariant is broken on purpose. If a later migration restores it, it should
  -- do so with a page that has a border frame and a grouped centre.
  select count(*) into n from reference_images
   where usable_as_input and page_type = 'Decorative page';
  if n <> 0 then raise exception 'expected 0 decorative refs, got %', n; end if;

  -- The old path must be gone, not duplicated. 073 inserted one row for it and
  -- this migration updates that row; two rows would mean the gate is both types.
  if exists (select 1 from reference_images
              where storage_path = 'exemplars/decorative-garden-gate.png') then
    raise exception 'the old decorative path is still registered';
  end if;

  select count(*) into n from reference_images
   where storage_path like '%garden-gate%';
  if n <> 1 then raise exception 'expected 1 garden gate row, got %', n; end if;

  -- A null page_type that is usable is a general style plate applying to every
  -- page in the library. Neither title card may become one by accident.
  if exists (select 1 from reference_images
              where storage_path like 'exemplars/study-title-card-%'
                and usable_as_input) then
    raise exception 'a title card was registered as usable input';
  end if;
end $$;

commit;

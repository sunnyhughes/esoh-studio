-- 068_the_export_checklist_gets_measured.sql
--
-- Step 6. `page_design_system` ends with a six-item export checklist and a line
-- system quoted in points. Three of the six are mechanical; `lib/page-check.ts`
-- does those and says plainly that the other three need a person.
--
-- **Two findings came out of building it, and both matter more than the code.**
--
-- **The print sheet has no top or bottom margin.** `placeOnPaper` defaults
-- `marginIn` to 0, so a 2:3 page scaled into 8.5x11 fills the full height and
-- is inset only 175px each side. The spec says 0.375in minimum on *all* sides.
-- D24's assumption was that the art carries its own margin — `hs-output` does
-- ask for key subject matter to stay clear of the edge — but measured on real
-- pages, between 2% and 10% of the ink lands inside the safe band. Reported per
-- page rather than fixed here, because changing the print geometry is a
-- decision about every page already approved, not a migration.
--
-- **Line weight cannot be measured and is not pretended.** 0.5pt at 300 DPI is
-- 2.08px; the page is a 1024-wide raster resampled to 2200, so every approved
-- exemplar reads 30-43% "hairline" purely from interpolation. A gate on that
-- fails all of them. D110's warning is the reason this is written down instead
-- of shipped: a metric that cannot see what it claims to is worse than none.
--
-- **The grey-fill threshold was set twice, and the first one was wrong.** Eight
-- pages suggested 6%. Measured across all 105, that line flags four pages Esoh
-- approved, which is D111 and D126 repeating — the model asserting failure on
-- work Esoh judged fine. The full distribution has approved and rejected pages
-- overlapping in every band up to 10%, and above 12% there are two pages, both
-- rejected, at 47% and 50%. So `ok: false` now means only "no page Esoh has ever
-- kept looks like this". The number is recorded on every page regardless:
-- rejected work averages 3.78% against approved work's 1.88%, which is signal
-- for watching a season drift, not for judging one page.
--
-- No schema change. The report lands in `generated_assets.metadata_json` beside
-- the transparency report it is modelled on, and `scripts/backfill-page-check.mjs`
-- has measured all 105 existing coloring pages so the history exists.

begin;

do $$
declare n int; flagged int;
begin
  select count(*) into n from generated_assets g
    join categories c on c.id = g.category_id
   where c.code = 'coloring-books' and g.purged_at is null
     and (g.metadata_json -> 'pageCheck') is null;
  if n <> 0 then
    raise exception '% coloring pages were never measured — run scripts/backfill-page-check.mjs', n;
  end if;

  -- The threshold must not contradict Esoh. Nothing approved may be flagged.
  select count(*) into flagged from generated_assets g
    join categories c on c.id = g.category_id
   where c.code = 'coloring-books' and g.status = 'approved'
     and (g.metadata_json -> 'pageCheck' ->> 'ok') = 'false';
  if flagged <> 0 then
    raise exception 'the grey-fill line flags % approved pages', flagged;
  end if;
end $$;

commit;

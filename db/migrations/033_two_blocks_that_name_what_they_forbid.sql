-- 033_two_blocks_that_name_what_they_forbid.sql
--
-- Two blocks are corrected. They are different failures with the same root:
-- each one points the model at the thing it does not want.
--
-- 1. THE HAIR NEGATIVE — a fourth occurrence of the law in §2.5.
--
--    hs-figure-rendering read "Hair and facial hair are drawn as outlined
--    sections with white inside them, never filled in and never shaded". That
--    is a technique negative, and §2.5 records the law against it after three
--    observations: "no hatching, stippling or grey fill" produced a stippled
--    page, "never as shading" produced a hatched face, and a negative about
--    borders produced a border.
--
--    Observed a fourth time on 2026-09-10. `Hispanic Fall 01` generated with
--    `items.hair` set to "thick wavy dark hair", so hs-hair fired correctly and
--    the prompt said the right thing twice. The hair came back a solid black
--    mass with a few white wave lines through it — 31.2% black across the head
--    crop, against 14.1% on the African American page generated the same day.
--    Uncolourable, which for a coloring page is the whole failure.
--
--    **This corrects 014's premise.** 014 held that "filled hair will keep
--    coming back for as long as nothing says what the hair is", and made hair
--    item data on that basis. Hair is now named, per item, and came back
--    filled anyway. Naming the hair was necessary and is not sufficient; the
--    sentence that names the defect was doing its own damage the whole time.
--
--    Both hair blocks are restated positively, borrowing the phrasing from
--    cb-linework that has never produced filled hair: "a few large outlined
--    flowing sections, left white and open inside".
--
-- 2. THE SEASON HAD ONE PLACE TO GO, AND NOTHING KEPT IT THERE.
--
--    hs-seasonal-restraint read "The season shows in the view outside and in
--    the light rather than in seasonal objects set out on every surface". It
--    was written to stop gourds appearing on every shelf, and at that it works
--    — there is not a pumpkin in any page generated under it.
--
--    But of the two channels it offers, one does not exist. §3.4 and §3.5 put
--    every page in outline alone, nothing shaded, so there is no light on
--    these pages to carry a season. Both channels collapse into one, and the
--    whole seasonal load lands in the window, where the model says autumn the
--    way it has learned to: scattered leaves, in quantity.
--
--    Nothing required that view to be bounded. Where the window happened to be
--    drawn with a frame and panes the leaves stayed outside; where it did not,
--    the leaf field ran flat across the wall plane and read, in Esoh's words,
--    "as if someone taped leaves to the walls".
--
--    The fix gives the season a second channel that outline can actually
--    carry — what the room is dressed with — and requires the view to sit
--    inside a drawn window. Both are positive statements. The clause excluding
--    seasonal objects on every surface is kept: it is a content negative, which
--    the law permits by name, and it is the half that has been working.

begin;

update prompt_blocks set body_text =
  'Clothing and skin are drawn as open white areas with only the lines that '
  'describe their form — a seam, a cuff, a fold. Faces are clean and unmarked. '
  'Hair and facial hair are drawn as a few large flowing sections, each one '
  'outlined and left white and open inside, so they can be coloured like any '
  'other area of the page.',
  updated_at = now()
 where slug = 'hs-figure-rendering';

update prompt_blocks set body_text =
  'The hair is {{hair}}, drawn as a few large outlined sections left white and '
  'open inside.',
  updated_at = now()
 where slug = 'hs-hair';

update prompt_blocks set body_text =
  'The facial hair is {{facial_hair}}, drawn in outline and left white and '
  'open inside.',
  updated_at = now()
 where slug = 'hs-facial-hair';

update prompt_blocks set body_text =
  'Seasonal cues establish atmosphere; they do not repeat. The season shows in '
  'what the room is dressed with — a heavier knit, a throw over the arm of a '
  'chair, a warm drink in hand — and in what is visible through the window, '
  'rather than in seasonal objects set out on every surface. Anything outside '
  'is seen through a window drawn as an enclosed frame with its own panes, so '
  'the view stays within it. This limits how often the season is echoed, not '
  'how furnished the room is.',
  updated_at = now()
 where slug = 'hs-seasonal-restraint';

-- No technique negative survives in any block these four sit beside. Content
-- negatives are permitted by name and are not matched here.
do $$
declare bad text;
begin
  select string_agg(slug, ', ') into bad from prompt_blocks
   where slug in ('hs-figure-rendering', 'hs-hair', 'hs-facial-hair',
                  'hs-seasonal-restraint')
     and body_text ~* '(never|no|without|avoid)[ ]+(filled|fill|shaded|shading|hatch|hatching|stippl|grey|gray|render)';
  if bad is not null then
    raise exception 'technique negative still present in: %', bad;
  end if;
end $$;

-- All four updates landed.
do $$
declare n int;
begin
  select count(*) into n from prompt_blocks
   where slug in ('hs-figure-rendering', 'hs-hair', 'hs-facial-hair',
                  'hs-seasonal-restraint')
     and updated_at > now() - interval '1 minute';
  if n <> 4 then
    raise exception 'expected 4 blocks updated, got %', n;
  end if;
end $$;

commit;

-- 042_two_briefs_stop_asking_for_the_window.sql
--
-- 041 gave the season five channels instead of two. These are the two briefs
-- that override it by naming the window themselves, and both are text I wrote
-- earlier today in 035 and 036 — "writing in a journal beside a framed window
-- where leaves drift past", on the first Solo portrait of the Fall season in
-- two of the three lines.
--
-- A block cannot argue with a brief. `hs-seasonal-restraint` can offer five
-- ways for autumn to show and the subject line will still put a window behind
-- her, because the subject line is describing the page and the block is only
-- describing the rules. These were also the most-generated pages in the
-- library — thirty renders across D111 and D116 — which is why the window read
-- as a fixed idea of autumn when only 2 of the 15 Fall rows on that line ask
-- for one.
--
-- The season now lands in what is worn, what is held, what is underfoot and
-- what is set down: a pushed-back sleeve, a blanket, a basket of apples, boots
-- set aside, a quilt, a lamp lit early, a basket of wool. Each of these is a
-- channel 041 names, and each is a thing outline can draw — which "the light"
-- never was (§3.5).
--
-- Both keep what D104 and D109 require of them: the line is named, the heritage
-- is named where the line is Multiracial, and the hair is described and still
-- matches `items.hair`.

begin;

update items set brief =
  'African American woman in her 30s with a twist-out framing her face, wrapped '
  'in an oversized cable-knit sweater with the sleeves pushed back, writing in a '
  'journal on a porch step with a blanket round her shoulders; a mug beside her, '
  'a basket of apples on the step below and her boots set to one side.',
  updated_at = now()
 where ref = 'African American Fall 01' and ethnicity_line = 'African American';

update items set brief =
  'Multiracial woman in her 30s, African American and Filipina, with loose '
  'spiralling curls gathered off her face, wrapped in a chunky knit cardigan '
  'over a collared shirt, writing in a journal on a sofa with her feet tucked '
  'under a heavy quilt; a mug on the low table, a lamp lit early beside her and '
  'a basket of wool at her feet.',
  updated_at = now()
 where ref = 'Multiracial Fall 01' and ethnicity_line = 'Multiracial';

-- Both updated, and neither asks for a window or falling leaves any more.
do $$
declare bad text;
begin
  select string_agg(ref, ', ') into bad from items
   where ref in ('African American Fall 01', 'Multiracial Fall 01')
     and brief ~* '\ywindow|\yleaves\y|\yleaf\y';
  if bad is not null then raise exception 'brief still names a window or leaves: %', bad; end if;

  select string_agg(ref, ', ') into bad from items
   where ref in ('African American Fall 01', 'Multiracial Fall 01')
     and updated_at < now() - interval '1 minute';
  if bad is not null then raise exception 'brief not updated: %', bad; end if;
end $$;

-- The season still has to be legible. Each brief carries at least two of the
-- channels 041 names, so removing the window did not remove the autumn.
do $$
declare bad text;
begin
  select string_agg(ref, ', ') into bad from items
   where ref in ('African American Fall 01', 'Multiracial Fall 01')
     and not (brief ~* 'sweater|cardigan|knit|blanket|quilt|boots'
              and brief ~* 'apples|wool|lamp lit early|mug');
  if bad is not null then raise exception 'season no longer legible on: %', bad; end if;
end $$;

-- D104/D109 survive the rewrite: the line is named, and the hair still matches
-- the value hs-hair fires with.
do $$
declare bad text;
begin
  select string_agg(ref, ', ') into bad from items
   where ref in ('African American Fall 01', 'Multiracial Fall 01')
     and not (brief ~* 'African American');
  if bad is not null then raise exception 'line not named: %', bad; end if;

  select string_agg(ref, ', ') into bad from items
   where ref in ('African American Fall 01', 'Multiracial Fall 01')
     and (hair is null or brief !~* split_part(regexp_replace(hair, '^(a|an) ', ''), ' ', 1));
  if bad is not null then raise exception 'hair value no longer reflected in brief: %', bad; end if;
end $$;

-- D105.
do $$
declare bad text;
begin
  select string_agg(ref, ', ') into bad from items
   where ref in ('African American Fall 01', 'Multiracial Fall 01')
     and brief ~* '\y(dark|black|white|brown|red|blue|green|golden|amber|silver|grey|gray|blonde|olive|tan|fair|pale)\y';
  if bad is not null then raise exception 'colour word in brief: %', bad; end if;
end $$;

commit;

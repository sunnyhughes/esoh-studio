-- 078_the_block_that_beat_the_brief.sql
--
-- 077 rewrote eleven Symbol briefs to ask for "three or four groups ... clear
-- channels of white run between the groups". Six renders across three pages,
-- two variants each: **every one came back an even all-over field.** The anchor
-- landed, the three scales landed, the species landed, the interior detail
-- landed. The grouping did not, 6 of 6. 075 reported the same thing on one page
-- and it was read as a near miss; it is not, it is a reliable failure.
--
-- The reason is the block order. `template_blocks` puts the brief at 30, and
-- these two bracket it:
--
--   20  hs-comp-tpl-05-symbol-cluster
--       "... Distributed clusters across the full page with one central
--        anchor motif."
--   46  hs-space-tpl-05-symbol-cluster
--       "Keep clean separations between motifs for easy coloring."
--
-- "Distributed ... across the full page" is an instruction to spread. "Clean
-- separations between motifs" is the scatter instruction 075 found in a brief
-- and 077 removed from eleven more — still sitting in the block layer, where
-- nobody looked, because the last seven findings all pointed the other way.
--
-- **This is the first case where the block beat the brief.** D118, D120, D121,
-- D131, D135 and D136 all recorded a brief clause quietly overriding the blocks.
-- Here one brief clause sits between two block clauses saying the opposite, and
-- loses 6 of 6. The lesson is not that the earlier findings were wrong — it is
-- that the count and the position matter, and that "check the brief first" is
-- half a rule. The other half is to read what brackets it.
--
-- Two changes, and one addition.
--
-- **The composition block stops asking for an even spread.** It keeps the edge
-- reach D43 requires — "Density means the composition reaches every edge, not
-- that every surface carries marks" — by sending the *channels* to the edge
-- rather than the motifs.
--
-- **The white-space block moves the white space up a level.** It said to keep
-- every motif separate, which is exactly how you prevent a cluster forming. A
-- group only reads as a group if the things in it may touch. So the separation
-- is stated at the group level and overlap within a group is permitted by name.
--
-- **The horizon is excluded.** Both Hispanic Summer 12 renders put a hill and a
-- horizon line under the sun. `hs-comp-symbol-page` says "No people and no
-- scene", but that block is not attached to TPL-05 — only `hs-no-figures` is,
-- and it bars people, not landscape. A horizon is content, so D46 allows
-- excluding it by name.

begin;

update prompt_blocks set body_text =
  'One large anchor motif at the centre of the page, with 8-15 related motifs '
  'gathered around it in three or four distinct groups rather than spread '
  'evenly. Each group reads as its own mass at mixed scales. The motifs sit on '
  'open paper with no ground, no horizon line and no landscape behind them; '
  'wide channels of white run between the groups and carry out to the edges of '
  'the page.',
  updated_at = now()
 where slug = 'hs-comp-tpl-05-symbol-cluster';

update prompt_blocks set body_text =
  'The white space belongs between the groups, not between every motif. Inside '
  'a group the leaves, stems and blooms may touch and overlap so the group '
  'reads as one mass; the channels between groups stay clear and wide enough to '
  'colour into.',
  updated_at = now()
 where slug = 'hs-space-tpl-05-symbol-cluster';

do $$
declare t text;
begin
  select body_text into t from prompt_blocks
   where slug = 'hs-comp-tpl-05-symbol-cluster';
  if t ~* 'distributed.*across the full page' then
    raise exception 'the composition block still spreads the motifs'; end if;
  if t !~* 'three or four distinct groups' then
    raise exception 'the composition block does not group'; end if;
  if t !~* 'horizon' then
    raise exception 'the horizon is still allowed'; end if;
  if t !~* 'edges of the page' then
    raise exception 'edge reach was dropped — see D43'; end if;

  select body_text into t from prompt_blocks
   where slug = 'hs-space-tpl-05-symbol-cluster';
  if t ~* 'separations between motifs|between every motif.{0,20}stay' then
    raise exception 'the white-space block still separates every motif'; end if;
  if t !~* 'touch and overlap' then
    raise exception 'the white-space block does not permit a group to form';
  end if;

  -- The brief layer must still agree with the blocks. 077 put the same words
  -- in eleven briefs; if either side drifts, this is where it shows.
  if exists (
    select 1 from items
     where page_type = 'Symbol page'
       and ref not in ('African American Spring 13')
       and brief !~* 'three or four groups'
  ) then
    raise exception 'a symbol brief no longer agrees with the block';
  end if;
end $$;

commit;

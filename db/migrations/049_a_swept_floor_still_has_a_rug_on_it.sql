-- 049_a_swept_floor_still_has_a_rug_on_it.sql
--
-- 048 worked and overshot. Removing the clause that named leaves in order to
-- forbid them cleared them from the floor in all six renders, medium and high —
-- the §2.5 reading was right, the prohibition was summoning them. But its
-- replacement, "the floor is clear, swept and ready to walk on", also removed
-- the rug, at both qualities, and the rug is the thing Esoh asked for: "with a
-- little coaxing I could add designs to the furniture and floor that would add
-- personalization".
--
-- "Clear" was doing two jobs — no debris, and nothing on the floor at all —
-- and the second one undid 047. The distinction the sentence needs is between
-- what has blown in and what has been laid down.

begin;

update prompt_blocks set body_text =
  replace(body_text,
    'and the floor is clear, swept and ready to walk on',
    'and the floor is swept, carrying only what has been laid down on purpose — '
    'a rug with its border and motif, a mat by the door'),
  updated_at = now()
 where slug = 'hs-seasonal-restraint';

do $$
declare t text;
begin
  select body_text into t from prompt_blocks where slug = 'hs-seasonal-restraint';
  if t ~* 'the floor is clear' then
    raise exception 'the clause that removed the rug is still present'; end if;
  if t !~* 'a rug with its border and motif' then
    raise exception 'the rug is not named as belonging on the floor'; end if;
  -- and 048's gain is not given back
  if t ~* 'do not collect|belong outdoors|fallen leaves' then
    raise exception 'the block names leaves again'; end if;
end $$;

commit;

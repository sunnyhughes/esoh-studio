-- 085_a_cloud_stops_being_a_row_of_bumps.sql
--
-- Esoh, on the two porch pages he accepted: "The two porch images that I
-- accepted still need better cloud drawing in the background. They look
-- cartoonish and/or flat."
--
-- Cropped to native resolution and looked at, every cloud on both pages is built
-- the same way:
--
--   * one closed outline, and nothing at all inside it;
--   * a **ruled flat base** — a straight horizontal line;
--   * a top made of four or five **near-identical circular bumps** in a row;
--   * no overlap anywhere, no contour broken by a form in front;
--   * all of them about the same size.
--
-- That is the children's-book cloud, and nothing in the prompt asks for anything
-- else. Six active templates can put sky or weather on a page — TPL-02, TPL-04,
-- TPL-06, TPL-07, TPL-08, TPL-09 — and between them they say "Top: sky, trees,
-- or buildings minimal", "Top: window frame and weather", "Top: sky, string
-- lights, pergola, or wall edge". Every one of them says *whether* sky appears
-- and none says how it is drawn, so the model supplies its own idea, which is a
-- cartoon.
--
-- **The block describes the cloud, not the sky.** D120 is the reason. 041 said
-- "where a page has one, it is seen through a window", and on a page with no
-- indoors that read as an instruction to invent a wall — a conditional that
-- invites the model to create the thing it is conditioned on. "Any cloud on the
-- page is drawn thus" cannot do that: with no cloud it says nothing, and it
-- never asks for one. That is also why it can be attached to TPL-04, an interior
-- with a window, without putting weather into a bedroom.
--
-- Four things, each aimed at one of the four faults above, and all of them pure
-- outline so D47 and D44 hold:
--
--   * **Overlapping masses** instead of one shape. Two or three rounded forms,
--     one in front of another.
--   * **A broken contour.** Where a nearer mass passes in front, the line of the
--     one behind stops and picks up on the far side. This is where the depth
--     comes from — the flatness is not a shading problem, it is a contour
--     problem, and shading is not available.
--   * **An uneven base.** The ruled horizontal is the single most cartoonish
--     thing on the page.
--   * **Varied curvature and varied size.** Long slow runs, tight turns, and
--     concave tucks where two masses meet, rather than one bump repeated.
--
-- An interior line following an overlap is a contour, not shading. It is stated
-- that way on purpose: D110 would read hatching here as detail and the grey-fill
-- gate would pass it, exactly as it passed 22.1% ink earlier today.

begin;

insert into prompt_blocks (kind, slug, label, body_text, category_id)
select 'output', 'hs-cloud-form', 'Cloud form',
       'Any cloud on the page is built from two or three rounded masses that '
       'overlap, one sitting in front of another, and its lower edge is soft '
       'and uneven rather than ruled flat. Where a nearer mass passes in front, '
       'the contour of the one behind stops against it and picks up again on '
       'the far side, and one or two lines inside the shape follow that same '
       'overlap so the form reads as rounded. The curves along the top vary — '
       'some running long and slow, some turning tightly, some tucking inward '
       'where two masses meet — rather than repeating one bump at one size. '
       'Clouds on the same page differ in size from each other.',
       id from categories where code = 'coloring-books';

-- Wired to the six active templates that can show sky or weather, at the
-- position where the other drawing rules sit, mirrored from hs-form-in-outline
-- so it lands beside "Form is described by outline" rather than guessing.
insert into template_blocks (template_id, block_id, position)
select tb.template_id, n.id, tb.position + 1
  from template_blocks tb
  join prompt_blocks src on src.id = tb.block_id
  join prompt_templates t on t.id = tb.template_id
  join prompt_blocks n on n.slug = 'hs-cloud-form'
 where src.slug = 'hs-form-in-outline'
   and t.is_active
   and t.slug in ('tpl-02-support-circle', 'tpl-04-healing-room',
                  'tpl-06-walking-reflection', 'tpl-07-pair-conversation',
                  'tpl-08-window-journal', 'tpl-09-outdoor-sanctuary');

do $$
declare n int; t text;
begin
  select count(*) into n from template_blocks tb
    join prompt_blocks b on b.id = tb.block_id
   where b.slug = 'hs-cloud-form';
  if n <> 6 then
    raise exception 'the cloud block reaches % templates, expected 6', n; end if;

  -- It must sit after the block that establishes outline, not before it.
  if exists (
    select 1
      from template_blocks cloud
      join prompt_blocks cb on cb.id = cloud.block_id and cb.slug = 'hs-cloud-form'
      join template_blocks outline on outline.template_id = cloud.template_id
      join prompt_blocks ob on ob.id = outline.block_id
                           and ob.slug = 'hs-form-in-outline'
     where cloud.position <= outline.position
  ) then
    raise exception 'the cloud block runs before form-in-outline';
  end if;

  select body_text into t from prompt_blocks where slug = 'hs-cloud-form';

  -- The four faults, each answered.
  if t !~* 'overlap' then raise exception 'the masses do not overlap'; end if;
  if t !~* 'picks up again on the far side' then
    raise exception 'the contour is never broken by a form in front'; end if;
  if t !~* 'uneven rather than ruled flat' then
    raise exception 'the flat base survives'; end if;
  if t !~* 'rather than repeating one bump' then
    raise exception 'the identical bumps survive'; end if;
  if t !~* 'differ in size' then
    raise exception 'every cloud is still the same size'; end if;

  -- D47 and D44: outline only. The same three checks 084 applies to styles.
  if t ~* 'hatch|stipple|shading|shade|tone|grey|gray|fill' then
    raise exception 'the cloud block asks for something that cannot be coloured';
  end if;

  -- D120: it must describe a cloud that is there, never ask for sky.
  if t !~* '^any cloud' then
    raise exception 'the block does not condition on the cloud itself'; end if;
  if t ~* 'add a cloud|include a cloud|sky shows|there is sky' then
    raise exception 'the block invites sky onto a page that has none'; end if;
end $$;

commit;

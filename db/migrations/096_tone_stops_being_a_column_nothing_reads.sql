-- 096 — Tone stops being a column nothing reads
--
-- The sheet's Tone column is filled on every row — 137 in the sheet, 130 in the
-- database — and no query has ever touched it. 15 distinct values, zero effect
-- on any prompt. That is the same defect 093 fixed for lettering: a column
-- Sunshine filled by hand that nothing consumes.
--
-- What makes it worth building now is not the empty column, it is what 41f3766
-- measured. Of ~3,340 characters in a VV-Styles prompt, 2,612 are word-for-word
-- identical on every design; only ~725 vary. `vvs-colour-life` tells a
-- Confrontational design and a Supportive one alike that colour is "bright,
-- saturated and cheerful", and `vvs-comp-front-print` gives all 130 designs the
-- same 434 characters of arrangement. Tone is the only filled column left that
-- can tell those blocks apart, so it is the selector the constants need.
--
-- This migration does the readable half: the column, the vocabulary, the wiring
-- and the engine selector, in one commit. Splitting the constant blocks by tone
-- comes next and needs this first.
--
-- What a tone block says: how the idea is delivered and what stance the imagery
-- takes. It does not name colour (`vvs-palette` and `vvs-colour-life` own that),
-- it does not set type (the 25 lettering blocks own that), and it stays off
-- arrangement (`vvs-comp-front-print` owns that) so nothing here contradicts a
-- block already in the stack.
--
-- Why it changes the pictures, from D142's evidence: `Humorous` should mean the
-- design shows the joke happening — a character mid-reaction, a hand caught in
-- the act — rather than naming it. VVS-0082's brief asked for "labeled buttons
-- and abstract impact shapes" and produced a pie chart. The brief is still the
-- ceiling ([[the brief is the ceiling]]) and this does not overrule it, but on
-- every row whose brief leaves room, the tone now says what the row is for.
--
-- Nineteen blocks, not fifteen. The live database and the sheet disagree about
-- tone on more rows than the seven the sheet has gained: the database holds
-- `Truth` (5 rows), `Positive` (2), `Accountability` (1) and `Boundaries` (1)
-- where the sheet now reads `Honest`, `Proud`, `Direct`, `Affirming` and `Firm`.
-- The import is still pending, so both vocabularies are live — the sheet's
-- fifteen for after it lands, the database's four extra for the rows as they
-- stand today. Nothing has to be re-run when the import happens.

-- -------------------------------------------------------------- items.tone
--
-- The value is already on every row inside `source_row`, so this is a promotion,
-- not an import: the same string, in a column the engine can read.

alter table items add column if not exists tone text;

comment on column items.tone is
  'Sheet Tone column. Selects a tone block the way art_style selects a base style.';

update items i
   set tone = nullif(trim(i.source_row->>'Tone'), '')
  from categories c
 where c.id = i.category_id
   and c.code = 'vv-styles'
   and i.tone is null;

-- -------------------------------------------------------- prompt_blocks.tone

alter table prompt_blocks drop constraint if exists prompt_blocks_kind_check;
alter table prompt_blocks add constraint prompt_blocks_kind_check
  check (kind = any (array[
    'base_style', 'subject', 'composition', 'environment', 'lighting',
    'color', 'brand_rule', 'print_req', 'negative', 'output', 'lettering',
    'tone'
  ]));

alter table prompt_blocks add column if not exists tone text;

comment on column prompt_blocks.tone is
  'Selects a tone block, the way lettering_style selects a lettering block. Null applies to every tone.';

-- ------------------------------------------------------------- the 19 blocks

insert into prompt_blocks (kind, slug, label, category_id, tone, body_text)
select v.kind, v.slug, v.label, c.id, v.tone, v.body
from categories c, (values

  ('tone', 'vvs-tone-bold', 'Bold', 'Bold',
   'The design states its idea at full strength with nothing hedged. One element is '
   'unmistakably the loudest and everything else defers to it, and every shape commits — '
   'no tentative marks and no apologetic scale.'),

  ('tone', 'vvs-tone-sassy', 'Sassy', 'Sassy',
   'The design delivers the idea with a raised eyebrow. One element is played knowingly '
   'against another — a sweet shape carrying a sharp remark, a prim arrangement looking '
   'entirely unbothered — so the attitude lands before the words are read.'),

  ('tone', 'vvs-tone-confident', 'Confident', 'Confident',
   'The design is at ease with itself. Forms are settled and unhurried, nothing crowds for '
   'attention, and the idea is presented as already true rather than argued for.'),

  ('tone', 'vvs-tone-empowering', 'Empowering', 'Empowering',
   'The design hands its strength to whoever wears it. Figures and forms are shown upright, '
   'open and mid-stride rather than braced, and the idea is addressed outward as something '
   'the reader already holds.'),

  ('tone', 'vvs-tone-confrontational', 'Confrontational', 'Confrontational',
   'The design faces the reader without softening. It is aimed squarely outward, the sharp '
   'part of the idea is the part that gets drawn, and nothing in the imagery lets the point '
   'be taken as a joke.'),

  ('tone', 'vvs-tone-motivational', 'Motivational', 'Motivational',
   'The design shows forward movement. Something is rising, reaching or already underway, '
   'and the idea arrives as momentum the reader can join rather than as an instruction.'),

  ('tone', 'vvs-tone-reflective', 'Reflective', 'Reflective',
   'The design is quiet and inward. Nothing is exclaimed, the imagery holds a single held '
   'moment, and the idea is offered as something being considered rather than announced.'),

  ('tone', 'vvs-tone-supportive', 'Supportive', 'Supportive',
   'The design stands beside the reader. Forms are open-handed and steady, the imagery holds '
   'rather than pushes, and the idea is offered gently and without condition.'),

  ('tone', 'vvs-tone-humorous', 'Humorous', 'Humorous',
   'The design shows the joke happening rather than naming it — a character mid-reaction, a '
   'hand caught in the act, the moment one beat before or after the trouble. The picture is '
   'funny on its own before the words are read.'),

  ('tone', 'vvs-tone-honest', 'Honest', 'Honest',
   'The design says the plain thing. The imagery shows the situation as it is, with nothing '
   'prettified and nothing left out, and no element softens the claim the words make.'),

  ('tone', 'vvs-tone-proud', 'Proud', 'Proud',
   'The design carries itself as a declaration. The subject is presented frontally and held '
   'high, the arrangement is deliberate and ceremonial, and the idea is worn rather than '
   'explained.'),

  ('tone', 'vvs-tone-informative', 'Informative', 'Informative',
   'The design explains. Its parts can be told apart at a glance and each one earns its '
   'place, and the idea is shown to the reader plainly rather than pressed on them.'),

  ('tone', 'vvs-tone-direct', 'Direct', 'Direct',
   'The design makes one statement and stops. A single subject carries it, nothing decorative '
   'is added around the point, and the idea reaches the reader in one move.'),

  ('tone', 'vvs-tone-affirming', 'Affirming', 'Affirming',
   'The design agrees with the reader. Forms are warm, open and settled, and the idea is put '
   'as confirmation of something already so rather than as advice.'),

  ('tone', 'vvs-tone-firm', 'Firm', 'Firm',
   'The design holds a line and does not negotiate. Forms are squared and immovable with '
   'their weight low, and the idea is stated once, without qualification.'),

  -- The four the database still carries. See the header.

  ('tone', 'vvs-tone-truth', 'Truth', 'Truth',
   'The design puts the uncomfortable part in plain sight. The imagery shows what the words '
   'name rather than gesturing at it, and nothing is arranged to make it easier to look at.'),

  ('tone', 'vvs-tone-positive', 'Positive', 'Positive',
   'The design is generous and light on its feet. Forms are open and lifting, the imagery '
   'shows the good outcome rather than the struggle behind it, and the idea arrives as an offer.'),

  ('tone', 'vvs-tone-accountability', 'Accountability', 'Accountability',
   'The design turns the idea back on the reader. The imagery shows the moment of being seen — '
   'a mirror, a caught gesture, a thing finally named — and the point is directed inward '
   'without scolding.'),

  ('tone', 'vvs-tone-boundaries', 'Boundaries', 'Boundaries',
   'The design shows a limit being kept. The imagery makes the edge visible — a raised palm, '
   'a closed door, a step back taken deliberately — and it reads as a calm decision rather '
   'than a fight.')

) as v(kind, slug, label, tone, body)
where c.code = 'vv-styles';

-- ------------------------------------------------------------------- wiring
--
-- Position 33: after the phrase at 32, before the lettering at 34. Tone speaks
-- about the brief and the phrase together, so it reads after both.
--
-- 091's mistake was writing blocks with no `template_blocks` row. A block that
-- is not wired is never selected, and nothing reports it.

insert into template_blocks (template_id, block_id, position)
select t.id, b.id, 33
from prompt_templates t, prompt_blocks b
where t.slug = 'vvs-front-print'
  and b.kind = 'tone'
  and b.slug like 'vvs-tone-%';

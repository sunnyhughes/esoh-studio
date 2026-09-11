-- 037_the_multiracial_line_gets_its_hair_column.sql
--
-- Multiracial was the only line of the three with nothing in `items.hair` — 0
-- of 16 Solo portraits, against 16 of 16 for Hispanic (032) and African
-- American (036). An empty slot drops its whole block by design (D103), so
-- `hs-hair` has never once fired on a Multiracial page.
--
-- That is worth fixing on its own, and it also happens to be the reason the
-- D111 variance baseline measured something other than what it looked like it
-- was measuring: ten runs of `Multiracial Fall 01` with the dedicated hair
-- instruction absent from every prompt.
--
-- Values are taken from the briefs 035 wrote, so the block and the subject line
-- say the same thing rather than two different things. No colour words (D105) —
-- which is the difference between this and the first time `hs-hair` fired for
-- Hispanic under 032, where the value still contained "dark" and the resulting
-- test in D106 was confounded without anyone knowing it yet.

begin;

create temporary table mr_hair (ref text primary key, hair text, facial_hair text)
  on commit drop;

insert into mr_hair (ref, hair, facial_hair) values
  ('Multiracial Fall 01',   'loose spiralling curls gathered off the face', null),
  ('Multiracial Fall 02',   'a short coiled fade',            'a neatly trimmed beard'),
  ('Multiracial Fall 03',   'long straight hair',                          null),
  ('Multiracial Fall 04',   'coils cropped close to the head',             null),
  ('Multiracial Spring 01', 'a high curly puff',                           null),
  ('Multiracial Spring 02', 'short twists',                   'a close-trimmed beard'),
  ('Multiracial Spring 03', 'straight hair tied in a low knot',            null),
  ('Multiracial Spring 04', 'shoulder-length waves held by a wide headband', null),
  ('Multiracial Summer 01', 'short locs gathered at the back',             null),
  ('Multiracial Summer 02', 'a long layered cut',                          null),
  ('Multiracial Summer 03', 'a high-top of tight coils',                   null),
  ('Multiracial Summer 04', 'a long plait over one shoulder',              null),
  ('Multiracial Winter 01', 'two-strand twists pinned up',                 null),
  ('Multiracial Winter 02', 'a short crop',                     'a full trimmed beard'),
  ('Multiracial Winter 03', 'a curly bob',                                 null),
  ('Multiracial Winter 04', 'a long spiral-curled ponytail',               null);

update items i
   set hair = h.hair,
       facial_hair = coalesce(h.facial_hair, i.facial_hair),
       updated_at = now()
  from mr_hair h
 where i.ref = h.ref
   and i.ethnicity_line = 'Multiracial';

-- All 16 Solo portraits now carry hair, so hs-hair fires on every one.
do $$
declare n int;
begin
  select count(*) into n from items
   where ethnicity_line = 'Multiracial' and page_type = 'Solo portrait' and hair is not null;
  if n <> 16 then raise exception 'expected hair on 16 Solo portraits, got %', n; end if;
end $$;

-- D105. The value goes straight into the prompt; a colour word here is what
-- confounded the 032 test.
do $$
declare bad text;
begin
  select string_agg(ref || ' = ' || hair, ', ') into bad from items
   where ethnicity_line = 'Multiracial' and hair is not null
     and hair ~* '\y(dark|black|white|brown|red|blue|green|golden|amber|silver|grey|gray|blonde)\y';
  if bad is not null then raise exception 'colour word in hair value: %', bad; end if;
end $$;

-- The block and the subject line must not describe two different heads. Every
-- hair value's distinguishing word appears in its own brief.
do $$
declare bad text;
begin
  select string_agg(ref, ', ') into bad from items
   where ethnicity_line = 'Multiracial' and page_type = 'Solo portrait'
     and not (brief ~* ('\y' || split_part(regexp_replace(hair, '^(a|an) ', ''), ' ', 1) || '\y'));
  if bad is not null then raise exception 'hair value not reflected in brief: %', bad; end if;
end $$;

commit;

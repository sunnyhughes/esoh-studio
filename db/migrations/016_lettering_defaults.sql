-- 016_lettering_defaults.sql
--
-- The eight default faces (D58) and a lettering default for the coloring-book
-- Quote pages (D59). VV-Styles is deliberately left alone: 130 rows in a
-- category with no template yet, and guessing their lettering ahead of the
-- Stage C design work would just be 130 rows to correct later.

begin;

-- Serif Editorial for the 36 Healing Seasons Quote pages. It reads as a book
-- rather than a poster, which suits a reflective adult title; Block Outline is
-- technically safer but sets recovery affirmations like advertising.
update items i
   set lettering_style = 'Serif Editorial'
  from categories c
 where c.id = i.category_id
   and c.code = 'coloring-books'
   and i.page_type = 'Quote page'
   and i.lettering_style is null;

-- The chosen face per lettering style. Verified against the font binaries:
-- every one carries the full Spanish set plus quotes and dashes.
create table if not exists lettering_faces (
  lettering_style text primary key,
  family          text not null,
  weight          integer not null default 400,
  license         text not null,
  glyph_count     integer,
  notes           text,
  created_at      timestamptz not null default now()
);

comment on table lettering_faces is
  'Default typeface per lettering style for overlaid quote type (D23, D58). '
  'An item may override its own; this is the fallback.';

insert into lettering_faces
  (lettering_style, family, weight, license, glyph_count, notes)
values
  ('Bubble Caps', 'Baloo 2', 800, 'OFL', 856,
   'Widest coverage of the rounded set; counters stay round at any stroke.'),
  ('Brush Script', 'Caveat Brush', 400, 'OFL', 496,
   'Letters stand apart rather than joining — fewer overlaps, fewer seams.'),
  ('Block Outline', 'Archivo Black', 400, 'OFL', 423,
   'Safest face tested: holds from a hairline outline to a very heavy one.'),
  ('Serif Editorial', 'Libre Baskerville', 700, 'OFL', 789,
   'Low contrast keeps the thin strokes open. Playfair was rejected here: '
   'its hairlines collide into solid bars when outlined.'),
  ('Hand-Marker', 'Permanent Marker', 400, 'Apache-2.0', 229,
   'Truest to the style name. Lowest coverage of the set — Spanish and no '
   'further, so a third language would need a different face.'),
  ('Sans Display', 'Montserrat', 800, 'OFL', 1312,
   'Broadest character set of all eighteen.'),
  ('Stencil', 'Big Shoulders Stencil Text', 700, 'OFL', 718,
   'Cleaner segment breaks than Stardos and twice the coverage.'),
  ('Mixed Caps + Script', 'Archivo Black + Caveat Brush', 400, 'OFL', null,
   'A pairing, not a face. Weights are close enough to share one stroke width.')
on conflict (lettering_style) do update
   set family = excluded.family, weight = excluded.weight,
       license = excluded.license, glyph_count = excluded.glyph_count,
       notes = excluded.notes;

commit;

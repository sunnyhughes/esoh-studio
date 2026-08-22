-- 017_font_files.sql
--
-- The font binaries live in assets/fonts/ so a build never depends on Google
-- being reachable (D58). Which file belongs to which lettering style is data,
-- for the same reason the face itself is data.
--
-- Four are variable fonts carrying a wght axis; `weight` names the instance to
-- cut. Rendering the file as-is would silently give the axis default, which
-- for Montserrat is Thin — the opposite of what the style asks for.

begin;

alter table lettering_faces add column if not exists font_file text;

update lettering_faces set font_file = f.file from (values
  ('Bubble Caps',         'Baloo2[wght].ttf'),
  ('Brush Script',        'CaveatBrush-Regular.ttf'),
  ('Block Outline',       'ArchivoBlack-Regular.ttf'),
  ('Serif Editorial',     'LibreBaskerville[wght].ttf'),
  ('Hand-Marker',         'PermanentMarker-Regular.ttf'),
  ('Sans Display',        'Montserrat[wght].ttf'),
  ('Stencil',             'BigShouldersStencilText[wght].ttf'),
  ('Mixed Caps + Script', 'ArchivoBlack-Regular.ttf + CaveatBrush-Regular.ttf')
) as f(style, file) where lettering_faces.lettering_style = f.style;

alter table lettering_faces alter column font_file set not null;

commit;

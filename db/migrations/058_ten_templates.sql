-- 058_ten_templates.sql
--
-- Step 2 of the source-of-truth rebuild (D133). Esoh's decision, 2026-09-14:
-- ten templates.
--
-- The tool had six, keyed one per page type, which silently deleted the
-- variants: three distinct solo compositions collapsed into one, two community
-- compositions into one. That is the direct cause of the sameness, and of
-- journaling reading as ubiquitous — `Window + Journal Reflection` is one of the
-- three solo templates, so a third of the solo pages are meant to be
-- window-and-journal and the other two thirds were never given a composition to
-- be different in.
--
-- Source: `docs/references/hs-folder/template_prompt_framework.csv`, which gives
-- each template a composition directive and a white-space directive of its own.
-- TPL-09 Outdoor Sanctuary exists because seven Environment pages are outdoor
-- while TPL-04 is explicitly an interior; TPL-10 exists because the Decorative
-- page type had no template anywhere, which is the hole the tool filled by
-- inventing `hs-decorative-page` from nothing.
--
-- **The framework's `quote handling` column is deliberately not adopted on the
-- nine non-quote templates.** It reads "No text on this page. Reject any
-- generated lettering." `hs-output` already covers this positively — "surfaces
-- that could carry writing ... are drawn blank, apart from any lettering named
-- above" — and that has held. §2.5 records five measured cases of naming a thing
-- in order to forbid it producing that thing, most recently D131. Adding a
-- second, negative statement of the same rule is the shape that has failed every
-- time. TPL-03 keeps `hs-comp-quote-page`'s positive instruction, because the
-- tool letters a page as SVG at `/api/overlay` (D23, D61) rather than asking the
-- model for type.
--
-- The white-space directives arrive as their own block at position 46 rather
-- than being folded into composition, so a page's density axis (D27) and its
-- template's open-space requirement stay separately readable and separately
-- editable.
--
-- Each new template inherits its wiring from the old template that served the
-- same page type — the style blocks, the density blocks, the subject and
-- seasonal layers — with only the composition block swapped. The six old
-- templates are deactivated rather than dropped, because `generation_jobs` rows
-- point at them and the history of what drew what is worth more than a tidy
-- table. `adult-coloring-clean-line` is deactivated with them: it carries no
-- page type, which means D56's mismatch guard cannot fire on it, and it would
-- remain the one selectable coloring-book template that answers to nothing.

begin;

-- TPL-01 — Solo Portrait Calm Scene (Solo portrait)
insert into prompt_blocks (kind, slug, label, body_text, category_id)
select 'composition', 'hs-comp-tpl-01-solo-portrait-calm', 'Solo Portrait Calm Scene composition',
       'One focal person centered slightly off-axis, 2-3 supporting props, light background context, open lower corners. Top: seasonal cues; Center: face/body focal point; Mid-lower: hands/object; Edges: light framing motifs.',
       id from categories where code = 'coloring-books';
insert into prompt_blocks (kind, slug, label, body_text, category_id)
select 'composition', 'hs-space-tpl-01-solo-portrait-calm', 'Solo Portrait Calm Scene white space',
       'Leave 35-45 percent open colorable space.',
       id from categories where code = 'coloring-books';

insert into prompt_templates
  (slug, name, description, category_id, page_type, has_people,
   variables_json, default_settings, is_active)
select 'tpl-01-solo-portrait-calm', 'Solo Portrait Calm Scene',
       'TPL-01 — Solo Portrait Calm Scene. Serves Solo portrait pages.',
       s.category_id, 'Solo portrait', true,
       s.variables_json, s.default_settings, true
  from prompt_templates s where s.slug = 'hs-solo-portrait';

-- inherit the source template's wiring, minus its composition block
insert into template_blocks (template_id, block_id, position)
select n.id, tb.block_id, tb.position
  from prompt_templates n, template_blocks tb
  join prompt_templates s on s.id = tb.template_id
  join prompt_blocks b on b.id = tb.block_id
 where n.slug = 'tpl-01-solo-portrait-calm' and s.slug = 'hs-solo-portrait'
   and b.kind <> 'composition';

-- plus its own composition and white space
insert into template_blocks (template_id, block_id, position)
select n.id, b.id, 20 from prompt_templates n, prompt_blocks b
 where n.slug = 'tpl-01-solo-portrait-calm' and b.slug = 'hs-comp-tpl-01-solo-portrait-calm';
insert into template_blocks (template_id, block_id, position)
select n.id, b.id, 46 from prompt_templates n, prompt_blocks b
 where n.slug = 'tpl-01-solo-portrait-calm' and b.slug = 'hs-space-tpl-01-solo-portrait-calm';

-- the density blocks are composition-kind and were skipped above
insert into template_blocks (template_id, block_id, position)
select n.id, tb.block_id, tb.position
  from prompt_templates n, template_blocks tb
  join prompt_templates s on s.id = tb.template_id
  join prompt_blocks b on b.id = tb.block_id
 where n.slug = 'tpl-01-solo-portrait-calm' and s.slug = 'hs-solo-portrait'
   and b.kind = 'composition' and b.slug like 'hs-density-%';

-- TPL-02 — Support Circle Scene (Community scene)
insert into prompt_blocks (kind, slug, label, body_text, category_id)
select 'composition', 'hs-comp-tpl-02-support-circle', 'Support Circle Scene composition',
       '3-5 people in a curved or circular arrangement, one clear focal interaction, simple background geometry. Indoor variant uses simple room geometry; outdoor variant uses trees, park edge, or garden as a low-detail backdrop. Top: wall, window, banners, or tree line kept minimal; Center: group interaction; Bottom: chairs, floor, ground, grounding objects.',
       id from categories where code = 'coloring-books';
insert into prompt_blocks (kind, slug, label, body_text, category_id)
select 'composition', 'hs-space-tpl-02-support-circle', 'Support Circle Scene white space',
       'Keep background under 30 percent detail so figures stay readable.',
       id from categories where code = 'coloring-books';

insert into prompt_templates
  (slug, name, description, category_id, page_type, has_people,
   variables_json, default_settings, is_active)
select 'tpl-02-support-circle', 'Support Circle Scene',
       'TPL-02 — Support Circle Scene. Serves Community scene pages.',
       s.category_id, 'Community scene', true,
       s.variables_json, s.default_settings, true
  from prompt_templates s where s.slug = 'hs-community-scene';

-- inherit the source template's wiring, minus its composition block
insert into template_blocks (template_id, block_id, position)
select n.id, tb.block_id, tb.position
  from prompt_templates n, template_blocks tb
  join prompt_templates s on s.id = tb.template_id
  join prompt_blocks b on b.id = tb.block_id
 where n.slug = 'tpl-02-support-circle' and s.slug = 'hs-community-scene'
   and b.kind <> 'composition';

-- plus its own composition and white space
insert into template_blocks (template_id, block_id, position)
select n.id, b.id, 20 from prompt_templates n, prompt_blocks b
 where n.slug = 'tpl-02-support-circle' and b.slug = 'hs-comp-tpl-02-support-circle';
insert into template_blocks (template_id, block_id, position)
select n.id, b.id, 46 from prompt_templates n, prompt_blocks b
 where n.slug = 'tpl-02-support-circle' and b.slug = 'hs-space-tpl-02-support-circle';

-- the density blocks are composition-kind and were skipped above
insert into template_blocks (template_id, block_id, position)
select n.id, tb.block_id, tb.position
  from prompt_templates n, template_blocks tb
  join prompt_templates s on s.id = tb.template_id
  join prompt_blocks b on b.id = tb.block_id
 where n.slug = 'tpl-02-support-circle' and s.slug = 'hs-community-scene'
   and b.kind = 'composition' and b.slug like 'hs-density-%';

-- TPL-03 — Quote Page Framed Border (Quote page)
insert into prompt_blocks (kind, slug, label, body_text, category_id)
select 'composition', 'hs-comp-tpl-03-quote-border', 'Quote Page Framed Border composition',
       'Short centered quote with wide margins and seasonal border motifs on 2-4 sides. Top-third: quote; Outer frame: florals and symbols; Corners: accent clusters; Center whitespace preserved.',
       id from categories where code = 'coloring-books';
insert into prompt_blocks (kind, slug, label, body_text, category_id)
select 'composition', 'hs-space-tpl-03-quote-border', 'Quote Page Framed Border white space',
       'Preserve at least 50 percent open space around text.',
       id from categories where code = 'coloring-books';

insert into prompt_templates
  (slug, name, description, category_id, page_type, has_people,
   variables_json, default_settings, is_active)
select 'tpl-03-quote-border', 'Quote Page Framed Border',
       'TPL-03 — Quote Page Framed Border. Serves Quote page pages.',
       s.category_id, 'Quote page', false,
       s.variables_json, s.default_settings, true
  from prompt_templates s where s.slug = 'hs-quote-page';

-- inherit the source template's wiring, minus its composition block
insert into template_blocks (template_id, block_id, position)
select n.id, tb.block_id, tb.position
  from prompt_templates n, template_blocks tb
  join prompt_templates s on s.id = tb.template_id
  join prompt_blocks b on b.id = tb.block_id
 where n.slug = 'tpl-03-quote-border' and s.slug = 'hs-quote-page'
   and b.kind <> 'composition';

-- plus its own composition and white space
insert into template_blocks (template_id, block_id, position)
select n.id, b.id, 20 from prompt_templates n, prompt_blocks b
 where n.slug = 'tpl-03-quote-border' and b.slug = 'hs-comp-tpl-03-quote-border';
insert into template_blocks (template_id, block_id, position)
select n.id, b.id, 46 from prompt_templates n, prompt_blocks b
 where n.slug = 'tpl-03-quote-border' and b.slug = 'hs-space-tpl-03-quote-border';

-- the density blocks are composition-kind and were skipped above
insert into template_blocks (template_id, block_id, position)
select n.id, tb.block_id, tb.position
  from prompt_templates n, template_blocks tb
  join prompt_templates s on s.id = tb.template_id
  join prompt_blocks b on b.id = tb.block_id
 where n.slug = 'tpl-03-quote-border' and s.slug = 'hs-quote-page'
   and b.kind = 'composition' and b.slug like 'hs-density-%';

-- TPL-03 keeps the positive no-lettering instruction the tool already relies on
insert into template_blocks (template_id, block_id, position)
select n.id, b.id, 21 from prompt_templates n, prompt_blocks b
 where n.slug = 'tpl-03-quote-border' and b.slug = 'hs-comp-quote-page';

-- TPL-04 — Healing Room Interior (Environment page)
insert into prompt_blocks (kind, slug, label, body_text, category_id)
select 'composition', 'hs-comp-tpl-04-healing-room', 'Healing Room Interior composition',
       'One interior room with strong furniture silhouette, layered comfort objects, single anchor light source or window. No people. Top: wall art or window; Center: bed, chair, or table anchor; Lower: rug, books, slippers, plants.',
       id from categories where code = 'coloring-books';
insert into prompt_blocks (kind, slug, label, body_text, category_id)
select 'composition', 'hs-space-tpl-04-healing-room', 'Healing Room Interior white space',
       'Avoid filling every surface with pattern; leave floors and walls partially open.',
       id from categories where code = 'coloring-books';

insert into prompt_templates
  (slug, name, description, category_id, page_type, has_people,
   variables_json, default_settings, is_active)
select 'tpl-04-healing-room', 'Healing Room Interior',
       'TPL-04 — Healing Room Interior. Serves Environment page pages.',
       s.category_id, 'Environment page', false,
       s.variables_json, s.default_settings, true
  from prompt_templates s where s.slug = 'hs-environment-page';

-- inherit the source template's wiring, minus its composition block
insert into template_blocks (template_id, block_id, position)
select n.id, tb.block_id, tb.position
  from prompt_templates n, template_blocks tb
  join prompt_templates s on s.id = tb.template_id
  join prompt_blocks b on b.id = tb.block_id
 where n.slug = 'tpl-04-healing-room' and s.slug = 'hs-environment-page'
   and b.kind <> 'composition';

-- plus its own composition and white space
insert into template_blocks (template_id, block_id, position)
select n.id, b.id, 20 from prompt_templates n, prompt_blocks b
 where n.slug = 'tpl-04-healing-room' and b.slug = 'hs-comp-tpl-04-healing-room';
insert into template_blocks (template_id, block_id, position)
select n.id, b.id, 46 from prompt_templates n, prompt_blocks b
 where n.slug = 'tpl-04-healing-room' and b.slug = 'hs-space-tpl-04-healing-room';

-- the density blocks are composition-kind and were skipped above
insert into template_blocks (template_id, block_id, position)
select n.id, tb.block_id, tb.position
  from prompt_templates n, template_blocks tb
  join prompt_templates s on s.id = tb.template_id
  join prompt_blocks b on b.id = tb.block_id
 where n.slug = 'tpl-04-healing-room' and s.slug = 'hs-environment-page'
   and b.kind = 'composition' and b.slug like 'hs-density-%';

-- TPL-05 — Symbol Cluster Page (Symbol page)
insert into prompt_blocks (kind, slug, label, body_text, category_id)
select 'composition', 'hs-comp-tpl-05-symbol-cluster', 'Symbol Cluster Page composition',
       '8-15 related motifs grouped in balanced clusters with breathing room between forms. Distributed clusters across the full page with one central anchor motif.',
       id from categories where code = 'coloring-books';
insert into prompt_blocks (kind, slug, label, body_text, category_id)
select 'composition', 'hs-space-tpl-05-symbol-cluster', 'Symbol Cluster Page white space',
       'Keep clean separations between motifs for easy coloring.',
       id from categories where code = 'coloring-books';

insert into prompt_templates
  (slug, name, description, category_id, page_type, has_people,
   variables_json, default_settings, is_active)
select 'tpl-05-symbol-cluster', 'Symbol Cluster Page',
       'TPL-05 — Symbol Cluster Page. Serves Symbol page pages.',
       s.category_id, 'Symbol page', false,
       s.variables_json, s.default_settings, true
  from prompt_templates s where s.slug = 'hs-symbol-page';

-- inherit the source template's wiring, minus its composition block
insert into template_blocks (template_id, block_id, position)
select n.id, tb.block_id, tb.position
  from prompt_templates n, template_blocks tb
  join prompt_templates s on s.id = tb.template_id
  join prompt_blocks b on b.id = tb.block_id
 where n.slug = 'tpl-05-symbol-cluster' and s.slug = 'hs-symbol-page'
   and b.kind <> 'composition';

-- plus its own composition and white space
insert into template_blocks (template_id, block_id, position)
select n.id, b.id, 20 from prompt_templates n, prompt_blocks b
 where n.slug = 'tpl-05-symbol-cluster' and b.slug = 'hs-comp-tpl-05-symbol-cluster';
insert into template_blocks (template_id, block_id, position)
select n.id, b.id, 46 from prompt_templates n, prompt_blocks b
 where n.slug = 'tpl-05-symbol-cluster' and b.slug = 'hs-space-tpl-05-symbol-cluster';

-- the density blocks are composition-kind and were skipped above
insert into template_blocks (template_id, block_id, position)
select n.id, tb.block_id, tb.position
  from prompt_templates n, template_blocks tb
  join prompt_templates s on s.id = tb.template_id
  join prompt_blocks b on b.id = tb.block_id
 where n.slug = 'tpl-05-symbol-cluster' and s.slug = 'hs-symbol-page'
   and b.kind = 'composition' and b.slug like 'hs-density-%';

-- TPL-06 — Walking Reflection Scene (Solo portrait)
insert into prompt_blocks (kind, slug, label, body_text, category_id)
select 'composition', 'hs-comp-tpl-06-walking-reflection', 'Walking Reflection Scene composition',
       'Single figure outdoors on a path, sidewalk, trail, dock, or shoreline with calm background depth and limited environmental clutter. Top: sky, trees, or buildings minimal; Center: figure; Lower: path, leaves, water, flowers, pavement texture.',
       id from categories where code = 'coloring-books';
insert into prompt_blocks (kind, slug, label, body_text, category_id)
select 'composition', 'hs-space-tpl-06-walking-reflection', 'Walking Reflection Scene white space',
       'Keep large sky and path zones open to avoid density.',
       id from categories where code = 'coloring-books';

insert into prompt_templates
  (slug, name, description, category_id, page_type, has_people,
   variables_json, default_settings, is_active)
select 'tpl-06-walking-reflection', 'Walking Reflection Scene',
       'TPL-06 — Walking Reflection Scene. Serves Solo portrait pages.',
       s.category_id, 'Solo portrait', true,
       s.variables_json, s.default_settings, true
  from prompt_templates s where s.slug = 'hs-solo-portrait';

-- inherit the source template's wiring, minus its composition block
insert into template_blocks (template_id, block_id, position)
select n.id, tb.block_id, tb.position
  from prompt_templates n, template_blocks tb
  join prompt_templates s on s.id = tb.template_id
  join prompt_blocks b on b.id = tb.block_id
 where n.slug = 'tpl-06-walking-reflection' and s.slug = 'hs-solo-portrait'
   and b.kind <> 'composition';

-- plus its own composition and white space
insert into template_blocks (template_id, block_id, position)
select n.id, b.id, 20 from prompt_templates n, prompt_blocks b
 where n.slug = 'tpl-06-walking-reflection' and b.slug = 'hs-comp-tpl-06-walking-reflection';
insert into template_blocks (template_id, block_id, position)
select n.id, b.id, 46 from prompt_templates n, prompt_blocks b
 where n.slug = 'tpl-06-walking-reflection' and b.slug = 'hs-space-tpl-06-walking-reflection';

-- the density blocks are composition-kind and were skipped above
insert into template_blocks (template_id, block_id, position)
select n.id, tb.block_id, tb.position
  from prompt_templates n, template_blocks tb
  join prompt_templates s on s.id = tb.template_id
  join prompt_blocks b on b.id = tb.block_id
 where n.slug = 'tpl-06-walking-reflection' and s.slug = 'hs-solo-portrait'
   and b.kind = 'composition' and b.slug like 'hs-density-%';

-- TPL-07 — Pair Conversation Scene (Community scene)
insert into prompt_blocks (kind, slug, label, body_text, category_id)
select 'composition', 'hs-comp-tpl-07-pair-conversation', 'Pair Conversation Scene composition',
       'Exactly 2-3 figures in close, readable interaction: seated together, standing side by side, or walking together. Anchor is a porch railing, patio edge, park or city bench, kitchen or dining table, shop chair, or shared task. Top: plants, string lights, window, or tree line; Center: the two figures and their shared focus; Bottom: floorboards, table, bench, path, or ground.',
       id from categories where code = 'coloring-books';
insert into prompt_blocks (kind, slug, label, body_text, category_id)
select 'composition', 'hs-space-tpl-07-pair-conversation', 'Pair Conversation Scene white space',
       'Keep railing, walls, table, and ground simple enough for color fill.',
       id from categories where code = 'coloring-books';

insert into prompt_templates
  (slug, name, description, category_id, page_type, has_people,
   variables_json, default_settings, is_active)
select 'tpl-07-pair-conversation', 'Pair Conversation Scene',
       'TPL-07 — Pair Conversation Scene. Serves Community scene pages.',
       s.category_id, 'Community scene', true,
       s.variables_json, s.default_settings, true
  from prompt_templates s where s.slug = 'hs-community-scene';

-- inherit the source template's wiring, minus its composition block
insert into template_blocks (template_id, block_id, position)
select n.id, tb.block_id, tb.position
  from prompt_templates n, template_blocks tb
  join prompt_templates s on s.id = tb.template_id
  join prompt_blocks b on b.id = tb.block_id
 where n.slug = 'tpl-07-pair-conversation' and s.slug = 'hs-community-scene'
   and b.kind <> 'composition';

-- plus its own composition and white space
insert into template_blocks (template_id, block_id, position)
select n.id, b.id, 20 from prompt_templates n, prompt_blocks b
 where n.slug = 'tpl-07-pair-conversation' and b.slug = 'hs-comp-tpl-07-pair-conversation';
insert into template_blocks (template_id, block_id, position)
select n.id, b.id, 46 from prompt_templates n, prompt_blocks b
 where n.slug = 'tpl-07-pair-conversation' and b.slug = 'hs-space-tpl-07-pair-conversation';

-- the density blocks are composition-kind and were skipped above
insert into template_blocks (template_id, block_id, position)
select n.id, tb.block_id, tb.position
  from prompt_templates n, template_blocks tb
  join prompt_templates s on s.id = tb.template_id
  join prompt_blocks b on b.id = tb.block_id
 where n.slug = 'tpl-07-pair-conversation' and s.slug = 'hs-community-scene'
   and b.kind = 'composition' and b.slug like 'hs-density-%';

-- TPL-08 — Window + Journal Reflection (Solo portrait)
insert into prompt_blocks (kind, slug, label, body_text, category_id)
select 'composition', 'hs-comp-tpl-08-window-journal', 'Window + Journal Reflection composition',
       'Person seated indoors at a window with a journal, mug, or book; the outside view simplified to weather and one or two shapes; indoor comfort props nearby. Top: window frame and weather; Center: seated figure; Lower: blanket, book, mug, plant.',
       id from categories where code = 'coloring-books';
insert into prompt_blocks (kind, slug, label, body_text, category_id)
select 'composition', 'hs-space-tpl-08-window-journal', 'Window + Journal Reflection white space',
       'The window view should stay simple and not compete with the figure.',
       id from categories where code = 'coloring-books';

insert into prompt_templates
  (slug, name, description, category_id, page_type, has_people,
   variables_json, default_settings, is_active)
select 'tpl-08-window-journal', 'Window + Journal Reflection',
       'TPL-08 — Window + Journal Reflection. Serves Solo portrait pages.',
       s.category_id, 'Solo portrait', true,
       s.variables_json, s.default_settings, true
  from prompt_templates s where s.slug = 'hs-solo-portrait';

-- inherit the source template's wiring, minus its composition block
insert into template_blocks (template_id, block_id, position)
select n.id, tb.block_id, tb.position
  from prompt_templates n, template_blocks tb
  join prompt_templates s on s.id = tb.template_id
  join prompt_blocks b on b.id = tb.block_id
 where n.slug = 'tpl-08-window-journal' and s.slug = 'hs-solo-portrait'
   and b.kind <> 'composition';

-- plus its own composition and white space
insert into template_blocks (template_id, block_id, position)
select n.id, b.id, 20 from prompt_templates n, prompt_blocks b
 where n.slug = 'tpl-08-window-journal' and b.slug = 'hs-comp-tpl-08-window-journal';
insert into template_blocks (template_id, block_id, position)
select n.id, b.id, 46 from prompt_templates n, prompt_blocks b
 where n.slug = 'tpl-08-window-journal' and b.slug = 'hs-space-tpl-08-window-journal';

-- the density blocks are composition-kind and were skipped above
insert into template_blocks (template_id, block_id, position)
select n.id, tb.block_id, tb.position
  from prompt_templates n, template_blocks tb
  join prompt_templates s on s.id = tb.template_id
  join prompt_blocks b on b.id = tb.block_id
 where n.slug = 'tpl-08-window-journal' and s.slug = 'hs-solo-portrait'
   and b.kind = 'composition' and b.slug like 'hs-density-%';

-- TPL-09 — Outdoor Sanctuary (Environment page)
insert into prompt_blocks (kind, slug, label, body_text, category_id)
select 'composition', 'hs-comp-tpl-09-outdoor-sanctuary', 'Outdoor Sanctuary composition',
       'One outdoor retreat space with a strong built anchor (patio, courtyard, balcony, garden bed) plus plants and seating. No people. Top: sky, string lights, pergola, or wall edge; Center: seating or planting anchor; Lower: paving, path, pots, ground plants.',
       id from categories where code = 'coloring-books';
insert into prompt_blocks (kind, slug, label, body_text, category_id)
select 'composition', 'hs-space-tpl-09-outdoor-sanctuary', 'Outdoor Sanctuary white space',
       'Keep sky, paving, and lawn zones broadly open; do not pattern every surface.',
       id from categories where code = 'coloring-books';

insert into prompt_templates
  (slug, name, description, category_id, page_type, has_people,
   variables_json, default_settings, is_active)
select 'tpl-09-outdoor-sanctuary', 'Outdoor Sanctuary',
       'TPL-09 — Outdoor Sanctuary. Serves Environment page pages.',
       s.category_id, 'Environment page', false,
       s.variables_json, s.default_settings, true
  from prompt_templates s where s.slug = 'hs-environment-page';

-- inherit the source template's wiring, minus its composition block
insert into template_blocks (template_id, block_id, position)
select n.id, tb.block_id, tb.position
  from prompt_templates n, template_blocks tb
  join prompt_templates s on s.id = tb.template_id
  join prompt_blocks b on b.id = tb.block_id
 where n.slug = 'tpl-09-outdoor-sanctuary' and s.slug = 'hs-environment-page'
   and b.kind <> 'composition';

-- plus its own composition and white space
insert into template_blocks (template_id, block_id, position)
select n.id, b.id, 20 from prompt_templates n, prompt_blocks b
 where n.slug = 'tpl-09-outdoor-sanctuary' and b.slug = 'hs-comp-tpl-09-outdoor-sanctuary';
insert into template_blocks (template_id, block_id, position)
select n.id, b.id, 46 from prompt_templates n, prompt_blocks b
 where n.slug = 'tpl-09-outdoor-sanctuary' and b.slug = 'hs-space-tpl-09-outdoor-sanctuary';

-- the density blocks are composition-kind and were skipped above
insert into template_blocks (template_id, block_id, position)
select n.id, tb.block_id, tb.position
  from prompt_templates n, template_blocks tb
  join prompt_templates s on s.id = tb.template_id
  join prompt_blocks b on b.id = tb.block_id
 where n.slug = 'tpl-09-outdoor-sanctuary' and s.slug = 'hs-environment-page'
   and b.kind = 'composition' and b.slug like 'hs-density-%';

-- TPL-10 — Decorative Border & Pattern Page (Decorative page)
insert into prompt_blocks (kind, slug, label, body_text, category_id)
select 'composition', 'hs-comp-tpl-10-decorative-border', 'Decorative Border & Pattern Page composition',
       'Seasonal border or repeating pattern frame with 4-8 comfort objects set inside it; flatter and more graphic than a symbol cluster. Full-page border or corner frames; Center: object grouping; Background: restrained repeating pattern or open white.',
       id from categories where code = 'coloring-books';
insert into prompt_blocks (kind, slug, label, body_text, category_id)
select 'composition', 'hs-space-tpl-10-decorative-border', 'Decorative Border & Pattern Page white space',
       'Keep the center open enough to read as a resting page; pattern supports, never fills.',
       id from categories where code = 'coloring-books';

insert into prompt_templates
  (slug, name, description, category_id, page_type, has_people,
   variables_json, default_settings, is_active)
select 'tpl-10-decorative-border', 'Decorative Border & Pattern Page',
       'TPL-10 — Decorative Border & Pattern Page. Serves Decorative page pages.',
       s.category_id, 'Decorative page', false,
       s.variables_json, s.default_settings, true
  from prompt_templates s where s.slug = 'hs-decorative-page';

-- inherit the source template's wiring, minus its composition block
insert into template_blocks (template_id, block_id, position)
select n.id, tb.block_id, tb.position
  from prompt_templates n, template_blocks tb
  join prompt_templates s on s.id = tb.template_id
  join prompt_blocks b on b.id = tb.block_id
 where n.slug = 'tpl-10-decorative-border' and s.slug = 'hs-decorative-page'
   and b.kind <> 'composition';

-- plus its own composition and white space
insert into template_blocks (template_id, block_id, position)
select n.id, b.id, 20 from prompt_templates n, prompt_blocks b
 where n.slug = 'tpl-10-decorative-border' and b.slug = 'hs-comp-tpl-10-decorative-border';
insert into template_blocks (template_id, block_id, position)
select n.id, b.id, 46 from prompt_templates n, prompt_blocks b
 where n.slug = 'tpl-10-decorative-border' and b.slug = 'hs-space-tpl-10-decorative-border';

-- the density blocks are composition-kind and were skipped above
insert into template_blocks (template_id, block_id, position)
select n.id, tb.block_id, tb.position
  from prompt_templates n, template_blocks tb
  join prompt_templates s on s.id = tb.template_id
  join prompt_blocks b on b.id = tb.block_id
 where n.slug = 'tpl-10-decorative-border' and s.slug = 'hs-decorative-page'
   and b.kind = 'composition' and b.slug like 'hs-density-%';

-- The six that keyed one template per page type, and the one with no page type.
update prompt_templates set is_active = false, updated_at = now()
 where category_id = (select id from categories where code = 'coloring-books')
   and slug in ('hs-solo-portrait','hs-community-scene','hs-quote-page',
                'hs-environment-page','hs-symbol-page','hs-decorative-page',
                'adult-coloring-clean-line');

do $$
declare n int;
begin
  select count(*) into n from prompt_templates t
    join categories c on c.id = t.category_id
   where c.code = 'coloring-books' and t.is_active;
  if n <> 10 then raise exception 'expected 10 active templates, got %', n; end if;

  -- Every template must carry exactly one composition block of its own.
  select count(*) into n from prompt_templates t
   where t.is_active and t.slug like 'tpl-%'
     and (select count(*) from template_blocks tb join prompt_blocks b on b.id = tb.block_id
           where tb.template_id = t.id and b.slug like 'hs-comp-tpl-%') <> 1;
  if n <> 0 then raise exception '% templates have the wrong composition count', n; end if;

  -- And its own white-space rule.
  select count(*) into n from prompt_templates t
   where t.is_active and t.slug like 'tpl-%'
     and not exists (select 1 from template_blocks tb join prompt_blocks b on b.id = tb.block_id
                      where tb.template_id = t.id and b.slug like 'hs-space-tpl-%');
  if n <> 0 then raise exception '% templates have no white-space rule', n; end if;

  -- A figure page must keep the hair blocks; a people-free page must not.
  select count(*) into n from prompt_templates t
   where t.is_active and t.slug like 'tpl-%' and t.has_people
     and not exists (select 1 from template_blocks tb join prompt_blocks b on b.id = tb.block_id
                      where tb.template_id = t.id and b.slug = 'hs-hair');
  if n <> 0 then raise exception '% figure templates lost their hair block', n; end if;
end $$;

commit;

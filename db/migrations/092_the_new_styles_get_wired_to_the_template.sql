-- 092 — The new styles get wired to the template
--
-- 091 wrote the thirteen missing `base_style` blocks and stopped there, which
-- made them invisible. `getBlocks` in `lib/prompt-engine.ts` does not read
-- `prompt_blocks` directly — it joins through `template_blocks`:
--
--     from template_blocks tb
--     join prompt_blocks b on b.id = tb.block_id
--    where tb.template_id = $1 and (b.art_style is null or b.art_style = $2)
--
-- A block with no row in `template_blocks` is never selected, whatever its
-- art_style says. So after 091 a design naming Minimal Symbolic still reached
-- `buildPrompt`'s guard and threw "No base style block for art style
-- 'Minimal Symbolic'" — the same 37 rows unbuildable, now failing loudly
-- instead of silently, which is the only improvement 091 actually delivered.
--
-- 091's own check was the wrong join. It confirmed `items.art_style` matched a
-- row in `prompt_blocks` and concluded the rows were buildable. Membership in
-- `prompt_blocks` is not reachability; `template_blocks` is what the engine
-- reads. Position 10 is the base_style slot, per 020's wiring block.
--
-- After this, all 25 vv-styles base styles are attached to `vvs-front-print`
-- at position 10 and `getBlocks` returns exactly one of them per call.

insert into template_blocks (template_id, block_id, position)
select t.id, b.id, 10
from prompt_templates t, prompt_blocks b, (values
  ('vvs-style-minimal-symbolic'),
  ('vvs-style-emotional-illustrative'),
  ('vvs-style-architectural-blueprint-editorial'),
  ('vvs-style-botanical-editorial-illustration'),
  ('vvs-style-editorial-scene'),
  ('vvs-style-urban-graffiti'),
  ('vvs-style-feminine'),
  ('vvs-style-geometric-abstract'),
  ('vvs-style-soft-botanical-line-art'),
  ('vvs-style-split-scene-editorial-illustration'),
  ('vvs-style-retro-diner-comic'),
  ('vvs-style-art-deco-editorial'),
  ('vvs-style-celestial')
) as v(slug)
where t.slug = 'vvs-front-print' and b.slug = v.slug;

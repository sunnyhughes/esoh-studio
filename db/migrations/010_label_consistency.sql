-- 010_label_consistency.sql
-- 009 renamed two block labels while leaving their art_style tags unchanged,
-- which would have shown "Open Scene" in the UI against an "Editorial Scene"
-- value in the spreadsheet and the items table. Renaming the vocabulary itself
-- is Esoh's call, not a side effect of a style fix.
begin;
update prompt_blocks set label = 'Editorial Scene' where slug = 'hs-style-editorial-scene';
update prompt_blocks set label = 'Texture and form' where slug = 'hs-texture-as-pattern';
commit;

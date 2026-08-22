-- 012_single_exemplar.sql
--
-- Three exemplars were active at once: two sparse pages registered when the
-- brief was "more open", and hoodie-on-sofa, registered when the brief turned
-- out to be "detailed and full". Sending all three as image input asks the
-- model to average two opposite intentions, which is a good description of the
-- results — never busy enough, never rich enough.
--
-- The two sparse pages stay as study material. Only the page identified as the
-- rendering target is sent to the model.
begin;
update reference_images set usable_as_input = false, kind = 'study'
 where storage_path in ('exemplars/journaling-under-tree.png',
                        'exemplars/walking-with-mug.png');
commit;

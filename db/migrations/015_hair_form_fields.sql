-- 015_hair_form_fields.sql
--
-- Puts hairstyle and facial hair on the generation form, and gives the setting
-- field the same treatment. All three are `combo`: the list is a starting point
-- you pick from or type past, because the prompt is a guideline for the
-- generation and not the master of the design.
--
-- The lists are deliberately specific and contemporary (D49). A vague field
-- invites a vague answer, and a vague answer is what the exemplar overrides.

begin;

update prompt_templates
   set variables_json = variables_json
     || jsonb_build_array(
          jsonb_build_object(
            'name', 'hair',
            'label', 'Hairstyle',
            'type', 'combo',
            'required', false,
            'placeholder', 'e.g. box braids, short fade with a lineup',
            'options', jsonb_build_array(
              'a short tapered afro', 'a full afro', 'a twist-out',
              'wash-and-go coils', 'box braids', 'knotless braids',
              'cornrows', 'Fulani braids', 'two-strand twists',
              'Bantu knots', 'locs', 'faux locs', 'a high puff',
              'a silk press', 'a curly bob', 'long layered curls',
              'a short fade', 'a short fade with a lineup',
              'a high-top fade', '360 waves', 'sponge curls',
              'a shaved head', 'a headwrap')),
          jsonb_build_object(
            'name', 'facial_hair',
            'label', 'Facial hair',
            'type', 'combo',
            'required', false,
            'placeholder', 'leave blank if not applicable',
            'options', jsonb_build_array(
              'clean-shaven', 'light stubble', 'a short beard',
              'a full beard', 'a full beard with a lineup',
              'a goatee', 'a mustache', 'a chin-strap beard')))
 where page_type is not null
   and not (variables_json @> '[{"name":"hair"}]');

-- The setting field existed but was free text with no guidance, and nothing
-- filled it from the item, so it was always blank and always dropped.
update prompt_templates
   set variables_json = (
     select jsonb_agg(
       case when v->>'name' = 'environment'
            then v || jsonb_build_object(
                   'type', 'combo',
                   'placeholder',
                     'what is actually in the room — the fuller the better',
                   'options', jsonb_build_array(
                     'a living room with a sectional, floating shelves, a trailing pothos and a lamp',
                     'a kitchen with open shelving, mugs, a kettle and herbs on the sill',
                     'a bedroom with layered bedding, a stack of books and a wall of framed photos',
                     'a front porch with a swing, potted plants and a woven mat',
                     'a home office with a desk, a monitor, plants and a corkboard'))
            else v end)
       from jsonb_array_elements(variables_json) v)
 where variables_json @> '[{"name":"environment"}]';

commit;

# VV-Styles vocabulary — every art style, lettering style and tone the tool knows

Generated from the database on 2026-09-29, after migrations 096–098. **Nothing here
is hand-written prose about the tool — every description is the exact text that
goes into a prompt.** Regenerate with:

```bash
psql "$DATABASE_URL" -c "select b.kind, b.art_style, b.lettering_style, b.tone,
  b.slug, b.body_text from prompt_blocks b join template_blocks tb on tb.block_id=b.id
  join prompt_templates t on t.id=tb.template_id
 where t.slug='vvs-front-print' and b.is_active order by tb.position"
```

## How the three columns reach a prompt

| Column | What it selects | If the value names nothing |
|---|---|---|
| **Art Style** | the base style block (how it is drawn) **and** the arrangement block (how it is laid out) | **fails loudly** — `No base style block for art style "X"`, nothing is generated |
| **Lettering Style** | one lettering block (letterform technique only) | **fails silently** — the prompt goes out with no lettering instruction |
| **Tone** | one tone block (how the idea is delivered) | **fails silently** — the prompt goes out with no tone instruction |

The join is on the **exact string**, including capitals, spaces and punctuation.
`Chrome Y2K` and `Y2K Chrome` are two different values; so are
`Urban graffiti` and `Urban Graffiti`.

Art style is also the one column the tool does not need: it is chosen at
generation time, so a blank cell still generates. Lettering and tone are read
from the row or the form, and a blank cell means that instruction is absent.

---

# Part 1 — the checklist

## Art styles

31 blocks. `Lists` means the name is on your spreadsheet's Lists tab; `rows` is
how many of the sheet's 137 rows use it today.

| Art style (exact string) | Block | Lists tab | Rows | Arrangement | Description written in |
|---|---|---|---|---|---|
| Architectural / Blueprint Editorial | yes | yes | 5 | panel | 091 |
| Art Deco Editorial | yes | yes | 1 | emblem | 091 |
| Bold Minimal | yes | yes | 6 | open | 020 |
| Botanical Editorial Illustration | yes | yes | 4 | open | 091 |
| Celestial | yes | yes | 1 | emblem | 091 |
| Chrome Y2K | yes | — | — | statement | 094 |
| Collage Zine Cutout | yes | — | — | collage | 094 |
| Collegiate / Varsity Emblem | yes | yes | 1 | emblem | 084 |
| Editorial Scene | yes | yes | 2 | scene | 091 |
| Editorial Typographic | yes | yes | 14 | open | 020 |
| Emotional Illustrative | yes | yes | 7 | scene | 091 |
| Feminine | yes | yes | 2 | open | 091 |
| Geometric Abstract | yes | yes | 1 | panel | 091 |
| Hand-Drawn Doodle | yes | — | — | scene | 020 |
| Luxury Editorial Typography | yes | yes | 1 | open | 084 |
| Minimal Symbolic | yes | yes | 9 | open | 091 |
| Modern Grunge Halftone | yes | — | — | statement | 094 |
| Modern Script Statement | yes | — | — | statement | 094 |
| Modern Transit Poster | **no** | yes | — | — | **none — would fail** |
| Neo-Brutalist Grid | yes | — | — | panel | 094 |
| Oversized Condensed Statement | yes | — | — | statement | 094 |
| Photoreal Composite | yes | — | — | statement | 020 |
| Retro Comic | yes | yes | 6 | scene | 020 |
| Retro Diner / Comic | yes | yes | 1 | scene | 091 |
| Retro Groovy | yes | yes | 3 | emblem | 020 |
| Soft Botanical Line Art | yes | yes | 1 | open | 091 |
| Split-Scene Editorial Illustration | yes | yes | 1 | split | 091 |
| Streetwear Graffiti | yes | yes | 4 | statement | 020 |
| Tattoo Linework | yes | yes | — | emblem | 020 |
| Urban graffiti | yes | yes | 2 | statement | 091 |
| Vintage Badge | yes | yes | 3 | emblem | 020 |
| Vintage Poster | yes | yes | 3 | emblem | 084 |
| Zentangle Pattern | **no** | yes | — | — | **none — would fail** |

**Two names on your Lists tab have no apparel block.** Assigning either to a row
makes that row fail at generation with `No base style block for art style`:

- **`Modern Transit Poster`** — your name, never written. Nothing else in the
  library covers it (the closest, `Vintage Poster`, is mid-century rather than
  transit-poster).
- **`Zentangle Pattern`** — a coloring-book art style that has a block in the
  coloring-books category, not in apparel. It is probably on the apparel Lists
  tab by inheritance from the coloring-book workbook.

**Eight blocks exist that are not on your Lists tab.** Six are mine from 2026-09-28
and you have never seen them — that is why `Chrome Y2K` was unfamiliar:

| Art style | Where it came from |
|---|---|
| Modern Grunge Halftone | 094, written by me 2026-09-28 |
| Oversized Condensed Statement | 094, written by me 2026-09-28 |
| Chrome Y2K | 094, written by me 2026-09-28 |
| Collage Zine Cutout | 094, written by me 2026-09-28 |
| Neo-Brutalist Grid | 094, written by me 2026-09-28 |
| Modern Script Statement | 094, written by me 2026-09-28 |
| Hand-Drawn Doodle | 020, one of the original twelve; used by no design |
| Photoreal Composite | 020, one of the original twelve; used by no design |

094 was written against your remark that the styles "all seem too plain and
don't match the feelings of the quotes", and nothing was removed to make room
for them. They are selectable in the form because art style is an argument, not
a stored value — which is exactly why they could appear without ever touching
your spreadsheet. **They have never been checked against your reference images.**

## Lettering styles

25 blocks, one per entry on your Lists tab — they match exactly, including the
two typos the sheet carries (`High-Constrast`, `acents`), because the join is on
the string. `Research doc` is where your new document ranks it.

| Lettering style (exact string) | Rows | Research doc |
|---|---|---|
| Big Top Display + playful condensed sans | 2 | excluded |
| Block Outline | 2 | #15 |
| Bold Geometric Sans | 1 | not mentioned |
| Bold Sans | 7 | #3 |
| Bold Sans + Italic accent | 4 | #8 |
| Bold Sans + Script accent | 6 | #1 |
| Bold Sans + Technical accent | 5 | #7 |
| Brush Script | — | excluded |
| Bubble Caps | 3 | not mentioned |
| Bubble Caps + handwritten script accent | 1 | #6 |
| Distressed Block Caps + Handwritten Strikeout | 1 | #11 |
| Elegant Serif Display + Geometric Sans | 1 | #4 |
| Hand-Marker | 1 | #14 |
| Hand-Marker Script | 1 | #14 |
| High-Constrast Serif + Small Sans | 3 | #2 |
| Mixed Caps + Script | 4 | excluded |
| Modern typography | 4 | excluded |
| Retro Display | 2 | #5 |
| Sans Display | 6 | not mentioned |
| Serif Display + Script | 5 | #9 |
| Serif Editorial | 10 | not mentioned |
| Soft hand-drawn | — | #12 |
| Soft hand-drawn serif + playful label-maker acents | 1 | #10 |
| Sophisticated editorial | 4 | excluded |
| Stencil | 3 | #13 |

Adopting your doc's exclusions would leave **14 filled rows** pointing at a
retired style. And four styles the doc never ranks cover
**20 rows** between them — including `Serif Editorial`, the most-used
lettering style in the library.

## Tones

19 blocks. Your Lists tab has 15; the other four are values the database still
carries from the older export, kept so no row loses its tone before the import.

| Tone (exact string) | Lists tab | Sheet rows | Database rows |
|---|---|---|---|
| Accountability | — (database only) | — | 1 |
| Affirming | yes | 1 | — |
| Bold | yes | 32 | 40 |
| Boundaries | — (database only) | — | 1 |
| Confident | yes | 15 | 12 |
| Confrontational | yes | 9 | 9 |
| Direct | yes | 3 | — |
| Empowering | yes | 12 | 4 |
| Firm | yes | 1 | — |
| Honest | yes | 5 | — |
| Humorous | yes | 7 | 4 |
| Informative | yes | 3 | 3 |
| Motivational | yes | 9 | 10 |
| Positive | — (database only) | — | 2 |
| Proud | yes | 4 | — |
| Reflective | yes | 8 | 4 |
| Sassy | yes | 21 | 24 |
| Supportive | yes | 7 | 11 |
| Truth | — (database only) | — | 5 |

## Your research doc's pairings, translated

Only the combos whose art style the tool already has. The third column is my
translation into the tool's exact lettering names — the judgement calls are
marked.

| Art style | Your doc's typography combo | Nearest tool lettering style |
|---|---|---|
| Architectural / Blueprint Editorial | Bold Sans + Technical Accent / Heavy Industrial Sans + Data Monospace | Bold Sans + Technical accent |
| Bold Minimal | Elegant Serif Display + Geometric Sans; also Single-Font Geometric Sans | Elegant Serif Display + Geometric Sans, or Bold Geometric Sans |
| Botanical Editorial Illustration | Traditional Book Serif + Monospaced Spec Tag | Serif Editorial or Bold Sans + Technical accent (no exact match) |
| Celestial | Ornate Serif + Delicate Script | Serif Display + Script (closest) |
| Chrome Y2K | Bubble Caps + Handwritten Script Accent (doc calls the art style “Y2K Chrome & Stars”) | Bubble Caps + handwritten script accent |
| Collegiate / Varsity Emblem | Bold Sans + Italic Accent, or Athletic Slab | Bold Sans + Italic accent |
| Emotional Illustrative | Soft Hand-Drawn + Playful Label-Maker Accent | Soft hand-drawn serif + playful label-maker acents |
| Hand-Drawn Doodle | Chunky Rounded Type + Casual Script | Bubble Caps + handwritten script accent (closest) |
| Minimal Symbolic | Distressed Block Caps + Handwritten Strikeout | Distressed Block Caps + Handwritten Strikeout |
| Retro Comic | Heavy Comic Display + Condensed Sans | Big Top Display + playful condensed sans — which your doc excludes |
| Retro Groovy | Retro Display + Rounded Sans | Retro Display |
| Soft Botanical Line Art | High-Contrast Serif + Small Sans / Soft Hand-Drawn Serif + Clean Small Sans | High-Constrast Serif + Small Sans |
| Streetwear Graffiti | Stencil + Hand-Marker Script | Stencil or Hand-Marker Script — the tool picks one |
| Tattoo Linework | Blackletter / Gothic + Compact Sans | — no block of that shape |
| Vintage Badge | Serif Display + Condensed Sans | Serif Display + Script (closest) |
| Vintage Poster | Arched Block Display + Vintage Script | Serif Display + Script, or Retro Display |

---

# Part 2 — the descriptions

Every one of these is the literal sentence the model receives.

## What every design gets, whatever the columns say

**`vvs-comp-front-print`** — Front-print composition

> A single front-print graphic, centred in its area and large enough to read at arm's length, with the phrase landing first and the imagery second. The group spans the print area rather than sitting small within it, and it is one deliberate arrangement — every element belongs to it and nothing is a stray mark left in an empty field.

**`vvs-subject`** — Visual elements

> {{visual_elements}}

**`vvs-quote`** — The phrase

> The design carries the exact phrase "{{quote}}", spelled precisely as written and legible at a glance. The lettering is drawn as part of the artwork — it shares the same contour weight and ink as the imagery and is built into the composition rather than laid on top of it.

**`vvs-palette`** — Palette

> Palette: {{palette}}.

**`vvs-colour-life`** — Colour has to live

> Colour is bright, saturated and cheerful. Light, mid and dark values are all present, so the design has depth and lift rather than sitting in one register. Where a palette is named, take it at its most vivid reading.

**`vvs-garment`** — Garment contrast

> The design carries its own contrast so it reads on any garment colour: shapes are held by dark contours with lighter fills inside them, and the design does not rely on the fabric behind it to separate one element from another. It will first be printed on {{garment}} fabric.

**`vvs-clean-date`** — Clean date

> A small ribbon within the design carries the text "{{clean_date}}".

**`vvs-flat-ink`** — Flat ink separation

> Built for DTF, which prints full colour: use as many colours as the design wants. Every area of colour is one flat, solid, evenly filled shape with a hard edge, and colours meet each other cleanly along a definite boundary. All type is filled solid.

**`vvs-edge-quality`** — Detail that survives printing

> Detail is kept at a weight that survives the press: the thinnest stroke stays heavy enough to hold ink, and the counters inside letters stay open.

**`vvs-keyline`** — Keyline

> Type and the focal shapes are separated from the fabric by contour rather than by luck: they carry one or more offset outlines in a contrasting ink, each following the form exactly and sitting a consistent distance outside the one before it. Two or three stacked contours are usual on bold display work; refined editorial work takes one, or leaves the form bare where the style is built on restraint.

**`vvs-output`** — Isolated cut-out artwork

> Delivered as isolated cut-out artwork standing on nothing. A badge, shield, circle, banner or panel belongs in the design whenever it is drawn as artwork in its own right, carrying its own contour, its own colour and its own detail. Outside that artwork the file is empty: around the whole design, and inside every gap between its shapes, the ground is fully transparent and the garment shows through.

**`vvs-exclusions`** — Excluded content

> The image shows the artwork by itself: no shirt, no mockup, no hanger, no draped or folded cloth, no person wearing the design, no photograph of a product. No brand logos or trademarks, no signature, no watermark. No recovery-fellowship logos or symbols. No drugs, no weapons, no injuries.

## Art styles — how it is drawn

### Architectural / Blueprint Editorial

> Drafting-table artwork in the manner of a working blueprint. Construction is left visible: hairline measure lines, section marks and numbered callouts sit alongside the main forms at one consistent fine weight. Solid areas stay flat and the linework carries all of the detail.

*Arrangement: panel. Block `vvs-style-architectural-blueprint-editorial`.*

### Art Deco Editorial

> Artwork built on Deco symmetry and stepped geometry. Forms rise in graduated tiers about a strong central axis, framed by fine parallel rules and fanned repeats at an even hairline weight. Flat metallic-toned fills against a deep ground, with sharp mitred corners throughout.

*Arrangement: emblem. Block `vvs-style-art-deco-editorial`.*

### Bold Minimal

> Bold reduced graphic artwork built from clean geometric shapes with hard edges. Few elements, large scale, high contrast, flat solid inks. Every form is carried down to its clearest silhouette.

*Arrangement: open. Block `vvs-style-bold-minimal`.*

### Botanical Editorial Illustration

> Composed botanical artwork drawn with editorial restraint. Growing forms are rendered as clean filled silhouettes carrying a few interior veins, arranged into deliberate structure — a border, an arch, a repeating run — at an even weight with generous space between them.

*Arrangement: open. Block `vvs-style-botanical-editorial-illustration`.*

### Celestial

> Artwork built from celestial geometry arranged with deliberate symmetry. Discs and crescents are solid flat shapes, ringed by fine radiating lines and small punctuation at a lighter weight. Depth is suggested by overlap and graduated sizing rather than by shading.

*Arrangement: emblem. Block `vvs-style-celestial`.*

### Chrome Y2K

> Early-2000s chrome artwork rendered in flat banded tone. Forms are swollen and liquid with rounded bevels, and the metal is described by hard-edged bands of light and dark stepping across each shape rather than by blending. Cool greys lifted by one saturated accent.

*Arrangement: statement. Block `vvs-style-chrome-y2k`.*

### Collage Zine Cutout

> Cut-and-paste zine artwork. Elements are torn or scissor-cut from flat colour and layered slightly out of square, with lettering assembled from mismatched flat letterforms. Rough edges and visible overlap carry the energy.

*Arrangement: collage. Block `vvs-style-collage-zine-cutout`.*

### Collegiate / Varsity Emblem

> Flat screen-printed collegiate artwork in the manner of a varsity chenille patch or an athletics crest. A shield, arch or block monogram anchors the design, with slab or block lettering tiered above and below it and layered offset outlines around each letter. Symmetrical, centred, and built from a small number of flat solid inks.

*Arrangement: emblem. Block `vvs-style-collegiate-emblem`.*

### Editorial Scene

> A single staged scene drawn as one flat illustrated tableau. Every element is built from solid shapes with hard contours and grouped so the situation reads at a glance. Depth comes from overlap and scale, with the whole design sitting on one plane in flat colour.

*Arrangement: scene. Block `vvs-style-editorial-scene`.*

### Editorial Typographic

> Refined typographic artwork in which the words are the image. High-contrast lettering set with generous space around it, supported by a few precise line elements drawn at hairline to medium weight. Held with restraint, in the manner of a fashion label rather than a poster.

*Arrangement: open. Block `vvs-style-editorial-typographic`.*

### Emotional Illustrative

> Warm illustrated artwork in which the drawing itself carries the feeling. Solid shapes are softened by fine interior linework at a lighter weight, so a form reads as tender and sturdy at once. Colour is laid flat throughout and light is drawn as shape rather than blended.

*Arrangement: scene. Block `vvs-style-emotional-illustrative`.*

### Feminine

> Soft-edged artwork built from fine outlined forms. Curves lead and corners run round, with delicate detail drawn at hairline weight against larger open shapes. Colour stays gentle and close in value, lifted by a single warm metallic note.

*Arrangement: open. Block `vvs-style-feminine`.*

### Geometric Abstract

> Artwork constructed from pure geometry — straight runs, repeating angles, true circles and evenly weighted bars. Elements align to one shared grid and meet at consistent angles so the composition reads as a designed system. Every shape is one flat colour with no modelling.

*Arrangement: panel. Block `vvs-style-geometric-abstract`.*

### Hand-Drawn Doodle

> Hand-drawn illustration with visible marker-and-brush character. Lines are confident but imperfect, corners run round, and fills are solid colour laid a little loose against the outline. Handmade and unfussy, drawn by a steady adult hand.

*Arrangement: scene. Block `vvs-style-hand-drawn-doodle`.*

### Luxury Editorial Typography

> Refined fashion-house typography. A short phrase set large in a high-contrast serif with wide letterspacing, held in generous empty space, with a single hairline rule or small mark as the only ornament. Solid ink, no texture and no distressing — the restraint is the design.

*Arrangement: open. Block `vvs-style-luxury-editorial-typography`.*

### Minimal Symbolic

> Reduced symbolic artwork built from the fewest shapes that carry the idea. Forms are flat and geometric with clean even edges, set in generous open space so the silhouette reads at a glance. One restrained accent carries the emphasis while everything else holds a single quiet tone.

*Arrangement: open. Block `vvs-style-minimal-symbolic`.*

### Modern Grunge Halftone

> Contemporary grunge print artwork. Forms are built from coarse halftone dot fields and photocopied texture, with edges breaking up as though reproduced several times over. Heavy condensed type sits hard against the imagery, the whole thing carried in one or two inks.

*Arrangement: statement. Block `vvs-style-modern-grunge-halftone`.*

### Modern Script Statement

> A single fluid modern script carrying the phrase at large scale, drawn with a monoline or lightly swelling stroke and confident open joins. One or two small flat shapes support it. Contemporary hand-lettering rather than period signwriting.

*Arrangement: statement. Block `vvs-style-modern-script-statement`.*

### Neo-Brutalist Grid

> Raw grid-built artwork. Heavy rules divide the area into hard rectangular fields, type is set flush into those fields at sharply contrasting weights, and one field carries a saturated flat colour against plain ground. The structure is left exposed.

*Arrangement: panel. Block `vvs-style-neo-brutalist-grid`.*

### Oversized Condensed Statement

> A single oversized statement filling the print area edge to edge. Letterforms are tall, narrow and tightly stacked across two or three lines, with imagery reduced to one small supporting mark. Scale is the whole design and the margins are deliberately tight.

*Arrangement: statement. Block `vvs-style-oversized-condensed-statement`.*

### Photoreal Composite

> Photographic imagery composited with graphic lettering. The photographic element is cut cleanly to its own silhouette and combined with flat typographic shapes that share its edge quality.

*Arrangement: statement. Block `vvs-style-photoreal-composite`.*

### Retro Comic

> Flat comic-book printed artwork. Heavy black contours of varying weight enclose bold inks filled solid, with a slight offset registration where one ink sits a fraction out of line with another. Bursts, motion marks and speed lines are drawn as solid shapes in their own right.

*Arrangement: scene. Block `vvs-style-retro-comic`.*

### Retro Diner / Comic

> Mid-century roadside advertising artwork crossed with comic-panel energy. Bold rounded shapes carry thick uniform outlines, with motion marks, bursts and small stamped emblems drawn as solid shapes in their own right. Flat spot colours in a limited set.

*Arrangement: scene. Block `vvs-style-retro-diner-comic`.*

### Retro Groovy

> Flat retro-inspired printed artwork. Thick rounded contours, generous curves, and inks laid down as solid areas. Lettering and imagery sit in the same plane and share one outline weight. The shapes carry the period; the ink itself is fresh and fully saturated, as though the shirt has just come off the press.

*Arrangement: emblem. Block `vvs-style-retro-groovy`.*

### Soft Botanical Line Art

> Artwork described almost entirely by a single continuous contour of even weight. Forms are given by outline alone and their interiors are left open to the garment. Curves are unhurried and the line holds one thickness from end to end.

*Arrangement: open. Block `vvs-style-soft-botanical-line-art`.*

### Split-Scene Editorial Illustration

> Artwork divided into two halves that share one composition. A single clean division runs through the design and both sides are drawn in the same flat technique at the same weight, so the contrast is carried by content rather than by styling.

*Arrangement: split. Block `vvs-style-split-scene-editorial-illustration`.*

### Streetwear Graffiti

> Layered screen-print poster artwork. Oversized compressed lettering stacked into blocks, shapes overprinting one another where they meet, and rough torn edges cut from solid ink. Every layer is one flat colour; depth comes from overlap and scale.

*Arrangement: statement. Block `vvs-style-streetwear-graffiti`.*

### Tattoo Linework

> Tattoo-flash linework. Confident black contours of deliberately varied weight describe every form, solid ink carries the accents, and depth is built from dense parallel line. Compositions are symmetrical and self-contained, in the manner of a traditional flash sheet.

*Arrangement: emblem. Block `vvs-style-tattoo-linework`.*

### Urban graffiti

> Wall-painted artwork carried by aerosol technique. Forms are built with wide sprayed strokes and hard stencil edges, with a light overspray halo where the paint meets open ground. Surface wear reads as scattered flecks and broken fill across the solid areas.

*Arrangement: statement. Block `vvs-style-urban-graffiti`.*

### Vintage Badge

> Flat screen-printed emblem artwork in the manner of an old athletic patch or tour shirt. Shapes are solid and hard-edged, arranged with arched banners and centred symmetry. Age is carried in the ink itself — the fill breaks up into fine speckle as though the print has been washed many times.

*Arrangement: emblem. Block `vvs-style-vintage-badge`.*

### Vintage Poster

> Mid-century printed poster artwork. A bold central image built from flat solid shapes in a few inks, with heavy display lettering arched or stacked around it and a plain rule containing the whole. The inks sit as solid areas with a slight overprint where they meet, and carry a faint press texture.

*Arrangement: emblem. Block `vvs-style-vintage-poster`.*

## Arrangements — how it is laid out

New in 097. Chosen by the art style, not by you, so there is no column for it.

### emblem

> The design is built as one self-contained emblem. A central anchor — a figure, symbol, shield or monogram — holds the middle, the phrase is tiered above and below it on arched or straight baselines, and small repeating marks close off the corners of the group. It is symmetrical about a vertical axis, the parts sit tight against one another, and the outer silhouette reads as one deliberate shape.

*Art Deco Editorial, Celestial, Collegiate / Varsity Emblem, Retro Groovy, Tattoo Linework, Vintage Badge, Vintage Poster*

### statement

> The words are the composition. The phrase is set as large as the area allows, stacked across two to four lines whose widths are worked to align with each other, and imagery is reduced to one or two supporting marks tucked into the spaces the lettering leaves. Nothing competes with the type for the eye — the scale is the design.

*Chrome Y2K, Modern Grunge Halftone, Modern Script Statement, Oversized Condensed Statement, Photoreal Composite, Streetwear Graffiti, Urban graffiti*

### scene

> The design stages one moment. Two or more elements are shown acting on each other — a figure and the thing it is reacting to — grouped so the situation reads before any single part of it does, with overlap and relative size carrying the depth. The phrase sits above or below the action as its caption rather than inside it. Motion marks, bursts and small accents are drawn where they carry what is happening.

*Editorial Scene, Emotional Illustrative, Hand-Drawn Doodle, Retro Comic, Retro Diner / Comic*

### panel

> The design is built on an exposed structure. Elements align to one shared system of fields, rules or measured runs, each part sitting in its own compartment at a consistent interval, and the phrase occupies one of those compartments rather than floating across them. The structure is drawn as part of the artwork, not implied.

*Architectural / Blueprint Editorial, Geometric Abstract, Neo-Brutalist Grid*

### open

> The design works with few elements at large scale, and the air between them is deliberate rather than left over. One focal mark and the phrase carry the whole thing, placed so the group still spans most of the print width — open, not small. Nothing is added to fill space, and nothing is drawn so fine that it would be lost at arm's length.

*Bold Minimal, Botanical Editorial Illustration, Editorial Typographic, Feminine, Luxury Editorial Typography, Minimal Symbolic, Soft Botanical Line Art*

### collage

> The design is assembled rather than drawn. Cut elements are layered slightly out of square, each overlapping its neighbour so the stack holds together as one mass, and the phrase is built from pieces sitting at their own angles within it. The edges of the group stay ragged and the overlap is the structure.

*Collage Zine Cutout*

### split

> The design is divided once. A single clean division runs through it and each side carries its own half of the idea at the same weight and scale, so the two read as a pair rather than as a subject and its background. The phrase spans the division or is split across it, and both halves reach the outer edge of the group together.

*Split-Scene Editorial Illustration*

## Lettering styles — letterform technique only

No colour and no objects: `vvs-palette` owns colour, `vvs-flat-ink` owns the fill.

### Big Top Display + playful condensed sans

> The words are set in circus-poster display lettering — tall condensed capitals with heavy slab terminals on an arched or banner-set baseline — paired with a plain condensed sans for the secondary line.

### Block Outline

> The words are set in heavy block capitals described by a contour of even weight, their interiors left open to the garment. Letterforms are square-shouldered and closely spaced, so the run of open counters reads as one continuous band.

### Bold Geometric Sans

> The words are set in capitals built from circles and straight runs at a single heavy weight. Bowls are true circles, joints are clean, counters stay wide and open, and the spacing is tight and even so the geometry is the character.

### Bold Sans

> The words are set in heavy sans capitals at one uniform weight, tight and square with flat terminals. Plain, direct and modern, reading at a distance with no ornament at all.

### Bold Sans + Italic accent

> The words are set in heavy upright sans capitals with a single emphasised word in a steeply sloped italic of the same family. The slope alone carries the emphasis; weight and spacing stay matched across both.

### Bold Sans + Script accent

> The words are set in heavy sans capitals, with one word set instead in a connected script at a larger scale and slight angle. The script crosses in front of the capitals and the two share one ink.

### Bold Sans + Technical accent

> The words are set in heavy sans capitals with small monospaced annotation alongside — tiny widely spaced labels, tick marks and a rule or two at hairline weight. The contrast between the mass and the fine notation is the effect.

### Brush Script

> The words are set in a connected brush script that shows its stroke direction. Strokes swell on the pull and taper at the lift, entry and exit strokes carry the joins, and the baseline rides with a slight natural rhythm.

### Bubble Caps

> The words are set in rounded display capitals with swollen cushioned counters. Strokes hold one uniform thickness and terminals close to soft points, and letters sit close enough to press against one another, held by a single clean contour.

### Bubble Caps + handwritten script accent

> The words are set in rounded cushioned display capitals, with one accent word in loose handwritten script at smaller scale and a jaunty angle. The script sits in the gap the bubble letters leave and shares their ink.

### Distressed Block Caps + Handwritten Strikeout

> The words are set in heavy block capitals whose fill breaks into fine speckle, with one word struck through by a fast handwritten line and a handwritten replacement beside it. The correction is drawn rather than typeset and is part of the design.

### Elegant Serif Display + Geometric Sans

> The words are set in a refined high-contrast serif at large size, with a geometric sans in small widely letterspaced capitals beneath. The serif carries the feeling and the sans carries the information, with generous space between them.

### Hand-Marker

> The words are set in capitals drawn with a chisel marker at speed. Stroke width shifts with the angle of the nib, corners overshoot a little where one stroke crosses another, and the baseline keeps a hand-set irregularity.

### Hand-Marker Script

> The words are set in a connected script drawn with a marker at speed. Stroke width stays near-uniform with slight swelling at the turns, joins are quick and open, and the line keeps the forward lean of handwriting done in one pass.

### High-Constrast Serif + Small Sans

> The words are set in a high-contrast display serif — thin hairlines against heavy stems, sharp unbracketed serifs — at large size, with a small widely letterspaced sans line beneath it. The difference in scale between the two does the work.

### Mixed Caps + Script

> The words are set in two voices: firm upright capitals carry the structural words while a connected script carries one emphasised word at a larger scale and contrasting angle. The script overlaps the capitals where they meet.

### Modern typography

> The words are set as current display typography: a tight high-impact setting with one dominant weight played against a much lighter one, hard left alignment, and generous space above and below. Contemporary and unfussy.

### Retro Display

> The words are set in display lettering with exaggerated proportions — tall shoulders, compressed counters, and swash terminals hooking back into the word. Letters nest tightly together with the character of hand-painted signwriting.

### Sans Display

> The words are set in a contemporary grotesque at large size and tight spacing. Stroke weight stays even, terminals are cut square to the baseline, and the letters sit near-touching so the line reads as a single mass.

### Serif Display + Script

> The words are set in a large display serif with a connected script running across or beneath one word at a contrasting scale. Both are filled solid and share one ink, the script tapering into the serif's counters.

### Serif Editorial

> The words are set in a book-weight serif at display size, with moderate stroke contrast and crisp bracketed serifs. Letterspacing is generous and even and the lines are set tight, carrying the authority of a printed page.

### Soft hand-drawn

> The words are set in gently irregular hand-drawn letterforms with rounded corners and slightly uneven stroke width. Each letter sits a little differently on the baseline, warm and unhurried, held by a calm single-weight contour.

### Soft hand-drawn serif + playful label-maker acents

> The words are set in a gently irregular hand-drawn serif, with small accent words punched as though from a label maker: tight monospaced capitals reversed out of a solid rounded-corner bar. Warm main setting, crisp small counterpoint.

### Sophisticated editorial

> The words are set with editorial restraint: a high-contrast serif for the phrase, one small all-caps sans line as counterpoint with wide letterspacing, and a single hairline rule. Quiet and confident.

### Stencil

> The words are set in stencil capitals with clean bridges interrupting the strokes. Letterforms are square and industrial and the breaks are deliberate and consistent in width, all at one heavy weight.

## Tones — how the idea is delivered

No colour, no type, no arrangement — those belong to other blocks, and a tone
that argued with them would put two instructions in one prompt.

### Accountability

> The design turns the idea back on the reader. The imagery shows the moment of being seen — a mirror, a caught gesture, a thing finally named — and the point is directed inward without scolding.

### Affirming

> The design agrees with the reader. Forms are warm, open and settled, and the idea is put as confirmation of something already so rather than as advice.

### Bold

> The design states its idea at full strength with nothing hedged. One element is unmistakably the loudest and everything else defers to it, and every shape commits — no tentative marks and no apologetic scale.

### Boundaries

> The design shows a limit being kept. The imagery makes the edge visible — a raised palm, a closed door, a step back taken deliberately — and it reads as a calm decision rather than a fight.

### Confident

> The design is at ease with itself. Forms are settled and unhurried, nothing crowds for attention, and the idea is presented as already true rather than argued for.

### Confrontational

> The design faces the reader without softening. It is aimed squarely outward, the sharp part of the idea is the part that gets drawn, and nothing in the imagery lets the point be taken as a joke.

### Direct

> The design makes one statement and stops. A single subject carries it, nothing decorative is added around the point, and the idea reaches the reader in one move.

### Empowering

> The design hands its strength to whoever wears it. Figures and forms are shown upright, open and mid-stride rather than braced, and the idea is addressed outward as something the reader already holds.

### Firm

> The design holds a line and does not negotiate. Forms are squared and immovable with their weight low, and the idea is stated once, without qualification.

### Honest

> The design says the plain thing. The imagery shows the situation as it is, with nothing prettified and nothing left out, and no element softens the claim the words make.

### Humorous

> The design shows the joke happening rather than naming it — a character mid-reaction, a hand caught in the act, the moment one beat before or after the trouble. The picture is funny on its own before the words are read.

### Informative

> The design explains. Its parts can be told apart at a glance and each one earns its place, and the idea is shown to the reader plainly rather than pressed on them.

### Motivational

> The design shows forward movement. Something is rising, reaching or already underway, and the idea arrives as momentum the reader can join rather than as an instruction.

### Positive

> The design is generous and light on its feet. Forms are open and lifting, the imagery shows the good outcome rather than the struggle behind it, and the idea arrives as an offer.

### Proud

> The design carries itself as a declaration. The subject is presented frontally and held high, the arrangement is deliberate and ceremonial, and the idea is worn rather than explained.

### Reflective

> The design is quiet and inward. Nothing is exclaimed, the imagery holds a single held moment, and the idea is offered as something being considered rather than announced.

### Sassy

> The design delivers the idea with a raised eyebrow. One element is played knowingly against another — a sweet shape carrying a sharp remark, a prim arrangement looking entirely unbothered — so the attitude lands before the words are read.

### Supportive

> The design stands beside the reader. Forms are open-handed and steady, the imagery holds rather than pushes, and the idea is offered gently and without condition.

### Truth

> The design puts the uncomfortable part in plain sight. The imagery shows what the words name rather than gesturing at it, and nothing is arranged to make it easier to look at.


---

# Part 3 — main + secondary (migration 099, 2026-10-06)

Two optional sheet columns, read by the importer under these exact headers:
**`Lettering Accent`** and **`Secondary Art Style`**. Blank means none, and the
design is composed exactly as before. A combined lettering name such as
`Bold Sans + Script accent` still works as a main style on its own.

Changed for every design the same day: the phrase block no longer ties the
lettering to the artwork's linework, `vvs-keyline` (stacked outlines) is retired,
and weapons follow the rule *symbols allowed, acts not* — symbolic emblems only on
Bold and Confrontational designs, never Survivorship.

## New main lettering styles

**Big Top Display** — The words are set in circus-poster display lettering — tall condensed capitals with heavy slab terminals on an arched or banner-set baseline.

**Distressed Block Caps** — The words are set in heavy block capitals whose fill breaks into fine speckle and worn gaps, as though printed and washed many times, while every letter stays fully legible.

**High-Contrast Serif** — The words are set in a high-contrast display serif — thin hairlines against heavy stems, sharp unbracketed serifs — at large size with generous, even letterspacing.

**Serif Display** — The words are set in a large display serif with strong bracketed serifs and moderate contrast, set tight and confident so the line reads as one shape.

## Lettering accents (column `Lettering Accent`)

**Brush Script** — Accent lettering: one short word or line of the phrase — never the whole phrase, and spelled exactly as written — is set in a brush script that swells on the pull and tapers at the lift, sweeping across the main lettering. The main lettering carries everything else.

**Condensed Sans** — Accent lettering: one short line of the phrase — never the whole phrase, and spelled exactly as written — is set in a plain, tall condensed sans, compact and upright, as a secondary line. The main lettering carries everything else.

**Hand-Marker** — Accent lettering: one short word or line of the phrase — never the whole phrase, and spelled exactly as written — is drawn fast with a marker, a little irregular, as though added by hand after the main lettering was set. The main lettering carries everything else.

**Handwritten Script** — Accent lettering: one short word or line of the phrase — never the whole phrase, and spelled exactly as written — is set in loose handwritten script, smaller and at a jaunty angle, tucked into a gap the main lettering leaves. The main lettering carries everything else.

**Italic** — Accent lettering: one short word of the phrase, spelled exactly as written, is set in a steeply sloped italic matched to the main lettering's weight, so the slope alone carries the emphasis. The main lettering carries everything else.

**Label-Maker** — Accent lettering: one or two short words of the phrase, spelled exactly as written, are set in tight monospaced capitals reversed out of a solid rounded-corner bar, as though punched from a label maker. The main lettering carries everything else.

**Script** — Accent lettering: one short word or line of the phrase — never the whole phrase, and spelled exactly as written — is set in a connected script at a larger scale and a slight angle, crossing the main lettering. The main lettering carries everything else.

**Small Sans** — Accent lettering: one short line of the phrase — never the whole phrase, and spelled exactly as written — is set in small sans capitals with very wide letterspacing above or beneath the main lettering, a quiet counterpoint to it. The main lettering carries everything else.

**Technical** — Accent lettering: one short word or line of the phrase — never the whole phrase, and spelled exactly as written — is set in small, widely spaced monospaced capitals with a tick mark or hairline rule beside it, like an annotation on a drawing. The main lettering carries everything else.

## Secondary art styles (column `Secondary Art Style`)

Same names as the main art styles. Each adds motifs only; the main style keeps its technique.

**Architectural / Blueprint Editorial** — Secondary influence, blueprint: hairline measure lines, section marks and small numbered callouts annotate the main forms. These are added as detail; the main style keeps its own technique.

**Art Deco Editorial** — Secondary influence, Art Deco: stepped tiers, fanned sunburst repeats and fine parallel rules frame the central forms. These are added as detail; the main style keeps its own technique.

**Bold Minimal** — Secondary influence, bold minimal: one element is reduced to a large, clean geometric silhouette that anchors the rest. The main style keeps its own technique everywhere else.

**Botanical Editorial Illustration** — Secondary influence, botanical: leaves, stems and blooms drawn as clean filled silhouettes with a few interior veins run as a border, arch or sprig. These are added as detail; the main style keeps its own technique.

**Celestial** — Secondary influence, celestial: crescents, small stars and fine radiating lines are set around the main forms with deliberate symmetry. These are added as detail; the main style keeps its own technique.

**Chrome Y2K** — Secondary influence, Y2K chrome: one or two forms are rendered as swollen liquid chrome in hard-edged bands of light and dark, with small four-point sparkle stars. The main style keeps its own technique everywhere else.

**Collage Zine Cutout** — Secondary influence, zine collage: a few elements look torn or scissor-cut and are layered slightly out of square. These are added as detail; the main style keeps its own technique.

**Collegiate / Varsity Emblem** — Secondary influence, varsity: an arched banner, block numerals or a layered offset outline around one key element. These are added as detail; the main style keeps its own technique.

**Editorial Scene** — Secondary influence, editorial scene: a small staged moment — a figure or object caught mid-action — is set within the design. The main style keeps its own technique.

**Editorial Typographic** — Secondary influence, editorial typography: a few precise hairline rules and small refined details are placed around the phrase. These are added as detail; the main style keeps its own technique.

**Emotional Illustrative** — Secondary influence, emotional illustration: a small warm illustrated figure or object, its solid shapes softened by fine interior linework. The main style keeps its own technique everywhere else.

**Feminine** — Secondary influence, feminine: fine hairline flourishes, rounded corners and one warm metallic note. These are added as detail; the main style keeps its own technique.

**Geometric Abstract** — Secondary influence, geometric: a repeating pattern of true circles and angled bars, aligned to one grid, fills a frame or background shape. The main style keeps its own technique everywhere else.

**Hand-Drawn Doodle** — Secondary influence, doodle: small loose marker doodles — stars, arrows, squiggles — gather around the main group. These are added as detail; the main style keeps its own technique.

**Luxury Editorial Typography** — Secondary influence, luxury editorial: one hairline rule, a small refined mark and extra breathing room around the phrase. The main style keeps its own technique.

**Minimal Symbolic** — Secondary influence, minimal symbol: one reduced symbol, built from the fewest shapes that carry the idea, serves as a focal mark. The main style keeps its own technique everywhere else.

**Modern Grunge Halftone** — Secondary influence, grunge halftone: coarse halftone dot fields sit inside a few of the larger shapes, their edges slightly broken. The main style keeps its own technique everywhere else.

**Modern Script Statement** — Secondary influence, modern script: a single fluid swash or underline stroke sweeps through the design. The main style keeps its own technique.

**Neo-Brutalist Grid** — Secondary influence, neo-brutalist: one heavy rule and a hard rectangular field of saturated colour cut through the design. The main style keeps its own technique everywhere else.

**Oversized Condensed Statement** — Secondary influence, oversized: one element is pushed to oversized scale and cropped by the edge of the design. The main style keeps its own technique.

**Photoreal Composite** — Secondary influence, photo composite: one small photographic element is cut cleanly to its own silhouette and set among the drawn forms. The main style keeps its own technique everywhere else.

**Retro Comic** — Secondary influence, comic: action bursts, speed lines and halftone dots drawn as solid shapes. These are added as detail; the main style keeps its own technique.

**Retro Diner / Comic** — Secondary influence, retro diner: small stamped emblems, starbursts and a rounded mid-century sign shape. These are added as detail; the main style keeps its own technique.

**Retro Groovy** — Secondary influence, groovy: wavy bands, a rounded sunburst and soft 70s curves run behind the main forms. These are added as detail; the main style keeps its own technique.

**Soft Botanical Line Art** — Secondary influence, line botanical: a single continuous-line sprig with open interiors curls around the group. This is added as detail; the main style keeps its own technique.

**Split-Scene Editorial Illustration** — Secondary influence, split scene: one clean division splits a key element into two contrasting halves. The main style keeps its own technique.

**Streetwear Graffiti** — Secondary influence, streetwear: torn-edge blocks and overprinted layers sit behind the main group. These are added as detail; the main style keeps its own technique.

**Tattoo Linework** — Secondary influence, tattoo flash: confident black contours of varied weight and dense parallel-line shading on the key forms, with flash motifs such as a rose, a swallow or a banner. The main style keeps its own technique everywhere else.

**Urban graffiti** — Secondary influence, aerosol: overspray halos, drips and scattered paint flecks at the edges of the main shapes. These are added as detail; the main style keeps its own technique.

**Vintage Badge** — Secondary influence, vintage badge: arched banners and fine washed speckle in the fill, as on a well-worn patch. These are added as detail; the main style keeps its own technique.

**Vintage Poster** — Secondary influence, vintage poster: a plain rule frames the whole and a faint press texture shows where inks overlap. These are added as detail; the main style keeps its own technique.


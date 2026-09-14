# Page Template Library

Reusable interior page templates for the Healing Seasons catalog. Every one of the
180 pages in `recovery_coloring_book_tracker.csv` is assigned one of these in
`template_page_assignment_matrix.csv`.

Ten templates, each serving exactly one page type. TPL-09 and TPL-10 were added in
the rebuild to cover outdoor environment pages and decorative pages, which the
original eight-template library had no home for. TPL-07 was renamed to reflect that
party size, not furniture, is what selects it.

## TPL-01 Solo Portrait Calm Scene

- **Serves:** Solo portrait pages
- **Detail load:** Medium
- **Layout:** One focal person centered slightly off-axis, 2-3 supporting props, light background context, open lower corners.
- **Zones:** Top: seasonal cues; Center: face/body focal point; Mid-lower: hands/object; Edges: light framing motifs.
- **White space:** Leave 35-45 percent open colorable space.
- **Notes:** Keep the focal person dominant and the background supportive.

## TPL-02 Support Circle Scene

- **Serves:** Community scene pages
- **Detail load:** Heavy
- **Layout:** 3-5 people in a curved or circular arrangement, one clear focal interaction, simple background geometry. Indoor variant uses simple room geometry; outdoor variant uses trees, park edge, or garden as a low-detail backdrop.
- **Zones:** Top: wall, window, banners, or tree line kept minimal; Center: group interaction; Bottom: chairs, floor, ground, grounding objects.
- **White space:** Keep background under 30 percent detail so figures stay readable.
- **Notes:** No crowd scenes; emotional clarity matters more than realism. Covers indoor meeting rooms and outdoor gatherings, picnics, cookouts, and shared garden work.

## TPL-03 Quote Page Framed Border

- **Serves:** Quote page pages
- **Detail load:** Light
- **Layout:** Short centered quote with wide margins and seasonal border motifs on 2-4 sides.
- **Zones:** Top-third: quote; Outer frame: florals and symbols; Corners: accent clusters; Center whitespace preserved.
- **White space:** Preserve at least 50 percent open space around text.
- **Notes:** Keep the phrase short enough to color around comfortably.

## TPL-04 Healing Room Interior

- **Serves:** Environment page pages
- **Detail load:** Heavy
- **Layout:** One interior room with strong furniture silhouette, layered comfort objects, single anchor light source or window. No people.
- **Zones:** Top: wall art or window; Center: bed, chair, or table anchor; Lower: rug, books, slippers, plants.
- **White space:** Avoid filling every surface with pattern; leave floors and walls partially open.
- **Notes:** Good for quiet pacing between social pages.

## TPL-05 Symbol Cluster Page

- **Serves:** Symbol page pages
- **Detail load:** Medium
- **Layout:** 8-15 related motifs grouped in balanced clusters with breathing room between forms.
- **Zones:** Distributed clusters across the full page with one central anchor motif.
- **White space:** Keep clean separations between motifs for easy coloring.
- **Notes:** Use as a pacing reset page. Motifs shift by season while retaining brand symbols.

## TPL-06 Walking Reflection Scene

- **Serves:** Solo portrait pages
- **Detail load:** Light-Medium
- **Layout:** Single figure outdoors on a path, sidewalk, trail, dock, or shoreline with calm background depth and limited environmental clutter.
- **Zones:** Top: sky, trees, or buildings minimal; Center: figure; Lower: path, leaves, water, flowers, pavement texture.
- **White space:** Keep large sky and path zones open to avoid density.
- **Notes:** Covers walking scenes and static outdoor grounding moments. Great recurring template across all three lines.

## TPL-07 Pair Conversation Scene

- **Serves:** Community scene pages
- **Detail load:** Medium
- **Layout:** Exactly 2-3 figures in close, readable interaction: seated together, standing side by side, or walking together. Anchor is a porch railing, patio edge, park or city bench, kitchen or dining table, shop chair, or shared task.
- **Zones:** Top: plants, string lights, window, or tree line; Center: the two figures and their shared focus; Bottom: floorboards, table, bench, path, or ground.
- **White space:** Keep railing, walls, table, and ground simple enough for color fill.
- **Notes:** Renamed in the rebuild from 'Porch or Patio Conversation'. The defining feature is party size, not furniture: use it for every 2-3 person scene, whether seated, walking, or working side by side.

## TPL-08 Window + Journal Reflection

- **Serves:** Solo portrait pages
- **Detail load:** Medium
- **Layout:** Person seated indoors at a window with a journal, mug, or book; the outside view simplified to weather and one or two shapes; indoor comfort props nearby.
- **Zones:** Top: window frame and weather; Center: seated figure; Lower: blanket, book, mug, plant.
- **White space:** The window view should stay simple and not compete with the figure.
- **Notes:** Reserved for scenes with an actual window or outside view. Indoor comfort scenes with no window go to TPL-01.

## TPL-09 Outdoor Sanctuary

- **Serves:** Environment page pages
- **Detail load:** Heavy
- **Layout:** One outdoor retreat space with a strong built anchor (patio, courtyard, balcony, garden bed) plus plants and seating. No people.
- **Zones:** Top: sky, string lights, pergola, or wall edge; Center: seating or planting anchor; Lower: paving, path, pots, ground plants.
- **White space:** Keep sky, paving, and lawn zones broadly open; do not pattern every surface.
- **Notes:** Added in the rebuild. The outdoor counterpart to TPL-04, which is explicitly an interior template. Covers patios, courtyards, balconies, backyards, and community gardens.

## TPL-10 Decorative Border & Pattern Page

- **Serves:** Decorative page pages
- **Detail load:** Medium
- **Layout:** Seasonal border or repeating pattern frame with 4-8 comfort objects set inside it; flatter and more graphic than a symbol cluster.
- **Zones:** Full-page border or corner frames; Center: object grouping; Background: restrained repeating pattern or open white.
- **White space:** Keep the center open enough to read as a resting page; pattern supports, never fills.
- **Notes:** Added in the rebuild. The Decorative page type appears 12 times in the tracker and had no template defined anywhere. Distinct from TPL-05: TPL-05 is scattered motif clusters, TPL-10 is border and pattern led.

## Library rules

- One page type maps to one template. Never assign a template outside the page
  type it serves — that was the defect in the original assignment matrix.
- Rotate templates within a page type so a book's four solo portraits are not four
  copies of the same layout. Where a template does repeat inside a book, the
  `repeat variant` column in the assignment matrix says how to differentiate it.
- Never place two Heavy pages back to back. Use the `detail load` column when you
  set the final book order.
- Seasonal swaps change props, weather, clothing, and mood. They never change the
  layout logic.
- Every book should mix people pages, space pages, and quote-driven pages.

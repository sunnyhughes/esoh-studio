# Esoh Studio — Scope Note for Claude

**Date:** August 31, 2026
**From:** Sunshine (Esoh Creations LLC)
**Status:** Decision / direction — please read before building the image-tool modules
**Complements (does not replace):** the VV-Styles Design Library & Image Tool Development Notes

---

## The thought

The original plan had **four** development categories for the Esoh Studio image-generation app:

1. Coloring Books
2. VV-Styles (tee shirt graphics)
3. Social Content
4. Print Designs

After reviewing it, I've decided to **drop "Print Designs" and "Social Content" as separate categories.** They are not product lines — they are **output formats / destinations** for an image that already exists.

## Why

A single generated design can be exported to many places: a tee print, a sticker, a poster, a tote, an Instagram story tile, a square post, a reel cover, a listing mockup. If "print" and "social" are built as separate modules, the same artwork gets regenerated multiple times and the app gains two parallel pipelines that do the same job. That is redundant and it was causing development blockage, not flow.

## What to build instead

**Two product lines, each with its own generation pipeline, plus one shared export layer:**

### Product Lines (2)
- **Coloring Books** — own pipeline: line-art coloring pages, seasonal + ethnicity matrix, page types (solo portrait, community scene, quote page, environment page, symbol page, decorative page). Source data: `recovery_coloring_book_tracker`.
- **VV-Styles** — own pipeline: tee shirt graphics, art-style briefs, prompt library, lettering/visual/color direction. Source data: `VV-Styles Designs Library Original (My version)` sheet, `vv-styles-master` tab.

### Output / Destinations layer (1, shared)
Any design from either product line can be exported to one or more destinations:
- Tee Print
- Sticker
- Poster / Apparel
- Social Story (9:16)
- Social Square (1:1)
- Reel Cover
- Listing Mockup

Treat each destination as a **format + resize + repurpose** operation on an existing generated design, not as a new generation.

## What this means for the data model

- A **Design** belongs to one Product Line (Coloring Books or VV-Styles).
- A Design can have many **Destinations / Exports** (tee print, social story, sticker, etc.).
- "Print design" and "social content" become destination records on a design, not standalone entities or modules.
- Social content that is NOT derived from an existing tee design (e.g., a standalone promo quote graphic) still uses the VV-Styles prompt-builder and quote library and is simply created with a social destination — no separate pipeline required.

## Scope boundary for Version 1

Build the two product-line pipelines + the shared destinations/export layer. Do not build separate print or social generation modules. If a feature request implies a third or fourth generation pipeline, flag it before building — the intent is generate-once, export-many.

---
*Note added by Sunshine's direction; the full app spec lives in the VV-Styles Design Library & Image Tool Development Notes doc, which is unchanged.*

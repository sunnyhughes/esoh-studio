import { NextResponse } from "next/server";
import { query } from "@/lib/db";
import { getTemplates } from "@/lib/prompt-engine";

export const dynamic = "force-dynamic";

/** Everything the New Job form needs to render itself. */
export async function GET() {
  try {
    const [categories, collections, templates, items, vocab, letteringStyles] =
      await Promise.all([
        query(`select id, code, label, output_width, output_height, transparent
                 from categories where is_active order by label`),
        query(`select id, category_id, name, slug from collections
                where status = 'active' order by name`),
        getTemplates(),
        // The planned queue (D39). The form needs enough of each row to show
        // what the item will contribute before anything is generated.
        query(`select id, collection_id, category_id, ref, title, page_type,
                      art_style, background_density, season, ethnicity_line,
                      hair, facial_hair, brief, visual_elements, brand_mark,
                      quote_text, lettering_style, status
                 from items order by ref`),
        // Art style and density come from the blocks that implement them, so
        // adding a style in SQL adds it to the form with no code change.
        query(`select
                 coalesce(
                   array_agg(distinct art_style)
                     filter (where art_style is not null), '{}') as art_styles,
                 coalesce(
                   array_agg(distinct background_density)
                     filter (where background_density is not null),
                   '{}') as densities
                 from prompt_blocks where is_active`),
        query(`select lettering_style, family from lettering_faces
                 order by lettering_style`),
      ]);

    return NextResponse.json({
      data: {
        categories,
        collections,
        templates,
        items,
        artStyles: (vocab[0] as { art_styles: string[] })?.art_styles ?? [],
        densities: (vocab[0] as { densities: string[] })?.densities ?? [],
        letteringStyles,
      },
    });
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    return NextResponse.json({ error: message }, { status: 500 });
  }
}

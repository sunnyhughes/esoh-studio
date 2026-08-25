import { NextResponse } from "next/server";
import { query } from "@/lib/db";

export const dynamic = "force-dynamic";

/**
 * Every book, with how much of it exists.
 *
 * The readiness count is worked out in SQL rather than by planning each book in
 * turn: the list is only ever a way in, and the per-page detail belongs to
 * `/api/books/<id>?format=json`. The two must agree on what "ready" means —
 * a page counts when it has an asset, and a Quote page counts only once that
 * asset carries lettering.
 */
export async function GET() {
  try {
    const books = await query(
      `select c.id, c.name, c.series, c.slug,
              count(i.id)::int as total,
              count(*) filter (
                where exists (
                  select 1 from generated_assets a
                   where a.item_id = i.id
                     and (i.page_type <> 'Quote page'
                          or (a.metadata_json -> 'overlay') is not null)
                )
              )::int as ready
         from collections c
         join items i on i.collection_id = c.id
        group by c.id, c.name, c.series, c.slug
       having count(i.id) > 0
        order by c.series nulls last, c.name`
    );

    return NextResponse.json({ books });
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    return NextResponse.json({ error: message }, { status: 500 });
  }
}

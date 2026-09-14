import { NextResponse } from "next/server";
import { query } from "@/lib/db";

export const dynamic = "force-dynamic";

/**
 * Every book, with how much of it exists.
 *
 * The readiness count comes from the `page_readiness` view, which is also what
 * `lib/book.ts` plans from. It used to be written twice — once here in SQL and
 * once there in TypeScript — with a comment insisting the two must agree. They
 * stopped agreeing the moment 063 added the production gates, and the list went
 * on reporting pages ready that the plan refused to print (064).
 */
export async function GET() {
  try {
    const books = await query(
      `select c.id, c.name, c.series, c.slug,
              count(p.item_id)::int as total,
              count(*) filter (where p.blocked is null)::int as ready
         from collections c
         join page_readiness p on p.collection_id = c.id
        group by c.id, c.name, c.series, c.slug
       having count(p.item_id) > 0
        order by c.series nulls last, c.name`
    );

    return NextResponse.json({ books });
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    return NextResponse.json({ error: message }, { status: 500 });
  }
}

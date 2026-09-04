import { NextResponse } from "next/server";
import { query } from "@/lib/db";

export const dynamic = "force-dynamic";

/**
 * Recent assets, newest first.
 *
 * Deliberately small: the results grid only ever held what the current session
 * generated, which left every earlier page unreachable from the app — and with
 * it the print export, since that is reached from a card. This is the least
 * that makes the studio's own output openable again. Filtering across category,
 * collection, page type, status and priority is the Stage D library and is not
 * this.
 */
export async function GET(req: Request) {
  try {
    const q = new URL(req.url).searchParams;
    const limit = Math.min(Math.max(Number(q.get("limit") ?? 12), 1), 60);

    const assets = await query(
      `select a.id, a.asset_name, a.storage_path, a.status, a.is_favorite,
              i.page_type, i.quote_text, i.lettering_style,
              (a.metadata_json -> 'overlay') is not null as is_lettering,
              -- D101: a failed knockout has to survive a page reload, not just
              -- appear on the card that generated it.
              a.metadata_json -> 'transparency' as transparency
         from generated_assets a
    left join items i on i.id = a.item_id
        order by a.created_at desc
        limit $1`,
      [limit]
    );

    return NextResponse.json({ assets });
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    return NextResponse.json({ error: message }, { status: 500 });
  }
}

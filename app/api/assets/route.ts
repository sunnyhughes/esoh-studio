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
      `select id, asset_name, storage_path, status, is_favorite
         from generated_assets
        order by created_at desc
        limit $1`,
      [limit]
    );

    return NextResponse.json({ assets });
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    return NextResponse.json({ error: message }, { status: 500 });
  }
}

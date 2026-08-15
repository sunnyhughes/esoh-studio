import { NextResponse } from "next/server";
import { query } from "@/lib/db";
import { getTemplates } from "@/lib/prompt-engine";

export const dynamic = "force-dynamic";

/** Everything the New Job form needs to render itself. */
export async function GET() {
  try {
    const [brands, projects, templates] = await Promise.all([
      query(`select id, slug, name from brands where is_active order by name`),
      query(`select id, brand_id, name, slug from projects
              where status = 'active' order by name`),
      getTemplates(),
    ]);

    return NextResponse.json({ brands, projects, templates });
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    return NextResponse.json({ error: message }, { status: 500 });
  }
}

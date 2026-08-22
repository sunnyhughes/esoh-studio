import { NextResponse } from "next/server";
import { query } from "@/lib/db";
import { getTemplates } from "@/lib/prompt-engine";

export const dynamic = "force-dynamic";

/** Everything the New Job form needs to render itself. */
export async function GET() {
  try {
    const [categories, collections, templates] = await Promise.all([
      query(`select id, code, label, output_width, output_height, transparent
               from categories where is_active order by label`),
      query(`select id, category_id, name, slug from collections
              where status = 'active' order by name`),
      getTemplates(),
    ]);

    return NextResponse.json({ data: { categories, collections, templates } });
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    return NextResponse.json({ error: message }, { status: 500 });
  }
}

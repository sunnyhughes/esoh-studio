import { NextResponse } from "next/server";
import { one, query } from "@/lib/db";

export const dynamic = "force-dynamic";

const FROM = `
     from generated_assets a
left join items i on i.id = a.item_id
left join categories c on c.id = a.category_id
left join collections col on col.id = a.collection_id`;

/** Collects `where` fragments and their parameters, numbering as it goes. */
function conditions() {
  // 030 keeps the record after the file is deleted, and a card whose image
  // 404s is worse than no card.
  const sql: string[] = ["a.purged_at is null"];
  const params: unknown[] = [];
  return {
    sql,
    params,
    add(template: string, value: string | null | undefined) {
      if (!value) return;
      params.push(value);
      sql.push(template.replace("$?", `$${params.length}`));
    },
    flag(expr: string, on: boolean) {
      if (on) sql.push(expr);
    },
    clause() {
      return `where ${sql.join(" and ")}`;
    },
  };
}

/**
 * The asset library.
 *
 * This began as "the twelve most recent, newest first" — the least that made
 * earlier pages openable again after the results grid only ever held the
 * current session's work. It is now filterable, because 39 approved pages
 * existed with no way to look at them as a set, and judging whether the style
 * has drifted means seeing the accepted ones side by side and in order (D128).
 *
 * Full Stage D is filters across category, collection, item, page type, status
 * and priority, with the item queue browsable in its own right. This is the
 * asset half of it and nothing more.
 */
export async function GET(req: Request) {
  try {
    const q = new URL(req.url).searchParams;
    const limit = Math.min(Math.max(Number(q.get("limit") ?? 12), 1), 240);
    const offset = Math.max(Number(q.get("offset") ?? 0), 0);
    // Oldest-first is what answers "has this got better or worse", so it is
    // offered rather than assumed — the results grid still wants newest first.
    const oldest = q.get("order") === "oldest";

    /**
     * Two filter sets, built separately rather than one edited down. The status
     * tallies deliberately ignore the status filter — otherwise choosing
     * "Approved" would report every other tab as empty — and removing a clause
     * from a finished list means renumbering its parameters, which is a bug
     * waiting to be written.
     */
    const build = (withStatus: boolean) => {
      const c = conditions();
      if (withStatus) c.add("a.status = $?", q.get("status"));
      c.add("c.code = $?", q.get("category"));
      c.add("i.page_type = $?", q.get("pageType"));
      c.add("i.season = $?", q.get("season"));
      c.add("i.ethnicity_line = $?", q.get("line"));
      c.flag("a.is_favorite", q.get("favorite") === "1");
      return c;
    };

    const filtered = build(true);
    const facets = build(false);

    const assets = await query(
      `select a.id, a.asset_name, a.storage_path, a.status, a.is_favorite,
              a.created_at,
              i.page_type, i.quote_text, i.lettering_style,
              i.ref, i.season, i.ethnicity_line,
              i.art_style, i.background_density,
              c.code as category_code, col.name as collection_name,
              (a.metadata_json -> 'overlay') is not null as is_lettering,
              -- D101: a failed knockout has to survive a page reload, not just
              -- appear on the card that generated it.
              a.metadata_json -> 'transparency' as transparency
              ${FROM}
              ${filtered.clause()}
        order by a.created_at ${oldest ? "asc" : "desc"}
        limit $${filtered.params.length + 1}
       offset $${filtered.params.length + 2}`,
      [...filtered.params, limit, offset]
    );

    // The count is what says the filter has more behind it than the page on
    // screen, so it is measured against the same filter.
    const total = await one<{ n: string }>(
      `select count(*)::text as n ${FROM} ${filtered.clause()}`,
      filtered.params
    );

    const counts = await query<{ status: string; n: string }>(
      `select a.status, count(*)::text as n ${FROM} ${facets.clause()}
        group by a.status`,
      facets.params
    );

    return NextResponse.json({
      assets,
      total: Number(total?.n ?? 0),
      counts: Object.fromEntries(counts.map((r) => [r.status, Number(r.n)])),
    });
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    return NextResponse.json({ error: message }, { status: 500 });
  }
}

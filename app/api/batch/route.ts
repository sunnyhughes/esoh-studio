import { NextResponse } from "next/server";
import { query } from "@/lib/db";
import {
  createRun,
  planRows,
  estimatePlan,
  type BatchFilter,
  type BatchSettings,
} from "@/lib/batch";

export const dynamic = "force-dynamic";

/**
 * `GET /api/batch` — the runs, newest first.
 * `GET /api/batch?preview=1&categoryId=…&season=…` — what a filter would do,
 * costed, before anything is created. The preview is the point: a season is
 * fifteen pages and roughly four dollars, and that is worth knowing while it
 * is still a question.
 */
export async function GET(req: Request) {
  try {
    const q = new URL(req.url).searchParams;

    if (q.get("preview") === "1") {
      const categoryId = q.get("categoryId");
      if (!categoryId) {
        return NextResponse.json(
          { error: "categoryId is required to preview a run." },
          { status: 400 }
        );
      }
      const filter: BatchFilter = {
        collectionId: q.get("collectionId") ?? undefined,
        season: q.get("season") ?? undefined,
        pageType: q.get("pageType") ?? undefined,
        priority: q.get("priority") ?? undefined,
        line: q.get("line") ?? undefined,
        skipWithArt: q.get("skipWithArt") === "1",
      };
      const settings: BatchSettings = {
        size: q.get("size") ?? undefined,
        quality: q.get("quality") ?? undefined,
        n: q.get("n") ? Number(q.get("n")) : undefined,
      };
      const rows = await planRows(categoryId, filter);
      return NextResponse.json({ rows, estimate: estimatePlan(rows, settings) });
    }

    const runs = await query(
      `select r.id, r.name, r.status, r.created_at, r.finished_at,
              r.max_spend_usd,
              count(b.*)::int as total,
              count(*) filter (where b.status = 'done')::int as done,
              count(*) filter (where b.status = 'failed')::int as failed,
              count(*) filter (where b.status = 'skipped')::int as skipped,
              coalesce(sum(j.cost_usd), 0)::float8 as spent_usd
         from batch_runs r
    left join batch_items b on b.run_id = r.id
    left join generation_jobs j on j.id = b.generation_job_id
        group by r.id
        order by r.created_at desc
        limit 30`
    );
    return NextResponse.json({ runs });
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    return NextResponse.json({ error: message }, { status: 500 });
  }
}

/** Plan a run. Creating one does not start it — `PATCH` does. */
export async function POST(req: Request) {
  try {
    const body = (await req.json()) as {
      name?: string;
      categoryId?: string;
      filter?: BatchFilter;
      settings?: BatchSettings;
      maxSpendUsd?: number | null;
    };

    if (!body.categoryId) {
      return NextResponse.json(
        { error: "categoryId is required." },
        { status: 400 }
      );
    }

    const created = await createRun({
      name: body.name?.trim() || "Untitled run",
      categoryId: body.categoryId,
      filter: body.filter ?? {},
      settings: body.settings ?? {},
      maxSpendUsd: body.maxSpendUsd ?? null,
    });

    return NextResponse.json(created);
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    return NextResponse.json({ error: message }, { status: 400 });
  }
}

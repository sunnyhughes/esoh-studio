import { NextResponse } from "next/server";
import { one, query } from "@/lib/db";
import { progress } from "@/lib/batch";

export const dynamic = "force-dynamic";

const MOVES = ["running", "paused", "cancelled"];

/** The run, its pages, and whatever art they have produced so far. */
export async function GET(
  _req: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    const p = await progress(id);
    if (!p) return NextResponse.json({ error: "No such run." }, { status: 404 });

    // The results come back with the run rather than from the library, because
    // reviewing a run means looking at what this run made, in the order it was
    // asked for — §7's "review queue for the results".
    const rows = await query(
      `select b.id, b.position, b.status, b.error_message, b.attempts,
              i.ref, i.title, i.page_type, i.season, i.priority,
              j.cost_usd::float8 as cost_usd,
              coalesce(
                (select json_agg(json_build_object(
                          'id', g.id,
                          'asset_name', g.asset_name,
                          'storage_path', g.storage_path,
                          'status', g.status)
                        order by g.source_variant_index)
                   from generated_assets g
                  where g.generation_job_id = b.generation_job_id
                    and g.purged_at is null),
                '[]'::json) as assets
         from batch_items b
         join items i on i.id = b.item_id
    left join generation_jobs j on j.id = b.generation_job_id
        where b.run_id = $1
        order by b.position`,
      [id]
    );

    return NextResponse.json({ run: p, rows });
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    return NextResponse.json({ error: message }, { status: 500 });
  }
}

/** Start, pause or abandon a run. */
export async function PATCH(
  req: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    const body = (await req.json()) as {
      status?: string;
      maxSpendUsd?: number | null;
      /** Put failed pages back in the queue before resuming. */
      retryFailed?: boolean;
    };

    if (body.status && !MOVES.includes(body.status)) {
      return NextResponse.json(
        { error: `status must be one of: ${MOVES.join(", ")}` },
        { status: 400 }
      );
    }

    // The common case this exists for: the account ran dry, the run paused on
    // the page that hit the wall, and the credits are now topped up. Without
    // this the failed page is stranded — only `queued` rows are ever claimed —
    // and resuming would quietly skip it.
    if (body.retryFailed) {
      await query(
        `update batch_items
            set status = 'queued', error_message = null
          where run_id = $1 and status = 'failed'`,
        [id]
      );
    }

    const run = await one<{ id: string }>(
      `update batch_runs
          set status = coalesce($2, status),
              max_spend_usd = case when $4 then $3::numeric else max_spend_usd end,
              started_at = case
                when $2 = 'running' and started_at is null then now()
                else started_at end,
              finished_at = case
                when $2 = 'cancelled' then now() else finished_at end
        where id = $1
      returning id`,
      [
        id,
        body.status ?? null,
        body.maxSpendUsd ?? null,
        // A ceiling has to be removable, so "was it sent" is asked separately
        // from "what was it" — otherwise null could only ever mean "unchanged".
        Object.prototype.hasOwnProperty.call(body, "maxSpendUsd"),
      ]
    );

    if (!run) return NextResponse.json({ error: "No such run." }, { status: 404 });
    return NextResponse.json({ run: await progress(id) });
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    return NextResponse.json({ error: message }, { status: 500 });
  }
}

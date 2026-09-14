import { one, query } from "@/lib/db";
import { estimateCostUsd } from "@/lib/pricing";
import { OPENAI_DEFAULT_MODEL } from "@/lib/providers/openai";
import { runGeneration, GenerationRefused } from "@/lib/generate";

/**
 * Stage E — generating a whole collection without sitting over it.
 *
 * The design decision worth stating is that a run is **expanded and frozen when
 * it is planned**, not discovered as it goes. The list of pages, the template
 * each one will use, and the rows that cannot run at all are all settled before
 * the first call to the provider, so the question "what is this about to cost
 * me" has an answer while it is still worth asking.
 *
 * Work is then claimed one row at a time. One unit of work is one image call,
 * which keeps every request short, makes the run resumable after a reload or a
 * crash, and means a failure costs one page rather than a season.
 */

export type BatchFilter = {
  collectionId?: string;
  season?: string;
  pageType?: string;
  priority?: string;
  line?: string;
  /** Leave out pages that already have art kept against them. */
  skipWithArt?: boolean;
};

export type BatchSettings = {
  size?: string;
  quality?: string;
  n?: number;
  useReferences?: boolean;
};

export type PlannedRow = {
  item_id: string;
  ref: string;
  title: string;
  page_type: string | null;
  priority: string | null;
  season: string | null;
  template_id: string | null;
  template_name: string | null;
  skip_reason: string | null;
};

const DEFAULTS: Required<Pick<BatchSettings, "size" | "quality" | "n">> = {
  size: "1024x1536",
  quality: "medium",
  n: 2,
};

/**
 * The rows a filter selects, each already matched to the template that will
 * draw it — or to the reason it cannot be drawn.
 *
 * Each page names its own template (058, 059, 060). Matching on `page_type`
 * stopped being possible the moment there were ten templates instead of six:
 * three of them serve Solo portrait and two serve Community scene, so a join on
 * page type would plan every solo page three times and pay for it three times.
 *
 * The page-type check survives as a *reason*, not as the join. If an item's
 * assigned template draws a different kind of page, that row is skipped with
 * the mismatch named — D56's guard, moved to where a run can read it before
 * spending rather than one page at a time in the middle of one.
 */
export async function planRows(
  categoryId: string,
  filter: BatchFilter
): Promise<PlannedRow[]> {
  const where: string[] = ["i.category_id = $1"];
  const params: unknown[] = [categoryId];
  const add = (sql: string, value?: string) => {
    if (!value) return;
    params.push(value);
    where.push(sql.replace("$?", `$${params.length}`));
  };

  add("i.collection_id = $?", filter.collectionId);
  add("i.season = $?", filter.season);
  add("i.page_type = $?", filter.pageType);
  add("i.priority = $?", filter.priority);
  add("i.ethnicity_line = $?", filter.line);

  if (filter.skipWithArt) {
    where.push(`not exists (
      select 1 from generated_assets g
       where g.item_id = i.id and g.purged_at is null and g.status = 'approved')`);
  }

  return query<PlannedRow>(
    `select i.id as item_id, i.ref, i.title, i.page_type, i.priority, i.season,
            t.id as template_id, t.name as template_name,
            case
              when i.page_type is null
                then 'This page has no page type, so no template claims it.'
              when t.id is null
                then 'No active template is assigned to this page.'
              when t.page_type is distinct from i.page_type
                then 'Assigned ' || t.name || ', which draws ' ||
                     coalesce(t.page_type, 'nothing') || ' pages.'
              else null
            end as skip_reason
       from items i
  left join prompt_templates t
         on t.id = i.prompt_template_id
        and t.is_active
      where ${where.join(" and ")}
      order by i.ref`,
    params
  );
}

/** What the plan will cost if every runnable row succeeds first time. */
export function estimatePlan(rows: PlannedRow[], settings: BatchSettings) {
  const size = settings.size ?? DEFAULTS.size;
  const quality = settings.quality ?? DEFAULTS.quality;
  const n = settings.n ?? DEFAULTS.n;
  const runnable = rows.filter((r) => !r.skip_reason).length;
  const per = estimateCostUsd(OPENAI_DEFAULT_MODEL, size, quality, n) ?? 0;
  return {
    runnable,
    skipped: rows.length - runnable,
    images: runnable * n,
    perPageUsd: per,
    totalUsd: Number((per * runnable).toFixed(4)),
  };
}

export async function createRun(input: {
  name: string;
  categoryId: string;
  filter: BatchFilter;
  settings: BatchSettings;
  maxSpendUsd?: number | null;
}) {
  const rows = await planRows(input.categoryId, input.filter);
  if (rows.length === 0) {
    throw new Error("Nothing matches that filter — there is no run to make.");
  }

  const run = await one<{ id: string }>(
    `insert into batch_runs (name, category_id, filter_json, settings_json,
                             max_spend_usd)
     values ($1,$2,$3,$4,$5) returning id`,
    [
      input.name,
      input.categoryId,
      JSON.stringify(input.filter),
      JSON.stringify(input.settings),
      input.maxSpendUsd ?? null,
    ]
  );
  const runId = run!.id;

  // Expanded and frozen here. A row that cannot run is written down as skipped
  // with its reason rather than left out, so the plan accounts for every page
  // the filter selected.
  for (const [position, row] of rows.entries()) {
    await query(
      `insert into batch_items (run_id, item_id, template_id, position, status,
                                error_message)
       values ($1,$2,$3,$4,$5,$6)`,
      [
        runId,
        row.item_id,
        row.template_id,
        position,
        row.skip_reason ? "skipped" : "queued",
        row.skip_reason,
      ]
    );
  }

  return { runId, rows, estimate: estimatePlan(rows, input.settings) };
}

export type RunProgress = {
  id: string;
  name: string;
  status: string;
  counts: Record<string, number>;
  total: number;
  spentUsd: number;
  maxSpendUsd: number | null;
};

export async function progress(runId: string): Promise<RunProgress | null> {
  const run = await one<{
    id: string;
    name: string;
    status: string;
    max_spend_usd: string | null;
  }>(`select id, name, status, max_spend_usd from batch_runs where id = $1`, [
    runId,
  ]);
  if (!run) return null;

  const counts = await query<{ status: string; n: string }>(
    `select status, count(*)::text as n from batch_items
      where run_id = $1 group by status`,
    [runId]
  );

  const spent = await one<{ usd: string }>(
    `select coalesce(sum(j.cost_usd), 0)::text as usd
       from batch_items b
       join generation_jobs j on j.id = b.generation_job_id
      where b.run_id = $1`,
    [runId]
  );

  const byStatus = Object.fromEntries(
    counts.map((c) => [c.status, Number(c.n)])
  );
  return {
    id: run.id,
    name: run.name,
    status: run.status,
    counts: byStatus,
    total: Object.values(byStatus).reduce((a, b) => a + b, 0),
    spentUsd: Number(spent?.usd ?? 0),
    maxSpendUsd: run.max_spend_usd === null ? null : Number(run.max_spend_usd),
  };
}

export type TickResult = {
  progress: RunProgress;
  /** True when there is no more work to claim. */
  finished: boolean;
  /** The row just attempted, if one was. */
  did?: { ref: string; status: string; message?: string };
  /** Why the run stopped, when it stopped for a reason. */
  halted?: string;
};

/**
 * Do one page.
 *
 * Deliberately one: a tick is a single image call, so no request runs long
 * enough to be cut off, an interrupted run resumes exactly where it stopped,
 * and a caller that goes away — a closed tab — stops the spending rather than
 * leaving something running that nobody is watching.
 */
export async function tick(runId: string): Promise<TickResult> {
  const before = await progress(runId);
  if (!before) throw new Error("No such run.");

  if (before.status !== "running") {
    return { progress: before, finished: true, halted: `Run is ${before.status}.` };
  }

  // The ceiling is checked before claiming, not after spending. The account
  // ran dry mid-session once with no warning; a run that spends unattended
  // stops itself.
  if (before.maxSpendUsd !== null && before.spentUsd >= before.maxSpendUsd) {
    await query(`update batch_runs set status = 'paused' where id = $1`, [runId]);
    return {
      progress: { ...before, status: "paused" },
      finished: true,
      halted:
        `Paused: $${before.spentUsd.toFixed(2)} spent against a ` +
        `$${before.maxSpendUsd.toFixed(2)} ceiling. Raise it to continue.`,
    };
  }

  // `skip locked` so two tickers can never claim the same page. A page
  // generated twice is a page paid for twice.
  const claimed = await one<{
    id: string;
    item_id: string;
    template_id: string | null;
    ref: string;
  }>(
    `update batch_items b
        set status = 'running', attempts = b.attempts + 1
      where b.id = (
        select c.id from batch_items c
         where c.run_id = $1 and c.status = 'queued'
         order by c.position
         limit 1
         for update skip locked)
    returning b.id, b.item_id, b.template_id,
              (select ref from items where id = b.item_id) as ref`,
    [runId]
  );

  if (!claimed) {
    await query(
      `update batch_runs set status = 'done', finished_at = now()
        where id = $1 and status = 'running'`,
      [runId]
    );
    const after = await progress(runId);
    return { progress: after!, finished: true };
  }

  const settings = await one<{ settings_json: BatchSettings }>(
    `select settings_json from batch_runs where id = $1`,
    [runId]
  );
  const s = settings?.settings_json ?? {};

  try {
    const result = await runGeneration({
      templateId: claimed.template_id!,
      itemId: claimed.item_id,
      useReferences: s.useReferences ?? true,
      size: s.size ?? DEFAULTS.size,
      quality: s.quality ?? DEFAULTS.quality,
      n: s.n ?? DEFAULTS.n,
      inputs: {},
    });

    await query(
      `update batch_items
          set status = 'done', generation_job_id = $2, error_message = null
        where id = $1`,
      [claimed.id, result.jobId]
    );

    return {
      progress: (await progress(runId))!,
      finished: false,
      did: { ref: claimed.ref, status: "done" },
    };
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);

    // A refusal is the page being wrong and will be wrong again on every
    // retry, so it is set aside rather than counted as a failure. Anything
    // else — a provider error, an empty account — is a failure, and the run
    // pauses rather than marching through the rest of the season repeating it.
    const refused = err instanceof GenerationRefused;
    await query(
      `update batch_items set status = $2, error_message = $3 where id = $1`,
      [claimed.id, refused ? "skipped" : "failed", message]
    );

    if (!refused) {
      await query(
        `update batch_runs set status = 'paused' where id = $1 and status = 'running'`,
        [runId]
      );
    }

    return {
      progress: (await progress(runId))!,
      finished: !refused,
      did: {
        ref: claimed.ref,
        status: refused ? "skipped" : "failed",
        message,
      },
      halted: refused ? undefined : `Paused after a failure on ${claimed.ref}.`,
    };
  }
}

"use client";

import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import type { Facets } from "./library-panel";

/**
 * Stage E — a season in one action.
 *
 * The shape of this panel follows the shape of the risk. Generating 27 pages
 * costs real money against a metered account that has already run dry once, so
 * nothing is created until the plan has been costed, nothing starts until it is
 * started, and the run stops itself on a ceiling or on the first real failure
 * rather than repeating it 26 more times.
 *
 * Ticking is driven from here, one page per request. That is what makes the run
 * resumable and what makes closing the tab a brake rather than a runaway.
 */

type Collection = { id: string; category_id: string; name: string };

type Row = {
  id: string;
  position: number;
  status: string;
  error_message: string | null;
  attempts: number;
  ref: string;
  page_type: string | null;
  season: string | null;
  priority: string | null;
  cost_usd: number | null;
  assets: {
    id: string;
    asset_name: string;
    storage_path: string;
    status: string;
  }[];
};

type Progress = {
  id: string;
  name: string;
  status: string;
  counts: Record<string, number>;
  total: number;
  spentUsd: number;
  maxSpendUsd: number | null;
};

type PreviewRow = {
  item_id: string;
  ref: string;
  page_type: string | null;
  template_name: string | null;
  skip_reason: string | null;
};

type Estimate = {
  runnable: number;
  skipped: number;
  images: number;
  perPageUsd: number;
  totalUsd: number;
};

type RunSummary = {
  id: string;
  name: string;
  status: string;
  created_at: string;
  total: number;
  done: number;
  failed: number;
  skipped: number;
  spent_usd: number;
};

export default function BatchPanel({
  categories,
  collections,
  facets,
  onClose,
}: {
  categories: { id: string; code: string; label: string }[];
  collections: Collection[];
  facets: Facets;
  onClose: () => void;
}) {
  const coloring = categories.find((c) => c.code === "coloring-books");
  const [categoryId, setCategoryId] = useState(coloring?.id ?? categories[0]?.id ?? "");
  const [collectionId, setCollectionId] = useState("");
  const [season, setSeason] = useState("");
  const [pageType, setPageType] = useState("");
  const [priority, setPriority] = useState("");
  const [line, setLine] = useState("");
  const [skipWithArt, setSkipWithArt] = useState(true);

  const [quality, setQuality] = useState("medium");
  const [n, setN] = useState(2);
  const [useReferences, setUseReferences] = useState(true);
  const [cap, setCap] = useState("5.00");

  const [preview, setPreview] = useState<{ rows: PreviewRow[]; estimate: Estimate } | null>(null);
  const [runs, setRuns] = useState<RunSummary[]>([]);
  const [runId, setRunId] = useState<string | null>(null);
  const [run, setRun] = useState<Progress | null>(null);
  const [rows, setRows] = useState<Row[]>([]);
  const [doing, setDoing] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  /** Stops a tick loop that outlives the panel, a pause, or a new run. */
  const ticking = useRef(false);
  /**
   * Mirrors the ref for rendering. A run is `running` in the database for as
   * long as it has not been paused, which is not the same as something
   * actually ticking it — close the tab mid-run and the row still says
   * running while nothing at all is happening. Without this the panel offers
   * no way to pick that run back up.
   */
  const [draining, setDraining] = useState(false);

  useEffect(() => {
    const esc = (e: KeyboardEvent) => e.key === "Escape" && onClose();
    window.addEventListener("keydown", esc);
    return () => window.removeEventListener("keydown", esc);
  }, [onClose]);

  const loadRuns = useCallback(() => {
    fetch("/api/batch")
      .then((r) => r.json())
      .then((d) => !d.error && setRuns(d.runs))
      .catch(() => {});
  }, []);

  useEffect(() => {
    loadRuns();
  }, [loadRuns]);

  // The estimate follows the filters, so the cost of an idea is visible while
  // it is still an idea.
  const previewQs = useMemo(() => {
    if (!categoryId) return null;
    const p = new URLSearchParams({ preview: "1", categoryId, quality, n: String(n) });
    if (collectionId) p.set("collectionId", collectionId);
    if (season) p.set("season", season);
    if (pageType) p.set("pageType", pageType);
    if (priority) p.set("priority", priority);
    if (line) p.set("line", line);
    if (skipWithArt) p.set("skipWithArt", "1");
    return p.toString();
  }, [categoryId, collectionId, season, pageType, priority, line, skipWithArt, quality, n]);

  useEffect(() => {
    if (!previewQs || runId) return;
    let live = true;
    fetch(`/api/batch?${previewQs}`)
      .then((r) => r.json())
      .then((d) => live && !d.error && setPreview(d))
      .catch(() => {});
    return () => {
      live = false;
    };
  }, [previewQs, runId]);

  const loadRun = useCallback(async (id: string) => {
    const d = await fetch(`/api/batch/${id}`).then((r) => r.json());
    if (d.error) return setError(d.error);
    setRun(d.run);
    setRows(d.rows);
    return d.run as Progress;
  }, []);

  /**
   * One page per request, in a loop, until the run says stop. The loop asks the
   * server what happened rather than assuming, so a ceiling, a failure or a
   * pause from another tab all end it the same way.
   */
  const drain = useCallback(
    async (id: string) => {
      if (ticking.current) return;
      ticking.current = true;
      setDraining(true);
      try {
        for (;;) {
          if (!ticking.current) break;
          const t = await fetch(`/api/batch/${id}/tick`, { method: "POST" }).then((r) =>
            r.json()
          );
          if (t.error) {
            setError(t.error);
            break;
          }
          setRun(t.progress);
          setDoing(t.did ? `${t.did.ref} — ${t.did.status}` : null);
          await loadRun(id);
          if (t.halted) setError(t.halted);
          if (t.finished) break;
        }
      } finally {
        ticking.current = false;
        setDraining(false);
        setDoing(null);
        loadRuns();
      }
    },
    [loadRun, loadRuns]
  );

  useEffect(() => {
    // Leaving the panel stops the spending. Deliberate.
    return () => {
      ticking.current = false;
      setDraining(false);
    };
  }, []);

  async function plan() {
    setBusy(true);
    setError(null);
    try {
      const res = await fetch("/api/batch", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          name: runName(),
          categoryId,
          filter: { collectionId, season, pageType, priority, line, skipWithArt },
          settings: { quality, n, useReferences },
          maxSpendUsd: cap.trim() === "" ? null : Number(cap),
        }),
      });
      const d = await res.json();
      if (d.error) throw new Error(d.error);
      setRunId(d.runId);
      await loadRun(d.runId);
      loadRuns();
    } catch (e) {
      setError(e instanceof Error ? e.message : String(e));
    } finally {
      setBusy(false);
    }
  }

  function runName() {
    const bits = [line, season, pageType, priority && `${priority} priority`].filter(Boolean);
    return bits.length ? bits.join(" · ") : "Everything";
  }

  async function move(status: string, retryFailed = false) {
    if (!runId) return;
    setError(null);
    const d = await fetch(`/api/batch/${runId}`, {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ status, retryFailed }),
    }).then((r) => r.json());
    if (d.error) return setError(d.error);
    setRun(d.run);
    await loadRun(runId);
    if (status === "running") drain(runId);
    else {
      ticking.current = false;
      setDraining(false);
    }
    loadRuns();
  }

  async function raiseCap() {
    if (!runId) return;
    const next = Number(cap);
    if (!Number.isFinite(next)) return;
    await fetch(`/api/batch/${runId}`, {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ maxSpendUsd: next }),
    });
    await loadRun(runId);
  }

  async function mark(assetId: string, status: string) {
    const d = await fetch(`/api/assets/${assetId}`, {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ status }),
    }).then((r) => r.json());
    if (d.error) return setError(d.error);
    setRows((prev) =>
      prev.map((r) => ({
        ...r,
        assets: r.assets.map((a) => (a.id === assetId ? { ...a, status: d.status } : a)),
      }))
    );
  }

  const catCollections = collections.filter((c) => c.category_id === categoryId);
  const done = run ? (run.counts.done ?? 0) + (run.counts.skipped ?? 0) + (run.counts.failed ?? 0) : 0;
  const pct = run && run.total ? Math.round((done / run.total) * 100) : 0;

  return (
    <div className="sheet-backdrop full" onClick={onClose}>
      <div
        className="sheet-panel batch"
        onClick={(e) => e.stopPropagation()}
        role="dialog"
        aria-label="Batch"
      >
        <header>
          <strong>Batch</strong>
          <span className="hint">
            {runId ? run?.name : "A whole season in one action"}
          </span>
          <span className="spacer" />
          {runId && (
            <button onClick={() => { ticking.current = false; setDraining(false); setRunId(null); setRun(null); setRows([]); setError(null); }}>
              ← New run
            </button>
          )}
          <button onClick={onClose} aria-label="Close">✕</button>
        </header>

        <div className="batch-body">
          {error && <p className="note warn">{error}</p>}

          {!runId && (
            <>
              <div className="batch-form">
                <label>
                  <span>Category</span>
                  <select value={categoryId} onChange={(e) => { setCategoryId(e.target.value); setCollectionId(""); }}>
                    {categories.map((c) => (
                      <option key={c.id} value={c.id}>{c.label}</option>
                    ))}
                  </select>
                </label>

                <label>
                  <span>Book</span>
                  <select value={collectionId} onChange={(e) => setCollectionId(e.target.value)}>
                    <option value="">Every book</option>
                    {catCollections.map((c) => (
                      <option key={c.id} value={c.id}>{c.name}</option>
                    ))}
                  </select>
                </label>

                <label>
                  <span>Season</span>
                  <select value={season} onChange={(e) => setSeason(e.target.value)}>
                    <option value="">Every season</option>
                    {facets.seasons.map((s) => <option key={s} value={s}>{s}</option>)}
                  </select>
                </label>

                <label>
                  <span>Page type</span>
                  <select value={pageType} onChange={(e) => setPageType(e.target.value)}>
                    <option value="">Every page type</option>
                    {facets.pageTypes.map((p) => <option key={p} value={p}>{p}</option>)}
                  </select>
                </label>

                <label>
                  <span>Line</span>
                  <select value={line} onChange={(e) => setLine(e.target.value)}>
                    <option value="">Every line</option>
                    {facets.lines.map((l) => <option key={l} value={l}>{l}</option>)}
                  </select>
                </label>

                <label>
                  <span>Priority</span>
                  <select value={priority} onChange={(e) => setPriority(e.target.value)}>
                    <option value="">Every priority</option>
                    <option value="High">High</option>
                    <option value="Medium">Medium</option>
                    <option value="Low">Low</option>
                  </select>
                </label>

                <label>
                  <span>Quality</span>
                  <select value={quality} onChange={(e) => setQuality(e.target.value)}>
                    <option value="low">low</option>
                    <option value="medium">medium</option>
                    <option value="high">high</option>
                  </select>
                </label>

                <label>
                  <span>Per page</span>
                  <select value={n} onChange={(e) => setN(Number(e.target.value))}>
                    {[1, 2, 3, 4].map((v) => <option key={v} value={v}>{v}</option>)}
                  </select>
                </label>

                <label>
                  <span>Spend ceiling</span>
                  <input value={cap} onChange={(e) => setCap(e.target.value)} placeholder="none" />
                </label>
              </div>

              <label className="check">
                <input type="checkbox" checked={skipWithArt} onChange={(e) => setSkipWithArt(e.target.checked)} />
                <span>Skip pages that already have art you kept</span>
              </label>
              <label className="check">
                <input type="checkbox" checked={useReferences} onChange={(e) => setUseReferences(e.target.checked)} />
                <span>Send approved exemplars as reference (D20)</span>
              </label>

              {preview && (
                <div className="batch-estimate">
                  <strong>
                    {preview.estimate.runnable} page
                    {preview.estimate.runnable === 1 ? "" : "s"} · {preview.estimate.images} image
                    {preview.estimate.images === 1 ? "" : "s"} · ${preview.estimate.totalUsd.toFixed(2)}
                  </strong>
                  {preview.estimate.skipped > 0 && (
                    <span className="note">
                      {preview.estimate.skipped} cannot run and will be listed as skipped.
                    </span>
                  )}
                  <button className="commit" onClick={plan} disabled={busy || preview.estimate.runnable === 0}>
                    {busy ? "Planning…" : "Plan this run"}
                  </button>
                  <p className="note">
                    Planning does not generate anything. The list is frozen so you can
                    read it before it spends.
                  </p>

                  <ol className="batch-plan">
                    {preview.rows.slice(0, 40).map((r) => (
                      <li key={r.item_id} className={r.skip_reason ? "blocked" : "ready"}>
                        <span className="pg-ref">{r.ref}</span>
                        <span className="pg-type">{r.page_type}</span>
                        {r.skip_reason && <span className="pg-note">{r.skip_reason}</span>}
                      </li>
                    ))}
                    {preview.rows.length > 40 && (
                      <li className="pg-note">…and {preview.rows.length - 40} more</li>
                    )}
                  </ol>
                </div>
              )}

              {runs.length > 0 && (
                <div className="batch-runs">
                  <p className="note">Earlier runs</p>
                  <ul>
                    {runs.map((r) => (
                      <li key={r.id}>
                        <button onClick={() => { setRunId(r.id); loadRun(r.id); }}>
                          <span>{r.name}</span>
                          <em>
                            {r.done}/{r.total} · ${Number(r.spent_usd).toFixed(2)} · {r.status}
                          </em>
                        </button>
                      </li>
                    ))}
                  </ul>
                </div>
              )}
            </>
          )}

          {runId && run && (
            <>
              <div className="batch-status">
                <span className="bk-bar"><i style={{ width: `${pct}%` }} /></span>
                <p className="note">
                  {done} of {run.total} · {run.counts.done ?? 0} generated ·{" "}
                  {run.counts.skipped ?? 0} skipped · {run.counts.failed ?? 0} failed ·
                  ${run.spentUsd.toFixed(2)} spent
                  {run.maxSpendUsd !== null && ` of $${run.maxSpendUsd.toFixed(2)}`}
                  {doing && ` · ${doing}`}
                </p>

                <div className="batch-actions">
                  {run.status !== "running" && run.status !== "done" && run.status !== "cancelled" && (
                    <button className="commit" onClick={() => move("running", (run.counts.failed ?? 0) > 0)}>
                      {run.status === "planned" ? "Start" : "Resume"}
                    </button>
                  )}
                  {run.status === "running" && !draining && (
                    <button className="commit" onClick={() => drain(runId)}>
                      Continue
                    </button>
                  )}
                  {run.status === "running" && draining && (
                    <button onClick={() => move("paused")}>Pause</button>
                  )}
                  {run.status !== "done" && run.status !== "cancelled" && (
                    <button onClick={() => move("cancelled")}>Cancel</button>
                  )}
                  <input value={cap} onChange={(e) => setCap(e.target.value)} size={5} />
                  <button onClick={raiseCap}>Set ceiling</button>
                </div>
              </div>

              <ol className="batch-rows">
                {rows.map((r) => (
                  <li key={r.id} className={r.status}>
                    <div className="br-head">
                      <span className="pg-ref">{r.ref}</span>
                      <span className="pg-type">{r.page_type}</span>
                      <span className="pg-note">
                        {r.status}
                        {r.cost_usd ? ` · $${r.cost_usd.toFixed(2)}` : ""}
                      </span>
                    </div>
                    {r.error_message && <p className="pg-note">{r.error_message}</p>}
                    {r.assets.length > 0 && (
                      <div className="br-assets">
                        {r.assets.map((a) => (
                          <figure key={a.id} className={`lib-card ${a.status}`}>
                            <a href={`/api/files/${a.storage_path}`} target="_blank" rel="noreferrer">
                              {/* eslint-disable-next-line @next/next/no-img-element */}
                              <img src={`/api/files/${a.storage_path}`} alt={a.asset_name} />
                            </a>
                            <div className="lib-actions">
                              <button onClick={() => mark(a.id, "approved")} disabled={a.status === "approved"}>Keep</button>
                              <button onClick={() => mark(a.id, "rejected")} disabled={a.status === "rejected"}>Reject</button>
                            </div>
                          </figure>
                        ))}
                      </div>
                    )}
                  </li>
                ))}
              </ol>
            </>
          )}
        </div>
      </div>
    </div>
  );
}

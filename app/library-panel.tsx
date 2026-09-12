"use client";

import { useCallback, useEffect, useMemo, useState } from "react";

/**
 * The asset library.
 *
 * The studio could generate 117 pages and keep 39 of them, and offer no way to
 * look at the 39. Judging whether the style has drifted — which is the question
 * every style decision since D110 has turned on — means seeing the accepted
 * pages together and in the order they were made, not one contact sheet at a
 * time from whichever session produced it (D128).
 *
 * So the two controls that matter are **status** and **order**. Everything else
 * narrows. Oldest-first is offered rather than defaulted because the results
 * grid wants the newest, and "has this got better" wants the oldest.
 *
 * This is the asset half of Stage D. The item queue — 180 planned pages,
 * browsable with their briefs and priorities — is the other half and is not
 * here.
 */

export type LibraryAsset = {
  id: string;
  asset_name: string;
  storage_path: string;
  status: string;
  is_favorite: boolean;
  created_at: string;
  ref: string | null;
  page_type: string | null;
  season: string | null;
  ethnicity_line: string | null;
  art_style: string | null;
  background_density: string | null;
  category_code: string | null;
  collection_name: string | null;
  is_lettering?: boolean;
};

export type Facets = {
  categories: { code: string; label: string }[];
  pageTypes: string[];
  seasons: string[];
  lines: string[];
};

const PAGE = 60;

export default function LibraryPanel({
  facets,
  onClose,
  onStatusChange,
}: {
  facets: Facets;
  onClose: () => void;
  /** Keeps the results grid behind the panel in step when a card is re-marked. */
  onStatusChange?: (id: string, status: string) => void;
}) {
  const [status, setStatus] = useState("approved");
  const [category, setCategory] = useState("");
  const [pageType, setPageType] = useState("");
  const [season, setSeason] = useState("");
  const [line, setLine] = useState("");
  const [oldest, setOldest] = useState(true);
  /**
   * The filter row starts closed. A library is a place you look at pictures in,
   * and a menu that cannot be got out of the way is worse than one more click —
   * which is what the first version of this panel was. Status stays in the
   * header bar, because choosing what to look at is not a filter, it is the
   * whole question.
   */
  const [showFilters, setShowFilters] = useState(false);

  const [assets, setAssets] = useState<LibraryAsset[]>([]);
  const [counts, setCounts] = useState<Record<string, number>>({});
  const [total, setTotal] = useState(0);
  const [shown, setShown] = useState(PAGE);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const qs = useMemo(() => {
    const p = new URLSearchParams({
      limit: String(shown),
      order: oldest ? "oldest" : "newest",
    });
    if (status) p.set("status", status);
    if (category) p.set("category", category);
    if (pageType) p.set("pageType", pageType);
    if (season) p.set("season", season);
    if (line) p.set("line", line);
    return p.toString();
  }, [status, category, pageType, season, line, oldest, shown]);

  useEffect(() => {
    let live = true;
    setLoading(true);
    fetch(`/api/assets?${qs}`)
      .then((r) => r.json())
      .then((d) => {
        if (!live) return;
        if (d.error) return setError(d.error);
        setError(null);
        setAssets(d.assets);
        setCounts(d.counts ?? {});
        setTotal(d.total ?? 0);
      })
      .catch((e) => live && setError(String(e)))
      .finally(() => live && setLoading(false));
    return () => {
      live = false;
    };
  }, [qs]);

  // Changing a filter starts the listing again; only "Show more" grows it.
  useEffect(() => {
    setShown(PAGE);
  }, [status, category, pageType, season, line, oldest]);

  useEffect(() => {
    const esc = (e: KeyboardEvent) => e.key === "Escape" && onClose();
    window.addEventListener("keydown", esc);
    return () => window.removeEventListener("keydown", esc);
  }, [onClose]);

  const mark = useCallback(
    async (id: string, next: string) => {
      const res = await fetch(`/api/assets/${id}`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ status: next }),
      });
      const d = await res.json();
      if (d.error) return setError(d.error);
      setAssets((prev) =>
        prev.map((a) => (a.id === id ? { ...a, status: d.status } : a))
      );
      setCounts((prev) => {
        const was = assets.find((a) => a.id === id)?.status;
        if (!was || was === d.status) return prev;
        return {
          ...prev,
          [was]: Math.max((prev[was] ?? 1) - 1, 0),
          [d.status]: (prev[d.status] ?? 0) + 1,
        };
      });
      onStatusChange?.(id, d.status);
    },
    [assets, onStatusChange]
  );

  const tabs = [
    { key: "approved", label: "Kept" },
    { key: "draft", label: "Unjudged" },
    { key: "rejected", label: "Rejected" },
    { key: "", label: "Everything" },
  ];

  const activeFilters = [category, pageType, season, line].filter(Boolean).length;

  return (
    <div className="sheet-backdrop full" onClick={onClose}>
      <div
        className="sheet-panel library"
        onClick={(e) => e.stopPropagation()}
        role="dialog"
        aria-label="Library"
      >
        <header>
          <strong>Library</strong>

          <div className="lib-tabs" role="tablist">
            {tabs.map((t) => (
              <button
                key={t.key}
                role="tab"
                aria-selected={status === t.key}
                className={status === t.key ? "on" : ""}
                onClick={() => setStatus(t.key)}
              >
                {t.label}
                <em>
                  {t.key
                    ? (counts[t.key] ?? 0)
                    : Object.values(counts).reduce((a, b) => a + b, 0)}
                </em>
              </button>
            ))}
          </div>

          <span className="spacer" />

          <button
            className={showFilters || activeFilters ? "on" : ""}
            aria-expanded={showFilters}
            onClick={() => setShowFilters((v) => !v)}
          >
            Filters{activeFilters ? ` (${activeFilters})` : ""} {showFilters ? "▴" : "▾"}
          </button>
          <button onClick={onClose} aria-label="Close">
            ✕
          </button>
        </header>

        <div className="lib-controls" hidden={!showFilters}>
          <div className="lib-filters">
            <select value={category} onChange={(e) => setCategory(e.target.value)}>
              <option value="">Every category</option>
              {facets.categories.map((c) => (
                <option key={c.code} value={c.code}>
                  {c.label}
                </option>
              ))}
            </select>

            <select value={pageType} onChange={(e) => setPageType(e.target.value)}>
              <option value="">Every page type</option>
              {facets.pageTypes.map((p) => (
                <option key={p} value={p}>
                  {p}
                </option>
              ))}
            </select>

            <select value={season} onChange={(e) => setSeason(e.target.value)}>
              <option value="">Every season</option>
              {facets.seasons.map((s) => (
                <option key={s} value={s}>
                  {s}
                </option>
              ))}
            </select>

            <select value={line} onChange={(e) => setLine(e.target.value)}>
              <option value="">Every line</option>
              {facets.lines.map((l) => (
                <option key={l} value={l}>
                  {l}
                </option>
              ))}
            </select>

            <button
              className={oldest ? "on" : ""}
              onClick={() => setOldest((v) => !v)}
              title="Oldest first shows how the pages have changed over time"
            >
              {oldest ? "Oldest first" : "Newest first"}
            </button>

            <button
              onClick={() => {
                setCategory("");
                setPageType("");
                setSeason("");
                setLine("");
              }}
              disabled={!activeFilters}
            >
              Clear
            </button>
          </div>
        </div>

        <div className="lib-body">
          {error && <p className="note warn">{error}</p>}

          {!error && total === 0 && !loading && (
            <p className="note">Nothing matches these filters.</p>
          )}

          {total > 0 && (
            <p className="note">
              Showing {assets.length} of {total}
              {oldest ? ", oldest first." : ", newest first."}
            </p>
          )}

          <div className="lib-grid">
            {assets.map((a) => (
              <figure key={a.id} className={`lib-card ${a.status}`}>
                <a
                  href={`/api/files/${a.storage_path}`}
                  target="_blank"
                  rel="noreferrer"
                  title="Open full size"
                >
                  {/* eslint-disable-next-line @next/next/no-img-element */}
                  <img src={`/api/files/${a.storage_path}`} alt={a.asset_name} />
                </a>
                <figcaption>
                  <span className="lib-ref">{a.ref ?? a.asset_name}</span>
                  <span className="lib-meta">
                    {[a.page_type, a.art_style, a.background_density]
                      .filter(Boolean)
                      .join(" · ")}
                  </span>
                  <span className="lib-meta">
                    {new Date(a.created_at).toLocaleDateString()}
                    {a.is_lettering ? " · lettered" : ""}
                  </span>
                </figcaption>
                <div className="lib-actions">
                  <button
                    onClick={() => mark(a.id, "approved")}
                    disabled={a.status === "approved"}
                  >
                    Keep
                  </button>
                  <button
                    onClick={() => mark(a.id, "rejected")}
                    disabled={a.status === "rejected"}
                  >
                    Reject
                  </button>
                </div>
              </figure>
            ))}
          </div>

          {assets.length < total && (
            <div className="lib-more">
              <button
                onClick={() => setShown((n) => n + PAGE)}
                disabled={loading}
              >
                {loading ? "Loading…" : `Show ${Math.min(PAGE, total - assets.length)} more`}
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

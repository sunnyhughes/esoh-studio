"use client";

import { useEffect, useState } from "react";

/**
 * The books, and how much of each one exists.
 *
 * A book is a collection: fifteen items in `ref` order. This is the only view
 * in the studio that is not asset-shaped, because assembling an interior is a
 * question about a whole collection rather than about any one page.
 *
 * The readiness count is the point. Of 180 planned pages a handful have art, so
 * "which pages are still missing" is the answer this panel usually gives, and
 * the build refuses an unfinished book rather than quietly producing a shorter
 * one.
 */

type Book = {
  id: string;
  name: string;
  series: string | null;
  ready: number;
  total: number;
};

type Page = {
  ref: string;
  pageType: string | null;
  lettered: boolean;
  status: string | null;
  blocked: string | null;
};

type Plan = {
  collection: { id: string; name: string; series: string | null };
  pages: Page[];
  ready: number;
  total: number;
  complete: boolean;
};

export default function BooksPanel({ onClose }: { onClose: () => void }) {
  const [books, setBooks] = useState<Book[]>([]);
  const [openId, setOpenId] = useState<string | null>(null);
  const [plan, setPlan] = useState<Plan | null>(null);
  const [blankBacks, setBlankBacks] = useState(true);
  const [frontMatter, setFrontMatter] = useState(true);
  const [building, setBuilding] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetch("/api/books")
      .then((r) => r.json())
      .then((d) => !d.error && setBooks(d.books))
      .catch(() => {});
  }, []);

  useEffect(() => {
    if (!openId) return setPlan(null);
    let live = true;
    fetch(`/api/books/${openId}?format=json`)
      .then((r) => r.json())
      .then((d) => live && !d.error && setPlan(d))
      .catch(() => {});
    return () => {
      live = false;
    };
  }, [openId]);

  useEffect(() => {
    const esc = (e: KeyboardEvent) => e.key === "Escape" && onClose();
    window.addEventListener("keydown", esc);
    return () => window.removeEventListener("keydown", esc);
  }, [onClose]);

  /**
   * Fetched rather than linked, because a fifteen-page interior is a minute of
   * work and a plain link would look like nothing was happening — and because
   * a refusal comes back as JSON that should be read, not downloaded.
   */
  async function build(id: string, draft: boolean) {
    setBuilding(true);
    setError(null);
    try {
      const qs = new URLSearchParams({
        blankBacks: blankBacks ? "1" : "0",
        frontMatter: frontMatter ? "1" : "0",
      });
      if (draft) qs.set("draft", "1");

      const res = await fetch(`/api/books/${id}?${qs}`);
      if (!res.ok) {
        const d = await res.json().catch(() => ({}));
        throw new Error(d.error ?? `Build failed (${res.status})`);
      }
      const blob = await res.blob();
      const url = URL.createObjectURL(blob);
      const name =
        /filename="([^"]+)"/.exec(res.headers.get("content-disposition") ?? "")?.[1] ??
        "interior.pdf";

      const a = document.createElement("a");
      a.href = url;
      a.download = name;
      a.click();
      URL.revokeObjectURL(url);
    } catch (e) {
      setError(e instanceof Error ? e.message : String(e));
    } finally {
      setBuilding(false);
    }
  }

  return (
    <div className="sheet-backdrop" onClick={onClose}>
      <div
        className="sheet-panel books"
        onClick={(e) => e.stopPropagation()}
        role="dialog"
        aria-label="Books"
      >
        <header>
          <div>
            <strong>Books</strong>
            <span className="hint">
              One interior PDF per book — what KDP takes
            </span>
          </div>
          <button onClick={onClose} aria-label="Close">
            ✕
          </button>
        </header>

        <div className="books-body">
          <ul className="book-list">
            {books.map((b) => (
              <li key={b.id}>
                <button
                  className={b.id === openId ? "on" : ""}
                  onClick={() => setOpenId(b.id === openId ? null : b.id)}
                >
                  <span className="bk-name">
                    {b.name}
                    {b.series && <em>{b.series}</em>}
                  </span>
                  <span className="bk-count">
                    {b.ready}/{b.total}
                  </span>
                  <span className="bk-bar">
                    <i style={{ width: `${(b.ready / b.total) * 100}%` }} />
                  </span>
                </button>
              </li>
            ))}
            {books.length === 0 && <li className="none">No books yet.</li>}
          </ul>

          <div className="book-detail">
            {!plan && <p className="note">Choose a book to see its pages.</p>}

            {plan && (
              <>
                <p className="note">
                  {plan.ready} of {plan.total} pages ready
                  {plan.complete ? " — the interior can be built." : "."}
                </p>

                <ol className="page-list">
                  {plan.pages.map((p) => (
                    <li key={p.ref} className={p.blocked ? "blocked" : "ready"}>
                      <span className="pg-ref">{p.ref}</span>
                      <span className="pg-type">{p.pageType}</span>
                      <span className="pg-note">
                        {p.blocked ??
                          (p.lettered ? "ready · lettered" : "ready")}
                      </span>
                    </li>
                  ))}
                </ol>

                <label className="check">
                  <input
                    type="checkbox"
                    checked={blankBacks}
                    onChange={(e) => setBlankBacks(e.target.checked)}
                  />
                  <span>Blank back to every page</span>
                </label>
                <p className="note">
                  KDP prints both sides of every leaf. Without this, markers
                  bleed into the drawing behind — and fifteen pages alone fall
                  under the minimum length for a paperback.
                </p>

                <label className="check">
                  <input
                    type="checkbox"
                    checked={frontMatter}
                    onChange={(e) => setFrontMatter(e.target.checked)}
                  />
                  <span>Title, copyright and belongs-to pages</span>
                </label>

                {error && <p className="note warn">{error}</p>}

                <div className="book-actions">
                  <button
                    onClick={() => build(plan.collection.id, false)}
                    disabled={building || !plan.complete}
                    className="commit"
                  >
                    {building ? "Building…" : "Build interior"}
                  </button>
                  <button
                    onClick={() => build(plan.collection.id, true)}
                    disabled={building}
                  >
                    Build draft
                  </button>
                </div>
                <p className="note">
                  A draft prints the gaps in place, named, so the shape can be
                  proofed before the pages exist. Never for upload.
                </p>
              </>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

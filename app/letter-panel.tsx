"use client";

import { useEffect, useRef, useState } from "react";

/**
 * Lettering control for a Quote page.
 *
 * The form has always said the quote would be overlaid after generation, but
 * nothing in the app ever called the overlay — every quote page was lettered
 * from the command line, in the middle of the one flow this tool exists to
 * make continuous.
 *
 * Everything here is a preview until Letter page is pressed. Settling on the
 * wording and a face takes several tries, and under D65 and D68 every try is
 * an asset row and a pair of files, so trying things would fill the library
 * with drafts nobody wants. The preview persists nothing; only the commit
 * writes.
 */

export type LetterTarget = {
  id: string;
  asset_name: string;
  storage_path: string;
  quote_text: string | null;
  lettering_style: string | null;
};

export type Face = { lettering_style: string; family: string };

export default function LetterPanel({
  asset,
  faces,
  onClose,
  onLettered,
}: {
  asset: LetterTarget;
  faces: Face[];
  onClose: () => void;
  onLettered: (created: unknown) => void;
}) {
  const [text, setText] = useState(asset.quote_text ?? "");
  const [style, setStyle] = useState(
    asset.lettering_style ?? "Serif Editorial"
  );
  const [preview, setPreview] = useState<string | null>(null);
  const [pending, setPending] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const urlRef = useRef<string | null>(null);

  // Debounced, because this re-sets the type on every keystroke otherwise.
  useEffect(() => {
    if (!text.trim()) {
      setPreview(null);
      return;
    }
    let live = true;
    setPending(true);
    const timer = setTimeout(async () => {
      try {
        const res = await fetch("/api/overlay?preview=1", {
          method: "POST",
          headers: { "content-type": "application/json" },
          body: JSON.stringify({
            assetId: asset.id,
            text,
            letteringStyle: style,
          }),
        });
        if (!res.ok) {
          const d = await res.json().catch(() => ({}));
          throw new Error(d.error ?? `Preview failed (${res.status})`);
        }
        const blob = await res.blob();
        if (!live) return;
        if (urlRef.current) URL.revokeObjectURL(urlRef.current);
        urlRef.current = URL.createObjectURL(blob);
        setPreview(urlRef.current);
        setError(null);
      } catch (e) {
        if (live) setError(e instanceof Error ? e.message : String(e));
      } finally {
        if (live) setPending(false);
      }
    }, 450);

    return () => {
      live = false;
      clearTimeout(timer);
    };
  }, [asset.id, text, style]);

  // The last preview outlives the effect that made it, so it is released here.
  useEffect(
    () => () => {
      if (urlRef.current) URL.revokeObjectURL(urlRef.current);
    },
    []
  );

  useEffect(() => {
    const esc = (e: KeyboardEvent) => e.key === "Escape" && onClose();
    window.addEventListener("keydown", esc);
    return () => window.removeEventListener("keydown", esc);
  }, [onClose]);

  async function commit() {
    setBusy(true);
    setError(null);
    try {
      const res = await fetch("/api/overlay", {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({
          assetId: asset.id,
          text,
          letteringStyle: style,
        }),
      });
      const d = await res.json();
      if (!res.ok || d.error) throw new Error(d.error ?? `Failed (${res.status})`);
      onLettered(d.asset);
      onClose();
    } catch (e) {
      setError(e instanceof Error ? e.message : String(e));
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="sheet-backdrop" onClick={onClose}>
      <div
        className="sheet-panel"
        onClick={(e) => e.stopPropagation()}
        role="dialog"
        aria-label="Letter this page"
      >
        <header>
          <div>
            <strong>Letter this page</strong>
            <span className="hint">
              Outlined type, laid over the art and left hollow so it colours in
              (D23)
            </span>
          </div>
          <button onClick={onClose} aria-label="Close">
            ✕
          </button>
        </header>

        <div className="sheet-body">
          <div className="sheet-stage">
            <div className="letter-preview">
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img
                src={preview ?? `/api/files/${asset.storage_path}`}
                alt={asset.asset_name}
              />
              {pending && <span className="setting">setting…</span>}
            </div>
          </div>

          <div className="sheet-controls">
            <label className="field">
              <span>Quote</span>
              <textarea
                rows={4}
                value={text}
                onChange={(e) => setText(e.target.value)}
                placeholder="The words to lay on the page"
              />
            </label>
            <p className="note">
              Spelling and accents are exact — the letters become geometry
              before anything is drawn, so “Un día a la vez” sets correctly
              without a font being installed anywhere (D64).
            </p>

            <label className="field">
              <span>Lettering style</span>
              <select value={style} onChange={(e) => setStyle(e.target.value)}>
                {faces.map((f) => (
                  <option key={f.lettering_style} value={f.lettering_style}>
                    {f.lettering_style} — {f.family}
                  </option>
                ))}
              </select>
            </label>
            <p className="note">
              The type is fitted to the oval the model actually left blank on
              this page, measured rather than assumed (D66).
            </p>

            {error && <p className="note warn">{error}</p>}

            <div className="sheet-actions">
              <button
                className="commit"
                onClick={commit}
                disabled={busy || !text.trim()}
              >
                {busy ? "Lettering…" : "Letter page"}
              </button>
            </div>
            <p className="note">
              Creates a new page and leaves this one as it is, so the quote can
              be re-set, restyled or translated against it later (D65).
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}

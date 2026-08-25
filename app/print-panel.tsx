"use client";

import { useEffect, useState } from "react";

/**
 * Print preview and export control.
 *
 * Shows the page as paper rather than as a picture: the sheet at its real
 * proportion, the art padded inside it, and the white that padding leaves.
 * That white is the KDP margin (D30), and it is the thing you cannot judge
 * from the generated image alone because the generated image does not contain
 * it.
 *
 * The placement comes from the server rather than being recomputed here. The
 * arithmetic is small enough to copy, which is exactly why it should not be —
 * `placeOnPaper()` is what the exported file is built from, so it has to be
 * what the preview draws too. A preview that agreed with the export only by
 * coincidence would be worse than none.
 */

type Sheet = {
  width: number;
  height: number;
  art: { x: number; y: number; width: number; height: number };
};

type Geometry = {
  sheet: Sheet;
  paper: { widthIn: number; heightIn: number };
  dpi: number;
  marginIn: number;
  name: string | null;
};

export type PrintTarget = { id: string; asset_name: string; storage_path: string };

const MARGINS = [0, 0.125, 0.25, 0.375, 0.5, 0.75, 1];

export default function PrintPanel({
  asset,
  onClose,
}: {
  asset: PrintTarget;
  onClose: () => void;
}) {
  const [marginIn, setMarginIn] = useState(0);
  const [format, setFormat] = useState<"pdf" | "png">("pdf");
  const [exact, setExact] = useState(false);
  const [guide, setGuide] = useState(false);
  const [guideIn, setGuideIn] = useState(0.5);
  const [geo, setGeo] = useState<Geometry | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let live = true;
    setError(null);
    fetch(`/api/export/${asset.id}?format=json&margin=${marginIn}`)
      .then((r) => r.json())
      .then((d) => {
        if (!live) return;
        if (d.error) setError(d.error);
        else setGeo(d);
      })
      .catch((e) => live && setError(String(e)));
    return () => {
      live = false;
    };
  }, [asset.id, marginIn]);

  useEffect(() => {
    const esc = (e: KeyboardEvent) => e.key === "Escape" && onClose();
    window.addEventListener("keydown", esc);
    return () => window.removeEventListener("keydown", esc);
  }, [onClose]);

  const href =
    `/api/export/${asset.id}?format=${format}&margin=${marginIn}` +
    (exact ? "&exact=1" : "");

  // Percentages of the sheet, so the preview scales with whatever width the
  // panel has without any pixel arithmetic of its own.
  const pct = geo && {
    left: (geo.sheet.art.x / geo.sheet.width) * 100,
    top: (geo.sheet.art.y / geo.sheet.height) * 100,
    width: (geo.sheet.art.width / geo.sheet.width) * 100,
    height: (geo.sheet.art.height / geo.sheet.height) * 100,
  };

  const guidePct = geo && (guideIn * geo.dpi * 100) / geo.sheet.width;
  const guidePctY = geo && (guideIn * geo.dpi * 100) / geo.sheet.height;

  return (
    <div className="sheet-backdrop" onClick={onClose}>
      <div
        className="sheet-panel"
        onClick={(e) => e.stopPropagation()}
        role="dialog"
        aria-label="Print preview"
      >
        <header>
          <div>
            <strong>Print preview</strong>
            <span className="hint">
              {geo
                ? `${geo.paper.widthIn}×${geo.paper.heightIn}in · ${geo.sheet.width}×${geo.sheet.height}px · ${geo.dpi} DPI`
                : "measuring…"}
            </span>
          </div>
          <button onClick={onClose} aria-label="Close">
            ✕
          </button>
        </header>

        <div className="sheet-body">
          <div className="sheet-stage">
            {geo && pct ? (
              <div
                className="sheet-paper"
                style={{ aspectRatio: `${geo.sheet.width} / ${geo.sheet.height}` }}
              >
                {/* eslint-disable-next-line @next/next/no-img-element */}
                <img
                  src={`/api/files/${asset.storage_path}`}
                  alt={asset.asset_name}
                  style={{
                    left: `${pct.left}%`,
                    top: `${pct.top}%`,
                    width: `${pct.width}%`,
                    height: `${pct.height}%`,
                  }}
                />
                <span
                  className="art-edge"
                  style={{
                    left: `${pct.left}%`,
                    top: `${pct.top}%`,
                    width: `${pct.width}%`,
                    height: `${pct.height}%`,
                  }}
                />
                {guide && (
                  <span
                    className="border-guide"
                    style={{
                      left: `${guidePct}%`,
                      right: `${guidePct}%`,
                      top: `${guidePctY}%`,
                      bottom: `${guidePctY}%`,
                    }}
                  />
                )}
              </div>
            ) : (
              <div className="sheet-empty">{error ?? "Measuring the sheet…"}</div>
            )}
          </div>

          <div className="sheet-controls">
            <label className="field">
              <span>Margin</span>
              <select
                value={marginIn}
                onChange={(e) => setMarginIn(Number(e.target.value))}
              >
                {MARGINS.map((m) => (
                  <option key={m} value={m}>
                    {m === 0 ? 'None — pad only' : `${m}in inset`}
                  </option>
                ))}
              </select>
            </label>
            <p className="note">
              Padding already leaves white on the long sides, because the art is
              narrower in proportion than the page (D30). An inset holds back
              more on every side.
            </p>

            <label className="field">
              <span>Format</span>
              <select
                value={format}
                onChange={(e) => setFormat(e.target.value as "pdf" | "png")}
              >
                <option value="pdf">Print PDF — art raster, type vector</option>
                <option value="png">Print PNG — flattened</option>
              </select>
            </label>
            <p className="note">
              {format === "pdf"
                ? "The letters stay geometry and print exact at any size (D61)."
                : "The letters are baked at 300 DPI. The stored SVG is untouched, so the quote can still be re-set (D65)."}
            </p>

            <label className="check">
              <input
                type="checkbox"
                checked={exact}
                onChange={(e) => setExact(e.target.checked)}
              />
              <span>Exact colour — roughly 3× the file size</span>
            </label>

            <label className="check">
              <input
                type="checkbox"
                checked={guide}
                onChange={(e) => setGuide(e.target.checked)}
              />
              <span>Border guide</span>
            </label>
            {guide && (
              <>
                <label className="field">
                  <span>Guide inset</span>
                  <select
                    value={guideIn}
                    onChange={(e) => setGuideIn(Number(e.target.value))}
                  >
                    {[0.25, 0.375, 0.5, 0.625, 0.75].map((m) => (
                      <option key={m} value={m}>
                        {m}in
                      </option>
                    ))}
                  </select>
                </label>
                <p className="note warn">
                  A guide only — nothing draws it into the file. D24 keeps the
                  border out of the pipeline until a proof print settles the
                  inset, and it must never enter a stored SVG.
                </p>
              </>
            )}

            <div className="sheet-actions">
              <a href={href} download>
                Download {format.toUpperCase()}
              </a>
            </div>
            {geo?.name && (
              <p className="note filename">
                {geo.name.slice(geo.name.lastIndexOf("/") + 1).replace(/\.pdf$/, `.${format}`)}
              </p>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

"use client";

import { useEffect, useMemo, useState } from "react";
import PrintPanel from "./print-panel";
import LetterPanel, { type Face } from "./letter-panel";
import BooksPanel from "./books-panel";

type Category = {
  id: string;
  code: string;
  label: string;
  output_width: number;
  output_height: number;
  transparent: boolean;
};
type Collection = { id: string; category_id: string; name: string; slug: string };
type Variable = {
  name: string;
  label: string;
  type: "text" | "textarea" | "select" | "combo";
  required?: boolean;
  placeholder?: string;
  options?: string[];
};
type Template = {
  id: string;
  name: string;
  slug: string;
  description: string | null;
  category_id: string;
  category_code: string;
  page_type: string | null;
  variables_json: Variable[];
  default_settings: { size?: string; quality?: string; n?: number };
};
/** A planned page from the queue. The item says WHAT is on the page (D39). */
type Item = {
  id: string;
  collection_id: string;
  category_id: string;
  ref: string;
  title: string;
  page_type: string | null;
  art_style: string | null;
  background_density: string | null;
  season: string | null;
  ethnicity_line: string | null;
  hair: string | null;
  facial_hair: string | null;
  brief: string | null;
  visual_elements: string | null;
  brand_mark: string | null;
  quote_text: string | null;
  lettering_style: string | null;
  status: string;
};
type Asset = {
  id: string;
  asset_name: string;
  storage_path: string;
  status: string;
  is_favorite: boolean;
  /** From the item behind the page: what can be lettered, and with what. */
  page_type?: string | null;
  quote_text?: string | null;
  lettering_style?: string | null;
  is_lettering?: boolean;
  /** D74's knockout measurement, present only on transparent categories. */
  transparency?: { ok: boolean; problems?: string[] } | null;
};

export default function NewJobPage() {
  const [categories, setCategories] = useState<Category[]>([]);
  const [collections, setCollections] = useState<Collection[]>([]);
  const [templates, setTemplates] = useState<Template[]>([]);
  const [items, setItems] = useState<Item[]>([]);
  const [artStyles, setArtStyles] = useState<string[]>([]);
  const [artStylesByCategory, setArtStylesByCategory] = useState<
    Record<string, string[]>
  >({});
  const [densities, setDensities] = useState<string[]>([]);

  const [categoryId, setCategoryId] = useState("");
  const [collectionId, setCollectionId] = useState("");
  const [templateId, setTemplateId] = useState("");
  const [itemId, setItemId] = useState("");
  const [artStyle, setArtStyle] = useState("");
  const [density, setDensity] = useState("");
  const [useReferences, setUseReferences] = useState(true);
  const [inputs, setInputs] = useState<Record<string, string>>({});
  const [size, setSize] = useState("1024x1536");
  const [quality, setQuality] = useState("medium");
  const [count, setCount] = useState(4);

  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [assets, setAssets] = useState<Asset[]>([]);
  const [printing, setPrinting] = useState<Asset | null>(null);
  const [lettering, setLettering] = useState<Asset | null>(null);
  const [faces, setFaces] = useState<Face[]>([]);
  const [showBooks, setShowBooks] = useState(false);
  /** True once this session has generated, so recent pages give way to results. */
  const [generated, setGenerated] = useState(false);
  const [prompt, setPrompt] = useState<string | null>(null);

  // Load form data once.
  // Without this the grid is empty until something is generated, which put
  // every page made before today — and the print export reached from it —
  // out of the app's reach.
  useEffect(() => {
    fetch("/api/assets?limit=12")
      .then((r) => r.json())
      .then((d) => {
        if (!d.error) setAssets(d.assets);
      })
      .catch(() => {});
  }, []);

  useEffect(() => {
    fetch("/api/bootstrap")
      .then((r) => r.json())
      .then((d) => {
        if (d.error) return setError(d.error);
        const {
          categories,
          collections,
          templates,
          items,
          artStyles,
          artStylesByCategory,
          densities,
          letteringStyles,
        } = d.data;
        setFaces(letteringStyles ?? []);
        setCategories(categories);
        setCollections(collections);
        setTemplates(templates);
        setItems(items ?? []);
        setArtStyles(artStyles ?? []);
        setArtStylesByCategory(artStylesByCategory ?? {});
        setDensities(densities ?? []);
        if (categories[0]) setCategoryId(categories[0].id);
        if (templates[0]) setTemplateId(templates[0].id);
      })
      .catch((e) => setError(String(e)));
  }, []);

  const template = useMemo(
    () => templates.find((t) => t.id === templateId),
    [templates, templateId]
  );

  const categoryCollections = useMemo(
    () => collections.filter((c) => c.category_id === categoryId),
    [collections, categoryId]
  );

  // A template belongs to one category, and so does every art style, because
  // both are defined by the blocks behind them. Showing all of either was the
  // reason picking VV-Styles used to offer a list of coloring-book choices
  // that could only fail.
  const categoryTemplates = useMemo(
    () => templates.filter((t) => t.category_id === categoryId),
    [templates, categoryId]
  );

  const item = useMemo(
    () => items.find((i) => i.id === itemId) ?? null,
    [items, itemId]
  );

  // The queue is long, so it is filtered to whatever is selected above it.
  const scopedItems = useMemo(
    () =>
      items.filter(
        (i) =>
          i.category_id === categoryId &&
          (!collectionId || i.collection_id === collectionId)
      ),
    [items, categoryId, collectionId]
  );

  // Choosing an item settles the three things it already knows about itself:
  // which template draws this page type, and its own art style and density.
  // Each stays editable — the row is a starting point, not a lock.
  useEffect(() => {
    if (!item) return;
    // Page type picks the template where there is one. Apparel items have no
    // page type — one VV-Styles design is not a kind of page — so the item's
    // own category settles it instead.
    const match =
      templates.find((t) => t.page_type && t.page_type === item.page_type) ??
      templates.find((t) => t.category_id === item.category_id);
    if (match) setTemplateId(match.id);
    if (item.art_style) setArtStyle(item.art_style);
    if (item.background_density) setDensity(item.background_density);
  }, [item, templates]);

  // Drop the item if it no longer belongs to what is selected above it.
  useEffect(() => {
    if (itemId && !scopedItems.some((i) => i.id === itemId)) setItemId("");
  }, [scopedItems, itemId]);

  // Keep the collection selection valid whenever the category changes.
  useEffect(() => {
    if (!categoryCollections.some((c) => c.id === collectionId)) {
      setCollectionId(categoryCollections[0]?.id ?? "");
    }
  }, [categoryCollections, collectionId]);

  // Each category fixes its own output size (docs/direction.md §5.1, D29).
  const category = useMemo(
    () => categories.find((c) => c.id === categoryId),
    [categories, categoryId]
  );
  useEffect(() => {
    if (category) setSize(`${category.output_width}x${category.output_height}`);
  }, [category]);

  const categoryArtStyles = useMemo(() => {
    if (!category) return artStyles;
    return artStylesByCategory[category.code] ?? [];
  }, [artStylesByCategory, artStyles, category]);

  // Keep template and art style valid whenever the category changes, the same
  // way the collection already is.
  useEffect(() => {
    if (!categoryTemplates.some((t) => t.id === templateId)) {
      setTemplateId(categoryTemplates[0]?.id ?? "");
    }
  }, [categoryTemplates, templateId]);

  useEffect(() => {
    if (artStyle && !categoryArtStyles.includes(artStyle)) setArtStyle("");
  }, [categoryArtStyles, artStyle]);

  // Adopt the template's own defaults, and seed selects with their first option.
  useEffect(() => {
    if (!template) return;
    const s = template.default_settings ?? {};
    if (s.size) setSize(s.size);
    if (s.quality) setQuality(s.quality);
    if (s.n) setCount(s.n);

    setInputs((prev) => {
      const next = { ...prev };
      for (const v of template.variables_json ?? []) {
        if (next[v.name] == null) {
          next[v.name] = v.type === "select" ? (v.options?.[0] ?? "") : "";
        }
      }
      return next;
    });
  }, [template]);

  async function generate() {
    setBusy(true);
    setError(null);
    setAssets([]);
    setPrompt(null);

    try {
      const res = await fetch("/api/generate", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          templateId,
          categoryId,
          collectionId: collectionId || undefined,
          itemId: itemId || undefined,
          artStyle: artStyle || undefined,
          density: density || undefined,
          useReferences,
          inputs,
          size,
          quality,
          n: count,
        }),
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error ?? `Request failed (${res.status})`);
      setAssets(data.assets);
      setGenerated(true);
      setPrompt(data.prompt);
    } catch (e) {
      setError(e instanceof Error ? e.message : String(e));
    } finally {
      setBusy(false);
    }
  }

  async function mark(id: string, status: string) {
    const res = await fetch(`/api/assets/${id}`, {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ status }),
    });
    if (!res.ok) return;
    const updated = await res.json();
    setAssets((prev) =>
      prev.map((a) => (a.id === id ? { ...a, status: updated.status } : a))
    );
  }

  const ready = categoryId && templateId && artStyle && !busy;

  return (
    <div className="shell">
      <header className="top">
        <h1>Esoh Studio</h1>
        <span className="tag">New job</span>
        <span className="spacer" />
        <button onClick={() => setShowBooks(true)}>Books…</button>
      </header>

      {error && <div className="error">{error}</div>}

      <div className="layout">
        <form
          className="panel"
          onSubmit={(e) => {
            e.preventDefault();
            generate();
          }}
        >
          <div className="field">
            <label htmlFor="category">Category</label>
            <select
              id="category"
              value={categoryId}
              onChange={(e) => setCategoryId(e.target.value)}
            >
              {categories.map((c) => (
                <option key={c.id} value={c.id}>
                  {c.label}
                </option>
              ))}
            </select>
          </div>

          <div className="field">
            <label htmlFor="collection">Collection</label>
            <select
              id="collection"
              value={collectionId}
              onChange={(e) => setCollectionId(e.target.value)}
            >
              {categoryCollections.length === 0 && <option value="">None yet</option>}
              {categoryCollections.map((c) => (
                <option key={c.id} value={c.id}>
                  {c.name}
                </option>
              ))}
            </select>
          </div>

          <div className="field">
            <label htmlFor="item">Page from the queue</label>
            <select
              id="item"
              value={itemId}
              onChange={(e) => setItemId(e.target.value)}
            >
              <option value="">None — describe it by hand below</option>
              {scopedItems.map((i) => (
                <option key={i.id} value={i.id}>
                  {i.ref} — {i.title}
                  {i.page_type ? ` (${i.page_type})` : ""}
                </option>
              ))}
            </select>
          </div>

          {/* What the row already knows, shown before anything is spent. An
              empty field here is a field the prompt will not receive. */}
          {item && (
            <div className="item-summary">
              {(
                [
                  ["Brief", item.brief],
                  ["Setting", item.visual_elements],
                  ["Hair", item.hair],
                  ["Facial hair", item.facial_hair],
                  ["Figure", item.ethnicity_line],
                  ["Season", item.season],
                  ["Name drop", item.brand_mark],
                ] as const
              ).map(([label, value]) => (
                <div key={label} className={value ? "has" : "missing"}>
                  <span>{label}</span>
                  <span>{value || "not set"}</span>
                </div>
              ))}

              {item.quote_text && (
                <p className="hint">
                  Quote: “{item.quote_text}” —{" "}
                  {category?.code === "vv-styles"
                    ? "lettered by the model as part of the artwork (D70). " +
                      "Apparel type is filled and built into the design, not " +
                      "laid over it."
                    : "overlaid as outlined type after generation, never " +
                      "drawn by the model (D23). The page reserves space for " +
                      "it."}
                </p>
              )}
            </div>
          )}

          <div className="field">
            <label htmlFor="template">Template</label>
            <select
              id="template"
              value={templateId}
              onChange={(e) => setTemplateId(e.target.value)}
            >
              {categoryTemplates.map((t) => (
                <option key={t.id} value={t.id}>
                  {t.name}
                </option>
              ))}
            </select>
          </div>

          <div className="row">
            <div className="field">
              <label htmlFor="artStyle">Art style</label>
              <select
                id="artStyle"
                value={artStyle}
                onChange={(e) => setArtStyle(e.target.value)}
              >
                <option value="">Choose…</option>
                {categoryArtStyles.map((a) => (
                  <option key={a} value={a}>
                    {a}
                  </option>
                ))}
              </select>
            </div>
            <div className="field">
              <label htmlFor="density">Density</label>
              <select
                id="density"
                value={density}
                onChange={(e) => setDensity(e.target.value)}
              >
                <option value="">Art style decides</option>
                {densities.map((d) => (
                  <option key={d} value={d}>
                    {d}
                  </option>
                ))}
              </select>
            </div>
          </div>

          <label className="check">
            <input
              type="checkbox"
              checked={useReferences}
              onChange={(e) => setUseReferences(e.target.checked)}
            />
            Send approved exemplars as reference (D20)
          </label>

          {/* Fields are driven by the template's variables_json, so adding a
              template in SQL adds its form here with no code change. */}
          {(template?.variables_json ?? []).map((v) => (
            <div className="field" key={v.name}>
              <label htmlFor={v.name}>
                {v.label}
                {v.required ? " *" : ""}
              </label>

              {v.type === "select" ? (
                <select
                  id={v.name}
                  value={inputs[v.name] ?? ""}
                  onChange={(e) =>
                    setInputs({ ...inputs, [v.name]: e.target.value })
                  }
                >
                  {(v.options ?? []).map((o) => (
                    <option key={o} value={o}>
                      {o}
                    </option>
                  ))}
                </select>
              ) : v.type === "combo" ? (
                // Suggestions, not a fixed menu — anything typed is accepted.
                <>
                  <input
                    id={v.name}
                    list={`${v.name}-options`}
                    placeholder={v.placeholder}
                    value={inputs[v.name] ?? ""}
                    onChange={(e) =>
                      setInputs({ ...inputs, [v.name]: e.target.value })
                    }
                  />
                  <datalist id={`${v.name}-options`}>
                    {(v.options ?? []).map((o) => (
                      <option key={o} value={o} />
                    ))}
                  </datalist>
                </>
              ) : v.type === "textarea" ? (
                <textarea
                  id={v.name}
                  placeholder={v.placeholder}
                  value={inputs[v.name] ?? ""}
                  onChange={(e) =>
                    setInputs({ ...inputs, [v.name]: e.target.value })
                  }
                />
              ) : (
                <input
                  id={v.name}
                  placeholder={v.placeholder}
                  value={inputs[v.name] ?? ""}
                  onChange={(e) =>
                    setInputs({ ...inputs, [v.name]: e.target.value })
                  }
                />
              )}
            </div>
          ))}

          <div className="row">
            <div className="field">
              <label htmlFor="size">Size</label>
              <select
                id="size"
                value={size}
                onChange={(e) => setSize(e.target.value)}
              >
                <option value="1024x1536">Portrait</option>
                <option value="1024x1024">Square</option>
                <option value="1536x1024">Landscape</option>
              </select>
            </div>
            <div className="field">
              <label htmlFor="quality">Quality</label>
              <select
                id="quality"
                value={quality}
                onChange={(e) => setQuality(e.target.value)}
              >
                <option value="low">Low</option>
                <option value="medium">Medium</option>
                <option value="high">High</option>
              </select>
            </div>
            <div className="field">
              <label htmlFor="count">Count</label>
              <select
                id="count"
                value={count}
                onChange={(e) => setCount(Number(e.target.value))}
              >
                {[1, 2, 3, 4, 6, 8].map((n) => (
                  <option key={n} value={n}>
                    {n}
                  </option>
                ))}
              </select>
            </div>
          </div>

          <button className="primary" type="submit" disabled={!ready}>
            {busy ? "Generating…" : "Generate"}
          </button>

          <p className="hint">
            Low quality is the right setting while you iterate on wording. Move
            to high only once the composition is right.
          </p>
        </form>

        <section>
          {busy && (
            <div className="empty">
              Generating {count} image{count === 1 ? "" : "s"}. This usually
              takes 15–60 seconds.
            </div>
          )}

          {!busy && assets.length === 0 && (
            <div className="empty">
              Results appear here. Fill in the brief and press Generate.
            </div>
          )}

          {!busy && !generated && assets.length > 0 && (
            <div className="empty recent">
              Recent pages. Generating replaces them with this run&rsquo;s results.
            </div>
          )}

          {assets.length > 0 && (
            <>
              <div className="grid">
                {assets.map((a) => (
                  <div key={a.id} className={`card ${a.status}`}>
                    {/* eslint-disable-next-line @next/next/no-img-element */}
                    <img
                      src={`/api/files/${a.storage_path}`}
                      alt={a.asset_name}
                    />
                    {a.transparency && !a.transparency.ok && (
                      /* D74 measures the knockout and D101 puts the result
                         where the image is. A panel hidden by white fabric is
                         invisible until the design is put on navy, so the one
                         moment this is worth saying is while the picture is
                         on screen. */
                      <p className="knockout-warning">
                        <strong>Knockout failed.</strong>{" "}
                        {a.transparency.problems?.join(" ") ??
                          "This does not measure as cut-out artwork."}
                      </p>
                    )}
                    <div className="actions">
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
                      <a
                        href={`/api/files/${a.storage_path}`}
                        download={`${a.asset_name}.png`}
                      >
                        Art
                      </a>
                      {a.page_type === "Quote page" && !a.is_lettering && (
                        <button onClick={() => setLettering(a)}>Letter…</button>
                      )}
                      <button onClick={() => setPrinting(a)}>Print…</button>
                    </div>
                  </div>
                ))}
              </div>

              {prompt && (
                <details className="prompt">
                  <summary>Resolved prompt</summary>
                  <pre>{prompt}</pre>
                </details>
              )}
            </>
          )}
        </section>
      </div>

      {printing && (
        <PrintPanel asset={printing} onClose={() => setPrinting(null)} />
      )}

      {showBooks && <BooksPanel onClose={() => setShowBooks(false)} />}

      {lettering && (
        <LetterPanel
          asset={{
            id: lettering.id,
            asset_name: lettering.asset_name,
            storage_path: lettering.storage_path,
            quote_text: lettering.quote_text ?? null,
            lettering_style: lettering.lettering_style ?? null,
          }}
          faces={faces}
          onClose={() => setLettering(null)}
          onLettered={(created) => {
            // The lettered page joins the grid next to the art it came from,
            // so the next step — Print… — is right there.
            const made = created as Asset;
            setAssets((prev) => {
              const at = prev.findIndex((p) => p.id === lettering.id);
              const row: Asset = {
                ...made,
                page_type: lettering.page_type,
                quote_text: lettering.quote_text,
                lettering_style: lettering.lettering_style,
                is_lettering: true,
              };
              const next = [...prev];
              next.splice(at < 0 ? prev.length : at + 1, 0, row);
              return next;
            });
          }}
        />
      )}
    </div>
  );
}

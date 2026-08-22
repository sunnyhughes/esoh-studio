"use client";

import { useEffect, useMemo, useState } from "react";

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
  type: "text" | "textarea" | "select";
  required?: boolean;
  placeholder?: string;
  options?: string[];
};
type Template = {
  id: string;
  name: string;
  slug: string;
  description: string | null;
  variables_json: Variable[];
  default_settings: { size?: string; quality?: string; n?: number };
};
type Asset = {
  id: string;
  asset_name: string;
  storage_path: string;
  status: string;
  is_favorite: boolean;
};

export default function NewJobPage() {
  const [categories, setCategories] = useState<Category[]>([]);
  const [collections, setCollections] = useState<Collection[]>([]);
  const [templates, setTemplates] = useState<Template[]>([]);

  const [categoryId, setCategoryId] = useState("");
  const [collectionId, setCollectionId] = useState("");
  const [templateId, setTemplateId] = useState("");
  const [inputs, setInputs] = useState<Record<string, string>>({});
  const [size, setSize] = useState("1024x1536");
  const [quality, setQuality] = useState("medium");
  const [count, setCount] = useState(4);

  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [assets, setAssets] = useState<Asset[]>([]);
  const [prompt, setPrompt] = useState<string | null>(null);

  // Load form data once.
  useEffect(() => {
    fetch("/api/bootstrap")
      .then((r) => r.json())
      .then((d) => {
        if (d.error) return setError(d.error);
        const { categories, collections, templates } = d.data;
        setCategories(categories);
        setCollections(collections);
        setTemplates(templates);
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
          inputs,
          size,
          quality,
          n: count,
        }),
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error ?? `Request failed (${res.status})`);
      setAssets(data.assets);
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

  const ready = categoryId && templateId && !busy;

  return (
    <div className="shell">
      <header className="top">
        <h1>Esoh Studio</h1>
        <span className="tag">Stage A — New Job</span>
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
            <label htmlFor="template">Template</label>
            <select
              id="template"
              value={templateId}
              onChange={(e) => setTemplateId(e.target.value)}
            >
              {templates.map((t) => (
                <option key={t.id} value={t.id}>
                  {t.name}
                </option>
              ))}
            </select>
          </div>

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
                        Save
                      </a>
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
    </div>
  );
}

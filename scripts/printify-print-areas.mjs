// Read the real printable areas out of Printify and store them.
//
//   PRINTIFY_API_TOKEN=xxx npm run printify:areas
//   PRINTIFY_API_TOKEN=xxx npm run printify:areas -- --set-default 12x16
//
// Printify publishes a printable area in pixels per blueprint, per print
// provider, per placement. It does not describe products in inches, so the
// delivery size is fetched rather than derived — this project has guessed it
// twice and been wrong twice.
//
// Only products that already exist in the shop are walked, so what lands in
// the table is the set of areas actually being sold into.
//
// The token needs THREE scopes, not one. Getting this wrong returns a bare 403
// with no indication of which is missing:
//
//   shops.read     — GET /shops.json
//   products.read  — GET /shops/{id}/products.json
//   catalog.read   — GET /catalog/blueprints/...
//
// Create one at https://printify.com/app/account/api and pass it in the
// environment; it is never written to disk by this script.

import pg from "pg";

const TOKEN = process.env.PRINTIFY_API_TOKEN;
const API = "https://api.printify.com/v1";

if (!TOKEN) {
  console.error(
    "PRINTIFY_API_TOKEN is not set.\n" +
      "Create a Personal Access Token at https://printify.com/app/account/api\n" +
      "then run:  PRINTIFY_API_TOKEN=xxx npm run printify:areas"
  );
  process.exit(1);
}

async function get(path) {
  const res = await fetch(`${API}${path}`, {
    headers: { Authorization: `Bearer ${TOKEN}` },
  });
  if (!res.ok) {
    // A 403 here is almost always a missing scope rather than a bad token —
    // Printify accepts the token and refuses the endpoint. Say which one.
    if (res.status === 403) {
      const scope = path.startsWith("/catalog")
        ? "catalog.read"
        : path.startsWith("/shops/")
          ? "products.read"
          : "shops.read";
      console.error(
        `GET ${path} → 403 Forbidden.\n` +
          `The token is missing the "${scope}" scope. This script needs all ` +
          `three of shops.read, products.read and catalog.read.\n` +
          `Edit the token at https://printify.com/app/account/api and re-run.`
      );
      process.exit(1);
    }
    const body = await res.text().catch(() => "");
    throw new Error(
      `GET ${path} → ${res.status} ${res.statusText}` +
        (body ? `\n${body.slice(0, 400)}` : "")
    );
  }
  return res.json();
}

/** Printify paginates products; the shop is small enough that one page is
 *  usually everything, but not assuming that costs nothing.
 *  50 is the API's maximum — asking for 100 is a 400, not a clamp. */
const PAGE_SIZE = 50;

async function allProducts(shopId) {
  const out = [];
  for (let page = 1; page <= 20; page++) {
    const body = await get(`/shops/${shopId}/products.json?limit=${PAGE_SIZE}&page=${page}`);
    const data = body.data ?? [];
    out.push(...data);
    if (data.length < PAGE_SIZE) break;
  }
  return out;
}

const client = new pg.Client({ connectionString: process.env.DATABASE_URL });
await client.connect();

try {
  const allShops = await get("/shops.json");
  if (!allShops.length) {
    console.error("No shops on this account.");
    process.exit(1);
  }

  // Printify keeps a disconnected shop in the API with its products intact, so
  // a store that was unhooked months ago still answers and still reports print
  // areas. Walking it would file dimensions from a dead catalogue alongside the
  // live one, and nothing downstream could tell them apart.
  const shops = allShops.filter((s) => s.sales_channel !== "disconnected");
  const skipped = allShops.filter((s) => s.sales_channel === "disconnected");

  if (!shops.length) {
    console.error(
      `Every shop on this account is disconnected: ` +
        `${allShops.map((s) => s.title).join(", ")}.`
    );
    process.exit(1);
  }

  console.log(`shops: ${shops.map((s) => `${s.title} (${s.id})`).join(", ")}`);
  if (skipped.length) {
    console.log(
      `skipped (disconnected): ${skipped
        .map((s) => `${s.title} (${s.id})`)
        .join(", ")}`
    );
  }
  console.log();

  // Which blueprint/provider pairs are actually in use.
  const pairs = new Map();
  for (const shop of shops) {
    for (const p of await allProducts(shop.id)) {
      if (p.blueprint_id == null || p.print_provider_id == null) continue;
      pairs.set(`${p.blueprint_id}:${p.print_provider_id}`, {
        blueprint_id: p.blueprint_id,
        print_provider_id: p.print_provider_id,
      });
    }
  }

  if (!pairs.size) {
    console.error(
      "No products found, so there is nothing to read a print area from.\n" +
        "Create one product in Printify first, then run this again."
    );
    process.exit(1);
  }
  console.log(`${pairs.size} blueprint/provider pair(s) in use\n`);

  const categoryId = (
    await client.query(`select id from categories where code = 'vv-styles'`)
  ).rows[0]?.id;

  let written = 0;
  for (const { blueprint_id, print_provider_id } of pairs.values()) {
    const blueprint = await get(`/catalog/blueprints/${blueprint_id}.json`);
    const variants = await get(
      `/catalog/blueprints/${blueprint_id}/print_providers/${print_provider_id}/variants.json`
    );

    // Placeholders are the same across a blueprint's variants; the first
    // variant that has any is representative.
    const withPlaceholders = (variants.variants ?? []).find(
      (v) => (v.placeholders ?? []).length
    );
    if (!withPlaceholders) {
      console.log(`  ${blueprint.title}: no placeholders reported, skipped`);
      continue;
    }

    for (const ph of withPlaceholders.placeholders) {
      await client.query(
        `insert into print_areas
           (category_id, blueprint_id, print_provider_id, blueprint_title,
            provider_title, placeholder, width_px, height_px, fetched_at)
         values ($1,$2,$3,$4,$5,$6,$7,$8, now())
         on conflict (blueprint_id, print_provider_id, placeholder)
         do update set width_px = excluded.width_px,
                       height_px = excluded.height_px,
                       blueprint_title = excluded.blueprint_title,
                       provider_title = excluded.provider_title,
                       fetched_at = now()`,
        [
          categoryId ?? null,
          blueprint_id,
          print_provider_id,
          blueprint.title,
          blueprint.brand ?? null,
          ph.position,
          ph.width,
          ph.height,
        ]
      );
      written++;
      const inches = (px) => (px / 300).toFixed(1);
      console.log(
        `  ${blueprint.title} — ${ph.position}: ${ph.width}×${ph.height} px ` +
          `(${inches(ph.width)}×${inches(ph.height)}" at 300 DPI)`
      );
    }
  }

  console.log(`\n${written} print area(s) recorded.`);

  // --set-default <placeholder> marks the area a category delivers into and
  // copies it onto the category, which is the only thing the app reads.
  const flag = process.argv.indexOf("--set-default");
  if (flag !== -1) {
    const position = process.argv[flag + 1];
    if (!position) {
      console.error("--set-default needs a placeholder name, e.g. front");
      process.exit(1);
    }
    const { rows } = await client.query(
      `select id, width_px, height_px, blueprint_title from print_areas
        where category_id = $1 and placeholder = $2
        order by width_px * height_px desc limit 1`,
      [categoryId, position]
    );
    if (!rows.length) {
      console.error(`No print area named "${position}" was recorded.`);
      process.exit(1);
    }
    const area = rows[0];
    await client.query(
      `update print_areas set is_default = (id = $1) where category_id = $2`,
      [area.id, categoryId]
    );
    await client.query(
      `update categories
          set deliver_width = $1, deliver_height = $2,
              deliver_note = $3
        where id = $4`,
      [
        area.width_px,
        area.height_px,
        `${area.blueprint_title} ${position} print area, read from Printify. ` +
          `Art is padded into it, never cropped.`,
        categoryId,
      ]
    );
    console.log(
      `\nvv-styles now delivers into ${area.width_px}×${area.height_px} ` +
        `(${area.blueprint_title}, ${position}).`
    );
  } else {
    console.log(
      "\nNothing has been made the default yet. Pick one with:\n" +
        "  PRINTIFY_API_TOKEN=xxx npm run printify:areas -- --set-default front"
    );
  }
} finally {
  await client.end();
}

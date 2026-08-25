import { one } from "@/lib/db";

/**
 * Export filenames.
 *
 * Storage keys stay opaque (see lib/storage.ts) — that is what keeps the move
 * to R2 a one-file change. This name is generated on the way out instead.
 *
 * Exported files leave the database behind. Inside the studio you find a page
 * by filtering on season, page type or art style and looking at thumbnails, so
 * the filename never matters. Once a file is sitting on a desktop or uploaded
 * to KDP, the filename is the only thing left, which is why nothing here is
 * abbreviated:
 *
 *   coloring-books/healing-seasons/african-american-fall/
 *       african-american-fall-09-quote-page-zentangle-pattern-v2.png
 *
 *   vv-styles/recovery-culture/
 *       vvs-0001-still-here-still-clean-retro-groovy-v1.png
 */

export function slug(value: string | null | undefined): string {
  if (!value) return "";
  return value
    .normalize("NFKD")
    .replace(/[̀-ͯ]/g, "") // "Un día a la vez" -> "un-dia-a-la-vez"
    .toLowerCase()
    .replace(/&/g, "and")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-|-$/g, "");
}

export type ExportParts = {
  categoryCode: string;
  series: string | null;
  collectionName: string;
  itemRef: string | null;
  itemTitle: string | null;
  pageType: string | null;
  artStyle: string | null;
  version: number;
  extension?: string;
};

/**
 * Directory only. Series sits between category and collection so a second
 * series never collides with the first.
 */
export function exportDir(p: ExportParts): string {
  return [p.categoryCode, slug(p.series), slug(p.collectionName)]
    .filter(Boolean)
    .join("/");
}

export function exportFilename(p: ExportParts): string {
  const ref = slug(p.itemRef);
  const title = slug(p.itemTitle);

  // A coloring-book ref already reads as "african-american-fall-09", so its
  // title adds nothing. An apparel ref is "VVS-0001", which alone says nothing
  // about the design, so the quote carries the meaning.
  const stem = [ref, title && title !== ref ? title : ""].filter(Boolean).join("-");

  const parts = [
    stem || "untitled",
    slug(p.pageType),
    slug(p.artStyle),
    `v${p.version}`,
  ].filter(Boolean);

  return `${parts.join("-")}.${p.extension ?? "png"}`;
}

export function exportPath(p: ExportParts): string {
  return `${exportDir(p)}/${exportFilename(p)}`;
}

type AssetRow = {
  category_code: string;
  series: string | null;
  collection_name: string | null;
  item_ref: string | null;
  item_title: string | null;
  page_type: string | null;
  art_style: string | null;
  version: string;
};

/**
 * Resolves the export name for a stored asset.
 *
 * `version` counts the asset's position among everything generated for the same
 * item, so a rework never overwrites the attempt it replaces. Assets generated
 * ad hoc — no item attached — fall back to counting within their own job.
 */
export async function exportNameForAsset(
  assetId: string,
  extension = "png"
): Promise<string | null> {
  const row = await one<AssetRow>(
    `
    select cat.code as category_code,
           col.series,
           col.name as collection_name,
           i.ref    as item_ref,
           i.title  as item_title,
           i.page_type,
           i.art_style,
           (
             select count(*)
               from generated_assets peer
              where peer.created_at <= a.created_at
                and case
                      when a.item_id is not null then peer.item_id = a.item_id
                      else peer.generation_job_id = a.generation_job_id
                    end
           ) as version
      from generated_assets a
      join categories  cat on cat.id = a.category_id
 left join collections col on col.id = a.collection_id
 left join items       i   on i.id   = a.item_id
     where a.id = $1
  `,
    [assetId]
  );

  if (!row) return null;

  return exportPath({
    categoryCode: row.category_code,
    series: row.series,
    collectionName: row.collection_name ?? "unsorted",
    itemRef: row.item_ref,
    itemTitle: row.item_title,
    pageType: row.page_type,
    artStyle: row.art_style,
    version: Number(row.version) || 1,
    extension,
  });
}

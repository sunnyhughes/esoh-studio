import { promises as fs } from "node:fs";
import path from "node:path";

/**
 * Local disk storage for Stage 1.
 *
 * Files live OUTSIDE public/ and are served through /api/files/[...path].
 * That indirection is the whole point: at Stage 3 this module gets swapped for
 * Cloudflare R2 and nothing else changes, because storage_path in the database
 * is already an opaque key rather than a URL.
 */

const ROOT = path.join(process.cwd(), "storage");

export async function save(key: string, data: Buffer): Promise<number> {
  const full = path.join(ROOT, key);
  await fs.mkdir(path.dirname(full), { recursive: true });
  await fs.writeFile(full, data);
  return data.byteLength;
}

export async function read(key: string): Promise<Buffer> {
  return fs.readFile(resolveKey(key));
}

/** Resolve a storage key to an absolute path, refusing anything outside ROOT. */
export function resolveKey(key: string): string {
  const full = path.resolve(ROOT, key);
  if (full !== ROOT && !full.startsWith(ROOT + path.sep)) {
    throw new Error("Invalid storage key");
  }
  return full;
}

/** storage key for one image: <job-id>/<index>.png */
export function assetKey(jobId: string, index: number): string {
  return path.join(jobId, `${index}.png`);
}

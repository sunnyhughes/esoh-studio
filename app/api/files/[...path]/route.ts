import { NextResponse } from "next/server";
import { read } from "@/lib/storage";
import { one } from "@/lib/db";
import { exportNameForAsset } from "@/lib/export-name";

/**
 * Serves stored images. Exists so storage_path in the database stays an opaque
 * key rather than a public URL — which is what makes the Stage 3 move to R2 a
 * one-file change.
 *
 * Add ?download to get the file with its export name attached. Inline viewing
 * keeps the opaque key; only the download carries the descriptive filename,
 * because that is the point at which the file stops being findable by query
 * and has to describe itself.
 */
export async function GET(
  req: Request,
  { params }: { params: Promise<{ path: string[] }> }
) {
  const { path: segments } = await params;
  const key = segments.join("/");

  try {
    const data = await read(key);
    const headers: Record<string, string> = {
      "Content-Type": "image/png",
      "Cache-Control": "private, max-age=31536000, immutable",
    };

    if (new URL(req.url).searchParams.has("download")) {
      const asset = await one<{ id: string }>(
        "select id from generated_assets where storage_path = $1",
        [key]
      );
      const name = asset ? await exportNameForAsset(asset.id) : null;
      if (name) {
        // Only the basename — the directory part is for a future bulk export
        // that writes real folders.
        const filename = name.slice(name.lastIndexOf("/") + 1);
        headers["Content-Disposition"] = `attachment; filename="${filename}"`;
      }
    }

    return new NextResponse(new Uint8Array(data), { headers });
  } catch {
    return NextResponse.json({ error: "Not found" }, { status: 404 });
  }
}

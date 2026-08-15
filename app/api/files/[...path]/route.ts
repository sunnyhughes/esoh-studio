import { NextResponse } from "next/server";
import { read } from "@/lib/storage";

/**
 * Serves stored images. Exists so storage_path in the database stays an opaque
 * key rather than a public URL — which is what makes the Stage 3 move to R2 a
 * one-file change.
 */
export async function GET(
  _req: Request,
  { params }: { params: Promise<{ path: string[] }> }
) {
  const { path: segments } = await params;

  try {
    const data = await read(segments.join("/"));
    return new NextResponse(new Uint8Array(data), {
      headers: {
        "Content-Type": "image/png",
        "Cache-Control": "private, max-age=31536000, immutable",
      },
    });
  } catch {
    return NextResponse.json({ error: "Not found" }, { status: 404 });
  }
}

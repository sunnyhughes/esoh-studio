import { NextResponse } from "next/server";
import { tick } from "@/lib/batch";

export const dynamic = "force-dynamic";
// One tick is one image call, and image calls are slow.
export const maxDuration = 300;

/**
 * Do the next page of a run.
 *
 * One page per request on purpose. It keeps every request inside a sane
 * timeout, it makes an interrupted run resumable at exactly the page it
 * stopped on, and it means the spending stops when the caller does — which for
 * a tool with no process supervision and a metered account is a feature and not
 * a limitation.
 */
export async function POST(
  _req: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    return NextResponse.json(await tick(id));
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    return NextResponse.json({ error: message }, { status: 500 });
  }
}

import { NextResponse } from "next/server";
import { one } from "@/lib/db";

const STATUSES = ["draft", "approved", "rejected"];

/** Keep / Reject / favourite from the results grid. */
export async function PATCH(
  req: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    const body = (await req.json()) as {
      status?: string;
      is_favorite?: boolean;
    };

    if (body.status && !STATUSES.includes(body.status)) {
      return NextResponse.json(
        { error: `status must be one of: ${STATUSES.join(", ")}` },
        { status: 400 }
      );
    }

    const asset = await one(
      `update generated_assets
          set status      = coalesce($2, status),
              is_favorite = coalesce($3, is_favorite)
        where id = $1
        returning id, status, is_favorite`,
      [id, body.status ?? null, body.is_favorite ?? null]
    );

    if (!asset) {
      return NextResponse.json({ error: "Asset not found" }, { status: 404 });
    }

    return NextResponse.json(asset);
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    return NextResponse.json({ error: message }, { status: 500 });
  }
}

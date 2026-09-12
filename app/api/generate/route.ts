import { NextResponse } from "next/server";
import {
  runGeneration,
  GenerationRefused,
  type GenerateBody,
} from "@/lib/generate";

export const dynamic = "force-dynamic";
// Image generation is slow; don't let the platform cut it off mid-flight.
export const maxDuration = 300;

/**
 * One job, generated now, for the New Job form.
 *
 * The work itself lives in `lib/generate.ts`, because Stage E runs the same
 * thing without an HTTP request in front of it and two copies of the reference
 * routing, the transparency measurement and the cost accounting would drift
 * apart within a week.
 */
export async function POST(req: Request) {
  try {
    const body = (await req.json()) as GenerateBody;
    return NextResponse.json(await runGeneration(body));
  } catch (err) {
    // A refusal is the request being wrong — a mismatched template, a missing
    // field — and is worth 400 rather than 500, so the form can say which.
    if (err instanceof GenerationRefused) {
      return NextResponse.json({ error: err.message }, { status: 400 });
    }
    const message = err instanceof Error ? err.message : String(err);
    return NextResponse.json({ error: message }, { status: 500 });
  }
}

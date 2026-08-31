import { NextRequest, NextResponse } from "next/server";
import { API_BASE, TOKEN_COOKIE } from "@/lib/api";

export const dynamic = "force-dynamic";

export async function POST(req: NextRequest) {
  const { name, email, password } = await req.json();

  const upstream = await fetch(`${API_BASE}/auth/register`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ name, email, password }),
    cache: "no-store",
  });

  const data = await upstream.json().catch(() => null);
  if (!upstream.ok || !data?.access_token) {
    const detail = Array.isArray(data?.detail)
      ? data.detail[0]?.msg
      : data?.detail;
    return NextResponse.json(
      { detail: detail ?? "Gagal mendaftar" },
      { status: upstream.status || 400 },
    );
  }

  const res = NextResponse.json({ ok: true });
  res.cookies.set(TOKEN_COOKIE, data.access_token, {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "lax",
    path: "/",
    maxAge: 60 * 60 * 24 * 7,
  });
  return res;
}

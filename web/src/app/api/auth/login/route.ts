import { NextRequest, NextResponse } from "next/server";
import { API_BASE, TOKEN_COOKIE } from "@/lib/api";

export const dynamic = "force-dynamic";

export async function POST(req: NextRequest) {
  const { email, password } = await req.json();

  const form = new URLSearchParams({ username: email ?? "", password: password ?? "" });
  const upstream = await fetch(`${API_BASE}/auth/login`, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: form,
    cache: "no-store",
  });

  const data = await upstream.json().catch(() => null);
  if (!upstream.ok || !data?.access_token) {
    return NextResponse.json(
      { detail: data?.detail ?? "Email atau password salah" },
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

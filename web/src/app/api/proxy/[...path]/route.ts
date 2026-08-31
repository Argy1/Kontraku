import { NextRequest, NextResponse } from "next/server";
import { API_BASE, TOKEN_COOKIE } from "@/lib/api";

export const dynamic = "force-dynamic";

async function forward(req: NextRequest, path: string[]) {
  const token = req.cookies.get(TOKEN_COOKIE)?.value;
  const search = req.nextUrl.search;
  const url = `${API_BASE}/${path.map(encodeURIComponent).join("/")}${search}`;

  const headers = new Headers();
  headers.set("Accept", "application/json");
  const ct = req.headers.get("content-type");
  if (ct) headers.set("content-type", ct);
  if (token) headers.set("Authorization", `Bearer ${token}`);

  const method = req.method.toUpperCase();
  const body =
    method === "GET" || method === "HEAD" ? undefined : await req.arrayBuffer();

  const upstream = await fetch(url, {
    method,
    headers,
    body: body && body.byteLength ? body : undefined,
    cache: "no-store",
  });

  // 204/205/304 tidak boleh punya body — NextResponse akan error kalau diberi.
  const noBody =
    upstream.status === 204 ||
    upstream.status === 205 ||
    upstream.status === 304;
  const resBody = noBody ? null : await upstream.arrayBuffer();
  const res = new NextResponse(resBody, {
    status: upstream.status,
    headers: noBody
      ? undefined
      : {
          "content-type":
            upstream.headers.get("content-type") ?? "application/json",
        },
  });

  // token kadaluarsa -> bersihkan cookie supaya klien tahu harus login ulang
  if (upstream.status === 401) {
    res.cookies.delete(TOKEN_COOKIE);
  }
  return res;
}

type Ctx = { params: Promise<{ path: string[] }> };

export async function GET(req: NextRequest, ctx: Ctx) {
  return forward(req, (await ctx.params).path);
}
export async function POST(req: NextRequest, ctx: Ctx) {
  return forward(req, (await ctx.params).path);
}
export async function PATCH(req: NextRequest, ctx: Ctx) {
  return forward(req, (await ctx.params).path);
}
export async function DELETE(req: NextRequest, ctx: Ctx) {
  return forward(req, (await ctx.params).path);
}

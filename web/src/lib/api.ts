import { cookies } from "next/headers";

export const API_BASE =
  process.env.KONTRAKU_API_URL ??
  "https://backend-production-675a5.up.railway.app";

export const TOKEN_COOKIE = "kt_token";

export class ApiError extends Error {
  status: number;
  constructor(message: string, status: number) {
    super(message);
    this.status = status;
  }
}

function friendlyDetail(data: unknown): string | null {
  if (data && typeof data === "object" && "detail" in data) {
    const d = (data as { detail: unknown }).detail;
    if (typeof d === "string") return d;
    if (Array.isArray(d) && d.length && typeof d[0] === "object" && d[0]) {
      const msg = (d[0] as { msg?: unknown }).msg;
      if (typeof msg === "string") return msg;
    }
  }
  return null;
}

/**
 * Server-side fetch ke backend, memakai token dari cookie httpOnly.
 * Dipakai di Server Components / Route Handlers.
 */
export async function serverApi<T = unknown>(
  path: string,
  init: RequestInit & { token?: string | null } = {},
): Promise<T> {
  const { token: explicitToken, ...rest } = init;
  const token =
    explicitToken ?? (await cookies()).get(TOKEN_COOKIE)?.value ?? null;

  const res = await fetch(`${API_BASE}${path}`, {
    ...rest,
    headers: {
      Accept: "application/json",
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...(rest.body && !(rest.body instanceof FormData)
        ? { "Content-Type": "application/json" }
        : {}),
      ...rest.headers,
    },
    cache: "no-store",
  });

  const text = await res.text();
  const data = text ? safeJson(text) : null;

  if (!res.ok) {
    throw new ApiError(
      friendlyDetail(data) ?? `Gagal memuat data (${res.status}).`,
      res.status,
    );
  }
  return data as T;
}

function safeJson(text: string): unknown {
  try {
    return JSON.parse(text);
  } catch {
    return text;
  }
}

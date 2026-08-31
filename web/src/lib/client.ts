"use client";

// Wrapper fetch untuk Client Components. Semua request lewat /api/proxy,
// yang menambahkan token dari cookie httpOnly di sisi server.

export class ClientApiError extends Error {
  status: number;
  constructor(message: string, status: number) {
    super(message);
    this.status = status;
  }
}

async function request<T>(
  method: string,
  path: string,
  body?: unknown,
): Promise<T> {
  const isForm = body instanceof FormData;
  const res = await fetch(`/api/proxy${path}`, {
    method,
    headers: isForm ? undefined : body ? { "Content-Type": "application/json" } : undefined,
    body: isForm ? body : body !== undefined ? JSON.stringify(body) : undefined,
  });

  const text = await res.text();
  const data = text ? JSON.parse(text) : null;

  if (!res.ok) {
    const detail =
      data && typeof data === "object" && typeof data.detail === "string"
        ? data.detail
        : Array.isArray(data?.detail)
          ? data.detail[0]?.msg
          : null;
    throw new ClientApiError(detail ?? `Terjadi kesalahan (${res.status}).`, res.status);
  }
  return data as T;
}

export const api = {
  get: <T>(path: string) => request<T>("GET", path),
  post: <T>(path: string, body?: unknown) => request<T>("POST", path, body),
  patch: <T>(path: string, body?: unknown) => request<T>("PATCH", path, body),
  del: <T>(path: string) => request<T>("DELETE", path),
};

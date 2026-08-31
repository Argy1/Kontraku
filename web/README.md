# Kontraku — Web

Web app Kontraku (Next.js 16 App Router + Tailwind v4 + shadcn/base-ui).
Terhubung ke backend FastAPI yang sama dengan aplikasi mobile.

## Menjalankan lokal

```bash
npm install
npm run dev
```

Buka http://localhost:3000. Secara default web memakai backend produksi di
Railway. Untuk menunjuk backend lain, buat `.env.local`:

```
KONTRAKU_API_URL=http://localhost:8000
```

## Arsitektur singkat

- **BFF (backend-for-frontend).** Token JWT disimpan di cookie `httpOnly`
  (`kt_token`), tidak pernah terekspos ke JavaScript klien.
- `src/proxy.ts` — pengganti `middleware` di Next 16; penjaga rute
  (redirect ke `/login` kalau belum masuk).
- `src/app/api/auth/*` — login / register / logout, men-set & menghapus cookie.
- `src/app/api/proxy/[...path]` — meneruskan request klien ke backend Railway
  sambil menambahkan header `Authorization`.
- `src/lib/api.ts` (`serverApi`) untuk Server Components,
  `src/lib/client.ts` (`api`) untuk Client Components.
- Mutasi memakai `api.*` lalu `router.refresh()` agar data server ter-render ulang.

## Deploy (Vercel)

- Root directory: `web`
- Environment variable: `KONTRAKU_API_URL=https://backend-production-675a5.up.railway.app`
- Framework preset: Next.js (otomatis)

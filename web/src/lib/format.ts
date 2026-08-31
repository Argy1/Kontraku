const idDate = new Intl.DateTimeFormat("id-ID", {
  day: "numeric",
  month: "short",
  year: "numeric",
});
const idDayMonth = new Intl.DateTimeFormat("id-ID", {
  day: "numeric",
  month: "short",
});
const idNum = new Intl.NumberFormat("id-ID");

export function formatDate(value: string | null | undefined): string {
  if (!value) return "-";
  const d = new Date(value);
  return Number.isNaN(d.getTime()) ? "-" : idDate.format(d);
}

export function formatDayMonth(value: string): string {
  return idDayMonth.format(new Date(value));
}

export function toNum(v: number | string | null | undefined): number | null {
  if (v === null || v === undefined) return null;
  const n = typeof v === "number" ? v : parseFloat(v);
  return Number.isNaN(n) ? null : n;
}

export function rupiah(v: number | string | null | undefined): string {
  const n = toNum(v);
  if (n === null) return "-";
  return `Rp ${idNum.format(Math.round(n))}`;
}

export function rupiahShort(v: number | string | null | undefined): string {
  const n = toNum(v);
  if (n === null) return "-";
  if (n >= 1_000_000) {
    const jt = n / 1_000_000;
    const s =
      jt === Math.round(jt)
        ? jt.toFixed(0)
        : jt.toFixed(1).replace(".", ",");
    return `Rp ${s}jt`;
  }
  if (n >= 1000) return `Rp ${Math.round(n / 1000)}rb`;
  return `Rp ${Math.round(n)}`;
}

export function relativeDays(daysLeft: number): string {
  if (daysLeft === 0) return "Hari ini";
  if (daysLeft === 1) return "Besok";
  if (daysLeft > 1) return `${daysLeft} hari lagi`;
  if (daysLeft === -1) return "Kemarin";
  return `Terlambat ${-daysLeft} hari`;
}

export function daysUntil(dateStr: string): number {
  const now = new Date();
  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const d = new Date(dateStr);
  const due = new Date(d.getFullYear(), d.getMonth(), d.getDate());
  return Math.round((due.getTime() - today.getTime()) / 86_400_000);
}

export function greeting(d = new Date()): string {
  const h = d.getHours();
  if (h < 11) return "Selamat pagi";
  if (h < 15) return "Selamat siang";
  if (h < 19) return "Selamat sore";
  return "Selamat malam";
}

/**
 * Ubah URL file dari backend jadi lewat /api/proxy, supaya tidak bergantung
 * pada PUBLIC_BASE_URL backend (yang bisa saja masih localhost).
 */
export function proxiedFileUrl(fileUrl: string | null | undefined): string {
  if (!fileUrl) return "";
  try {
    const u = new URL(fileUrl);
    return `/api/proxy${u.pathname}`;
  } catch {
    return fileUrl.startsWith("/") ? `/api/proxy${fileUrl}` : fileUrl;
  }
}

export function initials(name: string): string {
  const parts = name.trim().split(/\s+/).filter(Boolean);
  if (parts.length === 0) return "?";
  if (parts.length === 1) return parts[0].slice(0, 1).toUpperCase();
  return (parts[0][0] + parts[1][0]).toUpperCase();
}

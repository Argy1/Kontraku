import { cn } from "@/lib/utils";

// Ikon rumah + titik pengingat, digambar inline supaya ikut warna teks.
export function LogoMark({ className }: { className?: string }) {
  return (
    <svg
      viewBox="0 0 32 32"
      fill="none"
      className={cn("size-8", className)}
      aria-hidden
    >
      <path
        d="M5 15.5 16 6l11 9.5V26a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2z"
        fill="currentColor"
        fillOpacity="0.16"
      />
      <path
        d="M4 16 16 5.5 28 16M6.5 14v11.5A1.5 1.5 0 0 0 8 27h6.5v-7h3v7H24a1.5 1.5 0 0 0 1.5-1.5V14"
        stroke="currentColor"
        strokeWidth="2.1"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <circle cx="25" cy="8" r="4" className="fill-brand-amber" />
    </svg>
  );
}

export function Wordmark({
  className,
  showMark = true,
}: {
  className?: string;
  showMark?: boolean;
}) {
  return (
    <span className={cn("inline-flex items-center gap-2", className)}>
      {showMark && <LogoMark className="size-7" />}
      <span className="font-heading text-xl font-semibold tracking-tight">
        Kontraku
      </span>
    </span>
  );
}

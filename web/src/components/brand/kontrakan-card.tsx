import Link from "next/link";
import { MapPin, DoorOpen } from "lucide-react";
import { cn } from "@/lib/utils";
import type { Kontrakan } from "@/lib/types";

// Aksen warna bergantian (plum / rose) seperti di design-reference.
const ACCENTS = [
  {
    bar: "bg-brand-plum",
    glow: "bg-brand-plum/10",
    chip: "bg-brand-plum/12 text-brand-plum dark:text-brand-plum",
  },
  {
    bar: "bg-brand-rose",
    glow: "bg-brand-rose/10",
    chip: "bg-brand-rose/12 text-brand-rose dark:text-brand-rose",
  },
];

export function KontrakanCard({
  kontrakan,
  index = 0,
}: {
  kontrakan: Kontrakan;
  index?: number;
}) {
  const a = ACCENTS[index % ACCENTS.length];
  const empty = kontrakan.unit_count - kontrakan.occupied_count;

  return (
    <Link
      href={`/kontrakan/${kontrakan.id}`}
      className="group relative flex overflow-clip rounded-2xl bg-card ring-1 ring-foreground/10 transition-all hover:-translate-y-0.5 hover:shadow-[var(--shadow-lift)]"
    >
      <span className={cn("w-1.5 shrink-0", a.bar)} />
      <span
        className={cn(
          "pointer-events-none absolute -right-10 -top-10 size-32 rounded-full blur-2xl",
          a.glow,
        )}
      />
      <div className="relative flex-1 p-5">
        <h3 className="font-heading text-lg font-semibold leading-snug text-foreground">
          {kontrakan.name}
        </h3>
        <p className="mt-1 flex items-center gap-1.5 text-sm text-muted-foreground">
          <MapPin className="size-3.5 shrink-0" />
          <span className="line-clamp-1">
            {kontrakan.address || "Alamat belum diisi"}
          </span>
        </p>

        <div className="mt-4 flex flex-wrap items-center gap-2">
          <span
            className={cn(
              "inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-semibold",
              a.chip,
            )}
          >
            <DoorOpen className="size-3.5" />
            {kontrakan.unit_count} unit
          </span>
          <span className="text-xs text-muted-foreground">
            {kontrakan.occupied_count} terisi
            {empty > 0 && ` · ${empty} kosong`}
          </span>
        </div>
      </div>
    </Link>
  );
}

import {
  CalendarClock,
  FileWarning,
  Wrench,
  Zap,
  type LucideIcon,
} from "lucide-react";
import type { ReminderType } from "@/lib/types";

// Peta jenis reminder -> ikon + kelas warna (token "tone" di globals.css).
type ToneMeta = {
  label: string;
  icon: LucideIcon;
  soft: string; // latar lembut + teks pekat
  dot: string; // titik / strip warna solid
  ring: string;
};

export const REMINDER_META: Record<ReminderType, ToneMeta> = {
  sewa_jatuh_tempo: {
    label: "Sewa jatuh tempo",
    icon: CalendarClock,
    soft: "bg-rent-soft text-rent-ink",
    dot: "bg-rent",
    ring: "ring-rent/30",
  },
  kontrak_habis: {
    label: "Kontrak akan habis",
    icon: FileWarning,
    soft: "bg-contract-soft text-contract-ink",
    dot: "bg-contract",
    ring: "ring-contract/30",
  },
  maintenance: {
    label: "Maintenance",
    icon: Wrench,
    soft: "bg-maint-soft text-maint-ink",
    dot: "bg-maint",
    ring: "ring-maint/30",
  },
  utilitas: {
    label: "Tagihan utilitas",
    icon: Zap,
    soft: "bg-utility-soft text-utility-ink",
    dot: "bg-utility",
    ring: "ring-utility/30",
  },
};

import Link from "next/link";
import { BellPlus, BellRing, RefreshCw } from "lucide-react";

import { serverApi } from "@/lib/api";
import type { Kontrakan, KontrakanDetail, Reminder, ReminderType } from "@/lib/types";
import { daysUntil } from "@/lib/format";
import { cn } from "@/lib/utils";
import { REMINDER_META } from "@/lib/reminders";
import { Button } from "@/components/ui/button";
import { PageHeading } from "@/components/brand/page-heading";
import { EmptyState } from "@/components/brand/empty-state";
import { ReminderItem } from "@/components/feature/reminder-item";
import { ReminderForm, type UnitOption } from "@/components/forms/reminder-form";
import { ActionButton } from "@/components/common/action-button";

export const metadata = { title: "Reminder" };

const TYPE_TABS: { value: ReminderType | "all"; label: string }[] = [
  { value: "all", label: "Semua" },
  { value: "sewa_jatuh_tempo", label: "Sewa" },
  { value: "kontrak_habis", label: "Kontrak" },
  { value: "maintenance", label: "Maintenance" },
  { value: "utilitas", label: "Utilitas" },
];

type LocMap = Map<number, string>;

async function loadContext(): Promise<{
  units: UnitOption[];
  loc: LocMap;
}> {
  const kontrakan = await serverApi<Kontrakan[]>("/kontrakan");
  const details = await Promise.all(
    kontrakan.map((k) =>
      serverApi<KontrakanDetail>(`/kontrakan/${k.id}`).catch(() => null),
    ),
  );
  const units: UnitOption[] = [];
  const loc: LocMap = new Map();
  for (const d of details) {
    if (!d) continue;
    for (const u of d.units) {
      units.push({ id: u.id, label: `${d.name} · ${u.name}` });
      loc.set(u.id, `${d.name} · ${u.name}`);
    }
  }
  return { units, loc };
}

export default async function ReminderPage({
  searchParams,
}: {
  searchParams: Promise<{ type?: string }>;
}) {
  const { type } = await searchParams;
  const activeType = TYPE_TABS.some((t) => t.value === type)
    ? (type as ReminderType | "all")
    : "all";

  const query = activeType === "all" ? "" : `?type=${activeType}`;
  const [reminders, ctx] = await Promise.all([
    serverApi<Reminder[]>(`/reminders${query}`),
    loadContext(),
  ]);

  const sorted = [...reminders].sort(
    (a, b) => daysUntil(a.due_date) - daysUntil(b.due_date),
  );
  const groups: { key: string; label: string; items: Reminder[] }[] = [
    { key: "now", label: "Terlambat & hari ini", items: [] },
    { key: "week", label: "Minggu ini", items: [] },
    { key: "later", label: "Nanti", items: [] },
  ];
  for (const r of sorted) {
    const d = daysUntil(r.due_date);
    if (d <= 0) groups[0].items.push(r);
    else if (d <= 7) groups[1].items.push(r);
    else groups[2].items.push(r);
  }

  return (
    <div>
      <PageHeading
        title="Reminder"
        subtitle={`${reminders.length} pengingat aktif`}
        action={
          <div className="flex gap-2">
            <ActionButton
              method="post"
              path="/reminders/refresh"
              successMessage="Pengingat disegarkan."
              trigger={
                <Button variant="outline" className="h-10 rounded-full px-4">
                  <RefreshCw className="size-4" />
                  Segarkan
                </Button>
              }
            />
            <ReminderForm
              units={ctx.units}
              trigger={
                <Button className="h-10 rounded-full px-4">
                  <BellPlus className="size-4" />
                  Tambah
                </Button>
              }
            />
          </div>
        }
      />

      {/* Filter jenis */}
      <div className="mb-6 flex flex-wrap gap-2">
        {TYPE_TABS.map((t) => {
          const on = t.value === activeType;
          return (
            <Link
              key={t.value}
              href={t.value === "all" ? "/reminder" : `/reminder?type=${t.value}`}
              className={cn(
                "rounded-full px-3.5 py-1.5 text-sm font-medium transition-colors",
                on
                  ? "bg-primary text-primary-foreground"
                  : "bg-secondary text-secondary-foreground hover:bg-secondary/70",
              )}
            >
              {t.label}
            </Link>
          );
        })}
      </div>

      {reminders.length === 0 ? (
        <EmptyState
          icon={BellRing}
          title="Tidak ada pengingat"
          description={
            activeType === "all"
              ? "Semua sudah beres. Pengingat sewa & kontrak muncul otomatis saat mendekati jatuh tempo."
              : `Tidak ada pengingat untuk jenis "${
                  REMINDER_META[activeType as ReminderType]?.label ?? activeType
                }".`
          }
        />
      ) : (
        <div className="space-y-7">
          {groups
            .filter((g) => g.items.length > 0)
            .map((g) => (
              <section key={g.key}>
                <h2 className="mb-2.5 text-sm font-semibold uppercase tracking-wide text-muted-foreground">
                  {g.label}{" "}
                  <span className="text-muted-foreground/60">
                    ({g.items.length})
                  </span>
                </h2>
                <div className="space-y-2.5">
                  {g.items.map((r) => (
                    <ReminderItem
                      key={r.id}
                      reminder={r}
                      location={ctx.loc.get(r.unit_id)}
                    />
                  ))}
                </div>
              </section>
            ))}
        </div>
      )}
    </div>
  );
}

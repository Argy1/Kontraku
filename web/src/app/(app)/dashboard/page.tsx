import Link from "next/link";
import { ArrowRight, Building2, Plus, Sparkles } from "lucide-react";

import { serverApi } from "@/lib/api";
import type { Dashboard } from "@/lib/types";
import { buttonVariants } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { DecorCircles } from "@/components/brand/decor";
import { Greeting } from "@/components/brand/greeting";
import { AttentionCard } from "@/components/brand/attention-card";
import { KontrakanCard } from "@/components/brand/kontrakan-card";
import { EmptyState } from "@/components/brand/empty-state";

export const metadata = { title: "Beranda" };

export default async function DashboardPage() {
  const data = await serverApi<Dashboard>("/dashboard");

  return (
    <div className="space-y-8">
      {/* Hero */}
      <section className="rise-0 relative overflow-clip rounded-3xl bg-[linear-gradient(135deg,#0f6e56,#0b5142_55%,#083a2f)] px-6 py-7 text-white shadow-[var(--shadow-soft)] sm:px-9 sm:py-9">
        <DecorCircles
          variant="teal"
          className="-right-16 -top-20 h-72 w-72 opacity-90"
        />
        <div className="relative z-10">
          <p className="font-heading text-2xl font-semibold sm:text-[1.75rem]">
            <Greeting name={data.greeting_name} />
          </p>
          <p className="mt-1 text-sm text-white/70">
            Ini ringkasan properti sewamu hari ini.
          </p>

          <div className="mt-7 flex gap-8">
            <div>
              <p className="font-heading text-4xl font-semibold">
                {data.kontrakan_count}
              </p>
              <p className="mt-0.5 text-sm text-white/70">Kontrakan</p>
            </div>
            <div className="border-l border-white/15 pl-8">
              <p className="font-heading text-4xl font-semibold">
                {data.active_reminder_count}
              </p>
              <p className="mt-0.5 text-sm text-white/70">Pengingat aktif</p>
            </div>
          </div>
        </div>
      </section>

      {/* Perlu perhatian */}
      <section className="rise-1">
        <div className="mb-3 flex items-center justify-between">
          <h2 className="font-heading text-lg font-semibold text-foreground">
            Perlu perhatian
          </h2>
          {data.attention.length > 0 && (
            <Link
              href="/reminder"
              className="inline-flex items-center gap-1 text-sm font-medium text-primary hover:underline"
            >
              Semua reminder <ArrowRight className="size-3.5" />
            </Link>
          )}
        </div>

        {data.attention.length === 0 ? (
          <EmptyState
            icon={Sparkles}
            title="Semua aman"
            description="Tidak ada jatuh tempo atau kontrak yang mendekati batas dalam waktu dekat."
          />
        ) : (
          <div className="space-y-3">
            {data.attention.map((item) => (
              <AttentionCard key={item.reminder_id} item={item} />
            ))}
          </div>
        )}
      </section>

      {/* Kontrakan */}
      <section className="rise-2">
        <div className="mb-3 flex items-center justify-between">
          <h2 className="font-heading text-lg font-semibold text-foreground">
            Kontrakan kamu
          </h2>
          <Link
            href="/kontrakan"
            className={cn(
              buttonVariants({ variant: "secondary" }),
              "h-9 rounded-full px-4",
            )}
          >
            <Plus className="size-4" />
            Tambah
          </Link>
        </div>

        {data.kontrakan.length === 0 ? (
          <EmptyState
            icon={Building2}
            title="Belum ada kontrakan"
            description="Tambahkan kontrakan pertamamu untuk mulai mencatat unit, penyewa, dan pembayaran."
            action={
              <Link
                href="/kontrakan"
                className={cn(
                  buttonVariants(),
                  "h-10 rounded-full px-5",
                )}
              >
                <Plus className="size-4" />
                Tambah kontrakan
              </Link>
            }
          />
        ) : (
          <div className="grid gap-4 sm:grid-cols-2">
            {data.kontrakan.map((k, i) => (
              <KontrakanCard key={k.id} kontrakan={k} index={i} />
            ))}
          </div>
        )}
      </section>
    </div>
  );
}

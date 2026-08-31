import { notFound } from "next/navigation";
import {
  Archive,
  BellPlus,
  CalendarRange,
  Pencil,
  Phone,
  Plus,
  Trash2,
  UserPlus,
  Wallet,
} from "lucide-react";

import { serverApi, ApiError } from "@/lib/api";
import type { Payment, Tenant, Unit } from "@/lib/types";
import { formatDate, rupiah } from "@/lib/format";
import { Button } from "@/components/ui/button";
import { PageHeading } from "@/components/brand/page-heading";
import { StatusBadge } from "@/components/brand/badges";
import { EmptyState } from "@/components/brand/empty-state";
import { UnitForm } from "@/components/forms/unit-form";
import { TenantForm } from "@/components/forms/tenant-form";
import { PaymentForm } from "@/components/forms/payment-form";
import { ReminderForm } from "@/components/forms/reminder-form";
import { DeleteAction } from "@/components/common/delete-action";
import { ActionButton } from "@/components/common/action-button";

export async function generateMetadata({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  try {
    const u = await serverApi<Unit>(`/units/${id}`);
    return { title: u.name };
  } catch {
    return { title: "Unit" };
  }
}

export default async function UnitDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;

  let unit: Unit;
  try {
    unit = await serverApi<Unit>(`/units/${id}`);
  } catch (err) {
    if (err instanceof ApiError && err.status === 404) notFound();
    throw err;
  }

  const tenants = await serverApi<Tenant[]>(
    `/units/${id}/tenants?include_inactive=true`,
  );
  const active = tenants.find((t) => t.is_active) ?? null;
  const past = tenants.filter((t) => !t.is_active);
  const payments = active
    ? await serverApi<Payment[]>(`/tenants/${active.id}/payments`)
    : [];

  return (
    <div className="space-y-7">
      <PageHeading
        back={{
          href: `/kontrakan/${unit.kontrakan_id}`,
          label: "Kembali ke kontrakan",
        }}
        title={unit.name}
        action={
          <div className="flex gap-2">
            <UnitForm
              kontrakanId={unit.kontrakan_id}
              initial={unit}
              trigger={
                <Button variant="outline" className="h-10 rounded-full px-4">
                  <Pencil className="size-4" />
                  Ubah
                </Button>
              }
            />
            <DeleteAction
              path={`/units/${unit.id}`}
              redirectTo={`/kontrakan/${unit.kontrakan_id}`}
              title="Hapus unit ini?"
              description="Penyewa, pembayaran, dan pengingat unit ini ikut terhapus."
              successMessage="Unit dihapus."
              trigger={
                <Button
                  variant="ghost"
                  size="icon"
                  className="size-10 rounded-full text-muted-foreground hover:text-destructive"
                >
                  <Trash2 className="size-4" />
                </Button>
              }
            />
          </div>
        }
      />

      <div className="-mt-3 flex flex-wrap items-center gap-3">
        <StatusBadge status={unit.status} />
        <span className="text-sm text-muted-foreground">
          {unit.price != null ? `${rupiah(unit.price)} / bulan` : "Harga belum diisi"}
        </span>
      </div>

      {/* Penyewa aktif */}
      <section>
        <div className="mb-3 flex items-center justify-between">
          <h2 className="font-heading text-lg font-semibold">Penyewa aktif</h2>
          {!active && (
            <TenantForm
              unitId={unit.id}
              trigger={
                <Button variant="secondary" className="h-9 rounded-full px-4">
                  <UserPlus className="size-4" />
                  Tambah penyewa
                </Button>
              }
            />
          )}
        </div>

        {!active ? (
          <EmptyState
            icon={UserPlus}
            title="Unit ini kosong"
            description="Tambahkan penyewa beserta tanggal kontrak dan jatuh tempo agar pengingat sewa muncul otomatis."
          />
        ) : (
          <div className="rounded-2xl bg-card p-5 ring-1 ring-foreground/10">
            <div className="flex items-start justify-between gap-3">
              <div>
                <p className="font-heading text-lg font-semibold">
                  {active.name}
                </p>
                {active.phone && (
                  <a
                    href={`tel:${active.phone}`}
                    className="mt-0.5 flex items-center gap-1.5 text-sm text-muted-foreground hover:text-foreground"
                  >
                    <Phone className="size-3.5" />
                    {active.phone}
                  </a>
                )}
              </div>
              <div className="flex gap-1.5">
                <TenantForm
                  unitId={unit.id}
                  initial={active}
                  trigger={
                    <Button
                      variant="ghost"
                      size="icon-sm"
                      className="text-muted-foreground"
                    >
                      <Pencil className="size-4" />
                    </Button>
                  }
                />
                <ActionButton
                  method="post"
                  path={`/tenants/${active.id}/archive`}
                  successMessage="Penyewa diarsipkan."
                  confirm={{
                    title: "Arsipkan penyewa ini?",
                    description:
                      "Kontrak dianggap selesai. Data tetap tersimpan di riwayat.",
                    confirmLabel: "Arsipkan",
                  }}
                  trigger={
                    <Button
                      variant="ghost"
                      size="icon-sm"
                      className="text-muted-foreground"
                    >
                      <Archive className="size-4" />
                    </Button>
                  }
                />
              </div>
            </div>

            <dl className="mt-4 grid grid-cols-2 gap-4 text-sm sm:grid-cols-4">
              <div>
                <dt className="text-muted-foreground">Sewa / bulan</dt>
                <dd className="mt-0.5 font-medium">
                  {rupiah(active.rent_amount)}
                </dd>
              </div>
              <div>
                <dt className="text-muted-foreground">Jatuh tempo</dt>
                <dd className="mt-0.5 font-medium">
                  {active.due_day ? `Tanggal ${active.due_day}` : "-"}
                </dd>
              </div>
              <div>
                <dt className="text-muted-foreground">Mulai</dt>
                <dd className="mt-0.5 font-medium">
                  {formatDate(active.contract_start)}
                </dd>
              </div>
              <div>
                <dt className="text-muted-foreground">Berakhir</dt>
                <dd className="mt-0.5 font-medium">
                  {formatDate(active.contract_end)}
                </dd>
              </div>
            </dl>
          </div>
        )}
      </section>

      {/* Pembayaran */}
      {active && (
        <section>
          <div className="mb-3 flex items-center justify-between">
            <h2 className="font-heading text-lg font-semibold">
              Pembayaran{" "}
              <span className="text-muted-foreground">({payments.length})</span>
            </h2>
            <PaymentForm
              tenantId={active.id}
              defaultAmount={
                active.rent_amount != null ? Number(active.rent_amount) : null
              }
              trigger={
                <Button variant="secondary" className="h-9 rounded-full px-4">
                  <Plus className="size-4" />
                  Catat
                </Button>
              }
            />
          </div>

          {payments.length === 0 ? (
            <EmptyState
              icon={Wallet}
              title="Belum ada pembayaran"
              description="Catat setiap kali penyewa membayar sewa."
            />
          ) : (
            <ul className="divide-y divide-border overflow-hidden rounded-2xl bg-card ring-1 ring-foreground/10">
              {payments.map((p) => (
                <li
                  key={p.id}
                  className="flex items-center gap-3 p-4"
                >
                  <span className="flex size-9 items-center justify-center rounded-full bg-utility-soft text-utility-ink">
                    <Wallet className="size-4" />
                  </span>
                  <div className="min-w-0 flex-1">
                    <p className="font-medium">{rupiah(p.amount)}</p>
                    <p className="text-xs text-muted-foreground">
                      Dibayar {formatDate(p.paid_date)}
                      {p.period_start &&
                        ` · periode ${formatDate(p.period_start)}`}
                      {p.note && ` · ${p.note}`}
                    </p>
                  </div>
                  <DeleteAction
                    path={`/payments/${p.id}`}
                    title="Hapus catatan pembayaran ini?"
                    successMessage="Pembayaran dihapus."
                    trigger={
                      <Button
                        variant="ghost"
                        size="icon-sm"
                        className="text-muted-foreground hover:text-destructive"
                      >
                        <Trash2 className="size-4" />
                      </Button>
                    }
                  />
                </li>
              ))}
            </ul>
          )}
        </section>
      )}

      {/* Reminder manual */}
      <section>
        <div className="mb-3 flex items-center justify-between">
          <h2 className="font-heading text-lg font-semibold">
            Pengingat unit ini
          </h2>
          <ReminderForm
            unitId={unit.id}
            trigger={
              <Button variant="secondary" className="h-9 rounded-full px-4">
                <BellPlus className="size-4" />
                Tambah
              </Button>
            }
          />
        </div>
        <p className="rounded-2xl border border-dashed border-border bg-card/50 p-4 text-sm text-muted-foreground">
          Pengingat maintenance & utilitas yang kamu buat di sini akan tampil di
          halaman{" "}
          <span className="font-medium text-foreground">Reminder</span>. Pengingat
          sewa & kontrak dibuat otomatis dari data penyewa.
        </p>
      </section>

      {/* Riwayat penyewa */}
      {past.length > 0 && (
        <section>
          <h2 className="mb-3 font-heading text-lg font-semibold">
            Riwayat penyewa
          </h2>
          <ul className="space-y-2">
            {past.map((t) => (
              <li
                key={t.id}
                className="flex items-center gap-3 rounded-xl border border-border p-3.5 text-sm"
              >
                <CalendarRange className="size-4 shrink-0 text-muted-foreground" />
                <span className="font-medium">{t.name}</span>
                <span className="text-muted-foreground">
                  {formatDate(t.contract_start)} – {formatDate(t.contract_end)}
                </span>
              </li>
            ))}
          </ul>
        </section>
      )}
    </div>
  );
}

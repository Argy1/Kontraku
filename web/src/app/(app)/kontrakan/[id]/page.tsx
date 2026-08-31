import Link from "next/link";
import { notFound } from "next/navigation";
import {
  ChevronRight,
  DoorClosed,
  MapPin,
  Pencil,
  Plus,
  Trash2,
} from "lucide-react";

import { serverApi, ApiError } from "@/lib/api";
import type { KontrakanDetail } from "@/lib/types";
import { rupiah } from "@/lib/format";
import { Button } from "@/components/ui/button";
import { PageHeading } from "@/components/brand/page-heading";
import { StatusBadge } from "@/components/brand/badges";
import { EmptyState } from "@/components/brand/empty-state";
import { KontrakanForm } from "@/components/forms/kontrakan-form";
import { UnitForm } from "@/components/forms/unit-form";
import { DeleteAction } from "@/components/common/delete-action";
import { DocumentsCard } from "@/components/feature/documents-card";

export async function generateMetadata({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  try {
    const k = await serverApi<KontrakanDetail>(`/kontrakan/${id}`);
    return { title: k.name };
  } catch {
    return { title: "Kontrakan" };
  }
}

export default async function KontrakanDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;

  let k: KontrakanDetail;
  try {
    k = await serverApi<KontrakanDetail>(`/kontrakan/${id}`);
  } catch (err) {
    if (err instanceof ApiError && err.status === 404) notFound();
    throw err;
  }

  return (
    <div className="space-y-7">
      <PageHeading
        back={{ href: "/kontrakan", label: "Kontrakan" }}
        title={k.name}
        subtitle={
          k.unit_count > 0
            ? `${k.unit_count} unit · ${k.occupied_count} terisi`
            : undefined
        }
        action={
          <div className="flex gap-2">
            <KontrakanForm
              initial={k}
              trigger={
                <Button variant="outline" className="h-10 rounded-full px-4">
                  <Pencil className="size-4" />
                  Ubah
                </Button>
              }
            />
            <DeleteAction
              path={`/kontrakan/${k.id}`}
              redirectTo="/kontrakan"
              title="Hapus kontrakan ini?"
              description="Semua unit, penyewa, dan pembayaran di dalamnya ikut terhapus."
              successMessage="Kontrakan dihapus."
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

      {k.address && (
        <p className="-mt-3 flex items-center gap-1.5 text-sm text-muted-foreground">
          <MapPin className="size-4" />
          {k.address}
        </p>
      )}

      {/* Unit */}
      <section>
        <div className="mb-3 flex items-center justify-between">
          <h2 className="font-heading text-lg font-semibold">
            Unit{" "}
            <span className="text-muted-foreground">({k.units.length})</span>
          </h2>
          <UnitForm
            kontrakanId={k.id}
            trigger={
              <Button variant="secondary" className="h-9 rounded-full px-4">
                <Plus className="size-4" />
                Tambah unit
              </Button>
            }
          />
        </div>

        {k.units.length === 0 ? (
          <EmptyState
            icon={DoorClosed}
            title="Belum ada unit"
            description="Tambahkan kamar / petak yang disewakan di kontrakan ini."
          />
        ) : (
          <ul className="space-y-2.5">
            {k.units.map((u) => (
              <li key={u.id}>
                <Link
                  href={`/unit/${u.id}`}
                  className="flex items-center gap-3 rounded-xl bg-card p-4 ring-1 ring-foreground/10 transition-colors hover:bg-secondary/40"
                >
                  <div className="min-w-0 flex-1">
                    <p className="font-medium text-foreground">{u.name}</p>
                    <p className="text-sm text-muted-foreground">
                      {u.price != null ? `${rupiah(u.price)} / bln` : "Harga belum diisi"}
                    </p>
                  </div>
                  <StatusBadge status={u.status} />
                  <ChevronRight className="size-4 shrink-0 text-muted-foreground" />
                </Link>
              </li>
            ))}
          </ul>
        )}
      </section>

      <DocumentsCard kontrakanId={k.id} documents={k.documents} />
    </div>
  );
}

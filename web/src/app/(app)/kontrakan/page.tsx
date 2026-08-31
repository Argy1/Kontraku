import { Building2, Plus } from "lucide-react";

import { serverApi } from "@/lib/api";
import type { Kontrakan } from "@/lib/types";
import { Button } from "@/components/ui/button";
import { PageHeading } from "@/components/brand/page-heading";
import { KontrakanCard } from "@/components/brand/kontrakan-card";
import { EmptyState } from "@/components/brand/empty-state";
import { KontrakanForm } from "@/components/forms/kontrakan-form";

export const metadata = { title: "Kontrakan" };

export default async function KontrakanPage() {
  const list = await serverApi<Kontrakan[]>("/kontrakan");

  const addButton = (
    <Button className="h-10 rounded-full px-5">
      <Plus className="size-4" />
      Tambah kontrakan
    </Button>
  );

  return (
    <div>
      <PageHeading
        title="Kontrakan"
        subtitle={`${list.length} properti terdaftar`}
        action={<KontrakanForm trigger={addButton} />}
      />

      {list.length === 0 ? (
        <EmptyState
          icon={Building2}
          title="Belum ada kontrakan"
          description="Tambahkan kontrakan pertamamu untuk mulai mencatat unit, penyewa, dan pembayaran."
          action={<KontrakanForm trigger={addButton} />}
        />
      ) : (
        <div className="grid gap-4 sm:grid-cols-2">
          {list.map((k, i) => (
            <KontrakanCard key={k.id} kontrakan={k} index={i} />
          ))}
        </div>
      )}
    </div>
  );
}

"use client";

import { useRouter } from "next/navigation";
import { toast } from "sonner";

import { api, ClientApiError } from "@/lib/client";
import { ConfirmDialog } from "@/components/common/confirm-dialog";
import type { ReactElement } from "react";

/**
 * Tombol hapus generik: DELETE ke `path`, lalu refresh data
 * (atau pindah halaman kalau `redirectTo` diisi).
 */
export function DeleteAction({
  trigger,
  path,
  title,
  description,
  confirmLabel = "Hapus",
  redirectTo,
  successMessage = "Berhasil dihapus.",
}: {
  trigger: ReactElement;
  path: string;
  title: string;
  description?: string;
  confirmLabel?: string;
  redirectTo?: string;
  successMessage?: string;
}) {
  const router = useRouter();

  return (
    <ConfirmDialog
      trigger={trigger}
      title={title}
      description={description}
      confirmLabel={confirmLabel}
      onConfirm={async () => {
        try {
          await api.del(path);
        } catch (err) {
          throw new Error(
            err instanceof ClientApiError ? err.message : "Gagal menghapus.",
          );
        }
        toast.success(successMessage);
        if (redirectTo) router.push(redirectTo);
        router.refresh();
      }}
    />
  );
}

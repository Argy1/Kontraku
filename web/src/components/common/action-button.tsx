"use client";

import { cloneElement, useState, type MouseEvent, type ReactElement } from "react";
import { useRouter } from "next/navigation";
import { toast } from "sonner";

import { api, ClientApiError } from "@/lib/client";
import { ConfirmDialog } from "@/components/common/confirm-dialog";

type Method = "post" | "patch" | "del";

async function call(method: Method, path: string, body?: unknown) {
  if (method === "post") return api.post(path, body);
  if (method === "patch") return api.patch(path, body);
  return api.del(path);
}

/**
 * Tombol aksi generik (POST/PATCH/DELETE) + refresh.
 * Beri `confirm` untuk memunculkan dialog konfirmasi dulu.
 */
export function ActionButton({
  trigger,
  method,
  path,
  body,
  successMessage,
  confirm,
  redirectTo,
}: {
  trigger: ReactElement;
  method: Method;
  path: string;
  body?: unknown;
  successMessage?: string;
  confirm?: { title: string; description?: string; confirmLabel?: string };
  redirectTo?: string;
}) {
  const router = useRouter();
  const [busy, setBusy] = useState(false);

  async function run() {
    setBusy(true);
    try {
      await call(method, path, body);
      if (successMessage) toast.success(successMessage);
      if (redirectTo) router.push(redirectTo);
      router.refresh();
    } catch (err) {
      throw new Error(
        err instanceof ClientApiError ? err.message : "Gagal memproses.",
      );
    } finally {
      setBusy(false);
    }
  }

  if (confirm) {
    return (
      <ConfirmDialog
        trigger={trigger}
        title={confirm.title}
        description={confirm.description}
        confirmLabel={confirm.confirmLabel ?? "Lanjut"}
        destructive={method === "del"}
        onConfirm={run}
      />
    );
  }

  // Tanpa konfirmasi: klik langsung jalan.
  const el = trigger as ReactElement<{
    onClick?: (e: MouseEvent) => void;
    disabled?: boolean;
  }>;
  return cloneElement(el, {
    disabled: busy || el.props.disabled,
    onClick: (e: MouseEvent) => {
      e.preventDefault();
      el.props.onClick?.(e);
      if (!busy)
        void run().catch((err) =>
          toast.error(err instanceof Error ? err.message : "Gagal memproses."),
        );
    },
  });
}

"use client";

import { useState, type ReactElement } from "react";
import { Loader2 } from "lucide-react";
import { toast } from "sonner";

import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { withTrigger } from "@/components/forms/form-kit";

export function ConfirmDialog({
  trigger,
  title,
  description,
  confirmLabel = "Hapus",
  destructive = true,
  onConfirm,
}: {
  trigger: ReactElement;
  title: string;
  description?: string;
  confirmLabel?: string;
  destructive?: boolean;
  onConfirm: () => Promise<void>;
}) {
  const [open, setOpen] = useState(false);
  const [busy, setBusy] = useState(false);

  async function run() {
    setBusy(true);
    try {
      await onConfirm();
      setOpen(false);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Gagal memproses.");
    } finally {
      setBusy(false);
    }
  }

  return (
    <>
      {withTrigger(trigger, () => setOpen(true))}
      <Dialog open={open} onOpenChange={setOpen}>
        <DialogContent className="rounded-2xl sm:max-w-sm">
          <DialogHeader>
            <DialogTitle className="text-lg">{title}</DialogTitle>
            {description && <DialogDescription>{description}</DialogDescription>}
          </DialogHeader>
          <DialogFooter className="mt-1">
            <Button
              type="button"
              variant="outline"
              className="h-10 rounded-xl"
              onClick={() => setOpen(false)}
            >
              Batal
            </Button>
            <Button
              type="button"
              onClick={run}
              disabled={busy}
              className={cn(
                "h-10 rounded-xl px-5",
                destructive &&
                  "bg-destructive text-white hover:bg-destructive/90",
              )}
            >
              {busy ? <Loader2 className="size-4 animate-spin" /> : confirmLabel}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </>
  );
}

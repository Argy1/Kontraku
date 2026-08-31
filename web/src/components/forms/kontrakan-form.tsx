"use client";

import { useState, type ReactElement } from "react";
import { useRouter } from "next/navigation";
import { Loader2 } from "lucide-react";
import { toast } from "sonner";

import { api, ClientApiError } from "@/lib/client";
import type { Kontrakan } from "@/lib/types";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Button } from "@/components/ui/button";
import { Field, inputClass, withTrigger } from "@/components/forms/form-kit";

type Props = {
  trigger: ReactElement;
  initial?: Kontrakan;
};

export function KontrakanForm({ trigger, initial }: Props) {
  const router = useRouter();
  const editing = Boolean(initial);
  const [open, setOpen] = useState(false);
  const [saving, setSaving] = useState(false);

  const [name, setName] = useState(initial?.name ?? "");
  const [address, setAddress] = useState(initial?.address ?? "");

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setSaving(true);
    try {
      const body = { name: name.trim(), address: address.trim() || null };
      if (editing) {
        await api.patch(`/kontrakan/${initial!.id}`, body);
        toast.success("Kontrakan diperbarui.");
      } else {
        await api.post("/kontrakan", body);
        toast.success("Kontrakan ditambahkan.");
      }
      setOpen(false);
      if (!editing) setName("");
      router.refresh();
    } catch (err) {
      toast.error(
        err instanceof ClientApiError ? err.message : "Gagal menyimpan.",
      );
    } finally {
      setSaving(false);
    }
  }

  return (
    <>
      {withTrigger(trigger, () => setOpen(true))}
      <Dialog open={open} onOpenChange={setOpen}>
      <DialogContent className="rounded-2xl sm:max-w-md">
        <DialogHeader>
          <DialogTitle className="text-lg">
            {editing ? "Ubah kontrakan" : "Tambah kontrakan"}
          </DialogTitle>
          <DialogDescription>
            Beri nama yang mudah kamu kenali, misalnya &ldquo;Kontrakan Jl.
            Melati&rdquo;.
          </DialogDescription>
        </DialogHeader>

        <form onSubmit={onSubmit} className="space-y-4">
          <Field label="Nama kontrakan" htmlFor="k-name">
            <Input
              id="k-name"
              required
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="Kontrakan Jl. Melati"
              className={inputClass}
            />
          </Field>
          <Field label="Alamat" htmlFor="k-address" hint="Opsional">
            <Textarea
              id="k-address"
              value={address}
              onChange={(e) => setAddress(e.target.value)}
              placeholder="Jl. Melati No. 12, Bandung"
              className="min-h-20 rounded-xl text-[15px]"
            />
          </Field>

          <DialogFooter className="mt-2">
            <Button
              type="button"
              variant="outline"
              className="h-10 rounded-xl"
              onClick={() => setOpen(false)}
            >
              Batal
            </Button>
            <Button
              type="submit"
              disabled={saving}
              className="h-10 rounded-xl px-5"
            >
              {saving ? <Loader2 className="size-4 animate-spin" /> : "Simpan"}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
      </Dialog>
    </>
  );
}

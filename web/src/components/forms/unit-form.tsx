"use client";

import { useState, type ReactElement } from "react";
import { useRouter } from "next/navigation";
import { Loader2 } from "lucide-react";
import { toast } from "sonner";

import { api, ClientApiError } from "@/lib/client";
import type { Unit, UnitStatus } from "@/lib/types";
import { UNIT_STATUS_LABEL } from "@/lib/types";
import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import {
  Field,
  NativeSelect,
  inputClass,
  withTrigger,
} from "@/components/forms/form-kit";

const STATUSES: UnitStatus[] = ["kosong", "terisi", "renovasi"];

export function UnitForm({
  trigger,
  kontrakanId,
  initial,
}: {
  trigger: ReactElement;
  kontrakanId: number;
  initial?: Unit;
}) {
  const router = useRouter();
  const editing = Boolean(initial);
  const [open, setOpen] = useState(false);
  const [saving, setSaving] = useState(false);

  const [name, setName] = useState(initial?.name ?? "");
  const [status, setStatus] = useState<UnitStatus>(initial?.status ?? "kosong");
  const [price, setPrice] = useState(
    initial?.price != null ? String(initial.price) : "",
  );

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setSaving(true);
    try {
      const body = {
        name: name.trim(),
        status,
        price: price.trim() ? Number(price) : null,
      };
      if (editing) {
        await api.patch(`/units/${initial!.id}`, body);
        toast.success("Unit diperbarui.");
      } else {
        await api.post(`/kontrakan/${kontrakanId}/units`, body);
        toast.success("Unit ditambahkan.");
      }
      setOpen(false);
      if (!editing) {
        setName("");
        setPrice("");
      }
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
            {editing ? "Ubah unit" : "Tambah unit"}
          </DialogTitle>
        </DialogHeader>

        <form onSubmit={onSubmit} className="space-y-4">
          <Field label="Nama / nomor unit" htmlFor="u-name">
            <Input
              id="u-name"
              required
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="Kamar A1"
              className={inputClass}
            />
          </Field>
          <Field label="Status" htmlFor="u-status">
            <NativeSelect
              id="u-status"
              value={status}
              onChange={(e) => setStatus(e.target.value as UnitStatus)}
            >
              {STATUSES.map((s) => (
                <option key={s} value={s}>
                  {UNIT_STATUS_LABEL[s]}
                </option>
              ))}
            </NativeSelect>
          </Field>
          <Field label="Harga sewa / bulan" htmlFor="u-price" hint="Opsional">
            <Input
              id="u-price"
              type="number"
              inputMode="numeric"
              min={0}
              value={price}
              onChange={(e) => setPrice(e.target.value)}
              placeholder="1500000"
              className={inputClass}
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

"use client";

import { useState, type ReactElement } from "react";
import { useRouter } from "next/navigation";
import { Loader2 } from "lucide-react";
import { toast } from "sonner";

import { api, ClientApiError } from "@/lib/client";
import type { Tenant } from "@/lib/types";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import {
  Field,
  FormGrid,
  inputClass,
  withTrigger,
} from "@/components/forms/form-kit";

function dateVal(v: string | null | undefined) {
  return v ? v.slice(0, 10) : "";
}

export function TenantForm({
  trigger,
  unitId,
  initial,
}: {
  trigger: ReactElement;
  unitId: number;
  initial?: Tenant;
}) {
  const router = useRouter();
  const editing = Boolean(initial);
  const [open, setOpen] = useState(false);
  const [saving, setSaving] = useState(false);

  const [name, setName] = useState(initial?.name ?? "");
  const [phone, setPhone] = useState(initial?.phone ?? "");
  const [start, setStart] = useState(dateVal(initial?.contract_start));
  const [end, setEnd] = useState(dateVal(initial?.contract_end));
  const [rent, setRent] = useState(
    initial?.rent_amount != null ? String(initial.rent_amount) : "",
  );
  const [dueDay, setDueDay] = useState(
    initial?.due_day != null ? String(initial.due_day) : "",
  );

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setSaving(true);
    try {
      const body = {
        name: name.trim(),
        phone: phone.trim() || null,
        contract_start: start || null,
        contract_end: end || null,
        rent_amount: rent.trim() ? Number(rent) : null,
        due_day: dueDay.trim() ? Number(dueDay) : null,
      };
      if (editing) {
        await api.patch(`/tenants/${initial!.id}`, body);
        toast.success("Data penyewa diperbarui.");
      } else {
        await api.post(`/units/${unitId}/tenants`, body);
        toast.success("Penyewa ditambahkan.");
      }
      setOpen(false);
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
      <DialogContent className="rounded-2xl sm:max-w-lg">
        <DialogHeader>
          <DialogTitle className="text-lg">
            {editing ? "Ubah penyewa" : "Tambah penyewa"}
          </DialogTitle>
          <DialogDescription>
            Tanggal kontrak & tanggal jatuh tempo dipakai untuk membuat pengingat
            otomatis.
          </DialogDescription>
        </DialogHeader>

        <form onSubmit={onSubmit} className="space-y-4">
          <FormGrid>
            <Field label="Nama penyewa" htmlFor="t-name">
              <Input
                id="t-name"
                required
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder="Budi Santoso"
                className={inputClass}
              />
            </Field>
            <Field label="No. HP / WhatsApp" htmlFor="t-phone" hint="Opsional">
              <Input
                id="t-phone"
                value={phone}
                onChange={(e) => setPhone(e.target.value)}
                placeholder="08123456789"
                className={inputClass}
              />
            </Field>
            <Field label="Mulai kontrak" htmlFor="t-start">
              <Input
                id="t-start"
                type="date"
                value={start}
                onChange={(e) => setStart(e.target.value)}
                className={inputClass}
              />
            </Field>
            <Field label="Akhir kontrak" htmlFor="t-end">
              <Input
                id="t-end"
                type="date"
                value={end}
                onChange={(e) => setEnd(e.target.value)}
                className={inputClass}
              />
            </Field>
            <Field label="Nominal sewa / bulan" htmlFor="t-rent">
              <Input
                id="t-rent"
                type="number"
                inputMode="numeric"
                min={0}
                value={rent}
                onChange={(e) => setRent(e.target.value)}
                placeholder="1500000"
                className={inputClass}
              />
            </Field>
            <Field
              label="Tgl jatuh tempo tiap bulan"
              htmlFor="t-due"
              hint="1–31"
            >
              <Input
                id="t-due"
                type="number"
                inputMode="numeric"
                min={1}
                max={31}
                value={dueDay}
                onChange={(e) => setDueDay(e.target.value)}
                placeholder="5"
                className={inputClass}
              />
            </Field>
          </FormGrid>

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

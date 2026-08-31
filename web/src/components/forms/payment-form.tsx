"use client";

import { useState, type ReactElement } from "react";
import { useRouter } from "next/navigation";
import { Loader2 } from "lucide-react";
import { toast } from "sonner";

import { api, ClientApiError } from "@/lib/client";
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
  FormGrid,
  inputClass,
  withTrigger,
} from "@/components/forms/form-kit";

function today() {
  return new Date().toISOString().slice(0, 10);
}

export function PaymentForm({
  trigger,
  tenantId,
  defaultAmount,
}: {
  trigger: ReactElement;
  tenantId: number;
  defaultAmount?: number | null;
}) {
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const [saving, setSaving] = useState(false);

  const [amount, setAmount] = useState(
    defaultAmount != null ? String(defaultAmount) : "",
  );
  const [paidDate, setPaidDate] = useState(today());
  const [periodStart, setPeriodStart] = useState("");
  const [note, setNote] = useState("");

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setSaving(true);
    try {
      await api.post(`/tenants/${tenantId}/payments`, {
        amount: Number(amount),
        paid_date: paidDate,
        period_start: periodStart || null,
        note: note.trim() || null,
      });
      toast.success("Pembayaran dicatat.");
      setOpen(false);
      setNote("");
      setPeriodStart("");
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
          <DialogTitle className="text-lg">Catat pembayaran</DialogTitle>
        </DialogHeader>

        <form onSubmit={onSubmit} className="space-y-4">
          <Field label="Nominal dibayar" htmlFor="p-amount">
            <Input
              id="p-amount"
              type="number"
              inputMode="numeric"
              min={1}
              required
              value={amount}
              onChange={(e) => setAmount(e.target.value)}
              placeholder="1500000"
              className={inputClass}
            />
          </Field>
          <FormGrid>
            <Field label="Tanggal bayar" htmlFor="p-paid">
              <Input
                id="p-paid"
                type="date"
                required
                value={paidDate}
                onChange={(e) => setPaidDate(e.target.value)}
                className={inputClass}
              />
            </Field>
            <Field
              label="Untuk periode"
              htmlFor="p-period"
              hint="Awal bulan sewa"
            >
              <Input
                id="p-period"
                type="date"
                value={periodStart}
                onChange={(e) => setPeriodStart(e.target.value)}
                className={inputClass}
              />
            </Field>
          </FormGrid>
          <Field label="Catatan" htmlFor="p-note" hint="Opsional">
            <Input
              id="p-note"
              value={note}
              onChange={(e) => setNote(e.target.value)}
              placeholder="Transfer BCA"
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

"use client";

import { useState, type ReactElement } from "react";
import { useRouter } from "next/navigation";
import { Loader2 } from "lucide-react";
import { toast } from "sonner";

import { api, ClientApiError } from "@/lib/client";
import type { ReminderType } from "@/lib/types";
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
  NativeSelect,
  inputClass,
  withTrigger,
} from "@/components/forms/form-kit";

// Hanya jenis manual — sewa & kontrak dibuat otomatis oleh sistem.
const MANUAL_TYPES: { value: ReminderType; label: string }[] = [
  { value: "maintenance", label: "Maintenance" },
  { value: "utilitas", label: "Tagihan utilitas" },
];

export type UnitOption = { id: number; label: string };

export function ReminderForm({
  trigger,
  units,
  unitId,
}: {
  trigger: ReactElement;
  units?: UnitOption[];
  unitId?: number;
}) {
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const [saving, setSaving] = useState(false);

  const [type, setType] = useState<ReminderType>("maintenance");
  const [unit, setUnit] = useState<string>(
    unitId ? String(unitId) : units?.[0] ? String(units[0].id) : "",
  );
  const [dueDate, setDueDate] = useState("");
  const [leadDays, setLeadDays] = useState("3");
  const [title, setTitle] = useState("");

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    const uid = unitId ?? Number(unit);
    if (!uid) {
      toast.error("Pilih unit dulu.");
      return;
    }
    setSaving(true);
    try {
      await api.post("/reminders", {
        unit_id: uid,
        type,
        due_date: dueDate,
        lead_days: Number(leadDays) || 0,
        title: title.trim() || null,
      });
      toast.success("Reminder dibuat.");
      setOpen(false);
      setTitle("");
      setDueDate("");
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
          <DialogTitle className="text-lg">Reminder manual</DialogTitle>
          <DialogDescription>
            Untuk maintenance atau tagihan listrik/air. Pengingat sewa & kontrak
            muncul otomatis dari data penyewa.
          </DialogDescription>
        </DialogHeader>

        <form onSubmit={onSubmit} className="space-y-4">
          <Field label="Jenis" htmlFor="r-type">
            <NativeSelect
              id="r-type"
              value={type}
              onChange={(e) => setType(e.target.value as ReminderType)}
            >
              {MANUAL_TYPES.map((t) => (
                <option key={t.value} value={t.value}>
                  {t.label}
                </option>
              ))}
            </NativeSelect>
          </Field>

          {units && !unitId && (
            <Field label="Unit" htmlFor="r-unit">
              <NativeSelect
                id="r-unit"
                value={unit}
                onChange={(e) => setUnit(e.target.value)}
              >
                {units.map((u) => (
                  <option key={u.id} value={u.id}>
                    {u.label}
                  </option>
                ))}
              </NativeSelect>
            </Field>
          )}

          <Field label="Judul" htmlFor="r-title" hint="Opsional">
            <Input
              id="r-title"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="Servis pompa air"
              className={inputClass}
            />
          </Field>

          <div className="grid grid-cols-2 gap-4">
            <Field label="Tanggal" htmlFor="r-due">
              <Input
                id="r-due"
                type="date"
                required
                value={dueDate}
                onChange={(e) => setDueDate(e.target.value)}
                className={inputClass}
              />
            </Field>
            <Field label="Ingatkan H-" htmlFor="r-lead" hint="hari sebelum">
              <Input
                id="r-lead"
                type="number"
                min={0}
                max={90}
                value={leadDays}
                onChange={(e) => setLeadDays(e.target.value)}
                className={inputClass}
              />
            </Field>
          </div>

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

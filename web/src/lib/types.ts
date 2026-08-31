// Bentuk data dari backend FastAPI (mirror app/schemas).

export type UnitStatus = "kosong" | "terisi" | "renovasi";
export type ReminderType =
  | "sewa_jatuh_tempo"
  | "kontrak_habis"
  | "maintenance"
  | "utilitas";
export type ReminderStatus = "pending" | "sent" | "done" | "dismissed";
export type DocumentType = "ktp" | "surat_kontrak" | "foto" | "lainnya";

export interface User {
  id: number;
  name: string;
  email: string;
  created_at: string;
}

export interface Kontrakan {
  id: number;
  name: string;
  address: string | null;
  latitude: number | string | null;
  longitude: number | string | null;
  created_at: string;
  unit_count: number;
  occupied_count: number;
}

export interface DocumentItem {
  id: number;
  kontrakan_id: number;
  file_url: string;
  type: DocumentType;
  label: string | null;
  created_at: string;
}

export interface Unit {
  id: number;
  kontrakan_id: number;
  name: string;
  status: UnitStatus;
  price: number | string | null;
  created_at: string;
}

export interface KontrakanDetail extends Kontrakan {
  units: Unit[];
  documents: DocumentItem[];
}

export interface Tenant {
  id: number;
  unit_id: number;
  name: string;
  phone: string | null;
  contract_start: string | null;
  contract_end: string | null;
  rent_amount: number | string | null;
  due_day: number | null;
  is_active: boolean;
  created_at: string;
}

export interface Payment {
  id: number;
  tenant_id: number;
  amount: number | string;
  paid_date: string;
  period_start: string | null;
  note: string | null;
  created_at: string;
}

export interface Reminder {
  id: number;
  unit_id: number;
  tenant_id: number | null;
  type: ReminderType;
  due_date: string;
  lead_days: number;
  status: ReminderStatus;
  title: string | null;
  created_at: string;
}

export interface AttentionItem {
  reminder_id: number;
  type: ReminderType;
  title: string;
  due_date: string;
  days_left: number;
  unit_name: string;
  kontrakan_name: string;
}

export interface Dashboard {
  greeting_name: string;
  kontrakan_count: number;
  active_reminder_count: number;
  attention: AttentionItem[];
  kontrakan: Kontrakan[];
}

export const REMINDER_LABEL: Record<ReminderType, string> = {
  sewa_jatuh_tempo: "Sewa jatuh tempo",
  kontrak_habis: "Kontrak akan habis",
  maintenance: "Maintenance",
  utilitas: "Tagihan utilitas",
};

export const UNIT_STATUS_LABEL: Record<UnitStatus, string> = {
  kosong: "Kosong",
  terisi: "Terisi",
  renovasi: "Renovasi",
};

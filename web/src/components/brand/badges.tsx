import { cn } from "@/lib/utils";
import type { UnitStatus, ReminderType } from "@/lib/types";
import { UNIT_STATUS_LABEL } from "@/lib/types";
import { REMINDER_META } from "@/lib/reminders";

const UNIT_STATUS_STYLE: Record<UnitStatus, string> = {
  terisi: "bg-utility-soft text-utility-ink",
  kosong: "bg-muted text-muted-foreground",
  renovasi: "bg-rent-soft text-rent-ink",
};

export function StatusBadge({
  status,
  className,
}: {
  status: UnitStatus;
  className?: string;
}) {
  return (
    <span
      className={cn(
        "inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-semibold",
        UNIT_STATUS_STYLE[status],
        className,
      )}
    >
      <span className="size-1.5 rounded-full bg-current" />
      {UNIT_STATUS_LABEL[status]}
    </span>
  );
}

export function ReminderBadge({
  type,
  className,
  withIcon = true,
}: {
  type: ReminderType;
  className?: string;
  withIcon?: boolean;
}) {
  const meta = REMINDER_META[type];
  const Icon = meta.icon;
  return (
    <span
      className={cn(
        "inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-semibold",
        meta.soft,
        className,
      )}
    >
      {withIcon && <Icon className="size-3.5" />}
      {meta.label}
    </span>
  );
}

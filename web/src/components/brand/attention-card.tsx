import { cn } from "@/lib/utils";
import { relativeDays, formatDate } from "@/lib/format";
import type { AttentionItem } from "@/lib/types";
import { REMINDER_META } from "@/lib/reminders";

export function AttentionCard({ item }: { item: AttentionItem }) {
  const meta = REMINDER_META[item.type];
  const Icon = meta.icon;
  const overdue = item.days_left < 0;
  const urgent = item.days_left <= 2;

  return (
    <div className="flex items-center gap-4 rounded-2xl bg-card p-4 ring-1 ring-foreground/10">
      <span
        className={cn(
          "flex size-11 shrink-0 items-center justify-center rounded-xl",
          meta.soft,
        )}
      >
        <Icon className="size-5" />
      </span>

      <div className="min-w-0 flex-1">
        <p className="truncate font-medium text-foreground">{item.title}</p>
        <p className="truncate text-sm text-muted-foreground">
          {item.kontrakan_name} · {item.unit_name}
        </p>
      </div>

      <div className="shrink-0 text-right">
        <p
          className={cn(
            "text-sm font-semibold",
            overdue
              ? "text-destructive"
              : urgent
                ? "text-rent-ink"
                : "text-foreground",
          )}
        >
          {relativeDays(item.days_left)}
        </p>
        <p className="text-xs text-muted-foreground">
          {formatDate(item.due_date)}
        </p>
      </div>
    </div>
  );
}

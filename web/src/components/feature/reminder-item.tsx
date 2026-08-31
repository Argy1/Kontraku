import { Check, X } from "lucide-react";
import { cn } from "@/lib/utils";
import { formatDate, relativeDays, daysUntil } from "@/lib/format";
import type { Reminder } from "@/lib/types";
import { REMINDER_META } from "@/lib/reminders";
import { Button } from "@/components/ui/button";
import { ActionButton } from "@/components/common/action-button";

export function ReminderItem({
  reminder,
  location,
}: {
  reminder: Reminder;
  location?: string;
}) {
  const meta = REMINDER_META[reminder.type];
  const Icon = meta.icon;
  const left = daysUntil(reminder.due_date);
  const overdue = left < 0;

  return (
    <div
      className={cn(
        "flex items-center gap-4 rounded-2xl bg-card p-4 ring-1",
        overdue ? "ring-destructive/25" : "ring-foreground/10",
      )}
    >
      <span
        className={cn(
          "flex size-11 shrink-0 items-center justify-center rounded-xl",
          meta.soft,
        )}
      >
        <Icon className="size-5" />
      </span>

      <div className="min-w-0 flex-1">
        <p className="truncate font-medium text-foreground">
          {reminder.title || meta.label}
        </p>
        <p className="truncate text-sm text-muted-foreground">
          {location ? `${location} · ` : ""}
          {formatDate(reminder.due_date)}
        </p>
      </div>

      <span
        className={cn(
          "shrink-0 text-sm font-semibold",
          overdue ? "text-destructive" : "text-muted-foreground",
        )}
      >
        {relativeDays(left)}
      </span>

      <div className="flex shrink-0 gap-1">
        <ActionButton
          method="patch"
          path={`/reminders/${reminder.id}`}
          body={{ status: "done" }}
          successMessage="Ditandai selesai."
          trigger={
            <Button
              variant="ghost"
              size="icon-sm"
              className="text-muted-foreground hover:text-utility-ink"
              aria-label="Tandai selesai"
            >
              <Check className="size-4" />
            </Button>
          }
        />
        <ActionButton
          method="patch"
          path={`/reminders/${reminder.id}`}
          body={{ status: "dismissed" }}
          successMessage="Pengingat diabaikan."
          trigger={
            <Button
              variant="ghost"
              size="icon-sm"
              className="text-muted-foreground hover:text-destructive"
              aria-label="Abaikan"
            >
              <X className="size-4" />
            </Button>
          }
        />
      </div>
    </div>
  );
}

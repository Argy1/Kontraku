"use client";

import type { ReactElement, ReactNode } from "react";
import { ChevronDown } from "lucide-react";
import { cn } from "@/lib/utils";
import { Label } from "@/components/ui/label";

/**
 * Bungkus elemen trigger dengan span `display:contents` yang menangkap klik,
 * lalu membuka dialog. Ini menghindari Dialog.Trigger dari Base UI yang bentrok
 * dengan komponen Button kita saat hydration. Dialog dikendalikan lewat `open`.
 */
export function withTrigger(el: ReactElement, onOpen: () => void): ReactNode {
  return (
    <span
      className="contents"
      onClick={() => onOpen()}
      onKeyDown={(e) => {
        if (e.key === "Enter" || e.key === " ") onOpen();
      }}
    >
      {el}
    </span>
  );
}

// Kumpulan potongan form yang dipakai berulang di dialog-dialog.

export function Field({
  label,
  htmlFor,
  hint,
  children,
  className,
}: {
  label: string;
  htmlFor?: string;
  hint?: string;
  children: ReactNode;
  className?: string;
}) {
  return (
    <div className={cn("space-y-1.5", className)}>
      <Label htmlFor={htmlFor} className="text-[13px]">
        {label}
      </Label>
      {children}
      {hint && <p className="text-xs text-muted-foreground">{hint}</p>}
    </div>
  );
}

export function NativeSelect({
  className,
  ...props
}: React.ComponentProps<"select">) {
  return (
    <div className="relative">
      <select
        className={cn(
          "h-11 w-full appearance-none rounded-xl border border-input bg-transparent px-3.5 pr-9 text-[15px] outline-none transition-colors focus-visible:border-ring focus-visible:ring-3 focus-visible:ring-ring/50 dark:bg-input/30",
          className,
        )}
        {...props}
      />
      <ChevronDown className="pointer-events-none absolute right-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
    </div>
  );
}

export const inputClass =
  "h-11 rounded-xl px-3.5 text-[15px]";

export function FormGrid({ children }: { children: ReactNode }) {
  return <div className="grid gap-4 sm:grid-cols-2">{children}</div>;
}

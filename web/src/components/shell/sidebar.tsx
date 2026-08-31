"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { cn } from "@/lib/utils";
import { initials } from "@/lib/format";
import { Wordmark } from "@/components/brand/logo";
import { DecorCircles } from "@/components/brand/decor";
import { ThemeToggle } from "@/components/brand/theme-toggle";
import { LogoutButton } from "@/components/shell/logout-button";
import { NAV_ITEMS, isActive } from "@/components/shell/nav-items";

export function Sidebar({ name, email }: { name: string; email: string }) {
  const pathname = usePathname();

  return (
    <aside className="sticky top-0 hidden h-dvh w-[264px] shrink-0 flex-col overflow-clip bg-sidebar text-sidebar-foreground lg:flex">
      <DecorCircles
        variant="teal"
        className="-top-20 -right-16 h-64 w-64 opacity-80"
      />

      <div className="relative z-10 px-6 pt-7">
        <Wordmark className="text-sidebar-primary-foreground [&_span]:text-white" />
      </div>

      <nav className="relative z-10 mt-8 flex flex-1 flex-col gap-1 px-4">
        {NAV_ITEMS.map((item) => {
          const active = isActive(pathname, item);
          return (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                "group relative flex items-center gap-3 rounded-xl px-3.5 py-3 text-[15px] font-medium transition-colors",
                active
                  ? "bg-sidebar-accent text-white"
                  : "text-sidebar-foreground hover:bg-sidebar-accent/60 hover:text-white",
              )}
            >
              <span
                className={cn(
                  "absolute left-0 top-1/2 h-6 w-1 -translate-y-1/2 rounded-r-full bg-sidebar-primary transition-opacity",
                  active ? "opacity-100" : "opacity-0",
                )}
              />
              <item.icon className="size-5 shrink-0" />
              {item.label}
            </Link>
          );
        })}
      </nav>

      <div className="relative z-10 border-t border-sidebar-border/60 px-5 py-5">
        <div className="flex items-center gap-3">
          <span className="flex size-10 items-center justify-center rounded-full bg-sidebar-accent text-sm font-semibold text-white">
            {initials(name)}
          </span>
          <div className="min-w-0 flex-1">
            <p className="truncate text-sm font-semibold text-white">{name}</p>
            <p className="truncate text-xs text-sidebar-foreground/80">
              {email}
            </p>
          </div>
          <ThemeToggle className="text-sidebar-foreground" />
        </div>
        <LogoutButton className="mt-4 text-sidebar-foreground/90" />
      </div>
    </aside>
  );
}

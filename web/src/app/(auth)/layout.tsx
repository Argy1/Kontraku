import type { ReactNode } from "react";
import { DecorCircles } from "@/components/brand/decor";
import { Wordmark } from "@/components/brand/logo";

export default function AuthLayout({ children }: { children: ReactNode }) {
  return (
    <div className="relative flex min-h-dvh flex-col overflow-clip">
      {/* Latar dekoratif */}
      <DecorCircles className="-top-32 -right-24 h-[420px] w-[420px] opacity-90" />
      <DecorCircles className="-bottom-40 -left-32 h-[520px] w-[520px] rotate-180 opacity-70" />

      <header className="relative z-10 px-6 pt-8 sm:px-10">
        <Wordmark className="text-brand-teal dark:text-primary" />
      </header>

      <main className="relative z-10 flex flex-1 items-center justify-center px-5 py-10">
        <div className="w-full max-w-md rise-0">{children}</div>
      </main>

      <footer className="relative z-10 px-6 pb-8 text-center text-xs text-muted-foreground sm:px-10">
        Kelola kontrakan tanpa lupa jatuh tempo.
      </footer>
    </div>
  );
}

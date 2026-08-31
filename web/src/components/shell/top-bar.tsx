import { Wordmark } from "@/components/brand/logo";
import { ThemeToggle } from "@/components/brand/theme-toggle";

// Bar atas khusus mobile (di desktop sidebar sudah memuat identitas).
export function TopBar() {
  return (
    <header className="sticky top-0 z-30 flex items-center justify-between border-b border-border bg-background/90 px-4 py-3 backdrop-blur-md lg:hidden">
      <Wordmark className="text-brand-teal dark:text-primary" />
      <ThemeToggle className="text-foreground" />
    </header>
  );
}

import Link from "next/link";
import { Wordmark } from "@/components/brand/logo";
import { DecorCircles } from "@/components/brand/decor";
import { buttonVariants } from "@/components/ui/button";
import { cn } from "@/lib/utils";

export default function NotFound() {
  return (
    <div className="relative flex min-h-dvh flex-col items-center justify-center overflow-clip px-6 text-center">
      <DecorCircles className="-top-24 -right-20 h-80 w-80 opacity-80" />
      <DecorCircles className="-bottom-28 -left-24 h-96 w-96 rotate-180 opacity-60" />
      <div className="relative z-10">
        <Wordmark className="justify-center text-brand-teal dark:text-primary" />
        <p className="mt-8 font-heading text-6xl font-semibold text-foreground">
          404
        </p>
        <p className="mt-2 text-muted-foreground">
          Halaman yang kamu cari tidak ada.
        </p>
        <Link
          href="/dashboard"
          className={cn(buttonVariants(), "mt-6 h-11 rounded-full px-6")}
        >
          Ke beranda
        </Link>
      </div>
    </div>
  );
}

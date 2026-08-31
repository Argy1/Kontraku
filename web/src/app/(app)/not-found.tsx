import Link from "next/link";
import { SearchX } from "lucide-react";
import { EmptyState } from "@/components/brand/empty-state";
import { buttonVariants } from "@/components/ui/button";
import { cn } from "@/lib/utils";

export default function AppNotFound() {
  return (
    <div className="py-10">
      <EmptyState
        icon={SearchX}
        title="Tidak ditemukan"
        description="Data yang kamu buka mungkin sudah dihapus atau tautannya salah."
        action={
          <Link
            href="/dashboard"
            className={cn(buttonVariants(), "h-10 rounded-full px-5")}
          >
            Ke beranda
          </Link>
        }
      />
    </div>
  );
}

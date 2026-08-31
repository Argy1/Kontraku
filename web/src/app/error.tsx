"use client";

import { useEffect } from "react";
import { Button } from "@/components/ui/button";
import { RotateCw } from "lucide-react";

export default function GlobalError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    console.error(error);
  }, [error]);

  return (
    <div className="flex min-h-dvh flex-col items-center justify-center px-6 text-center">
      <p className="font-heading text-2xl font-semibold text-foreground">
        Ada yang tidak beres
      </p>
      <p className="mt-2 max-w-sm text-sm text-muted-foreground">
        {error.message || "Gagal memuat halaman. Coba lagi sebentar."}
      </p>
      <Button onClick={reset} className="mt-6 h-11 rounded-full px-6">
        <RotateCw className="size-4" />
        Coba lagi
      </Button>
    </div>
  );
}

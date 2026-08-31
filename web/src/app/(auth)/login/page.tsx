"use client";

import { Suspense, useState } from "react";
import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { ArrowRight, Loader2 } from "lucide-react";
import { toast } from "sonner";

import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";

function LoginForm() {
  const router = useRouter();
  const params = useSearchParams();
  const next = params.get("next") || "/dashboard";

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    try {
      const res = await fetch("/api/auth/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email, password }),
      });
      const data = await res.json().catch(() => null);
      if (!res.ok) {
        toast.error(data?.detail ?? "Gagal masuk. Coba lagi.");
        return;
      }
      router.replace(next);
      router.refresh();
    } catch {
      toast.error("Tidak bisa terhubung ke server.");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="rounded-3xl bg-card p-7 shadow-[var(--shadow-soft)] ring-1 ring-foreground/10 sm:p-9">
      <h1 className="font-heading text-[2rem] leading-tight font-semibold text-foreground">
        Selamat datang kembali
      </h1>
      <p className="mt-2 text-[15px] text-muted-foreground">
        Masuk untuk melihat kontrakan dan pengingatmu.
      </p>

      <form onSubmit={onSubmit} className="mt-7 space-y-4">
        <div className="space-y-2">
          <Label htmlFor="email" className="text-[13px]">
            Email
          </Label>
          <Input
            id="email"
            type="email"
            required
            autoComplete="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="kamu@email.com"
            className="h-12 rounded-xl px-4 text-[15px]"
          />
        </div>
        <div className="space-y-2">
          <Label htmlFor="password" className="text-[13px]">
            Password
          </Label>
          <Input
            id="password"
            type="password"
            required
            autoComplete="current-password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            placeholder="••••••••"
            className="h-12 rounded-xl px-4 text-[15px]"
          />
        </div>

        <Button
          type="submit"
          disabled={loading}
          className="h-12 w-full rounded-xl text-[15px] font-semibold"
        >
          {loading ? (
            <Loader2 className="size-4 animate-spin" />
          ) : (
            <>
              Masuk <ArrowRight className="size-4" />
            </>
          )}
        </Button>
      </form>

      <p className="mt-6 text-center text-sm text-muted-foreground">
        Belum punya akun?{" "}
        <Link
          href="/register"
          className="font-semibold text-primary underline-offset-4 hover:underline"
        >
          Daftar gratis
        </Link>
      </p>
    </div>
  );
}

export default function LoginPage() {
  return (
    <Suspense fallback={null}>
      <LoginForm />
    </Suspense>
  );
}

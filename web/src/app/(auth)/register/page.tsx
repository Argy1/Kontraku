"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { ArrowRight, Loader2 } from "lucide-react";
import { toast } from "sonner";

import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";

export default function RegisterPage() {
  const router = useRouter();
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (password.length < 6) {
      toast.error("Password minimal 6 karakter.");
      return;
    }
    setLoading(true);
    try {
      const res = await fetch("/api/auth/register", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ name, email, password }),
      });
      const data = await res.json().catch(() => null);
      if (!res.ok) {
        toast.error(data?.detail ?? "Gagal mendaftar.");
        return;
      }
      toast.success("Akun dibuat. Selamat datang!");
      router.replace("/dashboard");
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
        Buat akun Kontraku
      </h1>
      <p className="mt-2 text-[15px] text-muted-foreground">
        Langsung pakai — tanpa verifikasi email.
      </p>

      <form onSubmit={onSubmit} className="mt-7 space-y-4">
        <div className="space-y-2">
          <Label htmlFor="name" className="text-[13px]">
            Nama
          </Label>
          <Input
            id="name"
            required
            autoComplete="name"
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="Nama kamu"
            className="h-12 rounded-xl px-4 text-[15px]"
          />
        </div>
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
            autoComplete="new-password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            placeholder="Minimal 6 karakter"
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
              Daftar <ArrowRight className="size-4" />
            </>
          )}
        </Button>
      </form>

      <p className="mt-6 text-center text-sm text-muted-foreground">
        Sudah punya akun?{" "}
        <Link
          href="/login"
          className="font-semibold text-primary underline-offset-4 hover:underline"
        >
          Masuk
        </Link>
      </p>
    </div>
  );
}

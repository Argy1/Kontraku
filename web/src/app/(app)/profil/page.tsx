import { CalendarDays, Mail, Moon, ShieldCheck } from "lucide-react";

import { serverApi } from "@/lib/api";
import type { User } from "@/lib/types";
import { formatDate, initials } from "@/lib/format";
import { PageHeading } from "@/components/brand/page-heading";
import { ThemeToggle } from "@/components/brand/theme-toggle";
import { LogoutButton } from "@/components/shell/logout-button";

export const metadata = { title: "Profil" };

export default async function ProfilPage() {
  const me = await serverApi<User>("/auth/me");

  return (
    <div className="mx-auto max-w-xl">
      <PageHeading title="Profil" />

      <div className="rounded-3xl bg-card p-6 ring-1 ring-foreground/10">
        <div className="flex items-center gap-4">
          <span className="flex size-16 items-center justify-center rounded-2xl bg-brand-teal text-xl font-semibold text-white">
            {initials(me.name)}
          </span>
          <div className="min-w-0">
            <p className="font-heading text-xl font-semibold">{me.name}</p>
            <p className="truncate text-sm text-muted-foreground">{me.email}</p>
          </div>
        </div>

        <dl className="mt-6 space-y-3 text-sm">
          <div className="flex items-center gap-3">
            <Mail className="size-4 text-muted-foreground" />
            <dt className="sr-only">Email</dt>
            <dd>{me.email}</dd>
          </div>
          <div className="flex items-center gap-3">
            <CalendarDays className="size-4 text-muted-foreground" />
            <dt className="sr-only">Bergabung</dt>
            <dd>Bergabung {formatDate(me.created_at)}</dd>
          </div>
          <div className="flex items-center gap-3">
            <ShieldCheck className="size-4 text-muted-foreground" />
            <dd>Login tanpa verifikasi email</dd>
          </div>
        </dl>
      </div>

      <div className="mt-4 flex items-center justify-between rounded-2xl bg-card p-5 ring-1 ring-foreground/10">
        <div className="flex items-center gap-3">
          <Moon className="size-4 text-muted-foreground" />
          <div>
            <p className="text-sm font-medium">Tema tampilan</p>
            <p className="text-xs text-muted-foreground">
              Terang, gelap, atau ikut sistem
            </p>
          </div>
        </div>
        <ThemeToggle className="text-foreground" />
      </div>

      <div className="mt-4 rounded-2xl bg-card p-5 ring-1 ring-foreground/10">
        <LogoutButton className="text-destructive" />
      </div>
    </div>
  );
}

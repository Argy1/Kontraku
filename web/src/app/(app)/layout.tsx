import type { ReactNode } from "react";
import { redirect } from "next/navigation";

import { serverApi, ApiError } from "@/lib/api";
import type { User } from "@/lib/types";
import { Sidebar } from "@/components/shell/sidebar";
import { BottomNav } from "@/components/shell/bottom-nav";
import { TopBar } from "@/components/shell/top-bar";

export default async function AppLayout({ children }: { children: ReactNode }) {
  let me: User;
  try {
    me = await serverApi<User>("/auth/me");
  } catch (err) {
    if (err instanceof ApiError && err.status === 401) redirect("/login");
    throw err;
  }

  return (
    <div className="flex min-h-dvh">
      <Sidebar name={me.name} email={me.email} />

      <div className="flex min-w-0 flex-1 flex-col">
        <TopBar />
        <main className="flex-1 px-4 pb-24 pt-5 sm:px-6 lg:px-10 lg:pb-12 lg:pt-10">
          <div className="mx-auto w-full max-w-5xl">{children}</div>
        </main>
        <BottomNav />
      </div>
    </div>
  );
}

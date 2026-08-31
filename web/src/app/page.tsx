import { redirect } from "next/navigation";
import { cookies } from "next/headers";
import { TOKEN_COOKIE } from "@/lib/api";

// proxy.ts sudah mengalihkan "/", ini hanya cadangan.
export default async function RootPage() {
  const authed = Boolean((await cookies()).get(TOKEN_COOKIE)?.value);
  redirect(authed ? "/dashboard" : "/login");
}

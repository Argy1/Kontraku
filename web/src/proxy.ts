import { NextRequest, NextResponse } from "next/server";
import { TOKEN_COOKIE } from "@/lib/api";

const PROTECTED = ["/dashboard", "/kontrakan", "/unit", "/reminder", "/profil"];
const AUTH_PAGES = ["/login", "/register"];

export function proxy(req: NextRequest) {
  const { pathname } = req.nextUrl;
  const authed = Boolean(req.cookies.get(TOKEN_COOKIE)?.value);

  if (pathname === "/") {
    return NextResponse.redirect(
      new URL(authed ? "/dashboard" : "/login", req.url),
    );
  }

  if (!authed && PROTECTED.some((p) => pathname.startsWith(p))) {
    const url = new URL("/login", req.url);
    url.searchParams.set("next", pathname);
    return NextResponse.redirect(url);
  }

  if (authed && AUTH_PAGES.includes(pathname)) {
    return NextResponse.redirect(new URL("/dashboard", req.url));
  }

  return NextResponse.next();
}

export const config = {
  matcher: ["/((?!api|_next/static|_next/image|favicon.ico|icons|.*\\.png$).*)"],
};

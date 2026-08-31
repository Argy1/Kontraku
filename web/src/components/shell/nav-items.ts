import { Home, Building2, BellRing, User, type LucideIcon } from "lucide-react";

export type NavItem = {
  href: string;
  label: string;
  icon: LucideIcon;
  // cocok kalau pathname diawali salah satu prefix ini
  match: string[];
};

export const NAV_ITEMS: NavItem[] = [
  { href: "/dashboard", label: "Beranda", icon: Home, match: ["/dashboard"] },
  {
    href: "/kontrakan",
    label: "Kontrakan",
    icon: Building2,
    match: ["/kontrakan", "/unit"],
  },
  {
    href: "/reminder",
    label: "Reminder",
    icon: BellRing,
    match: ["/reminder"],
  },
  { href: "/profil", label: "Profil", icon: User, match: ["/profil"] },
];

export function isActive(pathname: string, item: NavItem): boolean {
  return item.match.some(
    (p) => pathname === p || pathname.startsWith(p + "/"),
  );
}

import { cn } from "@/lib/utils";

/**
 * Motif lingkaran bertumpuk khas Kontraku (lihat design-reference.html).
 * Dipakai sebagai latar dekoratif — selalu `pointer-events-none` dan
 * `aria-hidden` supaya tidak mengganggu interaksi / pembaca layar.
 */
export function DecorCircles({
  className,
  variant = "cream",
}: {
  className?: string;
  variant?: "cream" | "teal";
}) {
  const stroke =
    variant === "teal"
      ? ["rgba(255,255,255,0.14)", "rgba(255,255,255,0.09)", "rgba(246,198,103,0.5)"]
      : ["rgba(11,81,66,0.10)", "rgba(11,81,66,0.06)", "rgba(224,152,42,0.35)"];

  return (
    <svg
      aria-hidden
      className={cn("pointer-events-none absolute select-none", className)}
      viewBox="0 0 320 320"
      fill="none"
    >
      <circle cx="150" cy="150" r="150" fill={stroke[1]} opacity="0.5" />
      <circle
        cx="150"
        cy="150"
        r="110"
        stroke={stroke[0]}
        strokeWidth="1.5"
      />
      <circle cx="215" cy="105" r="70" stroke={stroke[0]} strokeWidth="1.5" />
      <circle cx="235" cy="150" r="14" fill={stroke[2]} />
    </svg>
  );
}

"use client";

import { useEffect, useState } from "react";
import { greeting } from "@/lib/format";

// Salam mengikuti jam browser (server memakai UTC, jadi harus di klien).
export function Greeting({ name }: { name: string }) {
  const [text, setText] = useState("Halo");
  useEffect(() => {
    // Jam hanya diketahui di klien; aman menyetel sekali setelah mount.
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setText(greeting());
  }, []);
  return (
    <>
      {text}, {name}
    </>
  );
}

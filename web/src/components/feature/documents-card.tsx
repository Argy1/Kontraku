"use client";

import { useRef, useState } from "react";
import { useRouter } from "next/navigation";
import { FileText, ImageIcon, Loader2, Plus, Trash2 } from "lucide-react";
import { toast } from "sonner";

import { api, ClientApiError } from "@/lib/client";
import { proxiedFileUrl, formatDate } from "@/lib/format";
import type { DocumentItem } from "@/lib/types";
import { Button } from "@/components/ui/button";
import { DeleteAction } from "@/components/common/delete-action";

const TYPE_LABEL: Record<string, string> = {
  ktp: "KTP",
  surat_kontrak: "Surat kontrak",
  foto: "Foto",
  lainnya: "Lainnya",
};

function isImage(url: string) {
  return /\.(png|jpe?g|webp|gif|avif)$/i.test(url);
}

export function DocumentsCard({
  kontrakanId,
  documents,
}: {
  kontrakanId: number;
  documents: DocumentItem[];
}) {
  const router = useRouter();
  const fileRef = useRef<HTMLInputElement>(null);
  const [uploading, setUploading] = useState(false);

  async function onFile(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file) return;
    const fd = new FormData();
    fd.append("file", file);
    fd.append("type", isImage(file.name) ? "foto" : "lainnya");
    setUploading(true);
    try {
      await api.post(`/kontrakan/${kontrakanId}/documents`, fd);
      toast.success("Dokumen diunggah.");
      router.refresh();
    } catch (err) {
      toast.error(
        err instanceof ClientApiError ? err.message : "Gagal mengunggah.",
      );
    } finally {
      setUploading(false);
      if (fileRef.current) fileRef.current.value = "";
    }
  }

  return (
    <section className="rounded-2xl bg-card p-5 ring-1 ring-foreground/10">
      <div className="mb-4 flex items-center justify-between">
        <h2 className="font-heading text-lg font-semibold">Dokumen & foto</h2>
        <input
          ref={fileRef}
          type="file"
          className="hidden"
          onChange={onFile}
          accept="image/*,application/pdf"
        />
        <Button
          type="button"
          variant="secondary"
          className="h-9 rounded-full px-4"
          disabled={uploading}
          onClick={() => fileRef.current?.click()}
        >
          {uploading ? (
            <Loader2 className="size-4 animate-spin" />
          ) : (
            <Plus className="size-4" />
          )}
          Unggah
        </Button>
      </div>

      {documents.length === 0 ? (
        <p className="py-4 text-center text-sm text-muted-foreground">
          Belum ada dokumen. Unggah KTP penyewa, surat kontrak, atau foto unit.
        </p>
      ) : (
        <ul className="grid gap-3 sm:grid-cols-2">
          {documents.map((doc) => {
            const url = proxiedFileUrl(doc.file_url);
            const img = isImage(doc.file_url);
            return (
              <li
                key={doc.id}
                className="flex items-center gap-3 rounded-xl border border-border p-2.5"
              >
                <a
                  href={url}
                  target="_blank"
                  rel="noreferrer"
                  className="flex size-12 shrink-0 items-center justify-center overflow-hidden rounded-lg bg-secondary text-secondary-foreground"
                >
                  {img ? (
                    // eslint-disable-next-line @next/next/no-img-element
                    <img
                      src={url}
                      alt={doc.label ?? "foto"}
                      className="size-full object-cover"
                    />
                  ) : (
                    <FileText className="size-5" />
                  )}
                </a>
                <div className="min-w-0 flex-1">
                  <p className="truncate text-sm font-medium">
                    {doc.label || TYPE_LABEL[doc.type] || "Dokumen"}
                  </p>
                  <p className="text-xs text-muted-foreground">
                    {img ? (
                      <ImageIcon className="mr-1 inline size-3" />
                    ) : null}
                    {formatDate(doc.created_at)}
                  </p>
                </div>
                <DeleteAction
                  path={`/kontrakan/${kontrakanId}/documents/${doc.id}`}
                  title="Hapus dokumen ini?"
                  successMessage="Dokumen dihapus."
                  trigger={
                    <Button
                      type="button"
                      variant="ghost"
                      size="icon-sm"
                      className="text-muted-foreground hover:text-destructive"
                    >
                      <Trash2 className="size-4" />
                    </Button>
                  }
                />
              </li>
            );
          })}
        </ul>
      )}
    </section>
  );
}

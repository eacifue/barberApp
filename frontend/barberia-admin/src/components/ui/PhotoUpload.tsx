import type { ChangeEvent } from 'react'

type PhotoUploadProps = {
  label?: string
  onFileChange?: (file: File | null) => void
}

export function PhotoUpload({ label = 'Foto', onFileChange }: PhotoUploadProps) {
  const handleChange = (event: ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0] ?? null
    onFileChange?.(file)
  }

  return (
    <label className="flex cursor-pointer flex-col items-center justify-center gap-2 rounded-lg border border-dashed border-[var(--border-strong)] bg-[var(--surface-2)] p-6 text-center text-sm text-[var(--text-base)] transition-colors hover:border-brass-ink">
      <span className="font-semibold text-brass-ink">{label}</span>
      <span>Subir imagen</span>
      <input type="file" accept="image/*" className="hidden" onChange={handleChange} />
    </label>
  )
}

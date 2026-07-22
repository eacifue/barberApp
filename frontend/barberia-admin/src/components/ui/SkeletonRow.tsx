type SkeletonRowProps = {
  templateColumns: string
  columnCount: number
  minWidth?: number
}

export function SkeletonRow({ templateColumns, columnCount, minWidth }: SkeletonRowProps) {
  return (
    <div
      className="grid items-center gap-3 rounded-lg px-3 py-3 skeleton-shimmer bg-[var(--surface3)]"
      style={{ gridTemplateColumns: templateColumns, minWidth }}
    >
      {Array.from({ length: columnCount }).map((_, idx) => (
        <div key={idx} className="h-2.5 rounded bg-white/10" />
      ))}
    </div>
  )
}

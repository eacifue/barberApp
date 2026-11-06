import { useState } from 'react'

type AvatarSize = 'sm' | 'md' | 'lg' | 'xl'

type AvatarProps = {
  fotoUrl?: string
  nombre: string
  apellido: string
  size?: AvatarSize
  dashedFallback?: boolean
}

const sizeMap: Record<AvatarSize, number> = {
  sm: 32,
  md: 40,
  lg: 56,
  xl: 72,
}

// Sistema: iniciales en Gloock sobre latón lavado (design/docs/componentes/Avatar.md).
const initialsColor = { bg: 'var(--brass-soft)', color: 'var(--brass-ink)' }

function UserSilhouetteIcon() {
  return (
    <svg viewBox="0 0 24 24" className="h-5 w-5" fill="none" aria-hidden="true">
      <circle cx="12" cy="9" r="3.2" stroke="currentColor" strokeWidth="1.6" />
      <path d="M5.5 19c1-3 3.4-4.7 6.5-4.7S17.5 16 18.5 19" stroke="currentColor" strokeWidth="1.6" />
    </svg>
  )
}

export function Avatar({ fotoUrl, nombre, apellido, size = 'md', dashedFallback = false }: AvatarProps) {
  const [imgError, setImgError] = useState(false)
  const fullName = `${nombre} ${apellido}`.trim()
  const initials = `${nombre?.[0] ?? ''}${apellido?.[0] ?? ''}`.toUpperCase()
  const avatarSize = sizeMap[size]

  if (!fotoUrl && !nombre && !apellido) {
    return (
      <div
        className={[
          'inline-flex items-center justify-center rounded-full bg-brass-soft text-brass-ink',
          dashedFallback ? 'border border-dashed border-brass-ink' : '',
        ].join(' ')}
        style={{ width: avatarSize, height: avatarSize }}
        title="Foto pendiente"
      >
        <UserSilhouetteIcon />
      </div>
    )
  }

  if (fotoUrl && !imgError) {
    return (
      <img
        src={fotoUrl}
        alt={fullName}
        onError={() => setImgError(true)}
        className="rounded-full object-cover"
        style={{ width: avatarSize, height: avatarSize }}
      />
    )
  }

  if (!nombre && !apellido) {
    return (
      <div
        className={[
          'inline-flex items-center justify-center rounded-full bg-brass-soft text-brass-ink',
          dashedFallback ? 'border border-dashed border-brass-ink' : '',
        ].join(' ')}
        style={{ width: avatarSize, height: avatarSize }}
        title="Foto pendiente"
      >
        <UserSilhouetteIcon />
      </div>
    )
  }

  return (
    <div
      className={[
        'inline-flex items-center justify-center rounded-full font-display',
        dashedFallback ? 'border border-dashed border-brass-ink' : '',
      ].join(' ')}
      style={{
        width: avatarSize,
        height: avatarSize,
        background: initialsColor.bg,
        color: initialsColor.color,
        fontSize: avatarSize >= 56 ? 18 : 13,
      }}
      title={fullName}
    >
      {initials || '--'}
    </div>
  )
}

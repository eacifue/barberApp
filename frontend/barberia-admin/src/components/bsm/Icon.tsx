import { useId, type CSSProperties } from 'react'

import { cx } from './format'
import { ICONS, type IconName } from './icons'

type IconProps = {
  name: IconName
  size?: number
  /** Solo si el ícono va sin texto y comunica algo. */
  label?: string
  strokeWidth?: number
  className?: string
}

export function Icon({ name, size = 20, label, strokeWidth = 2, className }: IconProps) {
  return (
    <svg
      className={cx('bsm-icon', className)}
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth={strokeWidth}
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden={label ? undefined : true}
      role={label ? 'img' : undefined}
      aria-label={label}
      dangerouslySetInnerHTML={{ __html: ICONS[name] ?? ICONS.circle }}
    />
  )
}

const POLE_STRIPES = (() => {
  let s = ''
  for (let i = 0, y = -30; y < 130; y += 14, i++) {
    s += `<rect x="-40" y="${y}" width="160" height="7" fill="${i % 2 ? '#7B2D26' : '#C6A15B'}"/>`
  }
  return s
})()

function emblemMarkup(id: string) {
  const clip = `<clipPath id="bsm-pole-${id}"><rect x="26" y="18" width="20" height="58" rx="10"/></clipPath>`
  const pole = `<rect x="26" y="18" width="20" height="58" rx="10" fill="#F6F2EA"/><g clip-path="url(#bsm-pole-${id})"><g transform="rotate(-35 36 47)">${POLE_STRIPES}</g></g>`
  const light = `<g class="bsm-logo-onlight"><path d="M0 84V36A36 36 0 0 1 72 36V84Z" fill="#1C1814"/><path d="M8 84V36A28 28 0 0 1 64 36V84" fill="none" stroke="#C6A15B" stroke-width="2.5"/>${pole}</g>`
  const dark = `<g class="bsm-logo-ondark"><path d="M2.5 84V36A33.5 33.5 0 0 1 69.5 36V84" fill="none" stroke="#C6A15B" stroke-width="5"/><path d="M8 84V36A28 28 0 0 1 64 36V84" fill="none" stroke="#C6A15B" stroke-width="1.75"/>${pole}</g>`
  return `<defs>${clip}</defs>${light}${dark}`
}

type LogoProps = {
  variant?: 'horizontal' | 'emblem'
  height?: number
  /** `auto` sigue el tema; `dark` fuerza la versión para fondos oscuros (p. ej. sobre `carbon`). */
  surface?: 'auto' | 'light' | 'dark'
  className?: string
}

/** El Portal: arco de fachada con el poste de barbero (design/docs/componentes/Logo.md). */
export function Logo({ variant = 'horizontal', height, surface = 'auto', className }: LogoProps) {
  const id = useId().replace(/:/g, '')
  const h = height ?? (variant === 'emblem' ? 48 : 40)
  const mark = (
    <svg
      className="bsm-logo-mark"
      viewBox="0 0 72 84"
      width={(h * 72) / 84}
      height={h}
      aria-hidden="true"
      dangerouslySetInnerHTML={{ __html: emblemMarkup(id) }}
    />
  )
  const cls = cx('bsm-logo', `bsm-logo-${variant}`, `bsm-logo-surface-${surface}`, className)
  if (variant === 'emblem') {
    return (
      <span className={cls} role="img" aria-label="BarberShop Medellín">
        {mark}
      </span>
    )
  }
  return (
    <span className={cls} role="img" aria-label="BarberShop Medellín" style={{ '--bsm-logo-h': `${h}px` } as CSSProperties}>
      {mark}
      <span className="bsm-logo-words" aria-hidden="true">
        <span className="bsm-logo-name">BarberShop</span>
        <span className="bsm-logo-city">Medellín</span>
      </span>
    </span>
  )
}

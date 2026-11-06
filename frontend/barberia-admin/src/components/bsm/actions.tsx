import { isValidElement, type ReactNode } from 'react'

import { Button, type ButtonSize, type ButtonVariant } from './controls'
import type { IconName } from './icons'

export type ActionSpec = { label: string; variant?: ButtonVariant; icon?: IconName; size?: ButtonSize; onClick?: () => void; loading?: boolean; disabled?: boolean }

/** Acciones como nodos o como objetos `{label, variant, icon, onClick}` pintados con `Button`. */
export function renderActions(list: ReactNode | ActionSpec[], defaultSize: ButtonSize = 'sm'): ReactNode {
  if (!Array.isArray(list)) return list
  return list.map((a, i) => {
    if (a == null || isValidElement(a)) return a
    const spec = a as ActionSpec
    return (
      <Button
        key={spec.label || i}
        variant={spec.variant ?? 'secondary'}
        size={spec.size ?? defaultSize}
        icon={spec.icon}
        onClick={spec.onClick}
        loading={spec.loading}
        disabled={spec.disabled}
      >
        {spec.label}
      </Button>
    )
  })
}

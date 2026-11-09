import type { ReactNode } from 'react'

import { Logo, Tabs } from '../../components/bsm'
import { useTheme } from '../../components/theme/themeContext'

/** Panel de marca sobre `carbon` + columna del formulario (design/pantallas/panel-web/Login-panel). */
export function AuthLayout({ children }: { children: ReactNode }) {
  const { theme, setChoice } = useTheme()
  return (
    <div className="flex min-h-dvh flex-wrap bg-bg text-ink">
      <section
        data-theme="dark"
        aria-label="BarberShop Medellín"
        className="flex min-h-60 flex-[1_1_480px] flex-col justify-between gap-8 bg-carbon px-6 py-8 text-ink md:px-14 md:py-12"
      >
        <Logo variant="horizontal" surface="dark" height={44} />
        <div className="flex max-w-[520px] flex-col gap-4">
          <h2 className="font-display text-[36px] leading-[40px] tracking-[-0.01em] md:text-[48px] md:leading-[52px]">Agenda, clientes y equipo en un solo lugar.</h2>
          <p className="text-body-lg text-ink-muted">Confirma citas, atiende a quien llama y mira cómo va el día desde recepción o desde el celular.</p>
        </div>
        <p className="text-caption text-ink-muted">Medellín, Colombia</p>
      </section>

      <section className="flex flex-[1_1_480px] flex-col px-6 pb-10 pt-6 md:px-8">
        <div className="flex justify-end">
          <Tabs
            variant="segmented"
            label="Tema"
            value={theme}
            onChange={(v) => setChoice(v === 'dark' ? 'oscuro' : 'claro')}
            items={[
              { value: 'light', label: 'Claro', icon: 'sun' },
              { value: 'dark', label: 'Oscuro', icon: 'moon' },
            ]}
          />
        </div>
        <div className="flex flex-1 items-center justify-center py-8">{children}</div>
      </section>
    </div>
  )
}

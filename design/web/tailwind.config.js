const v = (n) => `var(--${n})`;
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./index.html', './src/**/*.{js,jsx,ts,tsx}'],
  darkMode: ['selector', '[data-theme="dark"]'], // Tailwind ≥ 3.4.1; antes: ['class', '[data-theme="dark"]']
  theme: {
    extend: {
      colors: {
        bg: v('bg'),
        surface: { DEFAULT: v('surface'), raised: v('surface-raised'), sunken: v('surface-sunken') },
        line: { DEFAULT: v('line'), strong: v('line-strong') },
        scrim: v('scrim'),
        ink: { DEFAULT: v('ink'), muted: v('ink-muted'), disabled: v('ink-disabled') },
        brass: { DEFAULT: v('brass'), strong: v('brass-strong'), ink: v('brass-ink'), soft: v('brass-soft'), on: v('on-brass') },
        oxblood: { DEFAULT: v('oxblood'), soft: v('oxblood-soft') },
        carbon: v('carbon'), ivory: v('ivory'),
        inverse: { DEFAULT: v('inverse'), on: v('on-inverse'), action: v('inverse-action') },
        success: { DEFAULT: v('success'), bg: v('success-bg') },
        warning: { DEFAULT: v('warning'), bg: v('warning-bg') },
        danger: { DEFAULT: v('danger'), bg: v('danger-bg'), on: v('on-danger') },
        info: { DEFAULT: v('info'), bg: v('info-bg') },
        neutral: { DEFAULT: v('neutral'), bg: v('neutral-bg') },
        status: {
          pendiente: v('status-pendiente'), 'pendiente-bg': v('status-pendiente-bg'),
          confirmada: v('status-confirmada'), 'confirmada-bg': v('status-confirmada-bg'),
          enprogreso: v('status-enprogreso'), 'enprogreso-bg': v('status-enprogreso-bg'),
          completada: v('status-completada'), 'completada-bg': v('status-completada-bg'),
          cancelada: v('status-cancelada'), 'cancelada-bg': v('status-cancelada-bg'),
          noshow: v('status-noshow'), 'noshow-bg': v('status-noshow-bg'),
        },
        slot: { available: v('slot-available'), booked: v('slot-booked'), blocked: v('slot-blocked'), hold: v('slot-hold') },
        focus: v('focus'), now: v('now-line'),
        chart: { 1: v('chart-1'), 2: v('chart-2'), 3: v('chart-3'), 4: v('chart-4'), 5: v('chart-5') },
      },
      fontFamily: { display: v('font-display'), sans: v('font-sans') },
      fontSize: {
        'display-lg': ['40px', { lineHeight: '44px', letterSpacing: '-0.01em' }],
        display: ['32px', '36px'], 'title-lg': ['24px', '30px'], kpi: ['36px', { lineHeight: '40px', letterSpacing: '-0.01em' }],
        title: ['20px', { lineHeight: '26px', fontWeight: '600' }], 'title-sm': ['17px', { lineHeight: '24px', fontWeight: '600' }],
        'body-lg': ['16px', '24px'], body: ['14px', '20px'],
        label: ['15px', { lineHeight: '20px', fontWeight: '600' }], 'label-sm': ['13px', { lineHeight: '16px', fontWeight: '600' }],
        caption: ['12px', { lineHeight: '16px', fontWeight: '500' }], overline: ['11px', { lineHeight: '16px', letterSpacing: '0.08em', fontWeight: '600' }],
        numeric: ['28px', { lineHeight: '32px', letterSpacing: '-0.01em', fontWeight: '600' }],
      },
      borderRadius: { xs: v('radius-xs'), sm: v('radius-sm'), md: v('radius-md'), lg: v('radius-lg'), xl: v('radius-xl') },
      boxShadow: { sm: v('shadow-sm'), md: v('shadow-md'), lg: v('shadow-lg'), focus: v('focus-ring') },
      height: { 'control-sm': '36px', control: '44px', 'control-lg': '52px', topbar: '64px' },
      width: { sidebar: '264px' },
      transitionDuration: { fast: '120ms', base: '200ms', slow: '320ms' },
      transitionTimingFunction: { standard: 'cubic-bezier(0.2, 0, 0, 1)', enter: 'cubic-bezier(0.05, 0.7, 0.1, 1)', exit: 'cubic-bezier(0.3, 0, 0.8, 0.15)' },
      screens: { sm: '390px', md: '768px', lg: '1280px', xl: '1440px' },
    },
  },
};

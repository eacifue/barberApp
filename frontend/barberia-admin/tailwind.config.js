/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        gold: {
          DEFAULT: '#B8860B',
          light: '#D4A017',
          subtle: 'rgba(184,134,11,0.10)',
        },
        ink: {
          DEFAULT: '#0A0A0A',
          2: '#1a1a1a',
          3: '#2d2d2d',
        },
        surface: {
          DEFAULT: '#141414',
          2: '#1c1c1c',
          3: '#222222',
        },
        muted: '#6b6b6b',
        // Semantic colors that respond to theme via CSS variables
        'color-strong': 'var(--text-strong)',
        'color-base': 'var(--text-base)',
        'color-muted': 'var(--text-muted)',
        'color-faint': 'var(--text-faint)',
      },
      fontFamily: {
        display: ['Iowan Old Style', 'Palatino Linotype', 'Book Antiqua', 'Georgia', 'serif'],
        ui: ['Avenir Next', 'Segoe UI', 'Helvetica Neue', 'Arial', 'sans-serif'],
      },
    },
  },
  plugins: [],
}


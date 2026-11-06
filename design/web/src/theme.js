// Tema claro / oscuro / sistema para el panel. Guarda la elección y aplica data-theme en <html>.
const KEY = 'bsm-theme';
const media = window.matchMedia('(prefers-color-scheme: dark)');

export function getThemeChoice() {
  try { return localStorage.getItem(KEY) || 'sistema'; } catch { return 'sistema'; }
}

function apply(choice) {
  const dark = choice === 'oscuro' || (choice === 'sistema' && media.matches);
  document.documentElement.dataset.theme = dark ? 'dark' : 'light';
}

export function setThemeChoice(choice) { // 'claro' | 'oscuro' | 'sistema'
  try { localStorage.setItem(KEY, choice); } catch {}
  apply(choice);
}

export function initTheme() {
  apply(getThemeChoice());
  media.addEventListener('change', () => { if (getThemeChoice() === 'sistema') apply('sistema'); });
}

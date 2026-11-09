/** Lee el claim `barberiaId` del JWT (el panel no valida la firma: eso lo hace la API). */
export function barberiaIdDelToken(token: string | null | undefined): string | null {
  const payload = token?.split('.')[1]
  if (!payload) return null
  try {
    const json = atob(payload.replace(/-/g, '+').replace(/_/g, '/').padEnd(Math.ceil(payload.length / 4) * 4, '='))
    const valor = (JSON.parse(json) as { barberiaId?: unknown }).barberiaId
    return typeof valor === 'string' ? valor : null
  } catch {
    return null
  }
}

import type { QueryClient } from '@tanstack/react-query'

/** Invalida todo lo que depende de las citas (agenda, historial, dashboard, contador del menú, disponibilidad). */
export async function invalidarCitas(queryClient: QueryClient) {
  await Promise.all(
    ['agenda', 'agenda-historial', 'agenda-pendientes', 'agenda-nueva-slots', 'dashboard', 'disponibilidad-week', 'citas-admin'].map((key) =>
      queryClient.invalidateQueries({ queryKey: [key] }),
    ),
  )
}

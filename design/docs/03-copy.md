# Copy en español

Español de Colombia (es-CO), tuteo, tipo oración. Todos los formatos con `Intl` / `intl` en locale `es-CO`.

## Formatos

| Dato | Formato | Ejemplo |
|---|---|---|
| Dinero | `$` + miles con punto, sin decimales | `$45.000` · `$1.245.000` |
| Hora | 12 h, «a. m.» / «p. m.» con espacio fino | `9:00 a. m.` · `3:30 p. m.` |
| Rango | guion largo con espacios | `3:30 p. m. – 4:20 p. m.` |
| Fecha larga | día de la semana + día + mes en minúscula | `jueves 12 de noviembre` |
| Fecha corta | día + mes abreviado | `12 nov` · `12 nov 2026` |
| Duración | `min` o `h` | `50 min` · `1 h 15 min` |
| Decimal | coma | `4,8` |
| Teléfono | grupos 3-3-4 | `300 123 4567` |
| Días | lunes primero, minúscula en frase, mayúscula al inicio | `Lunes`, `Martes`, `Miércoles`, `Jueves`, `Viernes`, `Sábado`, `Domingo` |
| Meses | `enero` … `diciembre`; título de calendario `Noviembre 2026` | |

## Correcciones del panel actual

| Antes | Después |
|---|---|
| Descripcion | Descripción |
| Direccion | Dirección |
| Telefono | Teléfono |
| Biografia | Biografía |
| Anios experiencia | Años de experiencia |
| Dias no disponibles | Días libres |
| Catalogo | Catálogo |
| Duracion | Duración |
| Ultima visita | Última visita |
| Accion | Acciones |
| Monday, Friday… | Lunes, Viernes… |
| Key Redis | Horario en reserva |
| Barbero ID (UUID) | Barbero vinculado |
| CONTINUAR | Continuar |
| PRÓXIMAS / HISTORIAL | Próximas / Historial |
| 🔔 Push activo | Notificaciones activas (badge con ícono de campana) |
| Formato HH:mm | (selector de hora, sin texto de formato) |

## Glosario

- **Cita** (no «reserva» en listas; «reservar» es el verbo de la acción).
- **Barbero** / **barberos**; **la barbería** para el negocio; **Mi negocio** en el panel.
- **Horario** = franja de hora elegible; **horario apartado** = bloqueo de 5 min.
- **Reprogramar** (no «reagendar»). **Cancelar cita** (no «eliminar»).
- **No asistió** para `NoShow`; **En progreso** para `EnProgreso`.
- **Admin Barbería** para `AdministradorBarberia`; **Administrador** para `Admin`.

## Textos por pantalla (app)

- Login: «Inicia sesión» · «Ingresa para reservar y gestionar tus citas.» · «Entrar» · «¿Olvidaste tu contraseña?» · «¿No tienes cuenta? Crear cuenta». Errores: «Ingresa tu correo y tu contraseña.» · «Correo o contraseña incorrectos.» · «No pudimos iniciar sesión. Inténtalo de nuevo.»
- Registro: «Crea tu cuenta» · «Crear cuenta». Validaciones: «Este campo es obligatorio.» · «Ingresa un correo válido.» · «La contraseña debe tener al menos 6 caracteres.»
- Recuperar: «Recupera tu contraseña» · «Te enviaremos un código a tu correo.» · «Enviar código» · «Ingresa el código» · «Reenviar en 0:45» · «Crea una nueva contraseña» · «Guardar contraseña».
- Paso 1: «¿Qué servicio deseas?» · vacío «Aún no hay servicios disponibles».
- Paso 2: «Elige tu barbero» · «No disponible hoy» · vacío «No hay barberos para este servicio».
- Paso 3: «Elige fecha y hora» · «Horarios para el jueves 12 de noviembre» · «Horario apartado por 4:32» · «Tu horario se libera en 0:45» · vacío «No hay horarios este día» + «Ver el próximo día disponible».
- Paso 4: «Confirma tu reserva» · «Alguna nota para el barbero (opcional)» · «Pago en el local» · «Reservar ahora» · reprogramando: «Estás reprogramando tu cita. Al confirmar, la anterior se cancela automáticamente.» · «Confirmar nuevo horario».
- Salir: «¿Salir sin reservar?» · «Tu horario apartado se liberará.» · «Seguir reservando» / «Salir».
- Expirado: «Tu horario se liberó» · «Pasaron 5 minutos sin confirmar. Elige de nuevo; puede que siga libre.» · «Elegir horario».
- Éxito: «Reserva confirmada» · «Te enviaremos un recordatorio antes de tu cita.» · «Ver mis citas» · «Volver al inicio».
- Mis citas: «Próximas» · «Historial» · vacío «Aún no tienes citas» + «Reservar».
- Cancelar: «¿Cancelar esta cita?» · «Se liberará el horario del {día} a las {hora} con {barbero}. Esta acción no se puede deshacer.» · «Sí, cancelar cita» / «Volver» · toast «Cita cancelada».
- Sesión: «Tu sesión expirará pronto» · «Si estás reservando, termina ahora o vuelve a iniciar sesión para no perder tu horario.» · «Seguir conectado».
- Notificaciones push: «Tu cita es mañana a las 3:30 p. m. con Julián» · «Julián confirmó tu cita del jueves 12 de noviembre» · «Tu cita fue cancelada por la barbería. Toca para reprogramar.»

## Textos por pantalla (panel)

- Login: «Panel de BarberShop Medellín» · «Ingresa con tu cuenta administrativa.» · «Entrar al panel» · «Credenciales incorrectas. Revisa tu correo y tu contraseña.»
- Dashboard: «Hoy en la barbería» · KPIs «Citas del día», «Ingresos del día», «Clientes activos», «Barberos activos».
- Agenda: «Agenda» · «Día», «Semana», «Historial» · «Hoy» · «Todos los barberos» · «Todos los estados» · «Nueva cita» · acciones «Confirmar», «Iniciar», «Completar», «No asistió», «Cancelar».
- Barberos: «Equipo» · «Nuevo barbero» · «Horario semanal» · «Días libres» · «Motivo (vacaciones, incapacidad…)».
- Servicios: «Catálogo de servicios» · «Nuevo servicio».
- Clientes: «Clientes» · «Nuevo cliente» · «Sin visitas» · «Desactivar cliente» / «Activar cliente».
- Disponibilidad: «Disponible», «Ocupado», «Bloqueado», «Reservando» · «Reservas en curso» · «Se libera en 3:12» · «Liberar ahora».
- Mi negocio: «Así te ven tus clientes en la app.» · «Barbería activa».
- Cerrar sesión: «¿Cerrar sesión?» · «Tendrás que volver a ingresar con tu correo.» · «Cerrar sesión» / «Volver».

import axios from 'axios'

import { useAuthStore } from '../stores/authStore'
import { toast } from '../stores/toastStore'

export const http = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:5001/api',
	timeout: 10000,
})

http.interceptors.request.use((config) => {
	const token = useAuthStore.getState().token
	if (token) {
		config.headers.Authorization = `Bearer ${token}`
	} else {
		// Asegurar que no quede header residual
		delete config.headers.Authorization
	}
	return config
})

http.interceptors.response.use(
	(res) => res,
	(err) => {
		if (err.response?.status === 401) {
			// Solo reaccionar una vez: si ya no hay token, otra petición concurrente
			// ya proceso este mismo cierre de sesión.
			const wasAuthenticated = Boolean(useAuthStore.getState().token)
			if (wasAuthenticated) {
				// logout() limpia el token; AuthGuard reacciona al instante y navega a
				// /login por su cuenta (sin recargar la página). El ToastContainer vive
				// en la raíz de la app, así que el aviso sigue visible tras el cambio de ruta.
				useAuthStore.getState().logout()
				toast.error('Tu sesión expiró. Vuelve a iniciar sesión.')
			}
		}
		return Promise.reject(err)
	},
)

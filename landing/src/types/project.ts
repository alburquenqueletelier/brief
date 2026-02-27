export interface Project {
  id: string
  name: string
  description: string
  url: string
  tags: string[]
  status: 'live' | 'in-progress' | 'archived'
}

function resolveUrl(port: string | undefined, fallback: string | undefined): string {
  if (port) {
    return `http://${window.location.hostname}:${port}`
  }
  return fallback ?? ''
}

export const projects: Project[] = [
  {
    id: 'recuerda',
    name: 'RecuerdaBot',
    description:
      'Bot de Whatsapp y Telegram para recordate tus pendientes. Usa lenguaje natural y sincronización con calendario Outlook y Google',
    url: resolveUrl(import.meta.env.VITE_URL_RECUERDA_PORT, import.meta.env.VITE_URL_RECUERDA),
    tags: ['Python', 'FastAPI', 'Gemini API', 'Whatsapp', 'Telegram', 'Docker', 'Redis'],
    status: 'live',
  },
  {
    id: 'aerium',
    name: 'Aerium',
    description:
      'Demo plataforma de gestión de drones: telemetría en tiempo real de aeronaves con foco en mitigar riesgos en faenas mineras.',
    url: resolveUrl(import.meta.env.VITE_URL_AERIUM_PORT, import.meta.env.VITE_URL_AERIUM),
    tags: ['Vue 3', 'FastAPI', 'PostgreSQL', 'WebSocket'],
    status: 'live',
  },
]

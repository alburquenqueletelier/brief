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
    tags: ['Docker', 'FastAPI', 'Gemini API', 'Python', 'Redis', 'Telegram', 'Whatsapp'],
    status: 'live',
  },
  {
    id: 'aerium',
    name: 'Aerium',
    description:
      'Demo plataforma de gestión de drones: telemetría en tiempo real de aeronaves con foco en mitigar riesgos en faenas mineras.',
    url: resolveUrl(import.meta.env.VITE_URL_AERIUM_PORT, import.meta.env.VITE_URL_AERIUM),
    tags: ['Docker', 'FastAPI', 'PostgreSQL', 'Python', 'Typescript', 'Vue 3', 'WebSocket'],
    status: 'live',
  },
  {
    id: 'sexy-mkt',
    name: 'Sexy MKT',
    description:
      'Landing page para evento del día mundial de Marketing realizado por Felipe Parraguez',
    url: resolveUrl(import.meta.env.VITE_URL_SMART_ENGAGE_PORT, import.meta.env.VITE_URL_SMART_ENGAGE),
    tags: ['Vue Js', 'Typescript', 'Tailwind'],
    status: 'live',
  },
  {
    id: 'smart_engage',
    name: 'Smart Engage',
    description:
      'Plataforma de prospectos de negocio para empresas inteligentes. Desarrollo de aplicación web para la optimización estratégica de ventas y clasificación de leads',
    url: resolveUrl(import.meta.env.VITE_URL_SMART_ENGAGE_PORT, import.meta.env.VITE_URL_SMART_ENGAGE),
    tags: ['0Auth', 'Docker', 'NextJs', 'PostgreSQL', 'Typescript'],
    status: 'in-progress',
  },
]

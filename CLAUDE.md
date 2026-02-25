# alburquenque.net — Portfolio Monorepo

Ver `PLAN.md` para el plan completo de infraestructura y despliegue.

## Estructura
```
brief/
├── landing/      # Vue3 + TypeScript + Vite + Tailwind → desplegado en Vercel
├── nginx/        # Configs de Nginx para copiar al servidor
├── scripts/      # Scripts de deploy para la VM de Azure
├── PLAN.md       # Plan completo de infraestructura
└── CLAUDE.md     # Este archivo
```

Los proyectos (RecuerdaBot, Aerium) viven en sus propios repos. Sus deploys se hacen
directamente en la VM clonando esos repos en `/var/www/alburquenque.net/`.

## Dominios
- `alburquenque.net` → **Vercel** (landing page, deploy automático)
- `recuerda.alburquenque.net` → **Azure VM** (Docker Compose, 5 contenedores)
- `aerium.alburquenque.net` → **Azure VM** (Nginx estático + FastAPI + PostgreSQL en Docker)

## Landing page (`landing/`)

### Stack
- Vue 3 + TypeScript + Vite + Tailwind CSS
- No SSR — build estático servido por Vercel

### Comandos
```bash
cd landing
npm install        # primera vez
npm run dev        # desarrollo local
npm run build      # build para producción (output en dist/)
```

### Deploy
Push a `main` → Vercel hace el deploy automáticamente.
Vercel detecta Vue/Vite sin configuración extra gracias a `vercel.json`.

### Convenciones de código
- Componentes en PascalCase: `HeroSection.vue`, `ProjectCard.vue`
- Composables con prefijo `use`: `useScrollAnimation.ts`
- Tipos en `src/types/`, componentes en `src/components/`
- Tailwind sin CSS custom, excepto en `src/style.css` para la capa `@layer components`

### Paleta de colores (tema futurista)
```
dark-space:  #0a0a0f   fondo principal
dark-card:   #13131a   fondo de cards
dark-border: #1e1e2e   bordes
neon-cyan:   #00f5ff   acento principal (texto, bordes hover, CTA)
neon-purple: #9d4edd   acento secundario
```

## Azure VM

### Acceso
```bash
ssh azureuser@<IP_VM>
```

### Servicios que corren en la VM
| Servicio           | Tipo       | Puerto interno | Gestión      |
|--------------------|------------|----------------|--------------|
| Nginx              | paquete    | 80, 443        | systemd      |
| RecuerdaBot (app)  | Docker     | 8000           | docker compose |
| Aerium backend     | virtualenv | 8001           | systemd      |
| Aerium DB          | Docker     | 5432           | docker compose |

### Paths en la VM
```
/var/www/alburquenque.net/
├── recuerda/repo/         git clone de recuerdabot
├── aerium/backend/repo/   git clone de aerium-backend
├── aerium/backend/venv/   Python virtualenv
├── aerium/frontend/repo/  git clone de aerium-frontend
├── aerium/frontend/dist/  build estático (Nginx lo sirve aquí)
└── aerium/docker/         docker-compose.yml de la DB

/etc/nginx/sites-available/
├── recuerda.alburquenque.net
└── aerium.alburquenque.net

/etc/systemd/system/
└── aerium-backend.service
```

### Comandos frecuentes en la VM
```bash
# Nginx
sudo nginx -t && sudo systemctl reload nginx
sudo tail -f /var/log/nginx/error.log

# RecuerdaBot
cd /var/www/alburquenque.net/recuerda/repo
docker compose -f docker-compose.prod.yml ps
docker compose -f docker-compose.prod.yml logs -f app

# Aerium backend
sudo systemctl status aerium-backend
sudo journalctl -u aerium-backend -f

# Aerium DB
cd /var/www/alburquenque.net/aerium/docker
docker compose ps
```

## Notas de arquitectura
- Nginx es el único punto de entrada a la VM (puertos 80/443 expuestos)
- Los puertos de apps (8000, 8001, 5432) solo escuchan en `127.0.0.1` — nunca `0.0.0.0`
- SSL para subdomains: Certbot (Let's Encrypt), renovación automática via systemd timer
- SSL para landing: lo maneja Vercel automáticamente
- RecuerdaBot es 100% Docker: app FastAPI, bot Telegram, worker Celery, Redis, PostgreSQL
- Aerium: solo la DB en Docker; el backend corre en virtualenv para facilitar logs y acceso a la DB

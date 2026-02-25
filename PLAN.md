# Plan de Infraestructura — alburquenque.net

## Visión General

Portafolio personal en `alburquenque.net` con landing page en Vercel y proyectos en subdomains servidos desde una Azure VM.

```
Usuario
  │
  ├─► alburquenque.net ──────────────────► Vercel (CDN global, gratis)
  │      Landing page estática
  │      Vue3 + Vite + TypeScript + Tailwind
  │
  └─► *.alburquenque.net ───────────────► Azure VM (Ubuntu)
         │                                  Nginx :80/:443 (reverse proxy + SSL)
         │
         ├─► recuerdabot.alburquenque.net ──► Docker Compose (5 contenedores)
         │
         └─► aerium.alburquenque.net ───► FastAPI + Nginx
                                           PostgreSQL en Docker
```

---

## DNS

Todos los registros apuntan a la misma VM de Azure, **excepto** la landing page que va a Vercel.

| Tipo  | Host       | Valor                       | Para qué                         |
|-------|------------|-----------------------------|----------------------------------|
| A     | `@`        | IP de Vercel*               | Landing page                     |
| CNAME | `www`      | `cname.vercel-dns.com`      | Redirect www → landing           |
| A     | `recuerda` | `<IP_VM_AZURE>`             | RecuerdaBot                      |
| A     | `aerium`   | `<IP_VM_AZURE>`             | Aerium                           |

> *Vercel entrega la IP exacta cuando añades el dominio custom en su dashboard.
> El CNAME de `www` puede también ser un A record hacia Vercel, dependiendo del registrador.

### Configuración en Vercel
1. Proyecto landing → Settings → Domains → añadir `alburquenque.net` y `www.alburquenque.net`
2. Vercel provee las instrucciones DNS exactas (A record o CNAME según el registrador)
3. SSL automático vía Vercel (no se necesita Certbot para la landing)

---

## Azure VM — Setup Inicial

### Requisitos previos en la VM
```bash
# IP estática obligatoria (Azure Portal → VM → Networking → IP config → Static)

# Puertos NSG (Azure Portal → VM → Networking → Inbound port rules)
# Puerto 80  (HTTP)
# Puerto 443 (HTTPS)
# Puerto 22  (SSH)

# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar dependencias base
sudo apt install -y nginx certbot python3-certbot-nginx docker.io docker-compose-plugin git

# Habilitar Docker sin sudo
sudo usermod -aG docker azureuser
newgrp docker

# UFW (firewall del SO)
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 'Nginx Full'
sudo ufw enable
```

### SSL — Certbot (solo para subdomains, la landing usa SSL de Vercel)
```bash
# Esperar que los DNS propaguen antes de correr esto
dig recuerdabot.alburquenque.net A   # debe resolver la IP de la VM
dig aerium.alburquenque.net A     # debe resolver la IP de la VM

sudo certbot --nginx \
  -d recuerdabot.alburquenque.net \
  -d aerium.alburquenque.net

# Renovación automática (ya activa via systemd timer)
sudo systemctl status certbot.timer
sudo certbot renew --dry-run   # test
```

---

## Landing Page — Vercel

### Stack
- **Framework**: Vue 3 + TypeScript
- **Build tool**: Vite
- **Estilos**: Tailwind CSS
- **Deploy**: Push a `main` → Vercel hace el build y deploy automáticamente

### Estructura del proyecto
```
landing/
├── index.html
├── package.json
├── tsconfig.json
├── vite.config.ts
├── tailwind.config.ts
├── postcss.config.js
├── vercel.json
└── src/
    ├── main.ts
    ├── App.vue
    ├── style.css
    ├── types/
    │   └── project.ts
    ├── components/
    │   ├── NavBar.vue
    │   ├── HeroSection.vue
    │   ├── AboutSection.vue
    │   ├── ProjectsSection.vue
    │   └── ProjectCard.vue
    └── assets/
```

### `vercel.json`
```json
{
  "buildCommand": "npm run build",
  "outputDirectory": "dist",
  "framework": "vue",
  "rewrites": [
    { "source": "/(.*)", "destination": "/index.html" }
  ],
  "headers": [
    {
      "source": "/assets/(.*)",
      "headers": [
        { "key": "Cache-Control", "value": "public, max-age=31536000, immutable" }
      ]
    }
  ]
}
```

### Diseño — Tema futurista
```
Colores:
  dark-space:  #0a0a0f  (fondo principal)
  dark-card:   #13131a  (fondo de cards)
  dark-border: #1e1e2e  (bordes)
  neon-cyan:   #00f5ff  (acento principal)
  neon-purple: #9d4edd  (acento secundario)

Tipografía:
  body: Inter (Google Fonts)
  code/labels: JetBrains Mono

Efectos:
  - Grid CSS animado de fondo (líneas cyan muy transparentes)
  - Orbs de luz borrosos (blur + pulse lento)
  - Glassmorphism en cards
  - Glow en hover
```

### Secciones
1. **Hero**: nombre, título, CTA ("Ver Proyectos" / "Sobre mí")
2. **About**: descripción personal, tecnologías
3. **Projects**: cards con link a cada subdomain

### Datos de proyectos (`src/types/project.ts`)
```typescript
export interface Project {
  id: string
  name: string
  description: string
  url: string           // link al subdomain
  tags: string[]
  status: 'live' | 'in-progress' | 'archived'
}

export const projects: Project[] = [
  {
    id: 'recuerda',
    name: 'RecuerdaBot',
    description: 'Bot de Telegram con sincronización de Google Calendar y recordatorios en lenguaje natural.',
    url: 'https://recuerdabot.alburquenque.net',
    tags: ['Python', 'FastAPI', 'Telegram', 'Docker'],
    status: 'live',
  },
  {
    id: 'aerium',
    name: 'Aerium',
    description: 'Plataforma de gestión de drones: telemetría en tiempo real, planificación de vuelos y reportes.',
    url: 'https://aerium.alburquenque.net',
    tags: ['Vue3', 'FastAPI', 'PostgreSQL', 'Docker'],
    status: 'in-progress',
  },
]
```

### Deploy en Vercel
```bash
# Opción A: CLI
npm install -g vercel
cd landing
vercel --prod

# Opción B: GitHub integration (recomendado)
# 1. Push el repo a GitHub
# 2. Vercel Dashboard → New Project → Import repo
# 3. Seleccionar directorio: landing/
# 4. Vercel detecta Vue/Vite automáticamente
# 5. Cada push a main hace deploy automático
```

---

## RecuerdaBot — Docker Compose (5 contenedores)

### Subdomain: `recuerdabot.alburquenque.net`

### Arquitectura de contenedores
```
Docker Compose: recuerdabot
├── app         FastAPI (docs + vista feedback)    :8000 (interno)
├── bot         Worker del bot de Telegram
├── worker      Celery worker (tareas async)
├── redis       Broker para Celery                 :6379 (interno)
└── db          PostgreSQL                         :5432 (interno)
```

> Todos los puertos son **solo internos** al stack Docker. Solo `app` expone puerto hacia el host (8000).
> Nginx del host hace proxy a `127.0.0.1:8000`.

### Estructura en el servidor
```
/var/www/alburquenque.net/recuerdabot/
├── repo/                     # git clone del repo
│   ├── docker-compose.yml
│   ├── docker-compose.prod.yml
│   ├── .env.prod             # secrets (nunca en git)
│   ├── app/                  # FastAPI
│   │   ├── Dockerfile
│   │   ├── main.py
│   │   └── ...
│   ├── bot/                  # Telegram bot worker
│   │   ├── Dockerfile
│   │   └── ...
│   └── worker/               # Celery worker
│       ├── Dockerfile
│       └── ...
└── data/
    └── postgres/             # Volumen persistente de la DB
```

### `docker-compose.prod.yml`
```yaml
version: '3.9'

services:
  db:
    image: postgres:16-alpine
    restart: always
    env_file: .env.prod
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - /var/www/alburquenque.net/recuerdabot/data/postgres:/var/lib/postgresql/data
    networks:
      - recuerda-internal
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    restart: always
    networks:
      - recuerda-internal

  bot:
    build: ./bot
    restart: always
    env_file: .env.prod
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started
    networks:
      - recuerda-internal

  worker:
    build: ./worker
    restart: always
    env_file: .env.prod
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started
    networks:
      - recuerda-internal

  app:
    build: ./app
    restart: always
    env_file: .env.prod
    ports:
      - "127.0.0.1:8000:8000"    # Solo accesible desde el host, no desde internet
    depends_on:
      db:
        condition: service_healthy
    networks:
      - recuerda-internal

networks:
  recuerda-internal:
    driver: bridge
```

> `127.0.0.1:8000:8000` es clave: el contenedor solo escucha en loopback del host,
> nunca en `0.0.0.0`, así Nginx es el único punto de entrada.

### Vista de feedback (Google Calendar OAuth callback)

La única vista HTML custom es el callback OAuth. El usuario llega aquí desde Google después de autorizar el acceso al calendario.

```
Flujo:
  Usuario en Telegram → /connect_calendar
    → Bot genera URL de OAuth de Google
    → Usuario abre URL en navegador
    → Autoriza en pantalla de Google
    → Google redirige a: https://recuerdabot.alburquenque.net/api/v1/calendar/callback?code=...
    → FastAPI intercambia el code por tokens
    → Renderiza página HTML de confirmación/error
    → Usuario vuelve a Telegram
```

### Nginx config para RecuerdaBot
```nginx
# /etc/nginx/sites-available/recuerdabot.alburquenque.net

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name recuerdabot.alburquenque.net;

    ssl_certificate     /etc/letsencrypt/live/recuerdabot.alburquenque.net/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/recuerdabot.alburquenque.net/privkey.pem;
    include             /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam         /etc/letsencrypt/ssl-dhparams.pem;

    add_header Strict-Transport-Security "max-age=31536000" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;

    location / {
        proxy_pass         http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header   Host $host;
        proxy_set_header   X-Real-IP $remote_addr;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
        proxy_read_timeout 120s;
    }
}

server {
    listen 80;
    server_name recuerdabot.alburquenque.net;
    return 301 https://$host$request_uri;
}
```

### Comandos de operación
```bash
cd /var/www/alburquenque.net/recuerdabot/repo

# Levantar
docker compose -f docker-compose.prod.yml up -d

# Ver estado
docker compose -f docker-compose.prod.yml ps

# Logs de un servicio
docker compose -f docker-compose.prod.yml logs -f app
docker compose -f docker-compose.prod.yml logs -f bot

# Deploy: pull cambios y rebuild
git pull origin main
docker compose -f docker-compose.prod.yml up -d --build

# Parar todo
docker compose -f docker-compose.prod.yml down

# Backup de la DB
docker compose -f docker-compose.prod.yml exec db \
  pg_dump -U $POSTGRES_USER $POSTGRES_DB | gzip > backup_$(date +%Y%m%d).sql.gz
```

---

## Aerium — FastAPI + PostgreSQL en Docker

### Subdomain: `aerium.alburquenque.net`

### Arquitectura
```
Azure VM
  ├── Nginx → sirve frontend estático (dist/)
  │           hace proxy /api/* → FastAPI
  ├── FastAPI (Uvicorn, systemd service, puerto 8001)
  └── Docker
        └── db (PostgreSQL :5432 interno)
```

> Solo la base de datos está en Docker. El backend FastAPI corre directamente en el host (virtualenv + systemd),
> lo que facilita el acceso al DB container via red Docker y simplifica los logs.

### Estructura en el servidor
```
/var/www/alburquenque.net/aerium/
├── backend/
│   ├── repo/              # git clone del backend
│   │   ├── main.py
│   │   ├── requirements.txt
│   │   ├── alembic.ini
│   │   ├── .env
│   │   └── app/
│   │       ├── database.py
│   │       ├── models/
│   │       ├── api/
│   │       └── schemas/
│   └── venv/              # Python virtualenv
├── frontend/
│   ├── repo/              # git clone del frontend
│   └── dist/              # build estático (servido por Nginx)
└── docker/
    ├── docker-compose.yml # Solo la DB
    └── data/
        └── postgres/      # Volumen persistente
```

### `docker/docker-compose.yml` (solo DB)
```yaml
version: '3.9'

services:
  db:
    image: postgres:16-alpine
    restart: always
    env_file: ../.env.docker
    environment:
      POSTGRES_DB: aerium_db
      POSTGRES_USER: aerium_user
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    ports:
      - "127.0.0.1:5432:5432"    # Solo accesible desde el host
    volumes:
      - /var/www/alburquenque.net/aerium/docker/data/postgres:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U aerium_user"]
      interval: 10s
      retries: 5
```

### Variables de entorno — `backend/repo/.env`
```bash
DATABASE_URL=postgresql+asyncpg://aerium_user:<password>@127.0.0.1:5432/aerium_db
SECRET_KEY=<256-bit-random>
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=60
ENVIRONMENT=production
ALLOWED_ORIGINS=https://aerium.alburquenque.net
```

### Systemd service — backend
```ini
# /etc/systemd/system/aerium-backend.service

[Unit]
Description=Aerium FastAPI Backend
After=network.target docker.service

[Service]
User=azureuser
WorkingDirectory=/var/www/alburquenque.net/aerium/backend/repo
Environment="PATH=/var/www/alburquenque.net/aerium/backend/venv/bin"
EnvironmentFile=/var/www/alburquenque.net/aerium/backend/repo/.env
ExecStart=/var/www/alburquenque.net/aerium/backend/venv/bin/uvicorn \
    main:app \
    --host 127.0.0.1 \
    --port 8001 \
    --workers 2 \
    --log-level info
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
```

### Nginx config para Aerium
```nginx
# /etc/nginx/sites-available/aerium.alburquenque.net

map $http_upgrade $connection_upgrade {
    default upgrade;
    ''      close;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name aerium.alburquenque.net;

    ssl_certificate     /etc/letsencrypt/live/aerium.alburquenque.net/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/aerium.alburquenque.net/privkey.pem;
    include             /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam         /etc/letsencrypt/ssl-dhparams.pem;

    add_header Strict-Transport-Security "max-age=31536000" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;

    # Frontend estático
    root /var/www/alburquenque.net/aerium/frontend/dist;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
        access_log off;
    }

    # API proxy → FastAPI
    location /api/ {
        rewrite ^/api/(.*)$ /$1 break;

        proxy_pass         http://127.0.0.1:8001;
        proxy_http_version 1.1;
        proxy_set_header   Host $host;
        proxy_set_header   X-Real-IP $remote_addr;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;

        # WebSocket para telemetría de drones
        proxy_set_header   Upgrade $http_upgrade;
        proxy_set_header   Connection $connection_upgrade;
        proxy_read_timeout 300s;
    }
}

server {
    listen 80;
    server_name aerium.alburquenque.net;
    return 301 https://$host$request_uri;
}
```

### Comandos de operación
```bash
# Levantar DB
cd /var/www/alburquenque.net/aerium/docker
docker compose up -d

# Backend
sudo systemctl start aerium-backend
sudo systemctl status aerium-backend
sudo journalctl -u aerium-backend -f

# Migraciones
cd /var/www/alburquenque.net/aerium/backend/repo
source ../venv/bin/activate
alembic upgrade head

# Frontend build
cd /var/www/alburquenque.net/aerium/frontend/repo
npm ci && npm run build
cp -r dist/ ../dist/
sudo systemctl reload nginx
```

---

## Scripts de Deploy

### `scripts/deploy-landing.sh`
```bash
#!/usr/bin/env bash
# Landing page se despliega automáticamente via Vercel en cada push a main.
# Este script es solo para forzar un redeploy manual si es necesario.
set -euo pipefail
cd "$(dirname "$0")/../landing"
echo "==> Push a main para triggear Vercel automáticamente."
echo "==> O instala la CLI: npm i -g vercel && vercel --prod"
```

### `scripts/deploy-recuerdabot.sh`
```bash
#!/usr/bin/env bash
set -euo pipefail
APP_DIR="/var/www/alburquenque.net/recuerdabot/repo"
echo "==> Desplegando RecuerdaBot..."
cd "$APP_DIR"
git pull origin main
docker compose -f docker-compose.prod.yml up -d --build
echo "==> Esperando que los contenedores estén healthy..."
sleep 5
docker compose -f docker-compose.prod.yml ps
echo "==> RecuerdaBot desplegado."
```

### `scripts/deploy-aerium.sh`
```bash
#!/usr/bin/env bash
set -euo pipefail
BACKEND_DIR="/var/www/alburquenque.net/aerium/backend/repo"
FRONTEND_DIR="/var/www/alburquenque.net/aerium/frontend/repo"
VENV="/var/www/alburquenque.net/aerium/backend/venv"

echo "==> Desplegando Aerium Backend..."
cd "$BACKEND_DIR"
git pull origin main
source "$VENV/bin/activate"
pip install -r requirements.txt -q
alembic upgrade head
sudo systemctl restart aerium-backend

echo "==> Desplegando Aerium Frontend..."
cd "$FRONTEND_DIR"
git pull origin main
npm ci
npm run build
cp -r dist/ ../dist/
sudo nginx -t && sudo systemctl reload nginx

echo "==> Aerium desplegado exitosamente."
```

---

## Orden de Implementación (Primera Vez)

```
FASE 1 — VM base
  [X] Asignar IP estática en Azure Portal
  [X] Abrir puertos NSG: 80, 443, 22
  [X] SSH → apt update/upgrade
  [X] Instalar: nginx, certbot, docker, git
  [X] Configurar UFW

FASE 2 — DNS
  [X] Agregar A records: recuerda, aerium → IP de la VM
  [X] Configurar dominio apex en Vercel (alburquenque.net → Vercel)
  [X] Esperar propagación: dig recuerdabot.alburquenque.net A

FASE 3 — Nginx base (HTTP)
  [X] Crear configs en /etc/nginx/sites-available/
  [ ] Habilitar sites, sudo nginx -t, reload

FASE 4 — SSL
  [ ] sudo certbot --nginx -d recuerdabot.alburquenque.net -d aerium.alburquenque.net
  [ ] Verificar HTTPS y redirect 301

FASE 5 — RecuerdaBot
  [ ] git clone en /var/www/alburquenque.net/recuerdabot/repo
  [ ] Crear .env.prod con secrets
  [ ] docker compose -f docker-compose.prod.yml up -d
  [ ] Verificar https://recuerdabot.alburquenque.net/docs

FASE 6 — Aerium DB
  [ ] Crear /var/www/alburquenque.net/aerium/docker/docker-compose.yml
  [ ] docker compose up -d
  [ ] Verificar conexión desde el host

FASE 7 — Aerium Backend
  [ ] git clone backend repo
  [ ] python3 -m venv venv && pip install -r requirements.txt
  [ ] Crear .env con DATABASE_URL apuntando a 127.0.0.1:5432
  [ ] alembic upgrade head
  [ ] Crear y habilitar aerium-backend.service
  [ ] sudo systemctl enable --now aerium-backend

FASE 8 — Aerium Frontend
  [ ] git clone frontend repo
  [ ] npm ci && npm run build
  [ ] Copiar dist/ al directorio servido por Nginx
  [ ] sudo systemctl reload nginx

FASE 9 — Landing page
  [ ] Inicializar proyecto Vue3+Vite en landing/
  [ ] Desarrollar localmente (npm run dev)
  [ ] Conectar repo a Vercel
  [ ] Configurar dominio alburquenque.net en Vercel
  [ ] Push a main → deploy automático

FASE 10 — Operaciones
  [ ] Configurar UptimeRobot para monitoreo
  [ ] Configurar cron para backup de DBs
  [ ] Documentar secrets en gestor de passwords
```

---

## Estructura del Monorepo

```
alburquenque.net/             (repo raíz)
├── PLAN.md                   (este archivo)
├── CLAUDE.md                 (instrucciones para Claude Code)
├── landing/                  (Vue3 + Vite + Tailwind)
│   ├── vercel.json
│   ├── package.json
│   ├── vite.config.ts
│   ├── tailwind.config.ts
│   └── src/
├── nginx/                    (configs para copiar al servidor)
│   ├── recuerdabot.alburquenque.net.conf
│   └── aerium.alburquenque.net.conf
└── scripts/
    ├── deploy-recuerdabot.sh
    └── deploy-aerium.sh

--- EN LA VM (no en el repo) ---

/var/www/alburquenque.net/
├── recuerdabot/repo/            (git clone de recuerdabot)
├── aerium/backend/repo/      (git clone de aerium-backend)
├── aerium/frontend/repo/     (git clone de aerium-frontend)
├── aerium/frontend/dist/     (build estático servido por Nginx)
└── aerium/docker/            (docker-compose para DB)

/etc/systemd/system/
└── aerium-backend.service

/etc/nginx/sites-available/
├── recuerdabot.alburquenque.net
└── aerium.alburquenque.net
```

---

## Resumen de Responsabilidades por Plataforma

| Servicio                    | Plataforma     | SSL          | Deploy trigger          |
|-----------------------------|----------------|--------------|-------------------------|
| Landing page                | **Vercel**     | Automático   | Push a `main`           |
| RecuerdaBot (app + bot + workers + redis + db) | **Azure VM** (Docker) | Certbot | `deploy-recuerdabot.sh` |
| Aerium DB                   | **Azure VM** (Docker)  | N/A (interno) | `docker compose up` |
| Aerium backend              | **Azure VM** (systemd) | Certbot | `deploy-aerium.sh` |
| Aerium frontend             | **Azure VM** (Nginx static) | Certbot | `deploy-aerium.sh` |

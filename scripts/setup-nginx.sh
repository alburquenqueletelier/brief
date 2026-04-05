#!/usr/bin/env bash
# Configura Nginx en la VM: copia los configs, habilita los sites, obtiene SSL y recarga.
# Idempotente: seguro de ejecutar múltiples veces.
#
# USAR DESDE LA VM después de git pull:
#   bash scripts/setup-nginx.sh
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SITES_AVAILABLE="/etc/nginx/sites-available"
SITES_ENABLED="/etc/nginx/sites-enabled"

DOMAINS=(
    "recuerdabot.alburquenque.net"
    "aerium.alburquenque.net"
)

# ── 1. Bloque map para WebSocket ────────────────────────────────────────────
echo "==> Verificando bloque map para WebSocket en nginx.conf..."
if ! sudo grep -q "connection_upgrade" /etc/nginx/nginx.conf && \
   ! [ -f /etc/nginx/conf.d/websocket-map.conf ]; then
    sudo tee /etc/nginx/conf.d/websocket-map.conf > /dev/null <<'EOF'
map $http_upgrade $connection_upgrade {
    default upgrade;
    ''      close;
}
EOF
    echo "    Bloque map agregado en /etc/nginx/conf.d/websocket-map.conf"
else
    echo "    Ya existe, sin cambios."
fi

# ── 2. Copiar configs ────────────────────────────────────────────────────────
echo "==> Copiando configs de Nginx..."
sudo cp "$REPO_DIR/nginx/recuerdabot.alburquenque.net.conf" "$SITES_AVAILABLE/recuerdabot.alburquenque.net"
sudo cp "$REPO_DIR/nginx/aerium.alburquenque.net.conf"      "$SITES_AVAILABLE/aerium.alburquenque.net"

# ── 3. Habilitar sites (idempotente con -sf) ─────────────────────────────────
echo "==> Habilitando sites..."
sudo ln -sf "$SITES_AVAILABLE/recuerdabot.alburquenque.net" "$SITES_ENABLED/"
sudo ln -sf "$SITES_AVAILABLE/aerium.alburquenque.net"      "$SITES_ENABLED/"

# ── 4. Verificar y recargar Nginx ────────────────────────────────────────────
echo "==> Verificando config..."
sudo nginx -t

echo "==> Recargando Nginx..."
sudo systemctl reload nginx

# ── 5. SSL con Certbot (solo si faltan certificados) ─────────────────────────
echo "==> Verificando certificados SSL..."
MISSING_CERTS=()
for domain in "${DOMAINS[@]}"; do
    if ! sudo certbot certificates 2>/dev/null | grep -q "Domains:.*$domain"; then
        MISSING_CERTS+=("$domain")
    fi
done

if [ ${#MISSING_CERTS[@]} -gt 0 ]; then
    echo "    Solicitando certificados para: ${MISSING_CERTS[*]}"
    CERTBOT_ARGS=()
    for domain in "${MISSING_CERTS[@]}"; do
        CERTBOT_ARGS+=("-d" "$domain")
    done
    sudo certbot --nginx "${CERTBOT_ARGS[@]}"
    echo "    Recargando Nginx con SSL..."
    sudo systemctl reload nginx
else
    echo "    Todos los certificados ya existen, sin cambios."
fi

echo ""
echo "OK. Nginx configurado y SSL activo para: ${DOMAINS[*]}"

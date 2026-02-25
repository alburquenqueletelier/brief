#!/usr/bin/env bash
# Copia los configs de Nginx y los habilita.
# Correr desde la VM después de hacer git pull:
#   bash scripts/setup-nginx.sh
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SITES_AVAILABLE="/etc/nginx/sites-available"
SITES_ENABLED="/etc/nginx/sites-enabled"

echo "==> Verificando bloque map para WebSocket en nginx.conf..."
if ! sudo grep -q "connection_upgrade" /etc/nginx/nginx.conf; then
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

echo "==> Copiando configs de Nginx..."
sudo cp "$REPO_DIR/nginx/recuerdabot.alburquenque.net.conf" "$SITES_AVAILABLE/recuerdabot.alburquenque.net"
sudo cp "$REPO_DIR/nginx/aerium.alburquenque.net.conf"   "$SITES_AVAILABLE/aerium.alburquenque.net"

echo "==> Habilitando sites..."
sudo ln -sf "$SITES_AVAILABLE/recuerdabot.alburquenque.net" "$SITES_ENABLED/"
sudo ln -sf "$SITES_AVAILABLE/aerium.alburquenque.net"   "$SITES_ENABLED/"

echo "==> Verificando config..."
sudo nginx -t

echo "==> Recargando Nginx..."
sudo systemctl reload nginx

echo ""
echo "OK. Ahora corre Certbot para agregar SSL:"
echo "  sudo certbot --nginx -d recuerdabot.alburquenque.net -d aerium.alburquenque.net"

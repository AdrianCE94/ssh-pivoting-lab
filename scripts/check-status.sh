#!/bin/bash

echo "╔══════════════════════════════════════════════════╗"
echo "║        ESTADO DEL LABORATORIO SSH PIVOTING       ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""

echo "📦 CONTENEDORES:"
docker-compose ps

echo ""
echo "🌐 REDES:"
docker network ls | grep -E "br-dmz|br-internal|NETWORK"

echo ""
echo "🔌 CONECTIVIDAD:"

for container in dmz_server pivot_host internal_server; do
    if docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
        IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $container 2>/dev/null | head -n1)
        echo "  ✓ $container: $IP"
    else
        echo "  ✗ $container: No disponible"
    fi
done

echo ""
echo "🔐 TEST SSH (desde tu máquina al DMZ):"
timeout 2 bash -c "cat < /dev/null > /dev/tcp/192.16.0.10/22" 2>/dev/null && echo "  ✓ Puerto SSH 22 abierto en 192.16.0.10" || echo "  ℹ️  Verifica conectividad con: ssh alumno@192.16.0.10"

echo ""
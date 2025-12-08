#!/bin/bash

set -e

echo "╔══════════════════════════════════════════════════╗"
echo "║   SSH PIVOTING LAB - DEPLOYMENT SCRIPT          ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""

# Verificar Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker no está instalado."
    echo "   Instala Docker desde: https://docs.docker.com/engine/install/"
    exit 1
fi

# Verificar Docker Compose
COMPOSE_CMD="docker compose"
if ! docker compose version &> /dev/null; then
    if command -v docker-compose &> /dev/null; then
        COMPOSE_CMD="docker-compose"
    else
        echo "❌ Docker Compose no está instalado."
        exit 1
    fi
fi

echo "✓ Docker y Docker Compose detectados"
echo ""

# Limpiar despliegues anteriores
echo "🧹 Limpiando contenedores previos..."
$COMPOSE_CMD down -v 2>/dev/null || true
docker network prune -f 2>/dev/null || true

echo ""
echo "🏗️  Construyendo imágenes (puede tomar unos minutos)..."
$COMPOSE_CMD build --no-cache

echo ""
echo "🚀 Desplegando laboratorio..."
$COMPOSE_CMD up -d

echo ""
echo "⏳ Esperando que los servicios estén listos..."
sleep 15

echo ""
echo "✅ ¡Laboratorio desplegado exitosamente!"
echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║           INFORMACIÓN DE ACCESO                  ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""
echo "🌐 RED DMZ (192.16.0.0/16)"
echo "   └─ DMZ Server: 192.16.0.10"
echo "      Usuario: alumno"
echo "      Password: vulnerable123"
echo ""
echo "🔄 HOST PIVOT (Dual-homed)"
echo "   ├─ DMZ: 192.16.0.20"
echo "   └─ Internal: 172.16.0.20"
echo "      Usuario: sysadmin"
echo "      Password: access2024"
echo ""
echo "🔒 RED INTERNA (172.16.0.0/16)"
echo "   └─ Internal Server: 172.16.0.30"
echo "      Usuario: root"
echo "      Password: secretdata999"
echo "      🚩 FLAG: /opt/lab/flag.txt"
echo ""
echo "═══════════════════════════════════════════════════"
echo ""
echo "📋 COMANDOS ÚTILES:"
echo ""
echo "  Conectar al DMZ:    ssh alumno@192.16.0.10"
echo "  Ver estado:         ./scripts/check-status.sh"
echo "  Ver logs:           $COMPOSE_CMD logs -f"
echo "  Limpiar todo:       ./scripts/cleanup.sh"
echo ""
echo "📚 Consulta docs/EJERCICIOS.md para comenzar"
echo ""
#!/bin/bash

echo "╔══════════════════════════════════════════════════╗"
echo "║            LIMPIEZA DEL LABORATORIO              ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""

read -p "¿Seguro que deseas eliminar todo el laboratorio? (s/N): " confirm
if [[ ! "$confirm" =~ ^[Ss]$ ]]; then
    echo "❌ Operación cancelada"
    exit 0
fi

# Detectar comando compose
COMPOSE_CMD="docker compose"
if ! docker compose version &> /dev/null; then
    if command -v docker-compose &> /dev/null; then
        COMPOSE_CMD="docker-compose"
    fi
fi

echo ""
echo "🧹 Deteniendo contenedores..."
$COMPOSE_CMD down -v

echo "🗑️  Eliminando imágenes del laboratorio..."
docker rmi $(docker images | grep 'ssh-pivoting-lab' | awk '{print $3}') 2>/dev/null || true

echo "🌐 Limpiando redes..."
docker network prune -f

echo ""
echo "✅ Laboratorio completamente eliminado"
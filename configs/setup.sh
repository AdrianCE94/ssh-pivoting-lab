#!/bin/bash

echo "=== Iniciando configuración del servidor $SERVER_TYPE ==="

# Configurar SSH de forma permisiva para el laboratorio
cat > /etc/ssh/sshd_config << 'SSHD_EOF'
Port 22
PermitRootLogin yes
PasswordAuthentication yes
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding yes
PrintMotd no
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server
SSHD_EOF

# Crear usuario SSH si está especificado
if [ ! -z "$SSH_USER" ]; then
    useradd -m -s /bin/bash $SSH_USER
    echo "$SSH_USER:$SSH_PASS" | chpasswd
    echo "✓ Usuario $SSH_USER creado con éxito"
fi

# Configurar password de root
echo "root:rootpass123" | chpasswd
echo "✓ Password de root configurado"

# Configurar flag si existe (para el servidor interno)
if [ ! -z "$FLAG" ]; then
    echo "$FLAG" > /opt/lab/flag.txt
    chmod 600 /opt/lab/flag.txt
    chown root:root /opt/lab/flag.txt
    echo "✓ Flag configurada en /opt/lab/flag.txt"
fi

# Habilitar IP forwarding si es el pivot
if [ "$SERVER_TYPE" == "pivot" ]; then
    sysctl -w net.ipv4.ip_forward=1 > /dev/null 2>&1
    echo "✓ IP forwarding habilitado en el pivot"
fi

# Crear banner SSH personalizado
cat > /etc/ssh/banner << 'BANNER_EOF'
╔═══════════════════════════════════════════╗
║   SSH PIVOTING LAB - HACKING ÉTICO       ║
║   ⚠️  Solo para uso educativo             ║
╚═══════════════════════════════════════════╝
BANNER_EOF

echo "Banner /etc/ssh/banner" >> /etc/ssh/sshd_config

# Iniciar servicio SSH
service ssh start > /dev/null 2>&1
echo "✓ Servicio SSH iniciado"

# Mostrar información del servidor
echo "==================================="
echo "Servidor: $SERVER_TYPE"
echo "Hostname: $(hostname)"
echo "IPs configuradas:"
ip addr show | grep "inet " | grep -v "127.0.0.1" | awk '{print "  - " $2}'
echo "==================================="

# Mantener contenedor activo
tail -f /dev/null
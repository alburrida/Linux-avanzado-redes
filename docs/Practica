# Práctica: Linux avanzado y redes  
**Scripting Bash, administración del sistema, TCP/IP, DNS y DHCP**

## 1. Objetivo
El objetivo de esta práctica ha sido configurar un servidor Linux completo con administración básica del sistema, automatización mediante scripts Bash, acceso remoto seguro por SSH y servicios de red locales (DNS y DHCP), así como realizar pruebas de diagnóstico de conectividad.

## 2. Entorno de trabajo
- **Hipervisor:** Oracle VirtualBox
- **Servidor:** Ubuntu Server 24.04.4 LTS
- **Cliente:** Ubuntu Server
- **Red del servidor:**
  - `enp0s3` → NAT (`10.0.2.15/24`)
  - `enp0s8` → red interna `labnet` (`192.168.50.10/24`)
- **Red del cliente:**
  - `enp0s3` → red interna `labnet` (IP obtenida por DHCP, por ejemplo `192.168.50.122`)

> Nota: el enunciado indicaba Ubuntu Server 22.04, pero la práctica se realizó sobre Ubuntu Server 24.04.4 LTS.

## 3. Usuarios, grupos y permisos

### 3.1 Grupos creados
- `developers`
- `ops`

### 3.2 Usuarios creados
- `dev1`
- `dev2`
- `ops1`

### 3.3 Asignación de grupos
- `dev1` y `dev2` añadidos al grupo `developers`
- `ops1` añadido al grupo `ops`

### 3.4 Estructura de directorios
Se crearon los siguientes directorios:
- `/shared/dev`
- `/shared/ops`
- `/backups`

### 3.5 Permisos
- `/shared/dev` → grupo `developers`
- `/shared/ops` → grupo `ops`

Comandos utilizados:
```
sudo addgroup developers
sudo addgroup ops

sudo adduser dev1
sudo adduser dev2
sudo adduser ops1

sudo usermod -aG developers dev1
sudo usermod -aG developers dev2
sudo usermod -aG ops ops1

sudo mkdir -p /shared/dev /shared/ops /backups
sudo chown root:developers /shared/dev
sudo chown root:ops /shared/ops
sudo chmod 2775 /shared/dev
sudo chmod 2770 /shared/ops
sudo chmod 755 /shared
```

## 4. Scripts Bash

### 4.1 Script `backup.sh`
Se creó un script que:
- recibe una carpeta como argumento
- comprueba si existe
- genera un archivo `.tar.gz` con fecha y hora
- lo guarda en `/backups`
- elimina copias de seguridad de más de 7 días
- registra la operación en `/var/log/backup.log`

Ruta:
- `/usr/local/bin/backup.sh`

Contenido:
```bash 
#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="${1:-}"
BACKUP_DIR="/backups"
LOG_FILE="/var/log/backup.log"

if [ -z "$SOURCE_DIR" ]; then
  echo "Uso: $0 <carpeta>"
  exit 1
fi

if [ ! -d "$SOURCE_DIR" ]; then
  echo "Error: la carpeta no existe: $SOURCE_DIR"
  exit 1
fi

mkdir -p "$BACKUP_DIR"
touch "$LOG_FILE"

SOURCE_DIR="${SOURCE_DIR%/}"
BASE_NAME="$(basename "$SOURCE_DIR")"
TIMESTAMP="$(date +%F_%H-%M-%S)"
ARCHIVE_PATH="${BACKUP_DIR}/${BASE_NAME}_${TIMESTAMP}.tar.gz"

tar -czf "$ARCHIVE_PATH" -C "$(dirname "$SOURCE_DIR")" "$BASE_NAME"

find "$BACKUP_DIR" -type f -name "${BASE_NAME}_*.tar.gz" -mtime +7 -delete

echo "[$(date '+%F %T')] OK backup de $SOURCE_DIR -> $ARCHIVE_PATH" >> "$LOG_FILE"
```

### 4.2 Script `monitor.sh`
Se creó un script que muestra:
- uso de disco
- memoria
- 5 procesos más pesados
- uptime
- conexiones de red
- puertos en escucha

Ruta:
- `/usr/local/bin/monitor.sh`

Contenido:
```bash
#!/usr/bin/env bash

echo "===== $(date '+%F %T') ====="
echo

echo "== Uso de disco =="
df -h /
echo

echo "== Memoria =="
free -h
echo

echo "== Top 5 procesos por memoria =="
ps -eo pid,user,comm,%cpu,%mem --sort=-%mem | head -n 6
echo

echo "== Uptime =="
uptime -p
echo

echo "== Conexiones de red =="
ss -tun
echo

echo "== Puertos en escucha =="
ss -tuln
echo
```

## 5. Automatización con cron

Se configuró el `crontab` de `root` con estas tareas:
```
0 2 * * * /usr/local/bin/backup.sh /shared >/dev/null 2>&1
*/15 * * * * /usr/local/bin/monitor.sh >> /var/log/monitor.log 2>&1
```

Con ello:
- el backup se ejecuta diariamente a las 02:00
- el script de monitorización se ejecuta cada 15 minutos

## 6. Configuración de SSH

### 6.1 Generación de clave
Se generó una clave SSH ED25519 desde el host y se copió al servidor.

### 6.2 Endurecimiento del servicio
Se configuró SSH para:
- desactivar el login de `root`
- desactivar autenticación por contraseña
- permitir únicamente autenticación por clave pública

Archivo utilizado:
- `/etc/ssh/sshd_config.d/00-hardening.conf`

Contenido:

```
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
KbdInteractiveAuthentication no
ChallengeResponseAuthentication no
```

### 6.3 Verificación
Se comprobó que:
- `ssh -p 2222 alba@127.0.0.1` funciona con clave
- la autenticación por contraseña queda deshabilitada
- `sshd -t` no devuelve errores

## 7. Configuración de red

### 7.1 Netplan del servidor
Se configuró el servidor con:
- `enp0s3` por DHCP para salida a internet
- `enp0s8` con IP estática `192.168.50.10/24`

Configuración:
```
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: true
    enp0s8:
      dhcp4: false
      addresses:
        - 192.168.50.10/24
```

### 7.2 Netplan del cliente
El cliente se configuró para obtener IP automáticamente por DHCP en `enp0s3`.

Configuración:
```
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: true
      nameservers:
        addresses: [192.168.50.10]
```

## 8. Configuración de DNS y DHCP con dnsmasq

Se instaló y configuró `dnsmasq` en el servidor para proporcionar:
- **DNS local**
- **DHCP** en la red interna

Archivo de configuración:
- `/etc/dnsmasq.d/taskflow.conf`

Configuración utilizada:
```
interface=enp0s8
bind-interfaces
listen-address=192.168.50.10

domain-needed
bogus-priv
domain=taskflow.local
local=/taskflow.local/

address=/taskflow.local/192.168.50.10
address=/api.taskflow.local/192.168.50.10

dhcp-range=192.168.50.100,192.168.50.150,255.255.255.0,12h
dhcp-option=option:dns-server,192.168.50.10
```

### 8.1 Resultado
Desde el cliente se verificó que:
- recibe una IP por DHCP, por ejemplo `192.168.50.122`
- resuelve `taskflow.local`
- resuelve `api.taskflow.local`
- hace `ping` correctamente por nombre

Comprobaciones realizadas:
```
nslookup taskflow.local 192.168.50.10
nslookup api.taskflow.local 192.168.50.10
ping -c 3 taskflow.local
ping -c 3 api.taskflow.local
```

## 9. Captura y análisis de tráfico

### 9.1 Captura DNS
En el servidor se capturó tráfico DNS con:
```
sudo tcpdump -i enp0s8 -n port 53
```

Se observaron consultas `A` para:
- `taskflow.local`
- `api.taskflow.local`

y respuestas desde `192.168.50.10`.

### 9.2 Captura DHCP
En el servidor se capturó tráfico DHCP con:

```
sudo tcpdump -i enp0s8 -n 'port 67 or port 68'
```

Se observaron tramas equivalentes a:
- `DHCPDISCOVER`
- `DHCPOFFER`
- `DHCPREQUEST`
- `DHCPACK`

lo que confirma que el cliente obtuvo dirección IP correctamente.

## 10. Diagnóstico de red

### 10.1 Fallo simulado 1: parada de `dnsmasq`
Se detuvo el servicio:

```
sudo systemctl stop dnsmasq
```

#### Síntomas
- `nslookup` falla
- `ping` por nombre falla

#### Diagnóstico
Se utilizaron los siguientes comandos:
```
ss -tuln | grep -E ':53|:67'
ip route
traceroute 192.168.50.122
```

#### Observaciones
- dejaron de aparecer los puertos `53` y `67` del servicio en la interfaz interna
- `ip route` seguía siendo correcto
- `traceroute` seguía alcanzando el cliente

#### Conclusión
La conectividad IP seguía operativa, pero el servicio DNS/DHCP no estaba disponible.

#### Solución

sudo systemctl start dnsmasq

### 10.2 Fallo simulado 2: cambio de IP del servidor
Se modificó temporalmente la IP del servidor de:
- `192.168.50.10/24`
a:
- `192.168.50.20/24`

#### Diagnóstico
Se utilizaron los siguientes comandos:
```
ip a
ip route
ss -tuln | grep -E ':53|:67'
```

#### Observaciones
- `ip a` mostraba que la IP del servidor ya no era `192.168.50.10`
- `ip route` seguía mostrando la red `192.168.50.0/24` correctamente
- el problema no era de routing, sino de direccionamiento

#### Conclusión
La incidencia se debía a que el cliente continuaba usando la IP antigua del servicio.

#### Solución
Se restauró la IP original y se reinició `dnsmasq`.

## 11. Resultado final
Se ha conseguido:

- crear usuarios y grupos
- aplicar permisos sobre directorios compartidos
- desarrollar scripts Bash funcionales
- programar tareas automáticas con `cron`
- securizar SSH con clave pública
- desactivar acceso de `root` por SSH
- desactivar autenticación por contraseña
- configurar DNS local con `dnsmasq`
- configurar DHCP funcional para el cliente
- verificar resolución local y conectividad
- capturar tráfico DNS y DHCP
- diagnosticar y documentar fallos de red
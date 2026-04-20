# Linux avanzado y redes

Práctica de administración de sistemas en Linux con automatización en Bash, acceso seguro por SSH y configuración de servicios de red locales con DNS y DHCP.

## Contenido de la práctica

En esta práctica se ha configurado:

- usuarios y grupos (`developers`, `ops`)
- permisos sobre carpetas compartidas
- script de copia de seguridad (`backup.sh`)
- script de monitorización (`monitor.sh`)
- tareas programadas con `cron`
- acceso SSH con clave pública
- desactivación de login de `root` y autenticación por contraseña
- red interna con IP estática en el servidor
- DNS y DHCP con `dnsmasq`
- pruebas de conectividad y diagnóstico de red con `tcpdump`, `ss`, `ip route` y `traceroute`
- webhook para discord

## Estructura del repositorio

```text
.
├── README.md
├── .gitignore
├── scripts/
│   ├── backup.sh
│   └── monitor.sh
├── config/
│   ├── 00-hardening.conf
│   ├── 01-client.yaml
│   ├── 01-lab.yaml
│   └── taskflow.conf
└── docs/
```

## Scripts

### `backup.sh`
Realiza una copia comprimida de una carpeta, la guarda en `/backups`, elimina backups antiguos y escribe la ejecución en `/var/log/backup.log`.

### `monitor.sh`
Muestra información básica del sistema:
- uso de disco
- memoria
- procesos más pesados
- uptime
- conexiones de red
- puertos en escucha

## Red del laboratorio

### Servidor
- `enp0s3` → NAT / salida a internet
- `enp0s8` → red interna `192.168.50.10/24`

### Cliente
- IP obtenida por DHCP en la red interna
- uso del servidor como DNS local

## DNS y DHCP

Se ha utilizado `dnsmasq` para:

- resolver `taskflow.local`
- resolver `api.taskflow.local`
- asignar direcciones IP en el rango `192.168.50.100-150`

## Seguridad SSH

Se ha configurado SSH para:

- permitir acceso por clave pública
- desactivar autenticación por contraseña
- desactivar acceso de `root`

## Diagnóstico realizado

Se han realizado pruebas de:
- resolución DNS
- conectividad por nombre e IP
- captura de tráfico DNS
- captura de tráfico DHCP
- simulación de fallo de `dnsmasq`
- simulación de cambio de IP del servidor


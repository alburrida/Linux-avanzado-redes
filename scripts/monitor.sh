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

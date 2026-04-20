#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="${1:-}"
BACKUP_DIR="/backups"
LOG_FILE="/var/log/backup.log"
WEBHOOK_URL="miwebhooklopongoluego"

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

LOG_LINE="[$(date '+%F %T')] OK backup de $SOURCE_DIR -> $ARCHIVE_PATH"
echo "$LOG_LINE" >> "$LOG_FILE"

if [ -n "$WEBHOOK_URL" ] && [ "$WEBHOOK_URL" != "PEGA_AQUI_TU_WEBHOOK" ]; then
  HOSTNAME_VALUE="$(hostname)"

  HTTP_CODE=$(curl -o /dev/null -s -w "%{http_code}" \
    -H "Content-Type: application/json" \
    -X POST \
    -d "{\"content\":\"Backup completado en ${HOSTNAME_VALUE}: ${ARCHIVE_PATH}\"}" \
    "$WEBHOOK_URL" || true)

  echo "[$(date '+%F %T')] Discord webhook HTTP: ${HTTP_CODE}" >> "$LOG_FILE"
fi

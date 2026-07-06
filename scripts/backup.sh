#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="bookings_db"
DB_NAME="bookingsdb"
DB_USER="app_admin"
BACKUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/backup_${TIMESTAMP}.dump"

mkdir -p "$BACKUP_DIR"

docker exec -t "${CONTAINER_NAME}" pg_dump -U "${DB_USER}" -d "${DB_NAME}" -Fc > "${BACKUP_FILE}"

echo "Backup complete: ${BACKUP_FILE}"
#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="bookings_db"
DB_USER="app_admin"
RESTORE_DB="bookingsdb_restore"
BACKUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/backups"

if [ "${1:-}" != "" ]; then
  BACKUP_FILE="$1"
else
  BACKUP_FILE=$(ls -t "${BACKUP_DIR}"/backup_*.dump 2>/dev/null | head -n1)
fi

echo "Restoring from: ${BACKUP_FILE}"

docker exec -t "${CONTAINER_NAME}" psql -U "${DB_USER}" -d postgres -c "DROP DATABASE IF EXISTS ${RESTORE_DB};"
docker exec -t "${CONTAINER_NAME}" psql -U "${DB_USER}" -d postgres -c "CREATE DATABASE ${RESTORE_DB};"

docker cp "${BACKUP_FILE}" "${CONTAINER_NAME}:/tmp/restore.dump"
docker exec -t "${CONTAINER_NAME}" pg_restore -U "${DB_USER}" -d "${RESTORE_DB}" --no-owner --no-privileges /tmp/restore.dump

echo ""
echo "Restore complete. Row counts in ${RESTORE_DB}:"
docker exec -t "${CONTAINER_NAME}" psql -U "${DB_USER}" -d "${RESTORE_DB}" -c \
  "SELECT 'hotel_bookings' AS table_name, COUNT(*) FROM hotel_bookings
   UNION ALL
   SELECT 'booking_events', COUNT(*) FROM booking_events;"
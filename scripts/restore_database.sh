#!/bin/bash
# ============================================================================
# DATABASE RESTORE SCRIPT - DigiDekan
# ============================================================================
# Stellt ein Backup der PostgreSQL Datenbank wieder her
# VORSICHT: Überschreibt die aktuelle Datenbank!
# ============================================================================

set -e  # Exit on error

# ============================================================================
# CONFIGURATION
# ============================================================================
CONTAINER_NAME="digidekan-db"
DB_NAME="dekanat_production"
DB_USER="dekanat_user"

# ============================================================================
# CHECK ARGUMENTS
# ============================================================================
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <backup_file>"
    echo ""
    echo "Example:"
    echo "  $0 /opt/backups/digidekan/dekanat_20250101_020000.sql.gz"
    echo ""
    exit 1
fi

BACKUP_FILE="$1"

# ============================================================================
# VALIDATE BACKUP FILE
# ============================================================================
if [ ! -f "${BACKUP_FILE}" ]; then
    echo "ERROR: Backup file not found: ${BACKUP_FILE}"
    exit 1
fi

# ============================================================================
# CONFIRM RESTORE
# ============================================================================
echo "============================================================================"
echo "WARNING: DATABASE RESTORE"
echo "============================================================================"
echo ""
echo "This will REPLACE the current database with the backup:"
echo "  Backup File: ${BACKUP_FILE}"
echo "  Database: ${DB_NAME}"
echo "  Container: ${CONTAINER_NAME}"
echo ""
echo "ALL CURRENT DATA WILL BE LOST!"
echo ""
read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [ "${CONFIRM}" != "yes" ]; then
    echo "Restore cancelled."
    exit 0
fi

# ============================================================================
# CREATE SAFETY BACKUP
# ============================================================================
echo ""
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Creating safety backup of current database..."
SAFETY_BACKUP="/tmp/digidekan_safety_backup_$(date +%Y%m%d_%H%M%S).sql.gz"
docker exec "${CONTAINER_NAME}" pg_dump -U "${DB_USER}" "${DB_NAME}" | gzip > "${SAFETY_BACKUP}"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Safety backup created: ${SAFETY_BACKUP}"

# ============================================================================
# STOP BACKEND CONTAINER
# ============================================================================
echo ""
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Stopping backend container..."
docker stop digidekan-backend || true

# ============================================================================
# RESTORE DATABASE
# ============================================================================
echo ""
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Restoring database from backup..."

# Drop existing database
docker exec "${CONTAINER_NAME}" psql -U "${DB_USER}" -d postgres -c "DROP DATABASE IF EXISTS ${DB_NAME};"

# Create new database
docker exec "${CONTAINER_NAME}" psql -U "${DB_USER}" -d postgres -c "CREATE DATABASE ${DB_NAME} OWNER ${DB_USER};"

# Restore backup
if [[ "${BACKUP_FILE}" == *.gz ]]; then
    # Compressed backup
    gunzip -c "${BACKUP_FILE}" | docker exec -i "${CONTAINER_NAME}" psql -U "${DB_USER}" -d "${DB_NAME}"
else
    # Uncompressed backup
    cat "${BACKUP_FILE}" | docker exec -i "${CONTAINER_NAME}" psql -U "${DB_USER}" -d "${DB_NAME}"
fi

if [ $? -eq 0 ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Database restore successful!"
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: Database restore failed!"
    echo ""
    echo "Attempting to restore from safety backup..."
    gunzip -c "${SAFETY_BACKUP}" | docker exec -i "${CONTAINER_NAME}" psql -U "${DB_USER}" -d "${DB_NAME}"
    exit 1
fi

# ============================================================================
# START BACKEND CONTAINER
# ============================================================================
echo ""
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting backend container..."
docker start digidekan-backend

# ============================================================================
# VERIFY RESTORE
# ============================================================================
echo ""
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Verifying database..."
sleep 5
docker exec "${CONTAINER_NAME}" psql -U "${DB_USER}" -d "${DB_NAME}" -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public';"

echo ""
echo "============================================================================"
echo "RESTORE COMPLETE"
echo "============================================================================"
echo ""
echo "Safety backup saved at: ${SAFETY_BACKUP}"
echo "Keep this file until you've verified the restore!"
echo ""
echo "To verify the application:"
echo "  curl http://localhost/health"
echo "  curl http://localhost/api/health"
echo ""

# ============================================================================
# USAGE
# ============================================================================
# Restore from local backup:
#   sudo bash /opt/scripts/restore_database.sh /opt/backups/digidekan/dekanat_20250101_020000.sql.gz
#
# Restore from S3:
#   aws s3 cp s3://your-bucket/backups/digidekan/dekanat_20250101_020000.sql.gz /tmp/
#   sudo bash /opt/scripts/restore_database.sh /tmp/dekanat_20250101_020000.sql.gz
# ============================================================================

#!/bin/bash
# ============================================================================
# DATABASE BACKUP SCRIPT - DigiDekan
# ============================================================================
# Erstellt ein Backup der PostgreSQL Datenbank
# Kann manuell oder via Cron ausgeführt werden
# ============================================================================

set -e  # Exit on error

# ============================================================================
# CONFIGURATION
# ============================================================================
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/opt/backups/digidekan"
BACKUP_FILE="${BACKUP_DIR}/dekanat_${TIMESTAMP}.sql.gz"
CONTAINER_NAME="digidekan-db"
DB_NAME="dekanat_production"
DB_USER="dekanat_user"

# Retention (Tage)
RETENTION_DAYS=30

# Optional: S3 Bucket für Remote Backup
# S3_BUCKET="s3://your-bucket/backups/digidekan"

# ============================================================================
# CREATE BACKUP DIRECTORY
# ============================================================================
mkdir -p "${BACKUP_DIR}"

# ============================================================================
# BACKUP DATABASE
# ============================================================================
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting database backup..."

docker exec "${CONTAINER_NAME}" pg_dump -U "${DB_USER}" "${DB_NAME}" | gzip > "${BACKUP_FILE}"

if [ $? -eq 0 ]; then
    BACKUP_SIZE=$(du -h "${BACKUP_FILE}" | cut -f1)
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backup successful: ${BACKUP_FILE} (${BACKUP_SIZE})"
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: Backup failed!"
    exit 1
fi

# ============================================================================
# UPLOAD TO S3 (Optional)
# ============================================================================
# Uncomment wenn du Remote Backup nutzen willst:
# if command -v aws &> /dev/null; then
#     echo "[$(date '+%Y-%m-%d %H:%M:%S')] Uploading to S3..."
#     aws s3 cp "${BACKUP_FILE}" "${S3_BUCKET}/"
#     if [ $? -eq 0 ]; then
#         echo "[$(date '+%Y-%m-%d %H:%M:%S')] S3 upload successful"
#     else
#         echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: S3 upload failed"
#     fi
# fi

# ============================================================================
# CLEANUP OLD BACKUPS
# ============================================================================
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Cleaning up backups older than ${RETENTION_DAYS} days..."
find "${BACKUP_DIR}" -name "dekanat_*.sql.gz" -mtime +${RETENTION_DAYS} -delete
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Cleanup complete"

# ============================================================================
# LIST RECENT BACKUPS
# ============================================================================
echo ""
echo "Recent backups:"
ls -lh "${BACKUP_DIR}" | tail -5

echo ""
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backup script completed"

# ============================================================================
# USAGE
# ============================================================================
# Manual:
#   sudo bash /opt/scripts/backup_database.sh
#
# Cron (täglich um 2 Uhr):
#   0 2 * * * /opt/scripts/backup_database.sh >> /var/log/backup.log 2>&1
#
# Restore Backup:
#   gunzip -c /opt/backups/digidekan/dekanat_20250101_020000.sql.gz | \
#   docker exec -i digidekan-db psql -U dekanat_user -d dekanat_production
# ============================================================================

# Backend Scripts

Dieses Verzeichnis enthält Entwicklungs- und Migrations-Skripte.

## Dateien

### Migration Scripts (Historie)

Diese Skripte wurden während der Entwicklung für die Datenmigration verwendet:

- `migrate_complete.py` - Finale Migrationsversion
- `migrate_complete_v2.py` - Migrationsversion 2
- `migrate_complete_v3.py` - Migrationsversion 3

**Hinweis:** Diese Skripte sind nur für Referenzzwecke aufbewahrt. Für neue Migrationen verwenden Sie Flask-Migrate:

```bash
flask db migrate -m "Beschreibung"
flask db upgrade
```

## Verwendung

Die Skripte sollten aus dem `backend/` Verzeichnis ausgeführt werden:

```bash
cd backend
python scripts/migrate_complete.py
```

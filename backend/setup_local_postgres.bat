@echo off
REM ============================================================================
REM Setup lokale PostgreSQL-Datenbank
REM ============================================================================

echo ================================================================================
echo   PostgreSQL Datenbank Setup
echo ================================================================================
echo.

REM Setze PostgreSQL Passwort
set PGPASSWORD=postgres123

echo [1/4] Erstelle Datenbank...
psql -U postgres -h localhost -c "DROP DATABASE IF EXISTS dekanat_migration;"
psql -U postgres -h localhost -c "CREATE DATABASE dekanat_migration;"
echo    ✓ Datenbank erstellt

echo.
echo [2/4] Erstelle Benutzer...
psql -U postgres -h localhost -c "DROP USER IF EXISTS dekanat_user;"
psql -U postgres -h localhost -c "CREATE USER dekanat_user WITH PASSWORD 'dekanat123';"
echo    ✓ Benutzer erstellt

echo.
echo [3/4] Setze Berechtigungen...
psql -U postgres -h localhost -c "GRANT ALL PRIVILEGES ON DATABASE dekanat_migration TO dekanat_user;"
psql -U postgres -h localhost -d dekanat_migration -c "GRANT ALL ON SCHEMA public TO dekanat_user;"
psql -U postgres -h localhost -d dekanat_migration -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO dekanat_user;"
psql -U postgres -h localhost -d dekanat_migration -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO dekanat_user;"
echo    ✓ Berechtigungen gesetzt

echo.
echo [4/4] Test Verbindung...
psql -U dekanat_user -h localhost -d dekanat_migration -c "SELECT version();"

echo.
echo ================================================================================
echo   ✅ PostgreSQL Setup abgeschlossen!
echo ================================================================================
echo.
echo Database URI:
echo postgresql://dekanat_user:dekanat123@localhost:5432/dekanat_migration
echo.
pause

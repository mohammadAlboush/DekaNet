# Produktions-Deployment Checkliste

## Vor dem Deployment

### 1. Sicherheit (KRITISCH)

- [ ] **Neue Secrets generieren:**
  ```bash
  python -c "import secrets; print('SECRET_KEY:', secrets.token_hex(32))"
  python -c "import secrets; print('JWT_SECRET_KEY:', secrets.token_hex(32))"
  ```

- [ ] **Datenbank-Passwort ändern** (nicht das Standard-Passwort verwenden)

- [ ] **.env.production konfigurieren:**
  - [ ] `SECRET_KEY` mit neuem Wert
  - [ ] `JWT_SECRET_KEY` mit neuem Wert
  - [ ] `DATABASE_URL` mit echtem Passwort
  - [ ] `CORS_ORIGINS` auf Produktions-Domain setzen
  - [ ] `SESSION_COOKIE_SECURE=true` (für HTTPS)
  - [ ] `JWT_COOKIE_SECURE=true` (für HTTPS)

### 2. Infrastruktur

- [ ] **PostgreSQL-Datenbank einrichten:**
  ```bash
  # Datenbank erstellen
  createdb dekanat_production

  # Benutzer erstellen
  createuser dekanat_user

  # Migrationen ausführen
  flask db upgrade
  ```

- [ ] **Redis für Rate-Limiting einrichten** (optional aber empfohlen)

- [ ] **HTTPS/SSL-Zertifikat konfigurieren** (Let's Encrypt oder ähnlich)

- [ ] **Reverse Proxy (Nginx) konfigurieren:**
  ```nginx
  server {
      listen 443 ssl;
      server_name your-domain.com;

      location /api {
          proxy_pass http://localhost:5000;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
      }

      location / {
          root /var/www/digidekan/dist;
          try_files $uri $uri/ /index.html;
      }
  }
  ```

### 3. Backend-Deployment

```bash
cd backend

# Abhängigkeiten installieren
pip install -r requirements.txt

# Datenbank-Migrationen ausführen
flask db upgrade

# Mit Gunicorn starten
gunicorn -c gunicorn.conf.py run:app
```

### 4. Frontend-Deployment

```bash
cd digitales-dekanat-frontend/root_files

# Abhängigkeiten installieren
npm install

# Produktions-Build erstellen
npm run build

# dist/ Ordner auf Webserver kopieren
```

### 5. Docker-Deployment (Alternative)

```bash
# Mit Docker Compose
docker-compose -f docker-compose.production.yml up -d
```

---

## Nach dem Deployment

### Überprüfungen

- [ ] **API-Healthcheck:**
  ```bash
  curl https://your-domain.com/api/health
  ```

- [ ] **Login testen** (als Dekan und als Professor)

- [ ] **CORS überprüfen** (keine Fehler in Browser-Console)

- [ ] **SSL-Zertifikat überprüfen:**
  ```bash
  curl -I https://your-domain.com
  ```

### Monitoring einrichten

- [ ] **Error-Tracking** (Sentry oder ähnlich)
- [ ] **Uptime-Monitoring** (UptimeRobot oder ähnlich)
- [ ] **Log-Aggregation** (ELK Stack oder CloudWatch)

---

## Wichtige Dateien

| Datei | Zweck |
|-------|-------|
| `backend/.env.production` | Produktions-Umgebungsvariablen |
| `backend/gunicorn.conf.py` | Gunicorn Server-Konfiguration |
| `backend/docker/Dockerfile` | Docker-Image-Definition |
| `frontend/.env.production` | Frontend API-URL |

---

## Support

Bei Problemen:
1. Logs prüfen: `tail -f /var/log/digidekan/app.log`
2. Gunicorn-Status: `systemctl status digidekan`
3. Nginx-Status: `systemctl status nginx`

# ⚡ Quick Start: Production Deployment
**Ziel:** DigiDekan in Production bringen
**Zeit:** 3-5 Tage (je nach Erfahrung)
**Schwierigkeit:** ⭐⭐⭐ Mittel-Schwer

---

## 🎯 Phase 1: Kritische Fixes (Tag 1-2)

### ✅ 1. Backend-Validierung für Planungsphase
**Status:** ✅ ERLEDIGT
```python
# backend/app/services/planung_service.py (Zeile 73-82)
# Prüft ob Planungsphase aktiv ist vor Planung-Erstellung
```

### ❌ 2. Environment Variables - Backend
**Datei:** `backend/.env.production`

```bash
# ERSTELLE DIESE DATEI:
cd backend
cp .env.example .env.production

# FÜLLE AUS:
nano .env.production
```

**Inhalt:**
```bash
FLASK_ENV=production
FLASK_APP=run.py

# Generiere sichere Keys:
# python -c "import secrets; print(secrets.token_hex(32))"
SECRET_KEY=<64-stelliger-hex-string>
JWT_SECRET_KEY=<64-stelliger-hex-string>

DATABASE_URL=postgresql://dekanat_user:SECURE_PASSWORD@db:5432/dekanat_production
CORS_ORIGINS=https://your-domain.com

LOG_LEVEL=WARNING
RATELIMIT_STORAGE_URL=redis://redis:6379/1
```

**Generiere Keys:**
```bash
python3 -c "import secrets; print('SECRET_KEY=' + secrets.token_hex(32))"
python3 -c "import secrets; print('JWT_SECRET_KEY=' + secrets.token_hex(32))"
```

---

### ❌ 3. Gunicorn Configuration
**Datei:** `backend/gunicorn.conf.py`

```python
# ERSTELLE DIESE DATEI:
import multiprocessing

bind = "0.0.0.0:5000"
workers = multiprocessing.cpu_count() * 2 + 1
worker_class = "sync"
timeout = 30
keepalive = 2

accesslog = "/var/log/digidekan/access.log"
errorlog = "/var/log/digidekan/error.log"
loglevel = "warning"

proc_name = "digidekan"
```

**Update Dockerfile:**
```dockerfile
# docker/Dockerfile (Zeile 9)
# ÄNDERE:
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "run:app"]

# ZU:
CMD ["gunicorn", "--config", "gunicorn.conf.py", "run:app"]
```

---

### ❌ 4. Health Check Endpoint
**Datei:** `backend/app/api/health.py` (NEU ERSTELLEN)

```python
from flask import Blueprint, jsonify
from datetime import datetime
from app.extensions import db
from sqlalchemy import text

health_api = Blueprint('health', __name__)

@health_api.route('/health', methods=['GET'])
def health_check():
    """Health Check für Load Balancer"""
    try:
        # Prüfe DB Connection
        db.session.execute(text('SELECT 1'))

        return jsonify({
            'status': 'healthy',
            'database': 'connected',
            'timestamp': datetime.utcnow().isoformat()
        }), 200
    except Exception as e:
        return jsonify({
            'status': 'unhealthy',
            'error': str(e)
        }), 503

@health_api.route('/ready', methods=['GET'])
def readiness_check():
    """Readiness Check"""
    return jsonify({'status': 'ready'}), 200
```

**Registriere Blueprint:**
```python
# backend/app/__init__.py
# FÜGE HINZU nach anderen Blueprint-Imports:

from app.api.health import health_api
app.register_blueprint(health_api)
```

---

### ❌ 5. Frontend Build Configuration
**Datei:** `digitales-dekanat-frontend/root_files/package.json`

**PRÜFE ob diese Scripts vorhanden sind:**
```json
{
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview"
  }
}
```

**FALLS NICHT, HINZUFÜGEN:**
```bash
cd digitales-dekanat-frontend/root_files
npm install --save-dev typescript @types/node
```

**Teste Build:**
```bash
npm run build
# Sollte dist/ Ordner erstellen
```

---

### ❌ 6. Frontend Production .env
**Datei:** `digitales-dekanat-frontend/root_files/.env.production`

```bash
# ERSTELLE:
VITE_API_BASE_URL=/api

# ODER für separate API-Domain:
# VITE_API_BASE_URL=https://api.your-domain.com
```

---

### ❌ 7. Nginx Configuration
**Datei:** `frontend/nginx.conf` (NEU ERSTELLEN)

```nginx
user nginx;
worker_processes auto;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    sendfile on;
    keepalive_timeout 65;
    client_max_body_size 16M;

    gzip on;
    gzip_types text/plain text/css application/json application/javascript;

    server {
        listen 80;
        server_name _;

        root /usr/share/nginx/html;
        index index.html;

        # SPA Routing
        location / {
            try_files $uri $uri/ /index.html;
        }

        # API Proxy
        location /api {
            proxy_pass http://backend:5000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }

        # Security Headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-XSS-Protection "1; mode=block" always;
    }
}
```

---

### ❌ 8. Frontend Dockerfile
**Datei:** `frontend/Dockerfile` (NEU ERSTELLEN)

```dockerfile
# Build Stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY root_files/package*.json ./
RUN npm ci
COPY root_files/ ./
RUN npm run build

# Production Stage
FROM nginx:alpine
COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

---

### ❌ 9. Docker Compose Production
**Datei:** `docker/docker-compose.production.yml` (NEU ERSTELLEN)

```yaml
version: '3.8'

services:
  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_DB: ${DB_NAME}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - digidekan-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    networks:
      - digidekan-network
    restart: unless-stopped

  backend:
    build:
      context: ../backend
      dockerfile: ../docker/Dockerfile
    environment:
      FLASK_ENV: production
      DATABASE_URL: postgresql://${DB_USER}:${DB_PASSWORD}@db:5432/${DB_NAME}
      SECRET_KEY: ${SECRET_KEY}
      JWT_SECRET_KEY: ${JWT_SECRET_KEY}
      CORS_ORIGINS: ${CORS_ORIGINS}
      RATELIMIT_STORAGE_URL: redis://redis:6379/1
    volumes:
      - backend_uploads:/app/uploads
      - backend_logs:/var/log/digidekan
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started
    networks:
      - digidekan-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  frontend:
    build:
      context: ../digitales-dekanat-frontend
      dockerfile: Dockerfile
    ports:
      - "80:80"
    depends_on:
      - backend
    networks:
      - digidekan-network
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
  backend_uploads:
  backend_logs:

networks:
  digidekan-network:
    driver: bridge
```

---

### ❌ 10. Docker Environment File
**Datei:** `docker/.env` (NEU ERSTELLEN)

```bash
# Database
DB_USER=dekanat_user
DB_PASSWORD=GENERATE_SECURE_PASSWORD_HERE
DB_NAME=dekanat_production

# Backend Security (aus backend/.env.production kopieren)
SECRET_KEY=<64-char-hex>
JWT_SECRET_KEY=<64-char-hex>

# CORS
CORS_ORIGINS=https://your-domain.com
```

**Generiere DB Password:**
```bash
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

---

## 🎯 Phase 2: Testing (Tag 3)

### Test 1: Lokaler Build
```bash
# Backend bauen
cd docker
docker build -f Dockerfile -t digidekan-backend:latest ../backend

# Frontend bauen
docker build -f ../frontend/Dockerfile -t digidekan-frontend:latest ../digitales-dekanat-frontend

# Starte Production Setup
docker-compose -f docker-compose.production.yml up -d

# Prüfe Health
curl http://localhost/health
curl http://localhost/api/health
```

### Test 2: Database Migration
```bash
# Connect to backend container
docker exec -it digidekan-backend bash

# Run migrations
flask db upgrade

# Create test user
python -c "
from app import create_app, db
from app.models import Benutzer, Rolle
app = create_app('production')
with app.app_context():
    # Create roles if needed
    # Create admin user
    admin = Benutzer(username='admin', email='admin@example.com')
    admin.set_password('Change_Me_123')
    db.session.add(admin)
    db.session.commit()
"
```

### Test 3: Frontend Access
```bash
# Öffne Browser
# http://localhost

# Login testen
# API Calls prüfen (DevTools Network Tab)
```

---

## 🎯 Phase 3: Production Deployment (Tag 4)

### Option A: VPS (Hetzner, DigitalOcean)

**1. Server Setup:**
```bash
# SSH to server
ssh root@your-server-ip

# Update system
apt update && apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install Docker Compose
apt install docker-compose -y
```

**2. Clone Repository:**
```bash
cd /opt
git clone https://github.com/your-username/DigiDekan.git
cd DigiDekan
```

**3. Setup Environment:**
```bash
# Erstelle docker/.env mit production values
nano docker/.env

# Erstelle backend/.env.production
nano backend/.env.production

# Erstelle frontend/.env.production
nano frontend/root_files/.env.production
```

**4. Build & Start:**
```bash
cd docker
docker-compose -f docker-compose.production.yml up -d --build

# Prüfe logs
docker-compose logs -f
```

**5. SSL Setup (Let's Encrypt):**
```bash
# Install certbot
apt install certbot python3-certbot-nginx -y

# Get certificate
certbot certonly --standalone -d your-domain.com

# Update nginx.conf mit SSL
# Restart containers
docker-compose restart frontend
```

---

### Option B: Cloud (AWS, Azure, GCP)

**AWS Example:**
```bash
1. EC2 Instance (t3.medium)
2. RDS PostgreSQL (db.t3.micro)
3. ElastiCache Redis (cache.t3.micro)
4. Application Load Balancer
5. Route53 DNS
6. S3 für Backups
```

**Setup:**
```bash
# SSH to EC2
# Install Docker (siehe Option A)

# Update DATABASE_URL mit RDS endpoint
# Update RATELIMIT_STORAGE_URL mit ElastiCache endpoint
# Deploy (siehe Option A)
```

---

## 🎯 Phase 4: Post-Deployment (Tag 5)

### 1. Backup Setup
```bash
# Erstelle backup script
nano /opt/backup_db.sh
```

```bash
#!/bin/bash
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="/backups/dekanat_${TIMESTAMP}.sql.gz"

docker exec digidekan-db pg_dump -U dekanat_user dekanat_production | gzip > $BACKUP_FILE

# Optional: Upload to S3
# aws s3 cp $BACKUP_FILE s3://your-bucket/backups/

# Cleanup old backups (30 days)
find /backups -name "dekanat_*.sql.gz" -mtime +30 -delete
```

**Cron Job:**
```bash
crontab -e

# Daily at 2 AM
0 2 * * * /opt/backup_db.sh >> /var/log/backup.log 2>&1
```

---

### 2. Monitoring Setup
```bash
# Install monitoring tools
apt install prometheus grafana -y

# Configure prometheus
nano /etc/prometheus/prometheus.yml
```

**Prometheus Config:**
```yaml
scrape_configs:
  - job_name: 'digidekan'
    static_configs:
      - targets: ['localhost:5000']
```

---

### 3. Log Rotation
```bash
nano /etc/logrotate.d/digidekan
```

```
/var/log/digidekan/*.log {
    daily
    rotate 30
    compress
    delaycompress
    notifempty
    create 0640 www-data www-data
    sharedscripts
    postrotate
        docker-compose -f /opt/DigiDekan/docker/docker-compose.production.yml restart backend
    endscript
}
```

---

## ✅ Final Checklist

```bash
[ ] Phase 1: Kritische Fixes (Tag 1-2)
    [ ] Backend .env.production erstellt
    [ ] Gunicorn Config erstellt
    [ ] Health Check Endpoint implementiert
    [ ] Frontend Build Scripts konfiguriert
    [ ] Nginx Config erstellt
    [ ] Frontend Dockerfile erstellt
    [ ] Docker Compose Production erstellt
    [ ] Docker .env erstellt

[ ] Phase 2: Testing (Tag 3)
    [ ] Lokaler Build erfolgreich
    [ ] Database Migration erfolgreich
    [ ] Frontend Access erfolgreich
    [ ] API Calls funktionieren
    [ ] Health Checks PASS

[ ] Phase 3: Production Deployment (Tag 4)
    [ ] Server provisioniert
    [ ] Docker installiert
    [ ] Repository gecloned
    [ ] Environment Variables gesetzt
    [ ] Containers gestartet
    [ ] SSL konfiguriert
    [ ] Domain DNS konfiguriert

[ ] Phase 4: Post-Deployment (Tag 5)
    [ ] Backup-Cron aktiv
    [ ] Log-Rotation konfiguriert
    [ ] Monitoring läuft
    [ ] Dokumentation aktualisiert
    [ ] Team-Training durchgeführt
```

---

## 🆘 Troubleshooting

### Problem: Container startet nicht
```bash
# Logs prüfen
docker-compose logs backend
docker-compose logs frontend

# Neu bauen
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Problem: Database Connection Error
```bash
# Prüfe DB Container
docker-compose ps db

# Prüfe Credentials
docker-compose exec db psql -U dekanat_user -d dekanat_production -c "SELECT 1;"

# Prüfe Network
docker network inspect docker_digidekan-network
```

### Problem: Frontend 502 Bad Gateway
```bash
# Prüfe Backend Health
curl http://localhost:5000/health

# Prüfe Nginx Config
docker-compose exec frontend nginx -t

# Reload Nginx
docker-compose restart frontend
```

---

## 📞 Support

**Dokumentation:**
- PRODUCTION_READINESS_REPORT.md - Vollständiger Report
- TECHNISCHE_DOKUMENTATION.md - System-Architektur
- SYSTEM_ANALYSE.md - Code-Analyse

**Bei Fragen:**
1. Prüfe logs: `docker-compose logs -f`
2. Health Check: `curl http://localhost/health`
3. Prüfe PRODUCTION_READINESS_REPORT.md

---

**Erstellt:** 2025-12-04
**Version:** 1.0
**Status:** Ready for Execution
**Geschätzte Zeit:** 3-5 Tage

🚀 **Viel Erfolg beim Deployment!**

# Technische Dokumentation: DigiDekan System
**Version:** 1.0.0
**Datum:** 2025-12-04
**Autor:** Development Team

---

## 📖 Inhaltsverzeichnis

1. [System-Übersicht](#system-übersicht)
2. [Architektur](#architektur)
3. [Datenmodell](#datenmodell)
4. [API-Dokumentation](#api-dokumentation)
5. [Frontend-Architektur](#frontend-architektur)
6. [Sicherheit](#sicherheit)
7. [Deployment](#deployment)
8. [Wartung & Monitoring](#wartung--monitoring)

---

## 1. System-Übersicht

### 1.1 Zweck
Das DigiDekan-System digitalisiert den Prozess der Semesterplanung an Hochschulen:
- **Professoren** planen ihre Lehrveranstaltungen
- **Dekane** verwalten Semester und genehmigen Planungen
- **System** automatisiert Prozesse und Validierung

### 1.2 Technologie-Stack

#### Backend
```
├── Python 3.11+
├── Flask 3.0
├── SQLAlchemy (ORM)
├── SQLite (Development) / PostgreSQL (Production)
├── Flask-JWT-Extended (Authentication)
├── Flask-CORS
├── Flask-Limiter (Rate Limiting)
└── Flask-Caching
```

#### Frontend
```
├── React 18
├── TypeScript 5
├── Vite (Build Tool)
├── Material-UI (MUI) v5
├── Axios (HTTP Client)
├── Zustand (State Management)
└── React Router v6
```

### 1.3 System-Anforderungen

**Server:**
- CPU: 2 Cores minimum
- RAM: 4 GB minimum
- Disk: 10 GB minimum
- OS: Linux (Ubuntu 22.04 empfohlen) / Windows Server

**Client:**
- Browser: Chrome 100+, Firefox 100+, Safari 15+, Edge 100+
- JavaScript: Aktiviert
- Cookies: Aktiviert (für Session)

---

## 2. Architektur

### 2.1 Gesamt-Architektur

```
┌─────────────────────────────────────────────────────────┐
│                        CLIENT                            │
│  ┌────────────────────────────────────────────────┐    │
│  │           React Frontend (Port 3001)           │    │
│  │  - Components (UI)                              │    │
│  │  - Services (API Calls)                         │    │
│  │  - Store (State Management)                     │    │
│  └────────────────────────────────────────────────┘    │
└──────────────────────┬──────────────────────────────────┘
                       │ HTTPS (REST API)
                       │ JWT Token Authentication
┌──────────────────────▼──────────────────────────────────┐
│                      SERVER                              │
│  ┌────────────────────────────────────────────────┐    │
│  │           Flask Backend (Port 5000)            │    │
│  │  ┌──────────────────────────────────────┐     │    │
│  │  │         API Layer (Blueprints)       │     │    │
│  │  │  - /api/auth                          │     │    │
│  │  │  - /api/semester                      │     │    │
│  │  │  - /api/planung                       │     │    │
│  │  │  - /api/dashboard                     │     │    │
│  │  └──────────────┬───────────────────────┘     │    │
│  │                 │                              │    │
│  │  ┌──────────────▼───────────────────────┐     │    │
│  │  │      Service Layer (Business Logic)  │     │    │
│  │  │  - semester_service.py                │     │    │
│  │  │  - planung_service.py                 │     │    │
│  │  │  - auth_service.py                    │     │    │
│  │  └──────────────┬────────────────────────┘     │    │
│  │                 │                              │    │
│  │  ┌──────────────▼────────────────────────┐    │    │
│  │  │      Model Layer (ORM)                │    │    │
│  │  │  - Semester                            │    │    │
│  │  │  - Semesterplanung                     │    │    │
│  │  │  - Modul                               │    │    │
│  │  │  - Benutzer                            │    │    │
│  │  └──────────────┬─────────────────────────┘    │    │
│  └─────────────────┼──────────────────────────────┘    │
│                    │                                    │
│  ┌─────────────────▼─────────────────────────────┐    │
│  │          Database (PostgreSQL/SQLite)          │    │
│  └────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────┘
```

### 2.2 Daten-Fluss

#### Beispiel: Professor erstellt Planung

```
┌─────────┐     ┌─────────┐     ┌─────────┐     ┌──────────┐
│ Browser │────▶│ React   │────▶│ Service │────▶│ Backend  │
│         │     │Component│     │ Layer   │     │ API      │
└─────────┘     └─────────┘     └─────────┘     └──────────┘
     │               │               │                │
     │ User Input    │               │                │
     ├──────────────▶│               │                │
     │               │               │                │
     │               │ API Call      │                │
     │               ├──────────────▶│                │
     │               │  POST /planung│                │
     │               │               │                │
     │               │               │ JWT Validation │
     │               │               ├───────────────▶│
     │               │               │                │
     │               │               │ Business Logic │
     │               │               │◀───────────────│
     │               │               │                │
     │               │               │ DB Insert      │
     │               │               ├───────────────▶│
     │               │               │                │
     │               │   Response    │◀───────────────│
     │               │◀──────────────│                │
     │               │  {id: 1, ...} │                │
     │  Update UI    │               │                │
     │◀──────────────│               │                │
     │               │               │                │
```

---

## 3. Datenmodell

### 3.1 Entity-Relationship Diagram

```
┌──────────────┐         ┌──────────────────┐         ┌────────────┐
│   Semester   │────────▶│ Semesterplanung  │────────▶│  Benutzer  │
│              │  1:N    │                  │  N:1    │            │
│ - id         │         │ - id             │         │ - id       │
│ - bezeichnung│         │ - semester_id    │         │ - username │
│ - kuerzel    │         │ - benutzer_id    │         │ - rolle_id │
│ - ist_aktiv  │         │ - status         │         │ - email    │
│ - ist_plan.. │         │ - gesamt_sws     │         │            │
└──────────────┘         └──────────────────┘         └────────────┘
       │                          │
       │                          │
       │                          │ N:M
       │                          ▼
       │                 ┌──────────────────┐
       │                 │  Geplantes_Modul │
       │                 │                  │
       │                 │ - id             │
       │                 │ - planung_id     │
       │                 │ - modul_id       │
       │                 │ - anzahl_vorl..  │
       │                 │ - anzahl_ueb..   │
       │                 └──────────────────┘
       │                          │
       │                          │ N:1
       │                          ▼
       │                 ┌──────────────────┐
       └────────────────▶│      Modul       │
         N:1             │                  │
                         │ - id             │
                         │ - kuerzel        │
                         │ - bezeichnung_de │
                         │ - turnus         │
                         │ - po_id          │
                         │ - sws_gesamt     │
                         └──────────────────┘
                                  │
                                  │ N:1
                                  ▼
                         ┌──────────────────┐
                         │ Pruefungsordnung │
                         │                  │
                         │ - id             │
                         │ - po_jahr        │
                         │ - gueltig_von    │
                         │ - gueltig_bis    │
                         └──────────────────┘
```

### 3.2 Wichtige Tabellen

#### Semester
```sql
CREATE TABLE semester (
    id INTEGER PRIMARY KEY,
    bezeichnung VARCHAR(50) NOT NULL,
    kuerzel VARCHAR(10) UNIQUE NOT NULL,
    start_datum DATE NOT NULL,
    ende_datum DATE NOT NULL,
    vorlesungsbeginn DATE,
    vorlesungsende DATE,
    ist_aktiv BOOLEAN DEFAULT FALSE,
    ist_planungsphase BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Constraint: Nur 1 Semester kann aktiv sein
CREATE UNIQUE INDEX idx_one_active_semester
ON semester(ist_aktiv) WHERE ist_aktiv = TRUE;
```

#### Semesterplanung
```sql
CREATE TABLE semesterplanung (
    id INTEGER PRIMARY KEY,
    semester_id INTEGER NOT NULL,
    benutzer_id INTEGER NOT NULL,
    planungsphase_id INTEGER,
    status VARCHAR(20) DEFAULT 'entwurf',
    gesamt_sws DECIMAL(5,2),
    eingereicht_am TIMESTAMP,
    freigegeben_am TIMESTAMP,
    freigegeben_von INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (semester_id) REFERENCES semester(id),
    FOREIGN KEY (benutzer_id) REFERENCES benutzer(id),
    FOREIGN KEY (planungsphase_id) REFERENCES planungsphasen(id),

    -- Ein User kann nur 1 Planung pro Semester haben
    UNIQUE(semester_id, benutzer_id)
);
```

#### Modul
```sql
CREATE TABLE modul (
    id INTEGER PRIMARY KEY,
    kuerzel VARCHAR(20) UNIQUE NOT NULL,
    bezeichnung_de VARCHAR(200) NOT NULL,
    bezeichnung_en VARCHAR(200),
    leistungspunkte INTEGER,
    turnus VARCHAR(50),
    po_id INTEGER NOT NULL,
    sws_gesamt DECIMAL(5,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (po_id) REFERENCES pruefungsordnung(id)
);

-- Index für schnelle Turnus-Suche
CREATE INDEX idx_modul_turnus ON modul(turnus);
CREATE INDEX idx_modul_po ON modul(po_id);
```

### 3.3 Business Rules (Constraints)

1. **Semester:**
   - Nur 1 Semester kann `ist_aktiv = TRUE` sein
   - `start_datum` < `ende_datum`
   - `kuerzel` ist unique

2. **Semesterplanung:**
   - Status: `entwurf`, `eingereicht`, `freigegeben`, `abgelehnt`
   - Ein User kann nur 1 Planung pro Semester haben
   - Status-Übergänge:
     ```
     entwurf → eingereicht → freigegeben
     entwurf → eingereicht → abgelehnt → entwurf (Überarbeitung)
     ```

3. **Module:**
   - `turnus` filtert Sichtbarkeit:
     - "Wintersemester" → nur in WS sichtbar
     - "Sommersemester" → nur in SS sichtbar
     - "Jedes Semester" → immer sichtbar

---

## 4. API-Dokumentation

### 4.1 Authentication

#### POST /api/auth/login
```http
POST /api/auth/login
Content-Type: application/json

{
  "username": "dozent",
  "password": "dozent123"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Login erfolgreich",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIs...",
    "user": {
      "id": 2,
      "username": "dozent",
      "rolle": "dozent",
      "vorname": "Max",
      "nachname": "Mustermann"
    }
  }
}
```

**Errors:**
- 401: Ungültige Credentials
- 403: Account deaktiviert

---

### 4.2 Semester Management

#### GET /api/semester/
Hole alle Semester.

```http
GET /api/semester/
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "bezeichnung": "Wintersemester 2025/2026",
      "kuerzel": "WS2025",
      "start_datum": "2025-10-01",
      "ende_datum": "2026-03-31",
      "ist_aktiv": true,
      "ist_planungsphase": true,
      "ist_wintersemester": true,
      "ist_sommersemester": false,
      "ist_laufend": true
    }
  ]
}
```

---

#### GET /api/semester/auto-vorschlag
Automatischer Semester-Wechsel Vorschlag.

```http
GET /api/semester/auto-vorschlag
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "message": "Alles korrekt: 'Wintersemester 2025/2026' ist aktiv und läuft aktuell.",
  "data": {
    "vorschlag": null,
    "aktives": {
      "id": 1,
      "bezeichnung": "Wintersemester 2025/2026",
      "kuerzel": "WS2025"
    },
    "laufendes": {
      "id": 1,
      "bezeichnung": "Wintersemester 2025/2026",
      "kuerzel": "WS2025"
    },
    "ist_korrekt": true,
    "empfehlung": "Alles korrekt: 'Wintersemester 2025/2026' ist aktiv und läuft aktuell.",
    "datum_heute": "2025-12-04"
  }
}
```

---

#### POST /api/semester/{id}/aktivieren
Aktiviere ein Semester (deaktiviert automatisch alle anderen).

```http
POST /api/semester/1/aktivieren
Authorization: Bearer {token}
Content-Type: application/json

{
  "planungsphase": true
}
```

**Response:**
```json
{
  "success": true,
  "message": "Semester erfolgreich aktiviert",
  "data": {
    "id": 1,
    "bezeichnung": "Wintersemester 2025/2026",
    "ist_aktiv": true,
    "ist_planungsphase": true
  }
}
```

---

### 4.3 Planung API

#### POST /api/planung/
Erstelle oder lade Semesterplanung.

```http
POST /api/planung/
Authorization: Bearer {token}
Content-Type: application/json

{
  "semester_id": 1,
  "po_id": 1
}
```

**Response (Neu erstellt):**
```json
{
  "success": true,
  "message": "Semesterplanung erfolgreich erstellt",
  "data": {
    "id": 5,
    "semester_id": 1,
    "benutzer_id": 2,
    "status": "entwurf",
    "created": true,
    "gesamt_sws": 0,
    "semester": {
      "id": 1,
      "bezeichnung": "Wintersemester 2025/2026"
    },
    "benutzer": {
      "id": 2,
      "username": "dozent"
    }
  }
}
```

**Response (Existierend geladen):**
```json
{
  "success": true,
  "message": "Bestehende Semesterplanung geladen",
  "data": {
    "id": 5,
    "status": "entwurf",
    "created": false,
    ...
  }
}
```

---

#### POST /api/planung/{id}/module
Füge Modul zur Planung hinzu.

```http
POST /api/planung/5/module
Authorization: Bearer {token}
Content-Type: application/json

{
  "modul_id": 10,
  "anzahl_vorlesungen": 2,
  "anzahl_uebungen": 1
}
```

**Response:**
```json
{
  "success": true,
  "message": "Modul erfolgreich zur Planung hinzugefügt",
  "data": {
    "id": 15,
    "planung_id": 5,
    "modul_id": 10,
    "anzahl_vorlesungen": 2,
    "anzahl_uebungen": 1,
    "sws": 6.0,
    "modul": {
      "kuerzel": "GDM",
      "bezeichnung_de": "Grundlagen des Managements"
    }
  }
}
```

---

#### POST /api/planung/{id}/einreichen
Reiche Planung zur Freigabe ein.

```http
POST /api/planung/5/einreichen
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "message": "Semesterplanung erfolgreich eingereicht",
  "data": {
    "id": 5,
    "status": "eingereicht",
    "eingereicht_am": "2025-12-04T10:30:00"
  }
}
```

---

### 4.4 Error Responses

**Standard Error Format:**
```json
{
  "success": false,
  "message": "Fehler-Beschreibung",
  "errors": ["Detail 1", "Detail 2"]
}
```

**HTTP Status Codes:**
- `200 OK` - Erfolgreich
- `201 Created` - Ressource erstellt
- `400 Bad Request` - Ungültige Eingabe
- `401 Unauthorized` - Nicht authentifiziert
- `403 Forbidden` - Keine Berechtigung
- `404 Not Found` - Ressource nicht gefunden
- `500 Internal Server Error` - Server-Fehler

---

## 5. Frontend-Architektur

### 5.1 Verzeichnis-Struktur

```
digitales-dekanat-frontend/root_files/src/
├── components/
│   ├── common/           # Wiederverwendbare Komponenten
│   │   ├── Toast.tsx
│   │   └── LoadingSpinner.tsx
│   ├── dashboard/        # Dashboard-Widgets
│   │   ├── SemesterManagement.tsx
│   │   └── NichtZugeordneteModule.tsx
│   ├── planning/         # Planungs-Wizard
│   │   └── wizard/
│   │       └── steps/
│   │           ├── StepSemesterAuswahl.tsx
│   │           ├── Stepmodulehinzufuegen.tsx
│   │           └── Stepubersicht.tsx
│   └── dekan/            # Dekan-spezifische Komponenten
│       ├── DekanStatistics.tsx
│       └── AuftraegeWidget.tsx
│
├── services/             # API-Clients
│   ├── api.ts           # Basis Axios-Setup
│   ├── semesterService.ts
│   ├── planungService.ts
│   └── poService.ts
│
├── store/               # Zustand State Management
│   ├── authStore.ts
│   └── planungPhaseStore.ts
│
├── types/               # TypeScript Interfaces
│   ├── semester.types.ts
│   ├── planung.types.ts
│   └── user.types.ts
│
└── pages/               # Haupt-Seiten
    ├── Dashboard.tsx
    ├── Planning.tsx
    └── Login.tsx
```

### 5.2 State Management

#### Auth Store (Zustand)
```typescript
interface AuthStore {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  login: (username: string, password: string) => Promise<void>;
  logout: () => void;
}
```

**Verwendung:**
```typescript
const { user, isAuthenticated, login } = useAuthStore();

if (!isAuthenticated) {
  await login('dozent', 'password');
}
```

### 5.3 Komponenten-Kommunikation

```
Dashboard.tsx
    │
    ├──▶ SemesterManagement.tsx
    │        │
    │        └──▶ semesterService.getAutoSuggestion()
    │        └──▶ semesterService.activateSemester(id)
    │
    └──▶ NichtZugeordneteModule.tsx
             │
             └──▶ dashboardService.getNichtZugeordneteModule()
```

---

## 6. Sicherheit

### 6.1 Authentication & Authorization

#### JWT Tokens
```
Ablauf:
1. User Login → Server generiert JWT
2. Client speichert Token in Memory (Zustand Store)
3. Jede API-Request → Authorization Header: Bearer {token}
4. Server validiert Token → Extrahiert User-ID
5. Service-Layer prüft Permissions
```

#### Token-Lifetime
- Access Token: 1 Stunde
- Refresh Token: 7 Tage
- Auto-Refresh: 5 Minuten vor Ablauf

### 6.2 Authorization Levels

| Rolle | Berechtigungen |
|-------|---------------|
| **Dekan** | - Alle Semester verwalten<br>- Alle Planungen sehen<br>- Planungen freigeben/ablehnen<br>- Planungsphasen steuern |
| **Dozent** | - Eigene Planungen erstellen<br>- Eigene Planungen bearbeiten (nur entwurf)<br>- Eigene Planungen einreichen |
| **Admin** | - Alle Dekan-Rechte<br>- User-Verwaltung<br>- System-Konfiguration |

### 6.3 Sicherheits-Maßnahmen

#### Backend
```python
# Cross-User-Protection
def get_planung(planung_id):
    planung = Planung.query.get(planung_id)

    # Prüfe Ownership
    if planung.benutzer_id != current_user.id:
        abort(403, "Keine Berechtigung")

    return planung
```

#### Frontend
```typescript
// API Interceptor
axios.interceptors.response.use(
  response => response,
  error => {
    if (error.response.status === 401) {
      // Token abgelaufen → Logout
      authStore.logout();
      navigate('/login');
    }
    return Promise.reject(error);
  }
);
```

### 6.4 OWASP Top 10 Schutz

| Bedrohung | Maßnahme |
|-----------|----------|
| SQL Injection | ✅ SQLAlchemy ORM (Parameterisierte Queries) |
| XSS | ✅ React (Auto-Escaping), CSP Headers |
| CSRF | ✅ SameSite Cookies, CORS-Policy |
| Broken Auth | ✅ JWT, Password Hashing (bcrypt) |
| Sensitive Data | ✅ HTTPS, Keine Passwörter in Logs |

---

## 7. Deployment

### 7.1 Development

```bash
# Backend
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
python run.py

# Frontend
cd digitales-dekanat-frontend/root_files
npm install
npm run dev
```

### 7.2 Production (Docker)

```dockerfile
# Dockerfile (Backend)
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "run:app"]
```

```dockerfile
# Dockerfile (Frontend)
FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
```

```yaml
# docker-compose.yml
version: '3.8'

services:
  db:
    image: postgres:15
    environment:
      POSTGRES_DB: digidekan
      POSTGRES_USER: digidekan
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data

  backend:
    build: ./backend
    ports:
      - "5000:5000"
    environment:
      DATABASE_URL: postgresql://digidekan:${DB_PASSWORD}@db:5432/digidekan
      JWT_SECRET_KEY: ${JWT_SECRET}
    depends_on:
      - db

  frontend:
    build: ./digitales-dekanat-frontend/root_files
    ports:
      - "80:80"
    depends_on:
      - backend

volumes:
  postgres_data:
```

**Deployment:**
```bash
# Setze Umgebungsvariablen
export DB_PASSWORD="secure_password"
export JWT_SECRET="random_secret_key"

# Starte
docker-compose up -d

# Logs
docker-compose logs -f backend
```

---

## 8. Wartung & Monitoring

### 8.1 Logging

#### Backend
```python
# Logging konfiguriert in app/__init__.py
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(name)s: %(message)s'
)

# Verwendung
app.logger.info('[Semester] Activated: WS2025')
app.logger.error('[Planung] Failed to create: User 5, Semester 2')
```

#### Wichtige Log-Events
- User Login/Logout
- Semester-Aktivierung
- Planung Status-Änderungen (eingereicht, freigegeben)
- API-Errors (4xx, 5xx)

### 8.2 Monitoring

#### Metriken
```
- Anzahl aktive User
- Requests/Second
- Durchschnittliche Response-Zeit
- Error-Rate (4xx, 5xx)
- DB Connection Pool Status
```

#### Health-Check Endpoint
```http
GET /api/health

Response:
{
  "status": "healthy",
  "database": "connected",
  "version": "1.0.0",
  "uptime": "5d 12h 30m"
}
```

### 8.3 Backup-Strategie

```bash
# Tägliches DB-Backup
#!/bin/bash
BACKUP_DIR="/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
FILENAME="digidekan_${TIMESTAMP}.sql"

pg_dump -U digidekan digidekan > "${BACKUP_DIR}/${FILENAME}"
gzip "${BACKUP_DIR}/${FILENAME}"

# Lösche Backups älter als 30 Tage
find ${BACKUP_DIR} -name "*.sql.gz" -mtime +30 -delete
```

**Cron:**
```cron
# Täglich um 2 Uhr
0 2 * * * /opt/scripts/backup.sh
```

---

## 9. Troubleshooting

### 9.1 Häufige Probleme

#### Problem: "403 Forbidden" beim API-Call
```
Ursache: JWT Token fehlt oder ungültig
Lösung:
  1. Prüfe Token in Browser DevTools → Application → Session Storage
  2. Logout → Neu einloggen
  3. Prüfe Server-Logs auf Token-Validation Errors
```

#### Problem: "Semester nicht gefunden"
```
Ursache: Keine Semester in DB
Lösung:
  1. Python: from app import create_app; app = create_app()
  2. with app.app_context():
  3.     from app.models import Semester
  4.     Semester.query.all()  # Prüfe ob Semester vorhanden
  5. Falls leer: Erstelle Semester via Admin-UI
```

#### Problem: Frontend zeigt "Network Error"
```
Ursache: Backend nicht erreichbar
Lösung:
  1. Prüfe Backend läuft: curl http://localhost:5000/api/health
  2. Prüfe CORS-Config in backend/app/__init__.py
  3. Prüfe Frontend API_BASE_URL in .env
```

---

## 10. Glossar

| Begriff | Bedeutung |
|---------|-----------|
| **Semester** | Zeitraum (z.B. WS2025: Okt 2025 - März 2026) |
| **Planungsphase** | Zeitfenster für Professoren zum Einreichen |
| **Semesterplanung** | Sammlung von Modulen die ein Prof lehrt |
| **Modul** | Lehrveranstaltung (z.B. "Grundlagen des Managements") |
| **Turnus** | Rhythmus (Wintersemester, Sommersemester, Jedes Semester) |
| **PO** | Prüfungsordnung (z.B. PO2023) |
| **SWS** | Semesterwochenstunden |
| **JWT** | JSON Web Token (für Authentication) |

---

## 📞 Support

**Dokumentation:** [Link zur internen Doku]
**Issues:** [GitHub Issues]
**E-Mail:** support@hochschule.de
**Hotline:** +49 XXX XXXXXXX

---

**Letzte Aktualisierung:** 2025-12-04
**Nächste Review:** 2026-01-04

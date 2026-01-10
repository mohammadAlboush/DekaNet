# DigiDekan - Digitales Dekanat

Vollständiges Full-Stack-System zur Verwaltung von Lehrplanung, Deputatsabrechnung und Modulverwaltung für Hochschul-Dekanate.

## Autor

**Mohammad Alboush**
- Email: mohammadalboush8@gmail.com
- GitHub: [@mohammadAlboush](https://github.com/mohammadAlboush)

## Technologie-Stack

### Frontend
- **React 18** mit TypeScript
- **Material-UI (MUI)** - Moderne UI-Komponenten
- **Vite** - Schneller Build-Tool und Dev-Server
- **Zustand** - State Management
- **React Router 6** - Routing
- **React Hook Form** - Formularvalidierung
- **Axios** - HTTP-Client

### Backend
- **Python 3.10+** mit Flask
- **SQLAlchemy** - ORM für Datenbankzugriff
- **Flask-CORS** - Cross-Origin Resource Sharing
- **Flask-Login** - Authentifizierung
- **Alembic** - Datenbank-Migrationen
- **Gunicorn** - WSGI-Server für Produktion

## Projektstruktur

```
DigiDekan/
├── backend/                  # Python Flask Backend
│   ├── app/
│   │   ├── api/             # API Endpoints
│   │   ├── models/          # Datenbank-Modelle
│   │   ├── services/        # Business Logic
│   │   ├── auth/            # Authentifizierung
│   │   └── utils/           # Hilfsfunktionen
│   ├── migrations/          # Alembic Migrationen
│   ├── tests/               # Unit- und Integrationstests
│   └── requirements.txt     # Python-Abhängigkeiten
├── digitales-dekanat-frontend/  # React Frontend
│   └── root_files/
│       ├── src/
│       │   ├── components/  # React-Komponenten
│       │   ├── pages/       # Seiten-Komponenten
│       │   ├── services/    # API-Services
│       │   ├── store/       # Zustand-Stores
│       │   └── types/       # TypeScript-Typdefinitionen
│       └── package.json
├── docker/                  # Docker-Konfiguration
└── scripts/                 # Hilfsskripte
```

## Installation

### Voraussetzungen
- **Node.js** 18+ und npm
- **Python** 3.10+
- **Git**

### Backend-Installation

```bash
# In das Backend-Verzeichnis wechseln
cd backend

# Virtuelle Umgebung erstellen
python -m venv venv

# Virtuelle Umgebung aktivieren
# Windows:
venv\Scripts\activate
# Linux/macOS:
source venv/bin/activate

# Abhängigkeiten installieren
pip install -r requirements.txt

# Datenbank initialisieren
flask db upgrade

# Entwicklungsserver starten
python run.py
```

Der Backend-Server läuft auf `http://localhost:5000`

### Frontend-Installation

```bash
# In das Frontend-Verzeichnis wechseln
cd digitales-dekanat-frontend/root_files

# Abhängigkeiten installieren
npm install

# Entwicklungsserver starten
npm run dev
```

Der Frontend-Server läuft auf `http://localhost:5173`

## Features

### Lehrplanung
- **Wizard-basierte Semesterplanung** - Schrittweise Erfassung aller Planungsdaten
- **Modulverwaltung** - Verwaltung von Modulen, Lehrformen und SWS
- **Dozentenzuordnung** - Zuweisung von Dozenten zu Modulen
- **Planungsphasen** - Mehrere Planungsphasen pro Semester mit Historie

### Deputatsabrechnung
- **Automatische Berechnung** - SWS-basierte Deputatsberechnung
- **Multiplikatoren** - Flexible Faktoren für verschiedene Lehrformen
- **PDF-Export** - Generierung von Deputatsabrechnungen als PDF
- **Template-System** - Wiederverwendbare Planungsvorlagen

### Verwaltung
- **Wunsch-Freie-Tage** - Erfassung von Verfügbarkeiten der Dozenten
- **Auftragsverwaltung** - Verwaltung von Lehraufträgen und Zusatzaufgaben
- **Dashboard** - Übersicht über Planungsfortschritt und Statistiken
- **Audit-Log** - Nachvollziehbarkeit aller Änderungen

### Benutzerrollen
- **Dekan** - Vollzugriff auf alle Funktionen
- **Professor** - Eigene Planung und Deputat einsehen
- **Verwaltung** - Administrative Aufgaben

## Entwicklung

### Backend-Tests ausführen

```bash
cd backend
pytest
```

### Frontend-Tests ausführen

```bash
cd digitales-dekanat-frontend/root_files
npm run test
```

### TypeScript-Typ-Überprüfung

```bash
npm run type-check
```

### Linting

```bash
npm run lint
```

## Produktions-Deployment

### Mit Docker

```bash
cd docker
docker-compose -f docker-compose.production.yml up -d
```

### Manuell

#### Backend
```bash
cd backend
gunicorn -c gunicorn.conf.py run:app
```

#### Frontend
```bash
cd digitales-dekanat-frontend/root_files
npm run build
# Statische Dateien aus dist/ mit Nginx oder anderem Webserver bereitstellen
```

## Umgebungsvariablen

### Backend (.env)
```
FLASK_ENV=production
SECRET_KEY=<your-secret-key>
DATABASE_URL=sqlite:///dekanat.db
CORS_ORIGINS=https://your-domain.com
```

### Frontend (.env.production)
```
VITE_API_URL=https://api.your-domain.com
```

## Lizenz

MIT License - siehe [LICENSE](LICENSE)-Datei

## Copyright

© 2024-2026 Mohammad Alboush. Alle Rechte vorbehalten.

## Beiträge

Beiträge zum Projekt sind willkommen! Bitte erstellen Sie einen Pull Request oder öffnen Sie ein Issue.

## Support

Bei Fragen oder Problemen kontaktieren Sie bitte:
- Email: mohammadalboush8@gmail.com
- GitHub Issues: https://github.com/mohammadAlboush/DekaNet/issues

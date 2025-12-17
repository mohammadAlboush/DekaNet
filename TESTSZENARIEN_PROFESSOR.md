# Test-Szenarien: Professor Perspektive
**Zielgruppe:** QA-Team, Entwickler, Akzeptanz-Tests
**Datum:** 2025-12-04
**System:** DigiDekan Semesterplanungs-System

---

## 📋 Übersicht Test-Szenarien

| Nr | Szenario | Priorität | Status | Geschätzter Aufwand |
|----|----------|-----------|--------|---------------------|
| 1 | Erste Planung erstellen (Happy Path) | ⭐⭐⭐ | ⏳ Bereit | 10 Min |
| 2 | Planung bearbeiten und einreichen | ⭐⭐⭐ | ⏳ Bereit | 10 Min |
| 3 | Keine Planungsphase aktiv | ⭐⭐ | ⏳ Bereit | 5 Min |
| 4 | Gesperrte Planung bearbeiten | ⭐⭐ | ⏳ Bereit | 5 Min |
| 5 | Modul-Filter Wintersemester | ⭐⭐⭐ | ⏳ Bereit | 7 Min |
| 6 | Mehrere Planungen gleichzeitig | ⭐ | ⏳ Bereit | 10 Min |
| 7 | Planung nach Ablehnung überarbeiten | ⭐⭐ | ⏳ Bereit | 8 Min |
| 8 | Cross-User-Zugriff verhindern | ⭐⭐⭐ | ⏳ Bereit | 5 Min |

---

## 🧪 Test-Szenario 1: Erste Planung erstellen (Happy Path)

### Ziel
Professor erstellt seine erste Semesterplanung für ein aktives Semester.

### Vorbedingungen
- ✅ Benutzer: `dozent` (Passwort: `dozent123`)
- ✅ Semester: WS2025 ist aktiv
- ✅ Planungsphase: Offen
- ✅ Module: Mindestens 5 Module für WS verfügbar

### Test-Schritte

#### Schritt 1: Login
```
1. Öffne http://localhost:3001
2. Klicke "Anmelden"
3. Username: dozent
4. Passwort: dozent123
5. Klicke "Anmelden"
```

**Erwartetes Ergebnis:**
- ✅ Redirect zu Dashboard
- ✅ Anzeige "Willkommen zurück, Max!" (oder Username)
- ✅ Navigation zeigt "Dashboard", "Planung", "Aufträge"

#### Schritt 2: Planungs-Wizard starten
```
1. Klicke auf "Planung" in Navigation
   ODER
2. Klicke "Neue Planung" Button im Dashboard
```

**Erwartetes Ergebnis:**
- ✅ Wizard öffnet sich
- ✅ Step 1: "Semester auswählen" angezeigt
- ✅ Stepper zeigt: Semester (aktiv) → Module → Review

#### Schritt 3: Semester wählen
```
1. Prüfe: Liste zeigt "Wintersemester 2025/2026 (WS2025)"
2. Prüfe: Card zeigt:
   - Bezeichnung
   - Kürzel (WS2025)
   - Zeitraum (01.10.2025 - 31.03.2026)
   - Badge "Aktiv"
   - Badge "Planungsphase offen"
3. Semester ist bereits automatisch ausgewählt (Haken ✓)
4. Prüfe: Alert unten zeigt "✅ Planung erstellt • ID: X • Status: entwurf"
5. Klicke "Weiter"
```

**Erwartetes Ergebnis:**
- ✅ Backend erstellt Semesterplanung automatisch
- ✅ Response enthält `planung_id`
- ✅ Alert zeigt Erfolgs-Meldung
- ✅ "Weiter" Button ist enabled
- ✅ Wechsel zu Step 2: Module hinzufügen

#### Schritt 4: Module hinzufügen
```
1. Prüfe: Modul-Liste wird angezeigt
2. Prüfe: Filter zeigt nur Module mit Turnus:
   - "Wintersemester"
   - "Jedes Semester"
   - NICHT: "Sommersemester"
3. Wähle 3 Module aus (z.B. GDM, AID, BKV)
4. Für jedes Modul:
   - Anzahl Vorlesungen: 2
   - Anzahl Übungen: 1
5. Klicke "Weiter"
```

**Erwartetes Ergebnis:**
- ✅ Module werden gefiltert nach Semester-Typ
- ✅ Anzahl-Felder sind editierbar
- ✅ SWS wird live berechnet
- ✅ "Weiter" Button nur enabled wenn mindestens 1 Modul
- ✅ Wechsel zu Step 3: Review

#### Schritt 5: Review & Einreichen
```
1. Prüfe: Zusammenfassung zeigt:
   - Semester: Wintersemester 2025/2026
   - 3 Module
   - Gesamt-SWS: [Berechnet]
   - Status: Entwurf
2. Prüfe: Tabelle zeigt alle Module mit Details
3. Klicke "Als Entwurf speichern"
   ODER
4. Klicke "Einreichen zur Freigabe"
```

**Erwartetes Ergebnis (Entwurf):**
- ✅ Status bleibt "entwurf"
- ✅ Toast: "Planung gespeichert"
- ✅ Planung ist weiter bearbeitbar

**Erwartetes Ergebnis (Einreichen):**
- ✅ Status wechselt zu "eingereicht"
- ✅ Toast: "Planung eingereicht"
- ✅ Redirect zu Dashboard
- ✅ Planung ist NICHT mehr bearbeitbar

### Akzeptanzkriterien
- [ ] Alle Schritte durchlaufen ohne Fehler
- [ ] Planung in DB gespeichert
- [ ] Status korrekt (entwurf oder eingereicht)
- [ ] Module korrekt zugeordnet
- [ ] SWS korrekt berechnet
- [ ] User-Zuordnung korrekt

---

## 🧪 Test-Szenario 2: Planung bearbeiten

### Ziel
Professor bearbeitet eine bestehende Entwurfs-Planung.

### Vorbedingungen
- ✅ Szenario 1 durchgeführt (Planung im Status "entwurf" vorhanden)
- ✅ Login als selber User

### Test-Schritte

#### Schritt 1: Dashboard öffnen
```
1. Navigiere zu Dashboard
2. Prüfe: Card zeigt "Meine Planungen: 1"
3. Klicke auf Card ODER "Zu Planungen"
```

**Erwartetes Ergebnis:**
- ✅ Liste zeigt Planung
- ✅ Status: "Entwurf"
- ✅ Bearbeiten-Button ist sichtbar

#### Schritt 2: Planung öffnen
```
1. Klicke "Bearbeiten" neben der Planung
```

**Erwartetes Ergebnis:**
- ✅ Wizard öffnet sich
- ✅ Semester ist bereits gewählt (disabled)
- ✅ Button zeigt "Weiter" (nicht "Semester wählen")

#### Schritt 3: Module bearbeiten
```
1. Klicke "Weiter" (Skip Semester-Auswahl)
2. Step 2: Module werden geladen
3. Prüfe: Bereits gewählte Module sind vorausgewählt
4. Füge 1 weiteres Modul hinzu
5. Ändere Anzahl Vorlesungen bei einem Modul
6. Klicke "Weiter"
```

**Erwartetes Ergebnis:**
- ✅ Existierende Module werden geladen
- ✅ Neue Module hinzufügbar
- ✅ Änderungen werden übernommen
- ✅ SWS wird neu berechnet

#### Schritt 4: Speichern
```
1. Review zeigt aktualisierte Daten
2. Klicke "Als Entwurf speichern"
```

**Erwartetes Ergebnis:**
- ✅ Änderungen gespeichert
- ✅ Status bleibt "entwurf"
- ✅ Toast: "Planung aktualisiert"

### Akzeptanzkriterien
- [ ] Bestehende Planung lädt korrekt
- [ ] Änderungen werden gespeichert
- [ ] Keine Duplikate entstehen
- [ ] SWS neu berechnet

---

## 🧪 Test-Szenario 3: Keine Planungsphase aktiv

### Ziel
System verhindert Planung wenn Planungsphase geschlossen ist.

### Vorbedingungen
- ✅ Dekan schließt Planungsphase
- ✅ Login als Professor

### Test-Schritte

#### Schritt 1: Planungs-Wizard starten
```
1. Login als dozent
2. Navigiere zu "Planung"
3. Versuche "Neue Planung" zu erstellen
```

**Erwartetes Ergebnis:**
- ⚠️ Alert: "Keine Planungsphase aktiv"
- ⚠️ Message: "Derzeit ist keine Planungsphase geöffnet..."
- ⚠️ Wizard zeigt keine Semester-Auswahl
- ⚠️ Dashboard zeigt Warnung

#### Schritt 2: Bestehende Planung öffnen
```
1. Versuche bestehende Entwurfs-Planung zu bearbeiten
```

**Erwartetes Ergebnis (Option A - Strikt):**
- ⚠️ Bearbeitung nicht möglich
- ⚠️ Alert: "Planungsphase geschlossen"

**Erwartetes Ergebnis (Option B - Flexibel):**
- ✅ Entwürfe können weiter bearbeitet werden
- ⚠️ Einreichen ist deaktiviert

### Akzeptanzkriterien
- [ ] Keine neuen Planungen wenn Phase geschlossen
- [ ] Klare Fehlermeldungen
- [ ] Dashboard zeigt Status

---

## 🧪 Test-Szenario 4: Gesperrte Planung bearbeiten

### Ziel
System verhindert Bearbeitung von eingereichten/freigegebenen Planungen.

### Vorbedingungen
- ✅ Planung im Status "eingereicht" ODER "freigegeben"

### Test-Schritte

#### Schritt 1: Eingereichte Planung öffnen
```
1. Dashboard → Planungen
2. Planung hat Status "Eingereicht" (🔒 Icon)
3. Klicke "Bearbeiten"
```

**Erwartetes Ergebnis:**
- ⚠️ Alert: "Planung ist gesperrt"
- ⚠️ Message: "Status 'eingereicht' kann nicht bearbeitet werden"
- ⚠️ Wizard öffnet im Read-Only Modus
- ⚠️ ODER: Wizard öffnet gar nicht

#### Schritt 2: Freigegebene Planung öffnen
```
1. Planung hat Status "Freigegeben" (✅ Icon)
2. Klicke "Ansehen"
```

**Erwartetes Ergebnis:**
- ✅ Wizard öffnet im Read-Only Modus
- ✅ Alle Buttons deaktiviert außer "Schließen"
- ✅ Module sind anzeigbar aber nicht editierbar

### Akzeptanzkriterien
- [ ] Eingereichte Planungen sind gesperrt
- [ ] Freigegebene Planungen sind gesperrt
- [ ] Read-Only Modus funktioniert
- [ ] Klare Rückmeldung an User

---

## 🧪 Test-Szenario 5: Modul-Filter Semester-spezifisch

### Ziel
Module werden korrekt nach Semester-Turnus gefiltert.

### Vorbedingungen
- ✅ Module mit unterschiedlichen Turnus vorhanden:
  - Wintersemester
  - Sommersemester
  - Jedes Semester

### Test-Schritte

#### Test A: Wintersemester-Planung
```
1. Erstelle Planung für Wintersemester
2. Step 2: Module hinzufügen
3. Prüfe Modul-Liste
```

**Erwartetes Ergebnis:**
- ✅ Zeigt Module mit Turnus "Wintersemester"
- ✅ Zeigt Module mit Turnus "Jedes Semester"
- ❌ Zeigt KEINE Module mit Turnus "Sommersemester"

#### Test B: Sommersemester-Planung
```
1. Dekan aktiviert Sommersemester
2. Erstelle Planung für Sommersemester
3. Step 2: Module hinzufügen
4. Prüfe Modul-Liste
```

**Erwartetes Ergebnis:**
- ✅ Zeigt Module mit Turnus "Sommersemester"
- ✅ Zeigt Module mit Turnus "Jedes Semester"
- ❌ Zeigt KEINE Module mit Turnus "Wintersemester"

### Akzeptanzkriterien
- [ ] Filter funktioniert für Wintersemester
- [ ] Filter funktioniert für Sommersemester
- [ ] "Jedes Semester" erscheint immer
- [ ] Keine falschen Module sichtbar

---

## 🧪 Test-Szenario 6: Mehrere Planungen gleichzeitig

### Ziel
Prüfe ob Professor mehrere Planungen für verschiedene Semester erstellen kann.

### Vorbedingungen
- ✅ Mehrere Semester in DB
- ✅ Verschiedene POs verfügbar (für zukünftige Tests)

### Test-Schritte

#### Schritt 1: Erste Planung (WS2025)
```
1. Erstelle Planung für WS2025
2. Füge Module hinzu
3. Speichere als Entwurf
```

#### Schritt 2: Zweite Planung (SS2026) - Falls verfügbar
```
1. Dekan aktiviert SS2026
2. Öffne neuen Planungs-Wizard
3. Wähle SS2026
4. Füge andere Module hinzu
5. Speichere als Entwurf
```

**Erwartetes Ergebnis:**
- ✅ Beide Planungen existieren parallel
- ✅ Separate IDs
- ✅ Getrennte Module
- ✅ Dashboard zeigt "Meine Planungen: 2"

### Akzeptanzkriterien
- [ ] Mehrere Planungen möglich
- [ ] Keine Vermischung der Daten
- [ ] Korrekte Zuordnung pro Semester

---

## 🧪 Test-Szenario 7: Planung nach Ablehnung überarbeiten

### Ziel
Professor kann abgelehnte Planung überarbeiten und erneut einreichen.

### Vorbedingungen
- ✅ Planung im Status "abgelehnt"
- ✅ Ablehnungsgrund vom Dekan hinterlegt

### Test-Schritte

#### Schritt 1: Abgelehnte Planung ansehen
```
1. Dashboard → Planungen
2. Planung zeigt Status "Abgelehnt" (❌ Icon)
3. Prüfe: Ablehnungsgrund wird angezeigt
4. Klicke "Überarbeiten"
```

**Erwartetes Ergebnis:**
- ✅ Alert zeigt Ablehnungsgrund prominent
- ✅ Wizard öffnet im Edit-Modus
- ✅ Status wechselt zurück zu "entwurf"

#### Schritt 2: Änderungen vornehmen
```
1. Bearbeite Module gemäß Feedback
2. Klicke "Einreichen zur Freigabe"
```

**Erwartetes Ergebnis:**
- ✅ Status: abgelehnt → entwurf → eingereicht
- ✅ Neue Version erstellt (Historie?)
- ✅ Dekan sieht neue Einreichung

### Akzeptanzkriterien
- [ ] Abgelehnte Planung bearbeitbar
- [ ] Ablehnungsgrund sichtbar
- [ ] Erneutes Einreichen möglich
- [ ] Status-Übergang korrekt

---

## 🧪 Test-Szenario 8: Cross-User-Zugriff verhindern

### Ziel
Professor A kann Planung von Professor B nicht sehen/bearbeiten.

### Vorbedingungen
- ✅ 2 Professor-Accounts:
  - dozent (ID: 2)
  - dozent2 (ID: 3)
- ✅ Planung von dozent vorhanden

### Test-Schritte

#### Schritt 1: User A erstellt Planung
```
1. Login als dozent
2. Erstelle Planung (ID: X)
3. Logout
```

#### Schritt 2: User B versucht Zugriff
```
1. Login als dozent2
2. Dashboard → Planungen
3. Prüfe: Liste ist leer ODER zeigt nur eigene
4. Versuche direkten API-Zugriff:
   GET /api/planung/X
```

**Erwartetes Ergebnis:**
- ✅ User B sieht keine Planung von User A
- ✅ API-Call: 403 Forbidden
- ✅ Message: "Keine Berechtigung"

#### Schritt 3: User B versucht zu bearbeiten
```
1. Manipuliere Frontend (Browser DevTools)
2. Versuche Wizard mit planung_id=X zu öffnen
```

**Erwartetes Ergebnis:**
- ⛔ Backend lehnt ab: 403 Forbidden
- ⛔ Planung wird NICHT geladen
- ⛔ Alert: "Planung gehört einem anderen User"

### Akzeptanzkriterien
- [ ] Strikte User-Isolation
- [ ] Keine Cross-User-Sichtbarkeit
- [ ] API schützt vor unbefugtem Zugriff
- [ ] Frontend zeigt Fehler korrekt

---

## 📊 Test-Zusammenfassung

### Kritische Pfade (MUSS funktionieren)
- ✅ Szenario 1: Erste Planung erstellen
- ✅ Szenario 4: Gesperrte Planung
- ✅ Szenario 5: Modul-Filter
- ✅ Szenario 8: Cross-User-Schutz

### Wichtige Pfade (SOLLTE funktionieren)
- ✅ Szenario 2: Planung bearbeiten
- ✅ Szenario 3: Keine Planungsphase
- ✅ Szenario 7: Nach Ablehnung überarbeiten

### Nice-to-have (KANN funktionieren)
- ✅ Szenario 6: Mehrere Planungen

---

## 🛠️ Test-Ausführung

### Manuelle Tests
```bash
# 1. Starte Backend
cd backend
python run.py

# 2. Starte Frontend
cd digitales-dekanat-frontend/root_files
npm run dev

# 3. Öffne Browser
http://localhost:3001
```

### Automatisierte Tests (TODO)
```bash
# E2E Tests mit Playwright
npm run test:e2e

# Smoke Tests
npm run test:smoke
```

---

## 📝 Test-Protokoll Vorlage

```
Test-Szenario: [Nr + Name]
Tester: [Name]
Datum: [YYYY-MM-DD]
Browser: [Chrome/Firefox/Safari]
Umgebung: [Development/Staging/Production]

Schritt | Erwartet | Erhalten | Status | Bemerkung
--------|----------|----------|--------|----------
1.1     | ...      | ...      | ✅/❌  | ...
1.2     | ...      | ...      | ✅/❌  | ...

Gesamt-Status: ✅ BESTANDEN / ❌ FEHLGESCHLAGEN
Kritische Fehler: [Anzahl]
Nicht-kritische Fehler: [Anzahl]

Anmerkungen:
- ...
- ...
```

---

## 🎯 Nächste Schritte

1. [ ] Testszenarien durchführen
2. [ ] Fehler dokumentieren
3. [ ] Fixes implementieren
4. [ ] Re-Test
5. [ ] Akzeptanz-Freigabe

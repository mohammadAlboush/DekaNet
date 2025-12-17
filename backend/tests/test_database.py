"""
Test-Skript für Datenbankverbindung
====================================
Überprüft die Verbindung zur SQLite-Datenbank und zeigt wichtige Informationen an.
"""

import sqlite3
import os
from pathlib import Path

# Dein Datenbankpfad
DB_PATH = r"C:\Users\moham\OneDrive\Desktop\DigiDekan\dekanat_new.db"

def test_database_connection():
    """Testet die Datenbankverbindung und zeigt Informationen an"""
    
    print("=" * 60)
    print("🔍 DATENBANK-VERBINDUNGSTEST")
    print("=" * 60)
    
    # 1. Überprüfe ob Datei existiert
    print(f"\n1️⃣ Überprüfe Datenbankdatei...")
    if os.path.exists(DB_PATH):
        print(f"   ✅ Datenbank gefunden: {DB_PATH}")
        file_size = os.path.getsize(DB_PATH) / 1024  # KB
        print(f"   📦 Dateigröße: {file_size:.2f} KB")
    else:
        print(f"   ❌ Datenbank NICHT gefunden: {DB_PATH}")
        return False
    
    # 2. Versuche Verbindung herzustellen
    print(f"\n2️⃣ Versuche Verbindung herzustellen...")
    try:
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        print(f"   ✅ Verbindung erfolgreich!")
        
        # 3. Zeige alle Tabellen
        print(f"\n3️⃣ Vorhandene Tabellen:")
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;")
        tables = cursor.fetchall()
        
        if tables:
            for i, table in enumerate(tables, 1):
                table_name = table[0]
                
                # Zähle Einträge pro Tabelle
                cursor.execute(f"SELECT COUNT(*) FROM {table_name}")
                count = cursor.fetchone()[0]
                
                print(f"   {i}. {table_name:30} → {count:5} Einträge")
        else:
            print("   ⚠️  Keine Tabellen gefunden!")
        
        # 4. Test-Query auf Benutzer-Tabelle (falls vorhanden)
        print(f"\n4️⃣ Test-Query auf wichtige Tabellen...")
        
        # Teste Benutzer-Tabelle
        try:
            cursor.execute("SELECT COUNT(*) FROM benutzer")
            user_count = cursor.fetchone()[0]
            print(f"   ✅ Benutzer-Tabelle: {user_count} Benutzer gefunden")
            
            if user_count > 0:
                cursor.execute("SELECT username, rolle_name FROM benutzer LIMIT 3")
                users = cursor.fetchall()
                print(f"\n   📋 Erste 3 Benutzer:")
                for username, rolle in users:
                    print(f"      - {username:20} (Rolle: {rolle})")
                    
        except sqlite3.Error as e:
            print(f"   ⚠️  Benutzer-Tabelle nicht verfügbar: {e}")
        
        # Teste Semester-Tabelle
        try:
            cursor.execute("SELECT COUNT(*) FROM semester")
            semester_count = cursor.fetchone()[0]
            print(f"\n   ✅ Semester-Tabelle: {semester_count} Semester gefunden")
            
            if semester_count > 0:
                cursor.execute("SELECT bezeichnung, kuerzel, ist_aktiv FROM semester LIMIT 3")
                semesters = cursor.fetchall()
                print(f"\n   📋 Erste 3 Semester:")
                for bez, kuerzel, aktiv in semesters:
                    status = "🟢 Aktiv" if aktiv else "⚪ Inaktiv"
                    print(f"      - {kuerzel:10} | {bez:30} | {status}")
                    
        except sqlite3.Error as e:
            print(f"   ⚠️  Semester-Tabelle nicht verfügbar: {e}")
        
        # 5. Schließe Verbindung
        conn.close()
        print(f"\n5️⃣ Verbindung geschlossen")
        print("\n" + "=" * 60)
        print("✅ DATENBANKTEST ERFOLGREICH!")
        print("=" * 60)
        return True
        
    except sqlite3.Error as e:
        print(f"   ❌ Fehler bei der Verbindung: {e}")
        print("\n" + "=" * 60)
        print("❌ DATENBANKTEST FEHLGESCHLAGEN!")
        print("=" * 60)
        return False

if __name__ == "__main__":
    test_database_connection()
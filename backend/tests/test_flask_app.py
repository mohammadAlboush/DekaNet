"""
Flask-App Test mit Datenbankverbindung
=======================================
Testet ob die Flask-App korrekt mit der Datenbank verbunden ist.
"""

import sys
import os

# Füge den Backend-Pfad zum Python-Path hinzu
# ANPASSEN: Passe diesen Pfad an deine Projektstruktur an
BACKEND_PATH = r"C:\Users\moham\OneDrive\Desktop\DigiDekan\backend"
if BACKEND_PATH not in sys.path:
    sys.path.insert(0, BACKEND_PATH)

def test_flask_app():
    """Testet die Flask-App Initialisierung"""
    
    print("=" * 60)
    print("🚀 FLASK-APP TEST MIT DATENBANK")
    print("=" * 60)
    
    try:
        # ⚠️ WICHTIG: Setze explizit auf Development-Mode
        os.environ['FLASK_ENV'] = 'development'
        
        # 1. Importiere Flask App
        print("\n1️⃣ Importiere Flask-App...")
        from app import create_app
        from app.extensions import db
        print("   ✅ Import erfolgreich!")
        
        # 2. Erstelle App-Instanz (explizit mit development config)
        print("\n2️⃣ Erstelle App-Instanz...")
        app = create_app('development')
        print("   ✅ App erstellt!")
        print(f"   🔧 Debug Mode: {app.config['DEBUG']}")
        print(f"   📊 Testing Mode: {app.config['TESTING']}")
        print(f"   🗄️  Database: {app.config['SQLALCHEMY_DATABASE_URI'][:50]}...")
        
        # 3. Teste Datenbankverbindung im App-Context
        print("\n3️⃣ Teste Datenbankverbindung...")
        with app.app_context():
            # Versuche eine einfache Query
            from app.models.user import Benutzer
            
            # Teste ob wir auf die Datenbank zugreifen können
            try:
                user_count = Benutzer.query.count()
                print(f"   ✅ Datenbankverbindung erfolgreich!")
                print(f"   📊 Gefundene Benutzer: {user_count}")
                
                # Zeige ersten Benutzer
                if user_count > 0:
                    first_user = Benutzer.query.first()
                    print(f"\n   👤 Erster Benutzer:")
                    print(f"      - Username: {first_user.username}")
                    print(f"      - Rolle: {first_user.rolle.name if first_user.rolle else 'Keine'}")
                    print(f"      - Email: {first_user.email}")
                    print(f"      - Name: {first_user.name_komplett}")
            
            except Exception as e:
                print(f"   ❌ Fehler bei Datenbankzugriff: {e}")
                return False
        
        # 4. Zeige verfügbare Routes
        print("\n4️⃣ Verfügbare API-Endpunkte:")
        with app.app_context():
            routes = []
            for rule in app.url_map.iter_rules():
                if rule.endpoint != 'static':
                    routes.append({
                        'endpoint': rule.endpoint,
                        'methods': ','.join(sorted(rule.methods - {'HEAD', 'OPTIONS'})),
                        'path': str(rule)
                    })
            
            # Gruppiere nach Prefix
            auth_routes = [r for r in routes if '/auth/' in r['path']]
            api_routes = [r for r in routes if '/api/' in r['path']]
            other_routes = [r for r in routes if r not in auth_routes and r not in api_routes]
            
            if auth_routes:
                print("\n   🔐 Authentication Endpoints:")
                for route in sorted(auth_routes, key=lambda x: x['path']):
                    print(f"      {route['methods']:20} {route['path']}")
            
            if api_routes:
                print("\n   🌐 API Endpoints:")
                for route in sorted(api_routes, key=lambda x: x['path']):
                    print(f"      {route['methods']:20} {route['path']}")
            
            if other_routes:
                print("\n   📄 Andere Endpoints:")
                for route in sorted(other_routes, key=lambda x: x['path']):
                    print(f"      {route['methods']:20} {route['path']}")
        
        print("\n" + "=" * 60)
        print("✅ FLASK-APP TEST ERFOLGREICH!")
        print("=" * 60)
        print("\n💡 Nächster Schritt: Starte die App mit 'python run.py'")
        return True
        
    except ImportError as e:
        print(f"\n   ❌ Import-Fehler: {e}")
        print("\n   💡 Stelle sicher, dass:")
        print("      1. Der BACKEND_PATH korrekt ist")
        print("      2. Die app/__init__.py existiert")
        print("      3. Alle Dependencies installiert sind")
        return False
    
    except Exception as e:
        print(f"\n   ❌ Unerwarteter Fehler: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    test_flask_app()
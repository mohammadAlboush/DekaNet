"""
Test Script für Nicht Zugeordnete Module API
=============================================
Testet den neuen Endpoint /api/dashboard/nicht-zugeordnete-module
"""

import sys
import io
# Fix Windows Console Encoding
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

import requests
import json

BASE_URL = "http://127.0.0.1:5000"

def test_nicht_zugeordnete_module():
    """Testet den nicht-zugeordnete-module Endpoint"""

    print("=" * 80)
    print("TEST: Nicht zugeordnete Module API")
    print("=" * 80)

    # 1. Login als Dekan
    print("\n[1] Login als Dekan...")
    login_response = requests.post(
        f"{BASE_URL}/api/auth/login",
        json={
            "username": "dekan",
            "password": "dekan123"
        }
    )

    if not login_response.ok:
        print(f"❌ Login fehlgeschlagen: {login_response.status_code}")
        print(login_response.text)
        return

    login_data = login_response.json()
    access_token = login_data.get("data", {}).get("access_token")

    if not access_token:
        print("❌ Kein Access Token erhalten")
        return

    print(f"✅ Login erfolgreich! Token: {access_token[:20]}...")

    # 2. Request zu nicht zugeordnete Module
    print("\n[2] Hole nicht zugeordnete Module...")
    headers = {
        "Authorization": f"Bearer {access_token}"
    }

    response = requests.get(
        f"{BASE_URL}/api/dashboard/nicht-zugeordnete-module",
        headers=headers
    )

    print(f"Status Code: {response.status_code}")

    if not response.ok:
        print(f"❌ Request fehlgeschlagen: {response.status_code}")
        print(response.text)
        return

    data = response.json()

    if not data.get("success"):
        print(f"❌ API returned success=false")
        print(json.dumps(data, indent=2, ensure_ascii=False))
        return

    result = data.get("data", {})

    print("\n" + "=" * 80)
    print("ERGEBNIS")
    print("=" * 80)

    # Semester Info
    semester = result.get("semester", {})
    print(f"\n📅 Semester: {semester.get('bezeichnung')} ({semester.get('kuerzel')})")
    print(f"   Wintersemester: {semester.get('ist_wintersemester')}")
    print(f"   Sommersemester: {semester.get('ist_sommersemester')}")

    # Planungsphase
    planungsphase_aktiv = result.get("planungsphase_aktiv")
    print(f"\n🔄 Planungsphase aktiv: {planungsphase_aktiv}")

    if planungsphase_aktiv:
        phase = result.get("planungsphase", {})
        print(f"   Phase: {phase.get('name')}")
        print(f"   ID: {phase.get('id')}")

    # Relevante Turnus
    relevante_turnus = result.get("relevante_turnus", [])
    print(f"\n📚 Relevante Turnus: {', '.join(relevante_turnus) if relevante_turnus else 'Alle'}")

    # Statistiken
    statistik = result.get("statistik", {})
    print(f"\n📊 STATISTIKEN:")
    print(f"   Gesamt nicht zugeordnet: {statistik.get('gesamt')}")
    print(f"   Alle Module: {statistik.get('alle_module')}")
    print(f"   Geplante Module: {statistik.get('geplante_module')}")
    print(f"   Zuordnungsquote: {statistik.get('zuordnungsquote'):.2f}%")

    # Nach Turnus
    nach_turnus = statistik.get("nach_turnus", {})
    if nach_turnus:
        print(f"\n   Verteilung nach Turnus:")
        for turnus, anzahl in nach_turnus.items():
            print(f"      • {turnus}: {anzahl}")

    # Module
    module = result.get("nicht_zugeordnete_module", [])
    print(f"\n📋 NICHT ZUGEORDNETE MODULE ({len(module)}):")

    if module:
        print("\n   Top 10:")
        for i, modul in enumerate(module[:10], 1):
            print(f"   {i:2d}. {modul['kuerzel']:8s} - {modul['bezeichnung_de'][:50]:50s} ({modul['turnus']})")
            print(f"       LP: {modul['leistungspunkte']}, SWS: {modul['sws_gesamt']}")
    else:
        print("   ✅ Alle Module zugeordnet!")

    print("\n" + "=" * 80)
    print("✅ TEST ERFOLGREICH!")
    print("=" * 80)

if __name__ == "__main__":
    try:
        test_nicht_zugeordnete_module()
    except Exception as e:
        print(f"\n❌ FEHLER: {e}")
        import traceback
        traceback.print_exc()

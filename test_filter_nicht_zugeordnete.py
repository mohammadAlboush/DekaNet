"""
Test Script für Filter-Funktionalität - Nicht Zugeordnete Module
================================================================
Testet die verschiedenen Filter-Optionen:
- Aktuelles Semester
- Alle Semester
- Sommersemester
- Wintersemester
"""

import sys
import io
# Fix Windows Console Encoding
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

import requests
import json

BASE_URL = "http://127.0.0.1:5000"

def login():
    """Login als Dekan und hole Access Token"""
    print("\n[LOGIN] Einloggen als Dekan...")
    login_response = requests.post(
        f"{BASE_URL}/api/auth/login",
        json={
            "username": "dekan",
            "password": "dekan123"
        }
    )

    if not login_response.ok:
        print(f"❌ Login fehlgeschlagen: {login_response.status_code}")
        return None

    login_data = login_response.json()
    access_token = login_data.get("data", {}).get("access_token")

    if not access_token:
        print("❌ Kein Access Token erhalten")
        return None

    print(f"✅ Login erfolgreich!")
    return access_token


def get_all_semester(access_token):
    """Hole alle Semester"""
    headers = {"Authorization": f"Bearer {access_token}"}
    response = requests.get(f"{BASE_URL}/api/semester", headers=headers)

    if response.ok:
        data = response.json()
        return data.get("data", [])
    return []


def test_filter(access_token, filter_name, semester_id=None):
    """Testet einen spezifischen Filter"""
    print(f"\n{'='*80}")
    print(f"TEST: {filter_name}")
    print(f"{'='*80}")

    headers = {"Authorization": f"Bearer {access_token}"}
    params = {}

    if semester_id is not None:
        params["semester_id"] = semester_id
        print(f"   Parameter: semester_id={semester_id}")
    else:
        print(f"   Parameter: Kein semester_id (alle Module)")

    response = requests.get(
        f"{BASE_URL}/api/dashboard/nicht-zugeordnete-module",
        headers=headers,
        params=params
    )

    print(f"   Status Code: {response.status_code}")

    if not response.ok:
        print(f"   ❌ Request fehlgeschlagen")
        print(response.text[:500])
        return False

    data = response.json()
    if not data.get("success"):
        print(f"   ❌ API returned success=false")
        return False

    result = data.get("data", {})
    semester = result.get("semester", {})
    statistik = result.get("statistik", {})
    module = result.get("nicht_zugeordnete_module", [])

    print(f"\n   📅 Semester: {semester.get('bezeichnung')} ({semester.get('kuerzel')})")
    print(f"   🔄 Planungsphase aktiv: {result.get('planungsphase_aktiv')}")
    print(f"   📊 Nicht zugeordnet: {statistik.get('gesamt')}")
    print(f"   📊 Alle Module: {statistik.get('alle_module')}")
    print(f"   📊 Geplante Module: {statistik.get('geplante_module')}")
    print(f"   📊 Zuordnungsquote: {statistik.get('zuordnungsquote'):.2f}%")

    # Zeige Top 3 Module
    if module:
        print(f"\n   Top 3 Module:")
        for i, modul in enumerate(module[:3], 1):
            print(f"      {i}. {modul['kuerzel']} - {modul['bezeichnung_de'][:40]} ({modul['turnus']})")

    print(f"\n   ✅ Test erfolgreich!")
    return True


def main():
    print("="*80)
    print("TEST SUITE: Filter-Funktionalität für Nicht Zugeordnete Module")
    print("="*80)

    # 1. Login
    access_token = login()
    if not access_token:
        return

    # 2. Hole alle Semester
    print("\n[SEMESTER] Hole alle Semester...")
    alle_semester = get_all_semester(access_token)
    print(f"   Gefunden: {len(alle_semester)} Semester")

    if alle_semester:
        for sem in alle_semester:
            print(f"      - {sem['bezeichnung']} ({sem['kuerzel']}) - Aktiv: {sem.get('ist_aktiv')}")

    # Finde aktives Semester und verschiedene Semester-Typen
    aktives_semester = next((s for s in alle_semester if s.get('ist_aktiv')), None)
    sommer_semester = next((s for s in alle_semester if 'SS' in s['kuerzel'] or 'sommer' in s['bezeichnung'].lower()), None)
    winter_semester = next((s for s in alle_semester if 'WS' in s['kuerzel'] or 'winter' in s['bezeichnung'].lower()), None)

    # 3. Test 1: Aktuelles Semester (mit semester_id)
    if aktives_semester:
        test_filter(access_token, "Filter: Aktuelles Semester", aktives_semester['id'])
    else:
        print("\n⚠️  Kein aktives Semester gefunden, überspringe Test 1")

    # 4. Test 2: Alle Semester (ohne semester_id)
    test_filter(access_token, "Filter: Alle Semester", None)

    # 5. Test 3: Sommersemester
    if sommer_semester:
        test_filter(access_token, "Filter: Sommersemester", sommer_semester['id'])
    else:
        print("\n⚠️  Kein Sommersemester gefunden, überspringe Test 3")

    # 6. Test 4: Wintersemester
    if winter_semester:
        test_filter(access_token, "Filter: Wintersemester", winter_semester['id'])
    else:
        print("\n⚠️  Kein Wintersemester gefunden, überspringe Test 4")

    print("\n" + "="*80)
    print("✅ ALLE TESTS ABGESCHLOSSEN!")
    print("="*80)


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"\n❌ FEHLER: {e}")
        import traceback
        traceback.print_exc()

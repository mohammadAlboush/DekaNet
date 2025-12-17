"""Test Auto-Semester-Vorschlag"""
import sys
import io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

import requests
import json

BASE_URL = "http://127.0.0.1:5000"

# Login
print("[LOGIN] Einloggen als Dekan...")
login_response = requests.post(
    f"{BASE_URL}/api/auth/login",
    json={"username": "dekan", "password": "dekan123"}
)

if not login_response.ok:
    print(f"❌ Login fehlgeschlagen")
    exit(1)

access_token = login_response.json().get("data", {}).get("access_token")
print(f"✅ Login erfolgreich!\n")

# Test Auto-Vorschlag
headers = {"Authorization": f"Bearer {access_token}"}
response = requests.get(f"{BASE_URL}/api/semester/auto-vorschlag", headers=headers)

print("="*80)
print("AUTO-SEMESTER-VORSCHLAG")
print("="*80)

if response.ok:
    data = response.json()
    print(f"\nStatus: {response.status_code}")
    print(f"Message: {data.get('message')}\n")

    result = data.get("data", {})

    print(f"📅 Datum Heute: {result.get('datum_heute')}")
    print(f"✅ Ist korrekt: {result.get('ist_korrekt')}")
    print(f"💡 Empfehlung: {result.get('empfehlung')}\n")

    aktives = result.get('aktives')
    if aktives:
        print(f"🔵 Aktuell aktives Semester:")
        print(f"   {aktives['bezeichnung']} ({aktives['kuerzel']})")
        print(f"   Planungsphase: {aktives['ist_planungsphase']}\n")
    else:
        print("🔵 Kein aktives Semester\n")

    laufendes = result.get('laufendes')
    if laufendes:
        print(f"🟢 Heute laufendes Semester:")
        print(f"   {laufendes['bezeichnung']} ({laufendes['kuerzel']})")
        print(f"   Start: {laufendes['start_datum']}, Ende: {laufendes['ende_datum']}\n")
    else:
        print("🟢 Kein laufendes Semester\n")

    vorschlag = result.get('vorschlag')
    if vorschlag:
        print(f"⭐ Vorgeschlagenes Semester:")
        print(f"   {vorschlag['bezeichnung']} ({vorschlag['kuerzel']})")
        print(f"   → Sollte aktiviert werden!\n")
    else:
        print("⭐ Kein Vorschlag (alles korrekt oder keine Semester vorhanden)\n")

    print("="*80)
    print("✅ TEST ERFOLGREICH")
    print("="*80)
else:
    print(f"❌ Request fehlgeschlagen: {response.status_code}")
    print(response.text)

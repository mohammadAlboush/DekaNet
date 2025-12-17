"""Test PO API"""
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

# Test PO Liste
headers = {"Authorization": f"Bearer {access_token}"}
response = requests.get(f"{BASE_URL}/api/pruefungsordnungen/", headers=headers)

print("="*80)
print("PRÜFUNGSORDNUNGEN API")
print("="*80)

if response.ok:
    data = response.json()
    print(f"\nStatus: {response.status_code}")
    print(f"Message: {data.get('message')}\n")

    pos = data.get("data", [])
    print(f"Anzahl POs: {len(pos)}\n")

    for po in pos:
        print(f"📚 PO ID: {po['id']}")
        print(f"   Jahr: {po.get('po_jahr')}")
        print(f"   Gültig von: {po.get('gueltig_von')}")
        print(f"   Gültig bis: {po.get('gueltig_bis')}")
        print(f"   Beschreibung: {po.get('beschreibung')}")
        print()

    print("="*80)
    print("✅ TEST ERFOLGREICH")
    print("="*80)
else:
    print(f"❌ Request fehlgeschlagen: {response.status_code}")
    print(response.text)

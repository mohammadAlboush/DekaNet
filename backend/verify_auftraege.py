"""Verify default aufträge were inserted"""
from app import create_app
from app.models.auftrag import Auftrag

app = create_app()

with app.app_context():
    auftraege = Auftrag.query.order_by(Auftrag.sortierung).all()

    print(f"\n=== AUFTRÄGE ({len(auftraege)} total) ===\n")

    for auftrag in auftraege:
        print(f"{auftrag.sortierung:2d}. {auftrag.name:35s} {auftrag.standard_sws:4.1f} SWS - {auftrag.beschreibung}")

    print(f"\nTotal: {len(auftraege)} aufträge successfully inserted")

"""Check current semester data"""
import sys
import io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

# Add backend to path
sys.path.insert(0, 'backend')

from app import create_app
from app.models import Semester

app = create_app()

with app.app_context():
    sems = Semester.query.all()
    print(f'\nAnzahl Semester: {len(sems)}\n')

    for s in sems:
        print(f'  - {s.kuerzel}: {s.bezeichnung}')
        print(f'    Aktiv: {s.ist_aktiv}')
        print(f'    Planungsphase: {s.ist_planungsphase}')
        print(f'    Start: {s.start_datum}, Ende: {s.ende_datum}')
        print(f'    Ist Wintersemester: {s.ist_wintersemester}')
        print(f'    Ist Sommersemester: {s.ist_sommersemester}')
        print(f'    Ist laufend: {s.ist_laufend}')
        print()

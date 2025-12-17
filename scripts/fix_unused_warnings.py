#!/usr/bin/env python3
"""
Script to automatically fix unused import and variable warnings in TypeScript files
"""

import re
import os
from pathlib import Path

# Mapping of files to their unused imports/variables
FIXES = {
    "src/components/dashboard/NichtZugeordneteModule.tsx": {
        "unused_imports": ["TrendingUp", "NichtZugeordnetesModul"],
        "unused_variables": ["setSelectedSemesterId"]
    },
    "src/components/dashboard/SemesterManagement.tsx": {
        "unused_imports": ["Grid", "Stop", "Warning", "TrendingUp"]
    },
    "src/components/dekan/AuftraegeWidget.tsx": {
        "unused_imports": ["Add", "Edit", "Delete"],
        "unused_variables": ["updateAuftrag"]
    },
    "src/components/planning/wizard/steps/StepSemesterAuswahl.tsx": {
        "unused_variables": ["allPOs"]
    },
    "src/components/planning/wizard/steps/StepWunschFreieTage.tsx": {
        "unused_imports": ["ToggleButton", "ToggleButtonGroup", "AccessTime"],
        "unused_variables": ["planungId", "selectedDays", "setSelectedDays", "quickSelect", "setQuickSelect", "isTagSelected"]
    },
    "src/components/planning/wizard/steps/StepZusammenfassung.tsx": {
        "unused_imports": ["Divider", "Person", "EventNote"]
    },
    "src/components/planning/wizard/steps/StepZusatzInfos.tsx": {
        "unused_imports": ["Card", "CardContent"]
    },
    "src/components/planning/ArchivedPlanungsList.tsx": {
        "unused_variables": ["setPage", "setRowsPerPage", "paginatedPlanungen"]
    },
    "src/components/planning/PhaseHistoryDialog.tsx": {
        "unused_imports": ["ExpandMore"],
        "unused_variables": ["selectedPhase", "setSelectedPhase"]
    },
    "src/components/planning/PlanungsphasenManager.tsx": {
        "unused_imports": ["Notifications", "Download", "Warning", "Schedule"],
        "unused_variables": ["differenceInDays", "differenceInHours", "user", "submissionStatus", "isPhaseActive", "canSubmit", "updatePhase"]
    },
    "src/components/planning/ProfessorPhasenHistorie.tsx": {
        "unused_imports": ["Card", "CardContent", "ListItemText", "ListItemIcon", "Assignment", "TrendingUp", "School"]
    },
    "src/pages/AuftraegeVerwaltung.tsx": {
        "unused_imports": ["UpdateAuftragData"]
    },
    "src/pages/Dashboard.tsx": {
        "unused_imports": ["TrendingUp"]
    },
    "src/pages/Dozenten.tsx": {
        "unused_imports": ["useMemo", "Divider", "School"],
        "unused_variables": ["e"]  # Line 543
    },
    "src/pages/Module.tsx": {
        "unused_imports": ["useMemo", "Group", "Book", "Assessment", "WorkOutline", "LibraryBooks"],
        "unused_variables": ["e"]  # Line 762
    },
    "src/pages/ModulVerwaltung.tsx": {
        "unused_imports": ["Card", "CardContent", "Dialog", "DialogTitle", "DialogContent", "DialogActions"]
    },
    "src/pages/ProfessorDashboard.tsx": {
        "unused_imports": ["CardActions", "School", "TrendingUp", "CalendarToday", "Send"]
    },
    "src/pages/Semesterplanung.tsx": {
        "unused_imports": ["Grid", "Dialog", "DialogTitle", "DialogContent", "DialogActions", "TextField", "Select", "MenuItem", "FormControl", "InputLabel", "Delete", "Schedule", "School", "Calculate", "FileDownload"],
        "unused_variables": ["activeSemester", "selectedPlanung", "setSelectedPlanung", "openDialog", "setOpenDialog"]
    },
    "src/pages/WizardView.tsx": {
        "unused_variables": ["setCurrentStep"]
    },
    "src/services/mockPlanungPhaseService.ts": {
        "unused_variables": ["data", "professorId", "semesterId", "filter", "phaseId", "professorIds", "archivId"]
    }
}


def remove_from_import_line(content: str, file_path: str, unused: list) -> str:
    """Remove unused imports from import statements"""
    for item in unused:
        # Pattern for single-line imports: import { ..., Item, ... } from '...'
        pattern1 = rf',\s*{item}\s*(?=,|\}})'
        content = re.sub(pattern1, '', content)

        pattern2 = rf'{{\s*{item}\s*,\s*'
        content = re.sub(pattern2, '{', content)

        # Pattern for default imports: import Item from '...'
        pattern3 = rf'^import\s+{item}\s+from\s+[\'"][^\'"]+[\'"];?\s*$'
        content = re.sub(pattern3, '', content, flags=re.MULTILINE)

        # Clean up empty braces
        content = re.sub(r'import\s*\{\s*\}\s*from', '', content)

    return content


def remove_unused_variable(content: str, var_name: str) -> str:
    """Remove unused variable declarations"""
    # Pattern for: const [var, setVar] = useState(...)
    pattern1 = rf'const\s+\[([^,\]]+),\s*{var_name}\]\s*=\s*[^;]+;'
    match = re.search(pattern1, content)
    if match:
        # Keep only the first variable
        first_var = match.group(1).strip()
        replacement = f'const [{first_var}] = {match.group(0).split("=")[1]}'
        content = re.sub(pattern1, replacement, content)
        return content

    # Pattern for: const { var, ...rest } = ...
    pattern2 = rf',\s*{var_name}\s*(?=,|\}})'
    content = re.sub(pattern2, '', content)

    # Pattern for: const var = ...
    pattern3 = rf'const\s+{var_name}\s*=\s*[^;]+;\s*'
    content = re.sub(pattern3, '', content)

    return content


def fix_file(base_path: Path, rel_path: str, fixes: dict):
    """Apply fixes to a single file"""
    file_path = base_path / rel_path

    if not file_path.exists():
        print(f"⚠️  File not found: {rel_path}")
        return False

    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content

    # Remove unused imports
    if 'unused_imports' in fixes:
        content = remove_from_import_line(content, str(file_path), fixes['unused_imports'])

    # Remove unused variables
    if 'unused_variables' in fixes:
        for var in fixes['unused_variables']:
            content = remove_unused_variable(content, var)

    # Only write if changed
    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"✅ Fixed: {rel_path}")
        return True
    else:
        print(f"ℹ️  No changes: {rel_path}")
        return False


def main():
    # Base path is frontend root
    base_path = Path(__file__).parent.parent / "digitales-dekanat-frontend" / "root_files"

    print("🔧 Fixing TypeScript unused warnings...")
    print(f"📁 Base path: {base_path}")
    print()

    fixed_count = 0
    for rel_path, fixes in FIXES.items():
        if fix_file(base_path, rel_path, fixes):
            fixed_count += 1

    print()
    print(f"✨ Done! Fixed {fixed_count} file(s)")
    print()
    print("Run 'npm run type-check' to verify fixes")


if __name__ == "__main__":
    main()

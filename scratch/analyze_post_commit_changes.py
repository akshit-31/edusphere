import subprocess

files = [
    "lib/screens/features/academic_calendar_screen.dart",
    "lib/screens/features/announcements_screen.dart",
    "lib/screens/features/exam_approval_screen.dart",
    "lib/screens/features/exam_report_card_screen.dart",
    "lib/screens/features/exam_schedule_screen.dart",
    "lib/screens/features/exam_terms_screen.dart",
    "lib/screens/features/prepare_scan_screen.dart",
    "lib/screens/features/scanner_list_screen.dart",
    "lib/screens/features/scanner_live_screen.dart",
    "lib/screens/features/schedule_screen.dart",
    "lib/screens/features/settings_screen.dart",
    "lib/screens/features/student_directory_screen.dart",
    "lib/screens/features/teacher_attendance_screen.dart",
    "lib/screens/features/teacher_overdue_management_screen.dart",
    "lib/screens/features/teacher_scan_screen.dart",
    "lib/screens/features/teacher_self_attendance_screen.dart",
    "lib/screens/main_screen.dart",
    "lib/screens/profile_screen.dart",
    "lib/widgets/teacher_app_bar.dart"
]

def main():
    for f in files:
        result = subprocess.run(
            ["git", "diff", "945a8c3", "HEAD", "--", f],
            capture_output=True,
            text=True,
            encoding="utf-8"
        )
        diff_output = result.stdout.strip()
        if diff_output:
            print(f"File {f} has changes since commit 945a8c3:")
            # Print a summary of lines changed
            lines = diff_output.splitlines()
            additions = sum(1 for l in lines if l.startswith('+') and not l.startswith('+++'))
            deletions = sum(1 for l in lines if l.startswith('-') and not l.startswith('---'))
            print(f"  + {additions} lines, - {deletions} lines")
        else:
            print(f"File {f} has NO changes since commit 945a8c3")

if __name__ == "__main__":
    main()

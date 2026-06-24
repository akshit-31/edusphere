import subprocess

files = [
    "lib/screens/features/scanner_live_screen.dart",
    "lib/screens/features/scanner_list_screen.dart",
    "lib/screens/features/prepare_scan_screen.dart",
    "lib/screens/features/teacher_scan_screen.dart"
]

def main():
    for f in files:
        print(f"\n==================== DIFF FOR {f} ====================")
        try:
            result = subprocess.run(
                ["git", "diff", "945a8c3^!", "--", f],
                capture_output=True,
                text=True,
                encoding="utf-8"
            )
            lines = result.stdout.splitlines()
            # print only lines containing AppBar, BottomNavBar, TeacherAppBar, TeacherBottomNavBar
            for line in lines:
                if any(x in line.lower() for x in ["appbar", "navbar", "bottomnavigation", "app_bar"]):
                    print(line)
        except Exception as e:
            print("Error:", e)

if __name__ == "__main__":
    main()

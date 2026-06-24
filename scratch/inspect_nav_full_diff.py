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
                ["git", "diff", "945a8c3^", "945a8c3", "--", f],
                capture_output=True,
                text=True,
                encoding="utf-8"
            )
            # Find lines matching Scaffold and print those regions
            lines = result.stdout.splitlines()
            print_lines = False
            counter = 0
            for line in lines:
                if "Scaffold(" in line or "appBar:" in line or "bottomNavigationBar:" in line:
                    print_lines = True
                    counter = 20 # print next 20 lines
                if print_lines:
                    print(line)
                    counter -= 1
                    if counter <= 0:
                        print_lines = False
        except Exception as e:
            print("Error:", e)

if __name__ == "__main__":
    main()

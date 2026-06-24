import subprocess

def main():
    try:
        # Run git diff for profile_screen.dart
        result = subprocess.run(
            ["git", "diff", "lib/screens/profile_screen.dart"],
            capture_output=True,
            text=True,
            encoding="utf-8"
        )
        print("Diff output:")
        lines = result.stdout.splitlines()
        for i, line in enumerate(lines):
            # Print first 200 lines to see changes
            if i < 250:
                print(line)
            else:
                print("... (truncated)")
                break
    except Exception as e:
        print("Error:", e)

if __name__ == "__main__":
    main()

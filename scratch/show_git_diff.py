import subprocess
import sys

def main():
    if len(sys.argv) < 2:
        print("Usage: python show_git_diff.py <filename>")
        return
    f = sys.argv[1]
    
    # Reconfigure stdout to use utf-8 to avoid encoding crashes on Windows
    sys.stdout.reconfigure(encoding='utf-8')
    
    result = subprocess.run(
        ["git", "diff", "945a8c3^", "945a8c3", "--", f],
        capture_output=True,
        text=True,
        encoding="utf-8"
    )
    print(result.stdout)

if __name__ == "__main__":
    main()

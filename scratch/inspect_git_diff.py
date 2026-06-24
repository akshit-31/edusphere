import subprocess

def main():
    try:
        result = subprocess.run(
            ["git", "diff"],
            capture_output=True,
            text=True,
            encoding="utf-8"
        )
        lines = result.stdout.splitlines()
        current_file = ""
        for line in lines:
            if line.startswith("diff --git"):
                current_file = line
            if any(x in line.lower() for x in ["nav", "appbar", "app_bar", "bottomnavbar"]):
                if current_file:
                    print(f"File: {current_file}")
                    current_file = "" # only print once per file
                print(f"  {line}")
    except Exception as e:
        print("Error:", e)

if __name__ == "__main__":
    main()

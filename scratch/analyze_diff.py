import re

def analyze():
    # Try different encodings
    for enc in ['utf-16', 'utf-8', 'latin1']:
        try:
            with open('scratch/nav_commit_diff.txt', 'r', encoding=enc) as f:
                content = f.read()
            print(f"Successfully decoded with {enc}")
            break
        except Exception:
            continue
    else:
        print("Failed to decode file")
        return

    files_diffs = content.split('diff --git ')
    for file_diff in files_diffs:
        if not file_diff:
            continue
        lines = file_diff.splitlines()
        header = lines[0]
        match = re.search(r'a/(\S+)', header)
        if not match:
            continue
        filepath = match.group(1)
        
        changed_lines = []
        for line in lines:
            if line.startswith('+') or line.startswith('-'):
                if not line.startswith('+++') and not line.startswith('---'):
                    if any(x in line.lower() for x in ['appbar', 'navbar', 'bottomnavigation', 'main_screen', 'menu']):
                        changed_lines.append(line)
        
        if changed_lines:
            print(f"File: {filepath}")
            for l in changed_lines[:30]:
                print("  ", l)
            if len(changed_lines) > 30:
                print(f"  ... and {len(changed_lines) - 30} more lines")
            print()

if __name__ == '__main__':
    analyze()

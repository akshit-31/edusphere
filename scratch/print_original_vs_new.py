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
        
        # We want to print the hunks that modified AppBar/BottomNavBar
        # Let's extract blocks of diff starting with @@
        hunks = []
        current_hunk = []
        for line in lines:
            if line.startswith('@@'):
                if current_hunk:
                    hunks.append(current_hunk)
                current_hunk = [line]
            elif current_hunk:
                current_hunk.append(line)
        if current_hunk:
            hunks.append(current_hunk)

        relevant_hunks = []
        for hunk in hunks:
            hunk_str = '\n'.join(hunk)
            if any(x in hunk_str.lower() for x in ['appbar', 'navbar', 'bottomnavigation', 'main_screen', 'teacher_app_bar']):
                relevant_hunks.append(hunk)
                
        if relevant_hunks:
            print("=" * 80)
            print(f"FILE: {filepath}")
            print("=" * 80)
            for hunk in relevant_hunks:
                # Print the hunk header and the changed lines (lines with + or - or a few context lines)
                for line in hunk:
                    if line.startswith('@@') or line.startswith('+') or line.startswith('-'):
                        print(line)
            print()

if __name__ == '__main__':
    analyze()

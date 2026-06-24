def read_diff():
    for enc in ['utf-16', 'utf-8', 'latin1']:
        try:
            with open('scratch/main_screen_diff.txt', 'r', encoding=enc) as f:
                lines = f.readlines()
            break
        except Exception:
            continue
            
    for line in lines:
        if (line.startswith('+') or line.startswith('-')) and not (line.startswith('+++') or line.startswith('---')):
            # Print if contains appbar, navbar, etc.
            l = line.strip()
            if any(x in l.lower() for x in ['appbar', 'navbar', 'bottomnavigation', 'menu', 'notifications']):
                print(l)

if __name__ == '__main__':
    read_diff()

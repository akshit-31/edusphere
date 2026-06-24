def view_file_hunks(target_file):
    lines = []
    for enc in ['utf-16', 'utf-8', 'latin1']:
        try:
            with open('scratch/hunk_details.txt', 'r', encoding=enc) as f:
                lines = f.readlines()
            break
        except Exception:
            continue
    
    in_file = False
    for line in lines:
        if line.startswith('FILE: '):
            if target_file in line:
                in_file = True
                print(line.strip())
            else:
                in_file = False
        elif in_file:
            print(line, end='')

view_file_hunks('lib/screens/features/scanner_live_screen.dart')

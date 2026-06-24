def view_main_screen():
    for enc in ['utf-16', 'utf-8', 'latin1']:
        try:
            with open('scratch/hunk_details.txt', 'r', encoding=enc) as f:
                lines = f.readlines()
            break
        except Exception:
            continue
            
    in_main_screen = False
    for line in lines:
        if line.startswith('FILE: '):
            if 'main_screen.dart' in line:
                in_main_screen = True
                print(line.strip())
            else:
                in_main_screen = False
        elif in_main_screen:
            if line.startswith('@@') or line.startswith('+') or line.startswith('-'):
                print(line.strip())

view_main_screen()

import sys

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

if __name__ == '__main__':
    if len(sys.argv) > 1:
        view_file_hunks(sys.argv[1])
    else:
        print("Please specify a file name")

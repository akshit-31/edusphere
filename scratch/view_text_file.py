import sys

def main():
    if len(sys.argv) < 2:
        print("Usage: python view_text_file.py <filename> [start_line] [end_line]")
        return
    filename = sys.argv[1]
    start = int(sys.argv[2]) if len(sys.argv) > 2 else 1
    end = int(sys.argv[3]) if len(sys.argv) > 3 else -1

    for enc in ['utf-16', 'utf-8', 'latin1']:
        try:
            with open(filename, 'r', encoding=enc) as f:
                lines = f.readlines()
            # print lines
            if end == -1:
                end = len(lines)
            for i in range(start - 1, min(end, len(lines))):
                print(f"{i+1}: {lines[i]}", end='')
            break
        except Exception as e:
            continue

if __name__ == '__main__':
    main()

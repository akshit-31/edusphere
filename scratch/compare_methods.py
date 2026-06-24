with open(r"c:\edusphere\edusphere\lib\screens\profile_screen.dart", 'r', encoding='utf-8') as f:
    lines = f.readlines()

def print_lines(start_line, count):
    print(f"\n--- Lines {start_line} onwards ---")
    for i in range(count):
        idx = start_line - 1 + i
        if idx < len(lines):
            print(f"{start_line+i}: {lines[idx].strip()}")

print_lines(2871, 15)
print_lines(4163, 15)

print_lines(2921, 15)
print_lines(4213, 15)

import re

with open(r"c:\edusphere\edusphere\lib\screens\profile_screen.dart", 'r', encoding='utf-8') as f:
    lines = f.readlines()

for idx, line in enumerate(lines):
    line_num = idx + 1
    # look for patterns like:
    # Widget _build...
    # void _...
    # Future<...
    stripped = line.strip()
    if re.match(r'^(Widget|void|Future|String|bool|List|int|double)\s+\w+\(', stripped):
        print(f"{line_num:4d}: {stripped}")

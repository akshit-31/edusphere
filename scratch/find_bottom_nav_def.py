import sys
sys.stdout.reconfigure(encoding='utf-8')

with open('lib/screens/features/exam_schedule_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if '_buildBottomNav' in line:
        print(f"Line {i+1}: {line.strip()}")
        # print next 40 lines
        for j in range(1, 40):
            if i + j < len(lines):
                print(f"  {i+1+j}: {lines[i+j].strip()}")

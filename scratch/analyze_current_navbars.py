import os
import re

def analyze_current():
    screens_dir = 'lib/screens'
    results = []
    
    for root, dirs, files in os.walk(screens_dir):
        for f in files:
            if f.endswith('.dart'):
                path = os.path.join(root, f)
                with open(path, 'r', encoding='utf-8', errors='ignore') as file:
                    content = file.read()
                
                has_teacher_appbar = 'TeacherAppBar' in content
                has_teacher_bottomnavbar = 'TeacherBottomNavBar' in content
                
                if has_teacher_appbar or has_teacher_bottomnavbar:
                    # Find scaffold and its appBar/bottomNavigationBar lines
                    lines = content.splitlines()
                    appbar_lines = []
                    bottomnav_lines = []
                    for idx, line in enumerate(lines):
                        if 'appBar:' in line:
                            appbar_lines.append((idx + 1, line.strip()))
                        if 'bottomNavigationBar:' in line:
                            bottomnav_lines.append((idx + 1, line.strip()))
                            
                    results.append({
                        'file': path.replace('\\', '/'),
                        'has_appbar': has_teacher_appbar,
                        'has_bottomnav': has_teacher_bottomnavbar,
                        'appbar_lines': appbar_lines,
                        'bottomnav_lines': bottomnav_lines
                    })
                    
    for res in results:
        print(f"File: {res['file']}")
        print(f"  TeacherAppBar: {res['has_appbar']}")
        print(f"  TeacherBottomNavBar: {res['has_bottomnav']}")
        if res['appbar_lines']:
            print("  appBar lines:")
            for num, l in res['appbar_lines']:
                print(f"    {num}: {l}")
        if res['bottomnav_lines']:
            print("  bottomNavigationBar lines:")
            for num, l in res['bottomnav_lines']:
                print(f"    {num}: {l}")
        print()

if __name__ == '__main__':
    analyze_current()

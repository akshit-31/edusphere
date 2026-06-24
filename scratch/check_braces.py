import sys

def check_braces(filename):
    with open(filename, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    stack = []
    in_string = False
    string_char = None
    in_comment = False
    in_multiline_comment = False
    
    for idx, line in enumerate(lines):
        line_num = idx + 1
        i = 0
        while i < len(line):
            char = line[i]
            
            # Handle comments
            if not in_string:
                if in_multiline_comment:
                    if char == '*' and i + 1 < len(line) and line[i+1] == '/':
                        in_multiline_comment = False
                        i += 2
                        continue
                    i += 1
                    continue
                elif in_comment:
                    break
                else:
                    if char == '/' and i + 1 < len(line) and line[i+1] == '/':
                        in_comment = True
                        break
                    if char == '/' and i + 1 < len(line) and line[i+1] == '*':
                        in_multiline_comment = True
                        i += 2
                        continue
            
            # Handle strings
            if in_string:
                if char == '\\':
                    i += 2
                    continue
                if char == string_char:
                    in_string = False
                i += 1
                continue
            else:
                if char in ("'", '"'):
                    in_string = True
                    string_char = char
                    i += 1
                    continue
            
            # Handle braces/parentheses/brackets
            if char in ('{', '(', '['):
                stack.append((char, line_num, i, line.strip()))
            elif char in ('}', ')', ']'):
                if not stack:
                    if line_num >= 5950:
                        print(f"Extra closing '{char}' on line {line_num} at col {i}: {line.strip()}")
                else:
                    top_char, top_line, top_col, top_text = stack.pop()
                    matching = {'}': '{', ')': '(', ']': '['}
                    if matching[char] != top_char:
                        print(f"Mismatch: '{char}' on line {line_num} matches '{top_char}' from line {top_line} col {top_col}")
                    else:
                        if line_num >= 5950 or top_line >= 5950:
                            print(f"Match: line {line_num} closing '{char}' matches '{top_char}' from line {top_line}: {top_text[:40]}")
            i += 1
        in_comment = False # reset at end of line

    if stack:
        print(f"Unclosed braces/brackets/parentheses at EOF: {len(stack)}")
        for item in stack[-5:]:
            print(f"  Unclosed '{item[0]}' on line {item[1]} col {item[2]}: {item[3]}")

if __name__ == '__main__':
    check_braces(r"c:\edusphere\edusphere\lib\screens\profile_screen.dart")

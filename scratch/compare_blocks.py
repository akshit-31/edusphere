with open(r"c:\edusphere\edusphere\lib\screens\profile_screen.dart", 'r', encoding='utf-8') as f:
    lines = f.readlines()

block_a = lines[2859:3992] # 2860 to 3992 (1133 lines)
block_b = lines[3992:5125] # 3993 to 5125 (1133 lines)

identical_lines = 0
for idx, (la, lb) in enumerate(zip(block_a, block_b)):
    if la.strip() == lb.strip():
        identical_lines += 1

print(f"Block A length: {len(block_a)}")
print(f"Block B length: {len(block_b)}")
print(f"Identical lines: {identical_lines} / {len(block_a)}")

# Print a few lines from the beginning of each block to compare
print("\nBlock A start:")
for i in range(10):
    print(f"{2860+i}: {block_a[i].strip()}")

print("\nBlock B start:")
for i in range(10):
    print(f"{3993+i}: {block_b[i].strip()}")

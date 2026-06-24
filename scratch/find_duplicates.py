with open(r"c:\edusphere\edusphere\lib\screens\profile_screen.dart", 'r', encoding='utf-8') as f:
    for idx, line in enumerate(f):
        line_num = idx + 1
        if '_buildDigitalIdentityCard' in line or '_buildQRCodeContainer' in line or 'Widget build(' in line:
            print(f"{line_num}: {line.strip()}")

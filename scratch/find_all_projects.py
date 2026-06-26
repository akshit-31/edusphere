import os

def scan_folders():
    ignore_dirs = {
        'windows', 'program files', 'program files (x86)', 'appdata', 
        'node_modules', '.git', '.next', 'build', 'dist', 'cache',
        'onedrivetemp', 'temp', 'microsoft'
    }
    
    found = []
    print("Scanning C:\\ drive for project directories...")
    
    # We walk from C:\ but skip ignoring directories at the top level
    for root, dirs, files in os.walk("C:\\"):
        # Modify dirs in-place to avoid traversing ignored paths
        dirs[:] = [d for d in dirs if d.lower() not in ignore_dirs and not d.startswith('.')]
        
        if "package.json" in files:
            # Check if this might be our backend
            pkg_path = os.path.join(root, "package.json")
            try:
                with open(pkg_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    if "express" in content or "prisma" in content or "edusphere" in content:
                        found.append((root, pkg_path))
                        print(f"Found package.json: {root}")
            except Exception:
                pass
                
        # Also look for schema.prisma directly
        if "schema.prisma" in files:
            prisma_path = os.path.join(root, "schema.prisma")
            found.append((root, prisma_path))
            print(f"Found schema.prisma: {root}")
            
    print("\n--- Scan Results ---")
    for r, p in found:
        print(f"Path: {r} ({os.path.basename(p)})")

if __name__ == "__main__":
    scan_folders()

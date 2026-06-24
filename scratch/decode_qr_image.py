import base64
import re
import numpy as np
from io import BytesIO

def main():
    try:
        import subprocess
        import sys
        try:
            import cv2
            from PIL import Image
        except ImportError:
            print("Installing dependencies...")
            subprocess.check_call([sys.executable, "-m", "pip", "install", "opencv-python", "pillow"])
            import cv2
            from PIL import Image

        log_path = r"C:\Users\DELL\.gemini\antigravity-ide\brain\c91e3a1a-6f31-4329-ae05-6ebf0b5f80b0\.system_generated\tasks\task-380.log"
        with open(log_path, "r", encoding="utf-8") as f:
            lines = f.readlines()

        print(f"Reading logs from {log_path}...")
        detector = cv2.QRCodeDetector()
        
        for line in lines:
            line = line.strip()
            if not line.startswith("{id:"):
                continue
            
            # Extract name
            name_match = re.search(r"lastName:\s*([^,]+),\s*firstName:\s*([^}]+)", line)
            first_name = name_match.group(2).strip() if name_match else "Unknown"
            last_name = name_match.group(1).strip() if name_match else "Unknown"
            full_name = f"{first_name} {last_name}"

            # Extract admissionNumber
            adm_match = re.search(r"admissionNumber:\s*([^,]+)", line)
            adm_no = adm_match.group(1).strip() if adm_match else "Unknown"

            # Extract qrCode base64
            qr_match = re.search(r"qrCode:\s*(data:image/png;base64,[^,]+|[a-zA-Z0-9+/=]+)", line)
            if not qr_match:
                print(f"No QR code found for {full_name}")
                continue
            
            qr_val = qr_match.group(1).strip()
            if qr_val.startswith("data:image"):
                header, base64_data = qr_val.split(",", 1)
            else:
                base64_data = qr_val
            
            # Pad base64 data if needed
            missing_padding = len(base64_data) % 4
            if missing_padding:
                base64_data += '=' * (4 - missing_padding)

            try:
                img_bytes = base64.b64decode(base64_data)
                
                # Convert bytes to numpy array for cv2
                nparr = np.frombuffer(img_bytes, np.uint8)
                img_cv = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
                
                # Detect and decode
                qr_text, bbox, straight_qrcode = detector.detectAndDecode(img_cv)
                if not qr_text:
                    qr_text = "COULD NOT DECODE"
                print(f"Name: {full_name} | AdmissionNo: {adm_no} | Encoded QR Content: '{qr_text}'")
            except Exception as ex:
                print(f"Error decoding for {full_name}: {ex}")

    except Exception as e:
        print("Error:", e)

if __name__ == "__main__":
    main()

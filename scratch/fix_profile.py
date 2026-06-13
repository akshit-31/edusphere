import re

file_path = "c:/final edusphere app/edusphere/lib/screens/profile_screen.dart"
with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

# 1. remove unused imports
content = re.sub(r"import 'welcome_screen\.dart';\n", "", content)
content = re.sub(r"import 'features/settings_screen\.dart';\n", "", content)

# 2. replace activeColor with activeThumbColor
content = content.replace("activeColor: Colors.white,", "activeThumbColor: Colors.white,")

# 3. replace showToast for Change Password with _showChangePasswordSheet
content = content.replace("showToast(context, 'Change password initiated');", "_showChangePasswordSheet();")

# 4. insert _buildInfoBulletPoint and _buildLogoutDialog before _showChangePasswordSheet
missing_methods = """  Widget _buildInfoBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle_outline, color: const Color(0xFF0284C7), size: 18.sp),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFF475569), height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutDialog() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 40.w),
          padding: EdgeInsets.all(24.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Logout', style: GoogleFonts.inter(fontSize: 20.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
              SizedBox(height: 16.h),
              Text('Are you sure you want to log out?', style: GoogleFonts.inter(fontSize: 14.sp, color: const Color(0xFF475569))),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => setState(() => _showLogout = false), child: Text('Cancel', style: GoogleFonts.inter(color: const Color(0xFF64748B)))),
                  SizedBox(width: 16.w),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => _showLogout = false);
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
                    child: Text('Logout', style: GoogleFonts.inter(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordSheet() {"""
content = content.replace("  void _showChangePasswordSheet() {", missing_methods)

with open(file_path, "w", encoding="utf-8") as f:
    f.write(content)

import re

file_path = "c:/final edusphere app/edusphere/lib/screens/profile_screen.dart"
with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

# 1. remove unused _teacherData field
content = re.sub(r"\s*final Map<String, String> _teacherData = \{[^}]+\};\n", "", content)

# 2. remove unused _updateNotificationPreference
content = re.sub(r"  Future<void> _updateNotificationPreference\(String type, bool value\) async \{[\s\S]*?    \}\n  \}\n", "", content)

# 3. remove unused _toggleActivityStatus
content = re.sub(r"  Future<void> _toggleActivityStatus\(bool isActive\) async \{[\s\S]*?    \}\n  \}\n", "", content)

# 4. remove unused widget methods (_buildBulletPoint, _buildInfoRow, _buildDivider, _detailCard)
content = re.sub(r"  Widget _buildBulletPoint\(String text\) \{[\s\S]*?  \}\n\n", "", content)
content = re.sub(r"  Widget _buildInfoRow\(String label, String value\) \{[\s\S]*?  \}\n\n", "", content)
content = re.sub(r"  Widget _buildDivider\(\) \{[\s\S]*?  \}\n\n", "", content)
content = re.sub(r"  Widget _detailCard\(String label, String value, IconData icon, Color color, \{bool isFullWidth = false\}\) \{[\s\S]*?  \}\n\n", "", content)

# 5. remove unused _showDisplayIdDialog
content = re.sub(r"  void _showDisplayIdDialog\(\) \{[\s\S]*?  \}\n", "", content)

with open(file_path, "w", encoding="utf-8") as f:
    f.write(content)

const fs = require('fs');
const content = fs.readFileSync('lib/screens/features/create_assignment_screen.dart', 'utf8');
const lines = content.split('\n');

lines.forEach((line, idx) => {
  if (line.includes('void _showAssignmentDetailsBottomSheet') || line.includes('Future<void> _downloadFile') || line.includes('Widget _buildDetailRow')) {
    console.log(`${idx + 1}: ${line.trim()}`);
  }
});

import 'package:supabase/supabase.dart';

void main() async {
  const supabaseUrl = 'https://bstevdkjqjzaglayicdg.supabase.co';
  const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzdGV2ZGtqcWp6YWdsYXlpY2RnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2MjU5MDUsImV4cCI6MjA5NjIwMTkwNX0.DuFB6mkZLcE2qhhEQITchXjth0h86P6bkQSfY_bbvOE';

  final supabase = SupabaseClient(supabaseUrl, supabaseAnonKey);

  try {
    final qrRes = await supabase.from('QRScanner').select('*').limit(1);
    print('QRScanner columns: ${qrRes.first.keys.toList()}');
    print('QRScanner row: ${qrRes.first}');
  } catch (e) {
    print('Error QRScanner: $e');
  }

  try {
    final recordRes = await supabase.from('AttendanceRecord').select('*').limit(1);
    print('AttendanceRecord columns: ${recordRes.first.keys.toList()}');
    print('AttendanceRecord row: ${recordRes.first}');
  } catch (e) {
    print('Error AttendanceRecord: $e');
  }
}

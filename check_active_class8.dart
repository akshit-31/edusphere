import 'package:supabase/supabase.dart';
void main() async {
  final supabase = SupabaseClient('https://bstevdkjqjzaglayicdg.supabase.co', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzdGV2ZGtqcWp6YWdsYXlpY2RnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2MjU5MDUsImV4cCI6MjA5NjIwMTkwNX0.DuFB6mkZLcE2qhhEQITchXjth0h86P6bkQSfY_bbvOE');
  try {
    final cls = await supabase.from('Class').select().eq('name', 'Class 8');
    if (cls.isNotEmpty) {
      final classId = cls[0]['id'];
      final students = await supabase.from('Student').select('status, User(isActive)').eq('currentClassId', classId);
      int activeCount = 0;
      for (var s in students) {
        if (s['status'] == 'ACTIVE' && (s['User'] as Map)['isActive'] == true) {
          activeCount++;
        }
      }
      print('Active students in Class 8: $activeCount / ${students.length}');
    }
  } catch(e) {
    print(e);
  } finally {
    supabase.dispose();
  }
}

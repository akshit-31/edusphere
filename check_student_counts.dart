import 'package:supabase/supabase.dart';
void main() async {
  final supabase = SupabaseClient('https://bstevdkjqjzaglayicdg.supabase.co', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzdGV2ZGtqcWp6YWdsYXlpY2RnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2MjU5MDUsImV4cCI6MjA5NjIwMTkwNX0.DuFB6mkZLcE2qhhEQITchXjth0h86P6bkQSfY_bbvOE');
  try {
    final students = await supabase.from('Student').select('currentClassId, Class(name)');
    final counts = <String, int>{};
    for(var s in students) {
      final clsMap = s['Class'] as Map?;
      final cls = clsMap != null ? clsMap['name']?.toString() : 'Unknown';
      if (cls != null) {
        counts[cls] = (counts[cls] ?? 0) + 1;
      }
    }
    print(counts);
  } catch(e) {
    print(e);
  } finally {
    supabase.dispose();
  }
}

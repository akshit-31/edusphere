import 'package:supabase/supabase.dart';
void main() async {
  final supabase = SupabaseClient('https://bstevdkjqjzaglayicdg.supabase.co', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzdGV2ZGtqcWp6YWdsYXlpY2RnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2MjU5MDUsImV4cCI6MjA5NjIwMTkwNX0.DuFB6mkZLcE2qhhEQITchXjth0h86P6bkQSfY_bbvOE');
  try {
    final cls = await supabase.from('Class').select().eq('name', 'Class 8');
    if (cls.isNotEmpty) {
      final classId = cls[0]['id'];
      final sections = await supabase.from('Section').select().eq('classId', classId).eq('name', 'A');
      if (sections.isNotEmpty) {
        final sectionId = sections[0]['id'];
        final students = await supabase.from('Student').select('id, status, admissionNumber, User(isActive, firstName, lastName)').eq('currentClassId', classId).eq('sectionId', sectionId);
        print('Students in Class 8 Sec A: ${students.length}');
        for (var s in students) {
          print(s);
        }
      }
    }
  } catch(e) {
    print(e);
  } finally {
    supabase.dispose();
  }
}

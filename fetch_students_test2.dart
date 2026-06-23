import 'package:supabase/supabase.dart';
void main() async {
  final supabase = SupabaseClient('https://bstevdkjqjzaglayicdg.supabase.co', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzdGV2ZGtqcWp6YWdsYXlpY2RnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2MjU5MDUsImV4cCI6MjA5NjIwMTkwNX0.DuFB6mkZLcE2qhhEQITchXjth0h86P6bkQSfY_bbvOE');
  try {
    final cls = await supabase.from('Class').select().eq('name', 'Class 8');
    print('Class 8: $cls');
    if (cls.isNotEmpty) {
      final classId = cls[0]['id'];
      
      var studentQuery = supabase
          .from('Student')
          .select('id, admissionNumber, currentClassId, sectionId, User(firstName, lastName, email)')
          .eq('currentClassId', classId);
          
      final students = await studentQuery;
      print('Students in Class 8: ${students.length}');
      print(students);
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    supabase.dispose();
  }
}

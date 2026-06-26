import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://bstevdkjqjzaglayicdg.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzdGV2ZGtqcWp6YWdsYXlpY2RnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2MjU5MDUsImV4cCI6MjA5NjIwMTkwNX0.DuFB6mkZLcE2qhhEQITchXjth0h86P6bkQSfY_bbvOE'
  );

  try {
    print('Fetching Teacher sample data...');
    final teachers = await supabase.from('Teacher').select().limit(2);
    print('Teacher data: $teachers\n');

    print('Checking if there are tables representing ClassTeacher assignments or similar...');
    // Let's query Class where classTeacherId matches a teacher ID
    if (teachers.isNotEmpty) {
      final tId = teachers.first['id'];
      print('Querying Class tables for teacherId: $tId...');
      final classesForTeacher = await supabase.from('Class').select().eq('classTeacherId', tId);
      print('Classes where teacher is Class Teacher: $classesForTeacher\n');
    }

    // Let's check other tables that might map teachers to sections or subjects, e.g. Subject or ClassSubject
    try {
      final classSubjects = await supabase.from('ClassSubject').select().limit(2);
      print('ClassSubject data: $classSubjects\n');
    } catch (e) {
      print('ClassSubject table not found or query failed: $e');
    }

    try {
      final timetable = await supabase.from('TimetableSlot').select().limit(2);
      print('TimetableSlot data: $timetable\n');
    } catch (e) {
      print('TimetableSlot table not found or query failed: $e');
    }
  } catch (e) {
    print('Error: $e');
  }
}

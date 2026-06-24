import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://bstevdkjqjzaglayicdg.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzdGV2ZGtqcWp6YWdsYXlpY2RnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2MjU5MDUsImV4cCI6MjA5NjIwMTkwNX0.DuFB6mkZLcE2qhhEQITchXjth0h86P6bkQSfY_bbvOE'
  );
  
  try {
    print('--- SEARCHING FOR KAVITA ---');
    // Fetch all users with name containing kavita
    final users = await supabase.from('User').select('id, firstName, lastName, email, role');
    final kavitaUsers = users.where((u) {
      final name = '${u['firstName'] ?? ''} ${u['lastName'] ?? ''}'.toLowerCase();
      return name.contains('kavita');
    }).toList();
    
    print('Found users in User table: $kavitaUsers');
    
    // Fetch all students
    final students = await supabase.from('Student').select('id, admissionNumber, currentClassId, sectionId, userId');
    print('Total students: ${students.length}');
    
    for (var u in kavitaUsers) {
      final matchedStudents = students.where((s) => s['userId'] == u['id']).toList();
      print('User ID: ${u['id']} matches students: $matchedStudents');
    }
    
    // Check if there is any student with a matching name directly
    // Let's print Class and Section tables too
    final classes = await supabase.from('Class').select('id, name');
    final sections = await supabase.from('Section').select('id, name, classId');
    print('Classes in DB: $classes');
    print('Sections in DB: $sections');

  } catch (e) {
    print('Error: $e');
  } finally {
    supabase.dispose();
  }
}

import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://bstevdkjqjzaglayicdg.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzdGV2ZGtqcWp6YWdsYXlpY2RnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2MjU5MDUsImV4cCI6MjA5NjIwMTkwNX0.DuFB6mkZLcE2qhhEQITchXjth0h86P6bkQSfY_bbvOE'
  );
  
  try {
    print('Querying Teachers from User table...');
    final users = await supabase.from('User').select('id, email, role, firstName, lastName');
    final teachers = users.where((u) => u['role']?.toString().toUpperCase() == 'TEACHER').toList();
    print('Found ${teachers.length} teachers:');
    for (var t in teachers) {
      print('Name: ${t['firstName']} ${t['lastName']}, Email: ${t['email']}, ID: ${t['id']}');
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    supabase.dispose();
  }
}

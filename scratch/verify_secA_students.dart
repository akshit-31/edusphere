import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://bstevdkjqjzaglayicdg.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzdGV2ZGtqcWp6YWdsYXlpY2RnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2MjU5MDUsImV4cCI6MjA5NjIwMTkwNX0.DuFB6mkZLcE2qhhEQITchXjth0h86P6bkQSfY_bbvOE'
  );
  
  try {
    print('--- FETCHING STUDENTS FOR CLASS 8 SECTION A ---');
    // Class 8 ID: eca75480-c96e-4ea6-8e66-c934a89c9bc0
    // Section A ID: ba6e2d2f-da7e-49fa-be31-5369fe5991fb
    final list = await supabase
        .from('Student')
        .select('id, admissionNumber, currentClassId, sectionId, User(firstName, lastName, email)')
        .eq('currentClassId', 'eca75480-c96e-4ea6-8e66-c934a89c9bc0')
        .eq('sectionId', 'ba6e2d2f-da7e-49fa-be31-5369fe5991fb');

    print('Total students found: ${list.length}');
    for (var i = 0; i < list.length; i++) {
      final item = list[i];
      final user = item['User'] as Map? ?? {};
      final firstName = user['firstName'] ?? '';
      final lastName = user['lastName'] ?? '';
      final fullName = '$firstName $lastName'.trim();
      print('${i + 1}. $fullName (ID: ${item['id']}, Admission: ${item['admissionNumber']})');
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    supabase.dispose();
  }
}

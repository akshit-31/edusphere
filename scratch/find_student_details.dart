import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://bstevdkjqjzaglayicdg.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzdGV2ZGtqcWp6YWdsYXlpY2RnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2MjU5MDUsImV4cCI6MjA5NjIwMTkwNX0.DuFB6mkZLcE2qhhEQITchXjth0h86P6bkQSfY_bbvOE'
  );

  try {
    final student = await supabase
        .from('Student')
        .select('id, admissionNumber, currentClassId, sectionId, User(id, email, firstName, lastName, qrCode)')
        .eq('userId', '161367f4-ead0-4d92-abe7-6a664875e8b9')
        .maybeSingle();

    print('Student details:');
    print(student);
  } catch (e) {
    print('Error: $e');
  } finally {
    supabase.dispose();
  }
}

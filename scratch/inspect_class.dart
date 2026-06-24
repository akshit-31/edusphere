import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://bstevdkjqjzaglayicdg.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzdGV2ZGtqcWp6YWdsYXlpY2RnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2MjU5MDUsImV4cCI6MjA5NjIwMTkwNX0.DuFB6mkZLcE2qhhEQITchXjth0h86P6bkQSfY_bbvOE'
  );

  try {
    final classRes = await supabase
        .from('Class')
        .select('name')
        .eq('id', 'eca75480-c96e-4ea6-8e66-c934a89c9bc0')
        .maybeSingle();

    final sectionRes = await supabase
        .from('Section')
        .select('name')
        .eq('id', 'd95c2927-205f-4f6a-a84c-67df58611eaa')
        .maybeSingle();

    print('Class Name: ${classRes?['name']}');
    print('Section Name: ${sectionRes?['name']}');
  } catch (e) {
    print('Error: $e');
  } finally {
    supabase.dispose();
  }
}

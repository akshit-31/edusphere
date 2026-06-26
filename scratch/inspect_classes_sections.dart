import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://bstevdkjqjzaglayicdg.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzdGV2ZGtqcWp6YWdsYXlpY2RnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2MjU5MDUsImV4cCI6MjA5NjIwMTkwNX0.DuFB6mkZLcE2qhhEQITchXjth0h86P6bkQSfY_bbvOE'
  );

  try {
    print('Fetching Class sample data...');
    final classes = await supabase.from('Class').select().limit(2);
    print('Class data: $classes\n');

    print('Fetching Section sample data...');
    final sections = await supabase.from('Section').select().limit(2);
    print('Section data: $sections\n');
  } catch (e) {
    print('Error: $e');
  }
}

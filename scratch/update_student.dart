import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://bstevdkjqjzaglayicdg.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzdGV2ZGtqcWp6YWdsYXlpY2RnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2MjU5MDUsImV4cCI6MjA5NjIwMTkwNX0.DuFB6mkZLcE2qhhEQITchXjth0h86P6bkQSfY_bbvOE'
  );
  
  try {
    print('--- UPDATING SECTION FOR KAVITA DAS ---');
    // Kavita Das student ID: d70951be-b1a9-4269-b503-7c08ec55f035
    // Target Section A ID: ba6e2d2f-da7e-49fa-be31-5369fe5991fb (Class 8 Section A)
    final res = await supabase
        .from('Student')
        .update({'sectionId': 'ba6e2d2f-da7e-49fa-be31-5369fe5991fb'})
        .eq('id', 'd70951be-b1a9-4269-b503-7c08ec55f035')
        .select();
        
    print('UPDATE SUCCESS! Updated student record: $res');
  } catch (e) {
    print('Error: $e');
  } finally {
    supabase.dispose();
  }
}

import 'package:supabase/supabase.dart';

void main() async {
  const supabaseUrl = 'https://bstevdkjqjzaglayicdg.supabase.co';
  const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzdGV2ZGtqcWp6YWdsYXlpY2RnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Ngw2MjU5MDUsImV4cCI6MjA5NjIwMTkwNX0.DuFB6mkZLcE2qhhEQITchXjth0h86P6bkQSfY_bbvOE';

  // Wait! The key in main config had an O instead of a number, or let's copy exactly from supabase_config.dart:
  // Key in config: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzdGV2ZGtqcWp6YWdsYXlpY2RnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2MjU5MDUsImV4cCI6MjA5NjIwMTkwNX0.DuFB6mkZLcE2qhhEQITchXjth0h86P6bkQSfY_bbvOE
  const key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzdGV2ZGtqcWp6YWdsYXlpY2RnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2MjU5MDUsImV4cCI6MjA5NjIwMTkwNX0.DuFB6mkZLcE2qhhEQITchXjth0h86P6bkQSfY_bbvOE';

  final supabase = SupabaseClient(supabaseUrl, key);

  try {
    print('Searching for User with first name "Tanvi"...');
    final users = await supabase
        .from('User')
        .select()
        .ilike('firstName', '%Tanvi%');

    print('Users found: ${users.length}');
    for (var u in users) {
      print('User ID: ${u['id']}, Name: ${u['firstName']} ${u['lastName']}, Email: ${u['email']}');
      
      final student = await supabase
          .from('Student')
          .select()
          .eq('userId', u['id'])
          .maybeSingle();
          
      if (student != null) {
        final studentId = student['id'];
        print('Student found! Student ID: $studentId');
        
        final records = await supabase
            .from('AttendanceRecord')
            .select()
            .eq('studentId', studentId);
            
        print('Total Attendance Records: ${records.length}');
        for (var rec in records) {
          print('  Date: ${rec['date']}, Status: ${rec['status']}');
        }
      } else {
        print('No Student record found for this User.');
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}

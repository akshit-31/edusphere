import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://bstevdkjqjzaglayicdg.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzdGV2ZGtqcWp6YWdsYXlpY2RnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2MjU5MDUsImV4cCI6MjA5NjIwMTkwNX0.DuFB6mkZLcE2qhhEQITchXjth0h86P6bkQSfY_bbvOE'
  );

  try {
    final users = await supabase
        .from('User')
        .select('id, email, firstName, lastName, role')
        .or('firstName.ilike.%Aarohi%,lastName.ilike.%Mishra%,firstName.ilike.%Mishra%,lastName.ilike.%Aarohi%');

    print('Matching Users: ${users.length}');
    for (var u in users) {
      print(u);
    }

    final students = await supabase
        .from('Student')
        .select('id, admissionNumber, user:User(id, firstName, lastName)')
        .or('user.firstName.ilike.%Aarohi%,user.lastName.ilike.%Mishra%'); // wait, Postgrest doesn't support nested relation or in root, so let's filter after fetching or select users first.
  } catch (e) {
    print('Error: $e');
  } finally {
    supabase.dispose();
  }
}

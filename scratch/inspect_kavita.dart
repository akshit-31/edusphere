import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  final supabase = await Supabase.initialize(
    url: 'https://bstevdkjqjzaglayicdg.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzdGV2ZGtqcWp6YWdsYXlpY2RnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2MjU5MDUsImV4cCI6MjA5NjIwMTkwNX0.DuFB6mkZLcE2qhhEQITchXjth0h86P6bkQSfY_bbvOE',
  );

  print('Connected to Supabase. Querying Student table...');
  
  // Find student by admissionNumber or name
  final studentRes = await supabase.client
      .from('Student')
      .select('*, User(*), Class(*), Section(*)')
      .or('admissionNumber.eq.ADM-2024001');

  print('Students found:');
  for (var s in studentRes) {
    print('Student ID: ${s['id']}');
    print('Admission Number: ${s['admissionNumber']}');
    print('Class ID: ${s['currentClassId']} (Class Name: ${s['Class']?['name']})');
    print('Section ID: ${s['sectionId']} (Section Name: ${s['Section']?['name']})');
    print('User details: ${s['User']}');
  }

  // Let's also fetch all Class 8 and its sections
  final class8Res = await supabase.client
      .from('Class')
      .select('*, Section(*)')
      .eq('name', 'Class 8');
  print('\nClass 8 details:');
  for (var c in class8Res) {
    print('Class: ${c['name']}, ID: ${c['id']}');
    print('Sections: ${c['Section']}');
  }
}

import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://bstevdkjqjzaglayicdg.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzdGV2ZGtqcWp6YWdsYXlpY2RnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2MjU5MDUsImV4cCI6MjA5NjIwMTkwNX0.DuFB6mkZLcE2qhhEQITchXjth0h86P6bkQSfY_bbvOE'
  );

  final String selectedClass = 'Class 8';
  final String selectedSection = 'Section A';

  try {
    print('1. Loading class matching: $selectedClass');
    final classesRes = await supabase.from('Class').select('id, name');
    final cls = classesRes.firstWhere(
      (c) => c['name'] == selectedClass,
      orElse: () => {},
    );
    print('Class found: $cls');
    if (cls.isEmpty) {
      print('Error: Class not found');
      return;
    }
    final classId = cls['id']?.toString() ?? '';
    print('Class ID: $classId');

    print('\n2. Loading all sections...');
    final sectionsRes = await supabase.from('Section').select('id, name, classId');
    final allSections = List<Map<String, dynamic>>.from(sectionsRes);
    print('Total sections in DB: ${allSections.length}');

    String? sectionId;
    if (selectedSection != 'All Sections') {
      final secName = selectedSection.replaceAll('Section ', '').trim();
      print('Looking up section name: "$secName" for classId: "$classId"');
      final sec = allSections.firstWhere(
        (s) =>
            s['classId']?.toString() == classId &&
            s['name']?.toString() == secName,
        orElse: () => {},
      );
      print('Section found: $sec');
      if (sec.isNotEmpty) {
        sectionId = sec['id']?.toString();
      }
    }
    print('Resolved Section ID: $sectionId');

    // Fetch students directly from Supabase
    print('\n3. Querying students from Supabase...');
    var studentQuery = supabase
        .from('Student')
        .select('id, admissionNumber, currentClassId, sectionId, User(firstName, lastName, email)')
        .eq('currentClassId', classId);

    if (sectionId != null) {
      studentQuery = studentQuery.eq('sectionId', sectionId);
    }

    final List<dynamic> studentsRawList = await studentQuery;
    print('Supabase query returned: ${studentsRawList.length} rows');

    final List<Map<String, dynamic>> studentList = [];
    print('4. Mapping studentsRawList to studentList...');
    for (var item in studentsRawList) {
      final user = item['User'] as Map? ?? {};
      final firstName = user['firstName'] ?? '';
      final lastName = user['lastName'] ?? '';
      final fullName = '$firstName $lastName'.trim();
      final email = user['email'] ?? '';
      final admission = item['admissionNumber'] ?? '';

      final sId = item['id']?.toString() ?? '';
      if (sId.isEmpty) {
        print('Skipping: empty id');
        continue;
      }

      studentList.add({
        'id': sId,
        'name': fullName.isNotEmpty ? fullName : 'Unknown',
        'email': email,
        'class_name': selectedClass,
        'admission_no': admission,
      });
    }

    print('studentList final length: ${studentList.length}');
    if (studentList.isNotEmpty) {
      print('First Student: ${studentList.first}');
    }
  } catch (e, stack) {
    print('Error: $e');
    print(stack);
  } finally {
    supabase.dispose();
  }
}

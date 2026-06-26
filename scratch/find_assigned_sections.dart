import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://bstevdkjqjzaglayicdg.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzdGV2ZGtqcWp6YWdsYXlpY2RnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2MjU5MDUsImV4cCI6MjA5NjIwMTkwNX0.DuFB6mkZLcE2qhhEQITchXjth0h86P6bkQSfY_bbvOE'
  );

  final teacherId = '74c8220a-d062-454f-890b-373a449fa82b';

  try {
    print('1. Finding Classes where teacher is classTeacherId...');
    final classesRes = await supabase.from('Class').select('id, name').eq('classTeacherId', teacherId);
    print('Class Teacher for: $classesRes');

    print('2. Finding Sections under those classes...');
    List<String> classIds = [];
    for (var c in classesRes) {
      classIds.add(c['id'].toString());
    }

    List<Map<String, dynamic>> classTeacherSections = [];
    if (classIds.isNotEmpty) {
      final sectionsForClasses = await supabase.from('Section').select('id, name, classId, Class(name)').inFilter('classId', classIds);
      classTeacherSections = List<Map<String, dynamic>>.from(sectionsForClasses);
    }
    print('Class Teacher sections: $classTeacherSections');

    print('\n3. Finding TimetableSlots for the teacher...');
    final slotsRes = await supabase.from('TimetableSlot').select('sectionId, Section(id, name, classId, Class(id, name))').eq('teacherId', teacherId);
    print('Timetable Slots count: ${slotsRes.length}');
    
    // Group slots by unique class/section
    Set<String> uniqueSections = {};
    List<Map<String, dynamic>> slotSections = [];
    for (var slot in slotsRes) {
      final sec = slot['Section'] as Map?;
      if (sec != null) {
        final secId = sec['id']?.toString() ?? '';
        if (secId.isNotEmpty && !uniqueSections.contains(secId)) {
          uniqueSections.add(secId);
          slotSections.add(Map<String, dynamic>.from(sec));
        }
      }
    }
    print('Timetable sections: $slotSections');

    print('\n4. Merging both to get ALL assigned sections...');
    Map<String, Map<String, dynamic>> allAssigned = {};
    for (var sec in classTeacherSections) {
      final secId = sec['id'].toString();
      allAssigned[secId] = sec;
    }
    for (var sec in slotSections) {
      final secId = sec['id'].toString();
      allAssigned[secId] = sec;
    }

    print('Total unique assigned sections: ${allAssigned.length}');
    allAssigned.forEach((id, details) {
      final secName = details['name'];
      final clsName = (details['Class'] as Map)['name'];
      print(' - Section ID: $id -> $clsName - $secName');
    });

  } catch (e) {
    print('Error: $e');
  }
}

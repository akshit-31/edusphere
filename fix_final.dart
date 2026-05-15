import 'dart:io';

void main() {
  final libDir = Directory('lib');
  int fixes = 0;

  for (var entity in libDir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      String content = entity.readAsStringSync();
      String original = content;

      // Fix constconstraints typo
      content = content.replaceAll('constconstraints:', 'constraints:');
      
      // Also catch constraints: const BoxConstraints(...) if it was doubled
      content = content.replaceAll('constraints: const BoxConstraints', 'constraints: BoxConstraints');

      // Make sure common screens have const constructors if they don't have fields
      final screenClasses = [
        'GradebookScreen', 'MarkAttendanceScreen', 'LessonPlanScreen', 
        'CreateAssignmentScreen', 'CreateQuizScreen', 'UploadMaterialScreen',
        'StudentPerformanceScreen', 'NoticesScreen', 'DiscussionForumScreen',
        'ChangePasswordScreen', 'NotificationPreferencesScreen', 'CoCurricularScreen',
        'LeaveApplicationScreen'
      ];

      for (var cls in screenClasses) {
        // Find class ClassName extends ... { \n ClassName({super.key});
        content = content.replaceFirst('$cls({super.key})', 'const $cls({super.key})');
        // Avoid const const
        content = content.replaceAll('const const $cls', 'const $cls');
      }

      if (content != original) {
        entity.writeAsStringSync(content);
        fixes++;
      }
    }
  }

  print('Fixed const and typos in $fixes files.');
}

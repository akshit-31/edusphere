import 'dart:io';

void main() {
  final libDir = Directory('lib');
  int fixes = 0;

  for (var entity in libDir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      String content = entity.readAsStringSync();
      String original = content;

      // Fix pw. sized boxes and text styles that shouldn't have .sp, .w, .h
      content = content.replaceAllMapped(
        RegExp(r'(pw\.TextStyle|pw\.SizedBox|pw\.Header|pw\.Padding|pw\.Container|pw\.Column|pw\.Row|pw\.Center)\((.*?)\.(?:sp|w|h|r)'),
        (match) {
          // Re-process the inner content to remove all screenutil extensions
          String inner = match.group(0)!;
          inner = inner.replaceAll(RegExp(r'\.(sp|w|h|r)'), '');
          return inner;
        },
      );
      
      // Also catch cases like pw.SizedBox(height: 10.h) -> pw.SizedBox(height: 10)
      content = content.replaceAllMapped(
        RegExp(r'pw\.(SizedBox|TextStyle|EdgeInsets|BorderRadius|Radius|BoxDecoration|Padding|Container|Column|Row|Center)\(([^)]*?)\.(sp|w|h|r)([^)]*?)\)'),
        (match) {
           String res = match.group(0)!;
           res = res.replaceAll(RegExp(r'\.(sp|w|h|r)'), '');
           return res;
        }
      );

      if (content != original) {
        entity.writeAsStringSync(content);
        fixes++;
      }
    }
  }

  print('Fixed PDF-related ScreenUtil errors in $fixes files.');
}

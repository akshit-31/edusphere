import 'dart:io';

void main() {
  final libDir = Directory('lib');
  int filesFixed = 0;

  for (var entity in libDir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      String content = entity.readAsStringSync();
      String original = content;

      // Fix integer cases: 1.sp8.sp -> 18.sp, 4.h0.w -> 40.w
      content = content.replaceAllMapped(
        RegExp(r'([0-9])\.(?:sp|w|h|r)([0-9]+)\.(sp|w|h|r)'),
        (match) => '${match.group(1)}${match.group(2)}.${match.group(3)}',
      );

      // Fix float cases: 1.w.5.w -> 1.5.w
      content = content.replaceAllMapped(
        RegExp(r'([0-9])\.(?:sp|w|h|r)\.([0-9]+)\.(sp|w|h|r)'),
        (match) => '${match.group(1)}.${match.group(2)}.${match.group(3)}',
      );

      // Fix double replacements if there were any like 12.sp.sp
      content = content.replaceAll(RegExp(r'\.(sp|w|h|r)\.\1'), r'.\1');

      if (content != original) {
        entity.writeAsStringSync(content);
        filesFixed++;
      }
    }
  }

  print('Fixed regex disaster in $filesFixed files.');
}

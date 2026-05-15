import 'dart:io';

void main() {
  final libDir = Directory('lib');
  int fixes = 0;

  for (var entity in libDir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      String content = entity.readAsStringSync();
      String original = content;

      content = content.replaceAll('raints:', 'constraints:');
      content = content.replaceAll('accountLight', 'accountantLight');

      if (content != original) {
        entity.writeAsStringSync(content);
        fixes++;
      }
    }
  }

  print('Fixed typos in $fixes files.');
}

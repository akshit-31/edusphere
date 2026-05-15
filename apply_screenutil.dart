import 'dart:io';

void main() {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    print('lib directory not found.');
    return;
  }

  int modifiedFiles = 0;

  for (var entity in libDir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      String content = entity.readAsStringSync();
      String originalContent = content;

      // Add import if not present and we need it
      bool needsImport = false;

      // Helper function to check if we made a change
      String process(String pattern, String replacement, String content) {
        final regex = RegExp(pattern);
        if (regex.hasMatch(content)) {
          needsImport = true;
          return content.replaceAllMapped(regex, (match) {
            // Reconstruct the replacement properly
            String rep = replacement;
            for (int i = 1; i <= match.groupCount; i++) {
              rep = rep.replaceAll('\$$i', match.group(i)!);
            }
            return rep;
          });
        }
        return content;
      }

      // Replace font sizes
      content = process(r'fontSize:\s*([0-9]+(?:\.[0-9]+)?)(?![\.a-zA-Z])', r'fontSize: $1.sp', content);
      
      // Replace Radius.circular
      content = process(r'Radius\.circular\(\s*([0-9]+(?:\.[0-9]+)?)\s*\)', r'Radius.circular($1.r)', content);
      
      // Replace BorderRadius.circular
      content = process(r'BorderRadius\.circular\(\s*([0-9]+(?:\.[0-9]+)?)\s*\)', r'BorderRadius.circular($1.r)', content);

      // Replace EdgeInsets.all
      content = process(r'EdgeInsets\.all\(\s*([0-9]+(?:\.[0-9]+)?)\s*\)', r'EdgeInsets.all($1.r)', content);

      // Replace EdgeInsets.symmetric
      content = content.replaceAllMapped(RegExp(r'EdgeInsets\.symmetric\(\s*(horizontal:\s*([0-9]+(?:\.[0-9]+)?))?\s*,?\s*(vertical:\s*([0-9]+(?:\.[0-9]+)?))?\s*\)'), (match) {
        String res = 'EdgeInsets.symmetric(';
        List<String> parts = [];
        if (match.group(1) != null) {
          parts.add('horizontal: ${match.group(2)}.w');
        }
        if (match.group(3) != null) {
          parts.add('vertical: ${match.group(4)}.h');
        }
        res += parts.join(', ') + ')';
        needsImport = true;
        return res;
      });

      // Replace EdgeInsets.only
      content = content.replaceAllMapped(RegExp(r'EdgeInsets\.only\((.*?)\)'), (match) {
        String inner = match.group(1)!;
        inner = inner.replaceAllMapped(RegExp(r'(left|right):\s*([0-9]+(?:\.[0-9]+)?)(?![\.a-zA-Z])'), (m) => '${m.group(1)}: ${m.group(2)}.w');
        inner = inner.replaceAllMapped(RegExp(r'(top|bottom):\s*([0-9]+(?:\.[0-9]+)?)(?![\.a-zA-Z])'), (m) => '${m.group(1)}: ${m.group(2)}.h');
        needsImport = true;
        return 'EdgeInsets.only($inner)';
      });

      // Replace EdgeInsets.fromLTRB
      content = content.replaceAllMapped(RegExp(r'EdgeInsets\.fromLTRB\(\s*([0-9]+(?:\.[0-9]+)?)\s*,\s*([0-9]+(?:\.[0-9]+)?)\s*,\s*([0-9]+(?:\.[0-9]+)?)\s*,\s*([0-9]+(?:\.[0-9]+)?)\s*\)'), (match) {
        needsImport = true;
        return 'EdgeInsets.fromLTRB(${match.group(1)}.w, ${match.group(2)}.h, ${match.group(3)}.w, ${match.group(4)}.h)';
      });

      // Replace SizedBox(width: X) and SizedBox(height: X)
      content = content.replaceAllMapped(RegExp(r'SizedBox\(\s*width:\s*([0-9]+(?:\.[0-9]+)?)(?![\.a-zA-Z])\s*\)'), (match) {
        needsImport = true;
        return 'SizedBox(width: ${match.group(1)}.w)';
      });
      content = content.replaceAllMapped(RegExp(r'SizedBox\(\s*height:\s*([0-9]+(?:\.[0-9]+)?)(?![\.a-zA-Z])\s*\)'), (match) {
        needsImport = true;
        return 'SizedBox(height: ${match.group(1)}.h)';
      });
      content = content.replaceAllMapped(RegExp(r'SizedBox\(\s*width:\s*([0-9]+(?:\.[0-9]+)?)(?![\.a-zA-Z])\s*,\s*height:\s*([0-9]+(?:\.[0-9]+)?)(?![\.a-zA-Z])\s*\)'), (match) {
        needsImport = true;
        return 'SizedBox(width: ${match.group(1)}.w, height: ${match.group(2)}.h)';
      });

      // width: X and height: X in Container/etc. (Need to be careful not to replace double.infinity)
      content = content.replaceAllMapped(RegExp(r'(width|height):\s*([0-9]+(?:\.[0-9]+)?)(?![\.a-zA-Z])'), (match) {
        needsImport = true;
        String prop = match.group(1)!;
        String val = match.group(2)!;
        if (prop == 'width') return 'width: $val.w';
        return 'height: $val.h';
      });

      // Icon sizes
      content = content.replaceAllMapped(RegExp(r'size:\s*([0-9]+(?:\.[0-9]+)?)(?![\.a-zA-Z])'), (match) {
        needsImport = true;
        return 'size: ${match.group(1)}.sp';
      });

      if (content != originalContent) {
        if (needsImport && !content.contains("import 'package:flutter_screenutil/flutter_screenutil.dart';")) {
          // Insert after the last import
          int lastImportIdx = content.lastIndexOf("import '");
          if (lastImportIdx != -1) {
            int endOfLine = content.indexOf('\n', lastImportIdx);
            content = content.substring(0, endOfLine + 1) +
                "import 'package:flutter_screenutil/flutter_screenutil.dart';\n" +
                content.substring(endOfLine + 1);
          } else {
            content = "import 'package:flutter_screenutil/flutter_screenutil.dart';\n" + content;
          }
        }
        
        // Exclude specific files if necessary, like main.dart or app.dart, but those don't have these hardcoded numbers anyway usually.
        if (entity.path.endsWith('pdf_utils.dart')) {
          // don't touch pdf_utils because pdf package doesn't use screenutil
        } else {
            entity.writeAsStringSync(content);
            modifiedFiles++;
        }
      }
    }
  }

  print('Modified $modifiedFiles files.');
}

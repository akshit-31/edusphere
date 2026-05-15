import 'dart:io';

void main() {
  final file = File('analyze_output.txt');
  if (!file.existsSync()) {
    print('No analyze_output.txt');
    return;
  }
  
  final lines = file.readAsLinesSync();
  int fixes = 0;
  
  Map<String, List<int>> fileErrors = {};
  
  for (var line in lines) {
    if (line.contains('const_eval_extension_method') || 
        line.contains('const_with_non_constant_argument') ||
        line.contains('non_constant_list_element') ||
        line.contains('const_eval_throws_exception') ||
        line.contains('invalid_assignment') ||
        line.contains('undefined_getter') ||
        line.contains('non_constant_map_element') ||
        line.contains('const_initialized_with_non_constant_value') ||
        line.contains('const_eval_extension_method')) {
      
      final parts = line.split(' - ');
      if (parts.length >= 3) {
        final locParts = parts[1].split(':');
        if (locParts.length >= 2) {
          final filePath = locParts[0].trim();
          final lineNum = int.tryParse(locParts[1].trim());
          if (lineNum != null) {
            fileErrors.putIfAbsent(filePath, () => []).add(lineNum);
          }
        }
      }
    }
  }

  for (var entry in fileErrors.entries) {
    final filePath = entry.key;
    final errorLines = entry.value;
    
    final dartFile = File(filePath);
    if (!dartFile.existsSync()) continue;
    
    final fileLines = dartFile.readAsLinesSync();
    bool modified = false;
    
    for (int lineNum in errorLines) {
      if (lineNum > 0 && lineNum <= fileLines.length) {
        int idx = lineNum - 1;
        // Search backwards for the const keyword if not on this line
        int searchIdx = idx;
        bool foundConst = false;
        while (searchIdx >= 0 && searchIdx >= idx - 15) {
          if (fileLines[searchIdx].contains('const ')) {
            fileLines[searchIdx] = fileLines[searchIdx].replaceFirst('const ', '');
            modified = true;
            foundConst = true;
            break;
          }
          searchIdx--;
        }
        if (!foundConst) {
           // Maybe it's `const` at the end of the line before? or `const[`
           searchIdx = idx;
           while (searchIdx >= 0 && searchIdx >= idx - 15) {
              if (fileLines[searchIdx].contains('const')) {
                fileLines[searchIdx] = fileLines[searchIdx].replaceFirst('const', '');
                modified = true;
                break;
              }
              searchIdx--;
           }
        }
      }
    }
    
    if (modified) {
      dartFile.writeAsStringSync(fileLines.join('\n') + '\n');
      fixes++;
    }
  }
  
  print('Fixed const issues in $fixes files.');
}

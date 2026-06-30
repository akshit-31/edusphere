import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:file_saver/file_saver.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Platform implementation for Android, iOS, Windows, macOS, Linux.
Future<void> downloadFilePlatform(Uint8List bytes, String fileName, String extension) async {
  MimeType mime = MimeType.other;
  if (extension == 'xlsx') {
    mime = MimeType.microsoftExcel;
  } else if (extension == 'pdf') {
    mime = MimeType.pdf;
  } else if (extension == 'csv') {
    mime = MimeType.csv;
  }

  // Sanitize file name to avoid OS errors with spaces or special characters
  final String cleanName = fileName
      .replaceAll('.$extension', '')
      .replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');

  // Android Permissions Check
  if (Platform.isAndroid) {
    try {
      // For Android 10 and below, request WRITE_EXTERNAL_STORAGE/READ_EXTERNAL_STORAGE
      if (await Permission.storage.isDenied) {
        await Permission.storage.request();
      }
    } catch (e) {
      debugPrint('Error requesting storage permission: $e');
    }
  }

  String? savedPath;

  // Primary: Attempt saving via FileSaver (downloads/public folders)
  try {
    savedPath = await FileSaver.instance.saveFile(
      name: cleanName,
      bytes: bytes,
      fileExtension: extension,
      mimeType: mime,
    );
    debugPrint('FileSaver saved path: $savedPath');
  } catch (e) {
    debugPrint('FileSaver exception: $e. Attempting app-specific fallback...');
  }

  // Fallback: Write to app-specific external files or documents directory (always works without permissions)
  if (savedPath == null || savedPath.isEmpty) {
    try {
      Directory? dir;
      if (Platform.isAndroid) {
        dir = await getExternalStorageDirectory();
      }
      dir ??= await getApplicationDocumentsDirectory();

      final String fallbackPath = '${dir.path}/$cleanName.$extension';
      final File file = File(fallbackPath);
      await file.writeAsBytes(bytes, flush: true);
      savedPath = fallbackPath;
      debugPrint('✅ File saved successfully via fallback to: $savedPath');
    } catch (e) {
      debugPrint('❌ Fallback saving failed: $e');
    }
  }

  // Open the file using system intent/OpenFile
  if (savedPath != null && savedPath.isNotEmpty) {
    try {
      final result = await OpenFilex.open(savedPath);
      debugPrint('OpenFile result: ${result.type} - ${result.message}');
    } catch (e) {
      debugPrint('Error opening file: $e');
    }
  } else {
    debugPrint('❌ Failed to save file; cannot open.');
  }
}

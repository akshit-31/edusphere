import 'package:file_saver/file_saver.dart';

void main() {
  FileSaver.instance.saveAs(
    name: 'test',
    bytes: null,
    fileExtension: 'pdf',
    mimeType: MimeType.pdf,
  );
}


import 'package:file_picker/file_picker.dart';

Future<PlatformFile?> pickAnyDocument() async {
  final result = await FilePicker.platform.pickFiles(
    allowMultiple: true,
    type: FileType.any,
  );

  if (result == null) return null;

  return result.files.first;
}

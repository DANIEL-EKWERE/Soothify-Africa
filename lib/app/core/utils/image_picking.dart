import 'package:file_picker/file_picker.dart';

/// Where a portrait comes from — the two rows on the photo-source sheet
/// (`259:37567`).
enum ImageSource { camera, gallery }

/// Picks a portrait off the device and returns its path.
///
/// Through `file_picker`, which the application form already uses, rather
/// than adding a second plugin for the same job: it needs no runtime
/// permission on either platform, and one picker is one thing to keep
/// working.
///
/// Its image picker opens the photo library on both sources — the camera is
/// the one thing it cannot do. That is why the sheet's camera row ends up
/// here as well, and why it is worth revisiting if taking a photo in the app
/// becomes the point rather than having one.
Future<String?> pickImageFromDevice(ImageSource source) async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    // The caller uploads the file by path; reading every byte in first would
    // hold a photograph in memory for no reason.
    withData: false,
  );
  final file = result?.files.singleOrNull;
  if (file == null || file.path == null) return null;
  return file.path;
}

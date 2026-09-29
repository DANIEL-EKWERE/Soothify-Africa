import 'package:file_picker/file_picker.dart';

import '../../data/models/expert_application.dart';

/// Picks one document off the device.
///
/// A function rather than a class so a test can pass its own without
/// touching a platform channel — `FilePicker` has no test implementation.
typedef DocumentPicker = Future<AttachedDocument?> Function();

/// The real one: the system document picker, limited to what the expert
/// application asks for — "(PDF, JPG, or PNG)".
///
/// The *document* picker, not an image-library one: it needs no runtime
/// permission on either platform, and a certificate is usually a PDF anyway.
Future<AttachedDocument?> pickDocumentFromDevice() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
    // The form keeps a path and sends the file later; reading every byte into
    // memory here would hold a passport scan across three steps.
    withData: false,
  );
  final file = result?.files.singleOrNull;
  if (file == null || file.path == null) return null;
  return AttachedDocument(
    name: file.name,
    path: file.path!,
    bytes: file.size,
  );
}

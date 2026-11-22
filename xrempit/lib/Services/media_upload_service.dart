import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class MediaUploadService {
  final ImagePicker _picker = ImagePicker();

  /// Pick from camera or gallery/folder
  Future<({XFile file, Uint8List bytes})?> pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 80, // compresses large camera photos slightly
    );

    if (picked == null) return null;

    final bytes = await picked.readAsBytes();
    return (file: picked, bytes: bytes);
  }
}
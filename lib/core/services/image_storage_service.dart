import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Handles picking and persisting a profile photo.
/// On mobile, the picked image is copied into the app's own documents
/// directory and its file path stored. On web, since there's no durable
/// filesystem to write to, the image is stored as a base64 data URL
/// directly in the profile record — small (profile photos are compressed
/// on pick), but fully self-contained and works reliably.
class ImageStorageService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickAndStoreProfilePhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (picked == null) return null;

    if (kIsWeb) {
      final bytes = await picked.readAsBytes();
      final base64String = base64Encode(bytes);
      return 'data:image/jpeg;base64,$base64String';
    }

    final bytes = await picked.readAsBytes();
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = 'profile_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedFile = File('${appDir.path}/$fileName');
    await savedFile.writeAsBytes(bytes);

    return savedFile.path;
  }
}
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;

class StorageService {
  /// Compresses image locally before uploading to storage / local file storage reference
  Future<String> uploadReceiptImage(File imageFile, String userId, {bool isFirebaseAvailable = false}) async {
    // 1. Compress image to reduce storage usage and network latency
    final File compressedFile = await _compressImage(imageFile);

    if (isFirebaseAvailable) {
      final fileName = 'receipts/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child(fileName);
      final uploadTask = await ref.putFile(compressedFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } else {
      // Local fallback: returns local path location
      return compressedFile.path;
    }
  }

  static Future<File> _compressImage(File file) async {
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) return file;

    // Resize image to width 1080 (maintaining aspect ratio) to compress size
    final resized = img.copyResize(image, width: 1080);
    final compressedBytes = img.encodeJpg(resized, quality: 75);
    
    final tempPath = '${file.path}_compressed.jpg';
    final tempFile = File(tempPath);
    await tempFile.writeAsBytes(compressedBytes);
    return tempFile;
  }
}

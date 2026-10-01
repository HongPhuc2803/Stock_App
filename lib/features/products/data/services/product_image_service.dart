import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProductImageService {
  ProductImageService(this._storage, this._picker);

  final FirebaseStorage _storage;
  final ImagePicker _picker;

  Future<XFile?> pickImage() {
    return _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
    );
  }

  Future<String> upload({
    required XFile file,
    required String storeId,
    void Function(double progress)? onProgress,
  }) async {
    final bytes = await file.readAsBytes();
    if (bytes.length > 5 * 1024 * 1024) {
      throw ArgumentError('Ảnh sản phẩm không được vượt quá 5 MB.');
    }
    final extension = file.name.split('.').last.toLowerCase();
    if (!{'jpg', 'jpeg', 'png', 'webp'}.contains(extension)) {
      throw ArgumentError('Chỉ hỗ trợ ảnh JPG, PNG hoặc WEBP.');
    }

    final name = '${DateTime.now().microsecondsSinceEpoch}.$extension';
    final reference = _storage.ref('stores/$storeId/products/$name');
    final contentType =
        file.mimeType ??
        (extension == 'png'
            ? 'image/png'
            : extension == 'webp'
            ? 'image/webp'
            : 'image/jpeg');
    final task = reference.putData(
      bytes,
      SettableMetadata(contentType: contentType),
    );
    task.snapshotEvents.listen((snapshot) {
      if (snapshot.totalBytes > 0) {
        onProgress?.call(snapshot.bytesTransferred / snapshot.totalBytes);
      }
    });
    await task;
    return reference.getDownloadURL();
  }

  Future<void> deleteByUrl(String url) async {
    if (url.isEmpty) return;
    try {
      await _storage.refFromURL(url).delete();
    } on FirebaseException catch (error) {
      if (error.code != 'object-not-found') rethrow;
    }
  }
}

/*import 'dart:convert';
//import 'dart:html' as html;
import 'package:image_picker/image_picker.dart';

class LocalStorageService {
  final ImagePicker _picker = ImagePicker();
  static const String _storageKey = 'profile_picture';

  // Get profile picture from local storage
  String? getProfilePicture() {
    try {
      return html.window.localStorage[_storageKey];
    } catch (e) {
      return null;
    }
  }

  // Pick and save image
  Future<String?> pickAndSaveImage() async {
    try {
      // Pick image
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image == null) return null;

      // Read image as bytes
      final bytes = await image.readAsBytes();

      // Convert to base64
      final base64Image = base64Encode(bytes);
      final dataUrl = 'data:image/jpeg;base64,$base64Image';

      // Save to local storage
      html.window.localStorage[_storageKey] = dataUrl;

      return dataUrl;
    } catch (e) {
      throw 'Failed to save image: $e';
    }
  }

  // Delete profile picture
  void deleteProfilePicture() {
    try {
      html.window.localStorage.remove(_storageKey);
    } catch (e) {
      throw 'Failed to delete profile picture: $e';
    }
  }
}
*/

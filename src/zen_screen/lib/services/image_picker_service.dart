import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Image Picker Service
/// 
/// Handles image selection from gallery or camera.
/// 
/// **Product Learning Note:**
/// Always give users options - some prefer gallery, others prefer camera.
/// Handle permissions gracefully and provide clear error messages.
class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery
  Future<File?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85, // Compress to reduce upload size
      );

      if (image == null) return null;

      // For web, handle differently
      if (kIsWeb) {
        // Web doesn't use File, but we can return a File wrapper
        // that works with our upload service
        return File(image.path);
      }

      return File(image.path);
    } catch (e) {
      throw ImagePickerException('Failed to pick image from gallery: $e');
    }
  }

  /// Take photo with camera
  Future<File?> pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return null;

      if (kIsWeb) {
        return File(image.path);
      }

      return File(image.path);
    } catch (e) {
      throw ImagePickerException('Failed to take photo: $e');
    }
  }

  /// Show option dialog and pick image
  /// Returns null if user cancels
  Future<File?> pickImage({required ImageSource source}) async {
    if (source == ImageSource.gallery) {
      return pickFromGallery();
    } else {
      return pickFromCamera();
    }
  }
}

/// Custom exception for image picker errors
class ImagePickerException implements Exception {
  final String message;
  ImagePickerException(this.message);

  @override
  String toString() => message;
}


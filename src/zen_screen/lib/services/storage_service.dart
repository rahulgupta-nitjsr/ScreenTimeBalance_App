import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Storage Service
/// 
/// Handles file uploads to Firebase Storage.
/// 
/// **Product Learning Note:**
/// File uploads should:
/// 1. Show progress (users want to know it's working)
/// 2. Handle errors gracefully (network can fail)
/// 3. Be cancellable (users change their mind)
/// 4. Optimize file sizes (save bandwidth and storage)
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload avatar image for a user
  /// Returns the download URL
  Future<String> uploadAvatar({
    required String userId,
    required File imageFile,
    void Function(double progress)? onProgress,
  }) async {
    try {
      // Create reference to storage location
      final ref = _storage.ref().child('avatars/$userId.jpg');

      // Upload file
      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploadedBy': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Listen to progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw StorageException(_getErrorMessage(e));
    } catch (e) {
      throw StorageException('Failed to upload image: $e');
    }
  }

  /// Upload avatar for web (using bytes instead of File)
  Future<String> uploadAvatarBytes({
    required String userId,
    required Uint8List imageBytes,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final ref = _storage.ref().child('avatars/$userId.jpg');

      final uploadTask = ref.putData(
        imageBytes,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploadedBy': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw StorageException(_getErrorMessage(e));
    } catch (e) {
      throw StorageException('Failed to upload image: $e');
    }
  }

  /// Delete user's avatar
  Future<void> deleteAvatar(String userId) async {
    try {
      final ref = _storage.ref().child('avatars/$userId.jpg');
      await ref.delete();
    } on FirebaseException catch (e) {
      // Ignore if file doesn't exist
      if (e.code != 'object-not-found') {
        throw StorageException(_getErrorMessage(e));
      }
    } catch (e) {
      throw StorageException('Failed to delete avatar: $e');
    }
  }

  /// Get user-friendly error messages
  String _getErrorMessage(FirebaseException e) {
    switch (e.code) {
      case 'unauthorized':
        return 'You do not have permission to upload images';
      case 'canceled':
        return 'Upload was cancelled';
      case 'unknown':
        return 'An unknown error occurred';
      case 'object-not-found':
        return 'File not found';
      case 'quota-exceeded':
        return 'Storage quota exceeded';
      case 'unauthenticated':
        return 'Please sign in to upload images';
      default:
        return 'Upload failed: ${e.message ?? e.code}';
    }
  }
}

/// Custom exception for storage errors
class StorageException implements Exception {
  final String message;
  StorageException(this.message);

  @override
  String toString() => message;
}


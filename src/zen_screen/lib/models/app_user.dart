import 'package:firebase_auth/firebase_auth.dart' as firebase;

/// Lightweight representation of an authenticated user for app consumption.
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.emailVerified = false,
  });

  factory AppUser.fromFirebase(firebase.User user) {
    return AppUser(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      emailVerified: user.emailVerified,
    );
  }

  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool emailVerified;

  AppUser copyWith({
    String? displayName,
    String? photoUrl,
    bool? emailVerified,
  }) {
    return AppUser(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'emailVerified': emailVerified,
    };
  }
}


import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final DateTime? createdAt;
  final String? photoUrl;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.createdAt,
    this.photoUrl,
  });

  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      uid: user.uid,
      name: user.displayName ?? user.email?.split('@').first ?? 'User',
      email: user.email ?? '',
      createdAt: user.metadata.creationTime,
      photoUrl: user.photoURL,
    );
  }

  /// Returns initials for the avatar circle (up to 2 characters)
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }
}

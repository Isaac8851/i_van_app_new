import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String email;
  final String role;
  final String? routeId;
  final Timestamp createdAt;

  UserModel({
    required this.email,
    required this.role,
    this.routeId,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      email: data['email'] as String,
      role: data['role'] as String,
      routeId: data['routeId'] as String?,
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'role': role,
        if (routeId != null) 'routeId': routeId,
        'createdAt': createdAt,
      };
}

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String role;
  final String? routeId;
  final Timestamp createdAt;

  UserModel({
    required this.role,
    required this.routeId,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      role: data['role'] as String,
      routeId: data['routeId'] as String?,
      createdAt: data['createdAt'] as Timestamp,
    );
  }

  Map<String, dynamic> toMap() => {
    'role': role,
    'routeId': routeId,
    'createdAt': createdAt,
  };
}

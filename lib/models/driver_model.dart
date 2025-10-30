import 'package:cloud_firestore/cloud_firestore.dart';

class DriverModel {
  final bool isActive;
  final String? routeId;
  final String? currentVanId;
  final Timestamp lastUpdated;

  DriverModel({
    required this.isActive,
    this.routeId,
    this.currentVanId,
    required this.lastUpdated,
  });

  factory DriverModel.fromMap(Map<String, dynamic> data) {
    return DriverModel(
      isActive: data['isActive'] as bool? ?? false,
      routeId: data['routeId'] as String?,
      currentVanId: data['currentVanId'] as String?,
      lastUpdated: data['lastUpdated'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'isActive': isActive,
        if (routeId != null) 'routeId': routeId,
        if (currentVanId != null) 'currentVanId': currentVanId,
        'lastUpdated': lastUpdated,
      };
}

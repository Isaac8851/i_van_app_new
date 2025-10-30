import 'package:cloud_firestore/cloud_firestore.dart';

class VanModel {
  final String vanNumber;
  final int capacity;
  final String model;
  final VanLocation? location;

  VanModel({
    required this.vanNumber,
    required this.capacity,
    required this.model,
    this.location,
  });

  factory VanModel.fromMap(Map<String, dynamic> data) {
    return VanModel(
      vanNumber: data['vanNumber'] as String,
      capacity: data['capacity'] as int,
      model: data['model'] as String,
      location: data['location'] != null
          ? VanLocation.fromMap(data['location'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'vanNumber': vanNumber,
        'capacity': capacity,
        'model': model,
        if (location != null) 'location': location!.toMap(),
      };
}

class VanLocation {
  final double latitude;
  final double longitude;
  final Timestamp timestamp;

  VanLocation({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory VanLocation.fromMap(Map<String, dynamic> data) {
    return VanLocation(
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      timestamp: data['timestamp'] as Timestamp,
    );
  }

  Map<String, dynamic> toMap() => {
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': timestamp,
      };
}

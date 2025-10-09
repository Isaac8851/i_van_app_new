import 'package:cloud_firestore/cloud_firestore.dart';

class StopModel {
  final double lat;
  final double lng;
  final String? label;

  StopModel({required this.lat, required this.lng, this.label});

  factory StopModel.fromMap(Map<String, dynamic> data) {
    return StopModel(
      lat: (data['lat'] as num).toDouble(),
      lng: (data['lng'] as num).toDouble(),
      label: data['label'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'lat': lat,
    'lng': lng,
    if (label != null) 'label': label,
  };
}

class RouteModel {
  final String driverId;
  final List<String> studentIds;
  final List<StopModel> stops;
  final String status;

  RouteModel({
    required this.driverId,
    required this.studentIds,
    required this.stops,
    required this.status,
  });

  factory RouteModel.fromMap(Map<String, dynamic> data) {
    return RouteModel(
      driverId: data['driverId'] as String,
      studentIds: List<String>.from(data['studentIds'] ?? []),
      stops:
          (data['stops'] as List<dynamic>?)
              ?.map((e) => StopModel.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      status: data['status'] as String,
    );
  }

  Map<String, dynamic> toMap() => {
    'driverId': driverId,
    'studentIds': studentIds,
    'stops': stops.map((e) => e.toMap()).toList(),
    'status': status,
  };
}

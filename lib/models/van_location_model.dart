import 'package:cloud_firestore/cloud_firestore.dart';

class VanLocationModel {
  final double lat;
  final double lng;
  final Timestamp ts;

  VanLocationModel({required this.lat, required this.lng, required this.ts});

  factory VanLocationModel.fromMap(Map<String, dynamic> data) {
    return VanLocationModel(
      lat: (data['lat'] as num).toDouble(),
      lng: (data['lng'] as num).toDouble(),
      ts: data['ts'] as Timestamp,
    );
  }

  Map<String, dynamic> toMap() => {'lat': lat, 'lng': lng, 'ts': ts};
}

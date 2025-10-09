import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:math';

class DirectionsService {
  DateTime? _lastRequestTime;
  LatLng? _lastOrigin;
  Duration? _lastEta;

  // Throttle: only call if >30s or >50m moved
  Future<Duration?> getETA(LatLng origin, LatLng destination) async {
    final now = DateTime.now();
    if (_lastRequestTime != null &&
        now.difference(_lastRequestTime!) < const Duration(seconds: 30) &&
        _lastOrigin != null &&
        _distance(origin, _lastOrigin!) < 50) {
      return _lastEta;
    }
    // TODO: Call Google Directions API here
    // final eta = await ...
    // _lastEta = eta;
    // _lastRequestTime = now;
    // _lastOrigin = origin;
    // return eta;
    return null;
  }

  double _distance(LatLng a, LatLng b) {
    // Haversine formula for meters
    const R = 6371000;
    final dLat = (b.latitude - a.latitude) * pi / 180;
    final dLng = (b.longitude - a.longitude) * pi / 180;
    final lat1 = a.latitude * pi / 180;
    final lat2 = b.latitude * pi / 180;
    final aVal =
        (sin(dLat / 2) * sin(dLat / 2)) +
        cos(lat1) * cos(lat2) * (sin(dLng / 2) * sin(dLng / 2));
    final c = 2 * atan2(sqrt(aVal), sqrt(1 - aVal));
    return R * c;
  }
}

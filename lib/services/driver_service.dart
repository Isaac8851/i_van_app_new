import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/driver_model.dart';

class DriverService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get driver data
  Future<DriverModel?> getDriver(String driverId) async {
    final doc = await _firestore.collection('drivers').doc(driverId).get();
    if (!doc.exists || doc.data() == null) return null;
    return DriverModel.fromMap(doc.data()!);
  }

  // Stream driver data (real-time updates)
  Stream<DriverModel?> streamDriver(String driverId) {
    return _firestore.collection('drivers').doc(driverId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return DriverModel.fromMap(doc.data()!);
    });
  }

  // Update driver status
  Future<void> updateDriverStatus(
    String driverId, {
    required bool isActive,
    String? routeId,
    String? currentVanId,
  }) async {
    await _firestore.collection('drivers').doc(driverId).set({
      'isActive': isActive,
      if (routeId != null) 'routeId': routeId,
      if (currentVanId != null) 'currentVanId': currentVanId,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Start tracking (driver goes active)
  Future<void> startTracking(String driverId, String routeId, String vanId) async {
    await updateDriverStatus(
      driverId,
      isActive: true,
      routeId: routeId,
      currentVanId: vanId,
    );
  }

  // Stop tracking (driver goes inactive)
  Future<void> stopTracking(String driverId) async {
    await updateDriverStatus(
      driverId,
      isActive: false,
    );
  }
}

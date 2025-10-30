import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/van_model.dart';

class VanLocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Subscribe to van location updates for a specific van
  Stream<VanLocation?> subscribeToVanLocation(String vanId) {
    return _firestore.collection('vans').doc(vanId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      final data = snap.data()!;
      if (data['location'] == null) return null;
      return VanLocation.fromMap(data['location'] as Map<String, dynamic>);
    });
  }

  // Get full van details including location
  Stream<VanModel?> subscribeToVan(String vanId) {
    return _firestore.collection('vans').doc(vanId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return VanModel.fromMap(snap.data()!);
    });
  }

  // Update van location (for drivers)
  Future<void> updateVanLocation(
    String vanId,
    double latitude,
    double longitude,
  ) async {
    await _firestore.collection('vans').doc(vanId).set({
      'location': {
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': FieldValue.serverTimestamp(),
      }
    }, SetOptions(merge: true));
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Update driver location in Firestore
  Future<void> updateDriverLocation(String driverUid, Position position) async {
    await _firestore.collection('vans').doc(driverUid).set({
      'location': GeoPoint(position.latitude, position.longitude),
      'timestamp': FieldValue.serverTimestamp(),
      'lastUpdated': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  // Stream of driver location updates
  Stream<DocumentSnapshot> getDriverLocationStream(String driverUid) {
    return _firestore.collection('vans').doc(driverUid).snapshots();
  }

  // Get user role
  Future<String?> getUserRole(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data()?['role'] as String?;
  }

  // Set user role
  Future<void> setUserRole(String uid, String role) async {
    await _firestore.collection('users').doc(uid).set({
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Create a new trip in Firestore
  Future<void> createTrip(Map<String, dynamic> tripData) async {
    await _firestore.collection('trips').add(tripData);
  }

  // Update trip status in Firestore
  Future<void> updateTripStatus(String tripId, String status,
      {String? delayReason, int? estimatedDelayMinutes}) async {
    final updateData = {
      'status': status,
      if (delayReason != null) 'delayReason': delayReason,
      if (estimatedDelayMinutes != null)
        'estimatedDelay': estimatedDelayMinutes,
    };
    await _firestore.collection('trips').doc(tripId).update(updateData);
  }

  // Listen to a single trip document for real-time updates
  Stream<DocumentSnapshot<Map<String, dynamic>>> listenToTrip(String tripId) {
    return _firestore.collection('trips').doc(tripId).snapshots();
  }

  // Fetch all trips for a user (student or driver)
  Stream<QuerySnapshot<Map<String, dynamic>>> fetchTripsForUser(String userId,
      {String role = 'student'}) {
    if (role == 'driver') {
      return _firestore
          .collection('trips')
          .where('driverId', isEqualTo: userId)
          .snapshots();
    } else {
      return _firestore
          .collection('trips')
          .where('studentIds', arrayContains: userId)
          .snapshots();
    }
  }

  // Cancel a trip (set status to cancelled)
  Future<void> cancelTrip(String tripId) async {
    await _firestore
        .collection('trips')
        .doc(tripId)
        .update({'status': 'cancelled'});
  }
}

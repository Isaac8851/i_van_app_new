import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Update van location in Firestore (using correct structure)
  Future<void> updateVanLocation(String vanId, Position position) async {
    await _firestore.collection('vans').doc(vanId).set({
      'location': {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': FieldValue.serverTimestamp(),
      }
    }, SetOptions(merge: true));
  }

  // Stream of van location updates
  Stream<DocumentSnapshot> getVanLocationStream(String vanId) {
    return _firestore.collection('vans').doc(vanId).snapshots();
  }

  // Get user data
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }

  // Get user role
  Future<String?> getUserRole(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data()?['role'] as String?;
  }

  // Get user routeId
  Future<String?> getUserRouteId(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data()?['routeId'] as String?;
  }

  // Set user role
  Future<void> setUserRole(String uid, String role) async {
    await _firestore.collection('users').doc(uid).set({
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Update user routeId
  Future<void> updateUserRouteId(String uid, String? routeId) async {
    await _firestore.collection('users').doc(uid).update({
      'routeId': routeId,
    });
  }

  // Stream user data for real-time updates
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamUserData(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }
}

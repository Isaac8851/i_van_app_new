import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/route_model.dart';

class RouteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch a single route by ID
  Future<RouteModel?> fetchCurrentRoute(String routeId) async {
    final doc = await _firestore.collection('routes').doc(routeId).get();
    if (!doc.exists || doc.data() == null) return null;
    return RouteModel.fromMap(doc.data()!);
  }

  // Stream a single route by ID (real-time updates)
  Stream<RouteModel?> streamRoute(String routeId) {
    return _firestore.collection('routes').doc(routeId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return RouteModel.fromMap(doc.data()!);
    });
  }

  // Stream routes for a student by status
  Stream<List<RouteModel>> fetchRoutesByStatus(String uid, String status) {
    return _firestore
        .collection('routes')
        .where('studentIds', arrayContains: uid)
        .where('status', isEqualTo: status)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => RouteModel.fromMap(doc.data())).toList(),
        );
  }

  // Stream routes for a driver
  Stream<RouteModel?> streamDriverRoute(String driverId) {
    return _firestore
        .collection('routes')
        .where('driverId', isEqualTo: driverId)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;
      return RouteModel.fromMap(snap.docs.first.data());
    });
  }

  // Update route status
  Future<void> updateRouteStatus(String routeId, String status) async {
    await _firestore.collection('routes').doc(routeId).update({
      'status': status,
    });
  }

  // Start a route (driver)
  Future<void> startRoute(String routeId) async {
    await updateRouteStatus(routeId, 'active');
  }

  // Complete a route (driver)
  Future<void> completeRoute(String routeId) async {
    await updateRouteStatus(routeId, 'completed');
  }
}

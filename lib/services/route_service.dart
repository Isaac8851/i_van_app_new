import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/route_model.dart';

class RouteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<RouteModel?> fetchCurrentRoute(String routeId) async {
    final doc = await _firestore.collection('routes').doc(routeId).get();
    if (!doc.exists) return null;
    return RouteModel.fromMap(doc.data()!);
  }

  Stream<List<RouteModel>> fetchRoutesByStatus(String uid, String status) {
    // Query all routes where studentIds contains uid and status matches
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
}

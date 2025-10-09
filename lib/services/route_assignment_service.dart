import 'package:cloud_firestore/cloud_firestore.dart';

class RouteAssignmentService {
  static Future<void> cancelTrip(String uid, String routeId) async {
    final firestore = FirebaseFirestore.instance;
    final userRef = firestore.collection('users').doc(uid);
    final routeRef = firestore.collection('routes').doc(routeId);

    await firestore.runTransaction((tx) async {
      tx.update(routeRef, {
        'studentIds': FieldValue.arrayRemove([uid]),
      });
      tx.update(userRef, {'routeId': null});
    });
  }
}

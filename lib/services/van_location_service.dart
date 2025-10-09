import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/van_location_model.dart';

class VanLocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<VanLocationModel?> subscribeToDriver(String driverId) {
    return _firestore
        .collection('vans')
        .doc(driverId)
        .collection('location')
        .orderBy('ts', descending: true)
        .limit(1)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.isNotEmpty
                  ? VanLocationModel.fromMap(snap.docs.first.data())
                  : null,
        );
  }
}

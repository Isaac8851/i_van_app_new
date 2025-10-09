import 'package:cloud_firestore/cloud_firestore.dart';

enum TripStatus {
  scheduled,
  onRoute,
  inProgress,
  completed,
  cancelled,
  delayed
}

class Trip {
  final String id;
  final String driverId;
  final DateTime pickupTime;
  final String pickupLocation;
  final String dropoffLocation;
  final String driverName;
  final String driverPhone;
  final TripStatus status;
  final String? delayReason;
  final Duration? estimatedDelay;
  final bool isHistory;

  Trip({
    required this.id,
    required this.driverId,
    required this.pickupTime,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.driverName,
    required this.driverPhone,
    required this.status,
    this.delayReason,
    this.estimatedDelay,
    this.isHistory = false,
  });

  factory Trip.fromMap(Map<String, dynamic> map, String id) {
    return Trip(
      id: id,
      driverId: map['driverId'] ?? '',
      pickupTime: (map['pickupTime'] as Timestamp).toDate(),
      pickupLocation: map['pickupLocation'] ?? '',
      dropoffLocation: map['dropoffLocation'] ?? '',
      driverName: map['driverName'] ?? '',
      driverPhone: map['driverPhone'] ?? '',
      status: TripStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (map['status'] ?? 'scheduled'),
        orElse: () => TripStatus.scheduled,
      ),
      delayReason: map['delayReason'],
      estimatedDelay: map['estimatedDelay'] != null
          ? Duration(minutes: map['estimatedDelay'])
          : null,
      isHistory: map['isHistory'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'driverId': driverId,
      'pickupTime': pickupTime,
      'pickupLocation': pickupLocation,
      'dropoffLocation': dropoffLocation,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'status': status.toString().split('.').last,
      if (delayReason != null) 'delayReason': delayReason,
      if (estimatedDelay != null) 'estimatedDelay': estimatedDelay!.inMinutes,
      'isHistory': isHistory,
    };
  }
}

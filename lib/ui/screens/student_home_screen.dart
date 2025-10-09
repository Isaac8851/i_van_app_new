import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../models/route_model.dart';
import '../../models/van_location_model.dart';
import '../../services/route_service.dart';
import '../../services/van_location_service.dart';
import '../../services/directions_service.dart';
import '../../services/route_assignment_service.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  bool _loading = true;
  String? _error;
  UserModel? _user;
  RouteModel? _route;
  VanLocationModel? _driverLocation;
  Duration? _eta;
  late final RouteService _routeService;
  late final VanLocationService _vanLocationService;
  late final DirectionsService _directionsService;
  Stream<VanLocationModel?>? _driverLocationStream;
  Stream<List<LatLng>>? _polylineStream;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _routeService = RouteService();
    _vanLocationService = VanLocationService();
    _directionsService = DirectionsService();
    _initData();
  }

  Future<void> _initData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not signed in');
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      if (!userDoc.exists) throw Exception('User profile not found');
      _user = UserModel.fromMap(userDoc.data()!);
      if (_user!.routeId == null) {
        setState(() {
          _route = null;
          _loading = false;
        });
        return;
      }
      final route = await _routeService.fetchCurrentRoute(_user!.routeId!);
      if (route == null) throw Exception('Route not found');
      _route = route;
      // Subscribe to driver location
      _driverLocationStream = _vanLocationService.subscribeToDriver(
        route.driverId,
      );
      _driverLocationStream!.listen((location) async {
        if (location != null && _route != null) {
          setState(() {
            _driverLocation = location;
          });
          // Calculate ETA to student's stop (first stop for now)
          final nextStop = _route!.stops.isNotEmpty ? _route!.stops[0] : null;
          if (nextStop != null) {
            final eta = await _directionsService.getETA(
              LatLng(location.lat, location.lng),
              LatLng(nextStop.lat, nextStop.lng),
            );
            setState(() {
              _eta = eta;
            });
          }
        }
      });
      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _cancelTrip() async {
    if (_user == null || _route == null) return;
    setState(() => _loading = true);
    try {
      await RouteAssignmentService.cancelTrip(
        FirebaseAuth.instance.currentUser!.uid,
        _route!.driverId,
      );
      setState(() {
        _route = null;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error: ${_error!}'));
    }
    if (_route == null) {
      return Scaffold(
        body: const Center(child: Text('No active trip assigned.')),
      );
    }
    // Build map markers and polyline
    final List<LatLng> polylinePoints =
        _route!.stops.map((s) => LatLng(s.lat, s.lng)).toList();
    final Set<Marker> markers = {
      // Student stop marker (first stop)
      if (_route!.stops.isNotEmpty)
        Marker(
          markerId: const MarkerId('student_stop'),
          position: LatLng(_route!.stops[0].lat, _route!.stops[0].lng),
          infoWindow: const InfoWindow(title: 'Your Stop'),
        ),
      // Driver marker
      if (_driverLocation != null)
        Marker(
          markerId: const MarkerId('driver'),
          position: LatLng(_driverLocation!.lat, _driverLocation!.lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Driver'),
        ),
    };
    final Set<Polyline> polylines = {
      if (polylinePoints.length > 1)
        Polyline(
          polylineId: const PolylineId('route_polyline'),
          points: polylinePoints,
          color: Colors.blue,
          width: 5,
        ),
    };
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target:
                  polylinePoints.isNotEmpty
                      ? polylinePoints[0]
                      : const LatLng(35.91, 14.5),
              zoom: 12,
            ),
            markers: markers,
            polylines: polylines,
            onMapCreated: (controller) => _mapController = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          Positioned(bottom: 180, left: 16, child: ETAWidget(eta: _eta)),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            label: const Text('Cancel Trip'),
            icon: const Icon(Icons.cancel),
            onPressed: _cancelTrip,
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            label: const Text('Previous'),
            icon: const Icon(Icons.history),
            onPressed: () {
              // TODO: Navigator.pushNamed(context, '/previousRoutes')
            },
          ),
        ],
      ),
    );
  }
}

class ETAWidget extends StatelessWidget {
  final Duration? eta;
  const ETAWidget({this.eta, super.key});
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          eta != null ? 'ETA: ${eta!.inMinutes} min' : 'ETA: -- min',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

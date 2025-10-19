import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../../widgets/student_list.dart';
import 'driver_settings_screen.dart';
import '../../../services/driver_service.dart';
import '../../../services/route_service.dart';
import '../../../services/van_location_service.dart';
import '../../../models/route_model.dart';
import '../../../models/driver_model.dart';

class DriverMainScreen extends StatefulWidget {
  const DriverMainScreen({super.key});

  @override
  State<DriverMainScreen> createState() => _DriverMainScreenState();
}

class _DriverMainScreenState extends State<DriverMainScreen> {
  GoogleMapController? _mapController;
  bool _isTracking = false;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _selectedIndex = 0;
  
  final DriverService _driverService = DriverService();
  final RouteService _routeService = RouteService();
  final VanLocationService _vanLocationService = VanLocationService();
  
  StreamSubscription<Position>? _positionStreamSubscription;
  String? _currentVanId;
  String? _currentRouteId;

  late final List<Widget> _screens = [
    _buildMapScreen(),
    const StudentList(),
    const DriverSettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadDriverData();
  }

  Future<void> _loadDriverData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final driverDoc = await _firestore.collection('drivers').doc(uid).get();
    if (driverDoc.exists && driverDoc.data() != null) {
      final data = driverDoc.data()!;
      setState(() {
        _currentVanId = data['currentVanId'] as String?;
        _currentRouteId = data['routeId'] as String?;
      });
    }
  }

  void _updateRouteMarkers(RouteModel route) {
    final newMarkers = <Marker>{};
    
    // Add stop markers
    for (int i = 0; i < route.stops.length; i++) {
      final stop = route.stops[i];
      newMarkers.add(
        Marker(
          markerId: MarkerId('stop_$i'),
          position: LatLng(stop.lat, stop.lng),
          infoWindow: InfoWindow(
            title: stop.label ?? 'Stop ${i + 1}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            stop.label?.toLowerCase().contains('pickup') == true
                ? BitmapDescriptor.hueGreen
                : BitmapDescriptor.hueRed,
          ),
        ),
      );
    }
    
    // Add current position marker
    if (_currentPosition != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('my_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          infoWindow: const InfoWindow(title: 'My Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }
    
    setState(() {
      _markers = newMarkers;
    });
    
    // Create polyline
    if (route.stops.length >= 2) {
      final polylineCoordinates = route.stops.map((stop) => LatLng(stop.lat, stop.lng)).toList();
      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: polylineCoordinates,
            color: Colors.blue,
            width: 4,
          ),
        };
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
      _updateMapCamera();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not get current location')),
      );
    }
  }

  void _updateMapCamera() {
    if (_mapController != null && _currentPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        ),
      );
    }
  }

  Future<void> _startTracking() async {
    if (_currentVanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No van assigned to this driver')),
      );
      return;
    }

    setState(() => _isTracking = true);
    
    // Update driver status
    await _driverService.updateDriverStatus(
      _auth.currentUser!.uid,
      isActive: true,
      routeId: _currentRouteId,
      currentVanId: _currentVanId,
    );
    
    // Update initial location
    if (_currentPosition != null) {
      await _vanLocationService.updateVanLocation(
        _currentVanId!,
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
    }
    
    // Start location stream
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((position) async {
      setState(() => _currentPosition = position);
      
      // Update van location in Firestore
      if (_currentVanId != null) {
        await _vanLocationService.updateVanLocation(
          _currentVanId!,
          position.latitude,
          position.longitude,
        );
      }
      
      _updateMapCamera();
    });
  }

  Future<void> _stopTracking() async {
    setState(() => _isTracking = false);
    
    // Cancel location stream
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    
    try {
      await _driverService.stopTracking(_auth.currentUser!.uid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tracking stopped')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to stop tracking: $e')),
        );
      }
    }
  }

  Widget _buildMapScreen() {
    if (_currentPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return const Center(child: Text('Not authenticated'));
    }

    return StreamBuilder<RouteModel?>(
      stream: _routeService.streamDriverRoute(uid),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final route = snapshot.data!;
          
          // Update markers when route data changes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateRouteMarkers(route);
          });
        }

        return GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            ),
            zoom: 15,
          ),
          onMapCreated: (controller) => _mapController = controller,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          markers: _markers,
          polylines: _polylines,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Dashboard'),
        actions: [
          IconButton(
            icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
            onPressed: _isTracking ? _stopTracking : _startTracking,
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Students'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _getCurrentLocation,
              child: const Icon(Icons.my_location),
            )
          : null,
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _positionStreamSubscription?.cancel();
    super.dispose();
  }
}

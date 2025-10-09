import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/student_list.dart';
import 'driver_settings_screen.dart';

class DriverMainScreen extends StatefulWidget {
  const DriverMainScreen({super.key});

  @override
  State<DriverMainScreen> createState() => _DriverMainScreenState();
}

class _DriverMainScreenState extends State<DriverMainScreen> {
  GoogleMapController? _mapController;
  bool _isTracking = false;
  Position? _currentPosition;
  final Set<Marker> _markers = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _selectedIndex = 0;

  late final List<Widget> _screens = [
    _buildMapScreen(),
    const StudentList(),
    const DriverSettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _setupStudentMarkers();
  }

  Future<void> _setupStudentMarkers() async {
    final students = await _firestore
        .collection('students')
        .where('driverId', isEqualTo: _auth.currentUser!.uid)
        .get();

    for (var student in students.docs) {
      final data = student.data();
      if (data['location'] != null) {
        setState(() {
          _markers.add(
            Marker(
              markerId: MarkerId(student.id),
              position: LatLng(
                data['location'].latitude,
                data['location'].longitude,
              ),
              infoWindow: InfoWindow(
                title: data['name'],
                snippet: 'Student Location',
              ),
            ),
          );
        });
      }
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
    setState(() => _isTracking = true);
    await _updateLocationInFirestore();
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen((position) async {
      setState(() => _currentPosition = position);
      await _updateLocationInFirestore();
      _updateMapCamera();
    });
  }

  Future<void> _stopTracking() async {
    setState(() => _isTracking = false);
    try {
      await _firestore.collection('drivers').doc(_auth.currentUser!.uid).set({
        'isActive': false,
      }, SetOptions(merge: true));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update driver status: $e')),
      );
    }
  }

  Future<void> _updateLocationInFirestore() async {
    if (_currentPosition != null) {
      await _firestore.collection('drivers').doc(_auth.currentUser!.uid).set({
        'location': GeoPoint(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        ),
        'isActive': true,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Widget _buildMapScreen() {
    return _currentPosition == null
        ? const Center(child: CircularProgressIndicator())
        : GoogleMap(
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
    super.dispose();
  }
}

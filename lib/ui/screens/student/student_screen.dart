import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/route_service.dart';
import '../../../services/van_location_service.dart';
import '../../../services/route_assignment_service.dart';
import '../../../models/route_model.dart';
import '../../../models/van_model.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  GoogleMapController? _mapController;
  final LatLng _center = const LatLng(37.7749, -122.4194);
  
  final RouteService _routeService = RouteService();
  final VanLocationService _vanLocationService = VanLocationService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  String? _userRouteId;
  RouteModel? _currentRoute;
  VanLocation? _driverLocation;

  @override
  void initState() {
    super.initState();
    _loadUserRoute();
  }

  Future<void> _loadUserRoute() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await _firestore.collection('users').doc(uid).get();
    final routeId = userDoc.data()?['routeId'] as String?;
    
    if (routeId != null) {
      setState(() {
        _userRouteId = routeId;
      });
    }
  }

  void _updateMapMarkers(RouteModel route, VanLocation? vanLocation) {
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
    
    // Add driver location marker
    if (vanLocation != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: LatLng(vanLocation.latitude, vanLocation.longitude),
          infoWindow: const InfoWindow(title: 'Driver Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }
    
    setState(() {
      _markers = newMarkers;
    });
    
    // Update camera to show all markers
    if (_mapController != null && route.stops.isNotEmpty) {
      _fitMapToMarkers(route.stops, vanLocation);
    }
  }

  void _fitMapToMarkers(List<StopModel> stops, VanLocation? vanLocation) {
    if (stops.isEmpty) return;
    
    double minLat = stops.first.lat;
    double maxLat = stops.first.lat;
    double minLng = stops.first.lng;
    double maxLng = stops.first.lng;
    
    for (final stop in stops) {
      if (stop.lat < minLat) minLat = stop.lat;
      if (stop.lat > maxLat) maxLat = stop.lat;
      if (stop.lng < minLng) minLng = stop.lng;
      if (stop.lng > maxLng) maxLng = stop.lng;
    }
    
    if (vanLocation != null) {
      if (vanLocation.latitude < minLat) minLat = vanLocation.latitude;
      if (vanLocation.latitude > maxLat) maxLat = vanLocation.latitude;
      if (vanLocation.longitude < minLng) minLng = vanLocation.longitude;
      if (vanLocation.longitude > maxLng) maxLng = vanLocation.longitude;
    }
    
    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        50,
      ),
    );
  }

  void _createPolyline(List<StopModel> stops) {
    if (stops.length < 2) return;
    
    final polylineCoordinates = stops.map((stop) => LatLng(stop.lat, stop.lng)).toList();
    
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

  Future<void> _cancelTrip() async {
    if (_userRouteId == null) return;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Trip'),
        content: const Text('Are you sure you want to cancel this trip?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        await RouteAssignmentService.cancelTrip(
          _auth.currentUser!.uid,
          _userRouteId!,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Trip cancelled successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to cancel trip: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userRouteId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Trip'),
          centerTitle: true,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No active trip assigned',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trip'),
        centerTitle: true,
      ),
      body: StreamBuilder<RouteModel?>(
        stream: _routeService.streamRoute(_userRouteId!),
        builder: (context, routeSnapshot) {
          if (routeSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!routeSnapshot.hasData || routeSnapshot.data == null) {
            return const Center(
              child: Text('Route not found'),
            );
          }

          final route = routeSnapshot.data!;
          _currentRoute = route;

          // Create polyline from stops
          if (route.stops.isNotEmpty) {
            _createPolyline(route.stops);
          }

          // Get driver's van ID to track location
          return FutureBuilder<DocumentSnapshot>(
            future: _firestore.collection('drivers').doc(route.driverId).get(),
            builder: (context, driverSnapshot) {
              String? vanId;
              if (driverSnapshot.hasData && driverSnapshot.data?.data() != null) {
                final driverData = driverSnapshot.data!.data() as Map<String, dynamic>;
                vanId = driverData['currentVanId'] as String?;
              }

              return StreamBuilder<VanLocation?>(
                stream: vanId != null
                    ? _vanLocationService.subscribeToVanLocation(vanId)
                    : Stream.value(null),
                builder: (context, vanSnapshot) {
                  final vanLocation = vanSnapshot.data;
                  _driverLocation = vanLocation;

                  // Update markers when data changes
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _updateMapMarkers(route, vanLocation);
                  });

                  return Column(
                    children: [
                      // Map Section
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: GoogleMap(
                              onMapCreated: (GoogleMapController controller) {
                                _mapController = controller;
                                if (route.stops.isNotEmpty) {
                                  _fitMapToMarkers(route.stops, vanLocation);
                                }
                              },
                              initialCameraPosition: CameraPosition(
                                target: route.stops.isNotEmpty
                                    ? LatLng(route.stops.first.lat, route.stops.first.lng)
                                    : _center,
                                zoom: 15.0,
                              ),
                              markers: _markers,
                              polylines: _polylines,
                            ),
                          ),
                        ),
                      ),

                      // Trip Info Card
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: route.status == 'active'
                                        ? Colors.green.shade100
                                        : Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    route.status == 'active'
                                        ? Icons.check_circle
                                        : Icons.schedule,
                                    color: route.status == 'active'
                                        ? Colors.green.shade700
                                        : Colors.orange.shade700,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Trip Status: ${route.status.toUpperCase()}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        vanLocation != null
                                            ? 'Driver location updated'
                                            : 'Waiting for driver',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            if (route.stops.isNotEmpty) ...[
                              _buildInfoRow(
                                Icons.location_on,
                                'Pickup',
                                route.stops.firstWhere(
                                  (s) => s.label?.toLowerCase().contains('pickup') ?? false,
                                  orElse: () => route.stops.first,
                                ).label ?? 'First Stop',
                              ),
                              _buildInfoRow(
                                Icons.school,
                                'Destination',
                                route.stops.lastWhere(
                                  (s) => s.label?.toLowerCase().contains('drop') ?? false,
                                  orElse: () => route.stops.last,
                                ).label ?? 'Last Stop',
                              ),
                            ],
                            _buildInfoRow(
                              Icons.people,
                              'Students',
                              '${route.studentIds.length}',
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _cancelTrip,
                                    icon: const Icon(Icons.cancel_outlined),
                                    label: const Text('Cancel Trip'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Chat feature coming soon')),
                                      );
                                    },
                                    icon: const Icon(Icons.chat_bubble_outline),
                                    label: const Text('Chat Driver'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_mapController != null) {
            _mapController!.animateCamera(
              CameraUpdate.newLatLng(_center),
            );
          }
        },
        child: const Icon(Icons.my_location),
        tooltip: 'My Location',
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

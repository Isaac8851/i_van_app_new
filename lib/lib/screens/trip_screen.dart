import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../models/user.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' show min, max;
import 'dart:ui' as ui;
import 'previous_trips_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/location_service.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'messages_screen.dart';

class TripScreen extends StatefulWidget {
  const TripScreen({super.key});

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final bool _showHistory = false;
  GoogleMapController? _mapController;
  final LocationService _locationService = LocationService();
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  bool _isTracking = false;
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription<Position>? _locationSubscription;
  StreamSubscription<DocumentSnapshot>? _driverLocationSubscription;
  String? _currentUserId;
  String? _userRole;
  Position? _currentPosition;
  BitmapDescriptor? _vanIcon;

  // Default locations for school transport
  static const String _defaultHomeLocation = 'Msida';
  static const String _defaultSchoolLocation = 'University of Malta';
  static const String _defaultDriverName = 'John Smith';
  static const String _defaultDriverPhone = '+356 9999 8888';

  // Default coordinates for locations
  static const LatLng _msidaLocation = LatLng(
    35.8956,
    14.4889,
  ); // Msida coordinates
  static const LatLng _universityLocation = LatLng(
    35.9023,
    14.4846,
  ); // University coordinates

  // Sample route coordinates (simplified route from Msida to University)
  final List<LatLng> _routePoints = [
    const LatLng(35.8956, 14.4889), // Msida
    const LatLng(35.8967, 14.4876), // Via some main road
    const LatLng(35.8989, 14.4867), // Through another junction
    const LatLng(35.9001, 14.4856), // Near university area
    const LatLng(35.9023, 14.4846), // University
  ];

  // Simulated current driver location (for demo)
  final LatLng _driverLocation = const LatLng(
    35.8989,
    14.4867,
  ); // Somewhere along the route

  Trip _createSchoolTrip({
    required String id,
    required DateTime pickupTime,
    required bool isMorningTrip,
    required TripStatus status,
    String? delayReason,
    Duration? estimatedDelay,
    bool isHistory = false,
  }) {
    return Trip(
      id: id,
      driverId: _currentUserId ?? '',
      pickupTime: pickupTime,
      // For morning trips: pickup from home, dropoff at school
      // For afternoon trips: pickup from school, dropoff at home
      pickupLocation:
          isMorningTrip ? _defaultHomeLocation : _defaultSchoolLocation,
      dropoffLocation:
          isMorningTrip ? _defaultSchoolLocation : _defaultHomeLocation,
      driverName: _defaultDriverName,
      driverPhone: _defaultDriverPhone,
      status: status,
      delayReason: delayReason,
      estimatedDelay: estimatedDelay,
      isHistory: isHistory,
    );
  }

  List<Trip> get _activeTrips =>
      _trips.where((trip) => !trip.isHistory).toList();
  List<Trip> get _historyTrips =>
      _trips.where((trip) => trip.isHistory).toList();

  // Remove the hardcoded _trips list and add a dynamic list
  List<Trip> _trips = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _tripsSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _createVanMarker();
    _initializeUser();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _driverLocationSubscription?.cancel();
    _tripsSubscription?.cancel();
    _mapController?.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeUser() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      _currentUserId = _authService.currentUserId;
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      _userRole = await _firestoreService.getUserRole(_currentUserId!);
      if (_userRole == null) {
        throw Exception('User role not found');
      }

      // Listen to trips for this user
      _tripsSubscription = _firestoreService
          .fetchTripsForUser(_currentUserId!, role: _userRole!)
          .listen((snapshot) {
        setState(() {
          _trips = snapshot.docs
              .map((doc) => Trip.fromMap(doc.data(), doc.id))
              .toList();
        });
      }, onError: (error) {
        setState(() {
          _errorMessage = 'Trips error: $error';
        });
      });

      if (_userRole == 'driver') {
        await _startLocationTracking();
      } else if (_userRole == 'student') {
        await _listenToDriverLocation();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $_errorMessage')));
    }
  }

  Future<void> _startLocationTracking() async {
    try {
      final position = await _locationService.getCurrentLocation();
      setState(() {
        _currentPosition = position;
      });

      _locationSubscription = _locationService.getLocationStream().listen(
        (Position position) {
          if (_currentUserId != null) {
            _firestoreService.updateDriverLocation(_currentUserId!, position);
            setState(() {
              _currentPosition = position;
            });
          }
        },
        onError: (error) {
          setState(() {
            _errorMessage = 'Location tracking error: $error';
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Location error: $error')));
        },
      );

      setState(() {
        _isTracking = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to start location tracking: $e';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Location tracking error: $e')));
    }
  }

  Future<void> _listenToDriverLocation() async {
    try {
      // Get the driver ID from the current trip
      final currentTrip = _activeTrips.firstWhere(
        (trip) => trip.status == TripStatus.onRoute,
        orElse: () => _trips.first,
      );
      final driverId = currentTrip.driverId.isNotEmpty
          ? currentTrip.driverId
          : currentTrip.driverName;
      _driverLocationSubscription =
          _firestoreService.getDriverLocationStream(driverId).listen(
        (DocumentSnapshot snapshot) {
          if (snapshot.exists) {
            final data = snapshot.data() as Map<String, dynamic>;
            final location = data['location'] as GeoPoint;
            setState(() {
              _currentPosition = Position(
                latitude: location.latitude,
                longitude: location.longitude,
                timestamp: DateTime.now(),
                accuracy: 0,
                altitude: 0,
                heading: 0,
                speed: 0,
                speedAccuracy: 0,
                altitudeAccuracy: 0,
                headingAccuracy: 0,
              );
            });
          }
        },
        onError: (error) {
          setState(() {
            _errorMessage = 'Driver location error: $error';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Driver location error: $error')),
          );
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to listen to driver location: $e';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Driver location error: $e')));
    }
  }

  Future<void> _createVanMarker() async {
    const IconData arrowIcon = Icons.navigation;
    const double size = 70;

    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    const center = Offset(size / 1.5, size / 1.5);

    // Save the canvas state
    canvas.save();
    // Translate to center, rotate, translate back
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-90 * 3.14159 / 180); // Rotate -90 degrees to point right
    canvas.translate(-center.dx, -center.dy);

    TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(arrowIcon.codePoint),
      style: TextStyle(
        fontSize: size,
        fontFamily: arrowIcon.fontFamily,
        color: Colors.blue,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset.zero);

    // Restore the canvas state
    canvas.restore();

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    if (bytes != null) {
      setState(() {
        _vanIcon = BitmapDescriptor.fromBytes(bytes.buffer.asUint8List());
      });
    }
  }

  Set<Marker> _createMarkers(Trip trip) {
    final Set<Marker> markers = {};

    // Add pickup marker
    markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: trip.pickupLocation == _defaultHomeLocation
            ? _msidaLocation
            : _universityLocation,
        infoWindow: InfoWindow(title: 'Pickup: ${trip.pickupLocation}'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    // Add dropoff marker
    markers.add(
      Marker(
        markerId: const MarkerId('dropoff'),
        position: trip.dropoffLocation == _defaultHomeLocation
            ? _msidaLocation
            : _universityLocation,
        infoWindow: InfoWindow(title: 'Dropoff: ${trip.dropoffLocation}'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    // Add driver marker for active trips
    if (trip.status == TripStatus.onRoute && _vanIcon != null) {
      LatLng driverPosition;
      if (_userRole == 'student' && _currentPosition != null) {
        driverPosition =
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
      } else {
        driverPosition = _driverLocation;
      }
      markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: driverPosition,
          icon: _vanIcon!,
          infoWindow: InfoWindow(title: 'Driver: ${trip.driverName}'),
        ),
      );
    }

    return markers;
  }

  Set<Polyline> _createRoute() {
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: _routePoints,
        color: Colors.blue,
        width: 5,
      ),
    };
  }

  Widget _buildMap(Trip trip) {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _msidaLocation,
              zoom: 14,
            ),
            markers: _createMarkers(trip),
            polylines: _createRoute(),
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            mapToolbarEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              if (!mounted) return;
              setState(() {
                _mapController = controller;
              });
              // Fit the map to show the entire route
              controller.animateCamera(
                CameraUpdate.newLatLngBounds(
                  LatLngBounds(
                    southwest: LatLng(
                      _routePoints.map((p) => p.latitude).reduce(min),
                      _routePoints.map((p) => p.longitude).reduce(min),
                    ),
                    northeast: LatLng(
                      _routePoints.map((p) => p.latitude).reduce(max),
                      _routePoints.map((p) => p.longitude).reduce(max),
                    ),
                  ),
                  50, // padding
                ),
              );
            },
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'zoomIn',
                  onPressed: () {
                    _mapController?.animateCamera(CameraUpdate.zoomIn());
                  },
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoomOut',
                  onPressed: () {
                    _mapController?.animateCamera(CameraUpdate.zoomOut());
                  },
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(Trip trip) {
    Color statusColor;
    String statusText;

    switch (trip.status) {
      case TripStatus.scheduled:
        statusColor = Colors.blue;
        statusText = 'Scheduled';
        break;
      case TripStatus.onRoute:
        statusColor = Colors.green;
        statusText = 'On Route';
        break;
      case TripStatus.inProgress:
        statusColor = Colors.green;
        statusText = 'In Progress';
        break;
      case TripStatus.completed:
        statusColor = Colors.grey;
        statusText = 'Completed';
        break;
      case TripStatus.cancelled:
        statusColor = Colors.red;
        statusText = 'Cancelled';
        break;
      case TripStatus.delayed:
        statusColor = Colors.orange;
        statusText = 'Delayed';
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trip ${trip.id}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.access_time, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black),
                      children: [
                        const TextSpan(
                          text: 'Pickup Time: ',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text:
                              '${trip.pickupTime.hour}:${trip.pickupTime.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black),
                      children: [
                        const TextSpan(
                          text: 'Pickup: ',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: trip.pickupLocation,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_off, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black),
                      children: [
                        const TextSpan(
                          text: 'Dropoff: ',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: trip.dropoffLocation,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black),
                      children: [
                        const TextSpan(
                          text: 'Driver: ',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: trip.driverName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (trip.status == TripStatus.delayed ||
                (trip.status == TripStatus.onRoute &&
                    trip.delayReason != null)) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.warning, size: 20, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black),
                        children: [
                          const TextSpan(
                            text: 'Delay Info: ',
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: trip.delayReason!,
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (_userRole == 'driver' && !trip.isHistory) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (trip.status == TripStatus.scheduled)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start Trip'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        await _firestoreService.updateTripStatus(
                            trip.id, 'onRoute');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Trip started.')),
                        );
                      },
                    ),
                  if (trip.status == TripStatus.onRoute)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.stop),
                      label: const Text('End Trip'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        await _firestoreService.updateTripStatus(
                            trip.id, 'completed');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Trip completed.')),
                        );
                      },
                    ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (!trip.isHistory &&
                    (trip.status == TripStatus.scheduled ||
                        trip.status == TripStatus.onRoute) &&
                    trip.pickupTime.year == DateTime.now().year &&
                    trip.pickupTime.month == DateTime.now().month &&
                    trip.pickupTime.day == DateTime.now().day)
                  Expanded(
                    child: _buildActionButton(
                      Icons.phone,
                      'Call Driver',
                      () async {
                        final Uri phoneUri = Uri(
                          scheme: 'tel',
                          path: trip.driverPhone,
                        );
                        if (await canLaunchUrl(phoneUri)) {
                          await launchUrl(phoneUri);
                        }
                      },
                    ),
                  ),
                Expanded(
                  child: _buildActionButton(Icons.message, 'Message', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MessagesScreen(
                              user: User(
                                id: 'driver',
                                name: 'Van Driver',
                                avatarText: 'D',
                              ),
                            ),
                      ),
                    );
                  }),
                ),
                if (!trip.isHistory)
                  Expanded(
                    child: _buildActionButton(Icons.cancel, 'Cancel', () {
                      _showCancelDialog(trip);
                    }),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: TextButton.styleFrom(
        foregroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }

  void _showCancelDialog(Trip trip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Trip'),
        content: const Text(
          'Are you sure you want to cancel this trip? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              await _firestoreService.cancelTrip(trip.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Trip cancelled.')),
              );
              Navigator.pop(context);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  // Helper to create a test trip (for drivers only)
  Future<void> _createTestTrip() async {
    if (_currentUserId == null) return;
    final now = DateTime.now();
    final tripData = {
      'pickupTime': Timestamp.fromDate(now.add(const Duration(minutes: 10))),
      'pickupLocation': _defaultHomeLocation,
      'dropoffLocation': _defaultSchoolLocation,
      'driverId': _currentUserId,
      'driverName': _defaultDriverName,
      'driverPhone': _defaultDriverPhone,
      'status': 'scheduled',
      'studentIds': [], // Add test student IDs as needed
      'isHistory': false,
    };
    await _firestoreService.createTrip(tripData);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Test trip created.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: $_errorMessage',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeUser,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final currentTrip = _activeTrips.isNotEmpty ? _activeTrips.first : null;
    final upcomingTrips =
        _activeTrips.where((trip) => trip != currentTrip).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PreviousTripsScreen(historyTrips: _historyTrips),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [Tab(text: 'Current Trip'), Tab(text: 'Upcoming')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Current Trip Tab
          SingleChildScrollView(
            child: Column(
              children: [
                if (currentTrip != null) ...[
                  _buildMap(currentTrip),
                  _buildTripCard(currentTrip),
                ] else
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No current trip'),
                    ),
                  ),
              ],
            ),
          ),
          // Upcoming Trips Tab
          ListView.builder(
            itemCount: upcomingTrips.length,
            itemBuilder: (context, index) {
              return _buildTripCard(upcomingTrips[index]);
            },
          ),
        ],
      ),
      floatingActionButton: _userRole == 'driver'
          ? FloatingActionButton(
              onPressed: _createTestTrip,
              child: const Icon(Icons.add),
              tooltip: 'Create Test Trip',
            )
          : null,
    );
  }
}

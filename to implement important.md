You are working on a Flutter + Firebase application for a student van transport system.

The app already has authentication and role-based navigation (student, driver, admin).

Now, I need you to wire up the Flutter app and backend logic to work with the following Firestore structure and access logic.



⸻



🔧 FIRESTORE STRUCTURE (CURRENT SETUP)



USERS COLLECTION



Each document in the “users” collection represents either a student, driver, or admin.

The key fields are:

	•	email: the user’s email address

	•	role: defines access and app flow (values: “student”, “driver”, or “admin”)

	•	routeId: the ID of the route this user is assigned to

	•	createdAt: timestamp of account creation



Example: a student user document might contain the email “student@example.com”, role “student”, and routeId “route_ABC123”.



⸻



ROUTES COLLECTION



Each document represents one active or future journey for a driver and its assigned students.

The main fields include:

	•	driverId: links to a document in the “drivers” collection

	•	status: defines the route state, such as “active” or “completed”

	•	studentIds: an array containing the UIDs of all students assigned to this route

	•	stops: an array of maps, each containing:

	•	label (string): for example, “Pickup” or “Dropoff”

	•	location (GeoPoint): latitude and longitude for that stop



Example: a route could have two stops, one labeled “Pickup” at latitude 35.9 and longitude 14.5, and another labeled “Dropoff” at latitude 35.91 and longitude 14.51.

The field studentIds might contain an array like [“BHPlmbx7VPcUn2zZMKS…”].



⸻



DRIVERS COLLECTION



Each driver document tracks the driver’s current state and links to their assigned van.

The key fields are:

	•	isActive: a boolean that indicates whether the driver is currently online or tracking

	•	routeId: the current route the driver is operating

	•	currentVanId: references a van document ID

	•	lastUpdated: a timestamp (server timestamp) showing the last update time



Example: the driver document “uid_Driver456” could contain isActive: true, routeId: “route_ABC123”, currentVanId: “driver_XYZ789”, and lastUpdated: server timestamp.



⸻



VANS COLLECTION



Each document in the “vans” collection represents a single vehicle, linked to its driver.

The main fields are:

	•	vanNumber: for example “MIA-1234”

	•	capacity: number of passengers (e.g., 10)

	•	model: van model (e.g., “Ford Transit”)

	•	location: a map with three subfields:

	•	latitude (number)

	•	longitude (number)

	•	timestamp (server timestamp)



Example: the van “driver_XYZ789” could have vanNumber “MIA-1234”, capacity 10, model “Ford Transit”, and a location map showing latitude 35.90, longitude 14.49, and a timestamp.



⸻



🧠 OBJECTIVE



The goal is to wire up the Flutter app so that:

	1.	Students

	•	See their assigned route displayed on a Google Map, including polylines connecting all stops.

	•	See their driver’s live location updating in real time from the “vans” collection.

	•	See pickup and drop-off markers (from the “routes” collection).

	•	See the current trip status (“active”, “completed”).

	•	Have a button to cancel upcoming trips.

	•	When they cancel, the system should remove their UID from “routes.studentIds” and clear their “routeId” field in “users”.

	2.	Drivers

	•	See their assigned route and its stops (linked via routeId).

	•	Have markers showing all student stops.

	•	Have the ability to start or end a route (changing “status” in the “routes” document).

	•	Automatically update their location in “vans.location” every few seconds while active.

	3.	Admins (future phase)

	•	Have a dashboard to view all routes, drivers, vans, and students.

	•	Have the ability to assign users to routes and update roles.

	•	Have full access to all documents for management and debugging.



⸻



🧩 REQUIRED FLUTTER WIRING



To make this work properly, the Flutter app should have:

	1.	Models

	•	A user model with fields: role, routeId, createdAt.

	•	A route model with fields: driverId, studentIds, stops, and status.

	•	A stop model with fields: label and location (GeoPoint).

	•	A van model with fields: vanNumber, capacity, model, and location.

	•	A driver model with fields: isActive, routeId, currentVanId, lastUpdated.

	2.	Services

	•	RouteService: handles fetching, subscribing, and updating route data.

	•	VanLocationService: listens to live driver location updates in real time.

	•	DirectionsService: interfaces with the Google Directions API to draw the route polyline and calculate ETA.

	•	TripService: manages trip cancellations, route updates, and reassignments for students.

	3.	UI Wiring

	•	StudentHomeScreen: displays the live map with route polyline, driver marker, pickup and drop-off points, and trip control buttons.

	•	DriverMainScreen: displays the current route, student stops, and navigation tools.

	•	Profile and Settings: already implemented, but must read and write from the “users” collection.

	•	Use Firestore snapshot listeners (.snapshots()) for live updates of driver movement and route status.

	4.	Firestore Security Rules

	•	Students should only be able to read and write their own user document and their assigned route document (limited to their own fields).

	•	Drivers should only be able to update their own driver document and their corresponding van document.

	•	Admins should have full access to all collections.



⸻



🎯 EXPECTED OUTCOME



After wiring everything together:

	•	The student’s app should automatically update whenever the driver’s van location changes.

	•	The driver’s location will update every few seconds in Firestore while tracking is active.

	•	Routes will stay properly synced between student, driver, and admin views.

	•	Canceling a trip will correctly remove the student from the route and reset their routeId in “users”.

	•	Firestore will remain normalized, efficient, and scalable.



⸻



🧠 TASK FOR WINDSURF



Based on this structure, generate the Dart service logic, snapshot listeners, and UI integration patterns required to make this real-time architecture work.



Make sure to use clean separation of models, providers, and services, and ensure smooth live sync between:

	•	the driver’s real-time location (from “vans”)

	•	the student’s route map (from “routes”)

	•	and the driver’s active status (from “drivers”).



Focus on Firebase efficiency, clear state management, and real-time Google Maps integration.
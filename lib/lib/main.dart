import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'screens/profile_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/trip_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'services/auth_service.dart';

void main() async {
  // Ensure that the Flutter framework is bound to the native platform.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase so that Firebase services can be used in the app.
  await Firebase.initializeApp();

  // Run the iVan app by providing the IVan widget as the root of the widget tree.
  runApp(const IVan());
}

class IVan extends StatelessWidget {
  const IVan({super.key});

  // Add this new method to show network permission dialog
  static void showNetworkPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Network Permission Required'),
          content: const Text(
            'This app requires local network access for debugging and development.\n\nPlease enable it in Settings to continue.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () async {
                final url = Uri.parse('app-settings:');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Close App'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Add error handling for Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception.toString().contains('Local Network') ||
          details.exception.toString().contains('permission denied')) {
        // Show network permission dialog
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showNetworkPermissionDialog(context);
        });
      }
      // You might want to log other errors to a service
      debugPrint(details.exceptionAsString());
    };

    return MaterialApp(
      title: 'iVan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.blue,
          secondary: Colors.orange,
        ),
        useMaterial3: true,
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 16),
        ),
      ),
      builder: (BuildContext context, Widget? child) {
        // This will handle errors that aren't caught by Flutter's error handling
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          if (errorDetails.exception.toString().contains('Local Network') ||
              errorDetails.exception.toString().contains('permission denied')) {
            // Return a placeholder widget that will show the dialog
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showNetworkPermissionDialog(context);
            });
          }
          return const Center(child: Text('An error occurred'));
        };
        return child!;
      },
      home: StreamBuilder<User?>(
        stream: AuthService().userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            return const HomeScreen();
          }

          return const LoginScreen();
        },
      ),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle dynamic routes or fallback routes
        switch (settings.name) {
          case '/home':
            return MaterialPageRoute(builder: (context) => const HomeScreen());
          case '/login':
            return MaterialPageRoute(builder: (context) => const LoginScreen());
          case '/register':
            return MaterialPageRoute(builder: (context) => const RegisterScreen());
          default:
            // Return a default route or error page
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(title: const Text('Error')),
                body: const Center(
                  child: Text('Page not found'),
                ),
              ),
            );
        }
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _buildFeatureCard(IconData icon, String title) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isLargeScreen = constraints.maxWidth > 600;
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: InkWell(
            onTap: () {
              if (title == 'Profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              } else if (title == 'Message') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatListScreen()),
                );
              } else if (title == 'Settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              } else if (title == 'Trip') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TripScreen()),
                );
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: isLargeScreen ? 60 : 40, color: Colors.blue),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(fontSize: isLargeScreen ? 18 : 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('iVan'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildFeatureCard(Icons.map, 'Trip'),
            _buildFeatureCard(Icons.message, 'Message'),
            _buildFeatureCard(Icons.person, 'Profile'),
            _buildFeatureCard(Icons.settings, 'Settings'),
          ],
        ),
      ),
    );
  }
}

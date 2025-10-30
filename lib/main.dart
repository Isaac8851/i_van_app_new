import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:i_van_app_new/services/auth_service.dart';
import 'package:i_van_app_new/lib/services/firestore_service.dart';
import 'package:i_van_app_new/screens/auth/login_screen.dart';
import 'package:i_van_app_new/lib/screens/register_screen.dart';
import 'ui/screens/student/student_main_screen.dart';
import 'ui/screens/driver/driver_main_screen.dart';
import 'services/route_service.dart';
import 'services/van_location_service.dart';
import 'services/driver_service.dart';
import 'services/chat_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const IVan());
}

class IVan extends StatelessWidget {
  const IVan({super.key});

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
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception.toString().contains('Local Network') ||
          details.exception.toString().contains('permission denied')) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showNetworkPermissionDialog(context);
        });
      }
      debugPrint(details.exceptionAsString());
    };

    return MultiProvider(
      providers: [
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => FirestoreService()),
        Provider(create: (_) => RouteService()),
        Provider(create: (_) => VanLocationService()),
        Provider(create: (_) => DriverService()),
        Provider(create: (_) => ChatService()),
      ],
      child: MaterialApp(
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
          ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
            if (errorDetails.exception.toString().contains('Local Network') ||
                errorDetails.exception.toString().contains('permission denied')) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showNetworkPermissionDialog(context);
              });
            }
            return const Center(child: Text('An error occurred'));
          };
          return child!;
        },
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/student': (context) => const StudentMainScreen(),
          '/driver': (context) => const DriverMainScreen(),
        },
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/login':
              return MaterialPageRoute(builder: (context) => const LoginScreen());
            case '/register':
              return MaterialPageRoute(builder: (context) => const RegisterScreen());
            case '/student':
              return MaterialPageRoute(builder: (context) => const StudentMainScreen());
            case '/driver':
              return MaterialPageRoute(builder: (context) => const DriverMainScreen());
            default:
              return MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: const Text('Error')),
                  body: const Center(child: Text('Page not found')),
                ),
              );
          }
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: context.read<AuthService>().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return FutureBuilder<String?>(
            future: context.read<FirestoreService>().getUserRole(snapshot.data!.uid),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final role = roleSnapshot.data;
              if (role == 'student') {
                return const StudentMainScreen();
              } else if (role == 'driver') {
                return const DriverMainScreen();
              } else {
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No role assigned to this account.'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () async {
                            await context.read<AuthService>().signOut();
                          },
                          child: const Text('Sign Out'),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          );
        }

        return const LoginScreen();
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'profile_screen.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  bool isDarkMode = false;
  bool allowNotifications = true;
  bool isProfilePublic = true;

  void _showLocationDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Location Update'),
            content: const Text(
              'Changes to pickup/drop-off locations will be automatically adjusted in the driver\'s map pending approval. The driver will be notified of your request.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Account'),
            content: const Text(
              'To delete your account, please send an email to support@ivan.com. Our team will process your request within 24-48 hours.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final Uri emailLaunchUri = Uri(
                    scheme: 'mailto',
                    path: 'support@ivan.com',
                    query: 'subject=Account Deletion Request',
                  );
                  if (await canLaunchUrl(emailLaunchUri)) {
                    await launchUrl(emailLaunchUri);
                  }
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('Send Email'),
              ),
            ],
          ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _authService.signOut();
              if (mounted) {
                Navigator.pop(context);
                // Navigation will be handled by the StreamBuilder in main.dart
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // User Preferences
          _buildSectionHeader('User Preferences'),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Edit Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.brightness_6),
            title: const Text('Dark Mode'),
            value: isDarkMode,
            onChanged: (value) {
              setState(() => isDarkMode = value);
              final brightness = value ? Brightness.dark : Brightness.light;
              WidgetsBinding.instance.window.platformBrightness == brightness;
              // TODO: Use a state management solution for real theme switching
            },
          ),

          // Notifications
          _buildSectionHeader('Notifications'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('Allow Notifications'),
            value: allowNotifications,
            onChanged: (value) {
              setState(() => allowNotifications = value);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Notification settings updated.')),
              );
            },
          ),

          // Privacy
          _buildSectionHeader('Privacy'),
          SwitchListTile(
            secondary: const Icon(Icons.security),
            title: const Text('Public Profile'),
            subtitle: const Text('Allow others to view your profile'),
            value: isProfilePublic,
            onChanged: (value) {
              setState(() => isProfilePublic = value);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Privacy settings updated.')),
              );
            },
          ),

          // Van Service
          _buildSectionHeader('Van Service'),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Update Default Locations'),
            subtitle: const Text('Set pickup and drop-off points'),
            onTap: _showLocationDialog,
          ),

          // App Information
          _buildSectionHeader('App Information'),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms of Service'),
            onTap: () async {
              const url = 'https://ivan.com/terms';
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            onTap: () async {
              const url = 'https://ivan.com/privacy';
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.support),
            title: const Text('Contact Support'),
            subtitle: const Text('Get help with the app'),
            onTap: () async {
              final Uri emailLaunchUri = Uri(
                scheme: 'mailto',
                path: 'support@ivan.com',
                query: 'subject=Support Request',
              );
              if (await canLaunchUrl(emailLaunchUri)) {
                await launchUrl(emailLaunchUri);
              }
            },
          ),

          // Account Management
          _buildSectionHeader('Account Management'),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup Data'),
            subtitle: const Text('Export your app data'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Data backup feature coming soon.')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            subtitle: const Text('Sign out of your account'),
            onTap: _showSignOutDialog,
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('Delete Account'),
            subtitle: const Text('Permanently remove your account'),
            onTap: _showDeleteAccountDialog,
          ),
        ],
      ),
    );
  }
}

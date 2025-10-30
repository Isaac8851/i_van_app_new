import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../lib/services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  bool _darkMode = false;
  bool _autoAcceptTrips = false;

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await context.read<AuthService>().signOut();
                if (mounted) {
                  Navigator.of(context).pop();
                  // Navigation will be handled by AuthWrapper
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(context).pop();
                  // Error is already handled by AuthService
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // Notifications Section
          _buildSectionHeader('Notifications'),
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive trip updates and alerts'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
                // TODO: Implement actual notification preference update
              });
            },
          ),
          SwitchListTile(
            title: const Text('Trip Reminders'),
            subtitle: const Text('Get notified before pickup time'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
                // TODO: Implement actual trip reminders preference update
              });
            },
          ),
          SwitchListTile(
            title: const Text('Driver Messages'),
            subtitle: const Text('Receive chat notifications'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
                // TODO: Implement actual driver messages preference update
              });
            },
          ),

          const Divider(),

          // Location Section
          _buildSectionHeader('Location & Privacy'),
          SwitchListTile(
            title: const Text('Location Services'),
            subtitle: const Text('Share location for trip tracking'),
            value: _locationEnabled,
            onChanged: (value) {
              setState(() {
                _locationEnabled = value;
                // TODO: Implement actual location services preference update
              });
            },
          ),
          SwitchListTile(
            title: const Text('Background Location'),
            subtitle: const Text('Track location when app is closed'),
            value: _locationEnabled,
            onChanged: (value) {
              setState(() {
                _locationEnabled = value;
                // TODO: Implement actual background location preference update
              });
            },
          ),

          const Divider(),

          // App Preferences Section
          _buildSectionHeader('App Preferences'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Use dark theme'),
            value: _darkMode,
            onChanged: (value) {
              setState(() {
                _darkMode = value;
                // TODO: Implement actual theme update
              });
            },
          ),
          SwitchListTile(
            title: const Text('Auto-accept Trips'),
            subtitle: const Text('Automatically accept assigned trips'),
            value: _autoAcceptTrips,
            onChanged: (value) {
              setState(() {
                _autoAcceptTrips = value;
                // TODO: Implement actual auto-accept trips preference update
              });
            },
          ),

          const Divider(),

          // Account Section
          _buildSectionHeader('Account'),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Navigate to profile editing screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Navigate to password change screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Privacy Settings'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Navigate to privacy settings screen
            },
          ),

          const Divider(),

          // Support Section
          _buildSectionHeader('Support'),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & FAQ'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Navigate to help & FAQ screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.support_agent),
            title: const Text('Contact Support'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Implement contact support functionality
            },
          ),
          ListTile(
            leading: const Icon(Icons.bug_report),
            title: const Text('Report a Bug'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Implement bug reporting functionality
            },
          ),

          const Divider(),

          // App Info Section
          _buildSectionHeader('App Information'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Version info is already displayed in the subtitle
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Open terms of service URL or screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Open privacy policy URL or screen
            },
          ),

          const SizedBox(height: 32),

          // Danger Zone
          _buildSectionHeader('Danger Zone', color: Colors.red),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            onTap: _showSignOutDialog,
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Delete Account',
                style: TextStyle(color: Colors.red)),
            onTap: () {
              _showDeleteAccountDialog();
            },
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: color ?? Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement account deletion
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

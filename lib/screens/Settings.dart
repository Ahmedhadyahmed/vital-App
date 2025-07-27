import 'package:flutter/material.dart';
import 'package:vital/screens/privacy_policy.dart';
import 'AppThemeScreen.dart';
import 'LanguageSettingsScreen.dart';
import 'NotificationSettingsScreen.dart';
import 'ProfileInfoScreen.dart';
import 'number confirmation.dart'; // Add this import

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Settings
            _buildSectionHeader('Account Settings'),
            _buildSettingsItem(
              icon: Icons.person_outline,
              title: 'Profile Information',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileInfoScreen()),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.notifications_outlined,
              title: 'Notification Preferences',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationSettingsScreen()),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.lock_outline,
              title: 'Change Password',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                );
              },
            ),

            const SizedBox(height: 24),

            // App Settings
            _buildSectionHeader('App Settings'),
            _buildSettingsItem(
              icon: Icons.color_lens_outlined,
              title: 'App Theme',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AppThemeScreen()),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.language_outlined,
              title: 'Language',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LanguageSettingsScreen()),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
                );
              },
            ),

            const SizedBox(height: 24),

            // Data Management
            _buildSectionHeader('Data Management'),
            _buildSettingsItem(
              icon: Icons.backup_outlined,
              title: 'Backup Data',
              onTap: () {},
              hasSwitch: true,
              switchValue: true,
            ),
            _buildSettingsItem(
              icon: Icons.restore_outlined,
              title: 'Restore Data',
              onTap: () {},
              hasSwitch: true,
              switchValue: true,
            ),
            _buildSettingsItem(
              icon: Icons.delete_outline,
              title: 'Clear Cache',
              onTap: () {},
              isLast: true,
            ),

            const SizedBox(height: 32),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.teal[800],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLast = false,
    bool hasSwitch = false,
    bool switchValue = false,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.teal[600]),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          trailing: hasSwitch
              ? Switch(
            value: switchValue,
            onChanged: (value) {},
            activeColor: Colors.teal[600],
          )
              : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        if (!isLast) Divider(height: 1, color: Colors.grey[200]),
      ],
    );
  }
}
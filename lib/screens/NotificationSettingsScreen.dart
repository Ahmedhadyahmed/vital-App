import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _glucoseAlerts = true;
  bool _medicationReminders = true;
  bool _appUpdates = false;
  bool _promotional = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notification Preferences',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Notification Types',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.teal[800],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Text(
                'Choose which notifications you want to receive',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.teal[600],
                ),
              ),
            ),

            // Notification Options
            _buildNotificationCard(
              title: 'Glucose Level Alerts',
              description: 'Receive alerts when your glucose levels are abnormal',
              value: _glucoseAlerts,
              onChanged: (value) => setState(() => _glucoseAlerts = value),
            ),
            _buildNotificationCard(
              title: 'Medication Reminders',
              description: 'Get reminders for your medication schedule',
              value: _medicationReminders,
              onChanged: (value) => setState(() => _medicationReminders = value),
            ),
            _buildNotificationCard(
              title: 'App Updates',
              description: 'Be notified about new features and updates',
              value: _appUpdates,
              onChanged: (value) => setState(() => _appUpdates = value),
            ),
            _buildNotificationCard(
              title: 'Promotional Offers',
              description: 'Receive special offers and promotions',
              value: _promotional,
              onChanged: (value) => setState(() => _promotional = value),
            ),

            // Notification Sound
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Notification Sound',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.teal[800],
                ),
              ),
            ),
            _buildSoundOption(),

            // Save Button
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notification preferences saved'),
                      backgroundColor: Colors.teal,
                    ),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[600],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.teal[50], // Light green background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.teal[100]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal[800],
                  ),
                ),
                Switch(
                  value: value,
                  onChanged: onChanged,
                  activeColor: Colors.teal[600],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.teal[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundOption() {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 0,
      color: Colors.teal[50], // Light green background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.teal[100]!),
      ),
      child: ListTile(
        title: Text(
          'Default Sound',
          style: TextStyle(
            fontSize: 16,
            color: Colors.teal[800],
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.teal[600]),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
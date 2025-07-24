import 'package:flutter/material.dart';

class AppThemeScreen extends StatefulWidget {
  const AppThemeScreen({super.key});

  @override
  State<AppThemeScreen> createState() => _AppThemeScreenState();
}

class _AppThemeScreenState extends State<AppThemeScreen> {
  int _selectedTheme = 0; // 0 = System, 1 = Light, 2 = Dark

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('App Theme', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Theme',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black, // Changed from gray to black
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose how VitalTracker looks on your device',
              style: TextStyle(
                color: Colors.black, // Changed from gray to black
              ),
            ),
            const SizedBox(height: 24),
            _buildThemeOption(
              title: 'System Default',
              subtitle: 'Match your device theme settings',
              selected: _selectedTheme == 0,
              onTap: () => setState(() => _selectedTheme = 0),
            ),
            _buildThemeOption(
              title: 'Light Mode',
              subtitle: 'Bright interface for daytime use',
              selected: _selectedTheme == 1,
              onTap: () => setState(() => _selectedTheme = 1),
            ),
            _buildThemeOption(
              title: 'Dark Mode',
              subtitle: 'Dark interface for nighttime use',
              selected: _selectedTheme == 2,
              onTap: () => setState(() => _selectedTheme = 2),
            ),
            const SizedBox(height: 32),
            const Text(
              'Accent Color',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black, // Changed from gray to black
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildColorOption(Colors.teal[600]!),
                  _buildColorOption(Colors.blue[600]!),
                  _buildColorOption(Colors.green[600]!),
                  _buildColorOption(Colors.orange[600]!),
                  _buildColorOption(Colors.purple[600]!),
                  _buildColorOption(Colors.red[600]!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.teal[50], // Light green background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? Colors.teal[600]! : Colors.teal[100]!,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: selected ? Colors.teal[600] : Colors.teal[400],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.teal[800], // Dark teal for text
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black, // Changed from gray to black
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorOption(Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 60,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.teal[100]!),
          ),
        ),
      ),
    );
  }
}
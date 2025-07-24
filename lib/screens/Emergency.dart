import 'package:flutter/material.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final TextEditingController _emergencyContactController = TextEditingController();
  final TextEditingController _doctorNumberController = TextEditingController();
  final TextEditingController _hospitalNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Emergency Contacts',
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
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Emergency Contact
            _buildContactCard(
              title: 'Emergency Contact',
              hint: 'Enter emergency contact number',
              controller: _emergencyContactController,
              icon: Icons.emergency,
            ),
            const SizedBox(height: 20),

            // Doctor Contact
            _buildContactCard(
              title: 'Doctor\'s Number',
              hint: 'Enter your doctor\'s phone number',
              controller: _doctorNumberController,
              icon: Icons.medical_services,
            ),
            const SizedBox(height: 20),

            // Hospital Contact
            _buildContactCard(
              title: 'Hospital Number',
              hint: 'Enter hospital emergency number',
              controller: _hospitalNumberController,
              icon: Icons.local_hospital,
            ),
            const SizedBox(height: 30),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveContacts,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A6E6E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Contacts',
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

  Widget _buildContactCard({
    required String title,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Card(
      elevation: 0,
      color: const Color(0xFFE0F2F1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFB2DFDB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB2DFDB),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: const Color(0xFF00796B)),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00796B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: hint,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveContacts() {
    // Save contacts logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Emergency contacts saved successfully'),
        backgroundColor: Color(0xFF0A6E6E),
      ),
    );
  }
}
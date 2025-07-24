import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NoteReminderPage extends StatefulWidget {
  const NoteReminderPage({Key? key}) : super(key: key);

  @override
  State<NoteReminderPage> createState() => _NoteReminderPageState();
}

class _NoteReminderPageState extends State<NoteReminderPage> {
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isDateSelected = false;
  bool _isTimeSelected = false;
  String _reminderType = 'datetime'; // 'datetime' or 'date'

  @override
  void dispose() {
    _noteController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.teal[600],
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _isDateSelected = true;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.teal[600],
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _isTimeSelected = true;
      });
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  void _saveReminder() {
    if (_titleController.text.isEmpty) {
      _showSnackBar('Please enter a title for your reminder', Colors.red);
      return;
    }

    if (_noteController.text.isEmpty) {
      _showSnackBar('Please enter a note', Colors.red);
      return;
    }

    if (!_isDateSelected) {
      _showSnackBar('Please select a date', Colors.red);
      return;
    }

    if (_reminderType == 'datetime' && !_isTimeSelected) {
      _showSnackBar('Please select a time', Colors.red);
      return;
    }

    _scheduleNotification();

    _showSnackBar('Reminder saved successfully!', Colors.green);
    _clearForm();
  }

  void _scheduleNotification() {
    DateTime scheduledDateTime;

    if (_reminderType == 'datetime' && _selectedTime != null) {
      scheduledDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
    } else {
      scheduledDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        9,
        0,
      );
    }

    print('Scheduling notification for: $scheduledDateTime');
    print('Title: ${_titleController.text}');
    print('Note: ${_noteController.text}');
  }

  void _clearForm() {
    setState(() {
      _titleController.clear();
      _noteController.clear();
      _selectedDate = null;
      _selectedTime = null;
      _isDateSelected = false;
      _isTimeSelected = false;
      _reminderType = 'datetime';
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F0), // Slightly darker background
      appBar: AppBar(
        title: const Text(
          'Create Reminder',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.black, // Changed from white to black
          ),
        ),
        backgroundColor: const Color(0xFFD0E0D0), // Darker green app bar
        foregroundColor: Colors.black, // Changed from white to black
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _clearForm,
            icon: const Icon(Icons.refresh, color: Colors.black),
            tooltip: 'Clear Form',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Card
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFD8E8D8), // Darker green container
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.title,
                        color: Colors.teal[800], // Darker icon
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Reminder Title',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black, // Changed from grey to black
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Enter reminder title...',
                      hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)), // Darker hint
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.teal[800]!, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                    ),
                    maxLength: 50,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(color: Colors.black), // Ensure text is black
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Note Card
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFD8E8D8), // Darker green container
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.note_alt,
                        color: Colors.teal[800], // Darker icon
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Note Content',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black, // Changed from grey to black
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Write your note here...',
                      hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)), // Darker hint
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.teal[800]!, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    maxLines: 4,
                    maxLength: 200,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(color: Colors.black), // Ensure text is black
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Reminder Type Card
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFD8E8D8), // Darker green container
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        color: Colors.teal[800], // Darker icon
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Reminder Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black, // Changed from grey to black
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Date & Time', style: TextStyle(color: Colors.black)),
                          value: 'datetime',
                          groupValue: _reminderType,
                          onChanged: (value) {
                            setState(() {
                              _reminderType = value!;
                            });
                          },
                          activeColor: Colors.teal[800], // Darker radio button
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Date Only', style: TextStyle(color: Colors.black)),
                          value: 'date',
                          groupValue: _reminderType,
                          onChanged: (value) {
                            setState(() {
                              _reminderType = value!;
                              _selectedTime = null;
                              _isTimeSelected = false;
                            });
                          },
                          activeColor: Colors.teal[800], // Darker radio button
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Date and Time Selection Card
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFD8E8D8), // Darker green container
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Colors.teal[800], // Darker icon
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Schedule',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black, // Changed from grey to black
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Date Selection
                  InkWell(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: _isDateSelected ? Colors.teal[800]! : Colors.grey[400]!,
                          width: _isDateSelected ? 1.5 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            color: _isDateSelected ? Colors.teal[800] : Colors.black.withOpacity(0.6),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _isDateSelected && _selectedDate != null
                                ? _formatDate(_selectedDate!)
                                : 'Select Date',
                            style: TextStyle(
                              fontSize: 16,
                              color: _isDateSelected ? Colors.teal[800] : Colors.black.withOpacity(0.6),
                              fontWeight: _isDateSelected ? FontWeight.w500 : FontWeight.normal,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_reminderType == 'datetime') ...[
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _selectTime,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: _isTimeSelected ? Colors.teal[800]! : Colors.grey[400]!,
                            width: _isTimeSelected ? 1.5 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: _isTimeSelected ? Colors.teal[800] : Colors.black.withOpacity(0.6),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _isTimeSelected && _selectedTime != null
                                  ? _formatTime(_selectedTime!)
                                  : 'Select Time',
                              style: TextStyle(
                                fontSize: 16,
                                color: _isTimeSelected ? Colors.teal[800] : Colors.black.withOpacity(0.6),
                                fontWeight: _isTimeSelected ? FontWeight.w500 : FontWeight.normal,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.black.withOpacity(0.6),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveReminder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[800], // Darker button
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Create Reminder',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Info Card
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFD8E8D8), // Darker green container
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.teal.withOpacity(0.3),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.teal[800], // Darker icon
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You will receive a notification at the scheduled time',
                      style: const TextStyle(
                        color: Colors.black, // Changed from teal to black
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
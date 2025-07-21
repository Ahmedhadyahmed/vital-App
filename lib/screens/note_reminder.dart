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

    // Here you would integrate with your notification service
    // For example, using flutter_local_notifications package
    _scheduleNotification();

    _showSnackBar('Reminder saved successfully!', Colors.green);
    _clearForm();
  }

  void _scheduleNotification() {
    // This is where you would schedule the actual notification
    // You'll need to implement this with flutter_local_notifications
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
      // Default to 9 AM if only date is selected
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Create Reminder',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.teal[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _clearForm,
            icon: const Icon(Icons.refresh),
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
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.title,
                          color: Colors.teal[700],
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Reminder Title',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Enter reminder title...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.teal[600]!, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                      maxLength: 50,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Note Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.note_alt,
                          color: Colors.green[700],
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Note Content',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        hintText: 'Write your note here...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.green[700]!, width: 2),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      maxLines: 4,
                      maxLength: 200,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Reminder Type Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: Colors.blueGrey[700],
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Reminder Type',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Date & Time'),
                            value: 'datetime',
                            groupValue: _reminderType,
                            onChanged: (value) {
                              setState(() {
                                _reminderType = value!;
                              });
                            },
                            activeColor: Colors.blueGrey[700],
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Date Only'),
                            value: 'date',
                            groupValue: _reminderType,
                            onChanged: (value) {
                              setState(() {
                                _reminderType = value!;
                                _selectedTime = null;
                                _isTimeSelected = false;
                              });
                            },
                            activeColor: Colors.blueGrey[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Date and Time Selection Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Colors.cyan[800],
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Schedule',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[900],
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
                          border: Border.all(
                            color: _isDateSelected ? Colors.cyan[800]! : Colors.grey[300]!,
                            width: _isDateSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_month,
                              color: _isDateSelected ? Colors.cyan[800] : Colors.grey[600],
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _isDateSelected && _selectedDate != null
                                  ? _formatDate(_selectedDate!)
                                  : 'Select Date',
                              style: TextStyle(
                                fontSize: 16,
                                color: _isDateSelected ? Colors.cyan[800] : Colors.grey[600],
                                fontWeight: _isDateSelected ? FontWeight.w500 : FontWeight.normal,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Time Selection (only show if datetime type is selected)
                    if (_reminderType == 'datetime') ...[
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: _selectTime,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _isTimeSelected ? Colors.cyan[800]! : Colors.grey[300]!,
                              width: _isTimeSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: _isTimeSelected ? Colors.cyan[800] : Colors.grey[600],
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _isTimeSelected && _selectedTime != null
                                    ? _formatTime(_selectedTime!)
                                    : 'Select Time',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _isTimeSelected ? Colors.cyan[800] : Colors.grey[600],
                                  fontWeight: _isTimeSelected ? FontWeight.w500 : FontWeight.normal,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
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
                  backgroundColor: Colors.teal[700],
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.notifications_active, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Create Reminder',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Info Card
            Card(
              color: Colors.teal[50],
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.teal[800],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You will receive a notification at the scheduled time',
                        style: TextStyle(
                          color: Colors.teal[800],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
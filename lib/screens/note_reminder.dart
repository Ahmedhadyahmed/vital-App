import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum NoteCategory {
  medication,
  appointment,
  exercise,
  health,
  general,
}

enum NotePriority {
  high,
  medium,
  low,
}

class NoteItem {
  final String id;
  final String title;
  final String content;
  final NoteCategory category;
  final DateTime scheduledDate;
  final bool isCompleted;
  final NotePriority priority;
  final DateTime createdAt;

  NoteItem({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.scheduledDate,
    required this.isCompleted,
    required this.priority,
    required this.createdAt,
  });
}

class NoteStorage {
  static final List<NoteItem> _notes = [];

  static List<NoteItem> get notes => List.unmodifiable(_notes);

  static void addNote(NoteItem note) {
    _notes.add(note);
  }

  static void updateNote(NoteItem updatedNote) {
    final index = _notes.indexWhere((note) => note.id == updatedNote.id);
    if (index != -1) {
      _notes[index] = updatedNote;
    }
  }

  static void deleteNote(String noteId) {
    _notes.removeWhere((note) => note.id == noteId);
  }
}

class NoteReminderPage extends StatefulWidget {
  final NoteItem? existingNote;

  const NoteReminderPage({Key? key, this.existingNote}) : super(key: key);

  @override
  State<NoteReminderPage> createState() => _NoteReminderPageState();
}

class _NoteReminderPageState extends State<NoteReminderPage> with TickerProviderStateMixin {
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isDateSelected = false;
  bool _isTimeSelected = false;
  String _reminderType = 'datetime';
  NoteCategory _selectedCategory = NoteCategory.general;
  NotePriority _selectedPriority = NotePriority.medium;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool get _isEditing => widget.existingNote != null;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();

    if (_isEditing) {
      _populateFormForEditing();
    }
  }

  void _populateFormForEditing() {
    final note = widget.existingNote!;
    _titleController.text = note.title;
    _noteController.text = note.content;
    _selectedDate = note.scheduledDate;
    _selectedTime = TimeOfDay.fromDateTime(note.scheduledDate);
    _selectedCategory = note.category;
    _selectedPriority = note.priority;
    _isDateSelected = true;
    _isTimeSelected = true;
  }

  @override
  void dispose() {
    _noteController.dispose();
    _titleController.dispose();
    _animationController.dispose();
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
              primary: const Color(0xFF036E41),
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
      HapticFeedback.selectionClick();
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
              primary: const Color(0xFF036E41),
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
      HapticFeedback.selectionClick();
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  void _saveReminder() {
    if (_titleController.text.isEmpty) {
      _showSnackBar('Please enter a title for your note', Colors.red);
      return;
    }

    if (_noteController.text.isEmpty) {
      _showSnackBar('Please enter note content', Colors.red);
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
    _saveNoteToStorage();
    HapticFeedback.heavyImpact();

    _showSnackBar(
      _isEditing ? 'Note updated successfully!' : 'Note created successfully!',
      const Color(0xFF036E41),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    });
  }

  void _saveNoteToStorage() {
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

    final note = NoteItem(
      id: _isEditing ? widget.existingNote!.id : DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      content: _noteController.text.trim(),
      category: _selectedCategory,
      scheduledDate: scheduledDateTime,
      isCompleted: _isEditing ? widget.existingNote!.isCompleted : false,
      priority: _selectedPriority,
      createdAt: _isEditing ? widget.existingNote!.createdAt : DateTime.now(),
    );

    if (_isEditing) {
      NoteStorage.updateNote(note);
    } else {
      NoteStorage.addNote(note);
    }
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
    print('Category: ${_selectedCategory.name}');
    print('Priority: ${_selectedPriority.name}');
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
      _selectedCategory = NoteCategory.general;
      _selectedPriority = NotePriority.medium;
    });
    HapticFeedback.lightImpact();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Note' : 'Create Note',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: Color(0xFF1A1A1A),
          ),
        ),
        backgroundColor: const Color(0xFFF7F9FC),
        foregroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _clearForm,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Clear Form',
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFE8F3EF),
              foregroundColor: const Color(0xFF036E41),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildModernCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        icon: Icons.edit_rounded,
                        title: 'Note Title',
                        iconColor: const Color(0xFF6366F1),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          hintText: 'Enter a descriptive title...',
                          hintStyle: TextStyle(
                            color: const Color(0xFF64748B).withOpacity(0.7),
                            fontSize: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFF036E41), width: 2),
                          ),
                          contentPadding: const EdgeInsets.all(18),
                        ),
                        maxLength: 50,
                        textCapitalization: TextCapitalization.sentences,
                        style: const TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildModernCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                              icon: Icons.category_rounded,
                              title: 'Category',
                              iconColor: const Color(0xFFEC4899),
                            ),
                            const SizedBox(height: 12),
                            _buildCategorySelector(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildModernCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                              icon: Icons.flag_rounded,
                              title: 'Priority',
                              iconColor: const Color(0xFFF59E0B),
                            ),
                            const SizedBox(height: 12),
                            _buildPrioritySelector(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildModernCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        icon: Icons.description_rounded,
                        title: 'Content',
                        iconColor: const Color(0xFF10B981),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _noteController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          hintText: 'Describe your note in detail...',
                          hintStyle: TextStyle(
                            color: const Color(0xFF64748B).withOpacity(0.7),
                            fontSize: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFF036E41), width: 2),
                          ),
                          contentPadding: const EdgeInsets.all(18),
                        ),
                        maxLines: 4,
                        maxLength: 200,
                        textCapitalization: TextCapitalization.sentences,
                        style: const TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildModernCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        icon: Icons.alarm_rounded,
                        title: 'Reminder Type',
                        iconColor: const Color(0xFF8B5CF6),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildReminderTypeOption(
                              'datetime',
                              'Date & Time',
                              Icons.schedule_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildReminderTypeOption(
                              'date',
                              'Date Only',
                              Icons.calendar_today_rounded,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildModernCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        icon: Icons.event_rounded,
                        title: 'Schedule',
                        iconColor: const Color(0xFF0EA5E9),
                      ),
                      const SizedBox(height: 16),
                      _buildDateTimeSelectors(),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saveReminder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF036E41),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      shadowColor: const Color(0xFF036E41).withOpacity(0.3),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isEditing ? Icons.update_rounded : Icons.add_rounded,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isEditing ? 'Update Note' : 'Create Note',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF036E41).withOpacity(0.05),
                        const Color(0xFF10B981).withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF036E41).withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF036E41).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_active_rounded,
                          color: Color(0xFF036E41),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'You\'ll receive a push notification at the scheduled time',
                          style: TextStyle(
                            color: Color(0xFF036E41),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(24.0),
      child: child,
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildReminderTypeOption(String value, String label, IconData icon) {
    final isSelected = _reminderType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _reminderType = value;
          if (value == 'date') {
            _selectedTime = null;
            _isTimeSelected = false;
          }
        });
        HapticFeedback.selectionClick();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF036E41).withOpacity(0.1) : const Color(0xFFF8FAFC),
          border: Border.all(
            color: isSelected ? const Color(0xFF036E41) : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF036E41) : const Color(0xFF64748B),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? const Color(0xFF036E41) : const Color(0xFF64748B),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSelectors() {
    return Column(
      children: [
        _buildSelectionButton(
          icon: Icons.calendar_month_rounded,
          label: _isDateSelected && _selectedDate != null
              ? _formatDate(_selectedDate!)
              : 'Select Date',
          isSelected: _isDateSelected,
          onTap: _selectDate,
          color: const Color(0xFF0EA5E9),
        ),
        if (_reminderType == 'datetime') ...[
          const SizedBox(height: 12),
          _buildSelectionButton(
            icon: Icons.access_time_rounded,
            label: _isTimeSelected && _selectedTime != null
                ? _formatTime(_selectedTime!)
                : 'Select Time',
            isSelected: _isTimeSelected,
            onTap: _selectTime,
            color: const Color(0xFF8B5CF6),
          ),
        ],
      ],
    );
  }

  Widget _buildSelectionButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : const Color(0xFFF8FAFC),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isSelected ? color : const Color(0xFF64748B)).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? color : const Color(0xFF64748B),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: isSelected ? color : const Color(0xFF64748B),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: isSelected ? color : const Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: DropdownButtonFormField<NoteCategory>(
        value: _selectedCategory,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
        dropdownColor: Colors.white,
        items: NoteCategory.values.map((category) {
          return DropdownMenuItem(
            value: category,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(category),
                    color: _getCategoryColor(category),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _getCategoryName(category),
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedCategory = value;
            });
            HapticFeedback.selectionClick();
          }
        },
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: DropdownButtonFormField<NotePriority>(
        value: _selectedPriority,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
        dropdownColor: Colors.white,
        items: NotePriority.values.map((priority) {
          return DropdownMenuItem(
            value: priority,
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _getPriorityColor(priority),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  priority.name.toUpperCase(),
                  style: TextStyle(
                    color: _getPriorityColor(priority),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedPriority = value;
            });
            HapticFeedback.selectionClick();
          }
        },
      ),
    );
  }

  IconData _getCategoryIcon(NoteCategory category) {
    switch (category) {
      case NoteCategory.medication:
        return Icons.medication_rounded;
      case NoteCategory.appointment:
        return Icons.event_rounded;
      case NoteCategory.exercise:
        return Icons.fitness_center_rounded;
      case NoteCategory.health:
        return Icons.favorite_rounded;
      case NoteCategory.general:
        return Icons.note_rounded;
    }
  }

  Color _getCategoryColor(NoteCategory category) {
    switch (category) {
      case NoteCategory.medication:
        return const Color(0xFF036E41);
      case NoteCategory.appointment:
        return const Color(0xFF0EA5E9);
      case NoteCategory.exercise:
        return const Color(0xFF8B5CF6);
      case NoteCategory.health:
        return const Color(0xFFEF4444);
      case NoteCategory.general:
        return const Color(0xFF64748B);
    }
  }

  String _getCategoryName(NoteCategory category) {
    switch (category) {
      case NoteCategory.medication:
        return 'Medication';
      case NoteCategory.appointment:
        return 'Appointment';
      case NoteCategory.exercise:
        return 'Exercise';
      case NoteCategory.health:
        return 'Health';
      case NoteCategory.general:
        return 'General';
    }
  }

  Color _getPriorityColor(NotePriority priority) {
    switch (priority) {
      case NotePriority.high:
        return const Color(0xFFEF4444);
      case NotePriority.medium:
        return const Color(0xFFF59E0B);
      case NotePriority.low:
        return const Color(0xFF10B981);
    }
  }
}
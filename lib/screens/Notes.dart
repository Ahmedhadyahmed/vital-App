import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vital/screens/note_reminder.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({Key? key}) : super(key: key);

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Today', 'Upcoming', 'Completed'];

  // Sample notes data - you can replace this with your actual data source
  final List<NoteItem> _notes = [
    NoteItem(
      id: '1',
      title: 'Morning Medication',
      content: 'Take insulin before breakfast - 8 units',
      category: NoteCategory.medication,
      scheduledDate: DateTime.now().add(const Duration(hours: 2)),
      isCompleted: false,
      priority: NotePriority.high,
    ),
    NoteItem(
      id: '2',
      title: 'Doctor Checkup',
      content: 'Monthly diabetes checkup with Dr. Smith at 2:00 PM',
      category: NoteCategory.appointment,
      scheduledDate: DateTime.now().add(const Duration(days: 3)),
      isCompleted: false,
      priority: NotePriority.medium,
    ),
    NoteItem(
      id: '3',
      title: 'Evening Exercise',
      content: '30-minute walk in the park after dinner',
      category: NoteCategory.exercise,
      scheduledDate: DateTime.now().subtract(const Duration(hours: 1)),
      isCompleted: true,
      priority: NotePriority.low,
    ),
    NoteItem(
      id: '4',
      title: 'Blood Sugar Log',
      content: 'Record blood sugar levels before meals',
      category: NoteCategory.health,
      scheduledDate: DateTime.now().add(const Duration(hours: 4)),
      isCompleted: false,
      priority: NotePriority.high,
    ),
    NoteItem(
      id: '5',
      title: 'Grocery Shopping',
      content: 'Buy low-carb snacks and fresh vegetables',
      category: NoteCategory.general,
      scheduledDate: DateTime.now().add(const Duration(days: 1)),
      isCompleted: false,
      priority: NotePriority.low,
    ),
    NoteItem(
      id: '6',
      title: 'Insulin Refill',
      content: 'Order insulin refill from pharmacy',
      category: NoteCategory.medication,
      scheduledDate: DateTime.now().add(const Duration(days: 7)),
      isCompleted: false,
      priority: NotePriority.medium,
    ),
  ];

  List<NoteItem> get _filteredNotes {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    switch (_selectedFilter) {
      case 'Today':
        return _notes.where((note) {
          final noteDate = DateTime(
            note.scheduledDate.year,
            note.scheduledDate.month,
            note.scheduledDate.day,
          );
          return noteDate == today;
        }).toList();
      case 'Upcoming':
        return _notes.where((note) {
          final noteDate = DateTime(
            note.scheduledDate.year,
            note.scheduledDate.month,
            note.scheduledDate.day,
          );
          return noteDate.isAfter(today) && !note.isCompleted;
        }).toList();
      case 'Completed':
        return _notes.where((note) => note.isCompleted).toList();
      default:
        return _notes;
    }
  }

  void _toggleNoteCompletion(String noteId) {
    setState(() {
      final noteIndex = _notes.indexWhere((note) => note.id == noteId);
      if (noteIndex != -1) {
        _notes[noteIndex] = _notes[noteIndex].copyWith(
          isCompleted: !_notes[noteIndex].isCompleted,
        );
      }
    });
  }

  void _deleteNote(String noteId) {
    setState(() {
      _notes.removeWhere((note) => note.id == noteId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Note deleted'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotes = _filteredNotes;
    final completedCount = _notes.where((note) => note.isCompleted).length;
    final totalCount = _notes.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F8),
      appBar: AppBar(
        title: const Text(
          'My Notes',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Color(0xFF212121),
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF212121),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // Add search functionality here
            },
            icon: const Icon(Icons.search),
            tooltip: 'Search Notes',
          ),
          IconButton(
            onPressed: () {
              // Add sort/filter options here
            },
            icon: const Icon(Icons.sort),
            tooltip: 'Sort Notes',
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Container
          if (totalCount > 0) ...[
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF036E41), Color(0xFF389C7B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF036E41).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Notes Overview',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$completedCount of $totalCount completed',
                          style: const TextStyle(
                            color: Color(0xFFE8F5F0),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${((completedCount / totalCount) * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Filter Chips
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filterOptions.length,
              itemBuilder: (context, index) {
                final option = _filterOptions[index];
                final isSelected = _selectedFilter == option;
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(option),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = option;
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFF036E41).withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFF036E41) : const Color(0xFF424242),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF036E41)
                          : const Color(0xFFE0E0E0),
                    ),
                    elevation: 0,
                    pressElevation: 0,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Notes List
          Expanded(
            child: filteredNotes.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredNotes.length,
              itemBuilder: (context, index) {
                final note = filteredNotes[index];
                return _buildNoteCard(note);
              },
            ),
          ),
        ],
      ),
      // Create Note Button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NoteReminderPage(),
              ),
            );
          },
          backgroundColor: const Color(0xFF036E41),
          foregroundColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          label: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 24),
              SizedBox(width: 8),
              Text(
                'Create Note',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF389C7B).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.note_add,
              size: 64,
              color: Color(0xFF389C7B),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No notes found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 'All'
                ? 'Create your first note to get started'
                : 'No notes match the selected filter',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF757575),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(NoteItem note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: note.isCompleted
                ? const Color(0xFF389C7B).withOpacity(0.3)
                : _getPriorityColor(note.priority).withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Category Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(note.category).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getCategoryIcon(note.category),
                      color: _getCategoryColor(note.category),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title and Priority
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: note.isCompleted
                                ? const Color(0xFF424242)
                                : const Color(0xFF212121),
                            decoration: note.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getPriorityColor(note.priority).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                note.priority.name.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: _getPriorityColor(note.priority),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getCategoryName(note.category),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF757575),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Completion Checkbox
                  Checkbox(
                    value: note.isCompleted,
                    onChanged: (value) => _toggleNoteCompletion(note.id),
                    activeColor: const Color(0xFF036E41),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Note Content
              Text(
                note.content,
                style: TextStyle(
                  fontSize: 14,
                  color: note.isCompleted
                      ? const Color(0xFF757575)
                      : const Color(0xFF424242),
                  height: 1.4,
                  decoration: note.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Bottom Row with Date and Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: const Color(0xFF757575),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatScheduledDate(note.scheduledDate),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF757575),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          // Navigate to edit note
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NoteReminderPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit, size: 18),
                        color: const Color(0xFF757575),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                      ),
                      IconButton(
                        onPressed: () => _showDeleteConfirmation(note),
                        icon: const Icon(Icons.delete, size: 18),
                        color: Colors.red[400],
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(NoteItem note) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Note'),
          content: Text('Are you sure you want to delete "${note.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteNote(note.id);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  String _formatScheduledDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final noteDate = DateTime(date.year, date.month, date.day);

    if (noteDate == today) {
      return 'Today ${DateFormat('HH:mm').format(date)}';
    } else if (noteDate == tomorrow) {
      return 'Tomorrow ${DateFormat('HH:mm').format(date)}';
    } else if (noteDate.isBefore(today)) {
      return DateFormat('MMM dd, HH:mm').format(date);
    } else {
      return DateFormat('MMM dd, HH:mm').format(date);
    }
  }

  IconData _getCategoryIcon(NoteCategory category) {
    switch (category) {
      case NoteCategory.medication:
        return Icons.medication;
      case NoteCategory.appointment:
        return Icons.event;
      case NoteCategory.exercise:
        return Icons.fitness_center;
      case NoteCategory.health:
        return Icons.favorite;
      case NoteCategory.general:
        return Icons.note;
    }
  }

  Color _getCategoryColor(NoteCategory category) {
    switch (category) {
      case NoteCategory.medication:
        return const Color(0xFF036E41);
      case NoteCategory.appointment:
        return const Color(0xFF389C7B);
      case NoteCategory.exercise:
        return const Color(0xFF424242);
      case NoteCategory.health:
        return Colors.red[400]!;
      case NoteCategory.general:
        return const Color(0xFF757575);
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
        return Colors.red[400]!;
      case NotePriority.medium:
        return Colors.orange[400]!;
      case NotePriority.low:
        return Colors.green[400]!;
    }
  }
}

// Data Models
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

  NoteItem({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.scheduledDate,
    required this.isCompleted,
    required this.priority,
  });

  NoteItem copyWith({
    String? id,
    String? title,
    String? content,
    NoteCategory? category,
    DateTime? scheduledDate,
    bool? isCompleted,
    NotePriority? priority,
  }) {
    return NoteItem(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
    );
  }
}
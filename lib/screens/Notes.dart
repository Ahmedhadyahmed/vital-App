import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:vital/screens/note_reminder.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({Key? key}) : super(key: key);

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> with TickerProviderStateMixin {
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Today', 'Upcoming', 'Completed'];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    NoteItem(
      id: '2',
      title: 'Doctor Checkup',
      content: 'Monthly diabetes checkup with Dr. Smith at 2:00 PM',
      category: NoteCategory.appointment,
      scheduledDate: DateTime.now().add(const Duration(days: 3)),
      isCompleted: false,
      priority: NotePriority.medium,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    NoteItem(
      id: '3',
      title: 'Evening Exercise',
      content: '30-minute walk in the park after dinner',
      category: NoteCategory.exercise,
      scheduledDate: DateTime.now().subtract(const Duration(hours: 1)),
      isCompleted: true,
      priority: NotePriority.low,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    NoteItem(
      id: '4',
      title: 'Blood Sugar Log',
      content: 'Record blood sugar levels before meals',
      category: NoteCategory.health,
      scheduledDate: DateTime.now().add(const Duration(hours: 4)),
      isCompleted: false,
      priority: NotePriority.high,
      createdAt: DateTime.now(),
    ),
    NoteItem(
      id: '5',
      title: 'Grocery Shopping',
      content: 'Buy low-carb snacks and fresh vegetables',
      category: NoteCategory.general,
      scheduledDate: DateTime.now().add(const Duration(days: 1)),
      isCompleted: false,
      priority: NotePriority.low,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    NoteItem(
      id: '6',
      title: 'Insulin Refill',
      content: 'Order insulin refill from pharmacy',
      category: NoteCategory.medication,
      scheduledDate: DateTime.now().add(const Duration(days: 7)),
      isCompleted: false,
      priority: NotePriority.medium,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<NoteItem> get _filteredNotes {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

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
    HapticFeedback.lightImpact();
  }

  void _deleteNote(String noteId) {
    setState(() {
      _notes.removeWhere((note) => note.id == noteId);
    });
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Note deleted',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFFEF4444),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _navigateToCreateNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NoteReminderPage(),
      ),
    );

    if (result == true) {
      setState(() {});
    }
  }

  void _navigateToEditNote(NoteItem note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteReminderPage(existingNote: note),
      ),
    );

    if (result == true) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotes = _filteredNotes;
    final completedCount = _notes.where((note) => note.isCompleted).length;
    final totalCount = _notes.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text(
          'My Notes',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: Color(0xFF1A1A1A),
          ),
        ),
        backgroundColor: const Color(0xFFF7F9FC),
        foregroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
            },
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Search Notes',
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
            },
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Filter Options',
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            if (totalCount > 0) ...[
              Container(
                margin: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: _buildStatsCard(completedCount, totalCount),
              ),
            ],
            Container(
              height: 60,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _filterOptions.length,
                itemBuilder: (context, index) {
                  final option = _filterOptions[index];
                  final isSelected = _selectedFilter == option;
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: _buildFilterChip(option, isSelected),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: filteredNotes.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                itemCount: filteredNotes.length,
                itemBuilder: (context, index) {
                  final note = filteredNotes[index];
                  return _buildNoteCard(note, index);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: FloatingActionButton.extended(
          onPressed: _navigateToCreateNote,
          backgroundColor: const Color(0xFF036E41),
          foregroundColor: Colors.white,
          elevation: 12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          label: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, size: 24),
              SizedBox(width: 12),
              Text(
                'Create New Note',
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

  Widget _buildStatsCard(int completedCount, int totalCount) {
    final percentage = ((completedCount / totalCount) * 100).round();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF036E41), Color(0xFF10B981)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF036E41).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
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
                  'Progress Overview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$completedCount of $totalCount notes completed',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: completedCount / totalCount,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Column(
              children: [
                Text(
                  '$percentage%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'COMPLETE',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String option, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = option;
        });
        HapticFeedback.selectionClick();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF036E41) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF036E41) : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: const Color(0xFF036E41).withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          option,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF64748B),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
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
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF036E41).withOpacity(0.1),
                  const Color(0xFF10B981).withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.note_add_rounded,
              size: 80,
              color: Color(0xFF036E41),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'No notes found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _selectedFilter == 'All'
                ? 'Create your first note to get started\nwith organizing your tasks'
                : 'No notes match the selected filter.\nTry selecting a different filter.',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF64748B),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          if (_selectedFilter == 'All')
            ElevatedButton.icon(
              onPressed: _navigateToCreateNote,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Your First Note'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF036E41),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(NoteItem note, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: _buildNoteCardContent(note),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoteCardContent(NoteItem note) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
        border: Border.all(
          color: note.isCompleted
              ? const Color(0xFF10B981).withOpacity(0.2)
              : _getPriorityColor(note.priority).withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(note.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _getCategoryIcon(note.category),
                    color: _getCategoryColor(note.category),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: note.isCompleted
                              ? const Color(0xFF64748B)
                              : const Color(0xFF1A1A1A),
                          decoration: note.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(note.priority).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: _getPriorityColor(note.priority),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  note.priority.name.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: _getPriorityColor(note.priority),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getCategoryName(note.category),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    value: note.isCompleted,
                    onChanged: (value) => _toggleNoteCompletion(note.id),
                    activeColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    side: BorderSide(
                      color: note.isCompleted
                          ? const Color(0xFF10B981)
                          : const Color(0xFFD1D5DB),
                      width: 2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              note.content,
              style: TextStyle(
                fontSize: 15,
                color: note.isCompleted
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF475569),
                height: 1.5,
                decoration: note.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 16,
                        color: const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatScheduledDate(note.scheduledDate),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _navigateToEditNote(note),
                      icon: const Icon(Icons.edit_rounded, size: 20),
                      color: const Color(0xFF64748B),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F5F9),
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(36, 36),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _showDeleteConfirmation(note),
                      icon: const Icon(Icons.delete_rounded, size: 20),
                      color: const Color(0xFFEF4444),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFFEF2F2),
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(36, 36),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(NoteItem note) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Delete Note',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${note.title}"? This action cannot be undone.',
            style: const TextStyle(
              color: Color(0xFF64748B),
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF64748B),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteNote(note.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
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

  NoteItem copyWith({
    String? id,
    String? title,
    String? content,
    NoteCategory? category,
    DateTime? scheduledDate,
    bool? isCompleted,
    NotePriority? priority,
    DateTime? createdAt,
  }) {
    return NoteItem(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
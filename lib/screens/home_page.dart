import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vital/screens/payment_mehods.dart';
import 'package:vital/screens/privacy_policy.dart';
import 'package:vital/screens/login_screen.dart';
import 'package:vital/screens/note_reminder.dart';
import 'Emergency.dart';
import 'Help & Support.dart';
import 'MedicationsScreen.dart';
import 'Notes.dart';
import 'Settings.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _cardAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _cardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOutBack,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _cardAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String userName = "Alex Morgan";
    final double lastGlucose = 112.4;
    final DateTime lastReadingTime = DateTime.now().subtract(const Duration(minutes: 15));
    final String warningMessage = lastGlucose < 70
        ? "Low glucose warning!"
        : lastGlucose > 180
        ? "High glucose warning!"
        : "";

    final List<Note> notes = [
      Note(Icons.free_breakfast_outlined, "Breakfast", "Took 8 units insulin with meal", DateTime.now().subtract(const Duration(hours: 2))),
      Note(Icons.medication_liquid, "Medication", "Morning dose completed", DateTime.now().subtract(const Duration(days: 1))),
      Note(Icons.fitness_center, "Exercise", "30 min cardio session", DateTime.now().subtract(const Duration(days: 2))),
    ];

    final List<NotificationItem> notifications = [
      NotificationItem(
        id: "1",
        title: "Medication Reminder",
        message: "Time to take your evening insulin dose",
        type: NotificationType.medication,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
      ),
      NotificationItem(
        id: "2",
        title: "Glucose Alert",
        message: "Your glucose level is within normal range",
        type: NotificationType.glucose,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        isRead: false,
      ),
      NotificationItem(
        id: "3",
        title: "Exercise Reminder",
        message: "Don't forget your daily 30-minute walk",
        type: NotificationType.exercise,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      drawer: const _AppDrawer(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Enhanced App Bar
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            leading: Builder(
              builder: (context) => ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.menu_rounded, color: Colors.white),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Badge(
                    backgroundColor: const Color(0xFFEF4444),
                    label: Text(
                      "${notifications.where((n) => !n.isRead).length}",
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    child: const Icon(Icons.notifications_rounded, color: Colors.white),
                  ),
                  onPressed: () => _showNotificationsModal(context, notifications),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: AnimatedBuilder(
                animation: _headerAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 0.8 + (0.2 * _headerAnimation.value),
                    child: Opacity(
                      opacity: _headerAnimation.value,
                      child: _buildEnhancedHeader(userName),
                    ),
                  );
                },
              ),
            ),
          ),

          // Content
          // ADD THIS INSTEAD:
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _cardAnimation,
              builder: (context, child) {
                return SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _cardAnimation,
                    child: SafeArea(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: MediaQuery.of(context).size.height,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 24),
                                _buildQuickStatsRow(),
                                const SizedBox(height: 24),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                  child: _buildEnhancedGlucoseSection(
                                      lastGlucose, lastReadingTime, warningMessage),
                                ),
                                const SizedBox(height: 24),
                                _buildActionCards(),
                                const SizedBox(height: 24),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                  child: _buildEnhancedNotesSection(notes),
                                ),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildEnhancedHeader(String userName) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1E3A8A),
            Color(0xFF3B82F6),
            Color(0xFF06B6D4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.1),
              Colors.transparent,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Hero(
                  tag: 'user_avatar',
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person_rounded, size: 42, color: Color(0xFF3B82F6)),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Good ${_getTimeOfDay()}!",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Your health metrics are looking great today! Keep up the excellent work.",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.4,
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

  Widget _buildQuickStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _buildQuickStatCard("Today's Average", "118 mg/dL", Icons.trending_up_rounded, const Color(0xFF10B981))),
          const SizedBox(width: 12),
          Expanded(child: _buildQuickStatCard("Readings", "12", Icons.timeline_rounded, const Color(0xFF3B82F6))),
          const SizedBox(width: 12),
          Expanded(child: _buildQuickStatCard("Streak", "7 days", Icons.local_fire_department_rounded, const Color(0xFFEF4444))),
        ],
      ),
    );
  }

  Widget _buildQuickStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedGlucoseSection(double lastGlucose, DateTime readingTime, String warning) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Glucose Monitoring",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Live",
                style: TextStyle(
                  color: Color(0xFF3B82F6),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.08),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    SizedBox(height: 220, child: _buildEnhancedGlucoseChart()),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getStatusColor(lastGlucose).withOpacity(0.05),
                            _getStatusColor(lastGlucose).withOpacity(0.02),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _getStatusColor(lastGlucose).withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getStatusColor(lastGlucose).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.monitor_heart_rounded,
                              color: _getStatusColor(lastGlucose),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "CURRENT READING",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "$lastGlucose mg/dL",
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1F2937),
                                    letterSpacing: -1,
                                  ),
                                ),
                                Text(
                                  DateFormat('MMM dd, hh:mm a').format(readingTime),
                                  style: const TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _getStatusColor(lastGlucose),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getStatusText(lastGlucose),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (warning.isNotEmpty)
                Container(
                  margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_rounded, color: Color(0xFFEF4444), size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          warning,
                          style: const TextStyle(
                            color: Color(0xFFEF4444),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildActionCard(
              "Log Reading",
              "Add new glucose measurement",
              Icons.add_circle_outline_rounded,
              const Color(0xFF3B82F6),
                  () {},
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionCard(
              "Add Note",
              "Record health observation",
              Icons.note_add_rounded,
              const Color(0xFF10B981),
                  () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedNotesSection(List<Note> notes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Recent Activity",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: const Text("View All"),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF3B82F6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...notes.asMap().entries.map((entry) {
          final index = entry.key;
          final note = entry.value;
          return AnimatedContainer(
            duration: Duration(milliseconds: 200 + (index * 100)),
            child: _buildEnhancedNoteCard(note, index),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildEnhancedNoteCard(Note note, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getNoteIconColor(note.title).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: _getNoteIconColor(note.title).withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Hero(
                  tag: 'note_icon_$index',
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _getNoteIconColor(note.title).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _getNoteIconColor(note.title).withOpacity(0.2)),
                    ),
                    child: Icon(
                      note.icon,
                      color: _getNoteIconColor(note.title),
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        note.description,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          height: 1.4,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          DateFormat('MMM dd, yyyy').format(note.time),
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: const Color(0xFF6B7280).withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedGlucoseChart() {
    final values = [110, 140, 130, 112, 98, 105, 120, 115, 125, 118, 130, 140, 110, 95, 105];
    final maxValue = values.reduce((a, b) => a > b ? a : b).toDouble();
    final minValue = values.reduce((a, b) => a < b ? a : b).toDouble();

    return CustomPaint(painter: EnhancedHorizontalGlucoseChartPainter(values, maxValue, minValue));
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Morning";
    if (hour < 17) return "Afternoon";
    return "Evening";
  }

  Color _getStatusColor(double value) {
    if (value < 70) return const Color(0xFFEF4444);
    if (value > 180) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  String _getStatusText(double value) {
    if (value < 70) return "LOW";
    if (value > 180) return "HIGH";
    return "NORMAL";
  }

  Color _getNoteIconColor(String noteTitle) {
    switch (noteTitle.toLowerCase()) {
      case 'breakfast':
        return const Color(0xFF10B981);
      case 'medication':
        return const Color(0xFF3B82F6);
      case 'exercise':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  void _showNotificationsModal(BuildContext context, List<NotificationItem> notifications) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NotificationsModal(notifications: notifications),
    );
  }
}

// Enhanced Chart Painter
class EnhancedHorizontalGlucoseChartPainter extends CustomPainter {
  final List<int> values;
  final double maxValue;
  final double minValue;

  EnhancedHorizontalGlucoseChartPainter(this.values, this.maxValue, this.minValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF3B82F6).withOpacity(0.2),
          const Color(0xFF06B6D4).withOpacity(0.1),
          const Color(0xFF06B6D4).withOpacity(0.05),
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final pointPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final pointBorderPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    final pointRadius = 6.0;
    final width = size.width - 40;
    final height = size.height - 40;
    final valueRange = maxValue - minValue;

    final points = values.asMap().entries.map((entry) {
      final i = entry.key;
      final value = entry.value;
      final y = 20 + (height / (values.length - 1)) * i;
      final x = 20 + ((value - minValue) / valueRange) * width;
      return Offset(x, y);
    }).toList();

    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);

      for (int i = 0; i < points.length - 1; i++) {
        final currentPoint = points[i];
        final nextPoint = points[i + 1];
        final controlPointDistance = (nextPoint.dy - currentPoint.dy) * 0.4;

        final controlPoint1 = Offset(
          currentPoint.dx,
          currentPoint.dy + controlPointDistance,
        );

        final controlPoint2 = Offset(
          nextPoint.dx,
          nextPoint.dy - controlPointDistance,
        );

        path.cubicTo(
          controlPoint1.dx, controlPoint1.dy,
          controlPoint2.dx, controlPoint2.dy,
          nextPoint.dx, nextPoint.dy,
        );
      }
    }

    final fillPath = Path.from(path)
      ..lineTo(20, points.last.dy)
      ..lineTo(20, points.first.dy)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    for (final point in points) {
      canvas.drawCircle(point, pointRadius, pointPaint);
      canvas.drawCircle(point, pointRadius, pointBorderPaint);
    }

    // Grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFF3B82F6).withOpacity(0.1)
      ..strokeWidth = 1;

    for (int i = 1; i < 4; i++) {
      final x = 20 + width * i / 4;
      canvas.drawLine(Offset(x, 20), Offset(x, height + 20), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Notification data models and other classes remain the same
enum NotificationType {
  medication,
  glucose,
  exercise,
  appointment,
  report,
  general,
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    required this.isRead,
  });
}

class NotificationsModal extends StatefulWidget {
  final List<NotificationItem> notifications;

  const NotificationsModal({super.key, required this.notifications});

  @override
  State<NotificationsModal> createState() => _NotificationsModalState();
}

class _NotificationsModalState extends State<NotificationsModal> {
  late List<NotificationItem> notifications;

  @override
  void initState() {
    super.initState();
    notifications = List.from(widget.notifications);
  }

  void _markAsRead(String notificationId) {
    setState(() {
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications[index] = NotificationItem(
          id: notifications[index].id,
          title: notifications[index].title,
          message: notifications[index].message,
          type: notifications[index].type,
          timestamp: notifications[index].timestamp,
          isRead: true,
        );
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      notifications = notifications.map((notification) => NotificationItem(
        id: notification.id,
        title: notification.title,
        message: notification.message,
        type: notification.type,
        timestamp: notification.timestamp,
        isRead: true,
      )).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = notifications.where((n) => !n.isRead).length;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Notifications",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$unreadCount unread notifications",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                if (unreadCount > 0)
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextButton(
                      onPressed: _markAllAsRead,
                      child: const Text(
                        "Mark all read",
                        style: TextStyle(
                          color: Color(0xFF3B82F6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          Expanded(
            child: notifications.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 64,
                    color: Color(0xFFD1D5DB),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "No notifications",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "You're all caught up!",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationItem(notification);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : const Color(0xFF3B82F6).withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.isRead
              ? const Color(0xFFE5E7EB)
              : const Color(0xFF3B82F6).withOpacity(0.2),
        ),
        boxShadow: notification.isRead ? null : [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (!notification.isRead) {
              _markAsRead(notification.id);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getNotificationTypeColor(notification.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getNotificationTypeColor(notification.type).withOpacity(0.2),
                    ),
                  ),
                  child: Icon(
                    _getNotificationTypeIcon(notification.type),
                    color: _getNotificationTypeColor(notification.type),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w700,
                                color: const Color(0xFF1F2937),
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF3B82F6),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.message,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          height: 1.4,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTimestamp(notification.timestamp),
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getNotificationTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.medication:
        return Icons.medication_rounded;
      case NotificationType.glucose:
        return Icons.monitor_heart_rounded;
      case NotificationType.exercise:
        return Icons.fitness_center_rounded;
      case NotificationType.appointment:
        return Icons.event_rounded;
      case NotificationType.report:
        return Icons.assessment_rounded;
      case NotificationType.general:
        return Icons.info_rounded;
    }
  }

  Color _getNotificationTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.medication:
        return const Color(0xFF3B82F6);
      case NotificationType.glucose:
        return const Color(0xFF10B981);
      case NotificationType.exercise:
        return const Color(0xFFEF4444);
      case NotificationType.appointment:
        return const Color(0xFFF59E0B);
      case NotificationType.report:
        return const Color(0xFF8B5CF6);
      case NotificationType.general:
        return const Color(0xFF6B7280);
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return "Just now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}h ago";
    } else if (difference.inDays < 7) {
      return "${difference.inDays}d ago";
    } else {
      return DateFormat('MMM dd, yyyy').format(timestamp);
    }
  }
}

class Note {
  final IconData icon;
  final String title;
  final String description;
  final DateTime time;

  Note(this.icon, this.title, this.description, this.time);
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea( // Add SafeArea to avoid system UI overlap
        child: Column(
          children: [
            // Fixed height header
            Container(
              height: 180, // Reduced from 200 to 180
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1E3A8A),
                    Color(0xFF3B82F6),
                    Color(0xFF06B6D4),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20), // Reduced padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                    ),
                    child: const CircleAvatar(
                      radius: 25, // Reduced from 28 to 25
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person_rounded, size: 28, color: Color(0xFF3B82F6)), // Reduced icon size
                    ),
                  ),
                  const SizedBox(height: 12), // Reduced spacing
                  const Text(
                    "VitalTracker",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22, // Reduced font size
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2), // Reduced spacing
                  Text(
                    "Health Monitoring",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13, // Reduced font size
                    ),
                  ),
                ],
              ),
            ),
            // Flexible list that can scroll if needed
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 4), // Reduced padding
                physics: const BouncingScrollPhysics(), // Add smooth scrolling
                children: [
                  _buildDrawerItem(context, Icons.dashboard_rounded, "Dashboard", true, null),
                  _buildDrawerItem(context, Icons.analytics_rounded, "Analytics", false, null),
                  _buildDrawerItem(context, Icons.note_rounded, "Notes", false, () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const NotesListScreen()));
                  }),
                  _buildDrawerItem(context, Icons.medication_liquid_rounded, "Medications", false, () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MedicationsScreen()));
                  }),
                  _buildDrawerItem(context, Icons.emergency_rounded, "Emergency", false, () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const EmergencyContactsScreen()));
                  }),
                  _buildDrawerItem(context, Icons.payment_rounded, "Payments", false, () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const PaymentMethodsPage()));
                  }),
                  _buildDrawerItem(context, Icons.privacy_tip_rounded, "Privacy", false, () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()));
                  }),
                  _buildDrawerItem(context, Icons.settings_rounded, "Settings", false, () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
                  }),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4), // Reduced padding
                    child: Divider(color: Color(0xFFE5E7EB)),
                  ),
                  _buildDrawerItem(context, Icons.help_rounded, "Help & Support", false, () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const HelpSupportScreen()));
                  }),
                  _buildDrawerItem(context, Icons.logout_rounded, "Logout", false, () {
                    Navigator.pushReplacementNamed(context, '/login');
                  }),
                  const SizedBox(height: 16), // Add bottom padding for better spacing
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, [bool isSelected = false, VoidCallback? onTap]) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 1), // Reduced vertical margin
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () {},
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Reduced vertical padding
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF3B82F6).withOpacity(0.1) : null,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7), // Slightly reduced padding
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF3B82F6).withOpacity(0.2)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF6B7280),
                    size: 18, // Slightly reduced icon size
                  ),
                ),
                const SizedBox(width: 14), // Reduced spacing
                Expanded( // Add Expanded to prevent overflow
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? const Color(0xFF1F2937) : const Color(0xFF6B7280),
                      fontSize: 15, // Slightly reduced font size
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
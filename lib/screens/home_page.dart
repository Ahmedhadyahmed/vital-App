import 'dart:ui';
import 'dart:math';
import 'dart:async';

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

// Notification Manager Class
class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  // Track exercise status
  bool isExercising = false;
  Timer? _exerciseTimer;
  DateTime? _lastExerciseTime;

  // Simulate glucose readings
  double _currentGlucose = 112.4;
  Timer? _glucoseTimer;
  final Random _random = Random();

  // Danger thresholds
  static const double lowGlucoseThreshold = 70.0;
  static const double highGlucoseThreshold = 180.0;
  static const Duration exerciseInactivityThreshold = Duration(hours: 24);

  // Callback to update notifications
  Function(List<NotificationItem>)? _updateCallback;
  List<NotificationItem> _notifications = [];

  void initialize(Function(List<NotificationItem>) updateCallback) {
    _updateCallback = updateCallback;

    // Start glucose simulation
    _glucoseTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _simulateGlucoseChange();
    });

    // Start exercise monitoring
    _exerciseTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkExerciseInactivity();
    });
  }

  void dispose() {
    _glucoseTimer?.cancel();
    _exerciseTimer?.cancel();
  }

  void _simulateGlucoseChange() {
    // Simulate natural glucose fluctuations
    final change = (_random.nextDouble() * 20) - 10; // -10 to +10
    _currentGlucose += change;

    // Add some randomness to readings
    if (_random.nextDouble() < 0.1) {
      _currentGlucose = _random.nextDouble() * 300; // Random spike/drop
    }

    // Clamp values to reasonable range
    _currentGlucose = _currentGlucose.clamp(40.0, 300.0);

    // Check for danger levels
    _checkGlucoseLevels();
  }

  void _checkGlucoseLevels() {
    if (_currentGlucose < lowGlucoseThreshold) {
      _addDangerNotification(
        "Low Glucose Alert!",
        "Your glucose level is critically low (${_currentGlucose.toStringAsFixed(1)} mg/dL). Consume fast-acting carbs immediately.",
        NotificationType.glucose,
      );
    }
    else if (_currentGlucose > highGlucoseThreshold) {
      _addDangerNotification(
        "High Glucose Alert!",
        "Your glucose level is dangerously high (${_currentGlucose.toStringAsFixed(1)} mg/dL). Take corrective action as directed.",
        NotificationType.glucose,
      );
    }
    else if (_currentGlucose > highGlucoseThreshold - 20) {
      // Approaching high threshold
      _addWarningNotification(
        "Elevated Glucose Level",
        "Your glucose is approaching high levels (${_currentGlucose.toStringAsFixed(1)} mg/dL). Monitor closely.",
        NotificationType.glucose,
      );
    }
    else if (_currentGlucose < lowGlucoseThreshold + 15) {
      // Approaching low threshold
      _addWarningNotification(
        "Low Glucose Warning",
        "Your glucose is approaching low levels (${_currentGlucose.toStringAsFixed(1)} mg/dL). Consider a snack.",
        NotificationType.glucose,
      );
    }
  }

  void _checkExerciseInactivity() {
    if (_lastExerciseTime == null) {
      _addGeneralNotification(
        "Exercise Reminder",
        "You haven't recorded any exercise yet today. Physical activity helps regulate glucose levels.",
        NotificationType.exercise,
      );
      return;
    }

    final timeSinceExercise = DateTime.now().difference(_lastExerciseTime!);

    if (timeSinceExercise > exerciseInactivityThreshold) {
      _addGeneralNotification(
        "Exercise Reminder",
        "It's been over 24 hours since your last exercise. Regular activity is important for your health.",
        NotificationType.exercise,
      );
    }
  }

  void startExercise() {
    isExercising = true;
    _lastExerciseTime = DateTime.now();

    // Add exercise notification
    _addGeneralNotification(
      "Exercise Started",
      "Your exercise session has begun. Stay hydrated and monitor your glucose levels.",
      NotificationType.exercise,
    );
  }

  void stopExercise() {
    if (!isExercising) return;

    isExercising = false;
    _lastExerciseTime = DateTime.now();

    // Add completion notification
    _addGeneralNotification(
      "Exercise Completed",
      "Great job completing your exercise session! Remember to check your glucose levels.",
      NotificationType.exercise,
    );
  }

  void _addDangerNotification(String title, String message, NotificationType type) {
    // Avoid duplicate alerts for the same issue
    final similarExists = _notifications.any((n) =>
    n.title == title &&
        DateTime.now().difference(n.timestamp) < const Duration(minutes: 5));

    if (!similarExists) {
      final newNotification = NotificationItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        message: message,
        type: type,
        timestamp: DateTime.now(),
        isRead: false,
        isCritical: true,
      );

      _addNotification(newNotification);
    }
  }

  void _addWarningNotification(String title, String message, NotificationType type) {
    final similarExists = _notifications.any((n) =>
    n.title == title &&
        DateTime.now().difference(n.timestamp) < const Duration(minutes: 15));

    if (!similarExists) {
      final newNotification = NotificationItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        message: message,
        type: type,
        timestamp: DateTime.now(),
        isRead: false,
        isCritical: false,
      );

      _addNotification(newNotification);
    }
  }

  void _addGeneralNotification(String title, String message, NotificationType type) {
    final newNotification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
      timestamp: DateTime.now(),
      isRead: false,
      isCritical: false,
    );

    _addNotification(newNotification);
  }

  void _addNotification(NotificationItem notification) {
    _notifications.insert(0, notification);

    // Limit to 50 notifications
    if (_notifications.length > 50) {
      _notifications = _notifications.sublist(0, 50);
    }

    // Update UI
    if (_updateCallback != null) {
      _updateCallback!(_notifications);
    }
  }

  double get currentGlucose => _currentGlucose;
  DateTime? get lastExerciseTime => _lastExerciseTime;
  List<NotificationItem> get notifications => _notifications;
}

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

  // Use the notification manager
  final NotificationManager notificationManager = NotificationManager();

  // Move notifications to state so they can be updated
  late List<NotificationItem> notifications;

  @override
  void initState() {
    super.initState();

    // Initialize with empty notifications
    notifications = [];

    // Initialize notification manager with update callback
    notificationManager.initialize((updatedNotifications) {
      setState(() {
        notifications = updatedNotifications;
      });
    });

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
    notificationManager.dispose();
    _headerAnimationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  // Method to update notifications state
  void _updateNotifications(List<NotificationItem> updatedNotifications) {
    setState(() {
      notifications = updatedNotifications;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String userName = "Alex Morgan";
    final double lastGlucose = notificationManager.currentGlucose;
    final DateTime lastReadingTime = DateTime.now();
    final String warningMessage = lastGlucose < NotificationManager.lowGlucoseThreshold
        ? "Low glucose warning! Take action."
        : lastGlucose > NotificationManager.highGlucoseThreshold
        ? "High glucose warning! Take action."
        : "";

    final List<Note> notes = [
      Note(Icons.free_breakfast_outlined, "Breakfast", "Took 8 units insulin with meal", DateTime.now().subtract(const Duration(hours: 2))),
      Note(Icons.medication_liquid, "Medication", "Morning dose completed", DateTime.now().subtract(const Duration(days: 1))),
      Note(Icons.fitness_center, "Exercise", "30 min cardio session", DateTime.now().subtract(const Duration(days: 2))),
    ];

    // Calculate unread count from state notifications
    final int unreadCount = notifications.where((n) => !n.isRead).length;

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
                  icon: unreadCount > 0
                      ? Badge(
                    backgroundColor: const Color(0xFFEF4444),
                    label: Text(
                      "$unreadCount",
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    child: const Icon(Icons.notifications_rounded, color: Colors.white),
                  )
                      : const Icon(Icons.notifications_rounded, color: Colors.white),
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
                                // Removed horizontal padding for glucose section to make it wider
                                _buildEnhancedGlucoseSection(
                                    lastGlucose, lastReadingTime, warningMessage),
                                const SizedBox(height: 24),
                                _buildActionCards(),
                                const SizedBox(height: 24),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
          Expanded(child: _buildQuickStatCard("Current Glucose", "${notificationManager.currentGlucose.toStringAsFixed(1)} mg/dL", Icons.monitor_heart_rounded, const Color(0xFF3B82F6))),
          const SizedBox(width: 12),
          Expanded(child: _buildQuickStatCard("Exercise Status", notificationManager.isExercising ? "Active" : "Inactive", Icons.directions_run_rounded, notificationManager.isExercising ? const Color(0xFF10B981) : const Color(0xFFEF4444))),
          const SizedBox(width: 12),
          Expanded(child: _buildQuickStatCard("Last Exercise", notificationManager.lastExerciseTime != null
              ? DateFormat('h:mm a').format(notificationManager.lastExerciseTime!)
              : "N/A", Icons.timer_rounded, const Color(0xFFF59E0B))),
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
        // Title row with left/right padding
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
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
        ),
        const SizedBox(height: 20),
        // Chart container spans full width with minimal horizontal padding
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0), // Minimal horizontal margin
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
                padding: const EdgeInsets.fromLTRB(12, 24, 12, 24), // Reduced horizontal padding for chart
                child: Column(
                  children: [
                    SizedBox(height: 220, child: _buildEnhancedGlucoseChart()),
                    const SizedBox(height: 24),
                    // Current reading info with normal padding
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12.0), // Add back some margin for this section
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
                      TextButton(
                        onPressed: () {
                          // Add action for warning
                          notificationManager._addGeneralNotification(
                            "Warning Acknowledged",
                            "You acknowledged the glucose warning",
                            NotificationType.general,
                          );
                        },
                        child: const Text(
                          "ACKNOWLEDGE",
                          style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontWeight: FontWeight.w700,
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
              "Start Exercise",
              "Begin your workout session",
              Icons.directions_run_rounded,
              const Color(0xFF10B981),
                  () {
                notificationManager.startExercise();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Exercise session started"),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionCard(
              "Stop Exercise",
              "End your current workout",
              Icons.stop_circle_rounded,
              const Color(0xFFEF4444),
                  () {
                notificationManager.stopExercise();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Exercise session completed"),
                    backgroundColor: Colors.green,
                  ),
                );
              },
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
    // Generate simulated glucose data
    final values = List.generate(15, (index) {
      final base = 110 + index * 2;
      final variation = Random().nextInt(20) - 10;
      return (base + variation).toDouble();
    });

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
    if (value < NotificationManager.lowGlucoseThreshold) return const Color(0xFFEF4444);
    if (value > NotificationManager.highGlucoseThreshold) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  String _getStatusText(double value) {
    if (value < NotificationManager.lowGlucoseThreshold) return "LOW";
    if (value > NotificationManager.highGlucoseThreshold) return "HIGH";
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
      builder: (context) => NotificationsModal(
        notifications: notifications,
        onNotificationsChanged: _updateNotifications,
      ),
    );
  }
}

// Enhanced Chart Painter - Updated with reduced padding for wider chart
class EnhancedHorizontalGlucoseChartPainter extends CustomPainter {
  final List<double> values;
  final double maxValue;
  final double minValue;

  EnhancedHorizontalGlucoseChartPainter(this.values, this.maxValue, this.minValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style: PaintingStyle.stroke;

    final fillPaint = Paint()
    ..shader = LinearGradient(
    colors: [
    const Color(0xFF3B82F6).withOpacity(0.2),
    const Color(0xFF06B6D4).withOpacity(0.1),
    const Color(0xFF06B6D4).withOpacity(0.05),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
    ..style: PaintingStyle.fill;

    final pointPaint = Paint()
    ..color = Colors.white
    ..style: PaintingStyle.fill;

    final pointBorderPaint = Paint()
    ..shader = const LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
    ..strokeWidth = 3
    ..style: PaintingStyle.stroke;

    // Reduced horizontal padding significantly
    final hPadding = 20.0;
    final width = size.width - (hPadding * 2);
    final height = size.height;
    final valueRange = maxValue - minValue;

    final path = Path();
    final pointRadius = 4.0;

    // Calculate points from left to right
    final points = values.asMap().entries.map((entry) {
    final i = entry.key;
    final value = entry.value;
    final x = hPadding + (width / (values.length - 1)) * i;
    final y = height - ((value - minValue) / valueRange) * height;
    return Offset(x, y);
    }).toList();

    if (points.isNotEmpty) {
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
    final currentPoint = points[i];
    final nextPoint = points[i + 1];
    final controlPointDistance = (nextPoint.dx - currentPoint.dx) * 0.4;

    final controlPoint1 = Offset(
    currentPoint.dx + controlPointDistance,
    currentPoint.dy,
    );

    final controlPoint2 = Offset(
    nextPoint.dx - controlPointDistance,
    nextPoint.dy,
    );

    path.cubicTo(
    controlPoint1.dx, controlPoint1.dy,
    controlPoint2.dx, controlPoint2.dy,
    nextPoint.dx, nextPoint.dy,
    );
    }
    }

    // Create fill path that goes to bottom of chart
    final fillPath = Path.from(path)
    ..lineTo(points.last.dx, height)
    ..lineTo(points.first.dx, height)
    ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    for (final point in points) {
    canvas.drawCircle(point, pointRadius, pointPaint);
    canvas.drawCircle(point, pointRadius, pointBorderPaint);
    }

    // Horizontal grid lines
    final gridPaint = Paint()
    ..color = const Color(0xFF3B82F6).withOpacity(0.1)
    ..strokeWidth = 1;

    for (int i = 1; i < 4; i++) {
    final y = height * i / 4;
    canvas.drawLine(Offset(hPadding, y), Offset(width + hPadding, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Notification data models and other classes
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
  final bool isCritical;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    required this.isRead,
    required this.isCritical,
  });
}

class NotificationsModal extends StatefulWidget {
  final List<NotificationItem> notifications;
  final Function(List<NotificationItem>) onNotificationsChanged;

  const NotificationsModal({
    super.key,
    required this.notifications,
    required this.onNotificationsChanged,
  });

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
          isCritical: notifications[index].isCritical,
        );
      }
    });
    // Update the parent widget's notifications
    widget.onNotificationsChanged(notifications);
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
        isCritical: notification.isCritical,
      )).toList();
    });
    // Update the parent widget's notifications
    widget.onNotificationsChanged(notifications);
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
            padding: const EdgeInsets.fromLTRB(12,24,12,24),
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
        color: notification.isRead
            ? Colors.white
            : notification.isCritical
            ? const Color(0xFFFEF2F2)
            : const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.isRead
              ? const Color(0xFFE5E7EB)
              : notification.isCritical
              ? const Color(0xFFFECACA)
              : const Color(0xFFBAE6FD),
        ),
        boxShadow: notification.isRead ? null : [
          BoxShadow(
            color: (notification.isCritical
                ? const Color(0xFFFECACA)
                : const Color(0xFFBAE6FD)).withOpacity(0.3),
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
                                color: notification.isCritical ? const Color(0xFFEF4444) : const Color(0xFF1F2937),
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: notification.isCritical ? const Color(0xFFEF4444) : const Color(0xFF3B82F6),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.message,
                        style: TextStyle(
                          color: notification.isCritical ? const Color(0xFFEF4444) : const Color(0xFF6B7280),
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
      child: SafeArea(
        child: Column(
          children: [
            Container(
              height: 180,
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
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                    ),
                    child: const CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person_rounded, size: 28, color: Color(0xFF3B82F6)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "VitalTracker",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Health Monitoring",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 4),
                physics: const BouncingScrollPhysics(),
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
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Divider(color: Color(0xFFE5E7EB)),
                  ),
                  _buildDrawerItem(context, Icons.help_rounded, "Help & Support", false, () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const HelpSupportScreen()));
                  }),
                  _buildDrawerItem(context, Icons.logout_rounded, "Logout", false, () {
                    Navigator.pushReplacementNamed(context, '/login');
                  }),
                  const SizedBox(height: 16),
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
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () {},
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF3B82F6).withOpacity(0.1) : null,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF3B82F6).withOpacity(0.2)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF6B7280),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? const Color(0xFF1F2937) : const Color(0xFF6B7280),
                      fontSize: 15,
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
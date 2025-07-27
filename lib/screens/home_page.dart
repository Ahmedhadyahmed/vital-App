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
import 'Settings.dart'; // Add this import

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
      Note(Icons.medication, "Medication", "Morning dose completed", DateTime.now().subtract(const Duration(days: 1))),
      Note(Icons.fitness_center, "Exercise", "30 min cardio session", DateTime.now().subtract(const Duration(days: 2))),
    ];

    // Sample notifications data
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
      NotificationItem(
        id: "4",
        title: "Doctor Appointment",
        message: "Checkup scheduled for tomorrow at 10:00 AM",
        type: NotificationType.appointment,
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        isRead: false,
      ),
      NotificationItem(
        id: "5",
        title: "Daily Report",
        message: "Your daily health summary is ready to view",
        type: NotificationType.report,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F8),
      drawer: const _AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF212121)),
        actions: [
          IconButton(
            icon: Badge(
              backgroundColor: const Color(0xFF036E41),
              label: Text(
                "${notifications.where((n) => !n.isRead).length}",
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              child: const Icon(Icons.notifications, color: Color(0xFF424242)),
            ),
            onPressed: () => _showNotificationsModal(context, notifications),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(userName),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildGlucoseSection(lastGlucose, lastReadingTime, warningMessage),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildNotesHeader(),
            ),
            const SizedBox(height: 12),
            ...notes.map((note) => _buildNoteCard(note)).toList(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showNotificationsModal(BuildContext context, List<NotificationItem> notifications) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NotificationsModal(notifications: notifications),
    );
  }

  Widget _buildHeader(String userName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF036E41), Color(0xFF389C7B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            ),
            child: const CircleAvatar(
              radius: 32,
              backgroundColor: Color(0xFFFFFFFF),
              child: Icon(Icons.person, size: 40, color: Color(0xFF036E41)),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hello, $userName", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                const Text("Your glucose levels are looking good today! Keep up your routine.",
                    style: TextStyle(color: Color(0xFFE8F5F0), fontSize: 14, height: 1.4)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGlucoseSection(double lastGlucose, DateTime readingTime, String warning) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Glucose Levels", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF212121))),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF036E41).withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: -4,
              )
            ],
            border: Border.all(color: const Color(0xFF389C7B).withOpacity(0.1)),
          ),
          child: Column(
            children: [
              SizedBox(height: 200, child: _buildGlucoseChart()),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("LAST READING", style: TextStyle(fontSize: 12, color: Color(0xFF616161), fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      Text("$lastGlucose mg/dL", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF212121))),
                      Text(DateFormat('MMM dd, hh:mm a').format(readingTime),
                          style: const TextStyle(color: Color(0xFF757575), fontSize: 13)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getStatusColor(lastGlucose).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: _getStatusColor(lastGlucose).withOpacity(0.3)),
                    ),
                    child: Text(_getStatusText(lastGlucose),
                        style: TextStyle(color: _getStatusColor(lastGlucose), fontWeight: FontWeight.w600, fontSize: 12)),
                  )
                ],
              ),
              if (warning.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF424242).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF424242).withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_rounded, color: Color(0xFF212121), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(warning, style: const TextStyle(color: Color(0xFF212121), fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ),
              ]
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGlucoseChart() {
    final values = [110, 140, 130, 112, 98, 105, 120, 115, 125, 118, 130, 140, 110, 95, 105];
    final maxValue = values.reduce((a, b) => a > b ? a : b).toDouble();
    final minValue = values.reduce((a, b) => a < b ? a : b).toDouble();

    return CustomPaint(painter: HorizontalGlucoseChartPainter(values, maxValue, minValue));
  }

  Color _getStatusColor(double value) {
    if (value < 70) return const Color(0xFF212121);
    if (value > 180) return const Color(0xFF424242);
    return const Color(0xFF036E41);
  }

  String _getStatusText(double value) {
    if (value < 70) return "LOW";
    if (value > 180) return "HIGH";
    return "NORMAL";
  }

  Widget _buildNotesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Recent Notes", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF212121))),
        TextButton(
            onPressed: () {},
            child: const Text("See all", style: TextStyle(color: Color(0xFF389C7B), fontSize: 14, fontWeight: FontWeight.w500))
        ),
      ],
    );
  }

  Widget _buildNoteCard(Note note) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: const Color(0xFF389C7B).withOpacity(0.15), width: 1),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getNoteIconColor(note.title).withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: _getNoteIconColor(note.title).withOpacity(0.2)),
            ),
            child: Icon(note.icon, color: _getNoteIconColor(note.title), size: 24),
          ),
          title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF212121), fontSize: 16)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Text(note.description, style: const TextStyle(color: Color(0xFF424242), height: 1.4)),
              const SizedBox(height: 6),
              Text(DateFormat('MMM dd, yyyy').format(note.time),
                  style: const TextStyle(color: Color(0xFF757575), fontSize: 12)),
            ],
          ),
          trailing: IconButton(
              icon: const Icon(Icons.more_vert, color: Color(0xFF757575)),
              onPressed: () {}
          ),
        ),
      ),
    );
  }

  Color _getNoteIconColor(String noteTitle) {
    switch (noteTitle.toLowerCase()) {
      case 'breakfast':
        return const Color(0xFF389C7B);
      case 'medication':
        return const Color(0xFF036E41);
      case 'exercise':
        return const Color(0xFF424242);
      default:
        return const Color(0xFF757575);
    }
  }
}

// Notification data models
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

// Notifications Modal Widget
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
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Notifications",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$unreadCount unread notifications",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
                if (unreadCount > 0)
                  TextButton(
                    onPressed: _markAllAsRead,
                    child: const Text(
                      "Mark all read",
                      style: TextStyle(
                        color: Color(0xFF036E41),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          // Notifications list
          Expanded(
            child: notifications.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Color(0xFFBDBDBD),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "No notifications",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF757575),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "You're all caught up!",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFBDBDBD),
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : const Color(0xFF036E41).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead
              ? const Color(0xFFE0E0E0)
              : const Color(0xFF036E41).withOpacity(0.2),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getNotificationTypeColor(notification.type).withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: _getNotificationTypeColor(notification.type).withOpacity(0.3),
            ),
          ),
          child: Icon(
            _getNotificationTypeIcon(notification.type),
            color: _getNotificationTypeColor(notification.type),
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: TextStyle(
                  fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w600,
                  color: const Color(0xFF212121),
                  fontSize: 16,
                ),
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF036E41),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              notification.message,
              style: const TextStyle(
                color: Color(0xFF424242),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatTimestamp(notification.timestamp),
              style: const TextStyle(
                color: Color(0xFF757575),
                fontSize: 12,
              ),
            ),
          ],
        ),
        onTap: () {
          if (!notification.isRead) {
            _markAsRead(notification.id);
          }
        },
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
        return const Color(0xFF036E41);
      case NotificationType.glucose:
        return const Color(0xFF389C7B);
      case NotificationType.exercise:
        return const Color(0xFF424242);
      case NotificationType.appointment:
        return const Color(0xFF757575);
      case NotificationType.report:
        return const Color(0xFF616161);
      case NotificationType.general:
        return const Color(0xFF757575);
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

class HorizontalGlucoseChartPainter extends CustomPainter {
  final List<int> values;
  final double maxValue;
  final double minValue;

  HorizontalGlucoseChartPainter(this.values, this.maxValue, this.minValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF036E41)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF036E41).withOpacity(0.3),
          const Color(0xFF389C7B).withOpacity(0.15),
          const Color(0xFF389C7B).withOpacity(0.05),
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final pointPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final pointBorderPaint = Paint()
      ..color = const Color(0xFF036E41)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    final pointRadius = 5.0;
    final width = size.width - 20;
    final height = size.height;
    final valueRange = maxValue - minValue;

    final points = values.asMap().entries.map((entry) {
      final i = entry.key;
      final value = entry.value;
      final y = (height / (values.length - 1)) * i;
      final x = ((value - minValue) / valueRange) * width;
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
      ..lineTo(0, points.last.dy)
      ..lineTo(0, points.first.dy)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    for (final point in points) {
      canvas.drawCircle(point, pointRadius, pointPaint);
      canvas.drawCircle(point, pointRadius, pointBorderPaint);
    }

    final guidePaint = Paint()
      ..color = const Color(0xFF389C7B).withOpacity(0.2)
      ..strokeWidth = 1;

    for (int i = 1; i < 4; i++) {
      final x = width * i / 4;
      canvas.drawLine(Offset(x, 0), Offset(x, height), guidePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
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
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF036E41), Color(0xFF389C7B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Color(0xFF036E41)),
                ),
                SizedBox(height: 16),
                Text("VitalTracker", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)),
                Text("Health Monitoring", style: TextStyle(color: Color(0xFFE8F5F0), fontSize: 14)),
              ],
            ),
          ),
          _buildDrawerItem(context, Icons.dashboard_rounded, "Dashboard", true, null),
          _buildDrawerItem(context, Icons.bar_chart_rounded, "Statistics", false, null),
          _buildDrawerItem(context, Icons.note_rounded, "Notes", false, () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const NotesListScreen()));
          }),
          _buildDrawerItem(context, Icons.medication_rounded, "Medications", false, () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MedicationsScreen()));
          }),
          // Added Emergency Contacts button
          _buildDrawerItem(context, Icons.emergency, "Emergency Contacts", false, () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const EmergencyContactsScreen()));
          }),
          _buildDrawerItem(context, Icons.payment_rounded, "Payment Methods", false, () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const PaymentMethodsPage()));
          }),
          _buildDrawerItem(context, Icons.privacy_tip_rounded, "Privacy Policy", false, () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()));
          }),
          _buildDrawerItem(context, Icons.settings_rounded, "Settings", false, () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
          }),
          const Divider(height: 32, color: Color(0xFFE0E0E0)),
          _buildDrawerItem(context, Icons.help_rounded, "Help & Support", false, () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const HelpSupportScreen()));
          }),
          _buildDrawerItem(context, Icons.logout_rounded, "Logout", false, () {
            Navigator.pushReplacementNamed(context, '/login');
          }),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, [bool isSelected = false, VoidCallback? onTap]) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? const Color(0xFF036E41) : const Color(0xFF757575)),
        title: Text(title,
            style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? const Color(0xFF212121) : const Color(0xFF424242))),
        tileColor: isSelected ? const Color(0xFF389C7B).withOpacity(0.08) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap ?? () {},
      ),
    );
  }
}
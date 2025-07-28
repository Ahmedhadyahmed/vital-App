import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';

// Improved data models with proper encapsulation
class HealthMetrics {
  final double currentGlucose;
  final DateTime lastReadingTime;
  final double todayAverage;
  final int readingsCount;
  final int streakDays;
  final HealthStatus status;

  const HealthMetrics({
    required this.currentGlucose,
    required this.lastReadingTime,
    required this.todayAverage,
    required this.readingsCount,
    required this.streakDays,
    required this.status,
  });

  String get warningMessage {
    switch (status) {
      case HealthStatus.low:
        return "Low glucose warning! Consider having a snack.";
      case HealthStatus.high:
        return "High glucose warning! Monitor closely and consult your healthcare provider.";
      case HealthStatus.normal:
        return "";
    }
  }

  Color get statusColor {
    switch (status) {
      case HealthStatus.low:
        return const Color(0xFFEF4444);
      case HealthStatus.high:
        return const Color(0xFFF59E0B);
      case HealthStatus.normal:
        return const Color(0xFF10B981);
    }
  }

  String get statusText {
    switch (status) {
      case HealthStatus.low:
        return "LOW";
      case HealthStatus.high:
        return "HIGH";
      case HealthStatus.normal:
        return "NORMAL";
    }
  }
}

enum HealthStatus { low, normal, high }

class HealthNote {
  final String id;
  final IconData icon;
  final String title;
  final String description;
  final DateTime timestamp;
  final NoteType type;

  const HealthNote({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
  });

  Color get iconColor {
    switch (type) {
      case NoteType.meal:
        return const Color(0xFF10B981);
      case NoteType.medication:
        return const Color(0xFF3B82F6);
      case NoteType.exercise:
        return const Color(0xFFEF4444);
      case NoteType.general:
        return const Color(0xFF6B7280);
    }
  }
}

enum NoteType { meal, medication, exercise, general }

class UserProfile {
  final String name;
  final String? avatarUrl;

  const UserProfile({
    required this.name,
    this.avatarUrl,
  });
}

// Improved HomePage with better architecture
class ImprovedHomePage extends StatefulWidget {
  final UserProfile userProfile;
  final HealthMetrics healthMetrics;
  final List<HealthNote> recentNotes;

  const ImprovedHomePage({
    super.key,
    required this.userProfile,
    required this.healthMetrics,
    required this.recentNotes,
  });

  @override
  State<ImprovedHomePage> createState() => _ImprovedHomePageState();
}

class _ImprovedHomePageState extends State<ImprovedHomePage>
    with TickerProviderStateMixin {
  late final AnimationController _headerController;
  late final AnimationController _contentController;
  late final Animation<double> _headerAnimation;
  late final Animation<double> _contentAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    );

    _contentAnimation = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutBack,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() {
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _contentController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: _buildMenuButton(),
      actions: [_buildNotificationButton()],
      flexibleSpace: FlexibleSpaceBar(
        background: AnimatedBuilder(
          animation: _headerAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: 0.9 + (0.1 * _headerAnimation.value),
              child: Opacity(
                opacity: _headerAnimation.value,
                child: HeaderSection(
                  userProfile: widget.userProfile,
                  healthMetrics: widget.healthMetrics,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenuButton() {
    return Semantics(
      label: 'Open navigation menu',
      button: true,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white),
          onPressed: () {
            // TODO: Implement navigation drawer
          },
        ),
      ),
    );
  }

  Widget _buildNotificationButton() {
    return Semantics(
      label: 'View notifications',
      button: true,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Badge(
            backgroundColor: Color(0xFFEF4444),
            label: Text('2', style: TextStyle(color: Colors.white, fontSize: 12)),
            child: Icon(Icons.notifications_rounded, color: Colors.white),
          ),
          onPressed: () {
            // TODO: Implement notifications modal
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _contentAnimation,
        builder: (context, child) {
          return SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _contentAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    QuickStatsSection(healthMetrics: widget.healthMetrics),
                    const SizedBox(height: 24),
                    GlucoseMonitoringSection(healthMetrics: widget.healthMetrics),
                    const SizedBox(height: 24),
                    const ActionCardsSection(),
                    const SizedBox(height: 24),
                    RecentNotesSection(notes: widget.recentNotes),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Extracted Header Section Component
class HeaderSection extends StatelessWidget {
  final UserProfile userProfile;
  final HealthMetrics healthMetrics;

  const HeaderSection({
    super.key,
    required this.userProfile,
    required this.healthMetrics,
  });

  @override
  Widget build(BuildContext context) {
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
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserGreeting(),
          const SizedBox(height: 24),
          _buildHealthSummaryCard(),
        ],
      ),
    );
  }

  Widget _buildUserGreeting() {
    return Semantics(
      label: 'User profile section',
      child: Row(
        children: [
          _buildUserAvatar(),
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
                  userProfile.name,
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
    );
  }

  Widget _buildUserAvatar() {
    return Semantics(
      label: 'User avatar for ${userProfile.name}',
      child: Hero(
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
          child: CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white,
            backgroundImage: userProfile.avatarUrl != null
                ? NetworkImage(userProfile.avatarUrl!)
                : null,
            child: userProfile.avatarUrl == null
                ? const Icon(Icons.person_rounded, size: 42, color: Color(0xFF3B82F6))
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildHealthSummaryCard() {
    return Semantics(
      label: 'Health summary: ${healthMetrics.statusText} glucose level',
      child: Container(
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
                color: healthMetrics.statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.favorite_rounded,
                color: Colors.white,
                size: 20,
                semanticLabel: 'Health status indicator',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                healthMetrics.status == HealthStatus.normal
                    ? "Your health metrics are looking great today! Keep up the excellent work."
                    : "Please monitor your glucose levels closely and follow your care plan.",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Morning";
    if (hour < 17) return "Afternoon";
    return "Evening";
  }
}

// Extracted Quick Stats Section Component
class QuickStatsSection extends StatelessWidget {
  final HealthMetrics healthMetrics;

  const QuickStatsSection({
    super.key,
    required this.healthMetrics,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Quick health statistics',
      child: Row(
        children: [
          Expanded(
            child: _QuickStatCard(
              title: "Today's Average",
              value: "${healthMetrics.todayAverage.toStringAsFixed(1)} mg/dL",
              icon: Icons.trending_up_rounded,
              color: const Color(0xFF10B981),
              semanticLabel: "Today's average glucose: ${healthMetrics.todayAverage.toStringAsFixed(1)} milligrams per deciliter",
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickStatCard(
              title: "Readings",
              value: "${healthMetrics.readingsCount}",
              icon: Icons.timeline_rounded,
              color: const Color(0xFF3B82F6),
              semanticLabel: "${healthMetrics.readingsCount} glucose readings today",
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickStatCard(
              title: "Streak",
              value: "${healthMetrics.streakDays} days",
              icon: Icons.local_fire_department_rounded,
              color: const Color(0xFFEF4444),
              semanticLabel: "${healthMetrics.streakDays} day monitoring streak",
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String semanticLabel;

  const _QuickStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: Container(
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
      ),
    );
  }
}

// Extracted Glucose Monitoring Section Component
class GlucoseMonitoringSection extends StatelessWidget {
  final HealthMetrics healthMetrics;

  const GlucoseMonitoringSection({
    super.key,
    required this.healthMetrics,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(),
        const SizedBox(height: 20),
        _buildGlucoseCard(),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Semantics(
      header: true,
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
    );
  }

  Widget _buildGlucoseCard() {
    return Container(
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
          _buildGlucoseReading(),
          if (healthMetrics.warningMessage.isNotEmpty) _buildWarningMessage(),
        ],
      ),
    );
  }

  Widget _buildGlucoseReading() {
    return Semantics(
      label: 'Current glucose reading: ${healthMetrics.currentGlucose} milligrams per deciliter, ${healthMetrics.statusText} level, measured at ${DateFormat('MMM dd, hh:mm a').format(healthMetrics.lastReadingTime)}',
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                healthMetrics.statusColor.withOpacity(0.05),
                healthMetrics.statusColor.withOpacity(0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: healthMetrics.statusColor.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: healthMetrics.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.monitor_heart_rounded,
                  color: healthMetrics.statusColor,
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
                      "${healthMetrics.currentGlucose} mg/dL",
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2937),
                        letterSpacing: -1,
                      ),
                    ),
                    Text(
                      DateFormat('MMM dd, hh:mm a').format(healthMetrics.lastReadingTime),
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
                  color: healthMetrics.statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  healthMetrics.statusText,
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
      ),
    );
  }

  Widget _buildWarningMessage() {
    return Semantics(
      label: 'Warning: ${healthMetrics.warningMessage}',
      liveRegion: true,
      child: Container(
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
                healthMetrics.warningMessage,
                style: const TextStyle(
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extracted Action Cards Section Component
class ActionCardsSection extends StatelessWidget {
  const ActionCardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Quick actions',
      child: Row(
        children: [
          Expanded(
            child: _ActionCard(
              title: "Log Reading",
              subtitle: "Add new glucose measurement",
              icon: Icons.add_circle_outline_rounded,
              color: const Color(0xFF3B82F6),
              onTap: () {
                // TODO: Navigate to log reading screen
              },
              semanticLabel: "Log new glucose reading",
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionCard(
              title: "Add Note",
              subtitle: "Record health observation",
              icon: Icons.note_add_rounded,
              color: const Color(0xFF10B981),
              onTap: () {
                // TODO: Navigate to add note screen
              },
              semanticLabel: "Add health note",
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String semanticLabel;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: Material(
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
      ),
    );
  }
}

// Extracted Recent Notes Section Component
class RecentNotesSection extends StatelessWidget {
  final List<HealthNote> notes;

  const RecentNotesSection({
    super.key,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(),
        const SizedBox(height: 16),
        ...notes.map((note) => _NoteCard(note: note)).toList(),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Semantics(
      header: true,
      child: Row(
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
          Semantics(
            label: "View all recent activity",
            button: true,
            child: TextButton.icon(
              onPressed: () {
                // TODO: Navigate to all notes screen
              },
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: const Text("View All"),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF3B82F6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final HealthNote note;

  const _NoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${note.title}: ${note.description}, ${DateFormat('MMM dd, yyyy').format(note.timestamp)}',
      button: true,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: note.iconColor.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: note.iconColor.withOpacity(0.1)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // TODO: Navigate to note details
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: note.iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: note.iconColor.withOpacity(0.2)),
                    ),
                    child: Icon(
                      note.icon,
                      color: note.iconColor,
                      size: 24,
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
                            DateFormat('MMM dd, yyyy').format(note.timestamp),
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
      ),
    );
  }
}

// Example usage with sample data
class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VitalTracker - Improved',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'SF Pro Display',
      ),
      home: ImprovedHomePage(
        userProfile: const UserProfile(name: "Alex Morgan"),
        healthMetrics: HealthMetrics(
          currentGlucose: 112.4,
          lastReadingTime: DateTime.now().subtract(const Duration(minutes: 15)),
          todayAverage: 118.0,
          readingsCount: 12,
          streakDays: 7,
          status: HealthStatus.normal,
        ),
        recentNotes: [
          HealthNote(
            id: "1",
            icon: Icons.free_breakfast_outlined,
            title: "Breakfast",
            description: "Took 8 units insulin with meal",
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            type: NoteType.meal,
          ),
          HealthNote(
            id: "2",
            icon: Icons.medication_liquid,
            title: "Medication",
            description: "Morning dose completed",
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            type: NoteType.medication,
          ),
          HealthNote(
            id: "3",
            icon: Icons.fitness_center,
            title: "Exercise",
            description: "30 min cardio session",
            timestamp: DateTime.now().subtract(const Duration(days: 2)),
            type: NoteType.exercise,
          ),
        ],
      ),
    );
  }
}


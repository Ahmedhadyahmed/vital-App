import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _cardAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Medication> _medications = [
    Medication(
      name: 'Metformin',
      dosage: '500mg',
      frequency: 'Twice daily',
      purpose: 'Blood sugar control',
      doctor: 'Dr. Sarah Johnson',
      lastTaken: DateTime.now().subtract(const Duration(hours: 5)),
      category: MedicationCategory.diabetes,
      nextDue: DateTime.now().add(const Duration(hours: 3)),
    ),
    Medication(
      name: 'Insulin Glargine',
      dosage: '20 units',
      frequency: 'Once daily at bedtime',
      purpose: 'Long-acting insulin',
      doctor: 'Dr. Michael Chen',
      lastTaken: DateTime.now().subtract(const Duration(hours: 12)),
      category: MedicationCategory.insulin,
      nextDue: DateTime.now().add(const Duration(hours: 12)),
    ),
    Medication(
      name: 'Empagliflozin',
      dosage: '10mg',
      frequency: 'Once daily',
      purpose: 'Reduce blood sugar',
      doctor: 'Dr. Sarah Johnson',
      lastTaken: DateTime.now().subtract(const Duration(days: 1)),
      category: MedicationCategory.diabetes,
      nextDue: DateTime.now().add(const Duration(hours: 2)),
    ),
  ];

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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Enhanced App Bar
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
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
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
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
                  icon: const Icon(Icons.add_rounded, color: Colors.white),
                  onPressed: _showAddMedicationModal,
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
                      child: _buildEnhancedHeader(),
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
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          _buildQuickStatsRow(),
                          const SizedBox(height: 32),
                          _buildDoctorCard(),
                          const SizedBox(height: 32),
                          _buildSectionTitle("Your Medications", "${_medications.length} active"),
                          const SizedBox(height: 20),
                          ..._medications.asMap().entries.map((entry) {
                            final index = entry.key;
                            final medication = entry.value;
                            return AnimatedContainer(
                              duration: Duration(milliseconds: 200 + (index * 100)),
                              child: _buildEnhancedMedicationCard(medication, index),
                            );
                          }).toList(),
                          const SizedBox(height: 32),
                          _buildAddButton(),
                          const SizedBox(height: 32),
                        ],
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

  Widget _buildEnhancedHeader() {
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
                  tag: 'medication_icon',
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.medication_liquid_rounded,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "My Medications",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Stay on track with your health",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsRow() {
    final nextMed = _medications.where((m) => m.nextDue.isAfter(DateTime.now())).isNotEmpty
        ? _medications.where((m) => m.nextDue.isAfter(DateTime.now())).reduce((a, b) => a.nextDue.isBefore(b.nextDue) ? a : b)
        : null;

    final timeUntilNext = nextMed != null
        ? nextMed.nextDue.difference(DateTime.now()).inHours
        : 0;

    return Row(
      children: [
        Expanded(
          child: _buildQuickStatCard(
              "Total Meds",
              "${_medications.length}",
              Icons.medication_rounded,
              const Color(0xFF3B82F6)
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickStatCard(
              "Next Due",
              timeUntilNext > 0 ? "${timeUntilNext}h" : "Now",
              Icons.schedule_rounded,
              timeUntilNext <= 2 ? const Color(0xFFEF4444) : const Color(0xFF10B981)
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickStatCard(
              "Taken Today",
              "3",
              Icons.check_circle_rounded,
              const Color(0xFF10B981)
          ),
        ),
      ],
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

  Widget _buildSectionTitle(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
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
          child: Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF3B82F6),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorCard() {
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
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Hero(
                tag: 'doctor_avatar',
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2), width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 32,
                    backgroundColor: Color(0xFF3B82F6),
                    child: Icon(Icons.person_rounded, size: 32, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "PRIMARY PHYSICIAN",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Dr. Sarah Johnson",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Endocrinologist • 12 years exp.",
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF6B7280).withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.phone_rounded, size: 18),
                  label: const Text("Call Doctor"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.message_rounded, size: 18),
                  label: const Text("Message"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF3B82F6),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFF3B82F6)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedMedicationCard(Medication medication, int index) {
    final isOverdue = medication.nextDue.isBefore(DateTime.now());
    final isDueSoon = medication.nextDue.difference(DateTime.now()).inHours <= 2;

    Color statusColor = const Color(0xFF10B981);
    if (isOverdue) statusColor = const Color(0xFFEF4444);
    else if (isDueSoon) statusColor = const Color(0xFFF59E0B);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: statusColor.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showMedicationDetails(medication),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Hero(
                      tag: 'medication_icon_$index',
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(medication.category).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _getCategoryColor(medication.category).withOpacity(0.2),
                          ),
                        ),
                        child: Icon(
                          _getCategoryIcon(medication.category),
                          color: _getCategoryColor(medication.category),
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
                            medication.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            medication.dosage,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _getCategoryColor(medication.category),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withOpacity(0.2)),
                      ),
                      child: Text(
                        isOverdue ? "Overdue" : isDueSoon ? "Due Soon" : "On Track",
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDetailRow(Icons.schedule_rounded, medication.frequency),
                _buildDetailRow(Icons.medical_services_rounded, medication.purpose),
                _buildDetailRow(Icons.person_rounded, 'Dr. ${medication.doctor.split(' ').last}'),
                _buildDetailRow(
                    Icons.access_time_rounded,
                    'Next: ${DateFormat('MMM dd, hh:mm a').format(medication.nextDue)}'
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () => _logMedicationTaken(medication),
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: const Text("Mark Taken"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _setReminder(medication),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6B7280),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Icon(Icons.notification_add_rounded, size: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF6B7280)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3B82F6),
            Color(0xFF06B6D4),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _showAddMedicationModal,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          "Add New Medication",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(MedicationCategory category) {
    switch (category) {
      case MedicationCategory.diabetes:
        return const Color(0xFF3B82F6);
      case MedicationCategory.insulin:
        return const Color(0xFF10B981);
      case MedicationCategory.bloodPressure:
        return const Color(0xFFEF4444);
      case MedicationCategory.cholesterol:
        return const Color(0xFFF59E0B);
      case MedicationCategory.other:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getCategoryIcon(MedicationCategory category) {
    switch (category) {
      case MedicationCategory.diabetes:
        return Icons.bloodtype_rounded;
      case MedicationCategory.insulin:
        return Icons.vaccines_rounded;
      case MedicationCategory.bloodPressure:
        return Icons.favorite_rounded;
      case MedicationCategory.cholesterol:
        return Icons.health_and_safety_rounded;
      case MedicationCategory.other:
        return Icons.medication_rounded;
    }
  }

  void _logMedicationTaken(Medication medication) {
    setState(() {
      medication.lastTaken = DateTime.now();
      medication.nextDue = _calculateNextDue(medication);
    });

    // Show success animation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Text('${medication.name} marked as taken'),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _setReminder(Medication medication) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.notifications_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Text('Reminder set for ${medication.name}'),
          ],
        ),
        backgroundColor: const Color(0xFF3B82F6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showMedicationDetails(Medication medication) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MedicationDetailsModal(medication: medication),
    );
  }

  DateTime _calculateNextDue(Medication medication) {
    // Simple calculation - in a real app, this would be more sophisticated
    if (medication.frequency.contains('Twice')) {
      return DateTime.now().add(const Duration(hours: 12));
    } else if (medication.frequency.contains('Once')) {
      return DateTime.now().add(const Duration(hours: 24));
    }
    return DateTime.now().add(const Duration(hours: 8));
  }

  void _showAddMedicationModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddMedicationModal(
        onAddMedication: (medication) {
          setState(() {
            _medications.add(medication);
          });
        },
      ),
    );
  }
}

enum MedicationCategory {
  diabetes,
  insulin,
  bloodPressure,
  cholesterol,
  other,
}

class Medication {
  String name;
  String dosage;
  String frequency;
  String purpose;
  String doctor;
  DateTime lastTaken;
  MedicationCategory category;
  DateTime nextDue;

  Medication({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.purpose,
    required this.doctor,
    required this.lastTaken,
    required this.category,
    required this.nextDue,
  });
}

class AddMedicationModal extends StatefulWidget {
  final Function(Medication) onAddMedication;

  const AddMedicationModal({super.key, required this.onAddMedication});

  @override
  State<AddMedicationModal> createState() => _AddMedicationModalState();
}

class _AddMedicationModalState extends State<AddMedicationModal> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _purposeController = TextEditingController();
  final _doctorController = TextEditingController();
  MedicationCategory _selectedCategory = MedicationCategory.other;

  final List<String> _frequencyOptions = [
    'Once daily',
    'Twice daily',
    'Three times daily',
    'Four times daily',
    'Every 8 hours',
    'Every 12 hours',
    'As needed',
    'Weekly',
    'Monthly',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              "Add New Medication",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildTextField("Medication Name", _nameController, Icons.medication_rounded),
                  const SizedBox(height: 16),
                  _buildTextField("Dosage (e.g., 500mg, 20 units)", _dosageController, Icons.monitor_weight_rounded),
                  const SizedBox(height: 16),
                  _buildFrequencyDropdown(),
                  const SizedBox(height: 16),
                  _buildTextField("Purpose", _purposeController, Icons.medical_services_rounded),
                  const SizedBox(height: 16),
                  _buildTextField("Doctor Name", _doctorController, Icons.person_rounded),
                  const SizedBox(height: 16),
                  _buildCategoryDropdown(),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _addMedication,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Add Medication",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF6B7280)),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencyDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Frequency",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            value: _frequencyController.text.isEmpty ? null : _frequencyController.text,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.schedule_rounded, color: Color(0xFF6B7280)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 16),
            ),
            hint: const Text("Select frequency"),
            items: _frequencyOptions.map((String frequency) {
              return DropdownMenuItem<String>(
                value: frequency,
                child: Text(frequency),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _frequencyController.text = newValue ?? '';
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    final categoryNames = {
      MedicationCategory.diabetes: 'Diabetes',
      MedicationCategory.insulin: 'Insulin',
      MedicationCategory.bloodPressure: 'Blood Pressure',
      MedicationCategory.cholesterol: 'Cholesterol',
      MedicationCategory.other: 'Other',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Category",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<MedicationCategory>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.category_rounded, color: Color(0xFF6B7280)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 16),
            ),
            items: MedicationCategory.values.map((MedicationCategory category) {
              return DropdownMenuItem<MedicationCategory>(
                value: category,
                child: Row(
                  children: [
                    Icon(
                      _getCategoryIcon(category),
                      color: _getCategoryColor(category),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(categoryNames[category]!),
                  ],
                ),
              );
            }).toList(),
            onChanged: (MedicationCategory? newValue) {
              setState(() {
                _selectedCategory = newValue ?? MedicationCategory.other;
              });
            },
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(MedicationCategory category) {
    switch (category) {
      case MedicationCategory.diabetes:
        return const Color(0xFF3B82F6);
      case MedicationCategory.insulin:
        return const Color(0xFF10B981);
      case MedicationCategory.bloodPressure:
        return const Color(0xFFEF4444);
      case MedicationCategory.cholesterol:
        return const Color(0xFFF59E0B);
      case MedicationCategory.other:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getCategoryIcon(MedicationCategory category) {
    switch (category) {
      case MedicationCategory.diabetes:
        return Icons.bloodtype_rounded;
      case MedicationCategory.insulin:
        return Icons.vaccines_rounded;
      case MedicationCategory.bloodPressure:
        return Icons.favorite_rounded;
      case MedicationCategory.cholesterol:
        return Icons.health_and_safety_rounded;
      case MedicationCategory.other:
        return Icons.medication_rounded;
    }
  }

  void _addMedication() {
    if (_nameController.text.isEmpty ||
        _dosageController.text.isEmpty ||
        _frequencyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          margin: EdgeInsets.all(16),
        ),
      );
      return;
    }

    final newMedication = Medication(
      name: _nameController.text,
      dosage: _dosageController.text,
      frequency: _frequencyController.text,
      purpose: _purposeController.text.isEmpty ? 'Not specified' : _purposeController.text,
      doctor: _doctorController.text.isEmpty ? 'Not specified' : _doctorController.text,
      lastTaken: DateTime.now().subtract(const Duration(days: 1)), // Default to yesterday
      category: _selectedCategory,
      nextDue: _calculateNextDueForNewMedication(_frequencyController.text),
    );

    widget.onAddMedication(newMedication);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Text('${newMedication.name} added successfully'),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  DateTime _calculateNextDueForNewMedication(String frequency) {
    final now = DateTime.now();

    if (frequency.contains('Once daily')) {
      return DateTime(now.year, now.month, now.day, 8, 0); // 8 AM tomorrow
    } else if (frequency.contains('Twice daily')) {
      return DateTime(now.year, now.month, now.day, 8, 0); // 8 AM today
    } else if (frequency.contains('Three times daily')) {
      return DateTime(now.year, now.month, now.day, 8, 0); // 8 AM today
    } else if (frequency.contains('Four times daily')) {
      return DateTime(now.year, now.month, now.day, 8, 0); // 8 AM today
    } else if (frequency.contains('Every 8 hours')) {
      return now.add(const Duration(hours: 8));
    } else if (frequency.contains('Every 12 hours')) {
      return now.add(const Duration(hours: 12));
    } else if (frequency.contains('Weekly')) {
      return now.add(const Duration(days: 7));
    } else if (frequency.contains('Monthly')) {
      return DateTime(now.year, now.month + 1, now.day, now.hour, now.minute);
    } else {
      return now.add(const Duration(hours: 24)); // Default to 24 hours
    }
  }
}

class MedicationDetailsModal extends StatelessWidget {
  final Medication medication;

  const MedicationDetailsModal({super.key, required this.medication});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medication.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    medication.dosage,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildDetailSection("Frequency", medication.frequency, Icons.schedule_rounded),
                  const SizedBox(height: 16),
                  _buildDetailSection("Purpose", medication.purpose, Icons.medical_services_rounded),
                  const SizedBox(height: 16),
                  _buildDetailSection("Prescribed by", medication.doctor, Icons.person_rounded),
                  const SizedBox(height: 16),
                  _buildDetailSection(
                      "Last taken",
                      DateFormat('MMM dd, yyyy at hh:mm a').format(medication.lastTaken),
                      Icons.history_rounded
                  ),
                  const SizedBox(height: 16),
                  _buildDetailSection(
                      "Next due",
                      DateFormat('MMM dd, yyyy at hh:mm a').format(medication.nextDue),
                      Icons.access_time_rounded
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.edit_rounded),
                          label: const Text("Edit Details"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF3B82F6),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Color(0xFF3B82F6)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.delete_rounded),
                          label: const Text("Remove"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF3B82F6), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
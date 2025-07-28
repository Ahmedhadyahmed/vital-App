import 'package:flutter/material.dart';
import 'package:vital/screens/privacy_policy.dart';
import 'AppThemeScreen.dart';
import 'LanguageSettingsScreen.dart';
import 'NotificationSettingsScreen.dart';
import 'ProfileInfoScreen.dart';
import 'number confirmation.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _backupEnabled = true;
  bool _restoreEnabled = true;

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
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1F2937),
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Settings',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  color: Color(0xFF1F2937),
                ),
              ),
              centerTitle: true,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white, Color(0xFFF8FAFB)],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Account Settings Card
                    _buildSettingsCard(
                      title: 'Account Settings',
                      icon: Icons.person_4_rounded,
                      color: const Color(0xFF3B82F6),
                      children: [
                        _buildModernSettingsItem(
                          icon: Icons.account_circle_outlined,
                          title: 'Profile Information',
                          subtitle: 'Manage your personal details',
                          iconColor: const Color(0xFF3B82F6),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProfileInfoScreen()),
                          ),
                        ),
                        _buildModernSettingsItem(
                          icon: Icons.notifications_none_rounded,
                          title: 'Notifications',
                          subtitle: 'Configure your alerts',
                          iconColor: const Color(0xFF8B5CF6),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NotificationSettingsScreen()),
                          ),
                        ),
                        _buildModernSettingsItem(
                          icon: Icons.lock_outline_rounded,
                          title: 'Security',
                          subtitle: 'Password and authentication',
                          iconColor: const Color(0xFFEF4444),
                          isLast: true,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // App Preferences Card
                    _buildSettingsCard(
                      title: 'App Preferences',
                      icon: Icons.tune_rounded,
                      color: const Color(0xFF10B981),
                      children: [
                        _buildModernSettingsItem(
                          icon: Icons.palette_outlined,
                          title: 'Theme',
                          subtitle: 'Customize your experience',
                          iconColor: const Color(0xFF10B981),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AppThemeScreen()),
                          ),
                        ),
                        _buildModernSettingsItem(
                          icon: Icons.language_rounded,
                          title: 'Language',
                          subtitle: 'Change app language',
                          iconColor: const Color(0xFFF59E0B),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LanguageSettingsScreen()),
                          ),
                        ),
                        _buildModernSettingsItem(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy Policy',
                          subtitle: 'Terms and conditions',
                          iconColor: const Color(0xFF6B7280),
                          isLast: true,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Data Management Card
                    _buildSettingsCard(
                      title: 'Data Management',
                      icon: Icons.storage_rounded,
                      color: const Color(0xFF8B5CF6),
                      children: [
                        _buildModernSettingsItem(
                          icon: Icons.cloud_upload_outlined,
                          title: 'Backup Data',
                          subtitle: 'Automatically save your data',
                          iconColor: const Color(0xFF3B82F6),
                          hasSwitch: true,
                          switchValue: _backupEnabled,
                          onSwitchChanged: (value) {
                            setState(() {
                              _backupEnabled = value;
                            });
                          },
                          onTap: () {},
                        ),
                        _buildModernSettingsItem(
                          icon: Icons.cloud_download_outlined,
                          title: 'Restore Data',
                          subtitle: 'Recover from backup',
                          iconColor: const Color(0xFF10B981),
                          hasSwitch: true,
                          switchValue: _restoreEnabled,
                          onSwitchChanged: (value) {
                            setState(() {
                              _restoreEnabled = value;
                            });
                          },
                          onTap: () {},
                        ),
                        _buildModernSettingsItem(
                          icon: Icons.cleaning_services_outlined,
                          title: 'Clear Cache',
                          subtitle: 'Free up storage space',
                          iconColor: const Color(0xFFEF4444),
                          isLast: true,
                          onTap: () => _showClearCacheDialog(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Enhanced Logout Button
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => _showLogoutDialog(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFEF4444),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: const Color(0xFFEF4444).withOpacity(0.2)),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.logout_rounded, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildModernSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
    bool isLast = false,
    bool hasSwitch = false,
    bool switchValue = false,
    Function(bool)? onSwitchChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: isLast ? 20 : 0,
      ),
      decoration: BoxDecoration(
        border: isLast ? null : Border(
          bottom: BorderSide(
            color: const Color(0xFFF3F4F6),
            width: 1,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: hasSwitch ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasSwitch)
                  Switch.adaptive(
                    value: switchValue,
                    onChanged: onSwitchChanged,
                    activeColor: iconColor,
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: const Color(0xFF6B7280)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Clear Cache',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: const Text('This will clear all cached data. Continue?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: const Color(0xFF6B7280)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Add your clear cache logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cache cleared successfully'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }
}
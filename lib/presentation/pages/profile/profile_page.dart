import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../state/settings_provider.dart';
import '../../state/dryer_provider.dart';
import 'device_sharing_page.dart';
import 'device_health_page.dart';
import 'history_page.dart';
import 'document_view_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final dryerProvider = Provider.of<DryerProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          children: [
            // Mockup Profile Header Card
            _buildProfileHeader(context, settingsProvider, isDark),
            const SizedBox(height: 16),

            // Settings options list
            _buildListItem(
              icon: Icons.person_outline,
              title: 'Profile Information',
              onTap: () => _showEditProfileSheet(context, settingsProvider, isDark),
              isDark: isDark,
            ),
            _buildListItem(
              icon: Icons.share_outlined,
              title: 'Device Sharing',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DeviceSharingPage()),
                );
              },
              isDark: isDark,
            ),
            _buildListItem(
              icon: Icons.health_and_safety_outlined,
              title: 'Device Health',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DeviceHealthPage()),
                );
              },
              isDark: isDark,
            ),
            _buildListItem(
              icon: Icons.history,
              title: 'History',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryPage()),
                );
              },
              isDark: isDark,
            ),
            _buildListItem(
              icon: Icons.notifications_none_outlined,
              title: 'Notification Settings',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Push notifications are configured under local OS settings.')),
                );
              },
              isDark: isDark,
            ),
            _buildListItem(
              icon: Icons.gavel_outlined,
              title: 'Terms & Conditions',
              onTap: () => _openTermsPage(context),
              isDark: isDark,
            ),
            _buildListItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () => _openPrivacyPage(context),
              isDark: isDark,
            ),
            
            // Logout option
            _buildLogoutItem(context, isDark),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, SettingsProvider provider, bool isDark) {
    final borderCol = isDark ? AppColors.borderDark : AppColors.borderLight;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderCol, width: 1.5),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: const NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=120'),
            backgroundColor: Colors.grey.shade300,
            onForegroundImageError: (_, __) {},
            child: const Icon(Icons.person, size: 24), // Fallback
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.userName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  provider.userEmail,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondaryLight),
        ],
      ),
    );
  }

  Widget _buildListItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final borderCol = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderCol, width: 1.5),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey.shade700, size: 22),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondaryLight),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutItem(BuildContext context, bool isDark) {
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final borderCol = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderCol, width: 1.5),
      ),
      child: ListTile(
        leading: const Icon(Icons.logout, color: AppColors.critical, size: 22),
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.critical),
        ),
        trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.critical),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Simulated session logout successful.')),
          );
        },
      ),
    );
  }

  // Edit user profile details bottom sheet
  void _showEditProfileSheet(BuildContext context, SettingsProvider provider, bool isDark) {
    final formKey = GlobalKey<FormState>();
    String name = provider.userName;
    String email = provider.userEmail;
    String phone = provider.userPhone;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit Profile Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Name'),
                  initialValue: name,
                  validator: (v) => v!.trim().isEmpty ? 'Name required' : null,
                  onSaved: (v) => name = v!.trim(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email Address'),
                  initialValue: email,
                  validator: (v) => v!.trim().isEmpty ? 'Email required' : null,
                  onSaved: (v) => email = v!.trim(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  initialValue: phone,
                  validator: (v) => v!.trim().isEmpty ? 'Phone required' : null,
                  onSaved: (v) => phone = v!.trim(),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      Navigator.pop(ctx);
                      final success = await provider.saveProfile(name, email, phone);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profile information updated.')),
                        );
                      }
                    }
                  },
                  child: const Text('Save Changes'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openTermsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DocumentViewPage(
          title: 'Terms & Conditions',
          sections: [
            {
              'heading': '1. General Usage Rights',
              'content': 'This app controls and monitors smart drying equipment used for agricultural and food processing operations. Users are granted license to control connected dryers subject to safety guidelines and equipment tolerances.'
            },
            {
              'heading': '2. Control Operations Responsibility',
              'content': 'Operating heat-drying machinery carries safety risks. High temperature setpoint overrides must align with crop tolerances (e.g., maximum limits to prevent burning). The operator assumes liability for batch outcomes.'
            },
          ],
        ),
      ),
    );
  }

  void _openPrivacyPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DocumentViewPage(
          title: 'Privacy Policy',
          sections: [
            {
              'heading': '1. Data Collection Scope',
              'content': 'We gather local machine state metrics (chamber temperatures, relative humidity percentages, air velocities) to generate health ratings. No personal data outside local profile settings (operator name, contact phone) is catalogued.'
            },
            {
              'heading': '2. Offline Persistence Boundaries',
              'content': 'Your crop records and history entries persist locally on SharedPreferences memory. This client database stores data securely and does not share operational details with third-party networks.'
            },
          ],
        ),
      ),
    );
  }
}

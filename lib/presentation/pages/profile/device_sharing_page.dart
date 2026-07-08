import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../state/dryer_provider.dart';

class DeviceSharingPage extends StatelessWidget {
  const DeviceSharingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DryerProvider>(context);
    final currentRole = provider.currentUserRole;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Access & Sharing Roles')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Active Account Role Selection',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Switch roles below to see how app visibility and controls adapt dynamically according to permission definitions.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
          ),
          const SizedBox(height: 20),

          _buildRoleChoiceCard(
            context: context,
            roleName: 'Owner',
            description: 'Full administrative access. Can start/stop cycles, modify parameters, and manage device registrations.',
            icon: Icons.admin_panel_settings,
            isActive: currentRole == 'Owner',
            provider: provider,
            isDark: isDark,
          ),
          _buildRoleChoiceCard(
            context: context,
            roleName: 'Viewer',
            description: 'Read-only access. Can monitor telemetry and alerts, but cannot modify setpoints, start, or stop cycles.',
            icon: Icons.visibility_outlined,
            isActive: currentRole == 'Viewer',
            provider: provider,
            isDark: isDark,
          ),
          _buildRoleChoiceCard(
            context: context,
            roleName: 'Technician',
            description: 'Maintenance access. Can view diagnostics, run sensor calibrations, acknowledge faults, and repair items.',
            icon: Icons.construction,
            isActive: currentRole == 'Technician',
            provider: provider,
            isDark: isDark,
          ),

          const SizedBox(height: 24),
          _buildPermissionsMatrix(isDark),
        ],
      ),
    );
  }

  Widget _buildRoleChoiceCard({
    required BuildContext context,
    required String roleName,
    required String description,
    required IconData icon,
    required bool isActive,
    required DryerProvider provider,
    required bool isDark,
  }) {
    final activeBorder = isDark ? AppColors.primaryLight : AppColors.primary;
    final borderColor = isActive ? activeBorder : (isDark ? AppColors.borderDark : AppColors.borderLight);
    final bgColor = isActive 
        ? (isDark ? AppColors.primaryLight.withOpacity(0.08) : AppColors.primary.withOpacity(0.05))
        : (isDark ? AppColors.cardDark : AppColors.cardLight);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: isActive ? 2 : 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Icon(icon, color: isActive ? activeBorder : AppColors.textSecondaryLight, size: 28),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(roleName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            if (isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.normal.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'ACTIVE SESSION',
                  style: TextStyle(color: AppColors.normal, fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Text(description, style: const TextStyle(fontSize: 12, height: 1.4)),
        ),
        onTap: () {
          provider.setUserRole(roleName);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Switched to $roleName access permissions.'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPermissionsMatrix(bool isDark) {
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ROLE PERMISSIONS MATRIX',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: AppColors.textSecondaryLight),
          ),
          const SizedBox(height: 12),
          _buildMatrixRow('Start/Stop Drying', true, false, false),
          _buildMatrixRow('Change Parameter Setpoints', true, false, false),
          _buildMatrixRow('View Live Telemetry', true, true, true),
          _buildMatrixRow('Receive Warning Alerts', true, true, true),
          _buildMatrixRow('Recalibrate Sensors', false, false, true),
          _buildMatrixRow('Perform Diagnostics & Testing', false, false, true),
        ],
      ),
    );
  }

  Widget _buildMatrixRow(String capability, bool owner, bool viewer, bool tech) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Text(capability, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Icon(owner ? Icons.check_circle : Icons.cancel_outlined, size: 16, color: owner ? Colors.green : Colors.grey)),
          Expanded(child: Icon(viewer ? Icons.check_circle : Icons.cancel_outlined, size: 16, color: viewer ? Colors.green : Colors.grey)),
          Expanded(child: Icon(tech ? Icons.check_circle : Icons.cancel_outlined, size: 16, color: tech ? Colors.green : Colors.grey)),
        ],
      ),
    );
  }
}

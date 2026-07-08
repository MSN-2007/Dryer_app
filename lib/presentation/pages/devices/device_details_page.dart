import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../state/dryer_provider.dart';
import '../../../data/models/dryer_device.dart';
import '../../../data/models/alert_model.dart';
import 'change_parameters_page.dart';

class DeviceDetailsPage extends StatelessWidget {
  final String deviceId;

  const DeviceDetailsPage({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DryerProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Find the device
    final deviceIndex = provider.devices.indexWhere((d) => d.id == deviceId);
    if (deviceIndex == -1) {
      return Scaffold(
        appBar: AppBar(title: const Text('Device Details')),
        body: const Center(child: Text('Device not found')),
      );
    }
    final device = provider.devices[deviceIndex];
    final isRunning = device.currentCycleId != null && device.isOnline;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Device Details',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Alert Panel (if any)
            if (device.activeAlert != null && device.isOnline)
              _buildAlertPanel(context, device, provider, isDark),

            // Active Cycle Status Card (Replicated Mockup style)
            _buildMockupCycleCard(context, device, isDark),

            // Live Parameters Checklist Box
            if (device.isOnline)
              _buildLiveParametersBlock(context, device, provider, isDark),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertPanel(
    BuildContext context, 
    DryerDevice device, 
    DryerProvider provider, 
    bool isDark
  ) {
    final alert = device.activeAlert!;
    final isCritical = alert.severity == AlertSeverity.critical;
    final color = isCritical ? AppColors.critical : AppColors.warning;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                isCritical ? 'CRITICAL FAULT DETECTED' : 'SYSTEM WARNING',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            alert.problem,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            alert.reason,
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            'Action: ${alert.suggestedAction}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey),
          ),
          if (provider.currentUserRole != 'Viewer') ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => provider.resolveAlert(device.id),
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color),
                minimumSize: const Size.fromHeight(40),
              ),
              child: const Text('Clear Alert'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMockupCycleCard(BuildContext context, DryerDevice device, bool isDark) {
    final isRunning = device.currentCycleId != null && device.isOnline;
    final borderCol = isDark ? AppColors.borderDark : AppColors.borderLight;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderCol, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                device.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: (device.isOnline ? AppColors.normal : AppColors.offline).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  device.isOnline ? (isRunning ? 'Running' : 'Idle') : 'Offline',
                  style: TextStyle(
                    color: device.isOnline ? AppColors.normal : AppColors.offline,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          
          if (isRunning) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left details block
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Cycle',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        device.currentProduct ?? '--',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _buildInlineDetail('Cycle ID', device.currentCycleId ?? '--', isDark),
                      _buildInlineDetail(
                        'Started', 
                        device.startDryingTime != null ? DateFormat('dd MMM yyyy, hh:mm a').format(device.startDryingTime!) : '--', 
                        isDark
                      ),
                      _buildInlineDetail(
                        'Expected Finish', 
                        device.startDryingTime != null ? DateFormat('dd MMM yyyy, hh:mm a').format(device.startDryingTime!.add(Duration(hours: device.expectedDryingTimeHours?.toInt() ?? 8))) : '--', 
                        isDark
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Right circle progress
                Builder(
                  builder: (context) {
                    final elapsedSecs = DateTime.now().difference(device.startDryingTime!).inSeconds;
                    final totalSecs = (device.expectedDryingTimeHours ?? 8) * 3600;
                    final progress = (elapsedSecs / totalSecs).clamp(0.0, 1.0);

                    return SizedBox(
                      width: 80,
                      height: 80,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 72,
                            height: 72,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 6,
                              color: AppColors.normal,
                              backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                            ),
                          ),
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ] else ...[
            Text(
              'Idle / No Active Cycle',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInlineDetail(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveParametersBlock(
    BuildContext context, 
    DryerDevice device, 
    DryerProvider provider, 
    bool isDark
  ) {
    final isRunning = device.currentCycleId != null;
    final borderCol = isDark ? AppColors.borderDark : AppColors.borderLight;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;

    // Calculate elapsed and remaining
    double progress = 0.0;
    String remainingStr = 'Completed';
    if (isRunning && device.startDryingTime != null && device.expectedDryingTimeHours != null) {
      final elapsedSecs = DateTime.now().difference(device.startDryingTime!).inSeconds;
      final totalSecs = device.expectedDryingTimeHours! * 3600;
      progress = (elapsedSecs / totalSecs).clamp(0.0, 1.0);
      final remainingSecs = totalSecs - elapsedSecs;
      
      if (remainingSecs > 0) {
        final hours = (remainingSecs / 3600).floor();
        final mins = ((remainingSecs % 3600) / 60).floor();
        remainingStr = '${hours}h ${mins}m';
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderCol, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Live Parameters',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Temperature Row
          _buildParamCheckRow(
            label: 'Temperature',
            liveValue: '${device.temp.toStringAsFixed(0)}°C',
            targetValue: isRunning ? '${device.targetTemp?.toStringAsFixed(0)}–${((device.targetTemp ?? 55) + 5).toStringAsFixed(0)}°C' : '55–60°C',
            isNormal: isRunning && device.targetTemp != null &&
                device.temp >= device.targetTemp! - 2 && device.temp <= device.targetTemp! + 7,
          ),
          const Divider(height: 20),

          // Humidity Row
          _buildParamCheckRow(
            label: 'Humidity',
            liveValue: '${device.humidity.toStringAsFixed(0)}%',
            targetValue: isRunning ? '${device.targetHumidity?.toStringAsFixed(0)}–${((device.targetHumidity ?? 12) + 5).toStringAsFixed(0)}%' : '15–20%',
            isNormal: isRunning && device.targetHumidity != null &&
                device.humidity >= device.targetHumidity! - 3 && device.humidity <= device.targetHumidity! + 8,
          ),
          const Divider(height: 20),

          // Air Flow Row
          _buildParamCheckRow(
            label: 'Air Flow',
            liveValue: device.airFlow >= 2.0 ? 'High' : (device.airFlow >= 1.2 ? 'Medium' : 'Low'),
            targetValue: 'Medium',
            isNormal: device.airFlow >= 1.0 && device.airFlow <= 2.5,
          ),
          
          if (isRunning) ...[
            const Divider(height: 24),
            // Progress Bar row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Progress', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                Text('${(progress * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                color: AppColors.normal,
                backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 16),
            
            // Remaining Time row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Remaining Time', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                Text(remainingStr, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
          
          // Action Buttons panel
          if (isRunning && provider.currentUserRole != 'Viewer') ...[
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeParametersPage(deviceId: device.id),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      minimumSize: const Size(0, 48),
                    ),
                    child: const Text('Change Parameters'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _confirmStopCycle(context, device, provider),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.critical,
                      side: const BorderSide(color: AppColors.critical, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      minimumSize: const Size(0, 48),
                    ),
                    child: const Text('Stop Cycle'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildParamCheckRow({
    required String label,
    required String liveValue,
    required String targetValue,
    required bool isNormal,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Text('Target: ', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                Text(targetValue, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        Row(
          children: [
            Text(
              liveValue,
              style: TextStyle(
                fontSize: 15, 
                fontWeight: FontWeight.bold,
                color: isNormal ? null : AppColors.warning,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isNormal ? AppColors.normal : AppColors.warning,
              ),
            )
          ],
        ),
      ],
    );
  }

  void _confirmStopCycle(BuildContext context, DryerDevice device, DryerProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Stop Cycle?'),
        content: Text('Are you sure you want to stop the drying cycle on ${device.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await provider.stopCycle(device.id);
              if (success) {
                if (context.mounted) {
                  Navigator.pop(context); // Go back to Home
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.critical),
            child: const Text('Stop'),
          ),
        ],
      ),
    );
  }
}

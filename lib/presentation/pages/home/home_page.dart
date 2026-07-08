import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../state/dryer_provider.dart';
import '../../../data/models/dryer_device.dart';
import '../devices/device_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _activeFilter = 'All'; // 'All', 'Active', 'Offline', 'Alert'

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DryerProvider>(context);
    final devices = provider.devices;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate Summary Stats
    final totalCount = devices.length;
    final activeCount = devices.where((d) => d.currentCycleId != null && d.isOnline).length;
    final offlineCount = devices.where((d) => !d.isOnline).length;
    final alertCount = devices.where((d) => d.status == DryerStatus.warning || d.status == DryerStatus.critical).length;

    // Filter Devices list
    List<DryerDevice> filteredDevices = [];
    if (_activeFilter == 'All') {
      filteredDevices = devices;
    } else if (_activeFilter == 'Active') {
      filteredDevices = devices.where((d) => d.currentCycleId != null && d.isOnline).toList();
    } else if (_activeFilter == 'Offline') {
      filteredDevices = devices.where((d) => !d.isOnline).toList();
    } else if (_activeFilter == 'Alert') {
      filteredDevices = devices.where((d) => d.status == DryerStatus.warning || d.status == DryerStatus.critical).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Summary Grid Card
            _buildSummaryRow(
              total: totalCount,
              active: activeCount,
              offline: offlineCount,
              alerts: alertCount,
              isDark: isDark,
            ),
            
            // Filter Tabs
            _buildFilterTabs(isDark),

            // Devices list
            Expanded(
              child: filteredDevices.isEmpty
                  ? _buildEmptyState(isDark)
                  : ListView.builder(
                      itemCount: filteredDevices.length,
                      padding: const EdgeInsets.only(bottom: 24),
                      itemBuilder: (context, index) {
                        final device = filteredDevices[index];
                        return _buildMockupDeviceCard(context, device, provider, isDark);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow({
    required int total,
    required int active,
    required int offline,
    required int alerts,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          _buildSummaryBlock('Total', total.toString(), Colors.black87, isDark),
          const SizedBox(width: 8),
          _buildSummaryBlock('Active', active.toString(), AppColors.normal, isDark),
          const SizedBox(width: 8),
          _buildSummaryBlock('Offline', offline.toString(), AppColors.offline, isDark),
          const SizedBox(width: 8),
          _buildSummaryBlock('Alert', alerts.toString(), AppColors.critical, isDark),
        ],
      ),
    );
  }

  Widget _buildSummaryBlock(String label, String value, Color color, bool isDark) {
    final borderCol = isDark ? AppColors.borderDark : AppColors.borderLight;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderCol, width: 1.5),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark && color == Colors.black87 ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs(bool isDark) {
    return Container(
      height: 38,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('All', isDark),
          _buildFilterChip('Active', isDark),
          _buildFilterChip('Offline', isDark),
          _buildFilterChip('Alert', isDark),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isDark) {
    final isSelected = _activeFilter == label;
    final selectedColor = isDark ? AppColors.primaryLight : AppColors.primary;
    final selectedTextColor = isDark ? Colors.black : Colors.white;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: selectedColor,
        checkmarkColor: selectedTextColor,
        labelStyle: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected 
              ? selectedTextColor 
              : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
        ),
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _activeFilter = label;
            });
          }
        },
      ),
    );
  }

  Widget _buildMockupDeviceCard(BuildContext context, DryerDevice device, DryerProvider provider, bool isDark) {
    // Determine status colors and texts
    Color statusColor;
    String statusText;
    IconData statusIcon = Icons.wifi;
    
    switch (device.status) {
      case DryerStatus.healthy:
        statusColor = AppColors.normal;
        statusText = 'Running';
        statusIcon = Icons.wifi;
        break;
      case DryerStatus.warning:
        statusColor = AppColors.warning;
        statusText = 'Warning';
        statusIcon = Icons.wifi_tethering;
        break;
      case DryerStatus.critical:
        statusColor = AppColors.critical;
        statusText = 'Alert';
        statusIcon = Icons.warning_amber_rounded;
        break;
      case DryerStatus.offline:
        statusColor = AppColors.offline;
        statusText = 'Offline';
        statusIcon = Icons.wifi_off_outlined;
        break;
    }

    final isRunning = device.currentCycleId != null && device.isOnline;
    double progress = 0.0;
    String remainingStr = '--';

    if (isRunning && device.startDryingTime != null && device.expectedDryingTimeHours != null) {
      final elapsedSecs = DateTime.now().difference(device.startDryingTime!).inSeconds;
      final totalSecs = device.expectedDryingTimeHours! * 3600;
      progress = (elapsedSecs / totalSecs).clamp(0.0, 1.0);
      final remainingSecs = totalSecs - elapsedSecs;
      
      if (remainingSecs > 0) {
        final hours = (remainingSecs / 3600).floor();
        final mins = ((remainingSecs % 3600) / 60).floor();
        remainingStr = '${hours}h ${mins}m';
      } else {
        remainingStr = 'Completed';
        progress = 1.0;
      }
    }

    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final borderCol = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderCol, width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DeviceDetailsPage(deviceId: device.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Dryer name / product & Status badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isRunning ? (device.currentProduct ?? 'Processing') : 'No Active Cycle',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withValues(alpha: 0.4), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 12, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Metrics Row: Circular progress on left, Remaining info in center, Temp/Humidity on right
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. Circular Progress ring
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            value: isRunning ? progress : 0.0,
                            strokeWidth: 5,
                            color: statusColor,
                            backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                          ),
                        ),
                        Text(
                          isRunning ? '${(progress * 100).toStringAsFixed(0)}%' : 'Idle',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),

                  // 2. Remaining Time text & mini bar indicator
                  if (isRunning)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Remaining ',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                            Text(
                              remainingStr,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Small indicator bar under the text
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: SizedBox(
                            width: 80,
                            height: 4,
                            child: LinearProgressIndicator(
                              value: progress,
                              color: statusColor,
                              backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      'Ready to dry',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),

                  const Spacer(),

                  // 3. Telemetry values (Temp & Humidity)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Temperature
                      Row(
                        children: [
                          Text(
                            'Temp: ',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                          Text(
                            device.isOnline ? '${device.temp.toStringAsFixed(0)}°C' : '--',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      // Humidity
                      Row(
                        children: [
                          Text(
                            'Humidity: ',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                          Text(
                            device.isOnline ? '${device.humidity.toStringAsFixed(0)}%' : '--',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sensors_off_outlined,
              size: 64,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Dryers Match Filter',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

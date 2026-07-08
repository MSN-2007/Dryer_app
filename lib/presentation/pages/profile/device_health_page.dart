import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../state/dryer_provider.dart';
import '../../state/settings_provider.dart';
import '../../../data/models/dryer_device.dart';

class DeviceHealthPage extends StatefulWidget {
  const DeviceHealthPage({super.key});

  @override
  State<DeviceHealthPage> createState() => _DeviceHealthPageState();
}

class _DeviceHealthPageState extends State<DeviceHealthPage> {
  DryerDevice? _selectedDevice;

  @override
  Widget build(BuildContext context) {
    final dryerProvider = Provider.of<DryerProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final devices = dryerProvider.devices;
    
    // Auto-select first device if none is selected
    if (_selectedDevice == null && devices.isNotEmpty) {
      _selectedDevice = devices.first;
    } else if (_selectedDevice != null) {
      // Keep selected device updated with live state from provider
      final index = devices.indexWhere((d) => d.id == _selectedDevice!.id);
      if (index != -1) {
        _selectedDevice = devices[index];
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Equipment Diagnostics')),
      body: devices.isEmpty
          ? _buildEmptyState(isDark)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Dryer for Health Diagnostic',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildDeviceDropdown(devices, isDark),
                  
                  if (_selectedDevice != null) ...[
                    const SizedBox(height: 24),
                    _buildHealthScoreCard(settingsProvider, isDark),
                    const SizedBox(height: 24),
                    _buildChecklist(settingsProvider, isDark),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildDeviceDropdown(List<DryerDevice> devices, bool isDark) {
    final borderCol = isDark ? AppColors.borderDark : AppColors.borderLight;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderCol),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<DryerDevice>(
          value: _selectedDevice,
          isExpanded: true,
          dropdownColor: isDark ? AppColors.cardDark : AppColors.cardLight,
          onChanged: (DryerDevice? newValue) {
            setState(() {
              _selectedDevice = newValue;
            });
          },
          items: devices.map<DropdownMenuItem<DryerDevice>>((DryerDevice device) {
            return DropdownMenuItem<DryerDevice>(
              value: device,
              child: Row(
                children: [
                  Icon(
                    device.isOnline ? Icons.router : Icons.router_outlined,
                    color: device.isOnline ? AppColors.normal : AppColors.offline,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text('${device.name} (${device.id})'),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildHealthScoreCard(SettingsProvider settingsProvider, bool isDark) {
    final healthData = settingsProvider.checkDeviceHealth(_selectedDevice!);
    final int score = healthData['score'];
    
    Color scoreColor = AppColors.normal;
    if (score < 60) {
      scoreColor = AppColors.critical;
    } else if (score < 90) {
      scoreColor = AppColors.warning;
    }

    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final borderCol = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol, width: 1.5),
      ),
      child: Column(
        children: [
          const Text(
            'OVERALL HEALTH RATING',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: AppColors.textSecondaryLight),
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 10,
                  color: scoreColor,
                  backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$score%',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: scoreColor),
                  ),
                  Text(
                    score >= 90 ? 'Healthy' : (score >= 60 ? 'Degraded' : 'Critical'),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            score == 100
                ? 'All registers, fans, and sensors are working nominally.'
                : (score >= 60 
                    ? 'Minor sensor deviations detected. Dryer operation can continue with increased monitoring.'
                    : 'Critical diagnostics failed. Power down immediately and recalibrate sensors or replace faulty hardware.'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklist(SettingsProvider settingsProvider, bool isDark) {
    final healthData = settingsProvider.checkDeviceHealth(_selectedDevice!);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'DIAGNOSTIC COMPONENT LOG',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppColors.textSecondaryLight),
          ),
        ),
        
        _buildChecklistItem('Chamber Temperature Sensor', healthData['tempSensor'], isDark),
        _buildChecklistItem('Relative Humidity Sensor', healthData['humSensor'], isDark),
        _buildChecklistItem('Ventilation Circulation Fan', healthData['fan'], isDark),
        _buildChecklistItem('Electric Heating Element', healthData['heater'], isDark),
        _buildChecklistItem('Embedded Microcontroller unit', healthData['controller'], isDark),
        _buildChecklistItem('Local Network WiFi Module', healthData['wifi'], isDark),
        _buildChecklistItem('Bluetooth BLE Beacon Transceiver', healthData['bluetooth'], isDark),
      ],
    );
  }

  Widget _buildChecklistItem(String title, bool status, bool isDark) {
    final Color itemColor = status ? AppColors.normal : AppColors.critical;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final borderCol = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderCol),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Row(
            children: [
              Text(
                status ? 'NOMINAL' : 'FAILURE',
                style: TextStyle(color: itemColor, fontSize: 10, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Icon(
                status ? Icons.check_circle_outline : Icons.error_outline,
                color: itemColor,
                size: 18,
              ),
            ],
          )
        ],
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
            const Icon(Icons.sensors_off_outlined, size: 64, color: AppColors.offline),
            const SizedBox(height: 16),
            const Text(
              'No Equipment Discovered',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Connect a smart dryer on the Devices tab to enable diagnostics.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

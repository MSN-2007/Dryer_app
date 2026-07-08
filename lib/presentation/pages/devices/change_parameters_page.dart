import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../state/dryer_provider.dart';

class ChangeParametersPage extends StatefulWidget {
  final String deviceId;

  const ChangeParametersPage({super.key, required this.deviceId});

  @override
  State<ChangeParametersPage> createState() => _ChangeParametersPageState();
}

class _ChangeParametersPageState extends State<ChangeParametersPage> {
  double _tempValue = 58.0;
  double _humidityValue = 18.0;
  String _airflowValue = 'Medium'; // 'Low', 'Medium', 'High'
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DryerProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final deviceIndex = provider.devices.indexWhere((d) => d.id == widget.deviceId);
    if (deviceIndex == -1) {
      return Scaffold(
        appBar: AppBar(title: const Text('Change Parameters')),
        body: const Center(child: Text('Device not found')),
      );
    }
    final device = provider.devices[deviceIndex];

    if (!_initialized) {
      _tempValue = device.targetTemp ?? 58.0;
      _humidityValue = device.targetHumidity ?? 18.0;
      _airflowValue = device.airFlow >= 2.0 ? 'High' : (device.airFlow >= 1.2 ? 'Medium' : 'Low');
      _initialized = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Change Parameters',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'These changes will apply only\nto the current cycle.',
                      style: TextStyle(
                        fontSize: 13, 
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Temperature Slider Group
                    _buildSliderGroup(
                      label: 'Temperature',
                      valueStr: '${_tempValue.toStringAsFixed(0)}°C',
                      minVal: 40.0,
                      maxVal: 80.0,
                      currentValue: _tempValue,
                      minLabel: '55°C',
                      maxLabel: '60°C',
                      onChanged: (val) {
                        setState(() {
                          _tempValue = val;
                        });
                      },
                      isDark: isDark,
                    ),
                    const SizedBox(height: 28),

                    // Humidity Slider Group
                    _buildSliderGroup(
                      label: 'Humidity',
                      valueStr: '${_humidityValue.toStringAsFixed(0)}%',
                      minVal: 5.0,
                      maxVal: 35.0,
                      currentValue: _humidityValue,
                      minLabel: '15%',
                      maxLabel: '20%',
                      onChanged: (val) {
                        setState(() {
                          _humidityValue = val;
                        });
                      },
                      isDark: isDark,
                    ),
                    const SizedBox(height: 28),

                    // Airflow Segmented Controller
                    const Text(
                      'Air Flow',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    _buildSegmentedAirflow(isDark),
                  ],
                ),
              ),
            ),

            // Bottom Apply Button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () => _applyParameterChanges(context, provider),
                child: const Text('Apply Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderGroup({
    required String label,
    required String valueStr,
    required double minVal,
    required double maxVal,
    required double currentValue,
    required String minLabel,
    required String maxLabel,
    required ValueChanged<double> onChanged,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              valueStr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withOpacity(0.12),
            trackHeight: 6,
          ),
          child: Slider(
            value: currentValue,
            min: minVal,
            max: maxVal,
            onChanged: onChanged,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              minLabel,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
            ),
            Text(
              maxLabel,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildSegmentedAirflow(bool isDark) {
    final borderCol = isDark ? AppColors.borderDark : AppColors.borderLight;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderCol, width: 1.5),
      ),
      child: Row(
        children: [
          _buildAirflowSegment('Low'),
          _buildAirflowSegment('Medium'),
          _buildAirflowSegment('High'),
        ],
      ),
    );
  }

  Widget _buildAirflowSegment(String value) {
    final isSelected = _airflowValue == value;
    
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _airflowValue = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isSelected ? Colors.white : null,
            ),
          ),
        ),
      ),
    );
  }

  void _applyParameterChanges(BuildContext context, DryerProvider provider) async {
    // Translate airflow string back to mock velocity bounds
    double airVelocity = 1.8;
    if (_airflowValue == 'Low') airVelocity = 1.0;
    if (_airflowValue == 'High') airVelocity = 2.5;

    final success = await provider.applyTemporaryParameters(
      deviceId: widget.deviceId,
      newTemp: _tempValue,
      newHumidity: _humidityValue,
      newAirFlow: airVelocity,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parameter setpoint changes applied successfully.')),
      );
      Navigator.pop(context); // Go back to details
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/cycle_id_generator.dart';
import '../../state/dryer_provider.dart';
import '../../state/library_provider.dart';
import '../../../data/models/dryer_device.dart';
import '../../../data/models/drying_profile.dart';

class StartCyclePage extends StatefulWidget {
  const StartCyclePage({super.key});

  @override
  State<StartCyclePage> createState() => _StartCyclePageState();
}

class _StartCyclePageState extends State<StartCyclePage> {
  int _currentStep = 0; // 0: Device, 1: Product, 2: Details/Quantity, 3: Review, 4: Success Screen

  DryerDevice? _selectedDevice;
  DryingProfile? _selectedProfile;
  final TextEditingController _quantityController = TextEditingController(text: '20');
  String _generatedCycleId = '';

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _generateCycleId() {
    if (_selectedProfile == null) return;
    final randomNum = 1 + (DateTime.now().millisecondsSinceEpoch % 9);
    _generatedCycleId = CycleIdGenerator.generate(
      productName: _selectedProfile!.name,
      index: randomNum,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dryerProvider = Provider.of<DryerProvider>(context);
    final libraryProvider = Provider.of<LibraryProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final idleDevices = dryerProvider.devices.where((d) => d.isOnline && d.currentCycleId == null).toList();

    // If we succeeded and are on step 4, show the success screen directly
    if (_currentStep == 4) {
      return _buildSuccessScreen(isDark);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Start New Cycle',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Horizontal Step timeline dots
            _buildTimelineHeader(isDark),
            const SizedBox(height: 16),

            // Step Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildStepLayout(idleDevices, libraryProvider.allProfiles, isDark),
              ),
            ),

            // Bottom Navigation CTA
            _buildNavigationFooter(idleDevices, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTimelineNode(0, 'Device', isDark),
          _buildTimelineLine(0, isDark),
          _buildTimelineNode(1, 'Product', isDark),
          _buildTimelineLine(1, isDark),
          _buildTimelineNode(2, 'Details', isDark),
          _buildTimelineLine(2, isDark),
          _buildTimelineNode(3, 'Review', isDark),
        ],
      ),
    );
  }

  Widget _buildTimelineNode(int step, String label, bool isDark) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep > step;

    Color badgeBg = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    Color textCol = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    if (isActive) {
      badgeBg = AppColors.primary;
      textCol = Colors.white;
    } else if (isCompleted) {
      badgeBg = AppColors.normal;
      textCol = Colors.white;
    }

    return Column(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: badgeBg,
          child: isCompleted
              ? const Icon(Icons.check, size: 12, color: Colors.white)
              : Text(
                  (step + 1).toString(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textCol),
                ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? AppColors.primary : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineLine(int step, bool isDark) {
    final isCompleted = _currentStep > step;
    return Expanded(
      child: Container(
        height: 1.5,
        margin: const EdgeInsets.only(left: 4, right: 4, bottom: 12),
        color: isCompleted ? AppColors.normal : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
      ),
    );
  }

  Widget _buildStepLayout(List<DryerDevice> idleDevices, List<DryingProfile> profiles, bool isDark) {
    switch (_currentStep) {
      case 0:
        return _buildStepDeviceDropdown(idleDevices, isDark);
      case 1:
        return _buildStepProductDropdown(profiles, isDark);
      case 2:
        return _buildStepDetailsForm(isDark);
      case 3:
        return _buildStepReviewCard(isDark);
      default:
        return const SizedBox.shrink();
    }
  }

  // STEP 1: SELECT DEVICE
  Widget _buildStepDeviceDropdown(List<DryerDevice> idleDevices, bool isDark) {
    final borderCol = isDark ? AppColors.borderDark : AppColors.borderLight;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;

    if (idleDevices.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 48.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.sensors_off_outlined, size: 56, color: AppColors.offline),
              const SizedBox(height: 16),
              const Text('No Available Dryers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text(
                'Verify that your equipment devices are online and idle before setup.',
                style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Dryer Device', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderCol, width: 1.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<DryerDevice>(
              value: _selectedDevice,
              isExpanded: true,
              hint: const Text('Choose a dryer device'),
              dropdownColor: cardBg,
              onChanged: (DryerDevice? newVal) {
                setState(() {
                  _selectedDevice = newVal;
                });
              },
              items: idleDevices.map<DropdownMenuItem<DryerDevice>>((DryerDevice d) {
                return DropdownMenuItem<DryerDevice>(
                  value: d,
                  child: Text(d.name),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // STEP 2: SELECT PRODUCT
  Widget _buildStepProductDropdown(List<DryingProfile> profiles, bool isDark) {
    final borderCol = isDark ? AppColors.borderDark : AppColors.borderLight;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Crop Recipe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderCol, width: 1.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<DryingProfile>(
              value: _selectedProfile,
              isExpanded: true,
              hint: const Text('Choose a drying profile recipe'),
              dropdownColor: cardBg,
              onChanged: (DryingProfile? newVal) {
                setState(() {
                  _selectedProfile = newVal;
                });
              },
              items: profiles.map<DropdownMenuItem<DryingProfile>>((DryingProfile p) {
                return DropdownMenuItem<DryingProfile>(
                  value: p,
                  child: Text(p.name),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // STEP 3: DETAILS & QUANTITY
  Widget _buildStepDetailsForm(bool isDark) {
    final borderCol = isDark ? AppColors.borderDark : AppColors.borderLight;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Batch Quantity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: _quantityController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Quantity (KG)',
            suffixText: 'KG',
          ),
        ),
        const SizedBox(height: 24),
        
        const Text('Generated Run Reference ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondaryLight)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderCol, width: 1.5),
          ),
          child: Text(
            _generatedCycleId.isEmpty ? 'Generating ID...' : _generatedCycleId,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1.2),
          ),
        ),
      ],
    );
  }

  // STEP 4: REVIEW DETAILS CARD
  Widget _buildStepReviewCard(bool isDark) {
    final p = _selectedProfile!;
    final d = _selectedDevice!;
    final q = double.tryParse(_quantityController.text) ?? 20.0;
    final borderCol = isDark ? AppColors.borderDark : AppColors.borderLight;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderCol, width: 1.5),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Review Cycle Parameters',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              ),
              Text(
                _generatedCycleId,
                style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 24),
          
          _buildReviewRow('Dryer Device', d.name),
          _buildReviewRow('Crop / Recipe', p.name),
          _buildReviewRow('Batch Weight', '$q KG'),
          _buildReviewRow('Temp setpoint range', '${p.tempRangeMin.toStringAsFixed(0)}–${p.tempRangeMax.toStringAsFixed(0)}°C'),
          _buildReviewRow('Humidity threshold', '${p.humidityRangeMin.toStringAsFixed(0)}–${p.humidityRangeMax.toStringAsFixed(0)}%'),
          _buildReviewRow('Air Flow setting', 'Medium'),
          _buildReviewRow('Estimated Duration', '${p.expectedDryingTimeHours.toStringAsFixed(0)}–${(p.expectedDryingTimeHours + 2).toStringAsFixed(0)} Hours'),
        ],
      ),
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildNavigationFooter(List<DryerDevice> idleDevices, bool isDark) {
    // If step 0 and there are no dryers, hide controls
    if (_currentStep == 0 && idleDevices.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        border: Border(top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 1.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _currentStep--;
                });
              },
              style: OutlinedButton.styleFrom(minimumSize: const Size(100, 48)),
              child: const Text('Back'),
            )
          else
            const SizedBox.shrink(),
          
          ElevatedButton(
            onPressed: () {
              if (_currentStep == 0 && _selectedDevice == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select a dryer device')),
                );
                return;
              }
              if (_currentStep == 1 && _selectedProfile == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select a recipe profile')),
                );
                return;
              }
              if (_currentStep == 2) {
                final qty = double.tryParse(_quantityController.text);
                if (qty == null || qty <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid weight quantity')),
                  );
                  return;
                }
                _generateCycleId();
              }

              if (_currentStep == 3) {
                _confirmStartCycle(context);
              } else {
                setState(() {
                  _currentStep++;
                });
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(120, 48),
              backgroundColor: _currentStep == 3 ? AppColors.normal : AppColors.primary,
            ),
            child: Text(_currentStep == 3 ? 'Start Cycle' : 'Next'),
          ),
        ],
      ),
    );
  }

  // Popup warning dialog box: "Start This Cycle?"
  void _confirmStartCycle(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.12), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_outline, color: AppColors.normal, size: 24),
            ),
            const SizedBox(width: 8),
            const Text('Start This Cycle?'),
          ],
        ),
        content: Text('You are about to start ${_selectedProfile!.name} drying in ${_selectedDevice!.name}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: AppColors.textSecondaryLight),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _launchDryingCycle();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(100, 40),
            ),
            child: const Text('Yes, Start'),
          ),
        ],
      ),
    );
  }

  void _launchDryingCycle() async {
    final dryerProvider = Provider.of<DryerProvider>(context, listen: false);
    final p = _selectedProfile!;
    final d = _selectedDevice!;
    final qty = double.tryParse(_quantityController.text) ?? 20.0;

    final targetTemp = (p.tempRangeMin + p.tempRangeMax) / 2;
    final targetHum = (p.humidityRangeMin + p.humidityRangeMax) / 2;
    final targetAir = (p.airFlowRangeMin + p.airFlowRangeMax) / 2;

    final success = await dryerProvider.startCycle(
      deviceId: d.id,
      productName: p.name,
      cycleId: _generatedCycleId,
      quantity: qty,
      targetTemp: targetTemp,
      targetHumidity: targetHum,
      targetAirFlow: targetAir,
      expectedHours: p.expectedDryingTimeHours,
    );

    if (success && mounted) {
      setState(() {
        _currentStep = 4; // Shift to success screen layout
      });
    }
  }

  // Success screen layout matching mockup specifications
  Widget _buildSuccessScreen(bool isDark) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              // Large green checkmark circle
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.normal.withOpacity(0.12),
                  border: Border.all(color: AppColors.normal, width: 2),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.check,
                  color: AppColors.normal,
                  size: 48,
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'Cycle Started Successfully!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              Text(
                '${_selectedProfile?.name} drying has started in ${_selectedDevice?.name}.',
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondaryLight),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Cycle ID details box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Cycle ID: ', style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight)),
                    Text(
                      _generatedCycleId,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),

              // View Dashboard Button
              ElevatedButton(
                onPressed: () {
                  // Switch tab programmatically by popping/rebuilding
                  // Since StartCyclePage is inside bottom navigation stack,
                  // we can simply reset state and switch index using standard navigator triggers or just go back.
                  // For simplicity in our MVP flow, we reset this wizard state and pop/reset
                  setState(() {
                    _currentStep = 0;
                    _selectedDevice = null;
                    _selectedProfile = null;
                  });
                },
                child: const Text('View Dashboard'),
              ),
              const SizedBox(height: 16),
              
              // Done link
              TextButton(
                onPressed: () {
                  setState(() {
                    _currentStep = 0;
                    _selectedDevice = null;
                    _selectedProfile = null;
                  });
                },
                child: const Text(
                  'Done',
                  style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

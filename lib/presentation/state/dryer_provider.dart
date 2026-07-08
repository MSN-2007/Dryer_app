import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/models/dryer_device.dart';
import '../../data/models/alert_model.dart';
import '../../data/repositories/dryer_repository.dart';
import '../../data/repositories/history_repository.dart';

class DryerProvider with ChangeNotifier {
  final DryerRepository _repository = DryerRepository();
  final HistoryRepository _historyRepository = HistoryRepository();

  List<DryerDevice> _devices = [];
  bool _isLoading = false;
  Timer? _telemetryTimer;
  final Random _random = Random();
  String _currentUserRole = 'Owner'; // Default role is 'Owner'

  List<DryerDevice> get devices => _devices;
  bool get isLoading => _isLoading;
  String get currentUserRole => _currentUserRole;

  DryerProvider() {
    _init();
    // Start telemetry simulation loop (ticks every 4 seconds)
    _telemetryTimer = Timer.periodic(const Duration(seconds: 4), (_) => _simulateTelemetry());
  }

  @override
  void dispose() {
    _telemetryTimer?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    _devices = await _repository.getDevices();
    _isLoading = false;
    notifyListeners();
  }

  void setUserRole(String role) {
    _currentUserRole = role;
    _historyRepository.addEntry(
      'User Role Switched',
      'Active session changed to role: $role.',
      'System',
    );
    notifyListeners();
  }

  Future<void> refresh() async {
    _devices = await _repository.getDevices();
    notifyListeners();
  }

  // IoT Telemetry and Alert Check Loop
  void _simulateTelemetry() {
    bool hasChanges = false;
    
    for (int i = 0; i < _devices.length; i++) {
      final device = _devices[i];
      if (!device.isOnline) continue;

      double newTemp = device.temp;
      double newHumidity = device.humidity;
      double newAirflow = device.airFlow;
      DryerStatus newStatus = device.status;
      AlertModel? newAlert = device.activeAlert;

      if (device.currentCycleId != null) {
        // Device is running a cycle.
        // Fluctuating values slightly around target settings
        final targetT = device.targetTemp ?? 55.0;
        final targetH = device.targetHumidity ?? 12.0;
        final targetA = device.targetAirFlow ?? 1.8;

        newTemp += (_random.nextDouble() - 0.5) * 1.2;
        newHumidity += (_random.nextDouble() - 0.5) * 0.8;
        newAirflow += (_random.nextDouble() - 0.5) * 0.15;

        // Keep values bounded to realistic bounds
        newTemp = newTemp.clamp(20.0, 95.0);
        newHumidity = newHumidity.clamp(2.0, 95.0);
        newAirflow = newAirflow.clamp(0.0, 5.0);

        // Keep target proximity pull (simulate steady-state control loop)
        newTemp = newTemp + (targetT - newTemp) * 0.15;
        newHumidity = newHumidity + (targetH - newHumidity) * 0.15;
        newAirflow = newAirflow + (targetA - newAirflow) * 0.15;

        // Check for threshold violations if warning is not manually triggered
        if (newAlert == null) {
          // Check limits
          if (newTemp < targetT - 5.0) {
            newStatus = DryerStatus.warning;
            newAlert = AlertModel(
              problem: 'Temperature too low',
              reason: 'Temperature dropped below ${device.currentProduct?.toLowerCase()} drying range.',
              suggestedAction: 'Drying time may increase. Check if the heating element needs inspection.',
              severity: AlertSeverity.warning,
              timestamp: DateTime.now(),
            );
            _historyRepository.addEntry('Dryer Warning Alert', '${device.name}: Temperature below target threshold.', 'System');
          } else if (newTemp > targetT + 6.0) {
            newStatus = DryerStatus.critical;
            newAlert = AlertModel(
              problem: 'Critical High Temperature',
              reason: 'Temperature exceeded safety ceiling by ${(newTemp - targetT).toStringAsFixed(1)}°C.',
              suggestedAction: 'Risk of crop degradation. Inspect thermal regulator and fan circulation immediately.',
              severity: AlertSeverity.critical,
              timestamp: DateTime.now(),
            );
            _historyRepository.addEntry('Dryer Critical Alert', '${device.name}: Thermal ceiling overshoot.', 'System');
          } else {
            newStatus = DryerStatus.healthy;
          }
        }
      } else {
        // Idle device, cooling down to room temperature
        newTemp = newTemp + (24.0 - newTemp) * 0.1;
        newHumidity = newHumidity + (45.0 - newHumidity) * 0.1;
        newAirflow = newAirflow + (0.0 - newAirflow) * 0.2;
        newStatus = DryerStatus.healthy;
        newAlert = null;
      }

      // Check if values have actually drifted enough to warrant updates
      if ((newTemp - device.temp).abs() > 0.05 ||
          (newHumidity - device.humidity).abs() > 0.05 ||
          newStatus != device.status ||
          newAlert != device.activeAlert) {
        
        _devices[i] = device.copyWith(
          temp: double.parse(newTemp.toStringAsFixed(1)),
          humidity: double.parse(newHumidity.toStringAsFixed(1)),
          airFlow: double.parse(newAirflow.toStringAsFixed(2)),
          status: newStatus,
          activeAlert: newAlert,
        );
        hasChanges = true;
      }
    }

    if (hasChanges) {
      _repository.saveDevices(_devices);
      notifyListeners();
    }
  }

  // Trigger simulated fault for QA and developer review
  void triggerMockFault(String deviceId, bool critical) {
    final index = _devices.indexWhere((d) => d.id == deviceId);
    if (index == -1) return;

    final device = _devices[index];
    if (critical) {
      _devices[index] = device.copyWith(
        status: DryerStatus.critical,
        temp: 82.5,
        activeAlert: AlertModel(
          problem: 'Heater Overheating Fault',
          reason: 'Temperature probe registered 82.5°C, violating safe limits.',
          suggestedAction: 'Drying suspended. Power off main control switch and clean fan ventilation grills.',
          severity: AlertSeverity.critical,
          timestamp: DateTime.now(),
        ),
      );
      _historyRepository.addEntry('Critical Fault Triggered', 'Simulated heating fault on ${device.name}.', 'Technician');
    } else {
      _devices[index] = device.copyWith(
        status: DryerStatus.warning,
        temp: 42.0,
        activeAlert: AlertModel(
          problem: 'Weak Airflow Rate Detected',
          reason: 'Air velocity slowed to 0.6 m/s, below target thresholds.',
          suggestedAction: 'Drying cycle continues. Check filter screen blockage and exhaust dampers.',
          severity: AlertSeverity.warning,
          timestamp: DateTime.now(),
        ),
      );
      _historyRepository.addEntry('Warning Alert Triggered', 'Simulated airflow warning on ${device.name}.', 'Technician');
    }
    _repository.saveDevices(_devices);
    notifyListeners();
  }

  void resolveAlert(String deviceId) {
    final index = _devices.indexWhere((d) => d.id == deviceId);
    if (index == -1) return;

    final device = _devices[index];
    _devices[index] = device.copyWith(
      status: DryerStatus.healthy,
      activeAlert: null,
    );
    _historyRepository.addEntry(
      'Alert Acknowledged',
      'Active alert on ${device.name} was resolved/acknowledged.',
      _currentUserRole,
    );
    _repository.saveDevices(_devices);
    notifyListeners();
  }

  // Start drying cycle
  Future<bool> startCycle({
    required String deviceId,
    required String productName,
    required String cycleId,
    required double quantity,
    required double targetTemp,
    required double targetHumidity,
    required double targetAirFlow,
    required double expectedHours,
  }) async {
    // Role check
    if (_currentUserRole == 'Viewer') return false;

    final index = _devices.indexWhere((d) => d.id == deviceId);
    if (index == -1) return false;

    final device = _devices[index];
    _devices[index] = device.copyWith(
      currentProduct: productName,
      currentCycleId: cycleId,
      startDryingTime: DateTime.now(),
      targetTemp: targetTemp,
      targetHumidity: targetHumidity,
      targetAirFlow: targetAirFlow,
      quantity: quantity,
      expectedDryingTimeHours: expectedHours,
      temp: targetTemp - 5.0, // Start close to targets
      humidity: 45.0,
      airFlow: targetAirFlow,
      status: DryerStatus.healthy,
      activeAlert: null,
    );

    await _repository.saveDevices(_devices);
    await _historyRepository.addEntry(
      'Drying Cycle Launched',
      'Started cycle $cycleId on ${device.name} for $productName ($quantity kg). Expected time: ${expectedHours}h.',
      _currentUserRole,
    );
    
    notifyListeners();
    return true;
  }

  // Stop current drying cycle
  Future<bool> stopCycle(String deviceId) async {
    // Role check
    if (_currentUserRole == 'Viewer') return false;

    final index = _devices.indexWhere((d) => d.id == deviceId);
    if (index == -1) return false;

    final device = _devices[index];
    final String? cycleId = device.currentCycleId;
    final String? product = device.currentProduct;

    _devices[index] = DryerDevice(
      id: device.id,
      name: device.name,
      currentProduct: null,
      temp: 25.0,
      humidity: 45.0,
      airFlow: 0.0,
      isOnline: device.isOnline,
      status: DryerStatus.healthy,
      currentCycleId: null,
      startDryingTime: null,
    );

    await _repository.saveDevices(_devices);
    await _historyRepository.addEntry(
      'Drying Cycle Stopped',
      'Cycle $cycleId ($product) was manually stopped on ${device.name}.',
      _currentUserRole,
    );

    notifyListeners();
    return true;
  }

  // Temporary parameter overrides for the running cycle
  Future<bool> applyTemporaryParameters({
    required String deviceId,
    required double newTemp,
    required double newHumidity,
    required double newAirFlow,
  }) async {
    // Role check
    if (_currentUserRole == 'Viewer') return false;

    final index = _devices.indexWhere((d) => d.id == deviceId);
    if (index == -1) return false;

    final device = _devices[index];
    if (device.currentCycleId == null) return false;

    final oldTemp = device.targetTemp;

    _devices[index] = device.copyWith(
      targetTemp: newTemp,
      targetHumidity: newHumidity,
      targetAirFlow: newAirFlow,
      // Temporarily reset alert so the control loop targets the new parameter
      status: DryerStatus.healthy,
      activeAlert: null,
    );

    await _repository.saveDevices(_devices);
    await _historyRepository.addEntry(
      'Parameter Override Applied',
      '${device.name}: Temp setpoint adjusted from ${oldTemp?.toStringAsFixed(1)}°C to ${newTemp.toStringAsFixed(1)}°C for current batch.',
      _currentUserRole,
    );

    notifyListeners();
    return true;
  }

  // Add device via simulated processes
  Future<bool> connectNewDevice({
    required String name,
    required String id,
    required String method,
  }) async {
    // Role check
    if (_currentUserRole == 'Viewer') return false;

    // Check duplicate
    if (_devices.any((d) => d.id == id)) return false;

    final newDevice = DryerDevice(
      id: id,
      name: name,
      currentProduct: null,
      temp: 22.0,
      humidity: 50.0,
      airFlow: 0.0,
      isOnline: true,
      status: DryerStatus.healthy,
    );

    _devices.add(newDevice);
    await _repository.saveDevices(_devices);
    await _historyRepository.addEntry(
      'New Device Registered',
      'Registered dryer "$name" ($id) via mock $method connection.',
      _currentUserRole,
    );

    notifyListeners();
    return true;
  }

  // Disconnect/Remove device
  Future<bool> disconnectDevice(String id) async {
    if (_currentUserRole == 'Viewer') return false;

    final deviceIndex = _devices.indexWhere((d) => d.id == id);
    if (deviceIndex == -1) return false;
    final deviceName = _devices[deviceIndex].name;

    final success = await _repository.deleteDevice(id);
    if (success) {
      _devices.removeAt(deviceIndex);
      await _historyRepository.addEntry(
        'Device Removed',
        'Device "$deviceName" ($id) was unregistered from this client app.',
        _currentUserRole,
      );
      notifyListeners();
    }
    return success;
  }

  // Check diagnostics/calibration log for technicians
  Future<void> runTechnicianCalibration(String deviceId) async {
    if (_currentUserRole != 'Technician') return;
    
    final index = _devices.indexWhere((d) => d.id == deviceId);
    if (index == -1) return;
    
    final device = _devices[index];
    _devices[index] = device.copyWith(
      status: DryerStatus.healthy,
      activeAlert: null,
    );
    
    await _repository.saveDevices(_devices);
    await _historyRepository.addEntry(
      'Technician Recalibration',
      'Dryer "${device.name}" sensors and PID controls recalibrated to nominal baseline values.',
      'Technician',
    );
    notifyListeners();
  }
}

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dryer_device.dart';

class DryerRepository {
  static const String _devicesKey = 'connected_dryer_devices';

  // Seed default devices if none exist in local storage
  final List<DryerDevice> _seedDevices = [
    DryerDevice(
      id: 'DRY-A100-01',
      name: 'Dryer Alpha',
      currentProduct: 'Tomato',
      temp: 57.5,
      humidity: 12.8,
      airFlow: 2.0,
      isOnline: true,
      status: DryerStatus.healthy,
      currentCycleId: 'T-JUL08-01',
      startDryingTime: DateTime.now().subtract(const Duration(hours: 3)),
      targetTemp: 58.0,
      targetHumidity: 12.0,
      targetAirFlow: 2.0,
      quantity: 150.0,
      expectedDryingTimeHours: 10.0,
    ),
    DryerDevice(
      id: 'DRY-B200-02',
      name: 'Dryer Beta',
      currentProduct: null,
      temp: 24.5,
      humidity: 45.2,
      airFlow: 0.0,
      isOnline: true,
      status: DryerStatus.healthy,
      currentCycleId: null,
      startDryingTime: null,
    ),
    DryerDevice(
      id: 'DRY-C300-03',
      name: 'Dryer Gamma',
      currentProduct: null,
      temp: 0.0,
      humidity: 0.0,
      airFlow: 0.0,
      isOnline: false,
      status: DryerStatus.offline,
      currentCycleId: null,
      startDryingTime: null,
    )
  ];

  Future<List<DryerDevice>> getDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_devicesKey);
    
    if (jsonString == null) {
      // Seed initial devices
      await saveDevices(_seedDevices);
      return _seedDevices;
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => DryerDevice.fromMap(e)).toList();
    } catch (_) {
      return _seedDevices;
    }
  }

  Future<bool> saveDevices(List<DryerDevice> devices) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(devices.map((e) => e.toMap()).toList());
    return await prefs.setString(_devicesKey, jsonString);
  }

  Future<bool> saveDevice(DryerDevice device) async {
    final devices = await getDevices();
    final index = devices.indexWhere((d) => d.id == device.id);
    if (index != -1) {
      devices[index] = device;
    } else {
      devices.add(device);
    }
    return await saveDevices(devices);
  }

  Future<bool> deleteDevice(String id) async {
    final devices = await getDevices();
    devices.removeWhere((d) => d.id == id);
    return await saveDevices(devices);
  }
}

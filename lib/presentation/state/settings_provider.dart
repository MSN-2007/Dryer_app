import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/dryer_device.dart';

class SettingsProvider with ChangeNotifier {
  static const String _profileNameKey = 'profile_user_name';
  static const String _profileEmailKey = 'profile_user_email';
  static const String _profilePhoneKey = 'profile_user_phone';

  String _userName = 'John Farmer';
  String _userEmail = 'johnfarmer@email.com';
  String _userPhone = '+1 555-0199';
  bool _isLoading = false;

  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userPhone => _userPhone;
  bool get isLoading => _isLoading;

  SettingsProvider() {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    _isLoading = true;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString(_profileNameKey) ?? 'John Farmer';
    _userEmail = prefs.getString(_profileEmailKey) ?? 'johnfarmer@email.com';
    _userPhone = prefs.getString(_profilePhoneKey) ?? '+1 555-0199';
    
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> saveProfile(String name, String email, String phone) async {
    final prefs = await SharedPreferences.getInstance();
    _userName = name;
    _userEmail = email;
    _userPhone = phone;
    
    bool s1 = await prefs.setString(_profileNameKey, name);
    bool s2 = await prefs.setString(_profileEmailKey, email);
    bool s3 = await prefs.setString(_profilePhoneKey, phone);
    
    notifyListeners();
    return s1 && s2 && s3;
  }

  // Calculates a dynamic health score and checklist based on device's status and alerts
  Map<String, dynamic> checkDeviceHealth(DryerDevice device) {
    bool tempSensorOk = true;
    bool humSensorOk = true;
    bool fanOk = true;
    bool heaterOk = true;
    bool controllerOk = true;
    bool wifiOk = device.isOnline;
    bool bluetoothOk = device.isOnline;

    if (!device.isOnline) {
      return {
        'score': 0,
        'tempSensor': false,
        'humSensor': false,
        'fan': false,
        'heater': false,
        'controller': false,
        'wifi': false,
        'bluetooth': false,
      };
    }

    final alert = device.activeAlert;
    if (alert != null) {
      if (alert.problem.contains('Temperature') || alert.problem.contains('Thermal')) {
        tempSensorOk = false;
        heaterOk = false;
      }
      if (alert.problem.contains('Airflow') || alert.problem.contains('Fan')) {
        fanOk = false;
      }
      if (alert.problem.contains('Humidity')) {
        humSensorOk = false;
      }
      if (alert.problem.contains('Controller') || device.status == DryerStatus.critical) {
        controllerOk = false;
      }
    }

    // Compute numeric score
    int score = 100;
    if (!tempSensorOk) score -= 15;
    if (!humSensorOk) score -= 15;
    if (!fanOk) score -= 20;
    if (!heaterOk) score -= 25;
    if (!controllerOk) score -= 15;
    if (!wifiOk) score -= 5;
    if (!bluetoothOk) score -= 5;
    
    score = score.clamp(0, 100);

    return {
      'score': score,
      'tempSensor': tempSensorOk,
      'humSensor': humSensorOk,
      'fan': fanOk,
      'heater': heaterOk,
      'controller': controllerOk,
      'wifi': wifiOk,
      'bluetooth': bluetoothOk,
    };
  }
}

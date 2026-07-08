import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/drying_profile.dart';

class ProfileRepository {
  static const String _customProfilesKey = 'custom_drying_profiles';

  // Default preloaded profiles
  final List<DryingProfile> _defaultProfiles = [
    DryingProfile(
      id: 'default_tomato',
      name: 'Tomato',
      tempRangeMin: 55.0,
      tempRangeMax: 60.0,
      humidityRangeMin: 10.0,
      humidityRangeMax: 15.0,
      airFlowRangeMin: 1.8,
      airFlowRangeMax: 2.2,
      expectedDryingTimeHours: 10.0,
      isCustom: false,
    ),
    DryingProfile(
      id: 'default_mango',
      name: 'Mango',
      tempRangeMin: 60.0,
      tempRangeMax: 65.0,
      humidityRangeMin: 12.0,
      humidityRangeMax: 18.0,
      airFlowRangeMin: 2.0,
      airFlowRangeMax: 2.5,
      expectedDryingTimeHours: 12.0,
      isCustom: false,
    ),
    DryingProfile(
      id: 'default_rose_petals',
      name: 'Rose Petals',
      tempRangeMin: 40.0,
      tempRangeMax: 45.0,
      humidityRangeMin: 8.0,
      humidityRangeMax: 12.0,
      airFlowRangeMin: 1.0,
      airFlowRangeMax: 1.5,
      expectedDryingTimeHours: 8.0,
      isCustom: false,
    ),
    DryingProfile(
      id: 'default_leaves',
      name: 'Leaves',
      tempRangeMin: 45.0,
      tempRangeMax: 50.0,
      humidityRangeMin: 10.0,
      humidityRangeMax: 15.0,
      airFlowRangeMin: 1.2,
      airFlowRangeMax: 1.8,
      expectedDryingTimeHours: 6.0,
      isCustom: false,
    ),
    DryingProfile(
      id: 'default_herbs',
      name: 'Herbs',
      tempRangeMin: 40.0,
      tempRangeMax: 50.0,
      humidityRangeMin: 8.0,
      humidityRangeMax: 14.0,
      airFlowRangeMin: 1.0,
      airFlowRangeMax: 1.6,
      expectedDryingTimeHours: 7.0,
      isCustom: false,
    ),
    DryingProfile(
      id: 'default_vegetables',
      name: 'Vegetables',
      tempRangeMin: 55.0,
      tempRangeMax: 65.0,
      humidityRangeMin: 10.0,
      humidityRangeMax: 16.0,
      airFlowRangeMin: 1.5,
      airFlowRangeMax: 2.2,
      expectedDryingTimeHours: 9.0,
      isCustom: false,
    ),
  ];

  List<DryingProfile> getDefaultProfiles() {
    return List.unmodifiable(_defaultProfiles);
  }

  Future<List<DryingProfile>> getCustomProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_customProfilesKey);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => DryingProfile.fromMap(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> saveCustomProfile(DryingProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final currentCustom = await getCustomProfiles();
    
    // Check if profile ID already exists, replace it, otherwise add it.
    final index = currentCustom.indexWhere((p) => p.id == profile.id);
    if (index != -1) {
      currentCustom[index] = profile;
    } else {
      currentCustom.add(profile);
    }

    final jsonString = jsonEncode(currentCustom.map((e) => e.toMap()).toList());
    return await prefs.setString(_customProfilesKey, jsonString);
  }

  Future<bool> deleteCustomProfile(String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    final currentCustom = await getCustomProfiles();
    currentCustom.removeWhere((p) => p.id == profileId);
    final jsonString = jsonEncode(currentCustom.map((e) => e.toMap()).toList());
    return await prefs.setString(_customProfilesKey, jsonString);
  }
}

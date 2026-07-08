import 'package:flutter/material.dart';
import '../../data/models/drying_profile.dart';
import '../../data/repositories/profile_repository.dart';

class LibraryProvider with ChangeNotifier {
  final ProfileRepository _repository = ProfileRepository();

  List<DryingProfile> _defaultProfiles = [];
  List<DryingProfile> _customProfiles = [];
  bool _isLoading = false;

  List<DryingProfile> get defaultProfiles => _defaultProfiles;
  List<DryingProfile> get customProfiles => _customProfiles;
  List<DryingProfile> get allProfiles => [..._defaultProfiles, ..._customProfiles];
  bool get isLoading => _isLoading;

  LibraryProvider() {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    
    _defaultProfiles = _repository.getDefaultProfiles();
    _customProfiles = await _repository.getCustomProfiles();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    _customProfiles = await _repository.getCustomProfiles();
    notifyListeners();
  }

  Future<bool> addCustomProfile({
    required String name,
    required double tempMin,
    required double tempMax,
    required double humidityMin,
    required double humidityMax,
    required double airflowMin,
    required double airflowMax,
    required double expectedHours,
  }) async {
    final newProfile = DryingProfile(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      tempRangeMin: tempMin,
      tempRangeMax: tempMax,
      humidityRangeMin: humidityMin,
      humidityRangeMax: humidityMax,
      airFlowRangeMin: airflowMin,
      airFlowRangeMax: airflowMax,
      expectedDryingTimeHours: expectedHours,
      isCustom: true,
    );

    final success = await _repository.saveCustomProfile(newProfile);
    if (success) {
      await refresh();
    }
    return success;
  }

  Future<bool> deleteProfile(String id) async {
    final success = await _repository.deleteCustomProfile(id);
    if (success) {
      await refresh();
    }
    return success;
  }
}

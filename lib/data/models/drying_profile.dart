class DryingProfile {
  final String id;
  final String name;
  final double tempRangeMin;
  final double tempRangeMax;
  final double humidityRangeMin;
  final double humidityRangeMax;
  final double airFlowRangeMin;
  final double airFlowRangeMax;
  final double expectedDryingTimeHours;
  final bool isCustom;

  DryingProfile({
    required this.id,
    required this.name,
    required this.tempRangeMin,
    required this.tempRangeMax,
    required this.humidityRangeMin,
    required this.humidityRangeMax,
    required this.airFlowRangeMin,
    required this.airFlowRangeMax,
    required this.expectedDryingTimeHours,
    required this.isCustom,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'tempRangeMin': tempRangeMin,
      'tempRangeMax': tempRangeMax,
      'humidityRangeMin': humidityRangeMin,
      'humidityRangeMax': humidityRangeMax,
      'airFlowRangeMin': airFlowRangeMin,
      'airFlowRangeMax': airFlowRangeMax,
      'expectedDryingTimeHours': expectedDryingTimeHours,
      'isCustom': isCustom,
    };
  }

  factory DryingProfile.fromMap(Map<String, dynamic> map) {
    return DryingProfile(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      tempRangeMin: (map['tempRangeMin'] as num).toDouble(),
      tempRangeMax: (map['tempRangeMax'] as num).toDouble(),
      humidityRangeMin: (map['humidityRangeMin'] as num).toDouble(),
      humidityRangeMax: (map['humidityRangeMax'] as num).toDouble(),
      airFlowRangeMin: (map['airFlowRangeMin'] as num).toDouble(),
      airFlowRangeMax: (map['airFlowRangeMax'] as num).toDouble(),
      expectedDryingTimeHours: (map['expectedDryingTimeHours'] as num).toDouble(),
      isCustom: map['isCustom'] ?? false,
    );
  }
}

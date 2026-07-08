import 'alert_model.dart';

enum DryerStatus { healthy, warning, critical, offline }

class DryerDevice {
  final String id;
  final String name;
  final String? currentProduct;
  final double temp;
  final double humidity;
  final double airFlow;
  final bool isOnline;
  final DryerStatus status;
  final String? currentCycleId;
  final DateTime? startDryingTime;
  final double? targetTemp;
  final double? targetHumidity;
  final double? targetAirFlow;
  final double? quantity;
  final double? expectedDryingTimeHours;
  final AlertModel? activeAlert;

  DryerDevice({
    required this.id,
    required this.name,
    this.currentProduct,
    required this.temp,
    required this.humidity,
    required this.airFlow,
    required this.isOnline,
    required this.status,
    this.currentCycleId,
    this.startDryingTime,
    this.targetTemp,
    this.targetHumidity,
    this.targetAirFlow,
    this.quantity,
    this.expectedDryingTimeHours,
    this.activeAlert,
  });

  DryerDevice copyWith({
    String? id,
    String? name,
    String? currentProduct,
    double? temp,
    double? humidity,
    double? airFlow,
    bool? isOnline,
    DryerStatus? status,
    String? currentCycleId,
    DateTime? startDryingTime,
    double? targetTemp,
    double? targetHumidity,
    double? targetAirFlow,
    double? quantity,
    double? expectedDryingTimeHours,
    AlertModel? activeAlert,
  }) {
    return DryerDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      currentProduct: currentProduct != null ? currentProduct : this.currentProduct,
      temp: temp ?? this.temp,
      humidity: humidity ?? this.humidity,
      airFlow: airFlow ?? this.airFlow,
      isOnline: isOnline ?? this.isOnline,
      status: status ?? this.status,
      currentCycleId: currentCycleId != null ? currentCycleId : this.currentCycleId,
      startDryingTime: startDryingTime != null ? startDryingTime : this.startDryingTime,
      targetTemp: targetTemp != null ? targetTemp : this.targetTemp,
      targetHumidity: targetHumidity != null ? targetHumidity : this.targetHumidity,
      targetAirFlow: targetAirFlow != null ? targetAirFlow : this.targetAirFlow,
      quantity: quantity != null ? quantity : this.quantity,
      expectedDryingTimeHours: expectedDryingTimeHours != null ? expectedDryingTimeHours : this.expectedDryingTimeHours,
      activeAlert: activeAlert != null ? activeAlert : this.activeAlert,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'currentProduct': currentProduct,
      'temp': temp,
      'humidity': humidity,
      'airFlow': airFlow,
      'isOnline': isOnline,
      'status': status.name,
      'currentCycleId': currentCycleId,
      'startDryingTime': startDryingTime?.toIso8601String(),
      'targetTemp': targetTemp,
      'targetHumidity': targetHumidity,
      'targetAirFlow': targetAirFlow,
      'quantity': quantity,
      'expectedDryingTimeHours': expectedDryingTimeHours,
      'activeAlert': activeAlert?.toMap(),
    };
  }

  factory DryerDevice.fromMap(Map<String, dynamic> map) {
    return DryerDevice(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      currentProduct: map['currentProduct'],
      temp: (map['temp'] as num).toDouble(),
      humidity: (map['humidity'] as num).toDouble(),
      airFlow: (map['airFlow'] as num).toDouble(),
      isOnline: map['isOnline'] ?? false,
      status: DryerStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => DryerStatus.offline,
      ),
      currentCycleId: map['currentCycleId'],
      startDryingTime: map['startDryingTime'] != null
          ? DateTime.tryParse(map['startDryingTime'])
          : null,
      targetTemp: map['targetTemp'] != null ? (map['targetTemp'] as num).toDouble() : null,
      targetHumidity: map['targetHumidity'] != null ? (map['targetHumidity'] as num).toDouble() : null,
      targetAirFlow: map['targetAirFlow'] != null ? (map['targetAirFlow'] as num).toDouble() : null,
      quantity: map['quantity'] != null ? (map['quantity'] as num).toDouble() : null,
      expectedDryingTimeHours: map['expectedDryingTimeHours'] != null
          ? (map['expectedDryingTimeHours'] as num).toDouble()
          : null,
      activeAlert: map['activeAlert'] != null
          ? AlertModel.fromMap(map['activeAlert'])
          : null,
    );
  }
}

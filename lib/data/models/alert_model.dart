enum AlertSeverity { warning, critical }

class AlertModel {
  final String problem;
  final String reason;
  final String suggestedAction;
  final AlertSeverity severity;
  final DateTime timestamp;

  AlertModel({
    required this.problem,
    required this.reason,
    required this.suggestedAction,
    required this.severity,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'problem': problem,
      'reason': reason,
      'suggestedAction': suggestedAction,
      'severity': severity.name,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory AlertModel.fromMap(Map<String, dynamic> map) {
    return AlertModel(
      problem: map['problem'] ?? '',
      reason: map['reason'] ?? '',
      suggestedAction: map['suggestedAction'] ?? '',
      severity: AlertSeverity.values.firstWhere(
        (e) => e.name == map['severity'],
        orElse: () => AlertSeverity.warning,
      ),
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}

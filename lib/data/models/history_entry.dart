class HistoryEntry {
  final String id;
  final DateTime timestamp;
  final String title;
  final String details;
  final String userRole;

  HistoryEntry({
    required this.id,
    required this.timestamp,
    required this.title,
    required this.details,
    required this.userRole,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'title': title,
      'details': details,
      'userRole': userRole,
    };
  }

  factory HistoryEntry.fromMap(Map<String, dynamic> map) {
    return HistoryEntry(
      id: map['id'] ?? '',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      title: map['title'] ?? '',
      details: map['details'] ?? '',
      userRole: map['userRole'] ?? 'Owner',
    );
  }
}

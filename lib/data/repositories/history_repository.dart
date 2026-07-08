import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_entry.dart';

class HistoryRepository {
  static const String _historyKey = 'dryer_operation_history';

  final List<HistoryEntry> _seedHistory = [
    HistoryEntry(
      id: 'log_01',
      timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 4)),
      title: 'Mango Drying Cycle Completed',
      details: 'Cycle M-JUN06-01 completed successfully. Total dry time: 12 hours. Average Temp: 62.4°C.',
      userRole: 'Owner',
    ),
    HistoryEntry(
      id: 'log_02',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
      title: 'Sensor Calibration Completed',
      details: 'Technician recalibrated temperature probe on Dryer Alpha. Reference deviation corrected by -0.3°C.',
      userRole: 'Technician',
    ),
    HistoryEntry(
      id: 'log_03',
      timestamp: DateTime.now().subtract(const Duration(hours: 18)),
      title: 'Temporary Parameter Change Applied',
      details: 'Dryer Alpha: Temperature setpoint increased from 55°C to 58°C for current batch by operator command.',
      userRole: 'Owner',
    ),
    HistoryEntry(
      id: 'log_04',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      title: 'Tomato Drying Cycle Started',
      details: 'Cycle T-JUL08-01 started on Dryer Alpha. Target Temp: 58.0°C. Batch Weight: 150 kg.',
      userRole: 'Owner',
    ),
  ];

  Future<List<HistoryEntry>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_historyKey);
    
    if (jsonString == null) {
      await saveHistory(_seedHistory);
      return _seedHistory;
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final list = jsonList.map((e) => HistoryEntry.fromMap(e)).toList();
      // Sort history descending by timestamp
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    } catch (_) {
      return _seedHistory;
    }
  }

  Future<bool> saveHistory(List<HistoryEntry> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(list.map((e) => e.toMap()).toList());
    return await prefs.setString(_historyKey, jsonString);
  }

  Future<bool> addEntry(String title, String details, String userRole) async {
    final list = await getHistory();
    final newEntry = HistoryEntry(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      title: title,
      details: details,
      userRole: userRole,
    );
    list.insert(0, newEntry); // Insert at beginning
    return await saveHistory(list);
  }

  Future<bool> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_historyKey);
  }
}

import 'package:intl/intl.dart';

class CycleIdGenerator {
  static String generate({
    required String productName,
    required int index,
  }) {
    final now = DateTime.now();
    final String firstLetter = productName.isNotEmpty ? productName[0].toUpperCase() : 'X';
    final String month = DateFormat('MMM').format(now).toUpperCase();
    final String date = DateFormat('dd').format(now);
    final String numPart = index.toString().padLeft(2, '0');
    
    return '$firstLetter-$month$date-$numPart';
  }
}

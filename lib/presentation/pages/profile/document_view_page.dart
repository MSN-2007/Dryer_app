import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class DocumentViewPage extends StatelessWidget {
  final String title;
  final List<Map<String, String>> sections;

  const DocumentViewPage({
    super.key,
    required this.title,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: sections.length,
        itemBuilder: (context, index) {
          final item = sections[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['heading'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item['content'] ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

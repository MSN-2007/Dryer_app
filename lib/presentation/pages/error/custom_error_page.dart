import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CustomErrorPage extends StatefulWidget {
  final FlutterErrorDetails errorDetails;

  const CustomErrorPage({super.key, required this.errorDetails});

  @override
  State<CustomErrorPage> createState() => _CustomErrorPageState();
}

class _CustomErrorPageState extends State<CustomErrorPage> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderCol = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Console Interruption'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Reassuring Warning Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wifi_protected_setup_outlined,
                  color: AppColors.warning,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              
              const Text(
                'Mobile Interface Reconnecting',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // Friendly crop safety message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.normal.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.normal.withOpacity(0.2), width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.security, color: AppColors.normal, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'CROP DRYER IS SAFE: Your machine has local automatic parameter regulation. It will continue drying your crop at the safe targets even while this interface reloads.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'The mobile console encountered a temporary user interface interruption. You can reload the app to resume monitoring.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Re-initialize CTA Button
              ElevatedButton.icon(
                onPressed: () {
                  // Reboots the app navigation context
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('RELOAD CONSOLE'),
              ),
              const SizedBox(height: 24),

              // Technical info section
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showDetails = !_showDetails;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _showDetails ? 'Hide technical logs' : 'Show technical logs for technicians',
                      style: const TextStyle(fontSize: 12, decoration: TextDecoration.underline),
                    ),
                    Icon(_showDetails ? Icons.expand_less : Icons.expand_more, size: 16),
                  ],
                ),
              ),
              
              if (_showDetails) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderCol),
                  ),
                  child: SelectableText(
                    '${widget.errorDetails.exception}\n\n${widget.errorDetails.stack}',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../state/dryer_provider.dart';
import '../../../data/models/history_entry.dart';
import '../../../data/repositories/history_repository.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final HistoryRepository _repository = HistoryRepository();
  List<HistoryEntry> _logs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });
    final list = await _repository.getHistory();
    setState(() {
      _logs = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final role = Provider.of<DryerProvider>(context, listen: false).currentUserRole;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Operational Audit Log'),
        actions: [
          if (role == 'Owner' && _logs.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: AppColors.critical),
              tooltip: 'Clear Archives',
              onPressed: () => _confirmClearHistory(context),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _logs.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    itemCount: _logs.length,
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    itemBuilder: (context, index) {
                      final log = _logs[index];
                      return _buildHistoryCard(log, isDark);
                    },
                  ),
      ),
    );
  }

  Widget _buildHistoryCard(HistoryEntry log, bool isDark) {
    // Role styling
    Color roleColor;
    switch (log.userRole) {
      case 'Owner':
        roleColor = Colors.green;
        break;
      case 'Technician':
        roleColor = Colors.blue;
        break;
      case 'System':
        roleColor = Colors.orange;
        break;
      default:
        roleColor = Colors.grey;
    }

    final formattedDate = DateFormat('hh:mm a, MMM dd, yyyy').format(log.timestamp);
    final borderCol = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formattedDate,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: roleColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  log.userRole.toUpperCase(),
                  style: TextStyle(color: roleColor, fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            log.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            log.details,
            style: TextStyle(
              fontSize: 12, 
              height: 1.4,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Operational Logs?'),
        content: const Text('This action will wipe all history records. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _repository.clearHistory();
              _loadHistory();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Operational history cleared successfully.')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.critical),
            child: const Text('Wipe Logs'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(), // Pull-to-refresh needs scrollable
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history_toggle_off, size: 64, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              const SizedBox(height: 16),
              const Text('Audit History Empty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Pull down to refresh logs or check back once cycles run.',
                style: TextStyle(fontSize: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

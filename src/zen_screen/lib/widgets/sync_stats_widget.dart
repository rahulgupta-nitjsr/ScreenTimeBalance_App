import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/sync_service.dart';
import '../providers/repository_providers.dart';
import '../utils/theme.dart';

/// Widget that displays detailed sync statistics
class SyncStatsWidget extends ConsumerWidget {
  const SyncStatsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncService = ref.watch(syncServiceProvider);
    
    return FutureBuilder<SyncStats>(
      future: syncService.getSyncStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return _buildErrorWidget(context, snapshot.error.toString());
        }
        
        final stats = snapshot.data!;
        return _buildStatsWidget(context, stats);
      },
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 32),
          const SizedBox(height: 8),
          Text(
            'Failed to load sync stats',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsWidget(BuildContext context, SyncStats stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.cloud_sync,
                color: AppTheme.primaryGreen,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Sync Statistics',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              _buildConnectionStatus(context, stats.isOnline),
            ],
          ),
          const SizedBox(height: 16),
          
          // Data counts
          _buildDataCounts(context, stats),
          
          const SizedBox(height: 16),
          
          // Last sync time
          if (stats.lastSyncTime != null) ...[
            _buildLastSyncTime(context, stats.lastSyncTime!),
            const SizedBox(height: 16),
          ],
          
          // Sync actions
          _buildSyncActions(context),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus(BuildContext context, bool isOnline) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOnline 
            ? AppTheme.secondaryGreen.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOnline 
              ? AppTheme.secondaryGreen.withOpacity(0.3)
              : Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOnline ? Icons.wifi : Icons.wifi_off,
            size: 16,
            color: isOnline ? AppTheme.secondaryGreen : Colors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            isOnline ? 'Online' : 'Offline',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isOnline ? AppTheme.secondaryGreen : Colors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCounts(BuildContext context, SyncStats stats) {
    return Column(
      children: [
        _buildCountRow(
          context,
          'Daily Entries',
          stats.localEntriesCount,
          stats.cloudEntriesCount,
          Icons.calendar_today,
        ),
        const SizedBox(height: 8),
        _buildCountRow(
          context,
          'Timer Sessions',
          stats.localSessionsCount,
          stats.cloudSessionsCount,
          Icons.timer,
        ),
        const SizedBox(height: 8),
        _buildCountRow(
          context,
          'Audit Events',
          stats.localEventsCount,
          stats.cloudEventsCount,
          Icons.history,
        ),
      ],
    );
  }

  Widget _buildCountRow(
    BuildContext context,
    String label,
    int localCount,
    int cloudCount,
    IconData icon,
  ) {
    final isSynced = localCount == cloudCount;
    
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isSynced ? AppTheme.secondaryGreen : Colors.orange,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          '$localCount / $cloudCount',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isSynced ? AppTheme.secondaryGreen : Colors.orange,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          isSynced ? Icons.check_circle : Icons.sync_problem,
          size: 16,
          color: isSynced ? AppTheme.secondaryGreen : Colors.orange,
        ),
      ],
    );
  }

  Widget _buildLastSyncTime(BuildContext context, DateTime lastSync) {
    final timeAgo = _getTimeAgo(lastSync);
    
    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 20,
          color: AppTheme.textLight,
        ),
        const SizedBox(width: 12),
        Text(
          'Last sync: $timeAgo',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textLight,
          ),
        ),
      ],
    );
  }

  Widget _buildSyncActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _handleManualSync(context),
            icon: const Icon(Icons.sync, size: 18),
            label: const Text('Sync Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showSyncDetails(context),
            icon: const Icon(Icons.info_outline, size: 18),
            label: const Text('Details'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryGreen,
              side: BorderSide(color: AppTheme.primaryGreen),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _handleManualSync(BuildContext context) {
    // This will be handled by the parent widget or a provider
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Starting manual sync...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showSyncDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync Details'),
        content: const Text(
          'This feature will show detailed sync information including:\n\n'
          '• Conflict resolution details\n'
          '• Sync performance metrics\n'
          '• Error logs and diagnostics\n'
          '• Data integrity checks',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

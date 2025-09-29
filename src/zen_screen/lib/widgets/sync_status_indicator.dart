import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/sync_service.dart';
import '../utils/theme.dart';

/// Widget that displays sync status with visual indicators
class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncService = ref.watch(syncServiceProvider);
    
    return StreamBuilder<SyncStatus>(
      stream: syncService.syncStatusStream,
      initialData: syncService.currentStatus,
      builder: (context, snapshot) {
        final status = snapshot.data ?? SyncStatus.idle;
        
        return _buildStatusIndicator(context, status);
      },
    );
  }

  Widget _buildStatusIndicator(BuildContext context, SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return _buildIdleIndicator(context);
      case SyncStatus.syncing:
        return _buildSyncingIndicator(context);
      case SyncStatus.completed:
        return _buildCompletedIndicator(context);
      case SyncStatus.error:
        return _buildErrorIndicator(context);
      case SyncStatus.offline:
        return _buildOfflineIndicator(context);
    }
  }

  Widget _buildIdleIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.borderLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_outlined,
            size: 16,
            color: AppTheme.textLight,
          ),
          const SizedBox(width: 4),
          Text(
            'Ready',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncingIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Syncing...',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.secondaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.secondaryGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: AppTheme.secondaryGreen,
          ),
          const SizedBox(width: 4),
          Text(
            'Synced',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.secondaryGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 16,
            color: Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            'Sync Error',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 16,
            color: Colors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            'Offline',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Sync status button that shows current status and allows manual sync
class SyncStatusButton extends ConsumerWidget {
  const SyncStatusButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncService = ref.watch(syncServiceProvider);
    
    return StreamBuilder<SyncStatus>(
      stream: syncService.syncStatusStream,
      initialData: syncService.currentStatus,
      builder: (context, snapshot) {
        final status = snapshot.data ?? SyncStatus.idle;
        
        return _buildSyncButton(context, ref, status);
      },
    );
  }

  Widget _buildSyncButton(BuildContext context, WidgetRef ref, SyncStatus status) {
    final isSyncing = status == SyncStatus.syncing;
    
    return IconButton(
      onPressed: isSyncing ? null : () => _handleSync(context, ref),
      icon: isSyncing
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
              ),
            )
          : Icon(
              _getSyncIcon(status),
              color: _getSyncIconColor(status),
            ),
      tooltip: _getSyncTooltip(status),
    );
  }

  IconData _getSyncIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return Icons.sync;
      case SyncStatus.syncing:
        return Icons.sync;
      case SyncStatus.completed:
        return Icons.check_circle;
      case SyncStatus.error:
        return Icons.sync_problem;
      case SyncStatus.offline:
        return Icons.cloud_off;
    }
  }

  Color _getSyncIconColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return AppTheme.textLight;
      case SyncStatus.syncing:
        return AppTheme.primaryGreen;
      case SyncStatus.completed:
        return AppTheme.secondaryGreen;
      case SyncStatus.error:
        return Colors.red;
      case SyncStatus.offline:
        return Colors.orange;
    }
  }

  String _getSyncTooltip(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return 'Sync data';
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.completed:
        return 'Last sync completed';
      case SyncStatus.error:
        return 'Sync failed - tap to retry';
      case SyncStatus.offline:
        return 'Offline - sync when online';
    }
  }

  Future<void> _handleSync(BuildContext context, WidgetRef ref) async {
    final syncService = ref.read(syncServiceProvider);
    
    try {
      final result = await syncService.manualSync();
      
      if (context.mounted) {
        _showSyncResult(context, result);
      }
    } catch (e) {
      if (context.mounted) {
        _showSyncError(context, e.toString());
      }
    }
  }

  void _showSyncResult(BuildContext context, SyncResult result) {
    String message;
    Color color;
    
    switch (result) {
      case SyncResult.success:
        message = 'Data synced successfully';
        color = AppTheme.secondaryGreen;
        break;
      case SyncResult.failure:
        message = 'Sync failed';
        color = Colors.red;
        break;
      case SyncResult.partialFailure:
        message = 'Some data synced with errors';
        color = Colors.orange;
        break;
      case SyncResult.offline:
        message = 'No internet connection';
        color = Colors.orange;
        break;
      case SyncResult.alreadyInProgress:
        message = 'Sync already in progress';
        color = AppTheme.primaryGreen;
        break;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSyncError(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sync error: $error'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }
}

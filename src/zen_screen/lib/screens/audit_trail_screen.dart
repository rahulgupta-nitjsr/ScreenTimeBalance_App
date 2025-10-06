import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/audit_event.dart';
import '../models/habit_category.dart';
import '../providers/auth_provider.dart';
import '../providers/repository_providers.dart';
import '../utils/theme.dart';
import '../widgets/glass_card.dart';

/// Screen displaying audit trail of all habit edits
/// 
/// **Product Learning:**
/// Transparency builds trust. By showing users exactly what changes have been
/// made to their data, we create accountability and help debug issues.
/// 
/// This is also critical for GDPR compliance - users have the right to know
/// what data is stored about them and when it was modified.
class AuditTrailScreen extends ConsumerWidget {
  const AuditTrailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    if (authState is! Authenticated) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        appBar: AppBar(
          title: const Text('Audit Trail'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: Text(
            'Please sign in to view audit trail',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    final auditRepository = ref.watch(auditRepositoryProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Audit Trail'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<List<AuditEvent>>(
        future: auditRepository.getAllEvents(userId: authState.user.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryGreen,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spaceLG),
                child: Text(
                  'Error loading audit trail: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final events = snapshot.data ?? [];

          if (events.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spaceLG),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 64,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    const SizedBox(height: AppTheme.spaceMD),
                    Text(
                      'No edits yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceSM),
                    Text(
                      'Your habit edits will appear here',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppTheme.spaceMD),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return _AuditEventCard(event: event);
            },
          );
        },
      ),
    );
  }
}

/// Card displaying a single audit event
class _AuditEventCard extends StatelessWidget {
  const _AuditEventCard({required this.event});

  final AuditEvent event;

  @override
  Widget build(BuildContext context) {
    final category = event.category != null
        ? HabitCategoryX.fromId(event.category!)
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spaceMD),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Category Icon
                  if (category != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: category.primaryColor(context).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        category.icon,
                        color: category.primaryColor(context),
                        size: 20,
                      ),
                    ),
                  const SizedBox(width: AppTheme.spaceSM),

                  // Event Type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatEventType(event.eventType),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _formatDateTime(event.createdAt ?? DateTime.now()),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Change Badge
                  _buildChangeBadge(),
                ],
              ),

              // Details
              if (category != null) ...[
                const SizedBox(height: AppTheme.spaceSM),
                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: AppTheme.spaceSM),

                // Category and Change
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailRow(
                        label: 'Category',
                        value: category.label,
                      ),
                    ),
                    Expanded(
                      child: _buildDetailRow(
                        label: 'Change',
                        value: '${event.oldValue ?? 0} → ${event.newValue ?? 0} min',
                      ),
                    ),
                  ],
                ),
              ],

              // Reason
              if (event.reason != null && event.reason!.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spaceSM),
                Container(
                  padding: const EdgeInsets.all(AppTheme.spaceSM),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.notes,
                        size: 16,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.reason!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.8),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Metadata (if any)
              if (event.metadata != null && event.metadata!.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spaceSM),
                _buildMetadataSection(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChangeBadge() {
    if (event.oldValue == null || event.newValue == null) {
      return const SizedBox.shrink();
    }

    final difference = event.newValue! - event.oldValue!;
    final isIncrease = difference > 0;
    final color = isIncrease ? Colors.green : Colors.red;
    final icon = isIncrease ? Icons.arrow_upward : Icons.arrow_downward;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '${difference.abs()} min',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.5),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataSection() {
    final metadata = event.metadata!;
    final oldEarned = metadata['old_earned_time'] as int?;
    final newEarned = metadata['new_earned_time'] as int?;

    if (oldEarned != null && newEarned != null) {
      final earnedDiff = newEarned - oldEarned;
      final earnedColor = earnedDiff >= 0 ? Colors.green : Colors.red;

      return Container(
        padding: const EdgeInsets.all(AppTheme.spaceSM),
        decoration: BoxDecoration(
          color: earnedColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          border: Border.all(
            color: earnedColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.timer,
              size: 16,
              color: earnedColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Screen time: $oldEarned → $newEarned min (${earnedDiff >= 0 ? '+' : ''}$earnedDiff)',
                style: TextStyle(
                  fontSize: 12,
                  color: earnedColor.shade200,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  String _formatEventType(String type) {
    switch (type) {
      case 'habit_edit':
        return 'Habit Edited';
      case 'habit_create':
        return 'Habit Created';
      case 'habit_delete':
        return 'Habit Deleted';
      default:
        return type.split('_').map((word) {
          return word[0].toUpperCase() + word.substring(1);
        }).join(' ');
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else {
      return DateFormat('MMM d, y • h:mm a').format(dateTime);
    }
  }
}


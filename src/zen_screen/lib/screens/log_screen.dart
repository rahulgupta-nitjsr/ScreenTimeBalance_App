import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/habit_category.dart';
import '../models/daily_habit_entry.dart';
import '../providers/algorithm_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/minutes_provider.dart';
import '../providers/timer_provider.dart';
import '../providers/repository_providers.dart';
import '../utils/app_keys.dart';
import '../utils/app_router.dart';
import '../utils/theme.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/glass_card.dart';
import '../widgets/habit_entry_pad.dart';
import '../widgets/edit_habit_dialog.dart';
import '../widgets/glass_snack_bar.dart';
import '../widgets/undo_banner.dart';
import '../providers/habit_edit_provider.dart';
import '../providers/undo_provider.dart';
import '../services/habit_edit_service.dart';
import '../widgets/zen_button.dart';

class LogScreen extends ConsumerStatefulWidget {
  const LogScreen({super.key});

  @override
  ConsumerState<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends ConsumerState<LogScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Timer listener will be set up in build method
  }


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(algorithmResultProvider);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.backgroundGray,
              AppTheme.backgroundGray,
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundGray.withOpacity(0.92),
                border: const Border(
                  bottom: BorderSide(
                    color: AppTheme.borderLight,
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spaceMD),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go(AppRoutes.home);
                          }
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: AppTheme.textMedium,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Log Time',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final horizontalPadding = constraints.maxWidth > AppTheme.breakpointLarge
                      ? AppTheme.spaceXL
                      : AppTheme.spaceLG;
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: AppTheme.spaceXL,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildActiveTimerBanner(context),
                        const SizedBox(height: AppTheme.spaceXL),
                        TabBar(
                          controller: _tabController,
                          labelColor: AppTheme.primaryGreen,
                          unselectedLabelColor: AppTheme.textLight,
                          indicatorColor: AppTheme.primaryGreen,
                          tabs: const [
                            Tab(text: 'Timer'),
                            Tab(text: 'Manual Entry'),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spaceMD),
                        SizedBox(
                          height: 550, // Increased height for better manual entry experience
                          child: TabBarView(
                            controller: _tabController,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _buildTimerCard(context),
                              const HabitEntryPad(),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppTheme.spaceXL),
                        GlassCard(
                          child: Column(
                            children: [
                              Text(
                                'Today\'s Totals',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: AppTheme.spaceMD),
                              _buildTotalsList(context),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppTheme.spaceXL),
                        if (result.powerModeUnlocked)
                          _buildPowerModeSummary(context, result.totalEarnedMinutes)
                        else
                          _buildProgressSummary(context, result.totalEarnedMinutes),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }

  Widget _buildPowerModeSummary(BuildContext context, int earnedMinutes) {
    final theme = Theme.of(context);
    return GlassCard(
      child: Column(
        children: [
          Icon(Icons.rocket_launch, color: AppTheme.secondaryGreen),
          const SizedBox(height: AppTheme.spaceSM),
          Text('POWER+ Mode Unlocked!', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppTheme.spaceXS),
          Text('Total earned today: ${earnedMinutes ~/ 60}h ${earnedMinutes % 60}m'),
        ],
      ),
    );
  }

  Widget _buildProgressSummary(BuildContext context, int earnedMinutes) {
    final theme = Theme.of(context);
    return GlassCard(
      child: Column(
        children: [
          Icon(Icons.hourglass_bottom, color: AppTheme.primaryGreen),
          const SizedBox(height: AppTheme.spaceSM),
          Text('Total earned today: ${earnedMinutes ~/ 60}h ${earnedMinutes % 60}m',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: AppTheme.spaceXS),
          const Text('Keep logging habits to unlock POWER+ mode!'),
        ],
      ),
    );
  }

  Widget _buildTimerCard(BuildContext context) {
    final timerState = ref.watch(timerManagerProvider);
    final timerManager = ref.read(timerManagerProvider.notifier);
    final activeCategory = timerState.activeCategory;
    
    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceXL,
        vertical: AppTheme.spaceLG,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _formatTimerDisplay(timerState.elapsedSeconds),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontFamily: 'Spline Sans',
                  letterSpacing: 2,
                ),
          ),
          const SizedBox(height: AppTheme.spaceSM),
          Text(
            activeCategory != null 
                ? '${activeCategory.label} Timer${_getTimerStatusText(timerState)}'
                : 'Select a category to start timer',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppTheme.spaceLG),
          if (activeCategory != null) ...[
            // Use Wrap instead of Row to handle overflow gracefully
            Wrap(
              alignment: WrapAlignment.center,
              spacing: AppTheme.spaceMD,
              runSpacing: AppTheme.spaceSM,
              children: [
                ZenButton.secondary(
                  'Stop',
                  key: AppKeys.timerStopButton,
                  onPressed: () async {
                    final result = await timerManager.stopTimer();
                    if (!mounted) return;
                    await _handleTimerCompletion(
                      context,
                      activeCategory,
                      result,
                    );
                  },
                ),
                if (timerState.isPaused)
                  ZenButton.success(
                    'Resume',
                    key: AppKeys.timerResumeButton,
                    onPressed: () {
                      timerManager.resumeTimer();
                    },
                  )
                else
                  ZenButton.success(
                    'Pause',
                    key: AppKeys.timerPauseButton,
                    onPressed: () {
                      timerManager.pauseTimer();
                    },
                  ),
                ZenButton.outline(
                  'Cancel',
                  key: AppKeys.timerCancelButton,
                  onPressed: () async {
                    final result = await timerManager.cancelTimer(reason: 'User cancelled');
                    if (!mounted) return;
                    await _handleTimerCompletion(
                      context,
                      activeCategory,
                      result,
                      fromCancellation: true,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceLG),
            _buildActiveCategoryBadge(context, activeCategory, timerState.isPaused),
          ] else ...[
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ZenButton.outline(
                        HabitCategory.sleep.label,
                        key: _categoryKey(HabitCategory.sleep),
                        onPressed: () {
                          _startTimerForCategory(context, timerManager, HabitCategory.sleep);
                        },
                      ),
                    ),
                    const SizedBox(width: AppTheme.spaceMD),
                    Expanded(
                      child: ZenButton.outline(
                        HabitCategory.exercise.label,
                        key: _categoryKey(HabitCategory.exercise),
                        onPressed: () {
                          _startTimerForCategory(context, timerManager, HabitCategory.exercise);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spaceMD),
                Row(
                  children: [
                    Expanded(
                      child: ZenButton.outline(
                        HabitCategory.outdoor.label,
                        key: _categoryKey(HabitCategory.outdoor),
                        onPressed: () {
                          _startTimerForCategory(context, timerManager, HabitCategory.outdoor);
                        },
                      ),
                    ),
                    const SizedBox(width: AppTheme.spaceMD),
                    Expanded(
                      child: ZenButton.outline(
                        HabitCategory.productive.label,
                        key: _categoryKey(HabitCategory.productive),
                        onPressed: () {
                          _startTimerForCategory(context, timerManager, HabitCategory.productive);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveTimerBanner(BuildContext context) {
    final timerState = ref.watch(timerManagerProvider);
    final activeCategory = timerState.activeCategory;
    if (activeCategory == null) {
      return const SizedBox.shrink();
    }

    return GlassCard(
      key: AppKeys.timerStartBanner,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceXL,
        vertical: AppTheme.spaceLG,
      ),
      child: Column(
        children: [
          Text(
            _formatTimerDisplay(timerState.elapsedSeconds),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontFamily: 'Spline Sans',
                  letterSpacing: 2,
                ),
          ),
          const SizedBox(height: AppTheme.spaceSM),
          Text(
            '${activeCategory.label} Timer ${timerState.isPaused ? '(Paused)' : ''}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  String _getTimerStatusText(TimerState timerState) {
    if (timerState.isPaused) {
      return ' (Paused)';
    } else if (timerState.elapsedSeconds > 8 * 60 * 60) { // 8+ hours
      return ' (Long Session)';
    } else if (timerState.elapsedSeconds > 4 * 60 * 60) { // 4+ hours  
      return ' (Extended)';
    }
    return '';
  }

  Widget _buildActiveCategoryBadge(BuildContext context, HabitCategory category, bool isPaused) {
    final theme = Theme.of(context);
    final color = isPaused ? Colors.orange : AppTheme.primaryGreen;
    final label = isPaused ? 'Paused' : 'Running';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceMD,
        vertical: AppTheme.spaceSM,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(category.icon, color: color),
          const SizedBox(width: AppTheme.spaceSM),
          Text(
            '${category.label} Timer $label',
            style: theme.textTheme.bodyMedium?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Future<void> _startTimerForCategory(
    BuildContext context,
    TimerManager timerManager,
    HabitCategory category,
  ) async {
    try {
      await timerManager.startTimer(category);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${category.label} timer started'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
    } on TimerConflictException catch (e) {
      // Show dialog offering to switch timers
      final shouldSwitch = await _showTimerSwitchDialog(context, category);
      if (shouldSwitch == true) {
        await _switchToTimer(context, timerManager, category);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start timer: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool?> _showTimerSwitchDialog(BuildContext context, HabitCategory newCategory) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Timer Already Running'),
        content: Text(
          'You already have a timer running. Would you like to stop the current timer and start the ${newCategory.label} timer instead?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Switch Timer'),
          ),
        ],
      ),
    );
  }

  Future<void> _switchToTimer(
    BuildContext context,
    TimerManager timerManager,
    HabitCategory category,
  ) async {
    try {
      // Stop current timer first
      final timerState = ref.read(timerManagerProvider);
      final currentCategory = timerState.activeCategory;
      final result = await timerManager.stopTimer();
      if (result.earnedMinutes > 0 && currentCategory != null) {
        await _handleTimerCompletion(context, currentCategory, result);
      }
      
      // Start new timer
      await timerManager.startTimer(category);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Switched to ${category.label} timer'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to switch timer: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Key _categoryKey(HabitCategory category) {
    switch (category) {
      case HabitCategory.sleep:
        return AppKeys.timerStartSleepButton;
      case HabitCategory.exercise:
        return AppKeys.timerStartExerciseButton;
      case HabitCategory.outdoor:
        return AppKeys.timerStartOutdoorButton;
      case HabitCategory.productive:
        return AppKeys.timerStartProductiveButton;
    }
  }

  Future<void> _handleTimerCompletion(
    BuildContext context,
    HabitCategory category,
    TimerStopResult result, {
    bool fromCancellation = false,
  }) async {
    if (result.wasCancelled || fromCancellation) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${category.label} timer cancelled. No time recorded.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final earnedMinutes = result.earnedMinutes;
    if (earnedMinutes <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${category.label} timer stopped with no time recorded'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Get authenticated user ID
    final authState = ref.read(authControllerProvider);
    if (authState is! Authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to save your data'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final userId = authState.user.id;

    final minutesNotifier = ref.read(minutesByCategoryProvider.notifier);
    final config = await ref.read(algorithmConfigProvider.future);
    final categoryConfig = config.category(category.id);
    final maxMinutes = categoryConfig?.maxMinutes;

    final currentMinutes = ref.read(minutesByCategoryProvider)[category] ?? 0;
    final totalMinutes = currentMinutes + earnedMinutes;
    minutesNotifier.setMinutesWithValidation(
      category,
      totalMinutes,
      maxMinutes: maxMinutes,
    );

    final minutesMap = ref.read(minutesByCategoryProvider);
    final algorithmService = ref.read(algorithmServiceProvider);
    final repository = ref.read(dailyHabitRepositoryProvider);
    final algorithmResult = algorithmService.calculate(minutesByCategory: minutesMap);
    final algorithmConfig = await ref.read(algorithmConfigProvider.future); // Fetch algorithm config

    await repository.upsertEntry(
      userId: userId, // ✅ Use authenticated user ID
      date: DateTime.now(),
      minutesByCategory: minutesMap,
      earnedScreenTime: algorithmResult.totalEarnedMinutes,
      usedScreenTime: 0,
      powerModeUnlocked: algorithmResult.powerModeUnlocked,
      algorithmVersion: algorithmConfig.version, // Use config version
    );

    // Trigger sync after data save
    try {
      final syncService = ref.read(syncServiceProvider);
      final result = await syncService.manualSync();
    } catch (e) {
      // Sync failure shouldn't block the user experience
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${category.label} timer saved: ${_formatMinutes(earnedMinutes)}'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }
  String _formatTimerDisplay(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Widget _buildTotalsList(BuildContext context) {
    final minutesByCategory = ref.watch(minutesByCategoryProvider);
    final editService = ref.watch(habitEditServiceProvider);

    return Column(
      children: [
        for (final category in HabitCategory.values)
          InkWell(
            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            onTap: () => _showEditDialog(
              context,
              category,
              minutesByCategory[category] ?? 0,
              editService,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppTheme.spaceXS,
                horizontal: AppTheme.spaceSM,
              ),
              child: Row(
                children: [
                  Icon(category.icon, size: 20, color: category.primaryColor(context)),
                  const SizedBox(width: AppTheme.spaceSM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(category.label),
                        const SizedBox(height: AppTheme.spaceXS),
                        FutureBuilder<bool>(
                          future: _hasCategoryBeenEdited(
                            service: editService,
                            category: category,
                          ),
                          builder: (context, snapshot) {
                            final edited = snapshot.data ?? false;
                            if (!edited) return const SizedBox.shrink();
                            return Row(
                              children: [
                                Icon(
                                  Icons.history,
                                  size: 12,
                                  color: AppTheme.textMedium.withOpacity(0.7),
                                ),
                                const SizedBox(width: AppTheme.spaceXS),
                                Text(
                                  'Edited',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textMedium.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        _formatMinutes(minutesByCategory[category] ?? 0),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: AppTheme.spaceSM),
                      Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: AppTheme.textMedium.withOpacity(0.6),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String get _currentUserId {
    final authState = ref.read(authControllerProvider);
    if (authState is Authenticated) return authState.user.id;
    return '';
  }

  Future<void> _showEditDialog(
    BuildContext context,
    HabitCategory category,
    int currentMinutes,
    HabitEditService editService,
  ) async {
    final userId = _currentUserId;
    if (userId.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        GlassSnackBar.error(
          context,
          title: 'Sign in required',
          message: 'Please sign in to edit habit entries.',
        ),
      );
      return;
    }

    final canEdit = await editService.canEditEntry(
      userId: userId,
      entryDate: DateTime.now(),
    );

    if (!canEdit) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        GlassSnackBar.error(
          context,
          title: 'Editing unavailable',
          message: 'You can edit today\'s habits up to ${HabitEditService.maxEditsPerDay} times.',
        ),
      );
      return;
    }
    
    // Get the current entry for undo
    final habitRepo = ref.read(dailyHabitRepositoryProvider);
    final currentEntry = await habitRepo.getEntry(userId: userId, date: DateTime.now());
    if (currentEntry == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        GlassSnackBar.error(
          context,
          title: 'Error',
          message: 'Could not load current habit data.',
        ),
      );
      return;
    }

    if (!context.mounted) return;
    final result = await showDialog<_PendingEditResult?>(
      context: context,
      builder: (ctx) => EditHabitDialog(
        category: category,
        currentMinutes: currentMinutes,
        onSave: (minutes, reason) {
          Navigator.of(ctx).pop(_PendingEditResult(minutes: minutes, reason: reason));
        },
      ),
    );

    if (result == null || !context.mounted) return;

    final editResult = await editService.editHabitEntry(
      userId: userId,
      entryDate: DateTime.now(),
      category: category,
      newMinutes: result.minutes,
      reason: result.reason,
    );

    if (!context.mounted) return;

    if (editResult.requiresConfirmation) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => ConfirmLargeChangeDialog(
          changeSummary: editResult.changeSummary ?? 'This is a significant change. Continue?',
          onConfirm: () => Navigator.of(ctx).pop(true),
        ),
      );

      if (confirmed != true) {
        return;
      }

      final confirmedResult = await editService.editHabitEntry(
        userId: userId,
        entryDate: DateTime.now(),
        category: category,
        newMinutes: result.minutes,
        reason: result.reason,
        confirmed: true,
      );

      _handleEditResult(context, confirmedResult, category, result.minutes, currentMinutes, currentEntry);
      return;
    }

    _handleEditResult(context, editResult, category, result.minutes, currentMinutes, currentEntry);
  }

  void _handleEditResult(
    BuildContext context,
    EditResult result,
    HabitCategory category,
    int newMinutes,
    int oldMinutes,
    DailyHabitEntry previousEntry,
  ) {
    if (!context.mounted) return;

    if (result.success && result.updatedEntry != null) {
      // Record action for undo
      final undoService = ref.read(undoServiceProvider);
      undoService.registerUndoableAction(
        userId: _currentUserId,
        entryDate: DateTime.now(),
        category: category,
        oldMinutes: oldMinutes,
        newMinutes: newMinutes,
        previousEntry: previousEntry,
      );
      
      // Update the UI with the new value
      ref.read(minutesByCategoryProvider.notifier).setMinutes(category, newMinutes);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        GlassSnackBar.success(
          context,
          title: 'Updated ${category.label}',
          message: 'Set to ${_formatMinutes(newMinutes)}. Earned time recalculated.',
        ),
      );
      
      // Show undo banner
      showUndoBanner(
        context,
        undoService: undoService,
        onUndoComplete: () {
          // Refresh UI after undo
          _refreshFromRepository();
        },
      );
      return;
    }

    if (result.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        GlassSnackBar.error(
          context,
          title: 'Edit failed',
          message: result.errorMessage!,
        ),
      );
    }
  }
  
  Future<void> _refreshFromRepository() async {
    // Reload today's data from repository
    final userId = _currentUserId;
    if (userId.isEmpty) return;
    
    final habitRepo = ref.read(dailyHabitRepositoryProvider);
    final today = DateTime.now();
    
    final entry = await habitRepo.getEntry(userId: userId, date: today);
    if (entry != null) {
      // Update UI with repository data
      ref.read(minutesByCategoryProvider.notifier).setAll(entry.minutesByCategory);
    }
  }

  String _formatMinutes(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours == 0) return '${minutes}m';
    return '${hours}h ${minutes}m';
  }

  Future<bool> _hasCategoryBeenEdited({
    required HabitEditService service,
    required HabitCategory category,
  }) async {
    final userId = _currentUserId;
    if (userId.isEmpty) return false;

    final events = await service.getEditHistory(
      userId: userId,
      date: DateTime.now(),
    );

    return events.any((event) => event.category == category.id);
  }
}

class _PendingEditResult {
  const _PendingEditResult({required this.minutes, this.reason});

  final int minutes;
  final String? reason;
}
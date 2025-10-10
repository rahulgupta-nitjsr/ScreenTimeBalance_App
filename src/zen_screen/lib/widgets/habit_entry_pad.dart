import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/algorithm_config.dart';
import '../models/habit_category.dart';
import '../providers/algorithm_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/historical_data_provider.dart';
import '../providers/minutes_provider.dart';
import '../providers/repository_providers.dart';
import '../providers/timer_provider.dart';
import '../utils/theme.dart';

class HabitEntryPad extends ConsumerStatefulWidget {
  const HabitEntryPad({super.key});

  @override
  ConsumerState<HabitEntryPad> createState() => _HabitEntryPadState();
}

class _HabitEntryPadState extends ConsumerState<HabitEntryPad> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: HabitCategory.values.length, vsync: this);
    
    // Listen for app lifecycle changes
    WidgetsBinding.instance.addObserver(_AppLifecycleObserver(this));
  }

  @override
  void dispose() {
    _tabController.dispose();
    WidgetsBinding.instance.removeObserver(_AppLifecycleObserver(this));
    super.dispose();
  }

  /// Save any pending changes when app goes to background
  void _savePendingChanges() {
    // This would save any unsaved changes
    // Implementation depends on specific requirements
  }

  /// Refresh data when app comes back to foreground
  void _refreshData() {
    // Refresh the current state from the database
    _initializeFromState();
  }

  /// Initialize state from current data
  void _initializeFromState() {
    // This method can be implemented to refresh state from database
    // For now, it's a placeholder
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Manual time entry for habit tracking',
      hint: 'Select a habit category and enter time manually',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTabs(context),
          const SizedBox(height: AppTheme.spaceSM),
          _buildRealTimeDisplay(context),
          const SizedBox(height: AppTheme.spaceSM),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                for (final category in HabitCategory.values)
                  Semantics(
                    label: '${category.label} time entry',
                    child: _CategoryEntryPane(category: category),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    return Semantics(
      label: 'Habit categories',
      hint: 'Select a category to enter time manually',
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryGreen,
        unselectedLabelColor: AppTheme.textLight,
        labelPadding: const EdgeInsets.symmetric(horizontal: 1.0),
        labelStyle: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 12.0),
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          color: AppTheme.primaryGreen.withOpacity(0.12),
        ),
        tabs: [
          for (final category in HabitCategory.values)
            Semantics(
              label: '${category.label} category',
              hint: 'Tap to enter ${category.label} time',
              child: Tab(
                text: category.label,
                icon: Icon(category.icon, size: 20),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRealTimeDisplay(BuildContext context) {
    final algorithmResult = ref.watch(algorithmResultProvider);
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Earned Screen Time',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: AppTheme.spaceXS),
              Text(
                '${algorithmResult.totalEarnedMinutes ~/ 60}h ${algorithmResult.totalEarnedMinutes % 60}m',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (algorithmResult.powerModeUnlocked)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spaceSM,
                vertical: AppTheme.spaceXS,
              ),
              decoration: BoxDecoration(
                color: AppTheme.secondaryGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                border: Border.all(color: AppTheme.secondaryGreen.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.rocket_launch,
                    size: 16,
                    color: AppTheme.secondaryGreen,
                  ),
                  const SizedBox(width: AppTheme.spaceXS),
                  Text(
                    'POWER+',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.secondaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryEntryPane extends ConsumerStatefulWidget {
  const _CategoryEntryPane({required this.category});

  final HabitCategory category;

  @override
  ConsumerState<_CategoryEntryPane> createState() => _CategoryEntryPaneState();
}

class _CategoryEntryPaneState extends ConsumerState<_CategoryEntryPane> {
  late int _hours;
  late int _minutes;
  bool _halfHour = false;
  bool _isSaving = false;
  String? _errorMessage;
  Timer? _debounceTimer;
  
  // Performance optimization: cache expensive calculations
  int? _cachedDailyMax;
  int? _cachedCurrentTotal;
  bool? _cachedCanEdit;

  @override
  void initState() {
    super.initState();
    _initializeFromState();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _initializeFromState() {
    final existingMinutes = ref.read(minutesByCategoryProvider)[widget.category] ?? 0;
    _hours = existingMinutes ~/ 60;
    _minutes = existingMinutes % 60;
    _halfHour = _minutes == 30 && widget.category == HabitCategory.sleep;
  }

  /// Get daily maximum for this category from algorithm config
  int _getDailyMaximum() {
    final config = ref.read(algorithmConfigProvider);
    return config.when(
      data: (configData) {
        final categoryConfig = configData.categories[widget.category.id];
        return categoryConfig?.maxMinutes ?? 0;
      },
      loading: () => 0,
      error: (_, __) => 0,
    );
  }

  /// Get current daily total for this category
  int _getCurrentDailyTotal() {
    return ref.read(minutesByCategoryProvider)[widget.category] ?? 0;
  }

  /// Validate if the proposed time entry is within daily limits
  bool _isValidTimeEntry(int totalMinutes) {
    if (totalMinutes < 0) return false;
    
    final dailyMax = _getDailyMaximum();
    final currentTotal = _getCurrentDailyTotal();
    
    // Check if adding this time would exceed daily maximum
    return (currentTotal + totalMinutes) <= dailyMax;
  }

  /// Get remaining minutes available for this category today
  int _getRemainingMinutes() {
    final dailyMax = _getDailyMaximum();
    final currentTotal = _getCurrentDailyTotal();
    return (dailyMax - currentTotal).clamp(0, dailyMax);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalMinutes = _hours * 60 + _minutes;
    
    // Performance optimization: use cached values when possible
    final dailyMax = _cachedDailyMax ?? _getDailyMaximum();
    final currentTotal = _cachedCurrentTotal ?? _getCurrentDailyTotal();
    final canEdit = _cachedCanEdit ?? ref.watch(canEditManuallyProvider(widget.category)) ?? true;
    final activeCategory = ref.watch(activeTimerCategoryProvider);
    
    // Update cache if values changed
    if (_cachedDailyMax != dailyMax) _cachedDailyMax = dailyMax;
    if (_cachedCurrentTotal != currentTotal) _cachedCurrentTotal = currentTotal;
    if (_cachedCanEdit != canEdit) _cachedCanEdit = canEdit;
    
    final isValid = _isValidTimeEntry(totalMinutes);
    final remainingMinutes = _getRemainingMinutes();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        // Timer conflict warning
        if (!canEdit && activeCategory != null)
          Container(
            padding: const EdgeInsets.all(AppTheme.spaceMD),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.timer, color: Colors.orange, size: 20),
                const SizedBox(width: AppTheme.spaceSM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Timer Active',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${activeCategory!.label} timer is running. Stop it to edit manually.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (!canEdit && activeCategory != null) const SizedBox(height: AppTheme.spaceMD),
        
        // Daily progress indicator
        _buildDailyProgressIndicator(theme, currentTotal, dailyMax),
        const SizedBox(height: AppTheme.spaceMD),
        
        // Error message if any
        if (_errorMessage != null)
          Container(
            padding: const EdgeInsets.all(AppTheme.spaceSM),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.red, size: 16),
                const SizedBox(width: AppTheme.spaceXS),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        if (_errorMessage != null) const SizedBox(height: AppTheme.spaceMD),

        // Disable input controls when timer is active
        Opacity(
          opacity: canEdit ? 1.0 : 0.5,
          child: AbsorbPointer(
            absorbing: !canEdit,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HourChips(
                  category: widget.category,
                  selectedHour: _hours,
          onSelect: (hour) {
            _debounceTimer?.cancel();
            _debounceTimer = Timer(const Duration(milliseconds: 50), () {
              setState(() {
                _hours = hour;
                if (widget.category == HabitCategory.sleep && _halfHour) {
                  _minutes = 30;
                } else {
                  _minutes = 0;
                }
                _validateAndClearError();
              });
            });
          },
                ),
                const SizedBox(height: AppTheme.spaceMD),
                if (widget.category == HabitCategory.sleep)
                  _buildHalfHourToggle(theme),
                if (widget.category != HabitCategory.sleep)
                  _buildMinuteSlider(theme),
                const SizedBox(height: AppTheme.spaceMD),
                _QuickPresetsRow(category: widget.category, onPreset: _applyPreset),
                const SizedBox(height: AppTheme.spaceMD),
                _buildActions(theme, isValid, remainingMinutes),
              ],
            ),
          ),
        ),
      ],
      ),
    );
  }

  Widget _buildHalfHourToggle(ThemeData theme) {
    return Semantics(
      label: 'Add 30 minutes to sleep time',
      hint: _halfHour ? 'Enabled' : 'Disabled',
      child: SwitchListTile.adaptive(
        value: _halfHour,
        contentPadding: EdgeInsets.zero,
        activeColor: AppTheme.primaryGreen,
        onChanged: (value) {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 50), () {
          setState(() {
            _halfHour = value;
            _minutes = value ? 30 : 0;
            _validateAndClearError();
          });
        });
        },
        title: Text(
          '+30 minutes',
          style: theme.textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildMinuteSlider(ThemeData theme) {
    final totalMinutes = _hours * 60 + _minutes;
    final remainingMinutes = _getRemainingMinutes();
    final isOverLimit = totalMinutes > remainingMinutes;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Minutes',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spaceSM,
                vertical: AppTheme.spaceXS,
              ),
              decoration: BoxDecoration(
                color: isOverLimit 
                    ? Colors.orange.withOpacity(0.1)
                    : AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                border: Border.all(
                  color: isOverLimit 
                      ? Colors.orange.withOpacity(0.3)
                      : AppTheme.primaryGreen.withOpacity(0.3),
                ),
              ),
              child: Text(
                '$_minutes min',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isOverLimit ? Colors.orange : AppTheme.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceSM),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: isOverLimit ? Colors.orange : AppTheme.primaryGreen,
            inactiveTrackColor: AppTheme.primaryGreen.withOpacity(0.2),
            thumbColor: isOverLimit ? Colors.orange : AppTheme.primaryGreen,
            overlayColor: (isOverLimit ? Colors.orange : AppTheme.primaryGreen).withOpacity(0.2),
            valueIndicatorColor: isOverLimit ? Colors.orange : AppTheme.primaryGreen,
            valueIndicatorTextStyle: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: Semantics(
            label: 'Minutes slider for ${widget.category.label}',
            hint: 'Adjust minutes in 5-minute increments',
            value: '$_minutes minutes',
            child: Slider(
              value: _minutes.toDouble(),
              min: 0,
              max: 55,
              divisions: 11,
              label: '$_minutes min',
              onChanged: (value) {
              _debounceTimer?.cancel();
              _debounceTimer = Timer(const Duration(milliseconds: 50), () {
                setState(() {
                  _minutes = (value ~/ 5) * 5;
                  _validateAndClearError();
                });
              });
              },
            ),
          ),
        ),
        if (isOverLimit && remainingMinutes > 0)
          Padding(
            padding: const EdgeInsets.only(top: AppTheme.spaceXS),
            child: Text(
              'Only ${_formatMinutes(remainingMinutes)} available today',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.orange,
              ),
            ),
          ),
      ],
    );
  }

  /// Validate current input and clear error if valid
  void _validateAndClearError() {
    final totalMinutes = _hours * 60 + _minutes;
    if (_isValidTimeEntry(totalMinutes)) {
      // Only update state if error message exists
      if (_errorMessage != null) {
        setState(() {
          _errorMessage = null;
        });
      }
    }
  }

  /// Build daily progress indicator showing current vs maximum
  Widget _buildDailyProgressIndicator(ThemeData theme, int currentTotal, int dailyMax) {
    final progress = dailyMax > 0 ? (currentTotal / dailyMax).clamp(0.0, 1.0) : 0.0;
    final remaining = dailyMax - currentTotal;
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Progress',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${_formatMinutes(currentTotal)} / ${_formatMinutes(dailyMax)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceXS),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.primaryGreen.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1.0 ? Colors.orange : AppTheme.primaryGreen,
            ),
          ),
          if (remaining > 0) ...[
            const SizedBox(height: AppTheme.spaceXS),
            Text(
              '${_formatMinutes(remaining)} remaining today',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textMedium,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActions(ThemeData theme, bool isValid, int remainingMinutes) {
    final totalMinutes = _hours * 60 + _minutes;
    final isOverLimit = totalMinutes > remainingMinutes;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Selected Time Display - Simplified and Cleaner
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spaceMD,
            vertical: AppTheme.spaceSM,
          ),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.08),
            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Selected: ',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textMedium,
                ),
              ),
              Semantics(
                label: 'Current selection: ${_hours} hours ${_minutes} minutes',
                child: Text(
                  '${_hours}h ${_minutes}m',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spaceSM),
        
        // Warning message if over limit
        if (isOverLimit && remainingMinutes > 0)
          Container(
            padding: const EdgeInsets.all(AppTheme.spaceSM),
            margin: const EdgeInsets.only(bottom: AppTheme.spaceSM),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange, size: 16),
                const SizedBox(width: AppTheme.spaceXS),
                Expanded(
                  child: Text(
                    'Only ${_formatMinutes(remainingMinutes)} available today',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        // Primary Save Button - Large and Prominent
        SizedBox(
          width: double.infinity,
          height: 56, // Fixed height for consistency
          child: Semantics(
            label: 'Save ${_hours} hours ${_minutes} minutes for ${widget.category.label}',
            hint: _isSaving ? 'Saving...' : (isValid ? 'Tap to save' : 'Cannot save - exceeds daily limit'),
            button: true,
            enabled: (totalMinutes >= 0 && isValid && !_isSaving),
            child: ElevatedButton(
              onPressed: (totalMinutes >= 0 && isValid && !_isSaving) 
                  ? () => _save(totalMinutes) 
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppTheme.textLight.withOpacity(0.3),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                ),
              ),
              child: _isSaving 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, size: 24),
                        const SizedBox(width: AppTheme.spaceSM),
                        Text(
                          'Save ${widget.category.label} Time',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spaceSM),
        
        // Secondary Quick Action Button
        OutlinedButton.icon(
          onPressed: _applySameAsLastTime,
          icon: const Icon(Icons.history, size: 18),
          label: Text(
            widget.category == HabitCategory.sleep 
                ? 'Same as last night'
                : 'Same as last time',
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primaryGreen,
            side: BorderSide(color: AppTheme.primaryGreen.withOpacity(0.5)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }

  /// Format minutes into readable string
  String _formatMinutes(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours == 0) return '${minutes}m';
    return '${hours}h ${minutes}m';
  }

  void _applyPreset(Duration preset) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 25), () {
      setState(() {
        _hours = preset.inMinutes ~/ 60;
        _minutes = preset.inMinutes % 60;
        if (widget.category == HabitCategory.sleep) {
          _halfHour = _minutes == 30;
        }
        _validateAndClearError();
      });
    });
  }

  void _applySameAsLastTime() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 25), () async {
      int minutes = 0;
      
      if (widget.category == HabitCategory.sleep) {
        // For sleep, get yesterday's data ("same as last night")
        try {
          minutes = await ref.read(yesterdaySleepMinutesProvider.future);
        } catch (e) {
          // Fallback to current day's data if yesterday's data is not available
          minutes = ref.read(minutesByCategoryProvider)[widget.category] ?? 0;
        }
      } else {
        // For other categories, use today's data ("same as last time")
        minutes = ref.read(minutesByCategoryProvider)[widget.category] ?? 0;
      }
      
      if (mounted) {
        setState(() {
          _hours = minutes ~/ 60;
          _minutes = minutes % 60;
          _halfHour = widget.category == HabitCategory.sleep && _minutes == 30;
          _validateAndClearError();
        });
      }
    });
  }

  Future<void> _save(int totalMinutes) async {
    if (_isSaving) return;
    
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      // Validate before saving
      if (!_isValidTimeEntry(totalMinutes)) {
        final dailyMax = _getDailyMaximum();
        final currentTotal = _getCurrentDailyTotal();
        final remaining = dailyMax - currentTotal;
        
        setState(() {
          _errorMessage = remaining > 0 
              ? 'Only ${_formatMinutes(remaining)} available today (max: ${_formatMinutes(dailyMax)})'
              : 'Daily maximum reached for ${widget.category.label}';
        });
        return;
      }

      // Update state with debounced save
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 100), () async {
        try {
          final minutesNotifier = ref.read(minutesByCategoryProvider.notifier);
          final dailyMax = _getDailyMaximum();
          minutesNotifier.setMinutesWithValidation(widget.category, totalMinutes, maxMinutes: dailyMax);
          final minutesMap = ref.read(minutesByCategoryProvider);

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

          final algorithmService = ref.read(algorithmServiceProvider);
          final repository = ref.read(dailyHabitRepositoryProvider);
          final result = algorithmService.calculate(minutesByCategory: minutesMap);

          await repository.upsertEntry(
            userId: userId,
            date: DateTime.now(),
            minutesByCategory: minutesMap,
            earnedScreenTime: result.totalEarnedMinutes,
            usedScreenTime: 0,
            powerModeUnlocked: result.powerModeUnlocked,
            algorithmVersion: result.algorithmVersion,
          );

          // Trigger sync after data save
          try {
            final syncService = ref.read(syncServiceProvider);
            await syncService.manualSync();
          } catch (e) {
            // Sync failure shouldn't block the user experience
            // Log sync errors for debugging but don't fail the save
          }

          // Verify data persistence
          final savedEntry = await repository.getEntryForDate(
            userId: userId,
            date: DateTime.now(),
          );
          
          if (savedEntry == null) {
            throw Exception('Data persistence verification failed');
          }

          if (!mounted) return;
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.category.label} updated to ${_hours}h ${_minutes}m'),
              duration: const Duration(seconds: 2),
              backgroundColor: AppTheme.primaryGreen,
            ),
          );
          
          // Clear any previous errors
          setState(() {
            _errorMessage = null;
          });
          
        } catch (e) {
          if (!mounted) return;
          
          // Handle different types of errors
          String errorMessage;
          if (e.toString().contains('database') || e.toString().contains('corrupt')) {
            errorMessage = 'Database error. Please restart the app to recover.';
          } else if (e.toString().contains('network') || e.toString().contains('connection')) {
            errorMessage = 'Network error. Data will sync when connection is restored.';
          } else {
            errorMessage = 'Failed to save: ${e.toString()}';
          }
          
          setState(() {
            _errorMessage = errorMessage;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving ${widget.category.label}: $errorMessage'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () => _save(totalMinutes),
              ),
            ),
          );
        } finally {
          if (mounted) {
            setState(() {
              _isSaving = false;
            });
          }
        }
      });
      
    } catch (e) {
      setState(() {
        _errorMessage = 'Validation error: ${e.toString()}';
        _isSaving = false;
      });
    }
  }
}

class _HourChips extends StatelessWidget {
  const _HourChips({
    required this.category,
    required this.selectedHour,
    required this.onSelect,
  });

  final HabitCategory category;
  final int selectedHour;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final hours = _getHoursForCategory(category);
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Hours',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spaceSM),
        Wrap(
          spacing: AppTheme.spaceSM,
          runSpacing: AppTheme.spaceSM,
          children: [
            for (final hour in hours)
              _HourChip(
                hour: hour,
                isSelected: hour == selectedHour,
                onTap: () => onSelect(hour),
                category: category,
              ),
          ],
        ),
      ],
    );
  }

  List<int> _getHoursForCategory(HabitCategory category) {
    switch (category) {
      case HabitCategory.sleep:
        // Sleep: 1-12 hours (as per Feature 5 requirements)
        return List<int>.generate(12, (index) => index + 1);
      case HabitCategory.exercise:
      case HabitCategory.outdoor:
      case HabitCategory.productive:
        // Exercise/Outdoor/Productive: 0-6 hours (dual-layer with minute slider)
        return List<int>.generate(7, (index) => index);
    }
  }
}

class _HourChip extends StatelessWidget {
  const _HourChip({
    required this.hour,
    required this.isSelected,
    required this.onTap,
    required this.category,
  });

  final int hour;
  final bool isSelected;
  final VoidCallback onTap;
  final HabitCategory category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = category.primaryColor(context);
    
    return Semantics(
      label: '${hour} hours for ${category.label}',
      hint: isSelected ? 'Selected' : 'Tap to select',
      selected: isSelected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spaceMD,
            vertical: AppTheme.spaceSM,
          ),
          decoration: BoxDecoration(
            color: isSelected 
                ? color.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusLG),
            border: Border.all(
              color: isSelected 
                  ? color
                  : AppTheme.borderLight,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Text(
            '${hour}h',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isSelected 
                  ? color
                  : AppTheme.textMedium,
              fontWeight: isSelected 
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickPresetsRow extends StatelessWidget {
  const _QuickPresetsRow({required this.category, required this.onPreset});

  final HabitCategory category;
  final ValueChanged<Duration> onPreset;

  @override
  Widget build(BuildContext context) {
    final presets = _presetsForCategory(category);
    if (presets.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final color = category.primaryColor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Presets',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spaceSM),
        Wrap(
          spacing: AppTheme.spaceSM,
          runSpacing: AppTheme.spaceSM,
          children: [
            for (final preset in presets)
              _PresetButton(
                preset: preset,
                onTap: () => onPreset(preset.duration),
                category: category,
              ),
          ],
        ),
      ],
    );
  }

  List<_Preset> _presetsForCategory(HabitCategory category) {
    switch (category) {
      case HabitCategory.sleep:
        return const [
          _Preset(label: 'Same as last night', duration: Duration(hours: 8)),
          _Preset(label: '7.5 hours', duration: Duration(hours: 7, minutes: 30)),
          _Preset(label: '8.5 hours', duration: Duration(hours: 8, minutes: 30)),
        ];
      case HabitCategory.exercise:
        return const [
          _Preset(label: 'Quick 15', duration: Duration(minutes: 15)),
          _Preset(label: '30 min workout', duration: Duration(minutes: 30)),
          _Preset(label: '45 min session', duration: Duration(minutes: 45)),
          _Preset(label: '90 min workout', duration: Duration(minutes: 90)),
        ];
      case HabitCategory.outdoor:
        return const [
          _Preset(label: '15 min walk', duration: Duration(minutes: 15)),
          _Preset(label: '30 min outdoor', duration: Duration(minutes: 30)),
          _Preset(label: '1 hour hike', duration: Duration(hours: 1)),
          _Preset(label: '2 hour adventure', duration: Duration(hours: 2)),
        ];
      case HabitCategory.productive:
        return const [
          _Preset(label: '25 min focus', duration: Duration(minutes: 25)),
          _Preset(label: '1 hour work', duration: Duration(hours: 1)),
          _Preset(label: '2 hours deep work', duration: Duration(hours: 2)),
          _Preset(label: '3 hours project', duration: Duration(hours: 3)),
        ];
    }
  }
}

class _PresetButton extends StatelessWidget {
  const _PresetButton({
    required this.preset,
    required this.onTap,
    required this.category,
  });

  final _Preset preset;
  final VoidCallback onTap;
  final HabitCategory category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = category.primaryColor(context);
    
    return Semantics(
      label: '${preset.label} preset for ${category.label}',
      hint: 'Tap to set ${preset.label}',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spaceMD,
            vertical: AppTheme.spaceSM,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            preset.label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _Preset {
  const _Preset({required this.label, required this.duration});

  final String label;
  final Duration duration;
}

/// App lifecycle observer for handling state management
class _AppLifecycleObserver extends WidgetsBindingObserver {
  final _HabitEntryPadState _state;

  _AppLifecycleObserver(this._state);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        // Save any pending changes when app goes to background
        _state._savePendingChanges();
        break;
      case AppLifecycleState.resumed:
        // Refresh data when app comes back to foreground
        _state._refreshData();
        break;
      default:
        break;
    }
  }
}

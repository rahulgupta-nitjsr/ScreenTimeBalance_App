import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/habit_category.dart';
import '../providers/algorithm_provider.dart';
import '../providers/minutes_provider.dart';
import '../providers/repository_providers.dart';
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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTabs(context),
        const SizedBox(height: AppTheme.spaceMD),
        SizedBox(
          height: 280,
          child: TabBarView(
            controller: _tabController,
            children: [
              for (final category in HabitCategory.values)
                _CategoryEntryPane(category: category),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabs(BuildContext context) {
    return TabBar(
      controller: _tabController,
      labelColor: AppTheme.primaryGreen,
      unselectedLabelColor: AppTheme.textLight,
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        color: AppTheme.primaryGreen.withOpacity(0.12),
      ),
      tabs: [
        for (final category in HabitCategory.values)
          Tab(
            text: category.label,
            icon: Icon(category.icon, size: 20),
          ),
      ],
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

  @override
  void initState() {
    super.initState();
    _initializeFromState();
  }

  void _initializeFromState() {
    final existingMinutes = ref.read(minutesByCategoryProvider)[widget.category] ?? 0;
    _hours = existingMinutes ~/ 60;
    _minutes = existingMinutes % 60;
    _halfHour = _minutes == 30 && widget.category == HabitCategory.sleep;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HourChips(
          category: widget.category,
          selectedHour: _hours,
          onSelect: (hour) {
            setState(() {
              _hours = hour;
              if (widget.category == HabitCategory.sleep && _halfHour) {
                _minutes = 30;
              } else {
                _minutes = 0;
              }
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
        _buildActions(theme),
      ],
    );
  }

  Widget _buildHalfHourToggle(ThemeData theme) {
    return SwitchListTile.adaptive(
      value: _halfHour,
      contentPadding: EdgeInsets.zero,
      activeColor: AppTheme.primaryGreen,
      onChanged: (value) {
        setState(() {
          _halfHour = value;
          _minutes = value ? 30 : 0;
        });
      },
      title: Text(
        '+30 minutes',
        style: theme.textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildMinuteSlider(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Minutes', style: theme.textTheme.bodyMedium),
        Slider(
          value: _minutes.toDouble(),
          min: 0,
          max: 55,
          divisions: 11,
          label: '$_minutes min',
          onChanged: (value) {
            setState(() {
              _minutes = (value ~/ 5) * 5;
            });
          },
        ),
      ],
    );
  }

  Widget _buildActions(ThemeData theme) {
    final totalMinutes = _hours * 60 + _minutes;
    return Row(
      children: [
        Expanded(
          child: Text(
            '${_hours}h ${_minutes}m',
            style: theme.textTheme.titleMedium,
          ),
        ),
        TextButton(
          onPressed: _applySameAsLastTime,
          child: const Text('Same as last time'),
        ),
        const SizedBox(width: AppTheme.spaceSM),
        FilledButton(
          onPressed: totalMinutes >= 0 ? () => _save(totalMinutes) : null,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _applyPreset(Duration preset) {
    setState(() {
      _hours = preset.inMinutes ~/ 60;
      _minutes = preset.inMinutes % 60;
      if (widget.category == HabitCategory.sleep) {
        _halfHour = _minutes == 30;
      }
    });
  }

  void _applySameAsLastTime() {
    final minutes = ref.read(minutesByCategoryProvider)[widget.category] ?? 0;
    setState(() {
      _hours = minutes ~/ 60;
      _minutes = minutes % 60;
      _halfHour = widget.category == HabitCategory.sleep && _minutes == 30;
    });
  }

  Future<void> _save(int totalMinutes) async {
    final minutesNotifier = ref.read(minutesByCategoryProvider.notifier);
    minutesNotifier.setMinutes(widget.category, totalMinutes);
    final minutesMap = ref.read(minutesByCategoryProvider);

    final algorithmService = ref.read(algorithmServiceProvider);
    final repository = ref.read(dailyHabitRepositoryProvider);
    final result = algorithmService.calculate(minutesByCategory: minutesMap);

    await repository.upsertEntry(
      userId: 'local-user',
      date: DateTime.now(),
      minutesByCategory: minutesMap,
      earnedScreenTime: result.totalEarnedMinutes,
      usedScreenTime: 0,
      powerModeUnlocked: result.powerModeUnlocked,
      algorithmVersion: result.algorithmVersion,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.category.label} updated to ${_hours}h ${_minutes}m'),
        duration: const Duration(seconds: 2),
      ),
    );
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
    final hours = category == HabitCategory.sleep
        ? List<int>.generate(12, (index) => index + 1)
        : List<int>.generate(7, (index) => index);
    return Wrap(
      spacing: AppTheme.spaceSM,
      runSpacing: AppTheme.spaceSM,
      children: [
        for (final hour in hours)
          ChoiceChip(
            label: Text('${hour}h'),
            selected: hour == selectedHour,
            onSelected: (_) => onSelect(hour),
          ),
      ],
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

    return Wrap(
      spacing: AppTheme.spaceSM,
      runSpacing: AppTheme.spaceSM,
      children: [
        for (final preset in presets)
          OutlinedButton(
            onPressed: () => onPreset(preset.duration),
            child: Text(preset.label),
          ),
      ],
    );
  }

  List<_Preset> _presetsForCategory(HabitCategory category) {
    switch (category) {
      case HabitCategory.sleep:
        return const [
          _Preset(label: 'Last night', duration: Duration(hours: 8)),
        ];
      case HabitCategory.exercise:
        return const [
          _Preset(label: 'Quick 15', duration: Duration(minutes: 15)),
          _Preset(label: '45-minute session', duration: Duration(minutes: 45)),
          _Preset(label: '90-minute workout', duration: Duration(minutes: 90)),
        ];
      case HabitCategory.outdoor:
        return const [
          _Preset(label: '15-min walk', duration: Duration(minutes: 15)),
          _Preset(label: '1-hour hike', duration: Duration(hours: 1)),
        ];
      case HabitCategory.productive:
        return const [
          _Preset(label: '25-min focus', duration: Duration(minutes: 25)),
          _Preset(label: '1 hour', duration: Duration(hours: 1)),
          _Preset(label: '2 hours', duration: Duration(hours: 2)),
        ];
    }
  }
}

class _Preset {
  const _Preset({required this.label, required this.duration});

  final String label;
  final Duration duration;
}

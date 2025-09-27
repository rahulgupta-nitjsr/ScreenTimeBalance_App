import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/habit_category.dart';

part 'timer_provider.g.dart';

/// Timer state for tracking active timers
class TimerState {
  const TimerState({
    this.activeCategory,
    this.startTime,
    this.elapsedSeconds = 0,
  });

  final HabitCategory? activeCategory;
  final DateTime? startTime;
  final int elapsedSeconds;

  TimerState copyWith({
    HabitCategory? activeCategory,
    DateTime? startTime,
    int? elapsedSeconds,
  }) {
    return TimerState(
      activeCategory: activeCategory ?? this.activeCategory,
      startTime: startTime ?? this.startTime,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }

  bool get isActive => activeCategory != null;
  bool get isCategoryActive => (HabitCategory category) => activeCategory == category;
}

/// Timer provider for managing active timers
@riverpod
class TimerManager extends _$TimerManager {
  Timer? _tickTimer;

  @override
  TimerState build() {
    return const TimerState();
  }

  /// Start a timer for the specified category
  void startTimer(HabitCategory category) {
    if (state.isActive && state.activeCategory != category) {
      // Another timer is already running
      throw TimerConflictException(
        'Only one timer can be active at once. '
        'Stop the current ${state.activeCategory!.label} timer first.',
      );
    }

    if (state.isActive && state.activeCategory == category) {
      // Timer for this category is already running
      return;
    }

    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        final now = DateTime.now();
        final elapsed = state.startTime != null 
            ? now.difference(state.startTime!).inSeconds
            : 0;
        
        state = state.copyWith(elapsedSeconds: elapsed);
      }
    });

    state = state.copyWith(
      activeCategory: category,
      startTime: DateTime.now(),
      elapsedSeconds: 0,
    );
  }

  /// Stop the current timer
  void stopTimer() {
    _tickTimer?.cancel();
    _tickTimer = null;
    
    state = const TimerState();
  }

  /// Pause the current timer
  void pauseTimer() {
    _tickTimer?.cancel();
    _tickTimer = null;
    
    // Keep the state but stop the tick timer
  }

  /// Resume the current timer
  void resumeTimer() {
    if (!state.isActive) return;
    
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        final now = DateTime.now();
        final elapsed = state.startTime != null 
            ? now.difference(state.startTime!).inSeconds
            : 0;
        
        state = state.copyWith(elapsedSeconds: elapsed);
      }
    });
  }

  /// Get the current elapsed time in minutes
  int get elapsedMinutes => (state.elapsedSeconds / 60).floor();

  /// Check if a specific category can be manually edited
  bool canEditManually(HabitCategory category) {
    return !state.isCategoryActive(category);
  }

  /// Get the active timer category if any
  HabitCategory? get activeCategory => state.activeCategory;

  @override
  void dispose() {
    _tickTimer?.cancel();
    super.dispose();
  }
}

/// Exception thrown when trying to start a timer while another is active
class TimerConflictException implements Exception {
  const TimerConflictException(this.message);
  final String message;

  @override
  String toString() => 'TimerConflictException: $message';
}

/// Provider to check if manual entry is allowed for a category
@riverpod
bool canEditManually(CanEditManuallyRef ref, HabitCategory category) {
  final timerManager = ref.watch(timerManagerProvider.notifier);
  return timerManager.canEditManually(category);
}

/// Provider to get the active timer category
@riverpod
HabitCategory? activeTimerCategory(ActiveTimerCategoryRef ref) {
  final timerState = ref.watch(timerManagerProvider);
  return timerState.activeCategory;
}

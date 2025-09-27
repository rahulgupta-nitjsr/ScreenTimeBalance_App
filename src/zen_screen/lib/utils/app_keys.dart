import 'package:flutter/widgets.dart';

/// Centralized keys used for widget testing and accessibility.
class AppKeys {
  AppKeys._();

  static const welcomeGetStartedButton = Key('welcome_get_started_button');
  static const homeLogTimeButton = Key('home_log_time_button');
  static const homeSeeProgressButton = Key('home_see_progress_button');

  // Timer Keys
  static const timerStartSleepButton = Key('timer_start_sleep');
  static const timerStartExerciseButton = Key('timer_start_exercise');
  static const timerStartOutdoorButton = Key('timer_start_outdoor');
  static const timerStartProductiveButton = Key('timer_start_productive');

  static const timerPauseButton = Key('timer_pause_button');
  static const timerResumeButton = Key('timer_resume_button');
  static const timerStopButton = Key('timer_stop_button');
  static const timerCancelButton = Key('timer_cancel_button');

  static const timerDisplay = Key('timer_display');
  static const timerActiveBadge = Key('timer_active_badge');
  static const timerStartBanner = Key('timer_active_banner');

  // Dashboard keys
  static const dashboardDonutChart = Key('dashboard_donut_chart');
  static const dashboardDonutLegend = Key('dashboard_donut_legend');
}


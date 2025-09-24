import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigation_provider.g.dart';

/// Current navigation index for bottom navigation
@riverpod
class NavigationIndex extends _$NavigationIndex {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}

/// Navigation history for back button functionality
@riverpod
class NavigationHistory extends _$NavigationHistory {
  @override
  List<String> build() => ['/'];

  void pushRoute(String route) {
    state = [...state, route];
  }

  void popRoute() {
    if (state.length > 1) {
      state = state.sublist(0, state.length - 1);
    }
  }

  String get currentRoute => state.last;
  String get previousRoute => state.length > 1 ? state[state.length - 2] : '/';
  bool get canPop => state.length > 1;
}

/// App lifecycle state for navigation persistence
enum AppLifecycleState {
  active,
  inactive,
  paused,
  resumed,
  detached,
}

@riverpod
class AppLifecycle extends _$AppLifecycle {
  @override
  AppLifecycleState build() => AppLifecycleState.active;

  void setState(AppLifecycleState newState) {
    state = newState;
  }
}

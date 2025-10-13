# Changelog

All notable changes to ZenScreen will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

---

## [1.2] - 2025-10-12

### Added
- Release 1.2 introduces "Device Screen Time Used" (Android-first, hybrid approach).
- Display of Earned, Used (from OS), and Remaining across Home and Progress screens.

### Technical
- Android integration via Flutter package wrapping `UsageStatsManager` with permission education and deeplink to Usage Access.
- Architecture adds `ScreenTimeService` abstraction and Riverpod provider for used/remaining values.
- Data model persists aggregate daily `used_screen_time`; `remaining_screen_time` derived (clamped to 0).

### Notes
- iOS Screen Time integration scheduled for a later release using native Platform Channels and required entitlements.

---

## [1.11] - 2025-10-09

### Added
- Implemented stricter 2x2 timer category layout on the Log Time screen for consistent button sizing and interaction.

### Changed
- Manual entry tab bar: corrected icon visibility and label sizing for sleep, exercise, outdoor, and productive categories.
- Progress indicator: used `FittedBox` and explicit font sizing to ensure percentage text fits, including values above 100%.
- Donut chart and dashboard responsiveness: adjusted sizing and component behavior for small/wide screens.

### Fixed
- Fixed truncated icons in the Log Time manual entry screen (Exercise and Productive labels).
- Fixed timer button layout issues that caused horizontal overflow and inconsistent sizing.
- Addressed compilation/import issues by adding the required imports and performing cache clean-up when necessary.

### Technical
- Commits include changes to `screens/log_screen.dart`, `widgets/habit_entry_pad.dart`, `widgets/habit_progress_card.dart`, `widgets/home_dashboard.dart`, and `screens/home_screen.dart`.

---

## [1.12] - 2025-10-10

### Added
- Replaced the donut dashboard with clean horizontal activity progress bars to show Sleep, Exercise, Outdoor, and Productive progress at a glance.
- Introduced softer status color tokens for progress indicators: `statusGreenLight`, `statusYellowLight`, and `statusRedLight`.

### Changed
- Progress screen: refined 2x2 grid spacing and aspect ratio for perfect alignment and symmetry.
- Habit progress cards: improved vertical alignment, consistent borders that reflect progress status, and responsive text scaling to prevent truncation.
- Home screen: centered the earned screen time, improved responsive layout, and replaced dense widgets with a minimalist summary card.

### Fixed
- Fixed misaligned and truncated progress circles and inconsistent card borders.
- Resolved multiple layout overflow issues (RenderFlex overflows) across dashboard and cards.
- Resolved incorrect percentage rendering and scaling when progress exceeds 100%.

### Technical
- Key files edited: `widgets/home_dashboard.dart`, `widgets/habit_progress_card.dart`, `screens/progress_screen.dart`, `utils/theme.dart`, `widgets/home_dashboard.dart`.

---

## [1.13] - 2025-10-10

### Added
- Custom "Habits → Screen Time" hero illustration on Welcome screen
- Premium typography hierarchy with gradient "ZenScreen" branding
- New `HabitsToScreenTimeIllustration` widget with 4 colorful habit icons

### Changed
- **UX**: Swapped primary action to "Sign In" (green) and secondary to "Create Account" (gray)
- **Visual**: Lightened primary green color for better contrast and friendliness
- **Layout**: Increased button height to 56px for better touch targets
- **Typography**: Enhanced "ZenScreen" title with larger size (44px) and bold weight (900)

### Fixed
- Resolved RenderFlex overflow issues in hero illustration
- Improved responsive layout for different screen sizes
- Fixed spacing and alignment in Welcome screen card

### Technical
- Updated `welcome_screen.dart` with new layout and typography
- Created `habits_to_screentime_illustration.dart` custom widget
- Modified `theme.dart` primary button color to `#4AE896`
- No breaking changes or data migrations required

---

## Previous Releases

*[Previous releases would be documented here as the project grows]*

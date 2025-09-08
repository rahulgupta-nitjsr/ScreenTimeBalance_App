# ZenScreen - Detailed Features Specification

## Overview
This document defines all features for the ZenScreen mobile app Phase 1, organized by user journey flow with detailed acceptance criteria, technical requirements, and edge case handling.

**Related Documents:**
- [Product Requirements Document](./Product-Requirements-Document.md) - High-level requirements and constraints
- [ScreenTime Earning Algorithm](./ScreenTime-Earning-Algorithm.md) - Detailed algorithm specifications
- [Design Assets](../designs/README.md) - Visual design and wireframes
- [Privacy Policy Framework](./Privacy-Policy-Framework.md) - Privacy compliance and data handling policies

## Table of Contents
1. [Onboarding & Setup Features](#1-onboarding--setup-features)
2. [Core Habit Tracking Features](#2-core-habit-tracking-features)
3. [Progress & Visualization Features](#3-progress--visualization-features)
4. [Profile & Settings Features](#4-profile--settings-features)
5. [System & Utility Features](#5-system--utility-features)
6. [Data Models & Technical Architecture](#6-data-models--technical-architecture)
7. [Cross-Platform Considerations](#7-cross-platform-considerations)
8. [Future Enhancement Roadmap](#8-future-enhancement-roadmap)
9. [Testing Requirements](#9-testing-requirements)

---

## 1. Onboarding & Setup Features

### 1.1 Welcome Screen
**Purpose**: Introduce users to the app's value proposition and guide them to get started.

**User Story**: As a new user, I want to understand what the app does and how it benefits me, so that I can decide to proceed with setup.

**Functional Requirements**:
- Display app name "ScreenTime Balance"
- Show value proposition text
- Present single "Get Started" CTA button
- Apply liquid glass visual design

**Acceptance Criteria**:
- Given a new user opens the app
- When the welcome screen loads
- Then they see the value proposition clearly stated
- And the "Get Started" button is prominently displayed
- And the liquid glass aesthetic is applied consistently

**Technical Requirements**:
- Screen loads within 2 seconds
- Button tap response < 100ms
- Responsive design for Android screen sizes (5"-7")
- Gradient backgrounds render smoothly

### 1.2 Account Creation
**Purpose**: Create user accounts for data persistence and history tracking.

**User Story**: As a new user, I want to create an account with email/password, so that my habit data is saved and accessible across sessions.

**Functional Requirements**:
- Email input field with validation
- Password input field with strength requirements
- Confirm password field
- Create account button
- Firebase Authentication integration
- Error handling for existing accounts

**Acceptance Criteria**:
- Given a user enters valid email and password
- When they tap "Create Account"
- Then a Firebase user account is created
- And they are navigated to the main dashboard
- And their user ID is stored locally

**Technical Requirements**:
- Firebase Auth free tier integration
- Email format validation (regex)
- Password minimum 8 characters, 1 number, 1 letter
- Offline account creation queued for sync
- Local user session persistence

**Edge Cases**:
- Invalid email format → Show validation error
- Weak password → Show strength requirements
- Email already exists → Show "Account exists" message
- Network failure → Queue account creation for later sync
- Firebase quota exceeded → Fallback to local-only mode

### 1.3 User Login
**Purpose**: Allow existing users to access their account and historical data.

**User Story**: As a returning user, I want to log in with my credentials, so that I can access my previous habit tracking data.

**Functional Requirements**:
- Email input field
- Password input field
- Login button
- "Forgot Password" link
- Remember login state
- Automatic login for returning users

**Acceptance Criteria**:
- Given a user enters correct credentials
- When they tap "Login"
- Then they are authenticated via Firebase
- And navigated to the dashboard
- And their historical data is synced

**Technical Requirements**:
- Firebase Auth integration
- Biometric login option (future enhancement)
- Session token management
- Automatic token refresh
- Secure credential storage

**Edge Cases**:
- Wrong credentials → Show error message
- Account doesn't exist → Offer to create account
- Network failure → Allow offline access with cached credentials
- Password reset → Firebase password reset email

### 1.4 How It Works Tutorial
**Purpose**: Educate users about the app's earning algorithm and habit tracking system.

**User Story**: As a new user, I want to understand how the earning system works, so that I can effectively use the app to balance my screen time.

**Functional Requirements**:
- Explain earning time concept (up to 2 hours/day)
- Detail the 4 habit categories and their earning rates
- Explain POWER+ Mode mechanics
- Show penalty system (sleep-based)
- Provide behavioral science rationale

**Acceptance Criteria**:
- Given a user accesses "How It Works"
- When they read through the content
- Then they understand the earning algorithm
- And can identify all 4 habit categories
- And know how POWER+ Mode is unlocked

**Technical Requirements**:
- Static content with scroll functionality
- Links to privacy policy
- Accessible from multiple app locations
- Offline content availability

---

## 2. Core Habit Tracking Features

### 2.1 Timer Functionality
**Purpose**: Allow users to track habit time in real-time using a stopwatch interface.

**User Story**: As a user, I want to start a timer when I begin an activity, so that my habit time is accurately tracked without manual calculation.

**Functional Requirements**:
- Large digital timer display (HH:MM:SS format)
- Start/Stop/Pause timer controls
- Visual indication of active timer
- Background timer continuation
- Timer precision to seconds
- Single active timer enforcement

**Acceptance Criteria**:
- Given a user selects a habit category
- When they tap "Start Timer"
- Then the timer begins counting upward
- And only one timer can be active at a time
- And the timer continues in background
- And stopping the timer adds time to daily total

**Technical Requirements**:
- Millisecond precision timer implementation
- Background task management
- Battery-optimized timer logic
- Local storage of timer state
- Recovery from app crashes/force-close

**Edge Cases**:
- App backgrounded → Timer continues running
- Device sleep → Timer continues, recovers on wake
- App crash → Timer state recovered from last save
- Multiple timer start attempts → Show "One timer at a time" message
- Timer running >24 hours → Auto-stop with warning
- Battery saver mode → Maintain timer accuracy

### 2.2 Manual Time Entry
**Purpose**: Allow users to manually log habit time using +/- controls.

**User Story**: As a user, I want to manually adjust my habit time, so that I can log activities I did without using the timer.

**Functional Requirements**:
- +/- buttons for each habit category
- Display current daily total for each habit
- Increment/decrement in 15-minute intervals
- Visual feedback for button presses
- Real-time screen time calculation updates

**Acceptance Criteria**:
- Given a user wants to log past activity
- When they tap the + button for a habit
- Then 15 minutes is added to that habit's daily total
- And the earned screen time updates immediately
- And the change is saved locally

**Technical Requirements**:
- Immediate UI updates (<100ms response)
- Local SQLite database updates
- Real-time algorithm calculation
- Input validation (no negative values)
- Daily maximums enforcement per category

**Edge Cases**:
- Rapid button presses → Debounce to prevent double-counting
- Exceeding daily maximum → Show limit reached message
- Negative time attempts → Prevent, show minimum is 0
- Concurrent timer running → Prevent manual entry for that category
- Data corruption → Validate and recover from backup

### 2.3 Real-time Screen Time Calculation
**Purpose**: Continuously calculate and display earned screen time based on logged habits.

**User Story**: As a user, I want to see my earned screen time update immediately when I log habits, so that I understand the direct relationship between my actions and rewards.

**Functional Requirements**:
- Live calculation using the defined algorithm
- Display earned screen time prominently
- Show breakdown by habit category
- POWER+ Mode status updates
- Visual progress indicators

**Acceptance Criteria**:
- Given a user logs habit time
- When the data is entered
- Then earned screen time recalculates immediately
- And the display updates within 100ms
- And POWER+ Mode status is checked and updated

**Technical Requirements**:
- Algorithm implementation matching [ScreenTime-Earning-Algorithm.md](./ScreenTime-Earning-Algorithm.md)
- Efficient calculation performance
- State management for real-time updates
- Local caching of calculations
- Validation of algorithm logic

**Edge Cases**:
- Calculation errors → Use last known good state, log error
- Algorithm changes → Migrate existing data
- Floating point precision → Round to minutes for display
- Negative results → Floor at 0 minutes
- Data inconsistency → Recalculate from raw habit data

### 2.4 Single Activity Enforcement
**Purpose**: Ensure only one habit can be actively timed at once to prevent double-counting.

**User Story**: As a user, I want the app to prevent me from running multiple timers, so that my habit tracking is accurate and honest.

**Functional Requirements**:
- Check for active timer before starting new one
- Display "Only one habit can be timed at once" message
- Offer to stop current timer and start new one
- Visual indication of which timer is currently active
- Manual entry disabled for actively timed category

**Acceptance Criteria**:
- Given a timer is already running
- When a user tries to start another timer
- Then they see a prevention message
- And are offered to switch timers
- And manual entry is disabled for the active category

**Technical Requirements**:
- Global timer state management
- UI state synchronization
- Clear user feedback mechanisms
- State persistence across app sessions

**Edge Cases**:
- Timer state corruption → Reset all timers, notify user
- Rapid timer switching → Debounce controls
- Background timer forgotten → Show active timer notification
- Timer running across midnight → Handle day rollover correctly

### 2.5 Habit Data Correction (Edit/Undo)
**Purpose**: Allow users to correct accidental entries while maintaining behavioral integrity.

**User Story**: As a user, I want to correct accidental habit entries, so that my data is accurate, but not so easily that I can game the system.

**Functional Requirements**:
- Edit habit times within same day only
- Undo last action within 5 minutes
- Confirmation dialog for significant changes (>30 min adjustments)
- Audit trail of all corrections
- Visual indication of edited entries

**Acceptance Criteria**:
- Given a user makes an accidental entry
- When they attempt to correct it within the same day
- Then they can edit the time with confirmation
- And the change is logged in audit trail
- And earned screen time recalculates immediately

**Technical Requirements**:
- Time-limited edit windows
- Audit logging for all changes
- Confirmation dialogs for large adjustments
- Real-time algorithm recalculation
- Change history storage

**Behavioral Constraints**:
- No editing of previous days' data (maintains habit integrity)
- Maximum 3 edits per habit per day (prevents excessive gaming)
- Significant changes (>30 min) require written reason
- All edits logged with timestamp and reason

**Edge Cases**:
- User attempts to edit yesterday's data → Show "Can only edit today's habits" message
- Excessive editing attempts → Show "Maximum edits reached" with explanation
- Edit during active timer → Prevent editing of actively timed category
- Edit that would change POWER+ Mode status → Show impact preview before confirmation

---

## 3. Progress & Visualization Features

### 3.1 Dashboard Display
**Purpose**: Provide users with a clear overview of their current status and progress.

**User Story**: As a user, I want to see my earned screen time and daily progress at a glance, so that I can quickly understand my current status.

**Functional Requirements**:
- Large earned screen time display
- POWER+ Mode status indicator
- Motivational quote display
- Primary action buttons (Log Time, See Progress)
- Clean, liquid glass visual design

**Acceptance Criteria**:
- Given a user opens the app
- When the dashboard loads
- Then they see their current earned screen time prominently
- And POWER+ Mode status is clearly indicated
- And primary actions are easily accessible

**Technical Requirements**:
- Data loads within 1 second
- Real-time updates from habit logging
- Smooth animations for status changes
- Responsive layout for different screen sizes

### 3.2 Progress Tracking
**Purpose**: Show detailed progress for each habit category with visual indicators.

**User Story**: As a user, I want to see my progress toward daily goals for each habit, so that I can understand what I need to do to unlock POWER+ Mode.

**Functional Requirements**:
- Circular progress indicators for each habit
- Completion percentages and actual vs. goal times
- Visual distinction between completed and incomplete habits
- Grid layout for easy scanning
- Color coding for progress levels

**Acceptance Criteria**:
- Given a user views the progress screen
- When they see their habit progress
- Then each habit shows current time vs. goal
- And completion percentage is visually clear
- And completed habits are distinctly marked

**Technical Requirements**:
- SVG or Canvas-based circular progress bars
- Smooth animation for progress updates
- Efficient rendering for multiple indicators
- Color accessibility compliance

### 3.3 POWER+ Mode Features
**Purpose**: Gamify the experience by rewarding users who achieve multiple daily goals.

**User Story**: As a user, I want to be celebrated when I unlock POWER+ Mode, so that I feel motivated to maintain healthy habits.

**Functional Requirements**:
- Automatic detection when 3 of 4 goals are met
- Celebration animation/banner display
- Additional 30-minute screen time bonus
- Visual badge or indicator
- Status persistence throughout the day

**Acceptance Criteria**:
- Given a user completes 3 of 4 daily goals
- When the system checks POWER+ Mode eligibility
- Then POWER+ Mode is automatically activated
- And a celebration is displayed
- And the bonus 30 minutes is added to earned time

**Technical Requirements**:
- Real-time goal checking algorithm
- Animation system for celebrations
- State management for POWER+ Mode status
- Daily reset mechanics

**Edge Cases**:
- Goals completed simultaneously → Single celebration
- POWER+ Mode lost due to habit reduction → Update status gracefully
- Day rollover during POWER+ Mode → Reset for new day
- Multiple POWER+ Mode achievements → Only one bonus per day

### 3.4 Historical Data Display
**Purpose**: Show users their habit tracking history and trends over time.

**User Story**: As a user, I want to see my habit tracking history, so that I can understand my patterns and progress over time.

**Functional Requirements**:
- Daily habit summaries for past 7 days
- Earned screen time history
- POWER+ Mode achievement tracking
- Simple trend indicators
- Data export capability (future)

**Acceptance Criteria**:
- Given a user has been using the app for multiple days
- When they view historical data
- Then they see their past 7 days of habit tracking
- And can identify patterns in their behavior

**Technical Requirements**:
- Efficient database queries for historical data
- Local data storage optimization
- Data aggregation for trend calculation
- Privacy-compliant data retention

---

## 4. Profile & Settings Features

### 4.1 User Profile Management
**Purpose**: Allow users to manage their account information and preferences.

**User Story**: As a user, I want to manage my profile information, so that my account reflects my current details and preferences.

**Functional Requirements**:
- Display user avatar (default or uploaded)
- Show name and email address
- Edit profile information
- Avatar upload/selection
- Account information display

**Acceptance Criteria**:
- Given a user accesses their profile
- When they view profile information
- Then they see their current details accurately
- And can edit name and avatar
- And changes are saved and synced

**Technical Requirements**:
- Firebase user profile integration
- Local profile caching
- Image upload and storage
- Data validation for profile updates

### 4.2 Usage Statistics
**Purpose**: Provide users with insights into their app usage and habit patterns.

**User Story**: As a user, I want to see statistics about my app usage, so that I can understand my habits and progress.

**Functional Requirements**:
- Average daily screen time earned
- Most consistent habit category
- POWER+ Mode achievement rate
- Days since starting app
- Streak counters (future enhancement)

**Acceptance Criteria**:
- Given a user has usage history
- When they view statistics
- Then they see accurate calculations of their usage patterns
- And statistics update daily

**Technical Requirements**:
- Statistical calculation algorithms
- Historical data aggregation
- Performance optimization for calculations
- Local caching of computed statistics

### 4.3 App Settings
**Purpose**: Allow users to customize their app experience and manage preferences.

**User Story**: As a user, I want to customize my app settings, so that the app works according to my preferences.

**Functional Requirements**:
- Notification preferences (enable/disable)
- Timer sound settings
- Data sync preferences
- Privacy settings
- Theme options (future)

**Acceptance Criteria**:
- Given a user accesses settings
- When they modify preferences
- Then changes take effect immediately
- And preferences persist across app sessions

**Technical Requirements**:
- Local storage of user preferences
- Settings validation and fallbacks
- Real-time application of settings changes
- Cloud sync of preferences

### 4.4 Account Management
**Purpose**: Provide users with account security and data management options.

**User Story**: As a user, I want to manage my account security and data, so that I have control over my information.

**Functional Requirements**:
- Logout functionality
- Password change option
- Data export request
- Account deletion option
- Privacy policy access

**Acceptance Criteria**:
- Given a user wants to manage their account
- When they access account management
- Then they can perform security actions
- And data management options are available

**Technical Requirements**:
- Secure logout with session cleanup
- Firebase password reset integration
- Data export in standard format
- GDPR-compliant account deletion

### 4.5 Account Deletion Flow
**Purpose**: Handle complete account deletion with proper data cleanup.

**User Story**: As a user, I want to permanently delete my account and all associated data, so that I have complete control over my privacy.

**Functional Requirements**:
- Account deletion confirmation dialog
- Grace period (7 days) before permanent deletion
- Complete data removal from Firebase
- Local data cleanup options
- Deletion confirmation email

**Acceptance Criteria**:
- Given a user requests account deletion
- When they confirm the action
- Then account is marked for deletion with 7-day grace period
- And user receives confirmation email
- And after 7 days, all data is permanently removed

**Technical Requirements**:
- Firebase user account deletion
- Firestore data cleanup
- Local database purging
- Orphaned data handling

**Edge Cases**:
- User deletes cloud account but keeps local app → Show "Account deleted" message, offer local data export, disable sync
- User reinstalls app during grace period → Allow account recovery
- Network failure during deletion → Queue deletion request, retry when online
- Local data exists after cloud deletion → Offer export option, then purge locally

---

## 5. System & Utility Features

### 5.1 Data Persistence
**Purpose**: Ensure user data is reliably stored locally and synced to the cloud.

**User Story**: As a user, I want my data to be saved reliably, so that I don't lose my habit tracking progress.

**Functional Requirements**:
- Local SQLite database for all user data
- Firebase Firestore for cloud backup
- Automatic background sync
- Offline-first data architecture
- Data integrity validation

**Acceptance Criteria**:
- Given a user logs habit data
- When they use the app offline
- Then data is stored locally
- And syncs to cloud when online
- And no data is lost during sync conflicts

**Technical Requirements**:
- SQLite database with proper indexing
- Firebase Firestore integration
- Conflict resolution algorithms
- Data migration strategies
- Backup and restore functionality

**Edge Cases**:
- Sync conflicts → Use last-write-wins with user notification
- Storage quota exceeded → Prompt user to free space
- Corrupted database → Restore from cloud backup
- Network interruption during sync → Queue for retry
- Cloud service unavailable → Continue offline operation

### 5.2 Offline Functionality
**Purpose**: Ensure the app works fully without internet connectivity.

**User Story**: As a user, I want to track my habits even when offline, so that I can use the app anywhere without worrying about connectivity.

**Functional Requirements**:
- Full timer functionality offline
- Manual entry works offline
- Progress calculations work offline
- Data queued for sync when online
- Offline indicator in UI

**Acceptance Criteria**:
- Given a user has no internet connection
- When they use the app
- Then all core features work normally
- And data is saved locally
- And sync occurs when connectivity returns

**Technical Requirements**:
- Local-first architecture
- Background sync service
- Network connectivity monitoring
- Queue management for pending syncs
- Offline state management

### 5.3 Performance Optimization
**Purpose**: Ensure the app performs smoothly across different Android devices.

**User Story**: As a user, I want the app to be fast and responsive, so that tracking my habits is effortless.

**Functional Requirements**:
- App startup time < 3 seconds
- Screen transitions < 300ms
- Timer updates < 100ms response time
- Smooth animations at 60fps
- Battery-efficient background operation

**Acceptance Criteria**:
- Given a user interacts with the app
- When they perform any action
- Then the response is immediate and smooth
- And battery usage is minimized

**Technical Requirements**:
- Optimized database queries
- Efficient state management
- Background task optimization
- Memory leak prevention
- Performance monitoring

### 5.4 Error Handling & Recovery
**Purpose**: Gracefully handle errors and provide recovery mechanisms.

**User Story**: As a user, I want the app to handle errors gracefully, so that I can continue using it even when something goes wrong.

**Functional Requirements**:
- User-friendly error messages
- Automatic error recovery where possible
- Data backup before risky operations
- Crash reporting (anonymous)
- Graceful degradation of features

**Acceptance Criteria**:
- Given an error occurs in the app
- When the user encounters it
- Then they see a helpful error message
- And the app attempts automatic recovery
- And core functionality remains available

**Technical Requirements**:
- Comprehensive error logging
- Automatic backup mechanisms
- Fallback strategies for each feature
- User feedback collection for errors
- Recovery procedures documentation

---

## 6. Data Models & Technical Architecture

### 6.1 Core Data Models

#### User Model
```
User {
  id: string (Firebase UID)
  email: string
  name: string
  avatar_url: string
  created_at: timestamp
  last_login: timestamp
  preferences: UserPreferences
}
```

#### Daily Habit Data Model
```
DailyHabitEntry {
  id: string
  user_id: string
  date: date (YYYY-MM-DD)
  sleep_minutes: integer
  exercise_minutes: integer
  outdoor_minutes: integer
  productive_minutes: integer
  earned_screen_time: integer
  used_screen_time: integer
  power_mode_unlocked: boolean
  algorithm_version: string (e.g., "1.0.0")
  penalty_applied: boolean
  sleep_penalty_minutes: integer
  notes: string (optional, for future use)
  created_at: timestamp
  updated_at: timestamp
  last_modified_by: enum(user, system, sync)
}
```

#### Timer Session Model
```
TimerSession {
  id: string
  user_id: string
  habit_category: enum(sleep, exercise, outdoor, productive)
  start_time: timestamp
  end_time: timestamp
  duration_minutes: integer
  date: date
  was_completed: boolean (false if abandoned/interrupted)
  manual_entry: boolean (false for timer, true for +/- entry)
  interrupted_reason: string (crash, force_close, user_switch, etc.)
  created_at: timestamp
  synced_at: timestamp
}
```

#### Audit Trail Model
```
AuditEvent {
  id: string
  user_id: string
  event_type: enum(habit_edit, data_export, account_delete, timer_start, timer_stop, manual_entry)
  target_date: date
  habit_category: string (optional)
  old_value: integer (optional, for edits)
  new_value: integer (optional, for edits)
  reason: string (optional, for significant changes)
  ip_address: string (hashed for privacy)
  user_agent: string
  created_at: timestamp
}
```

### 6.2 Storage Architecture
- **Primary**: SQLite local database
- **Backup**: Firebase Firestore
- **Sync Strategy**: Local-first with cloud backup
- **Conflict Resolution**: Last-write-wins with user notification

### 6.3 Security Requirements
- Firebase Authentication for user management
- Local database encryption
- Secure API communication (HTTPS)
- Privacy-compliant data handling
- No sensitive data in logs

---

## 7. Cross-Platform Considerations

### 7.1 Technology Stack Recommendation
- **Framework**: Flutter for true cross-platform development
- **Database**: SQLite with sqflite package  
- **Backend**: Firebase (Auth + Firestore) - *See [Section 5.1](#51-data-persistence) for detailed architecture*
- **State Management**: Provider or Riverpod
- **Local Storage**: Shared Preferences for settings

### 7.2 Platform-Specific Adaptations
- **Android**: Material Design components
- **iOS**: Cupertino design elements (future)
- **Navigation**: Platform-appropriate patterns
- **Permissions**: Platform-specific permission handling

### 7.3 Performance Targets
- **App Size**: <50MB download
- **Memory Usage**: <150MB RAM
- **Battery Impact**: <5% daily battery usage
- **Startup Time**: <3 seconds on mid-range devices

---

## 8. Future Enhancement Roadmap

### Phase 2 Features (Post-MVP)
- Weekly/monthly analytics
- Habit streaks and achievements
- Social features (sharing progress)
- Advanced customization options
- Widget support

### Phase 3 Features
- Sensor integration (step counter, sleep tracking)
- AI-powered insights
- Habit recommendations
- Premium features and monetization

---

## 9. Testing Requirements

### 9.1 Functional Testing
- All user stories must have corresponding test cases
- Timer accuracy testing across different scenarios
- Data sync testing with various network conditions
- Algorithm validation testing

### 9.2 Performance Testing
- Load testing with large datasets
- Battery usage testing
- Memory leak testing
- Network efficiency testing

### 9.3 Usability Testing
- User journey testing with real users
- Accessibility testing
- Cross-device compatibility testing
- Error scenario testing

---

*This features document serves as the definitive specification for ScreenTime Balance Phase 1 development. All features align with the Product Requirements Document and visual designs created in the design phase.*

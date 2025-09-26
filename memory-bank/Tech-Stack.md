# Tech Stack - ZenScreen Mobile App

## 🎯 Executive Summary

### Technology Stack Overview
ZenScreen is built using a modern, cross-platform mobile development stack that prioritizes Android-first development while maintaining iOS readiness. The technology choices focus on simplicity, cost-effectiveness, and beginner-friendliness while delivering enterprise-grade functionality.

### Core Development Stack Diagram
```
Flutter (UI Framework)
    ↓
Dart (Programming Language)
    ↓
Android Studio (Development Environment)
    ↓
Riverpod (State Management)
    ↓
SQLite (Local Database)
    ↓
Firebase (Backend Services)
    ↓
Flutter Test (Testing Framework)
    ↓
Android-First, iOS-Ready (Cross-Platform Strategy)
```

### Key Technology Decisions
- **Frontend**: Flutter for cross-platform UI development
- **Backend**: Firebase for serverless backend services
- **Database**: SQLite (local) + Firebase Firestore (cloud)
- **State Management**: Riverpod for modern, type-safe state management
- **Testing**: Flutter Test with comprehensive automated testing
- **Platform Strategy**: Android-first with seamless iOS conversion

### Cost Analysis
- **Development**: Free (Flutter, Android Studio, Firebase free tier)
- **Operational**: Firebase free tier covers initial usage
- **Scaling**: Pay-as-you-grow Firebase pricing model
- **Total Initial Cost**: $0 (free tier sufficient for MVP)

---

## 🎨 Frontend Technologies

### Flutter Framework
**Version**: 3.16.0+ (Latest Stable)
**Purpose**: Cross-platform UI framework for native performance

#### Key Features
- **Single Codebase**: Write once, run on Android and iOS
- **Native Performance**: Compiled to native ARM code
- **Hot Reload**: Instant development feedback
- **Rich Widgets**: Extensive pre-built UI components
- **Custom Rendering**: Flexible UI customization

#### Configuration
```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6
```

#### Best Practices
- Use StatelessWidget for static UI
- Use StatefulWidget for dynamic UI
- Implement proper widget lifecycle management
- Follow Material Design 3 guidelines

### Dart Programming Language
**Version**: 3.2.0+ (Latest Stable)
**Purpose**: Client-optimized programming language for Flutter

#### Key Features
- **Type Safety**: Strong typing with null safety
- **Performance**: Compiled to native code
- **Modern Syntax**: Clean, readable code
- **Async Support**: Built-in async/await
- **Package Ecosystem**: Rich package library

#### Language Features
```dart
// Null Safety
String? nullableString;
String nonNullableString = 'Hello';

// Async Programming
Future<void> fetchData() async {
  final data = await api.getData();
  // Handle data
}

// Type Safety
class User {
  final String name;
  final int age;
  
  User({required this.name, required this.age});
}
```

### UI Framework & Design System
**Material Design 3**: Google's latest design system
**Custom Components**: Liquid glass UI aesthetic

#### Design Principles
- **Consistency**: Unified design language
- **Accessibility**: WCAG 2.1 compliance
- **Responsiveness**: Multi-device support
- **Performance**: Smooth animations and transitions

#### Custom Components
```dart
// Glass Card Component
class GlassCard extends StatelessWidget {
  final Widget child;
  final double opacity;
  
  const GlassCard({
    Key? key,
    required this.child,
    this.opacity = 0.1,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}
```

### State Management - Riverpod
**Version**: 2.4.9+
**Purpose**: Modern, type-safe state management

#### Why Riverpod?
- **Type Safety**: Compile-time error checking
- **Testability**: Easy to mock and test
- **Performance**: Efficient rebuilds
- **Scalability**: Handles complex state management
- **Developer Experience**: Excellent tooling support

#### Implementation
```dart
// Provider Definition
@riverpod
class HabitNotifier extends _$HabitNotifier {
  @override
  List<Habit> build() => [];
  
  void addHabit(Habit habit) {
    state = [...state, habit];
  }
  
  void removeHabit(String id) {
    state = state.where((h) => h.id != id).toList();
  }
}

// Provider Usage
class HabitList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitNotifierProvider);
    
    return ListView.builder(
      itemCount: habits.length,
      itemBuilder: (context, index) {
        return HabitTile(habit: habits[index]);
      },
    );
  }
}
```

### Navigation
**Flutter Navigator 2.0**: Modern navigation system

#### Navigation Structure
```dart
// App Router
class AppRouter {
  static const String welcome = '/welcome';
  static const String home = '/home';
  static const String log = '/log';
  static const String progress = '/progress';
  static const String profile = '/profile';
  static const String howItWorks = '/how-it-works';
}

// Route Configuration
class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRouter.welcome:
        return MaterialPageRoute(builder: (_) => WelcomeScreen());
      case AppRouter.home:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      // ... other routes
      default:
        return MaterialPageRoute(builder: (_) => WelcomeScreen());
    }
  }
}
```

---

## 🔧 Backend Technologies

### Firebase Platform
**Purpose**: Complete serverless backend solution
**Services Used**: Authentication, Firestore, Storage, Analytics, Crashlytics

#### Firebase Authentication
**Purpose**: Secure user authentication and session management

#### Features
- **Multiple Providers**: Email/password, Google, Apple
- **Security**: Built-in security best practices
- **Session Management**: Automatic token refresh
- **User Management**: User profiles and data

#### Implementation
```dart
// Auth Service
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      throw AuthException(e.toString());
    }
  }
  
  Future<User?> createUserWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      throw AuthException(e.toString());
    }
  }
}
```

#### Firebase Firestore
**Purpose**: NoSQL cloud database for real-time data sync

#### Features
- **Real-time Sync**: Automatic data synchronization
- **Offline Support**: Works offline with sync when online
- **Scalability**: Handles millions of documents
- **Security**: Fine-grained access control

#### Data Structure
```dart
// Firestore Collections
class FirestoreCollections {
  static const String users = 'users';
  static const String habits = 'habits';
  static const String timerSessions = 'timer_sessions';
  static const String auditEvents = 'audit_events';
}

// Document Structure
class UserDocument {
  final String id;
  final String email;
  final String name;
  final DateTime createdAt;
  final DateTime lastLogin;
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
    };
  }
}
```

#### Firebase Storage
**Purpose**: File storage for user data and assets

#### Features
- **File Upload**: Secure file upload and download
- **Access Control**: User-specific file access
- **CDN**: Global content delivery
- **Security**: Secure file access rules

#### Implementation
```dart
// Storage Service
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  Future<String> uploadFile(String path, File file) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw StorageException(e.toString());
    }
  }
}
```

#### Firebase Analytics
**Purpose**: User behavior tracking and app insights

#### Features
- **Event Tracking**: Custom event tracking
- **User Properties**: User segmentation
- **Conversion Tracking**: Goal and funnel analysis
- **Real-time Reports**: Live user activity

#### Implementation
```dart
// Analytics Service
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  Future<void> logEvent(String name, Map<String, dynamic> parameters) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }
  
  Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }
}
```

#### Firebase Crashlytics
**Purpose**: Crash reporting and error monitoring

#### Features
- **Crash Reporting**: Automatic crash detection
- **Error Tracking**: Custom error logging
- **Performance Monitoring**: App performance metrics
- **User Impact**: Crash impact analysis

#### Implementation
```dart
// Crashlytics Service
class CrashlyticsService {
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  
  Future<void> recordError(dynamic error, StackTrace stackTrace) async {
    await _crashlytics.recordError(error, stackTrace);
  }
  
  Future<void> setCustomKey(String key, dynamic value) async {
    await _crashlytics.setCustomKey(key, value);
  }
}
```

---

## 🗄️ Database & Storage

### Local Database - SQLite
**Purpose**: Offline-first data storage and performance

#### Features
- **Offline Support**: Works without internet connection
- **Performance**: Fast local data access
- **Reliability**: ACID compliance
- **Lightweight**: Minimal resource usage

#### Implementation
```dart
// Database Service
class DatabaseService {
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    return await openDatabase(
      join(path, 'zen_screen.db'),
      version: 1,
      onCreate: _createTables,
    );
  }
  
  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE habits (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        category TEXT,
        target_duration INTEGER,
        created_at TEXT,
        updated_at TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE timer_sessions (
        id TEXT PRIMARY KEY,
        habit_id TEXT,
        start_time TEXT,
        end_time TEXT,
        duration INTEGER,
        status TEXT,
        created_at TEXT,
        FOREIGN KEY (habit_id) REFERENCES habits (id)
      )
    ''');
  }
}
```

### Cloud Database - Firebase Firestore
**Purpose**: Real-time data synchronization and backup

#### Features
- **Real-time Sync**: Automatic data synchronization
- **Offline Support**: Works offline with sync when online
- **Scalability**: Handles millions of documents
- **Security**: Fine-grained access control

#### Data Models
```dart
// Habit Model
class Habit {
  final String id;
  final String name;
  final String description;
  final String category;
  final int targetDuration;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  Habit({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.targetDuration,
    required this.createdAt,
    required this.updatedAt,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'targetDuration': targetDuration,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
  
  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      category: map['category'],
      targetDuration: map['targetDuration'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
```

### Data Synchronization Strategy
**Offline-First Architecture**: Local data with cloud sync

#### Sync Strategy
1. **Local First**: All operations work offline
2. **Background Sync**: Sync when online
3. **Conflict Resolution**: Last-write-wins with timestamps
4. **Data Integrity**: Validation and error handling

#### Implementation
```dart
// Sync Service
class SyncService {
  final DatabaseService _localDb;
  final FirebaseFirestore _firestore;
  final AlgorithmConfigService _config;
  
  Future<void> syncHabits() async {
    try {
      // Get local changes
      final localChanges = await _localDb.getUnsyncedHabits();
      
      // Upload to cloud
      for (final habit in localChanges) {
        await _firestore
            .collection('habits')
            .doc(habit.id)
            .set(habit.toMap());
      }
      
      // Sync algorithm configuration metadata if updated
      final config = await _config.getActiveConfig();
      await _firestore.collection('configs').doc('earning_algorithm').set({
        'version': config.version,
      'updatedAt': DateTime.now().toIso8601String(),
      });

      // Download cloud changes
      final cloudChanges = await _firestore
          .collection('habits')
          .where('updatedAt', isGreaterThan: _lastSyncTime)
          .get();
      
      // Update local database
      for (final doc in cloudChanges.docs) {
        final habit = Habit.fromMap(doc.data());
      await _localDb.insertOrUpdateHabit(habit);
      }
      
      _lastSyncTime = DateTime.now();
    } catch (e) {
      // Handle sync errors
      await _handleSyncError(e);
    }
  }
}
```

---

## 🛠️ Development Environment

### Android Studio
**Purpose**: Official IDE for Android development with Flutter support

#### Features
- **Flutter Plugin**: Integrated Flutter development tools
- **Hot Reload**: Instant code changes
- **Debugging**: Advanced debugging capabilities
- **Emulator**: Built-in Android emulator
- **Profiling**: Performance analysis tools

#### Setup
1. Install Android Studio
2. Install Flutter plugin
3. Configure Flutter SDK path
4. Set up Android emulator
5. Enable USB debugging for physical devices

#### Configuration
```bash
# Flutter Doctor Check
flutter doctor

# Expected Output:
# ✓ Flutter (Channel stable, 3.16.0)
# ✓ Android toolchain - develop for Android devices
# ✓ Android Studio (version 2023.1)
# ✓ VS Code (version 1.80.0)
# ✓ Connected device (1 available)
```

### Cursor IDE
**Purpose**: AI-powered code editor with Flutter support

#### Features
- **AI Assistance**: Intelligent code completion
- **Flutter Support**: Flutter-specific features
- **Git Integration**: Version control integration
- **Extensions**: Flutter and Dart extensions
- **Terminal**: Integrated terminal for commands

#### Extensions
- **Flutter**: Official Flutter extension
- **Dart**: Dart language support
- **Flutter Intl**: Internationalization support
- **Flutter Widget Snippets**: Widget code snippets

### Version Control - Git
**Purpose**: Source code version control and collaboration

#### Workflow
```bash
# Feature Branch Workflow
git checkout -b feature/habit-tracking
git add .
git commit -m "Add habit tracking functionality"
git push origin feature/habit-tracking

# Create Pull Request
# Review and merge
git checkout main
git pull origin main
```

#### Git Hooks
```bash
# Pre-commit Hook
#!/bin/sh
flutter analyze
flutter test
```

---

## 🧪 Testing & Quality Assurance

### Testing Framework - Flutter Test
**Purpose**: Comprehensive testing for Flutter applications

#### **🚨 CRITICAL: Test Directory Structure**

**ALWAYS use these established test directories:**
- ✅ **Flutter Tests**: `ScreenTimeBalance\tests\flutter\`
- ✅ **Unit Tests**: `ScreenTimeBalance\tests\flutter\unit\`
- ✅ **Widget Tests**: `ScreenTimeBalance\tests\flutter\widget\`
- ✅ **Integration Tests**: `ScreenTimeBalance\tests\flutter\integration\`
- ✅ **Test Mocks**: `ScreenTimeBalance\tests\flutter\mocks\`

**❌ NEVER create new test folders** - Always use the existing structure and place test artifacts in the designated locations.

#### Testing Levels
1. **Unit Tests**: Individual function testing
2. **Widget Tests**: UI component testing
3. **Integration Tests**: End-to-end testing
4. **Performance Tests**: Performance benchmarking

#### Unit Testing
```dart
// Example Unit Test
void main() {
  group('HabitService', () {
    late HabitService habitService;
    
    setUp(() {
      habitService = HabitService();
    });
    
    test('should create habit successfully', () {
      // Arrange
      final habit = Habit(
        id: '1',
        name: 'Meditation',
        description: 'Daily meditation practice',
        category: 'Wellness',
        targetDuration: 30,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Act
      final result = habitService.createHabit(habit);
      
      // Assert
      expect(result, isA<Habit>());
      expect(result.name, equals('Meditation'));
    });
  });
}
```

#### Widget Testing
```dart
// Example Widget Test
void main() {
  testWidgets('HabitCard displays habit information', (WidgetTester tester) async {
    // Arrange
    final habit = Habit(
      id: '1',
      name: 'Meditation',
      description: 'Daily meditation practice',
      category: 'Wellness',
      targetDuration: 30,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: HabitCard(habit: habit),
      ),
    );
    
    // Assert
    expect(find.text('Meditation'), findsOneWidget);
    expect(find.text('Daily meditation practice'), findsOneWidget);
    expect(find.text('Wellness'), findsOneWidget);
  });
}
```

#### Integration Testing
```dart
// Example Integration Test
void main() {
  group('Habit Flow Integration Tests', () {
    testWidgets('Complete habit creation flow', (WidgetTester tester) async {
      // Start app
      await tester.pumpWidget(MyApp());
      
      // Navigate to habit creation
      await tester.tap(find.byKey(Key('add_habit_button')));
      await tester.pumpAndSettle();
      
      // Fill form
      await tester.enterText(find.byKey(Key('habit_name_field')), 'Meditation');
      await tester.enterText(find.byKey(Key('habit_description_field')), 'Daily practice');
      
      // Submit form
      await tester.tap(find.byKey(Key('submit_button')));
      await tester.pumpAndSettle();
      
      // Verify habit created
      expect(find.text('Meditation'), findsOneWidget);
    });
  });
}
```

### Mocking - Mockito
**Purpose**: Create test doubles for dependencies

#### Implementation
```dart
// Mock Database Service
@GenerateMocks([DatabaseService])
void main() {
  group('HabitProvider Tests', () {
    late MockDatabaseService mockDatabaseService;
    late HabitProvider habitProvider;
    
    setUp(() {
      mockDatabaseService = MockDatabaseService();
      habitProvider = HabitProvider(mockDatabaseService);
    });
    
    test('should load habits from database', () async {
      // Arrange
      final habits = [
        Habit(id: '1', name: 'Meditation', /* ... */),
        Habit(id: '2', name: 'Exercise', /* ... */),
      ];
      when(mockDatabaseService.getAllHabits())
          .thenAnswer((_) async => habits);
      
      // Act
      await habitProvider.loadHabits();
      
      // Assert
      expect(habitProvider.habits, equals(habits));
      verify(mockDatabaseService.getAllHabits()).called(1);
    });
  });
}
```

### Test Coverage
**Target**: 90% code coverage

#### Coverage Tools
```bash
# Generate Coverage Report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

#### Coverage Targets
- **Unit Tests**: 95% coverage
- **Widget Tests**: 85% coverage
- **Integration Tests**: 80% coverage
- **Overall**: 90% coverage

---

## 📱 Platform & Deployment

### Primary Platform - Android
**Target**: Android API 21+ (Android 5.0+)
**Coverage**: 95% of Android devices

#### Android Configuration
```gradle
// android/app/build.gradle
android {
    compileSdkVersion 34
    defaultConfig {
        applicationId "com.zenscreen.app"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
}
```

#### Permissions
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.VIBRATE" />
```

### Secondary Platform - iOS (Future)
**Target**: iOS 12.0+
**Strategy**: Seamless conversion with minimal changes

#### iOS Configuration
```yaml
# ios/Runner/Info.plist
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
<key>CFBundleVersion</key>
<string>1</string>
```

### Build Process
**Debug Build**: Development and testing
**Release Build**: Production deployment

#### Debug Build
```bash
# Debug APK
flutter build apk --debug

# Debug Bundle
flutter build appbundle --debug
```

#### Release Build
```bash
# Release APK
flutter build apk --release

# Release Bundle
flutter build appbundle --release
```

### APK Generation
**Purpose**: Android application package for distribution

#### Build Commands
```bash
# Generate APK
flutter build apk --release

# Generate App Bundle (Recommended)
flutter build appbundle --release

# Generate Split APKs
flutter build apk --split-per-abi
```

#### APK Optimization
- **Code Shrinking**: Remove unused code
- **Resource Shrinking**: Remove unused resources
- **Obfuscation**: Code obfuscation for security
- **Compression**: APK size optimization

### Play Store Deployment
**Purpose**: Google Play Store distribution

#### Requirements
- **App Bundle**: Use AAB format (recommended)
- **Signing**: App signing with keystore
- **Metadata**: App description, screenshots, icons
- **Privacy Policy**: Required for data collection

#### Deployment Process
1. **Build Release**: Generate signed AAB
2. **Upload**: Upload to Play Console
3. **Review**: Google review process
4. **Publish**: Release to users

#### Signing Configuration
```gradle
// android/app/build.gradle
android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

---

## 🔒 Security & Privacy

### Data Encryption
**Local Encryption**: SQLite database encryption
**Cloud Encryption**: Firebase data encryption

#### Local Encryption
```dart
// Encrypted Database
class EncryptedDatabaseService {
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initEncryptedDatabase();
    return _database!;
  }
  
  Future<Database> _initEncryptedDatabase() async {
    final path = await getDatabasesPath();
    final key = await _getEncryptionKey();
    
    return await openDatabase(
      join(path, 'zen_screen_encrypted.db'),
      version: 1,
      onCreate: _createTables,
      password: key,
    );
  }
}
```

### API Security
**Firebase Security Rules**: Fine-grained access control

#### Firestore Security Rules
```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Habits are user-specific
    match /habits/{habitId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
  }
}
```

### Authentication Security
**Session Management**: Secure token handling
**Password Security**: Strong password requirements

#### Security Implementation
```dart
// Auth Security
class AuthSecurity {
  static const int minPasswordLength = 8;
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);
  
  static bool isPasswordStrong(String password) {
    return password.length >= minPasswordLength &&
           password.contains(RegExp(r'[A-Z]')) &&
           password.contains(RegExp(r'[a-z]')) &&
           password.contains(RegExp(r'[0-9]')) &&
           password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }
}
```

### Privacy Compliance
**GDPR Compliance**: European data protection
**Data Minimization**: Collect only necessary data

#### Privacy Implementation
```dart
// Privacy Service
class PrivacyService {
  Future<void> requestDataDeletion(String userId) async {
    // Delete local data
    await _localDb.deleteUserData(userId);
    
    // Delete cloud data
    await _firestore.collection('users').doc(userId).delete();
    
    // Delete user account
    await _auth.currentUser?.delete();
  }
  
  Future<Map<String, dynamic>> exportUserData(String userId) async {
    final userData = await _localDb.getUserData(userId);
    final cloudData = await _firestore.collection('users').doc(userId).get();
    
    return {
      'localData': userData,
      'cloudData': cloudData.data(),
      'exportDate': DateTime.now().toIso8601String(),
    };
  }
}
```

---

## ⚡ Performance & Optimization

### Performance Targets
**App Launch**: < 3 seconds
**Screen Transition**: < 300ms
**Memory Usage**: < 100MB
**Battery Impact**: Minimal background usage

### Memory Management
**Efficient Widgets**: Proper widget lifecycle
**Image Optimization**: Compressed images
**Memory Monitoring**: Memory usage tracking

#### Memory Optimization
```dart
// Memory Efficient Widget
class OptimizedHabitList extends StatelessWidget {
  final List<Habit> habits;
  
  const OptimizedHabitList({Key? key, required this.habits}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: habits.length,
      itemBuilder: (context, index) {
        return HabitTile(
          key: ValueKey(habits[index].id),
          habit: habits[index],
        );
      },
    );
  }
}
```

### Battery Optimization
**Background Tasks**: Minimal background processing
**Wake Locks**: Efficient wake lock usage
**Power Monitoring**: Battery usage tracking

#### Battery Optimization
```dart
// Battery Efficient Timer
class BatteryEfficientTimer {
  Timer? _timer;
  bool _isRunning = false;
  
  void startTimer(Duration duration, VoidCallback onTick) {
    if (_isRunning) return;
    
    _isRunning = true;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      onTick();
    });
  }
  
  void stopTimer() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }
}
```

### Network Optimization
**Data Usage**: Minimize data consumption
**Offline Support**: Full offline functionality
**Sync Efficiency**: Smart synchronization

#### Network Optimization
```dart
// Network Efficient Sync
class NetworkEfficientSync {
  static const Duration syncInterval = Duration(minutes: 15);
  static const int maxRetries = 3;
  
  Future<void> syncData() async {
    if (!await _isOnline()) return;
    
    try {
      await _syncHabits();
      await _syncTimerSessions();
      await _syncUserData();
    } catch (e) {
      await _handleSyncError(e);
    }
  }
}
```

### UI Performance
**Smooth Animations**: 60fps animations
**Efficient Rendering**: Optimized widget rendering
**Loading States**: Proper loading indicators

#### UI Performance
```dart
// Performance Optimized Animation
class SmoothAnimation extends StatefulWidget {
  @override
  _SmoothAnimationState createState() => _SmoothAnimationState();
}

class _SmoothAnimationState extends State<SmoothAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

---

## 📊 Monitoring & Analytics

### User Analytics - Firebase Analytics
**Purpose**: User behavior tracking and app insights

#### Event Tracking
```dart
// Analytics Events
class AnalyticsEvents {
  static const String habitCreated = 'habit_created';
  static const String timerStarted = 'timer_started';
  static const String timerCompleted = 'timer_completed';
  static const String screenViewed = 'screen_viewed';
  
  static Future<void> trackHabitCreated(String habitName) async {
    await FirebaseAnalytics.instance.logEvent(
      name: habitCreated,
      parameters: {
        'habit_name': habitName,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}
```

### Error Monitoring - Firebase Crashlytics
**Purpose**: Crash reporting and error tracking

#### Error Tracking
```dart
// Error Tracking
class ErrorTracking {
  static Future<void> recordError(dynamic error, StackTrace stackTrace) async {
    await FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }
  
  static Future<void> setUserContext(String userId) async {
    await FirebaseCrashlytics.instance.setUserIdentifier(userId);
  }
}
```

### Performance Monitoring
**Purpose**: App performance metrics and optimization

#### Performance Metrics
```dart
// Performance Monitoring
class PerformanceMonitoring {
  static Future<void> startTrace(String traceName) async {
    await FirebasePerformance.instance.startTrace(traceName);
  }
  
  static Future<void> stopTrace(String traceName) async {
    await FirebasePerformance.instance.stopTrace(traceName);
  }
}
```

---

## 📦 Dependencies & Packages

### Complete pubspec.yaml
```yaml
name: zen_screen
description: A mindful screen time balance app
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.16.0"

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3
  
  # Database
  sqflite: ^2.3.0
  path: ^1.8.3
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  firebase_storage: ^11.5.6
  firebase_analytics: ^10.7.4
  firebase_crashlytics: ^3.4.9
  
  # UI Components
  cupertino_icons: ^1.0.6
  
  # Utilities
  shared_preferences: ^2.2.2
  intl: ^0.19.0
  uuid: ^4.2.1
  
  # Development
  flutter_lints: ^3.0.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # Code Generation
  build_runner: ^2.4.7
  riverpod_generator: ^2.3.9
  
  # Testing
  mockito: ^5.4.4
  
  # Linting
  flutter_lints: ^3.0.1

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
    - assets/fonts/
```

### Package Descriptions
- **flutter_riverpod**: Modern state management
- **sqflite**: SQLite database for Flutter
- **firebase_core**: Firebase initialization
- **firebase_auth**: User authentication
- **cloud_firestore**: NoSQL cloud database
- **firebase_storage**: File storage
- **firebase_analytics**: User analytics
- **firebase_crashlytics**: Crash reporting
- **shared_preferences**: Local key-value storage
- **intl**: Internationalization
- **uuid**: Unique ID generation
- **mockito**: Testing mocks

---

## ⚙️ Configuration & Environment

### Environment Variables
**Development**: Debug configuration
**Production**: Release configuration

#### Environment Configuration
```dart
// Environment Configuration
class Environment {
  static const String development = 'development';
  static const String production = 'production';
  
  static String get current {
    return const String.fromEnvironment('ENV', defaultValue: development);
  }
  
  static bool get isDevelopment => current == development;
  static bool get isProduction => current == production;
}
```

### Build Configurations
**Debug**: Development builds
**Release**: Production builds

#### Build Configuration
```dart
// Build Configuration
class BuildConfig {
  static const String appName = 'ZenScreen';
  static const String packageName = 'com.zenscreen.app';
  static const String version = '1.0.0';
  static const int versionCode = 1;
  
  static String get buildType {
    return const String.fromEnvironment('BUILD_TYPE', defaultValue: 'debug');
  }
}
```

### Firebase Configuration
**Project Settings**: Firebase project configuration
**API Keys**: Secure API key management

#### Firebase Configuration
```dart
// Firebase Configuration
class FirebaseConfig {
  static const String projectId = 'zenscreen-app';
  static const String apiKey = 'your-api-key';
  static const String authDomain = 'zenscreen-app.firebaseapp.com';
  static const String storageBucket = 'zenscreen-app.appspot.com';
  static const String messagingSenderId = '123456789';
  static const String appId = '1:123456789:android:abcdef123456';
}
```

---

## 🔧 Troubleshooting & FAQ

### Common Issues
**Build Errors**: Compilation and build problems
**Runtime Errors**: App crashes and errors
**Performance Issues**: Slow performance and optimization

#### Build Issues
```bash
# Clean Build
flutter clean
flutter pub get
flutter build apk

# Doctor Check
flutter doctor

# Dependency Issues
flutter pub deps
flutter pub upgrade
```

#### Runtime Issues
```dart
// Error Handling
class ErrorHandler {
  static void handleError(dynamic error, StackTrace stackTrace) {
    // Log error
    print('Error: $error');
    print('StackTrace: $stackTrace');
    
    // Report to Crashlytics
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }
}
```

### Performance Issues
**Memory Leaks**: Memory usage optimization
**Slow Animations**: Animation performance
**Battery Drain**: Battery usage optimization

#### Performance Debugging
```dart
// Performance Debugging
class PerformanceDebugger {
  static void startPerformanceMonitoring() {
    // Enable performance monitoring
    FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
  }
  
  static void logPerformanceMetric(String name, int value) {
    // Log performance metrics
    print('Performance: $name = $value');
  }
}
```

---

## 🚀 Future Roadmap

### Technology Updates
**Flutter Updates**: Framework version upgrades
**Dart Updates**: Language version upgrades
**Firebase Updates**: Service version upgrades

#### Update Strategy
```bash
# Flutter Update
flutter upgrade

# Dependency Update
flutter pub upgrade

# Major Version Update
flutter upgrade --major-versions
```

### Platform Expansion
**iOS Development**: Native iOS app
**Web Development**: Progressive web app
**Desktop Development**: Windows, macOS, Linux

#### Platform Strategy
```dart
// Platform Detection
class PlatformDetection {
  static bool get isAndroid => Platform.isAndroid;
  static bool get isIOS => Platform.isIOS;
  static bool get isWeb => kIsWeb;
  static bool get isDesktop => Platform.isWindows || Platform.isMacOS || Platform.isLinux;
}
```

### Scalability Planning
**User Growth**: Handle millions of users
**Feature Expansion**: New feature development
**Performance Scaling**: Optimize for scale

#### Scalability Strategy
```dart
// Scalability Configuration
class ScalabilityConfig {
  static const int maxConcurrentUsers = 1000000;
  static const int maxDataPerUser = 1000; // habits
  static const Duration syncInterval = Duration(minutes: 5);
  static const int maxRetries = 3;
}
```

---

## 📝 Conclusion

This comprehensive tech stack document provides the complete technology foundation for ZenScreen mobile app development. The stack prioritizes:

- **Simplicity**: Easy to understand and implement
- **Cost-Effectiveness**: Free tier sufficient for MVP
- **Beginner-Friendly**: Suitable for first-time app developers
- **Scalability**: Ready for growth and expansion
- **Cross-Platform**: Android-first with iOS readiness

The technology choices ensure a robust, performant, and maintainable mobile application that can scale from MVP to enterprise-level usage.

---

**Last Updated**: September 11, 2025
**Version**: 1.0.0
**Next Review**: October 2025

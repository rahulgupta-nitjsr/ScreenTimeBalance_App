# ZenScreen Architecture & Data Flow Documentation

## 🏗️ **SYSTEM ARCHITECTURE OVERVIEW**

ZenScreen uses a **hybrid offline-first architecture** combining Firebase (cloud) and SQLite (local) to provide seamless user experience with robust data synchronization.

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Firebase      │    │   Flutter App   │    │   SQLite        │
│   (Cloud)       │    │   (Local)       │    │   (Offline)     │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ • Auth Service  │◄──►│ • AuthService   │◄──►│ • User Data     │
│ • Firestore    │    │ • SyncService   │    │ • Habit Entries │
│ • User Profile │    │ • Repositories  │    │ • Timer Sessions│
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

---

## 🔐 **AUTHENTICATION SYSTEM**

### **Firebase Authentication (Cloud)**
- **Purpose**: User authentication and session management
- **Stores**: Email, password hashes, user IDs, authentication tokens
- **Security**: Firebase handles all password encryption and security
- **Access**: Users can only access their own authenticated data

### **Local Authentication (Flutter)**
- **AuthService**: Wraps Firebase Auth with custom error handling
- **AuthController**: Manages authentication state with Riverpod
- **AppUser Model**: Clean user representation for the app
- **Session Management**: Automatic login persistence

---

## 💾 **DATA STORAGE ARCHITECTURE**

### **SQLite (Primary Storage - Offline-First)**
**Purpose**: Primary data storage for offline-first functionality
**Tables**:
```sql
-- User Profile
user_profiles (id, email, display_name, avatar_url, created_at, updated_at)

-- Daily Habit Entries  
daily_habit_entries (id, user_id, entry_date, minutes_sleep, minutes_exercise, 
                    minutes_outdoor, minutes_productive, earned_screen_time, 
                    used_screen_time, power_mode_unlocked, algorithm_version, 
                    created_at, updated_at, manual_adjustment_minutes)

-- Timer Sessions
timer_sessions (id, user_id, category, start_time, end_time, duration_minutes, 
               status, created_at, updated_at, synced_at, notes)

-- Audit Events
audit_events (id, user_id, event_type, target_date, category, old_value, 
             new_value, reason, created_at, metadata)
```

### **Firestore (Cloud Backup & Sync)**
**Purpose**: Cloud backup, cross-device sync, and data recovery
**Collections**:
```javascript
users/{firebase_uid}/
daily_habit_entries/{entry_id}/
timer_sessions/{session_id}/
audit_events/{event_id}/
```

---

## 🔄 **COMPLETE DATA FLOW**

### **1. User Account Creation**
```
User Input → Validation → Firebase Auth → Local SQLite → Cloud Firestore
```

**Step-by-Step Process**:
1. **User Input**: Email, password, confirm password
2. **Client Validation**: Password match, email format
3. **Firebase Auth**: `createUserWithEmailAndPassword()`
4. **Firebase Response**: Returns authenticated user with UID
5. **Local Storage**: Create UserProfile in SQLite
6. **Cloud Sync**: Upload to Firestore (background)

### **2. User Sign-In**
```
User Input → Firebase Auth → Load Local Data → Background Sync
```

**Step-by-Step Process**:
1. **User Input**: Email, password
2. **Firebase Auth**: `signInWithEmailAndPassword()`
3. **Firebase Response**: Returns authenticated user
4. **Local Data Load**: Load user's data from SQLite
5. **Background Sync**: Sync local ↔ cloud data

### **3. Data Entry (Offline-First)**
```
User Action → SQLite Storage → Background Sync → Firestore
```

**Example: User Logs 8 Hours of Sleep**
1. **User Action**: Taps sleep timer, logs 8 hours
2. **Immediate Storage**: Data saved to SQLite instantly
3. **App Continues**: Full functionality without internet
4. **Background Sync**: Data uploaded to Firestore (within 5 minutes)
5. **Conflict Resolution**: If conflicts exist, last-write-wins

---

## 🔄 **SYNC MECHANICS**

### **Automatic Sync Triggers**
- **Every 5 minutes**: Background sync when online
- **Network restoration**: Sync when back online
- **App startup**: Sync if authenticated
- **Data changes**: After major operations

### **Manual Sync Triggers**
- **User-initiated**: Sync button in profile screen
- **Force sync**: Manual trigger for immediate sync

### **Sync Process**
```dart
Future<SyncResult> syncAll() async {
  // 1. Check connectivity
  if (!await isOnline) return SyncResult.offline;
  
  // 2. Sync user profile
  await _syncUserProfile();
  
  // 3. Sync daily habit entries
  await _syncDailyHabitEntries();
  
  // 4. Sync timer sessions
  await _syncTimerSessions();
  
  // 5. Sync audit events
  await _syncAuditEvents();
}
```

### **Conflict Resolution Strategy**
- **Last-Write-Wins**: Most recent timestamp wins
- **Automatic Resolution**: No user intervention needed
- **Data Integrity**: No data loss during conflicts

---

## 🔒 **SECURITY & PRIVACY**

### **Firebase Security Rules**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /daily_habit_entries/{entryId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
    
    match /timer_sessions/{sessionId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
    
    match /audit_events/{eventId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
  }
}
```

### **Data Privacy**
- **Firebase Auth**: Only stores email/password hash
- **Firestore**: Stores app data, but user-specific
- **SQLite**: Stores all data locally, encrypted by device
- **Sync**: Only syncs authenticated user's data

---

## 📱 **OFFLINE-FIRST BENEFITS**

### **What Works Offline**
- ✅ User can log habits
- ✅ Timer sessions work
- ✅ Data validation
- ✅ Algorithm calculations
- ✅ All app functionality
- ✅ Data persistence

### **What Requires Online**
- ❌ Account creation
- ❌ Sign in
- ❌ Password reset
- ❌ Data sync to cloud

### **Sync When Back Online**
```dart
// Automatic sync when connectivity restored
_connectivity.onConnectivityChanged.listen((result) {
  if (result != ConnectivityResult.none) {
    syncAll(); // Sync all pending changes
  }
});
```

---

## 🎯 **KEY ARCHITECTURAL PRINCIPLES**

### **1. Offline-First Design**
- **Primary Storage**: SQLite (local)
- **Backup Storage**: Firestore (cloud)
- **User Experience**: App works without internet
- **Data Safety**: Never lose user data

### **2. Data Synchronization**
- **Bidirectional**: Local ↔ Cloud
- **Automatic**: Background sync every 5 minutes
- **Manual**: User-triggered sync
- **Conflict Resolution**: Last-write-wins strategy

### **3. Security & Privacy**
- **Authentication**: Firebase Auth
- **Authorization**: User-specific data access
- **Encryption**: Firebase handles password security
- **Privacy**: Users only access their own data

### **4. Performance**
- **Instant Response**: Local SQLite queries
- **Background Sync**: Non-blocking operations
- **Efficient**: Only sync changed data
- **Reliable**: Retry mechanisms for failed syncs

---

## 📊 **DATA FLOW SUMMARY**

| **Action** | **Firebase** | **SQLite** | **Firestore** | **Sync** |
|------------|--------------|------------|---------------|----------|
| **Account Creation** | ✅ Auth | ✅ Profile | ✅ Profile | ✅ Auto |
| **Sign In** | ✅ Auth | ✅ Load Data | ✅ Sync | ✅ Auto |
| **Log Habit** | ❌ | ✅ Immediate | ✅ Background | ✅ Auto |
| **Timer Session** | ❌ | ✅ Immediate | ✅ Background | ✅ Auto |
| **Offline Use** | ❌ | ✅ All Data | ❌ | ❌ |
| **Manual Sync** | ❌ | ✅ Read | ✅ Write | ✅ Manual |

---

## 🚀 **IMPLEMENTATION STATUS**

### **Completed Features**
- ✅ Firebase Authentication integration
- ✅ SQLite offline-first storage
- ✅ Firestore cloud backup
- ✅ Automatic background sync
- ✅ Conflict resolution
- ✅ Manual sync triggers
- ✅ Security rules
- ✅ Comprehensive testing

### **Architecture Benefits**
- **Reliability**: Works offline, syncs when online
- **Performance**: Instant local responses
- **Security**: Firebase authentication + user-specific data
- **Scalability**: Cloud backup for unlimited data
- **User Experience**: Seamless offline-first functionality

---

## 📚 **TECHNICAL STACK**

### **Frontend**
- **Flutter**: Cross-platform mobile framework
- **Riverpod**: State management
- **GoRouter**: Navigation with auth protection

### **Backend**
- **Firebase Auth**: Authentication service
- **Firestore**: NoSQL cloud database
- **SQLite**: Local relational database

### **Sync & State**
- **SyncService**: Background synchronization
- **AuthService**: Authentication wrapper
- **Repositories**: Data access layer

### **Testing**
- **Unit Tests**: Business logic validation
- **Widget Tests**: UI component testing
- **Integration Tests**: End-to-end scenarios
- **Mock Testing**: Isolated component testing

---

*This architecture ensures ZenScreen provides a robust, offline-first experience while maintaining cloud backup and cross-device synchronization capabilities.*

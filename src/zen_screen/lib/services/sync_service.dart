import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../models/daily_habit_entry.dart';
import '../models/timer_session.dart';
import '../models/audit_event.dart';
import '../models/user_profile.dart';
import 'firestore_service.dart';
import 'daily_habit_repository.dart';
import 'timer_repository.dart';
import 'audit_repository.dart';
import 'user_repository.dart';

/// Service for managing data synchronization between local SQLite and Firestore
class SyncService {
  SyncService({
    FirestoreService? firestoreService,
    DailyHabitRepository? dailyHabitRepository,
    TimerRepository? timerRepository,
    AuditRepository? auditRepository,
    UserRepository? userRepository,
    Connectivity? connectivity,
    String? userId,
  }) : _firestore = firestoreService ?? FirestoreService(),
       _dailyHabitRepo = dailyHabitRepository ?? DailyHabitRepository(),
       _timerRepo = timerRepository ?? TimerRepository(),
       _auditRepo = auditRepository ?? AuditRepository(),
       _userRepo = userRepository ?? UserRepository(),
       _connectivity = connectivity ?? Connectivity(),
       _userId = userId;

  final FirestoreService _firestore;
  final DailyHabitRepository _dailyHabitRepo;
  final TimerRepository _timerRepo;
  final AuditRepository _auditRepo;
  final UserRepository _userRepo;
  final Connectivity _connectivity;
  final String? _userId;

  StreamController<SyncStatus>? _statusController;
  Timer? _syncTimer;
  bool _isSyncing = false;

  /// Stream of sync status updates
  Stream<SyncStatus> get syncStatusStream {
    _statusController ??= StreamController<SyncStatus>.broadcast();
    return _statusController!.stream;
  }

  /// Current sync status
  SyncStatus _currentStatus = SyncStatus.idle;
  SyncStatus get currentStatus => _currentStatus;

  /// Initialize sync service with automatic sync
  Future<void> initialize() async {
    // Start periodic sync every 5 minutes
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (!_isSyncing) {
        syncAll();
      }
    });

    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none && !_isSyncing) {
        syncAll();
      }
    });
  }

  /// Dispose resources
  void dispose() {
    _syncTimer?.cancel();
    _statusController?.close();
  }

  /// Update sync status and notify listeners
  void _updateStatus(SyncStatus status) {
    _currentStatus = status;
    _statusController?.add(status);
  }

  /// Check if device is online
  Future<bool> get isOnline async {
    try {
      final result = await _connectivity.checkConnectivity();
      if (result == ConnectivityResult.none) {
        return false;
      }
      
      // For web, just trust the connectivity result
      // For mobile, do additional network check
      if (kIsWeb) {
        return true;
      }
      
      // Additional check with actual network request for mobile
      final result2 = await InternetAddress.lookup('google.com');
      final isOnline = result2.isNotEmpty && result2[0].rawAddress.isNotEmpty;
      return isOnline;
    } catch (e) {
      return false;
    }
  }

  /// Sync all data types
  Future<SyncResult> syncAll() async {
    if (_isSyncing) {
      return SyncResult.alreadyInProgress;
    }
    
    _isSyncing = true;
    _updateStatus(SyncStatus.syncing);

    try {
      final online = await isOnline;
      if (!online) {
        _updateStatus(SyncStatus.offline);
        return SyncResult.offline;
      }

      final results = <String, SyncResult>{};
      
      // Sync user profile first
      results['userProfile'] = await _syncUserProfile();
      
      // Sync daily habit entries
      results['dailyHabitEntries'] = await _syncDailyHabitEntries();
      
      // Sync timer sessions
      results['timerSessions'] = await _syncTimerSessions();
      
      // Sync audit events
      results['auditEvents'] = await _syncAuditEvents();

      // Check if any sync failed
      final hasFailures = results.values.any((result) => result == SyncResult.failure);
      
      if (hasFailures) {
        _updateStatus(SyncStatus.error);
        return SyncResult.partialFailure;
      } else {
        _updateStatus(SyncStatus.completed);
        return SyncResult.success;
      }
    } catch (e) {
      _updateStatus(SyncStatus.error);
      return SyncResult.failure;
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync user profile
  Future<SyncResult> _syncUserProfile() async {
    try {
      // Get local profile
      final localProfile = await _userRepo.getUserProfile(userId: _getCurrentUserId());
      if (localProfile == null) {
        return SyncResult.success;
      }

      // Get cloud profile
      final cloudProfile = await _firestore.getUserProfile();

      if (cloudProfile == null) {
        // No cloud profile, upload local
        await _firestore.upsertUserProfile(localProfile);
        return SyncResult.success;
      }

      // Resolve conflict
      final resolvedProfile = _resolveUserProfileConflict(localProfile, cloudProfile);
      
      // Update both local and cloud with resolved data
      await _userRepo.updateUserProfile(resolvedProfile);
      await _firestore.upsertUserProfile(resolvedProfile);
      
      return SyncResult.success;
    } catch (e) {
      return SyncResult.failure;
    }
  }

  /// Sync daily habit entries
  Future<SyncResult> _syncDailyHabitEntries() async {
    try {
      // Get local entries
      final localEntries = await _dailyHabitRepo.getAllEntries(userId: _getCurrentUserId());
      for (int i = 0; i < localEntries.length; i++) {
        final entry = localEntries[i];
      }
      
      // Get cloud entries
      final cloudEntries = await _firestore.getDailyHabitEntries();
      for (int i = 0; i < cloudEntries.length; i++) {
        final entry = cloudEntries[i];
      }

      // Create maps for easier lookup
      final localMap = {for (var entry in localEntries) entry.id: entry};
      final cloudMap = {for (var entry in cloudEntries) entry.id: entry};

      // Find conflicts and new entries
      final conflicts = <String>[];
      final newLocalEntries = <DailyHabitEntry>[];
      final newCloudEntries = <DailyHabitEntry>[];

      // Check for conflicts
      for (final localEntry in localEntries) {
        final cloudEntry = cloudMap[localEntry.id];
        if (cloudEntry != null) {
          if (localEntry.updatedAt != cloudEntry.updatedAt) {
            conflicts.add(localEntry.id);
          }
        } else {
          newCloudEntries.add(localEntry);
        }
      }

      // Check for new cloud entries
      for (final cloudEntry in cloudEntries) {
        if (!localMap.containsKey(cloudEntry.id)) {
          newLocalEntries.add(cloudEntry);
        }
      }

      // Resolve conflicts
      for (final conflictId in conflicts) {
        final localEntry = localMap[conflictId]!;
        final cloudEntry = cloudMap[conflictId]!;
        final resolvedEntry = _resolveDailyHabitEntryConflict(localEntry, cloudEntry);
        
        await _dailyHabitRepo.upsertEntry(
          userId: resolvedEntry.userId,
          date: resolvedEntry.date,
          minutesByCategory: resolvedEntry.minutesByCategory,
          earnedScreenTime: resolvedEntry.earnedScreenTime,
          usedScreenTime: resolvedEntry.usedScreenTime,
          remainingScreenTime: resolvedEntry.remainingScreenTime,
          powerModeUnlocked: resolvedEntry.powerModeUnlocked,
          algorithmVersion: resolvedEntry.algorithmVersion,
          manualAdjustmentMinutes: resolvedEntry.manualAdjustmentMinutes,
        );
        await _firestore.upsertDailyHabitEntry(resolvedEntry);
      }

      // Upload new local entries to cloud
      for (final entry in newCloudEntries) {
        await _firestore.upsertDailyHabitEntry(entry);
      }

      // Download new cloud entries to local
      for (final entry in newLocalEntries) {
        await _dailyHabitRepo.upsertEntry(
          userId: entry.userId,
          date: entry.date,
          minutesByCategory: entry.minutesByCategory,
          earnedScreenTime: entry.earnedScreenTime,
          usedScreenTime: entry.usedScreenTime,
          remainingScreenTime: entry.remainingScreenTime,
          powerModeUnlocked: entry.powerModeUnlocked,
          algorithmVersion: entry.algorithmVersion,
          manualAdjustmentMinutes: entry.manualAdjustmentMinutes,
        );
      }

      return SyncResult.success;
    } catch (e) {
      return SyncResult.failure;
    }
  }

  /// Sync timer sessions
  Future<SyncResult> _syncTimerSessions() async {
    try {
      // Get local sessions
      final localSessions = await _timerRepo.getAllSessions(userId: _getCurrentUserId());
      
      // Get cloud sessions
      final cloudSessions = await _firestore.getTimerSessions();

      // Create maps for easier lookup
      final localMap = {for (var session in localSessions) session.id: session};
      final cloudMap = {for (var session in cloudSessions) session.id: session};

      // Find conflicts and new entries
      final conflicts = <String>[];
      final newLocalSessions = <TimerSession>[];
      final newCloudSessions = <TimerSession>[];

      // Check for conflicts
      for (final localSession in localSessions) {
        final cloudSession = cloudMap[localSession.id];
        if (cloudSession != null) {
          if (localSession.updatedAt != cloudSession.updatedAt) {
            conflicts.add(localSession.id);
          }
        } else {
          newCloudSessions.add(localSession);
        }
      }

      // Check for new cloud sessions
      for (final cloudSession in cloudSessions) {
        if (!localMap.containsKey(cloudSession.id)) {
          newLocalSessions.add(cloudSession);
        }
      }

      // Resolve conflicts
      for (final conflictId in conflicts) {
        final localSession = localMap[conflictId]!;
        final cloudSession = cloudMap[conflictId]!;
        final resolvedSession = _resolveTimerSessionConflict(localSession, cloudSession);
        
        await _timerRepo.upsertSession(resolvedSession);
        await _firestore.upsertTimerSession(resolvedSession);
      }

      // Upload new local sessions to cloud
      for (final session in newCloudSessions) {
        await _firestore.upsertTimerSession(session);
      }

      // Download new cloud sessions to local
      for (final session in newLocalSessions) {
        await _timerRepo.upsertSession(session);
      }

      return SyncResult.success;
    } catch (e) {
      if (e.toString().contains('index')) {
        return SyncResult.failure; // Still return failure but with context
      }
      return SyncResult.failure;
    }
  }

  /// Sync audit events
  Future<SyncResult> _syncAuditEvents() async {
    try {
      // Get local events
      final localEvents = await _auditRepo.getAllEvents(userId: _getCurrentUserId());
      
      // Get cloud events
      final cloudEvents = await _firestore.getAuditEvents();

      // Create maps for easier lookup
      final localMap = {for (var event in localEvents) event.id: event};
      final cloudMap = {for (var event in cloudEvents) event.id: event};

      // Find new entries
      final newLocalEvents = <AuditEvent>[];
      final newCloudEvents = <AuditEvent>[];

      // Check for new local events
      for (final localEvent in localEvents) {
        if (!cloudMap.containsKey(localEvent.id)) {
          newCloudEvents.add(localEvent);
        }
      }

      // Check for new cloud events
      for (final cloudEvent in cloudEvents) {
        if (!localMap.containsKey(cloudEvent.id)) {
          newLocalEvents.add(cloudEvent);
        }
      }

      // Upload new local events to cloud
      for (final event in newCloudEvents) {
        await _firestore.createAuditEvent(event);
      }

      // Download new cloud events to local
      for (final event in newLocalEvents) {
        await _auditRepo.createEvent(event);
      }

      return SyncResult.success;
    } catch (e) {
      return SyncResult.failure;
    }
  }

  // ==================== CONFLICT RESOLUTION ====================

  /// Resolve user profile conflict using last-write-wins strategy
  UserProfile _resolveUserProfileConflict(UserProfile local, UserProfile cloud) {
    // Use the profile with the most recent update
    if (local.updatedAt.isAfter(cloud.updatedAt)) {
      return local;
    } else {
      return cloud;
    }
  }

  /// Resolve daily habit entry conflict using last-write-wins strategy
  DailyHabitEntry _resolveDailyHabitEntryConflict(DailyHabitEntry local, DailyHabitEntry cloud) {
    // Use the entry with the most recent update
    if (local.updatedAt.isAfter(cloud.updatedAt)) {
      return local;
    } else {
      return cloud;
    }
  }

  /// Resolve timer session conflict using last-write-wins strategy
  TimerSession _resolveTimerSessionConflict(TimerSession local, TimerSession cloud) {
    // Use the session with the most recent update
    final localUpdate = local.updatedAt ?? local.createdAt;
    final cloudUpdate = cloud.updatedAt ?? cloud.createdAt;
    
    if (localUpdate.isAfter(cloudUpdate)) {
      return local;
    } else {
      return cloud;
    }
  }

  /// Manual sync trigger
  Future<SyncResult> manualSync() async {
    return await syncAll();
  }

  /// Get current authenticated user ID
  String _getCurrentUserId() {
    if (_userId == null) {
      throw StateError('User ID not provided to SyncService');
    }
    return _userId!;
  }

  /// Get sync statistics
  Future<SyncStats> getSyncStats() async {
    try {
      final localEntries = await _dailyHabitRepo.getAllEntries(userId: _getCurrentUserId());
      final localSessions = await _timerRepo.getAllSessions(userId: _getCurrentUserId());
      final localEvents = await _auditRepo.getAllEvents(userId: _getCurrentUserId());
      
      final cloudEntries = await _firestore.getDailyHabitEntries();
      final cloudSessions = await _firestore.getTimerSessions();
      final cloudEvents = await _firestore.getAuditEvents();

      return SyncStats(
        localEntriesCount: localEntries.length,
        localSessionsCount: localSessions.length,
        localEventsCount: localEvents.length,
        cloudEntriesCount: cloudEntries.length,
        cloudSessionsCount: cloudSessions.length,
        cloudEventsCount: cloudEvents.length,
        lastSyncTime: DateTime.now(), // TODO: Store actual last sync time
        isOnline: await isOnline,
      );
    } catch (e) {
      return SyncStats(
        localEntriesCount: 0,
        localSessionsCount: 0,
        localEventsCount: 0,
        cloudEntriesCount: 0,
        cloudSessionsCount: 0,
        cloudEventsCount: 0,
        lastSyncTime: null,
        isOnline: false,
      );
    }
  }
}

/// Sync status enumeration
enum SyncStatus {
  idle,
  syncing,
  completed,
  error,
  offline,
}

/// Sync result enumeration
enum SyncResult {
  success,
  failure,
  partialFailure,
  offline,
  alreadyInProgress,
}

/// Sync statistics
class SyncStats {
  const SyncStats({
    required this.localEntriesCount,
    required this.localSessionsCount,
    required this.localEventsCount,
    required this.cloudEntriesCount,
    required this.cloudSessionsCount,
    required this.cloudEventsCount,
    required this.lastSyncTime,
    required this.isOnline,
  });

  final int localEntriesCount;
  final int localSessionsCount;
  final int localEventsCount;
  final int cloudEntriesCount;
  final int cloudSessionsCount;
  final int cloudEventsCount;
  final DateTime? lastSyncTime;
  final bool isOnline;
}


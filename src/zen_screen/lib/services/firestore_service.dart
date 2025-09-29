import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/daily_habit_entry.dart';
import '../models/timer_session.dart';
import '../models/audit_event.dart';
import '../models/user_profile.dart';

/// Service for managing Firestore operations with offline-first architecture
class FirestoreService {
  FirestoreService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // Collection names
  static const String _usersCollection = 'users';
  static const String _dailyHabitEntriesCollection = 'daily_habit_entries';
  static const String _timerSessionsCollection = 'timer_sessions';
  static const String _auditEventsCollection = 'audit_events';

  /// Get current user ID, throws if not authenticated
  String get _currentUserId {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirestoreException('User not authenticated');
    }
    return user.uid;
  }

  /// Get user document reference
  DocumentReference<Map<String, dynamic>> get _userDoc =>
      _firestore.collection(_usersCollection).doc(_currentUserId);

  /// Get daily habit entries collection reference
  CollectionReference<Map<String, dynamic>> get _dailyHabitEntriesCol =>
      _firestore.collection(_dailyHabitEntriesCollection);

  /// Get timer sessions collection reference
  CollectionReference<Map<String, dynamic>> get _timerSessionsCol =>
      _firestore.collection(_timerSessionsCollection);

  /// Get audit events collection reference
  CollectionReference<Map<String, dynamic>> get _auditEventsCol =>
      _firestore.collection(_auditEventsCollection);

  // ==================== USER PROFILE OPERATIONS ====================

  /// Create or update user profile in Firestore
  Future<void> upsertUserProfile(UserProfile profile) async {
    try {
      await _userDoc.set(profile.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw FirestoreException('Failed to upsert user profile: $e');
    }
  }

  /// Get user profile from Firestore
  Future<UserProfile?> getUserProfile() async {
    try {
      final doc = await _userDoc.get();
      if (!doc.exists) return null;
      return UserProfile.fromFirestore(doc.data()!);
    } catch (e) {
      throw FirestoreException('Failed to get user profile: $e');
    }
  }

  // ==================== DAILY HABIT ENTRIES OPERATIONS ====================

  /// Create or update daily habit entry in Firestore
  Future<void> upsertDailyHabitEntry(DailyHabitEntry entry) async {
    try {
      await _dailyHabitEntriesCol
          .doc(entry.id)
          .set(entry.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw FirestoreException('Failed to upsert daily habit entry: $e');
    }
  }

  /// Get daily habit entry by ID
  Future<DailyHabitEntry?> getDailyHabitEntry(String id) async {
    try {
      final doc = await _dailyHabitEntriesCol.doc(id).get();
      if (!doc.exists) return null;
      return DailyHabitEntry.fromFirestore(doc.data()!);
    } catch (e) {
      throw FirestoreException('Failed to get daily habit entry: $e');
    }
  }

  /// Get all daily habit entries for user
  Future<List<DailyHabitEntry>> getDailyHabitEntries({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _dailyHabitEntriesCol
          .where('userId', isEqualTo: _currentUserId);

      if (startDate != null) {
        query = query.where('date', isGreaterThanOrEqualTo: startDate);
      }
      if (endDate != null) {
        query = query.where('date', isLessThanOrEqualTo: endDate);
      }
      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.orderBy('date', descending: true).get();
      return snapshot.docs
          .map((doc) => DailyHabitEntry.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      throw FirestoreException('Failed to get daily habit entries: $e');
    }
  }

  /// Delete daily habit entry
  Future<void> deleteDailyHabitEntry(String id) async {
    try {
      await _dailyHabitEntriesCol.doc(id).delete();
    } catch (e) {
      throw FirestoreException('Failed to delete daily habit entry: $e');
    }
  }

  // ==================== TIMER SESSIONS OPERATIONS ====================

  /// Create or update timer session in Firestore
  Future<void> upsertTimerSession(TimerSession session) async {
    try {
      await _timerSessionsCol
          .doc(session.id)
          .set(session.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw FirestoreException('Failed to upsert timer session: $e');
    }
  }

  /// Get timer sessions for user
  Future<List<TimerSession>> getTimerSessions({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _timerSessionsCol
          .where('userId', isEqualTo: _currentUserId);

      if (startDate != null) {
        query = query.where('date', isGreaterThanOrEqualTo: startDate);
      }
      if (endDate != null) {
        query = query.where('date', isLessThanOrEqualTo: endDate);
      }
      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.orderBy('date', descending: true).get();
      return snapshot.docs
          .map((doc) => TimerSession.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      throw FirestoreException('Failed to get timer sessions: $e');
    }
  }

  // ==================== AUDIT EVENTS OPERATIONS ====================

  /// Create audit event in Firestore
  Future<void> createAuditEvent(AuditEvent event) async {
    try {
      await _auditEventsCol.doc(event.id).set(event.toFirestore());
    } catch (e) {
      throw FirestoreException('Failed to create audit event: $e');
    }
  }

  /// Get audit events for user
  Future<List<AuditEvent>> getAuditEvents({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _auditEventsCol
          .where('userId', isEqualTo: _currentUserId);

      if (startDate != null) {
        query = query.where('createdAt', isGreaterThanOrEqualTo: startDate);
      }
      if (endDate != null) {
        query = query.where('createdAt', isLessThanOrEqualTo: endDate);
      }
      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.orderBy('createdAt', descending: true).get();
      return snapshot.docs
          .map((doc) => AuditEvent.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      throw FirestoreException('Failed to get audit events: $e');
    }
  }

  // ==================== BATCH OPERATIONS ====================

  /// Perform batch write operations
  Future<void> batchWrite(List<FirestoreOperation> operations) async {
    try {
      final batch = _firestore.batch();
      
      for (final operation in operations) {
        switch (operation.type) {
          case FirestoreOperationType.set:
            batch.set(operation.reference, operation.data!);
            break;
          case FirestoreOperationType.update:
            batch.update(operation.reference, operation.data!);
            break;
          case FirestoreOperationType.delete:
            batch.delete(operation.reference);
            break;
        }
      }
      
      await batch.commit();
    } catch (e) {
      throw FirestoreException('Failed to perform batch write: $e');
    }
  }

  // ==================== SYNC STATUS OPERATIONS ====================

  /// Get sync status for a document
  Future<SyncStatus> getSyncStatus(String collection, String documentId) async {
    try {
      final doc = await _firestore.collection(collection).doc(documentId).get();
      if (!doc.exists) return SyncStatus.notFound;
      
      final data = doc.data()!;
      final lastModified = data['lastModified'] as Timestamp?;
      final syncedAt = data['syncedAt'] as Timestamp?;
      
      if (syncedAt == null) return SyncStatus.pending;
      if (lastModified == null) return SyncStatus.synced;
      
      return lastModified.millisecondsSinceEpoch > syncedAt.millisecondsSinceEpoch
          ? SyncStatus.pending
          : SyncStatus.synced;
    } catch (e) {
      return SyncStatus.error;
    }
  }

  /// Mark document as synced
  Future<void> markAsSynced(String collection, String documentId) async {
    try {
      await _firestore.collection(collection).doc(documentId).update({
        'syncedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw FirestoreException('Failed to mark document as synced: $e');
    }
  }
}

/// Firestore operation for batch writes
class FirestoreOperation {
  const FirestoreOperation({
    required this.type,
    required this.reference,
    this.data,
  });

  final FirestoreOperationType type;
  final DocumentReference<Map<String, dynamic>> reference;
  final Map<String, dynamic>? data;
}

enum FirestoreOperationType { set, update, delete }

/// Sync status for documents
enum SyncStatus { synced, pending, error, notFound }

/// Custom exception for Firestore operations
class FirestoreException implements Exception {
  const FirestoreException(this.message);
  final String message;

  @override
  String toString() => 'FirestoreException: $message';
}

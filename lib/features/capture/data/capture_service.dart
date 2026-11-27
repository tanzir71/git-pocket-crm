import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/crm_queries.dart';
import '../../../core/files/file_store.dart';
import '../../../core/native/device_api.g.dart';

/// Entry types selectable in the Add sheet.
enum AddEntryType {
  note,
  call,
  visit,
  task,
  payment,
  file,
}

/// Reason a person was suggested when opening the Add sheet with no person fixed.
enum PersonSuggestionReason {
  lastCall,
  upcomingFollowUp,
}

class SuggestedPerson {
  const SuggestedPerson({
    required this.contact,
    required this.reason,
    this.followUpDueMs,
  });

  final Contact contact;
  final PersonSuggestionReason reason;
  final int? followUpDueMs;
}

/// Optional follow-up attached to a new entry or after-call note.
class FollowUpDraft {
  const FollowUpDraft({
    required this.title,
    required this.dueDateMs,
    this.note,
  });

  final String title;
  final int dueDateMs;
  final String? note;
}

/// Reverses a saved Add or After-call transaction completely.
class CaptureUndoToken {
  const CaptureUndoToken({
    required this.contactId,
    required this.previousLastInteractionAt,
    this.insertedTimelineId,
    this.insertedTaskId,
    this.previousTimelineRow,
  });

  final int contactId;
  final int? previousLastInteractionAt;
  final int? insertedTimelineId;
  final int? insertedTaskId;
  final TimelineEntry? previousTimelineRow;
}

/// Abstraction over media/file/location pickers so tests can inject deterministic fakes.
abstract class CapturePlatformAdapter {
  Future<String?> pickImage({required bool fromCamera});
  Future<String?> pickFile();
  Future<LocationPoint?> currentLocation();
  Future<void> setAfterCallMode(String mode);
}

class DefaultCapturePlatformAdapter implements CapturePlatformAdapter {
  DefaultCapturePlatformAdapter({
    Future<String?> Function(bool fromCamera)? imagePicker,
    Future<String?> Function()? filePicker,
    DeviceApi? deviceApi,
  })  : imagePickerCallback = imagePicker,
        filePickerCallback = filePicker,
        deviceApiInstance = deviceApi;

  final Future<String?> Function(bool fromCamera)? imagePickerCallback;
  final Future<String?> Function()? filePickerCallback;
  final DeviceApi? deviceApiInstance;

  @override
  Future<String?> pickImage({required bool fromCamera}) async {
    if (imagePickerCallback != null) return imagePickerCallback!(fromCamera);
    return null;
  }

  @override
  Future<String?> pickFile() async {
    if (filePickerCallback != null) return filePickerCallback!();
    return null;
  }

  @override
  Future<LocationPoint?> currentLocation() async {
    try {
      return await (deviceApiInstance ?? DeviceApi()).currentLocation();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> setAfterCallMode(String mode) async {
    try {
      await (deviceApiInstance ?? DeviceApi()).setAfterCallMode(mode);
    } catch (_) {
      // Ignore on non-Android platforms/tests
    }
  }
}

/// Handles transactional saving, editing, after-call review, full Undo, and
/// smart person suggestions for Spec 07.
class CaptureService {
  CaptureService({
    required AppDatabase db,
    required this.fileStore,
    DateTime Function()? clock,
  })  : _db = db,
        _queries = CrmQueries(db),
        _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final CrmQueries _queries;
  final FileStore fileStore;
  final DateTime Function() _clock;

  /// Suggests a person when Add sheet is opened without one:
  /// 1. Most recent unreviewed call in the last 12 hours (`lastCall`)
  /// 2. Next open follow-up due within 2 hours (`upcomingFollowUp`)
  /// 3. Otherwise `null`
  Future<SuggestedPerson?> suggestPerson() async {
    final now = _clock();
    final nowMs = now.millisecondsSinceEpoch;
    final twelveHoursAgo = nowMs - const Duration(hours: 12).inMilliseconds;

    final unreviewedCalls = await (_db.select(_db.timelineEntries)
          ..where(
            (t) =>
                t.type.isIn(const ['call_incoming', 'call_outgoing', 'call_missed']) &
                t.timestamp.isBiggerOrEqualValue(twelveHoursAgo) &
                t.reviewedAt.isNull() &
                t.note.isNull() &
                t.hidden.equals(0) &
                t.contactId.isNotNull(),
          )
          ..orderBy([(t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc)])
          ..limit(1))
        .get();

    if (unreviewedCalls.isNotEmpty) {
      final cid = unreviewedCalls.first.contactId!;
      final contact = await (_db.select(_db.contacts)..where((t) => t.id.equals(cid)))
          .getSingleOrNull();
      if (contact != null) {
        return SuggestedPerson(
          contact: contact,
          reason: PersonSuggestionReason.lastCall,
        );
      }
    }

    final twoHoursAhead = nowMs + const Duration(hours: 2).inMilliseconds;
    final soonTasks = await (_db.select(_db.tasks)
          ..where(
            (t) =>
                t.isCompleted.equals(0) &
                t.contactId.isNotNull() &
                t.dueDate.isBiggerOrEqualValue(nowMs - const Duration(hours: 1).inMilliseconds) &
                t.dueDate.isSmallerOrEqualValue(twoHoursAhead),
          )
          ..orderBy([(t) => OrderingTerm(expression: t.dueDate)])
          ..limit(1))
        .get();

    if (soonTasks.isNotEmpty) {
      final task = soonTasks.first;
      final contact = await (_db.select(_db.contacts)..where((t) => t.id.equals(task.contactId!)))
          .getSingleOrNull();
      if (contact != null) {
        return SuggestedPerson(
          contact: contact,
          reason: PersonSuggestionReason.upcomingFollowUp,
          followUpDueMs: task.dueDate,
        );
      }
    }

    return null;
  }

  /// Saves any new Add-sheet entry (Note, Call, Visit, Task, Payment, File) +
  /// attachments + optional follow-up + `last_interaction_at` in ONE transaction.
  Future<CaptureUndoToken> saveNew({
    required int contactId,
    required AddEntryType type,
    required int timestampMs,
    String? note,
    // Call
    String? callDirectionType, // 'call_outgoing' | 'call_incoming'
    int? durationSeconds,
    String? outcome, // 'spoke' | 'no_answer' | 'left_message'
    // Visit
    String? placeName,
    double? lat,
    double? lng,
    List<String> photoSourcePaths = const [],
    // Task
    String? taskTitle,
    int? taskDueDateMs,
    // Payment
    double? amount,
    String? currencyCode,
    String? paymentStatus, // 'received' | 'paid' | 'owed_to_me' | 'i_owe'
    // File
    String? fileSourcePath,
    // Optional attached follow-up (for all types except Task)
    FollowUpDraft? followUp,
  }) async {
    final nowMs = _clock().millisecondsSinceEpoch;

    // Copy any external attachments into private app storage before the DB txn
    final storedPhotos = <String>[];
    for (final path in photoSourcePaths) {
      storedPhotos.add(await fileStore.copyIntoStorage(path, now: _clock()));
    }
    String? storedFile;
    if (fileSourcePath != null && fileSourcePath.isNotEmpty) {
      storedFile = await fileStore.copyIntoStorage(fileSourcePath, now: _clock());
    }

    final existingContact = await (_db.select(_db.contacts)..where((t) => t.id.equals(contactId)))
        .getSingleOrNull();
    final prevLastInteraction = existingContact?.lastInteractionAt;

    int? insertedTimelineId;
    int? insertedTaskId;

    await _db.transaction(() async {
      if (type == AddEntryType.task) {
        insertedTaskId = await _db.into(_db.tasks).insert(
              TasksCompanion.insert(
                contactId: Value(contactId),
                title: (taskTitle ?? '').trim(),
                dueDate: taskDueDateMs ?? timestampMs,
                reminderTime: Value(taskDueDateMs ?? timestampMs),
                note: Value(_nullIfEmpty(note)),
                createdAt: Value(nowMs),
              ),
            );
        return;
      }

      switch (type) {
        case AddEntryType.note:
          insertedTimelineId = await _db.into(_db.timelineEntries).insert(
                TimelineEntriesCompanion.insert(
                  contactId: Value(contactId),
                  type: 'note',
                  timestamp: timestampMs,
                  content: Value(_nullIfEmpty(note) ?? ''),
                  note: Value(_nullIfEmpty(note)),
                  source: const Value('manual'),
                ),
              );

        case AddEntryType.call:
          final effectiveDuration = (durationSeconds != null && durationSeconds > 0)
              ? durationSeconds
              : (outcome == 'spoke' ? 60 : 0);
          insertedTimelineId = await _db.into(_db.timelineEntries).insert(
                TimelineEntriesCompanion.insert(
                  contactId: Value(contactId),
                  type: callDirectionType ?? 'call_outgoing',
                  timestamp: timestampMs,
                  content: Value(_nullIfEmpty(note) ?? ''),
                  note: Value(_nullIfEmpty(note)),
                  outcome: Value(outcome),
                  durationSeconds: Value(effectiveDuration),
                  reviewedAt: Value(nowMs),
                  source: const Value('manual'),
                ),
              );

        case AddEntryType.visit:
          insertedTimelineId = await _db.into(_db.timelineEntries).insert(
                TimelineEntriesCompanion.insert(
                  contactId: Value(contactId),
                  type: 'visit',
                  timestamp: timestampMs,
                  content: Value(_nullIfEmpty(note) ?? _nullIfEmpty(placeName) ?? ''),
                  note: Value(_nullIfEmpty(note)),
                  placeName: Value(_nullIfEmpty(placeName)),
                  lat: Value(lat),
                  lng: Value(lng),
                  source: const Value('manual'),
                ),
              );
          for (final p in storedPhotos) {
            await _db.into(_db.timelineAttachments).insert(
                  TimelineAttachmentsCompanion.insert(
                    timelineId: insertedTimelineId!,
                    path: p,
                    createdAt: Value(nowMs),
                  ),
                );
          }

        case AddEntryType.payment:
          // Spec 07 step 2: New payment rows store amount, currency, payment_status;
          // no v1 prefix written into content.
          insertedTimelineId = await _db.into(_db.timelineEntries).insert(
                TimelineEntriesCompanion.insert(
                  contactId: Value(contactId),
                  type: 'payment',
                  timestamp: timestampMs,
                  amount: Value(amount),
                  currency: Value(currencyCode),
                  paymentStatus: Value(paymentStatus),
                  note: Value(_nullIfEmpty(note)),
                  content: Value(_nullIfEmpty(note) ?? ''),
                  source: const Value('manual'),
                ),
              );

        case AddEntryType.file:
          insertedTimelineId = await _db.into(_db.timelineEntries).insert(
                TimelineEntriesCompanion.insert(
                  contactId: Value(contactId),
                  type: 'attachment',
                  timestamp: timestampMs,
                  content: Value(_nullIfEmpty(note) ?? ''),
                  note: Value(_nullIfEmpty(note)),
                  attachmentPath: Value(storedFile),
                  source: const Value('manual'),
                ),
              );
          if (storedFile != null) {
            await _db.into(_db.timelineAttachments).insert(
                  TimelineAttachmentsCompanion.insert(
                    timelineId: insertedTimelineId!,
                    path: storedFile,
                    createdAt: Value(nowMs),
                  ),
                );
          }

        case AddEntryType.task:
          break;
      }

      // Optional follow-up linked to source_timeline_id
      if (followUp != null && followUp.title.trim().isNotEmpty) {
        insertedTaskId = await _db.into(_db.tasks).insert(
              TasksCompanion.insert(
                contactId: Value(contactId),
                title: followUp.title.trim(),
                dueDate: followUp.dueDateMs,
                reminderTime: Value(followUp.dueDateMs),
                note: Value(_nullIfEmpty(followUp.note)),
                createdAt: Value(nowMs),
                sourceTimelineId: Value(insertedTimelineId),
              ),
            );
      }

      // Update last_interaction_at when type counts as contact:
      // Visit always; Call when outcome == 'spoke'
      final countsAsContact = type == AddEntryType.visit ||
          (type == AddEntryType.call && outcome == 'spoke');
      if (countsAsContact) {
        final nextLast = (prevLastInteraction == null || timestampMs > prevLastInteraction)
            ? timestampMs
            : prevLastInteraction;
        await (_db.update(_db.contacts)..where((t) => t.id.equals(contactId))).write(
          ContactsCompanion(lastInteractionAt: Value(nextLast)),
        );
      }
    });

    await _db.rebuildFtsForContact(contactId);

    return CaptureUndoToken(
      contactId: contactId,
      previousLastInteractionAt: prevLastInteraction,
      insertedTimelineId: insertedTimelineId,
      insertedTaskId: insertedTaskId,
    );
  }

  /// Edits an existing timeline row in place (used by After-call sheet and Add
  /// sheet in edit mode) plus an optional attached follow-up in one transaction.
  Future<CaptureUndoToken> saveEdit({
    required TimelineEntry existing,
    String? note,
    String? outcome,
    String? placeName,
    double? lat,
    double? lng,
    double? amount,
    String? currencyCode,
    String? paymentStatus,
    int? timestampMs,
    bool markReviewed = false,
    List<String> addedPhotoSourcePaths = const [],
    FollowUpDraft? followUp,
  }) async {
    final nowMs = _clock().millisecondsSinceEpoch;
    final contactId = existing.contactId ?? 0;

    final storedPhotos = <String>[];
    for (final path in addedPhotoSourcePaths) {
      storedPhotos.add(await fileStore.copyIntoStorage(path, now: _clock()));
    }

    final existingContact = contactId > 0
        ? await (_db.select(_db.contacts)..where((t) => t.id.equals(contactId))).getSingleOrNull()
        : null;
    final prevLastInteraction = existingContact?.lastInteractionAt;

    int? insertedTaskId;

    await _db.transaction(() async {
      final isCallOrSms =
          existing.type.startsWith('call_') || existing.type.startsWith('sms_');

      await (_db.update(_db.timelineEntries)..where((t) => t.id.equals(existing.id))).write(
        TimelineEntriesCompanion(
          note: Value(_nullIfEmpty(note)),
          content: isCallOrSms
              ? const Value.absent()
              : Value(_nullIfEmpty(note) ?? _nullIfEmpty(placeName) ?? existing.content ?? ''),
          outcome: outcome != null ? Value(outcome) : const Value.absent(),
          placeName: !isCallOrSms && placeName != null
              ? Value(_nullIfEmpty(placeName))
              : const Value.absent(),
          lat: !isCallOrSms && lat != null ? Value(lat) : const Value.absent(),
          lng: !isCallOrSms && lng != null ? Value(lng) : const Value.absent(),
          amount: !isCallOrSms && amount != null ? Value(amount) : const Value.absent(),
          currency:
              !isCallOrSms && currencyCode != null ? Value(currencyCode) : const Value.absent(),
          paymentStatus: !isCallOrSms && paymentStatus != null
              ? Value(paymentStatus)
              : const Value.absent(),
          timestamp:
              !isCallOrSms && timestampMs != null ? Value(timestampMs) : const Value.absent(),
          reviewedAt: markReviewed ? Value(nowMs) : const Value.absent(),
          editedAt: Value(nowMs),
        ),
      );

      for (final p in storedPhotos) {
        await _db.into(_db.timelineAttachments).insert(
              TimelineAttachmentsCompanion.insert(
                timelineId: existing.id,
                path: p,
                createdAt: Value(nowMs),
              ),
            );
      }

      if (followUp != null && followUp.title.trim().isNotEmpty && contactId > 0) {
        insertedTaskId = await _db.into(_db.tasks).insert(
              TasksCompanion.insert(
                contactId: Value(contactId),
                title: followUp.title.trim(),
                dueDate: followUp.dueDateMs,
                reminderTime: Value(followUp.dueDateMs),
                note: Value(_nullIfEmpty(followUp.note)),
                createdAt: Value(nowMs),
                sourceTimelineId: Value(existing.id),
              ),
            );
      }
    });

    if (contactId > 0) {
      await _queries.recomputeLastInteraction(contactId);
      await _db.rebuildFtsForContact(contactId);
    }

    return CaptureUndoToken(
      contactId: contactId,
      previousLastInteractionAt: prevLastInteraction,
      insertedTaskId: insertedTaskId,
      previousTimelineRow: existing,
    );
  }

  /// Reverses the entire transaction captured by [token] so the database
  /// matches its exact prior state across all tables.
  Future<void> undo(CaptureUndoToken token) async {
    await _db.transaction(() async {
      if (token.insertedTaskId != null) {
        await (_db.delete(_db.tasks)..where((t) => t.id.equals(token.insertedTaskId!))).go();
      }
      if (token.insertedTimelineId != null) {
        // Cascading delete removes any timeline_attachments rows automatically
        await (_db.delete(_db.timelineEntries)
              ..where((t) => t.id.equals(token.insertedTimelineId!)))
            .go();
      }
      if (token.previousTimelineRow != null) {
        final prev = token.previousTimelineRow!;
        await (_db.update(_db.timelineEntries)..where((t) => t.id.equals(prev.id))).write(
          TimelineEntriesCompanion(
            timestamp: Value(prev.timestamp),
            content: Value(prev.content),
            amount: Value(prev.amount),
            note: Value(prev.note),
            outcome: Value(prev.outcome),
            placeName: Value(prev.placeName),
            lat: Value(prev.lat),
            lng: Value(prev.lng),
            currency: Value(prev.currency),
            paymentStatus: Value(prev.paymentStatus),
            reviewedAt: Value(prev.reviewedAt),
            editedAt: Value(prev.editedAt),
          ),
        );
      }
      if (token.contactId > 0) {
        await (_db.update(_db.contacts)..where((t) => t.id.equals(token.contactId))).write(
          ContactsCompanion(lastInteractionAt: Value(token.previousLastInteractionAt)),
        );
      }
    });

    if (token.contactId > 0) {
      await _db.rebuildFtsForContact(token.contactId);
    }
  }

  String? _nullIfEmpty(String? v) {
    final t = v?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }
}

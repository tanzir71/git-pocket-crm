import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import 'package:permission_handler/permission_handler.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/crm_queries.dart';
import '../../../core/native/device_api.g.dart';
import '../../../core/phone/phone_service.dart';
import '../../settings/data/settings_repository.dart';
import 'amount_parser.dart';
import 'sync_state_repository.dart';

class DevicePhoneInput {
  const DevicePhoneInput({
    required this.raw,
    this.label,
    this.isPrimary = false,
  });

  final String raw;
  final String? label;
  final bool isPrimary;
}

class DeviceContactInput {
  const DeviceContactInput({
    required this.deviceId,
    required this.displayName,
    required this.phones,
    this.company,
    this.role,
    this.email,
    this.birthday,
  });

  final String deviceId;
  final String displayName;
  final List<DevicePhoneInput> phones;
  final String? company;
  final String? role;
  final String? email;
  final String? birthday;
}

abstract class DeviceDataSource {
  Future<List<DeviceContactInput>> readContacts();
  Future<List<CallRecord>> readCalls(int afterId, int limit);
  Future<List<SmsRecord>> readSms(int afterId, int limit);
  Future<String?> simCountryIso();
  Future<void> startObserving();
  Future<void> stopObserving();
}

class PlatformDeviceDataSource implements DeviceDataSource {
  PlatformDeviceDataSource({DeviceApi? api}) : _api = api ?? DeviceApi();

  final DeviceApi _api;

  @override
  Future<List<DeviceContactInput>> readContacts() async {
    if (!Platform.isAndroid) return const [];
    final granted = await Permission.contacts.isGranted;
    if (!granted) return const [];

    final contacts = await fc.FlutterContacts.getAll(
      properties: fc.ContactProperties.allProperties,
    );
    final result = <DeviceContactInput>[];
    for (final c in contacts) {
      if (c.phones.isEmpty) continue;
      final id = c.id ?? '';
      final name = (c.displayName ?? '').trim().isNotEmpty
          ? c.displayName!.trim()
          : c.phones.first.number;
      final org = c.organizations.isNotEmpty ? c.organizations.first : null;
      final email = c.emails.isNotEmpty ? c.emails.first.address : null;

      String? birthday;
      for (final ev in c.events) {
        if (ev.label.label == fc.EventLabel.birthday) {
          final mm = ev.month.toString().padLeft(2, '0');
          final dd = ev.day.toString().padLeft(2, '0');
          birthday = ev.year != null ? '${ev.year}-$mm-$dd' : '$mm-$dd';
          break;
        }
      }

      result.add(
        DeviceContactInput(
          deviceId: id,
          displayName: name,
          phones: [
            for (var i = 0; i < c.phones.length; i++)
              DevicePhoneInput(
                raw: c.phones[i].number,
                label: c.phones[i].label.label.name,
                isPrimary: c.phones[i].isPrimary ?? (i == 0),
              ),
          ],
          company: org?.name,
          role: org?.jobTitle,
          email: email,
          birthday: birthday,
        ),
      );
    }
    return result;
  }

  @override
  Future<List<CallRecord>> readCalls(int afterId, int limit) async {
    if (!Platform.isAndroid) return const [];
    return _api.readCalls(afterId, limit);
  }

  @override
  Future<List<SmsRecord>> readSms(int afterId, int limit) async {
    if (!Platform.isAndroid) return const [];
    return _api.readSms(afterId, limit);
  }

  @override
  Future<String?> simCountryIso() async {
    if (!Platform.isAndroid) return null;
    try {
      return await _api.simCountryIso();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> startObserving() async {
    if (!Platform.isAndroid) return;
    try {
      await _api.startObserving();
    } catch (_) {}
  }

  @override
  Future<void> stopObserving() async {
    if (!Platform.isAndroid) return;
    try {
      await _api.stopObserving();
    } catch (_) {}
  }
}

enum SyncPhase { idle, running, failed }

class SyncStatus {
  const SyncStatus({
    required this.phase,
    this.contactsSynced = 0,
    this.callsSynced = 0,
    this.smsSynced = 0,
    this.error,
    this.lastSuccessAt,
  });

  static const initial = SyncStatus(phase: SyncPhase.idle);

  final SyncPhase phase;
  final int contactsSynced;
  final int callsSynced;
  final int smsSynced;
  final String? error;
  final int? lastSuccessAt;
}

class SyncResult {
  const SyncResult({
    required this.contactsSynced,
    required this.callsSynced,
    required this.smsSynced,
  });

  final int contactsSynced;
  final int callsSynced;
  final int smsSynced;
}

class MergeSuggestion {
  const MergeSuggestion({
    required this.contactIdA,
    required this.contactIdB,
    required this.e164,
  });

  final int contactIdA;
  final int contactIdB;
  final String e164;

  Map<String, Object?> toJson() => {
        'a': contactIdA,
        'b': contactIdB,
        'e164': e164,
      };

  static MergeSuggestion fromJson(Map<String, dynamic> json) => MergeSuggestion(
        contactIdA: json['a'] as int,
        contactIdB: json['b'] as int,
        e164: json['e164'] as String,
      );
}

/// Fast, incremental, batched sync engine for contacts, calls, and SMS.
/// Messages from saved people are NEVER filtered out.
class SyncService {
  SyncService({
    required AppDatabase db,
    required this.source,
    this.phoneService = const PhoneService(),
    this.amountParser = const AmountParser(),
    this.clock = DateTime.now,
    this.batchSize = 500,
  })  : _db = db,
        _settings = SettingsRepository(db),
        _syncState = SyncStateRepository(db);

  final AppDatabase _db;
  final DeviceDataSource source;
  final PhoneService phoneService;
  final AmountParser amountParser;
  final DateTime Function() clock;
  final int batchSize;
  final SettingsRepository _settings;
  final SyncStateRepository _syncState;

  final _statusController = StreamController<SyncStatus>.broadcast();
  SyncStatus _currentStatus = SyncStatus.initial;
  bool _running = false;
  DateTime? _lastAutoTrigger;

  Stream<SyncStatus> get statusStream => _statusController.stream;
  SyncStatus get currentStatus => _currentStatus;

  void _emit(SyncStatus status) {
    _currentStatus = status;
    if (!_statusController.isClosed) {
      _statusController.add(status);
    }
  }

  /// Resolves the active 2-letter phone region ISO:
  /// 1. User setting `phone_region`
  /// 2. SIM country ISO from native API (persisted if found)
  /// 3. Device locale country code
  /// 4. Fallback `'US'`
  Future<String> resolveRegionIso() async {
    final saved = await _settings.get('phone_region');
    if (saved != null && saved.trim().length == 2) {
      return saved.trim().toUpperCase();
    }

    final simIso = await source.simCountryIso();
    if (simIso != null && simIso.trim().length == 2) {
      final upper = simIso.trim().toUpperCase();
      await _settings.set('phone_region', upper);
      return upper;
    }

    final localeName = Platform.localeName; // e.g. en_US or bn_BD
    final parts = localeName.split(RegExp(r'[_-]'));
    if (parts.length >= 2 && parts[1].length == 2) {
      return parts[1].toUpperCase();
    }
    return 'US';
  }

  /// Throttled sync for app start / foreground resume (at most once per minute).
  Future<SyncResult?> syncIfStale() async {
    final now = clock();
    if (_lastAutoTrigger != null && now.difference(_lastAutoTrigger!) < const Duration(minutes: 1)) {
      return null;
    }
    _lastAutoTrigger = now;
    return syncAll();
  }

  /// Full incremental sync: one-time migrations -> contacts -> calls -> SMS.
  Future<SyncResult> syncAll({
    bool syncContacts = true,
    bool syncCalls = true,
    bool syncSms = true,
  }) async {
    if (_running) {
      return const SyncResult(contactsSynced: 0, callsSynced: 0, smsSynced: 0);
    }
    _running = true;
    int contactsSynced = 0;
    int callsSynced = 0;
    int smsSynced = 0;

    final lastSuccess = await _syncState.getInt('last_sync_success_at');
    _emit(SyncStatus(phase: SyncPhase.running, lastSuccessAt: lastSuccess));

    try {
      final region = await resolveRegionIso();

      await _migratePhonesOnce(region);
      final firstPassAfterMigration = await _migrateLegacyNativeIdsOnce();

      if (syncContacts) {
        contactsSynced = await _syncContacts(region);
        _emit(
          SyncStatus(
            phase: SyncPhase.running,
            contactsSynced: contactsSynced,
            lastSuccessAt: lastSuccess,
          ),
        );
      }

      // Build in-memory phone lookup tables once for batched call & SMS matching
      final lookup = await _buildPhoneLookup(region);

      if (syncCalls) {
        callsSynced = await _syncCalls(
          region: region,
          lookup: lookup,
          dedupLegacyNullCalls: firstPassAfterMigration,
          onBatch: (totalCalls) {
            _emit(
              SyncStatus(
                phase: SyncPhase.running,
                contactsSynced: contactsSynced,
                callsSynced: totalCalls,
                smsSynced: smsSynced,
                lastSuccessAt: lastSuccess,
              ),
            );
          },
        );
      }

      if (syncSms) {
        final userCurrency = await _settings.get('currency');
        smsSynced = await _syncSms(
          region: region,
          lookup: lookup,
          userCurrencyCode: userCurrency,
          onBatch: (totalSms) {
            _emit(
              SyncStatus(
                phase: SyncPhase.running,
                contactsSynced: contactsSynced,
                callsSynced: callsSynced,
                smsSynced: totalSms,
                lastSuccessAt: lastSuccess,
              ),
            );
          },
        );
      }

      final completedAt = clock().millisecondsSinceEpoch;
      await _syncState.setInt('last_sync_success_at', completedAt);
      _emit(
        SyncStatus(
          phase: SyncPhase.idle,
          contactsSynced: contactsSynced,
          callsSynced: callsSynced,
          smsSynced: smsSynced,
          lastSuccessAt: completedAt,
        ),
      );

      return SyncResult(
        contactsSynced: contactsSynced,
        callsSynced: callsSynced,
        smsSynced: smsSynced,
      );
    } catch (e, st) {
      debugPrint('SyncService error: $e\n$st');
      _emit(
        SyncStatus(
          phase: SyncPhase.failed,
          contactsSynced: contactsSynced,
          callsSynced: callsSynced,
          smsSynced: smsSynced,
          error: e.toString(),
          lastSuccessAt: lastSuccess,
        ),
      );
      rethrow;
    } finally {
      _running = false;
    }
  }

  /// One-time normalisation of `contact_phones.raw` into E.164.
  /// When two contacts share the same normalised E.164, keeps both contacts,
  /// leaves the second phone row unnormalised, and records a merge suggestion.
  Future<void> _migratePhonesOnce(String region) async {
    final done = await _syncState.get('phones_migrated_v5');
    if (done == '1') return;

    final rows = await (_db.select(_db.contactPhones)
          ..orderBy([(t) => OrderingTerm(expression: t.id)]))
        .get();

    final claimedByContact = <String, int>{};
    final suggestions = <MergeSuggestion>[];

    for (final row in rows) {
      final raw = row.raw ?? row.e164 ?? '';
      final e164 = phoneService.normalise(raw, region);
      if (e164 == null) continue;

      final existingOwner = claimedByContact[e164];
      if (existingOwner != null && existingOwner != row.contactId) {
        // Collision across two contacts: leave this row unnormalised and record merge suggestion
        suggestions.add(
          MergeSuggestion(
            contactIdA: existingOwner,
            contactIdB: row.contactId,
            e164: e164,
          ),
        );
        continue;
      }

      claimedByContact[e164] = row.contactId;
      final mobile = phoneService.isMobile(e164) ? 1 : 0;

      if (row.e164 != e164 || row.isMobile != mobile) {
        try {
          await (_db.update(_db.contactPhones)..where((t) => t.id.equals(row.id))).write(
            ContactPhonesCompanion(
              e164: Value(e164),
              isMobile: Value(mobile),
            ),
          );
          if (row.isPrimary == 1) {
            await (_db.update(_db.contacts)..where((t) => t.id.equals(row.contactId)))
                .write(ContactsCompanion(phoneNumber: Value(e164)));
          }
        } catch (_) {
          // Unique constraint collision with a later row not yet processed
        }
      }
    }

    if (suggestions.isNotEmpty) {
      await _syncState.set(
        'merge_suggestions',
        jsonEncode(suggestions.map((s) => s.toJson()).toList()),
      );
    }

    await _syncState.set('phones_migrated_v5', '1');
  }

  /// Rewrites bare numeric legacy SMS IDs to `sms:<id>` once and initializes
  /// both watermarks to 0 so messages previously dropped by SpamFilter are recovered.
  Future<bool> _migrateLegacyNativeIdsOnce() async {
    final done = await _syncState.get('native_ids_migrated_v5');
    if (done == '1') return false;

    final queries = CrmQueries(_db);
    await _db.transaction(() async {
      await queries.rewriteLegacyBareSmsIds();
      await _syncState.setInt('last_call_id', 0);
      await _syncState.setInt('last_sms_id', 0);
      await _syncState.set('native_ids_migrated_v5', '1');
    });

    return true;
  }

  Future<int> _syncContacts(String region) async {
    final deviceContacts = await source.readContacts();
    if (deviceContacts.isEmpty) return 0;

    final existingContacts = await _db.select(_db.contacts).get();
    final existingPhones = await _db.select(_db.contactPhones).get();

    final byDeviceId = <String, Contact>{
      for (final c in existingContacts)
        if (c.deviceContactId != null && c.deviceContactId!.isNotEmpty) c.deviceContactId!: c,
    };
    final byId = <int, Contact>{for (final c in existingContacts) c.id: c};
    final e164ToContactId = <String, int>{};
    for (final ph in existingPhones) {
      if (ph.e164 != null && ph.e164!.isNotEmpty) {
        e164ToContactId[ph.e164!] = ph.contactId;
      }
    }

    int synced = 0;
    final touchedIds = <int>{};
    final now = clock().millisecondsSinceEpoch;

    await _db.transaction(() async {
      for (final dc in deviceContacts) {
        final normalisedPhones = <(DevicePhoneInput input, String e164, bool isMobile)>[];
        for (final ph in dc.phones) {
          final e164 = phoneService.normalise(ph.raw, region);
          if (e164 == null) continue;
          normalisedPhones.add((ph, e164, phoneService.isMobile(e164)));
        }
        if (normalisedPhones.isEmpty) continue;

        Contact? match;
        if (dc.deviceId.isNotEmpty) {
          match = byDeviceId[dc.deviceId];
        }
        if (match == null) {
          for (final (_, e164, _) in normalisedPhones) {
            final cid = e164ToContactId[e164];
            if (cid != null) {
              match = byId[cid];
              break;
            }
          }
        }

        if (match != null) {
          final existing = match;
          // Respect manual edits: update fields only when device value is present
          // and contact was not manually created or field is currently empty / device-sourced
          final isDeviceSource = existing.source == 'device';
          final needsUpdate = (dc.deviceId.isNotEmpty && existing.deviceContactId != dc.deviceId) ||
              (isDeviceSource && dc.displayName.isNotEmpty && existing.displayName != dc.displayName) ||
              (dc.company != null && dc.company!.isNotEmpty && (existing.company == null || existing.company!.isEmpty)) ||
              (dc.email != null && dc.email!.isNotEmpty && (existing.email == null || existing.email!.isEmpty)) ||
              (dc.birthday != null && dc.birthday!.isNotEmpty && (existing.birthday == null || existing.birthday!.isEmpty));

          if (needsUpdate) {
            await (_db.update(_db.contacts)..where((t) => t.id.equals(existing.id))).write(
              ContactsCompanion(
                deviceContactId: dc.deviceId.isNotEmpty ? Value(dc.deviceId) : const Value.absent(),
                displayName: isDeviceSource && dc.displayName.isNotEmpty
                    ? Value(dc.displayName)
                    : const Value.absent(),
                company: dc.company != null && dc.company!.isNotEmpty && (existing.company == null || existing.company!.isEmpty)
                    ? Value(dc.company)
                    : const Value.absent(),
                role: dc.role != null && dc.role!.isNotEmpty && (existing.role == null || existing.role!.isEmpty)
                    ? Value(dc.role)
                    : const Value.absent(),
                email: dc.email != null && dc.email!.isNotEmpty && (existing.email == null || existing.email!.isEmpty)
                    ? Value(dc.email)
                    : const Value.absent(),
                birthday: dc.birthday != null && dc.birthday!.isNotEmpty && (existing.birthday == null || existing.birthday!.isEmpty)
                    ? Value(dc.birthday)
                    : const Value.absent(),
                lastSyncTime: Value(now),
              ),
            );
            touchedIds.add(existing.id);
          }

          for (final (input, e164, mobile) in normalisedPhones) {
            if (!e164ToContactId.containsKey(e164)) {
              await _db.into(_db.contactPhones).insert(
                    ContactPhonesCompanion.insert(
                      contactId: existing.id,
                      e164: Value(e164),
                      raw: Value(input.raw),
                      label: Value(input.label),
                      isPrimary: const Value(0),
                      isMobile: Value(mobile ? 1 : 0),
                    ),
                    mode: InsertMode.insertOrIgnore,
                  );
              e164ToContactId[e164] = existing.id;
              touchedIds.add(existing.id);
            }
          }
        } else {
          final primaryPhone = normalisedPhones.first.$2;
          final newId = await _db.into(_db.contacts).insert(
                ContactsCompanion.insert(
                  displayName: dc.displayName,
                  phoneNumber: Value(primaryPhone),
                  company: Value(dc.company),
                  role: Value(dc.role),
                  email: Value(dc.email),
                  gmailAddress: Value(dc.email),
                  birthday: Value(dc.birthday),
                  deviceContactId: Value(dc.deviceId.isNotEmpty ? dc.deviceId : null),
                  source: const Value('device'),
                  createdAt: Value(now),
                  lastSyncTime: Value(now),
                ),
                mode: InsertMode.insertOrIgnore,
              );

          if (newId > 0) {
            synced++;
            touchedIds.add(newId);
            for (var i = 0; i < normalisedPhones.length; i++) {
              final (input, e164, mobile) = normalisedPhones[i];
              await _db.into(_db.contactPhones).insert(
                    ContactPhonesCompanion.insert(
                      contactId: newId,
                      e164: Value(e164),
                      raw: Value(input.raw),
                      label: Value(input.label),
                      isPrimary: Value(i == 0 ? 1 : 0),
                      isMobile: Value(mobile ? 1 : 0),
                    ),
                    mode: InsertMode.insertOrIgnore,
                  );
              e164ToContactId[e164] = newId;
            }
          }
        }
      }
    });

    for (final cid in touchedIds) {
      await _db.rebuildFtsForContact(cid);
    }

    return synced;
  }

  Future<_PhoneLookup> _buildPhoneLookup(String region) async {
    final phones = await _db.select(_db.contactPhones).get();
    final e164Map = <String, int>{};
    final suffixCounts = <String, Set<int>>{};

    for (final ph in phones) {
      final candidate = (ph.e164 != null && ph.e164!.isNotEmpty)
          ? ph.e164!
          : phoneService.normalise(ph.raw ?? '', region);
      if (candidate != null && candidate.isNotEmpty) {
        e164Map[candidate] = ph.contactId;
        final suffix = phoneService.nationalSuffix(candidate, digits: 9);
        if (suffix != null) {
          suffixCounts.putIfAbsent(suffix, () => <int>{}).add(ph.contactId);
        }
      }
    }

    // Fallback: unique 9-digit suffix matches only
    final uniqueSuffixMap = <String, int>{};
    suffixCounts.forEach((suffix, owners) {
      if (owners.length == 1) {
        uniqueSuffixMap[suffix] = owners.first;
      }
    });

    return _PhoneLookup(e164Map, uniqueSuffixMap, phoneService, region);
  }

  Future<int> _syncCalls({
    required String region,
    required _PhoneLookup lookup,
    required bool dedupLegacyNullCalls,
    required void Function(int totalCalls) onBatch,
  }) async {
    int watermark = await _syncState.getInt('last_call_id') ?? 0;
    int totalInserted = 0;

    while (true) {
      final batch = await source.readCalls(watermark, batchSize);
      if (batch.isEmpty) break;

      int batchMaxId = watermark;
      final touchedContacts = <int>{};

      await _db.transaction(() async {
        for (final rec in batch) {
          if (rec.id > batchMaxId) batchMaxId = rec.id;

          final contactId = lookup.resolve(rec.number);
          if (contactId == null) continue;

          final callType = switch (rec.type) {
            'outgoing' => 'call_outgoing',
            'missed' => 'call_missed',
            _ => 'call_incoming',
          };
          final nativeId = 'call:${rec.id}';

          if (dedupLegacyNullCalls) {
            final stamped = await CrmQueries(_db).stampLegacyCallIfPresent(
              contactId: contactId,
              type: callType,
              timestampMs: rec.dateMs,
              nativeId: nativeId,
              durationSeconds: rec.durationSeconds,
            );
            if (stamped) {
              touchedContacts.add(contactId);
              continue;
            }
          }

          final insertedId = await _db.into(_db.timelineEntries).insert(
                TimelineEntriesCompanion.insert(
                  contactId: Value(contactId),
                  type: callType,
                  timestamp: rec.dateMs,
                  content: const Value(''),
                  durationSeconds: Value(rec.durationSeconds),
                  nativeMessageId: Value(nativeId),
                  source: const Value('device'),
                ),
                mode: InsertMode.insertOrIgnore,
              );

          if (insertedId > 0) {
            totalInserted++;
            touchedContacts.add(contactId);
          }
        }

        await _updateLastInteractionBatch(touchedContacts);
        watermark = batchMaxId;
        await _syncState.setInt('last_call_id', watermark);
      });

      onBatch(totalInserted);
    }

    return totalInserted;
  }

  Future<int> _syncSms({
    required String region,
    required _PhoneLookup lookup,
    required String? userCurrencyCode,
    required void Function(int totalSms) onBatch,
  }) async {
    int watermark = await _syncState.getInt('last_sms_id') ?? 0;
    int totalInserted = 0;

    while (true) {
      final batch = await source.readSms(watermark, batchSize);
      if (batch.isEmpty) break;

      int batchMaxId = watermark;
      final touchedContacts = <int>{};

      await _db.transaction(() async {
        for (final rec in batch) {
          if (rec.id > batchMaxId) batchMaxId = rec.id;

          final contactId = lookup.resolve(rec.address);
          if (contactId == null) continue;

          final isSent = rec.box == 'sent';
          final type = isSent ? 'sms_outgoing' : 'sms_incoming';
          final nativeId = 'sms:${rec.id}';

          // Incoming SMS from a saved person: detect monetary amounts as suggestions only
          double? suggestedAmount;
          String? suggestionState;
          if (!isSent) {
            suggestedAmount = amountParser.extract(
              rec.body,
              extraCode: userCurrencyCode,
            );
            if (suggestedAmount != null) {
              suggestionState = 'open';
            }
          }

          final insertedId = await _db.into(_db.timelineEntries).insert(
                TimelineEntriesCompanion.insert(
                  contactId: Value(contactId),
                  type: type,
                  timestamp: rec.dateMs,
                  content: Value(rec.body),
                  nativeMessageId: Value(nativeId),
                  suggestedAmount: Value(suggestedAmount),
                  suggestionState: Value(suggestionState),
                  source: const Value('device'),
                ),
                mode: InsertMode.insertOrIgnore,
              );

          if (insertedId > 0) {
            totalInserted++;
            touchedContacts.add(contactId);
          }
        }

        await _updateLastInteractionBatch(touchedContacts);
        watermark = batchMaxId;
        await _syncState.setInt('last_sms_id', watermark);
      });

      onBatch(totalInserted);
    }

    return totalInserted;
  }

  Future<void> _updateLastInteractionBatch(Set<int> contactIds) {
    return CrmQueries(_db).recomputeLastInteractions(contactIds);
  }

  Future<void> startObserving(void Function(String kind) onChange) async {
    DeviceEvents.setUp(_DeviceEventsAdapter(onChange));
    await source.startObserving();
  }

  Future<void> stopObserving() async {
    await source.stopObserving();
  }

  Future<void> dispose() async {
    await stopObserving();
    await _statusController.close();
  }
}

class _DeviceEventsAdapter extends DeviceEvents {
  _DeviceEventsAdapter(this._onChange);

  final void Function(String kind) _onChange;

  @override
  void onDeviceDataChanged(String kind) => _onChange(kind);
}

class _PhoneLookup {
  _PhoneLookup(this._e164Map, this._uniqueSuffixMap, this.phoneService, this._region);

  final Map<String, int> _e164Map;
  final Map<String, int> _uniqueSuffixMap;
  final PhoneService phoneService;
  final String _region;

  int? resolve(String rawNumber) {
    final e164 = phoneService.normalise(rawNumber, _region);
    if (e164 != null) {
      final exact = _e164Map[e164];
      if (exact != null) return exact;
      final suffix = phoneService.nationalSuffix(e164, digits: 9);
      if (suffix != null) return _uniqueSuffixMap[suffix];
    }
    final rawSuffix = phoneService.nationalSuffix(rawNumber, digits: 9);
    if (rawSuffix != null) return _uniqueSuffixMap[rawSuffix];
    return null;
  }
}

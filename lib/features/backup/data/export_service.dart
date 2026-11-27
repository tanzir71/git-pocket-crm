import 'dart:io';

import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import '../../../core/db/app_database.dart';
import '../../messages/data/outbox_repository.dart';
import '../../payments/data/payments_repository.dart';
import 'backup_service.dart';

/// Exports People (CSV and vCard 3.0) and per-person History (CSV) to open formats
/// via Android SAF or the native share sheet.
class ExportService {
  ExportService({
    required this._db,
    required this._safClient,
    required this._outboxClient,
    required this._cacheDirProvider,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final BackupSafClient _safClient;
  final OutboxPlatformClient _outboxClient;
  final Future<Directory> Function() _cacheDirProvider;
  final DateTime Function()? _clock;

  /// Generates RFC 4180 CSV with columns:
  /// name, numbers, company, role, city, email, lists, last contact, balance.
  Future<String> buildPeopleCsv() async {
    final contacts = await (_db.select(_db.contacts)
          ..orderBy([(t) => OrderingTerm(expression: t.displayName)]))
        .get();
    final allPhones = await _db.select(_db.contactPhones).get();
    final allLists = await _db.select(_db.contactLists).get();
    final allMembers = await _db.select(_db.contactListMembers).get();
    final allTimeline = await _db.select(_db.timelineEntries).get();

    final phonesByContact = <int, List<String>>{};
    for (final ph in allPhones) {
      final numStr = (ph.e164 != null && ph.e164!.isNotEmpty) ? ph.e164! : (ph.raw ?? '');
      if (numStr.isNotEmpty) {
        phonesByContact.putIfAbsent(ph.contactId, () => <String>[]).add(numStr);
      }
    }
    final listNameById = {for (final l in allLists) l.id: l.name};
    final listsByContact = <int, List<String>>{};
    for (final m in allMembers) {
      final cid = m.contactId;
      final name = listNameById[m.listId];
      if (cid != null && name != null) {
        listsByContact.putIfAbsent(cid, () => <String>[]).add(name);
      }
    }
    final timelineByContact = <int, List<TimelineEntry>>{};
    for (final t in allTimeline) {
      final cid = t.contactId;
      if (cid != null) {
        timelineByContact.putIfAbsent(cid, () => <TimelineEntry>[]).add(t);
      }
    }

    final buf = StringBuffer();
    buf.writeln('name,numbers,company,role,city,email,lists,last_contact,balance');
    for (final c in contacts) {
      final fallbackNum = c.phoneNumber ?? '';
      final nums = phonesByContact[c.id] ?? (fallbackNum.isNotEmpty ? [fallbackNum] : const <String>[]);
      final uniqueNums = nums.where((n) => n.trim().isNotEmpty).toSet().join('; ');
      final lists = (listsByContact[c.id] ?? const <String>[]).join('; ');
      final lastContact = c.lastInteractionAt != null
          ? DateTime.fromMillisecondsSinceEpoch(c.lastInteractionAt!).toUtc().toIso8601String()
          : '';
      final balance = PaymentsRepository.computeBalance(timelineByContact[c.id] ?? const []);
      final balStr = balance.hasBalance ? balance.netAmount.toStringAsFixed(2) : '';
      final email = (c.email != null && c.email!.isNotEmpty)
          ? c.email!
          : (c.gmailAddress ?? '');

      buf.writeln([
        _csvCell(c.displayName),
        _csvCell(uniqueNums),
        _csvCell(c.company ?? ''),
        _csvCell(c.role ?? ''),
        _csvCell(c.city ?? ''),
        _csvCell(email),
        _csvCell(lists),
        _csvCell(lastContact),
        _csvCell(balStr),
      ].join(','));
    }
    return buf.toString();
  }

  /// Generates standards-compliant vCard 3.0 text for all contacts.
  Future<String> buildPeopleVcard() async {
    final contacts = await (_db.select(_db.contacts)
          ..orderBy([(t) => OrderingTerm(expression: t.displayName)]))
        .get();
    final allPhones = await _db.select(_db.contactPhones).get();
    final phonesByContact = <int, List<ContactPhone>>{};
    for (final ph in allPhones) {
      phonesByContact.putIfAbsent(ph.contactId, () => <ContactPhone>[]).add(ph);
    }

    final buf = StringBuffer();
    for (final c in contacts) {
      buf.write('BEGIN:VCARD\r\n');
      buf.write('VERSION:3.0\r\n');
      buf.write('FN:${_escapeVcard(c.displayName)}\r\n');
      final parts = c.displayName.trim().split(RegExp(r'\s+'));
      final first = parts.isNotEmpty ? parts.first : '';
      final last = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      buf.write('N:${_escapeVcard(last)};${_escapeVcard(first)};;;\r\n');

      final phones = phonesByContact[c.id];
      final fallbackNum = (c.phoneNumber ?? '').trim();
      if (phones != null && phones.isNotEmpty) {
        for (final ph in phones) {
          final number = (ph.e164 != null && ph.e164!.isNotEmpty) ? ph.e164! : (ph.raw ?? '');
          if (number.trim().isEmpty) continue;
          final type = ph.isMobile == 1 ? 'CELL' : 'VOICE';
          buf.write('TEL;TYPE=$type:${number.trim()}\r\n');
        }
      } else if (fallbackNum.isNotEmpty) {
        buf.write('TEL;TYPE=CELL:$fallbackNum\r\n');
      }

      if (c.company != null && c.company!.trim().isNotEmpty) {
        buf.write('ORG:${_escapeVcard(c.company!.trim())}\r\n');
      }
      if (c.role != null && c.role!.trim().isNotEmpty) {
        buf.write('TITLE:${_escapeVcard(c.role!.trim())}\r\n');
      }
      final email = (c.email != null && c.email!.trim().isNotEmpty)
          ? c.email!.trim()
          : (c.gmailAddress ?? '').trim();
      if (email.isNotEmpty) {
        buf.write('EMAIL;TYPE=INTERNET:${_escapeVcard(email)}\r\n');
      }
      if (c.city != null && c.city!.trim().isNotEmpty) {
        buf.write('ADR;TYPE=WORK:;;;${_escapeVcard(c.city!.trim())};;;\r\n');
      }
      if (c.birthday != null && c.birthday!.trim().isNotEmpty) {
        buf.write('BDAY:${c.birthday!.trim()}\r\n');
      }
      final note = (c.about != null && c.about!.trim().isNotEmpty)
          ? c.about!.trim()
          : (c.pinnedNote ?? '').trim();
      if (note.isNotEmpty) {
        buf.write('NOTE:${_escapeVcard(note)}\r\n');
      }
      buf.write('END:VCARD\r\n');
    }
    return buf.toString();
  }

  /// Generates RFC 4180 CSV for one person's full history.
  Future<String> buildPersonHistoryCsv(int contactId) async {
    final rows = await (_db.select(_db.timelineEntries)
          ..where((t) => t.contactId.equals(contactId) & t.hidden.equals(0))
          ..orderBy([(t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc)]))
        .get();

    final buf = StringBuffer();
    buf.writeln('date,type,duration_seconds,outcome,place,content,note,amount,currency,payment_status');
    for (final r in rows) {
      final dt = DateTime.fromMillisecondsSinceEpoch(r.timestamp).toUtc().toIso8601String();
      buf.writeln([
        _csvCell(dt),
        _csvCell(r.type),
        _csvCell(r.durationSeconds?.toString() ?? ''),
        _csvCell(r.outcome ?? ''),
        _csvCell(r.placeName ?? ''),
        _csvCell(r.content ?? ''),
        _csvCell(r.note ?? ''),
        _csvCell(r.amount != null ? r.amount!.toStringAsFixed(2) : ''),
        _csvCell(r.currency ?? ''),
        _csvCell(r.paymentStatus ?? ''),
      ].join(','));
    }
    return buf.toString();
  }

  Future<bool> exportPeopleCsvToSaf() async {
    final date = DateFormat('yyyy-MM-dd').format((_clock ?? DateTime.now)());
    final csv = await buildPeopleCsv();
    return _saveOrShare(
      fileName: 'PocketCRM People $date.csv',
      mimeType: 'text/csv',
      content: csv,
      useSaf: true,
    );
  }

  Future<bool> exportPeopleVcardToSaf() async {
    final date = DateFormat('yyyy-MM-dd').format((_clock ?? DateTime.now)());
    final vcf = await buildPeopleVcard();
    return _saveOrShare(
      fileName: 'PocketCRM People $date.vcf',
      mimeType: 'text/vcard',
      content: vcf,
      useSaf: true,
    );
  }

  Future<bool> exportPersonHistoryCsv(Contact contact) async {
    final date = DateFormat('yyyy-MM-dd').format((_clock ?? DateTime.now)());
    final safeName = contact.displayName.replaceAll(RegExp(r'[^\w\- ]'), '').trim();
    final namePart = safeName.isEmpty ? 'person_${contact.id}' : safeName;
    final csv = await buildPersonHistoryCsv(contact.id);
    return _saveOrShare(
      fileName: 'PocketCRM $namePart $date.csv',
      mimeType: 'text/csv',
      content: csv,
      useSaf: false,
      subject: '${contact.displayName} history',
    );
  }

  Future<bool> _saveOrShare({
    required String fileName,
    required String mimeType,
    required String content,
    required bool useSaf,
    String? subject,
  }) async {
    final cacheDir = await _cacheDirProvider();
    final safeFile = fileName.replaceAll(RegExp(r'[^\w.\- ]'), '_');
    final cacheFile = File(p.join(cacheDir.path, safeFile));
    await cacheFile.writeAsString(content, flush: true);

    if (useSaf) {
      try {
        final uri = await _safClient.createDocument(fileName, mimeType);
        if (uri == null || uri.isEmpty) return false;
        await _safClient.copyFileToUri(cacheFile.path, uri);
        return true;
      } finally {
        if (await cacheFile.exists()) {
          try {
            await cacheFile.delete();
          } catch (_) {}
        }
      }
    } else {
      await _outboxClient.shareFile(cacheFile.path, mimeType, subject ?? fileName);
      return true;
    }
  }

  String _csvCell(String raw) {
    final needsQuote =
        raw.contains(',') || raw.contains('"') || raw.contains('\n') || raw.contains('\r');
    if (!needsQuote) return raw;
    return '"${raw.replaceAll('"', '""')}"';
  }

  String _escapeVcard(String raw) {
    return raw
        .replaceAll('\\', r'\\')
        .replaceAll(';', r'\;')
        .replaceAll(',', r'\,')
        .replaceAll('\r\n', r'\n')
        .replaceAll('\n', r'\n');
  }
}

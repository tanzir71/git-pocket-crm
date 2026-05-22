import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../database_helper.dart';
import '../sync_engine.dart';
import '../sms_processor.dart';
import 'package:sqflite/sqflite.dart';
import 'directory_screen.dart';
import 'thread_screen.dart';
import 'backup_screen.dart';
import 'package:file_picker/file_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _starredContacts = [];
  List<Map<String, dynamic>> _pendingTasks = [];
  List<Map<String, dynamic>> _scheduledSms = [];
  int _totalContacts = 0;
  int _totalTimelineEvents = 0;
  int _lastSyncTime = 0;
  bool _isLoading = true;
  Timer? _smsProcessorTimer;
  int _selectedTabIndex = 0;
  int _smsSubTabIndex = 0;
  List<Map<String, dynamic>> _contactLists = [];
  List<Map<String, dynamic>> _activeBulkJobs = [];
  int _directoryScreenRefreshCount = 0;

  @override
  void initState() {
    super.initState();
    _initAndSeed();
    _startSmsProcessor();
  }

  @override
  void dispose() {
    _smsProcessorTimer?.cancel();
    super.dispose();
  }

  void _startSmsProcessor() {
    _smsProcessorTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _processDueScheduledSms();
      _processDueTaskReminders();
    });
  }

  Future<void> _processDueScheduledSms() async {
    await SmsProcessor.processDueSms(context, () {
      _loadDashboardData();
    });
  }

  Future<void> _processDueTaskReminders() async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    final List<Map<String, dynamic>> dueTasks = await db.rawQuery('''
      SELECT t.*, c.id as c_id, c.display_name 
      FROM tasks t 
      JOIN contacts c ON t.contact_id = c.id 
      WHERE t.reminder_time IS NOT NULL AND t.reminder_time > 0 AND t.reminder_time <= ? AND t.is_completed = 0
    ''', [now]);

    if (dueTasks.isEmpty) return;

    for (var task in dueTasks) {
      final taskId = task['id'] as int;
      final contactId = task['c_id'] as int;
      final taskTitle = task['title'] as String;
      final contactName = task['display_name'] as String;

      await db.update(
        'tasks',
        {'reminder_time': null},
        where: 'id = ?',
        whereArgs: [taskId],
      );

      await db.insert('timeline', {
        'contact_id': contactId,
        'type': 'promise',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'content': 'Reminder Alert Triggered for Task: "$taskTitle"',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFD97706),
            behavior: SnackBarBehavior.floating,
            content: Row(
              children: [
                const Icon(Icons.alarm_on, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Task Due ($contactName): "$taskTitle"',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
            action: SnackBarAction(
              label: 'View Thread',
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => ThreadScreen(contactId: contactId)),
                );
              },
            ),
          ),
        );
      }
    }

    _loadDashboardData();
  }

  Future<void> _initAndSeed() async {
    await _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    final db = await DatabaseHelper.instance.database;

    // 1. Starred Contacts with subqueries for last interaction and next task/sms
    final starred = await db.rawQuery('''
      SELECT c.*,
        (SELECT MAX(timestamp) FROM timeline WHERE contact_id = c.id) as last_interaction_time,
        (SELECT MIN(due_date) FROM tasks WHERE contact_id = c.id AND is_completed = 0) as next_task_time,
        (SELECT MIN(scheduled_time) FROM scheduled_sms WHERE contact_id = c.id AND is_sent = 0) as next_sms_time
      FROM contacts c
      WHERE c.is_starred = 1
    ''');

    // Sort starred contacts descending by max(last_interaction, next_task, next_sms)
    final List<Map<String, dynamic>> sortedStarred = List.from(starred);
    sortedStarred.sort((a, b) {
      int getScore(Map<String, dynamic> c) {
        final lastInt = c['last_interaction_time'] as int? ?? 0;
        final nextTask = c['next_task_time'] as int? ?? 0;
        final nextSms = c['next_sms_time'] as int? ?? 0;
        
        int maxVal = lastInt;
        if (nextTask > maxVal) maxVal = nextTask;
        if (nextSms > maxVal) maxVal = nextSms;
        return maxVal;
      }
      return getScore(b).compareTo(getScore(a));
    });

    // 2. Pending/Incomplete Tasks with contact names (all global tasks for digest)
    final tasks = await db.rawQuery('''
      SELECT t.*, c.display_name, c.avatar_color 
      FROM tasks t 
      JOIN contacts c ON t.contact_id = c.id
      WHERE t.is_completed = 0
      ORDER BY t.due_date ASC
    ''');

    // 3. Upcoming Standalone Scheduled SMS (bulk_job_id IS NULL)
    final scheduled = await db.rawQuery('''
      SELECT s.*, c.display_name, c.avatar_color
      FROM scheduled_sms s
      JOIN contacts c ON s.contact_id = c.id
      WHERE s.is_sent = 0 AND s.bulk_job_id IS NULL
      ORDER BY s.scheduled_time ASC
    ''');

    // 4. Active Bulk SMS Jobs (is_sent = 0)
    final activeBulk = await db.query(
      'bulk_sms_jobs',
      where: 'is_sent = 0',
      orderBy: 'scheduled_time ASC',
    );

    final List<Map<String, dynamic>> processedBulkJobs = [];
    for (var job in activeBulk) {
      final jobId = job['id'] as int;
      final unsentCount = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM scheduled_sms WHERE bulk_job_id = ? AND is_sent = 0',
        [jobId],
      )) ?? 0;
      final totalCount = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM scheduled_sms WHERE bulk_job_id = ?',
        [jobId],
      )) ?? 0;

      if (unsentCount == 0) {
        await db.update(
          'bulk_sms_jobs',
          {'is_sent': 1},
          where: 'id = ?',
          whereArgs: [jobId],
        );
      } else {
        final jobMap = Map<String, dynamic>.from(job);
        jobMap['unsent_count'] = unsentCount;
        jobMap['total_count'] = totalCount;
        processedBulkJobs.add(jobMap);
      }
    }

    // 5. Contact Lists
    final lists = await DatabaseHelper.instance.getContactLists();

    // 6. Stats
    final contactsCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM contacts'),
    ) ?? 0;
    
    final timelineCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM timeline'),
    ) ?? 0;

    final lastSyncRow = await db.rawQuery('SELECT MAX(last_sync_time) as max_sync FROM contacts');
    final maxSync = lastSyncRow.first['max_sync'] as int? ?? 0;

    if (mounted) {
      setState(() {
        _starredContacts = sortedStarred;
        _pendingTasks = tasks;
        _scheduledSms = scheduled;
        _activeBulkJobs = processedBulkJobs;
        _contactLists = lists;
        _totalContacts = contactsCount;
        _totalTimelineEvents = timelineCount;
        _lastSyncTime = maxSync;
        _isLoading = false;
      });
    }
  }

  Future<void> _simulateSendSMS(int smsId, int contactId, String phone, String message) async {
    // Send actual native SMS
    await SmsProcessor.sendNativeSms(phone, message);

    final db = await DatabaseHelper.instance.database;
    
    // Mark as sent
    await db.update(
      'scheduled_sms',
      {'is_sent': 1},
      where: 'id = ?',
      whereArgs: [smsId],
    );

    // Insert outgoing SMS into timeline
    await db.insert('timeline', {
      'contact_id': contactId,
      'type': 'sms_outgoing',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'content': message,
      'native_message_id': 'scheduled_sent_$smsId',
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully sent SMS to: $phone'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    }

    _loadDashboardData();
  }

  Future<void> _cancelScheduledSMS(int smsId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('scheduled_sms', where: 'id = ?', whereArgs: [smsId]);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Scheduled SMS cancelled successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    _loadDashboardData();
  }

  Future<void> _simulateSendBulkJob(int jobId, String listName, String message) async {
    final db = await DatabaseHelper.instance.database;
    
    final List<Map<String, dynamic>> unsentSms = await db.query(
      'scheduled_sms',
      where: 'bulk_job_id = ? AND is_sent = 0',
      whereArgs: [jobId],
    );

    if (unsentSms.isEmpty) return;

    for (var sms in unsentSms) {
      final phone = sms['phone_number'] as String;
      await SmsProcessor.sendNativeSms(phone, message);
    }

    await db.transaction((txn) async {
      for (var sms in unsentSms) {
        final smsId = sms['id'] as int;
        final contactId = sms['contact_id'] as int;

        await txn.update(
          'scheduled_sms',
          {'is_sent': 1},
          where: 'id = ?',
          whereArgs: [smsId],
        );

        await txn.insert('timeline', {
          'contact_id': contactId,
          'type': 'sms_outgoing',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'content': message,
          'native_message_id': 'scheduled_sent_$smsId',
        });
      }

      await txn.update(
        'bulk_sms_jobs',
        {'is_sent': 1},
        where: 'id = ?',
        whereArgs: [jobId],
      );
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bulk SMS dispatch completed for $listName (${unsentSms.length} recipients).'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    }

    _loadDashboardData();
  }

  Future<void> _cancelBulkJob(int jobId) async {
    final db = await DatabaseHelper.instance.database;
    await db.transaction((txn) async {
      await txn.delete(
        'scheduled_sms',
        where: 'bulk_job_id = ? AND is_sent = 0',
        whereArgs: [jobId],
      );
      await txn.update(
        'bulk_sms_jobs',
        {'is_sent': 1},
        where: 'id = ?',
        whereArgs: [jobId],
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bulk SMS Job cancelled successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    _loadDashboardData();
  }

  Future<void> _startNativeSync() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await SyncEngine.syncAll();
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            'Sync Completed',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF3525CD)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Device database synced completely offline.', style: GoogleFonts.inter(fontSize: 14)),
              const SizedBox(height: 16),
              _buildSyncSummaryRow(Icons.person_add_alt_1, '${results['contacts']} new contacts added'),
              const SizedBox(height: 8),
              _buildSyncSummaryRow(Icons.phone_in_talk, '${results['calls']} new call history logs'),
              const SizedBox(height: 8),
              _buildSyncSummaryRow(Icons.sms_outlined, '${results['sms']} new personal SMS synced'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Done', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF3525CD))),
            )
          ],
        ),
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sync failed: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        _loadDashboardData();
      }
    }
  }

  Widget _buildSyncSummaryRow(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF4F46E5), size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 13, color: const Color(0xFF374151)),
          ),
        ),
      ],
    );
  }

  void _openStarredListDetailsSheet() {
    List<Map<String, dynamic>> nonStarred = [];
    String searchQuery = "";
    final searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            void loadNonStarred() async {
              final db = await DatabaseHelper.instance.database;
              final results = await db.query(
                'contacts',
                where: 'is_starred = 0 AND (display_name LIKE ? OR phone_number LIKE ?)',
                whereArgs: ['%$searchQuery%', '%$searchQuery%'],
                orderBy: 'display_name ASC',
                limit: 10,
              );
              setSheetState(() {
                nonStarred = results;
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 16,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Starred Contacts',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[800],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${_starredContacts.length} Starred',
                            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.amber[800]),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Members',
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF4B5563)),
                        ),
                        if (_starredContacts.isNotEmpty)
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _openGlobalCreateSheet(initialType: 'sms', initialSmsList: {'id': -1, 'name': 'Starred Contacts'});
                            },
                            icon: const Icon(Icons.sms_outlined, size: 16, color: Color(0xFF3525CD)),
                            label: Text(
                              'Send Bulk SMS',
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF3525CD)),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF3525CD), width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      flex: 3,
                      child: _starredContacts.isEmpty
                          ? Center(
                              child: Text(
                                'No starred contacts yet. Search and add below!',
                                style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[500]),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _starredContacts.length,
                              itemBuilder: (context, index) {
                                final member = _starredContacts[index];
                                final phone = member['phone_number'] ?? '';
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.amber.withOpacity(0.1),
                                    child: const Icon(Icons.star, color: Colors.amber, size: 20),
                                  ),
                                  title: Text(member['display_name'], style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                                  subtitle: Text(phone, style: GoogleFonts.inter(fontSize: 12)),
                                  trailing: TextButton(
                                    onPressed: () async {
                                      final db = await DatabaseHelper.instance.database;
                                      await db.update(
                                        'contacts',
                                        {'is_starred': 0},
                                        where: 'id = ?',
                                        whereArgs: [member['id']],
                                      );
                                      await _loadDashboardData();
                                      setSheetState(() {});
                                      loadNonStarred();
                                    },
                                    child: const Text('Unstar', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                                  ),
                                );
                              },
                            ),
                    ),
                    const Divider(height: 24),
                    Text(
                      'Add Contacts to Starred',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF4B5563)),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: searchController,
                      onChanged: (val) {
                        searchQuery = val.trim();
                        loadNonStarred();
                      },
                      decoration: const InputDecoration(
                        labelText: 'Search contacts to add...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      flex: 2,
                      child: nonStarred.isEmpty
                          ? Center(
                              child: Text(
                                searchQuery.isEmpty ? 'Type to search contacts' : 'No matching contacts found',
                                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: nonStarred.length,
                              itemBuilder: (context, index) {
                                final contact = nonStarred[index];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const CircleAvatar(
                                    backgroundColor: Color(0xFFE5E7EB),
                                    child: Icon(Icons.person, color: Colors.grey),
                                  ),
                                  title: Text(contact['display_name'], style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                                  subtitle: Text(contact['phone_number'] ?? '', style: GoogleFonts.inter(fontSize: 12)),
                                  trailing: ElevatedButton(
                                    onPressed: () async {
                                      final db = await DatabaseHelper.instance.database;
                                      await db.update(
                                        'contacts',
                                        {'is_starred': 1},
                                        where: 'id = ?',
                                        whereArgs: [contact['id']],
                                      );
                                      await _loadDashboardData();
                                      setSheetState(() {});
                                      loadNonStarred();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.amber,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      elevation: 0,
                                    ),
                                    child: const Text('Star', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openContactListDetailsSheet(Map<String, dynamic> list) {
    final listId = list['id'] as int;
    final listName = list['name'] as String;
    List<Map<String, dynamic>> members = [];
    List<Map<String, dynamic>> nonMembers = [];
    String searchQuery = "";
    final searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            void loadMembersData() async {
              final mList = await DatabaseHelper.instance.getContactsInList(listId);
              final nmList = await DatabaseHelper.instance.getContactsNotInList(listId);
              
              final filteredNm = nmList.where((c) {
                final dName = (c['display_name'] as String).toLowerCase();
                final phone = (c['phone_number'] as String? ?? '').toLowerCase();
                final query = searchQuery.toLowerCase();
                return dName.contains(query) || phone.contains(query);
              }).toList();

              setSheetState(() {
                members = mList;
                nonMembers = filteredNm.take(10).toList();
              });
            }

            if (members.isEmpty && searchQuery.isEmpty) {
              loadMembersData();
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 16,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            listName,
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF3525CD),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3525CD).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${members.length} Members',
                                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: const Color(0xFF3525CD)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                              tooltip: 'Delete List',
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete list?'),
                                    content: Text('Are you sure you want to delete the contact list "$listName"? Contacts will NOT be deleted.'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await DatabaseHelper.instance.deleteContactList(listId);
                                  await _loadDashboardData();
                                  Navigator.pop(context);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Members',
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF4B5563)),
                        ),
                        if (members.isNotEmpty)
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _openGlobalCreateSheet(initialType: 'sms', initialSmsList: {'id': listId, 'name': listName});
                            },
                            icon: const Icon(Icons.sms_outlined, size: 16, color: Color(0xFF3525CD)),
                            label: Text(
                              'Send Bulk SMS',
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF3525CD)),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF3525CD), width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      flex: 3,
                      child: members.isEmpty
                          ? Center(
                              child: Text(
                                'No members in this list yet. Search and add below!',
                                style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[500]),
                              ),
                            )
                          : ListView.builder(
                              itemCount: members.length,
                              itemBuilder: (context, index) {
                                final member = members[index];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const CircleAvatar(
                                    backgroundColor: Color(0xFFE5E7EB),
                                    child: Icon(Icons.person, color: Color(0xFF3525CD)),
                                  ),
                                  title: Text(member['display_name'], style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                                  subtitle: Text(member['phone_number'] ?? '', style: GoogleFonts.inter(fontSize: 12)),
                                  trailing: TextButton(
                                    onPressed: () async {
                                      await DatabaseHelper.instance.removeContactFromList(listId, member['id']);
                                      await _loadDashboardData();
                                      loadMembersData();
                                    },
                                    child: const Text('Remove', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                                  ),
                                );
                              },
                            ),
                    ),
                    const Divider(height: 24),
                    Text(
                      'Add Contacts to List',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF4B5563)),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: searchController,
                      onChanged: (val) {
                        searchQuery = val.trim();
                        loadMembersData();
                      },
                      decoration: const InputDecoration(
                        labelText: 'Search contacts to add...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      flex: 2,
                      child: nonMembers.isEmpty
                          ? Center(
                              child: Text(
                                searchQuery.isEmpty ? 'Type to search contacts' : 'No matching contacts found',
                                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: nonMembers.length,
                              itemBuilder: (context, index) {
                                final contact = nonMembers[index];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const CircleAvatar(
                                    backgroundColor: Color(0xFFE5E7EB),
                                    child: Icon(Icons.person, color: Colors.grey),
                                  ),
                                  title: Text(contact['display_name'], style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                                  subtitle: Text(contact['phone_number'] ?? '', style: GoogleFonts.inter(fontSize: 12)),
                                  trailing: ElevatedButton(
                                    onPressed: () async {
                                      await DatabaseHelper.instance.addContactToList(listId, contact['id']);
                                      await _loadDashboardData();
                                      loadMembersData();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF3525CD),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      elevation: 0,
                                    ),
                                    child: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _toggleTaskCompletion(int taskId, int currentVal) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'tasks',
      {'is_completed': currentVal == 0 ? 1 : 0},
      where: 'id = ?',
      whereArgs: [taskId],
    );
    _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;
    PreferredSizeWidget? customAppBar;
    final primaryColor = const Color(0xFF3525CD);

    if (_selectedTabIndex == 0) {
      customAppBar = AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'PocketCRM',
          style: GoogleFonts.outfit(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload_outlined, color: Color(0xFF3525CD)),
            tooltip: 'Backup & Migrate',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BackupScreen()),
              );
              _loadDashboardData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.sync, color: Color(0xFF3525CD)),
            tooltip: 'Sync Logs',
            onPressed: () async {
              setState(() => _isLoading = true);
              try {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DirectoryScreen(isEmbedded: false)),
                );
              } catch (_) {}
              _loadDashboardData();
            },
          ),
        ],
      );
      bodyContent = _buildDashboardView();
    } else if (_selectedTabIndex == 1) {
      // Return directory embedded directly (hides parent AppBar as DirectoryScreen handles its own AppBar)
      bodyContent = DirectoryScreen(
        key: ValueKey(_directoryScreenRefreshCount),
        isEmbedded: true,
        onCreateContact: () {
          _openCreateContactSheet(
            onContactCreated: () {
              setState(() {
                _directoryScreenRefreshCount++;
              });
            },
          );
        },
      );
    } else if (_selectedTabIndex == 2) {
      customAppBar = AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Scheduled SMS Queue',
          style: GoogleFonts.outfit(
            color: const Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      );
      bodyContent = _buildSmsQueueDigest();
    } else {
      customAppBar = AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Tasks Checklist',
          style: GoogleFonts.outfit(
            color: const Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      );
      bodyContent = _buildTasksDigest();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: customAppBar,
      body: _isLoading && _selectedTabIndex != 1
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3525CD)))
          : SafeArea(
              bottom: true,
              child: bodyContent,
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
          ),
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _selectedTabIndex,
            onTap: (index) {
              setState(() {
                _selectedTabIndex = index;
              });
              _loadDashboardData();
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            selectedItemColor: primaryColor,
            unselectedItemColor: const Color(0xFF9CA3AF),
            selectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 11),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_outline),
                activeIcon: Icon(Icons.people),
                label: 'Contacts',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.sms_outlined),
                activeIcon: Icon(Icons.sms),
                label: 'SMS Queue',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assignment_outlined),
                activeIcon: Icon(Icons.task_alt),
                label: 'Tasks',
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openFABChoiceSheet,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildDashboardView() {
    final primaryColor = const Color(0xFF3525CD);

    if (_totalContacts == 0) {
      return RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: Center(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.06),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.contact_phone_outlined,
                    size: 80,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'PocketCRM',
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your Local-First Personal CRM',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'PocketCRM runs completely offline and secure on-device. Seamlessly organize contacts, track tasks, attach screenshots, and schedule SMS digests.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Privacy Badge Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.security, color: Color(0xFF059669), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '100% On-Device & Private: None of your data ever leaves this phone.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF047857),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Action buttons
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _startNativeSync,
                    icon: const Icon(Icons.sync, size: 22, color: Colors.white),
                    label: Text(
                      'Sync Phone Contacts',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: _openCreateContactSheet,
                    icon: Icon(Icons.person_add_alt_outlined, size: 22, color: primaryColor),
                    label: Text(
                      'Create Contact Manually',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primaryColor, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Bento Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Contacts',
                    '$_totalContacts',
                    Icons.perm_contact_calendar_outlined,
                    primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Interactions',
                    '$_totalTimelineEvents',
                    Icons.history,
                    const Color(0xFF4F46E5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildSyncStatusCard(primaryColor),
            
            const SizedBox(height: 24),
            
            // Dynamic Compact Starred Roster Row
            Text(
              'Starred Contacts',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            _starredContacts.isEmpty
                ? _buildEmptyStarredCard()
                : _buildStarredHorizontalList(),

            const SizedBox(height: 24),

            // Short Dashboard Summary Section
            Text(
              'Upcoming Activity Summary',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  _buildSummaryDigestRow(
                    Icons.sms_outlined,
                    const Color(0xFF6366F1),
                    'Pending Scheduled SMS',
                    '${_scheduledSms.length} unsent scheduled SMS reminders pending',
                    () => setState(() => _selectedTabIndex = 2),
                  ),
                  const Divider(height: 20),
                  _buildSummaryDigestRow(
                    Icons.task_alt_outlined,
                    const Color(0xFFF59E0B),
                    'Active Unresolved Tasks',
                    '${_pendingTasks.length} active tasks checklists',
                    () => setState(() => _selectedTabIndex = 3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80), // spacer for bottom padding/navigation overlapping
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryDigestRow(IconData icon, Color color, String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF1F2937)),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  Widget _buildStarredHorizontalList() {
    return SizedBox(
      height: 125,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _starredContacts.length,
        itemBuilder: (context, index) {
          final contact = _starredContacts[index];
          final colorHex = contact['avatar_color'] ?? '#3525CD';
          final intColor = int.tryParse(colorHex.replaceFirst('#', '0xFF')) ?? 0xFF3525CD;
          final color = Color(intColor);

          return GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ThreadScreen(contactId: contact['id']),
                ),
              );
              _loadDashboardData();
            },
            child: Container(
              width: 145,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.015),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: color.withOpacity(0.1),
                    child: Text(
                      contact['display_name'][0].toUpperCase(),
                      style: GoogleFonts.outfit(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    contact['display_name'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  _buildStarredStatus(contact),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStarredStatus(Map<String, dynamic> c) {
    final lastInt = c['last_interaction_time'] as int? ?? 0;
    final nextTask = c['next_task_time'] as int? ?? 0;
    final nextSms = c['next_sms_time'] as int? ?? 0;

    final now = DateTime.now().millisecondsSinceEpoch;

    String text = 'No activity';
    Color badgeColor = Colors.grey;

    if (nextSms > 0 && nextSms > now) {
      final diff = DateTime.fromMillisecondsSinceEpoch(nextSms).difference(DateTime.now());
      if (diff.inMinutes < 60) {
        text = 'SMS in ${diff.inMinutes}m';
      } else if (diff.inHours < 24) {
        text = 'SMS in ${diff.inHours}h';
      } else {
        text = 'SMS: ${DateFormat('Md').format(DateTime.fromMillisecondsSinceEpoch(nextSms))}';
      }
      badgeColor = const Color(0xFF6366F1); // Indigo
    } else if (nextTask > 0 && nextTask > now) {
      final diff = DateTime.fromMillisecondsSinceEpoch(nextTask).difference(DateTime.now());
      if (diff.inMinutes < 60) {
        text = 'Task in ${diff.inMinutes}m';
      } else if (diff.inHours < 24) {
        text = 'Task in ${diff.inHours}h';
      } else if (diff.inDays <= 1) {
        text = 'Task tomorrow';
      } else {
        text = 'Task: ${diff.inDays}d left';
      }
      badgeColor = const Color(0xFFF59E0B); // Amber
    } else if (lastInt > 0) {
      final diff = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(lastInt));
      if (diff.inMinutes < 60) {
        text = 'Active ${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        text = 'Active ${diff.inHours}h ago';
      } else if (diff.inDays <= 1) {
        text = 'Active yesterday';
      } else {
        text = 'Active ${diff.inDays}d ago';
      }
      badgeColor = const Color(0xFF10B981); // Green
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: badgeColor.withOpacity(0.2), width: 1),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: badgeColor,
        ),
      ),
    );
  }

  Widget _buildSmsQueueDigest() {
    return Column(
      children: [
        _buildSmsSubNavigationBar(),
        Expanded(
          child: _smsSubTabIndex == 0 ? _buildSmsQueueList() : _buildContactListsView(),
        ),
      ],
    );
  }

  Widget _buildSmsSubNavigationBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSubTabButton(0, 'SMS Queue', Icons.queue_play_next),
          ),
          Expanded(
            child: _buildSubTabButton(1, 'Contact Lists', Icons.contact_mail_outlined),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTabButton(int index, String label, IconData icon) {
    final isSelected = _smsSubTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _smsSubTabIndex = index;
        });
        _loadDashboardData();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? const Color(0xFF3525CD) : const Color(0xFF4B5563),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF3525CD) : const Color(0xFF4B5563),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmsQueueList() {
    final List<Map<String, dynamic>> combinedQueue = [];
    for (var sms in _scheduledSms) {
      final map = Map<String, dynamic>.from(sms);
      map['queue_type'] = 'single';
      combinedQueue.add(map);
    }
    for (var job in _activeBulkJobs) {
      final map = Map<String, dynamic>.from(job);
      map['queue_type'] = 'bulk';
      combinedQueue.add(map);
    }

    combinedQueue.sort((a, b) {
      final timeA = a['scheduled_time'] as int;
      final timeB = b['scheduled_time'] as int;
      return timeA.compareTo(timeB);
    });

    if (combinedQueue.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sms_failed_outlined, size: 54, color: Colors.grey[300]),
              const SizedBox(height: 12),
              Text(
                'Queue Empty',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF374151)),
              ),
              const SizedBox(height: 4),
              Text(
                'No outbound SMS scheduled globally. Set up scheduled events inside contact threads or the "+" creator!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: combinedQueue.length,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
      separatorBuilder: (c, i) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = combinedQueue[index];
        final scheduledTime = DateTime.fromMillisecondsSinceEpoch(item['scheduled_time']);
        final formattedTime = DateFormat('yMMMd').add_jm().format(scheduledTime);

        if (item['queue_type'] == 'single') {
          final colorHex = item['avatar_color'] ?? '#3525CD';
          final intColor = int.tryParse(colorHex.replaceFirst('#', '0xFF')) ?? 0xFF3525CD;
          final avatarColor = Color(intColor);

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ThreadScreen(contactId: item['contact_id'])),
                );
                _loadDashboardData();
              },
              leading: CircleAvatar(
                radius: 20,
                backgroundColor: avatarColor.withOpacity(0.1),
                child: Text(
                  item['display_name'][0].toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: avatarColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              title: Text(
                item['message'],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                  fontSize: 14,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    'To: ${item['display_name']} (${item['phone_number']})',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF3525CD)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Send: $formattedTime',
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF10B981), size: 20),
                    tooltip: 'Send Now',
                    onPressed: () => _simulateSendSMS(
                      item['id'],
                      item['contact_id'],
                      item['phone_number'],
                      item['message'],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 20),
                    tooltip: 'Cancel SMS',
                    onPressed: () => _cancelScheduledSMS(item['id']),
                  ),
                ],
              ),
            ),
          );
        } else {
          final unsent = item['unsent_count'] as int? ?? 0;
          final total = item['total_count'] as int? ?? 0;

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              gradient: LinearGradient(
                colors: [const Color(0xFF3525CD).withOpacity(0.01), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3525CD).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.group, color: Color(0xFF3525CD), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bulk SMS to ${item['list_name']}',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1F2937),
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Send: $formattedTime',
                              style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3525CD).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$unsent / $total left',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: const Color(0xFF3525CD),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item['message'],
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF4B5563),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => _simulateSendBulkJob(
                          item['id'],
                          item['list_name'],
                          item['message'],
                        ),
                        icon: const Icon(Icons.send, size: 16, color: Color(0xFF10B981)),
                        label: Text(
                          'Send Remaining Now',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      TextButton.icon(
                        onPressed: () => _cancelBulkJob(item['id']),
                        icon: const Icon(Icons.cancel_outlined, size: 16, color: Colors.redAccent),
                        label: Text(
                          'Cancel Bulk Job',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildContactListsView() {
    final listNameController = TextEditingController();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: listNameController,
                  decoration: const InputDecoration(
                    labelText: 'Create Custom Contact List...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final name = listNameController.text.trim();
                    if (name.isEmpty) return;
                    try {
                      await DatabaseHelper.instance.createContactList(name);
                      listNameController.clear();
                      _loadDashboardData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Contact List "$name" created!'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: const Color(0xFF10B981),
                        ),
                      );
                    } catch (_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('A contact list with this name already exists.'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3525CD),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
            children: [
              _buildListCard(
                'Starred Contacts',
                _starredContacts.length,
                Icons.star,
                Colors.amber,
                onTap: _openStarredListDetailsSheet,
              ),
              const SizedBox(height: 12),
              ..._contactLists.map((list) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildListCard(
                    list['name'],
                    list['member_count'] as int? ?? 0,
                    Icons.folder_shared_outlined,
                    const Color(0xFF3525CD),
                    onTap: () => _openContactListDetailsSheet(list),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListCard(String name, int memberCount, IconData icon, Color color, {required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          name,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          '$memberCount members',
          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }

  Widget _buildTasksDigest() {
    if (_pendingTasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assignment_turned_in_outlined, size: 54, color: Colors.grey[300]),
              const SizedBox(height: 12),
              Text(
                'All Tasks Completed',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF374151)),
              ),
              const SizedBox(height: 4),
              Text(
                'All tasks and commitments are fulfilled completely! Great job.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: _pendingTasks.length,
      padding: const EdgeInsets.all(16),
      separatorBuilder: (c, i) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final task = _pendingTasks[index];
        final dueDate = DateTime.fromMillisecondsSinceEpoch(task['due_date']);
        final diff = dueDate.difference(DateTime.now()).inDays;
        String relativeTime = '';
        Color relativeColor = Colors.grey[600]!;

        if (diff == 0) {
          relativeTime = 'Due today';
          relativeColor = Colors.amber[700]!;
        } else if (diff == 1) {
          relativeTime = 'Due tomorrow';
          relativeColor = Colors.amber[700]!;
        } else if (diff > 1) {
          relativeTime = 'Due in $diff days';
          relativeColor = const Color(0xFF3525CD);
        } else {
          relativeTime = 'Overdue by ${diff.abs()} days';
          relativeColor = Colors.redAccent;
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ThreadScreen(contactId: task['contact_id'])),
              );
              _loadDashboardData();
            },
            leading: Checkbox(
              activeColor: const Color(0xFF3525CD),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              value: task['is_completed'] == 1,
              onChanged: (bool? val) {
                _toggleTaskCompletion(task['id'], task['is_completed']);
              },
            ),
            title: Text(
              task['title'],
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: const Color(0xFF1F2937),
                decoration: task['is_completed'] == 1 ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280)),
                children: [
                  const TextSpan(text: 'With '),
                  TextSpan(
                    text: task['display_name'],
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3525CD)),
                  ),
                  const TextSpan(text: ' • '),
                  TextSpan(
                    text: relativeTime,
                    style: TextStyle(fontWeight: FontWeight.w600, color: relativeColor),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncStatusCard(Color primaryColor) {
    String syncStr = "Never synced";
    if (_lastSyncTime > 0) {
      final dt = DateTime.fromMillisecondsSinceEpoch(_lastSyncTime);
      syncStr = "Last synced: ${DateFormat('yMMMd').add_jm().format(dt)}";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(Icons.sync, color: primaryColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    syncStr,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () async {
              setState(() => _selectedTabIndex = 1);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Manage Contacts',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                Icon(Icons.chevron_right, color: primaryColor, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStarredCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          const Icon(Icons.star_outline, size: 48, color: Colors.amber),
          const SizedBox(height: 12),
          Text(
            'No Starred Contacts',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Star contacts in your directory to see them in this active roster.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  void _openCreateContactSheet({VoidCallback? onContactCreated}) {
    final displayNameController = TextEditingController();
    final phoneController = TextEditingController();
    final facebookController = TextEditingController();
    final linkedinController = TextEditingController();
    final gmailController = TextEditingController();
    final pinnedNoteController = TextEditingController();
    bool isStarred = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 16,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Create Contact Manually',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF3525CD),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: displayNameController,
                        decoration: const InputDecoration(
                          labelText: 'Display Name *',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number *',
                          prefixIcon: Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Star this Contact?',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF374151)),
                          ),
                          Switch(
                            value: isStarred,
                            activeColor: Colors.amber,
                            onChanged: (val) {
                              setSheetState(() {
                                isStarred = val;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: facebookController,
                        decoration: const InputDecoration(
                          labelText: 'Facebook Username / URL',
                          prefixIcon: Icon(Icons.link),
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: linkedinController,
                        decoration: const InputDecoration(
                          labelText: 'LinkedIn Username / URL',
                          prefixIcon: Icon(Icons.link),
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: gmailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Gmail Address',
                          prefixIcon: Icon(Icons.mail_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: pinnedNoteController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Initial Pinned Note / Description',
                          prefixIcon: Icon(Icons.description_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () async {
                            final name = displayNameController.text.trim();
                            final phone = phoneController.text.trim();
                            
                            if (name.isEmpty || phone.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Name and Phone Number are required.'),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                              return;
                            }

                            final db = await DatabaseHelper.instance.database;
                            final colors = ['#3525CD', '#6366F1', '#4F46E5', '#10B981', '#F59E0B', '#EF4444', '#EC4899', '#8B5CF6'];
                            final avatarColor = (colors..shuffle()).first;

                            try {
                              final insertedId = await db.insert('contacts', {
                                'display_name': name,
                                'phone_number': phone,
                                'avatar_color': avatarColor,
                                'is_starred': isStarred ? 1 : 0,
                                'facebook_url': facebookController.text.trim(),
                                'linkedin_url': linkedinController.text.trim(),
                                'gmail_address': gmailController.text.trim(),
                                'pinned_note': pinnedNoteController.text.trim(),
                                'last_sync_time': DateTime.now().millisecondsSinceEpoch,
                              });

                              if (pinnedNoteController.text.trim().isNotEmpty) {
                                await db.insert('timeline', {
                                  'contact_id': insertedId,
                                  'type': 'note',
                                  'timestamp': DateTime.now().millisecondsSinceEpoch,
                                  'content': 'Contact Created. Pinned Note: ${pinnedNoteController.text.trim()}',
                                });
                              } else {
                                await db.insert('timeline', {
                                  'contact_id': insertedId,
                                  'type': 'note',
                                  'timestamp': DateTime.now().millisecondsSinceEpoch,
                                  'content': 'Contact Created Manually.',
                                });
                              }

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Contact "$name" created successfully!'),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: const Color(0xFF10B981),
                                  ),
                                );
                              }
                              
                              Navigator.pop(context);
                              _loadDashboardData();
                              if (onContactCreated != null) {
                                onContactCreated();
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to save: Phone number may already exist.'),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3525CD),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Save Contact',
                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openFABChoiceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 24,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'What would you like to do?',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 24),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    _openCreateContactSheet();
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[200]!),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.person_add_rounded,
                            color: Color(0xFF10B981),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Create New Contact',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Add a new contact to your database',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFF9CA3AF),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    _openGlobalCreateSheet();
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[200]!),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3525CD).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.add_task_rounded,
                            color: Color(0xFF3525CD),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Log Event / Task',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Log a note, payment, task, SMS, or file',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFF9CA3AF),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openGlobalCreateSheet({String? initialType, Map<String, dynamic>? initialSmsList}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => GlobalCreateBottomSheet(
        key: const ValueKey('global_create_bottom_sheet'),
        initialType: initialType,
        initialSmsList: initialSmsList,
        contactLists: _contactLists,
        starredContacts: _starredContacts,
        onEventLogged: _loadDashboardData,
      ),
    );
  }
}

class GlobalCreateBottomSheet extends StatefulWidget {
  final String? initialType;
  final Map<String, dynamic>? initialSmsList;
  final List<Map<String, dynamic>> contactLists;
  final List<Map<String, dynamic>> starredContacts;
  final VoidCallback onEventLogged;

  const GlobalCreateBottomSheet({
    Key? key,
    this.initialType,
    this.initialSmsList,
    required this.contactLists,
    required this.starredContacts,
    required this.onEventLogged,
  }) : super(key: key);

  @override
  State<GlobalCreateBottomSheet> createState() => _GlobalCreateBottomSheetState();
}
class _GlobalCreateBottomSheetState extends State<GlobalCreateBottomSheet> {
  Map<String, dynamic>? selectedContact;
  bool isNewContact = false;
  String newContactName = "";
  late String selectedType; // "note", "payment", "promise", "sms", "attachment"
  late String smsRecipientType; // "single" or "list"
  int? selectedSmsListId;
  String? pickedPath;
  bool setPromiseAlarm = false;
  DateTime? promiseReminderTime;
  String selectedPaymentStatus = 'Paid';

  late final TextEditingController searchController;
  late final TextEditingController newPhoneController;
  late final TextEditingController noteController;
  late final TextEditingController paymentAmtController;
  late final TextEditingController paymentDescController;
  late final TextEditingController promiseTitleController;
  late final TextEditingController smsController;
  late final TextEditingController attachFilenameController;
  late final TextEditingController attachDescController;

  late DateTime promiseDueDate;
  late DateTime smsScheduledTime;
  List<Map<String, dynamic>> searchResults = [];

  @override
  void initState() {
    super.initState();
    selectedType = widget.initialType ?? "note";
    smsRecipientType = widget.initialSmsList != null ? "list" : "single";
    selectedSmsListId = widget.initialSmsList != null ? (widget.initialSmsList!['id'] as int?) : null;
    
    promiseDueDate = DateTime.now().add(const Duration(days: 1));
    smsScheduledTime = DateTime.now().add(const Duration(hours: 1));

    searchController = TextEditingController();
    newPhoneController = TextEditingController();
    noteController = TextEditingController();
    paymentAmtController = TextEditingController();
    paymentDescController = TextEditingController();
    promiseTitleController = TextEditingController();
    smsController = TextEditingController();
    attachFilenameController = TextEditingController();
    attachDescController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    newPhoneController.dispose();
    noteController.dispose();
    paymentAmtController.dispose();
    paymentDescController.dispose();
    promiseTitleController.dispose();
    smsController.dispose();
    attachFilenameController.dispose();
    attachDescController.dispose();
    super.dispose();
  }

  void runSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'contacts',
      where: 'display_name LIKE ? OR phone_number LIKE ?',
      whereArgs: ['%${query.trim()}%', '%${query.trim()}%'],
      limit: 5,
    );
    setState(() {
      searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Create Event Log',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF3525CD),
                ),
              ),
              const SizedBox(height: 16),

              if (selectedType != 'sms' || smsRecipientType == 'single') ...[
                Text(
                  'Target Contact',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF4B5563)),
                ),
                const SizedBox(height: 8),
                
                if (selectedContact != null || isNewContact) ...[
                  InputChip(
                    avatar: CircleAvatar(
                      backgroundColor: const Color(0xFF3525CD).withOpacity(0.1),
                      child: Text(
                        (isNewContact ? newContactName : selectedContact!['display_name'])[0].toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3525CD)),
                      ),
                    ),
                    label: Text(isNewContact ? '$newContactName (New)' : selectedContact!['display_name']),
                    onDeleted: () {
                      setState(() {
                        selectedContact = null;
                        isNewContact = false;
                        newContactName = "";
                        searchController.clear();
                        searchResults = [];
                      });
                    },
                  ),
                  if (isNewContact) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: newPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'New Contact Phone Number',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      ),
                    ),
                  ],
                ] else ...[
                  TextField(
                    controller: searchController,
                    onChanged: runSearch,
                    decoration: const InputDecoration(
                      labelText: 'Search existing contact or type new...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                  ),
                  if (searchController.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ...searchResults.map((c) {
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                key: ValueKey('search_res_${c['id']}'),
                                onTap: () {
                                  setState(() {
                                    selectedContact = c;
                                    isNewContact = false;
                                    searchController.clear();
                                    searchResults = [];
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: Colors.grey[100]!),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor: const Color(0xFF3525CD).withOpacity(0.1),
                                        child: const Icon(Icons.person, color: Color(0xFF3525CD), size: 18),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              c['display_name'],
                                              style: GoogleFonts.inter(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: const Color(0xFF1F2937),
                                              ),
                                            ),
                                            if (c['phone_number'] != null && c['phone_number'].toString().isNotEmpty) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                c['phone_number'],
                                                style: GoogleFonts.inter(
                                                  fontSize: 12,
                                                  color: const Color(0xFF6B7280),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF), size: 18),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              key: const ValueKey('search_res_create_new'),
                              onTap: () {
                                setState(() {
                                  isNewContact = true;
                                  newContactName = searchController.text.trim();
                                  selectedContact = null;
                                  searchController.clear();
                                  searchResults = [];
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.green.withOpacity(0.1),
                                      child: const Icon(Icons.person_add, color: Colors.green, size: 18),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Create new contact "${searchController.text.trim()}"',
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.green[700],
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.add_circle_outline, color: Colors.green, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 20),
              ],

              Text(
                'Select Event Type',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF4B5563)),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Note'),
                      selected: selectedType == 'note',
                      selectedColor: const Color(0xFF3525CD).withOpacity(0.15),
                      onSelected: (val) { if (val) setState(() => selectedType = 'note'); },
                    ),
                    const SizedBox(width: 6),
                    ChoiceChip(
                      label: const Text('Payment'),
                      selected: selectedType == 'payment',
                      selectedColor: const Color(0xFF3525CD).withOpacity(0.15),
                      onSelected: (val) { if (val) setState(() => selectedType = 'payment'); },
                    ),
                    const SizedBox(width: 6),
                    ChoiceChip(
                      label: const Text('Task'),
                      selected: selectedType == 'promise',
                      selectedColor: const Color(0xFF3525CD).withOpacity(0.15),
                      onSelected: (val) { if (val) setState(() => selectedType = 'promise'); },
                    ),
                    const SizedBox(width: 6),
                    ChoiceChip(
                      label: const Text('SMS Schedule'),
                      selected: selectedType == 'sms',
                      selectedColor: const Color(0xFF3525CD).withOpacity(0.15),
                      onSelected: (val) { if (val) setState(() => selectedType = 'sms'); },
                    ),
                    const SizedBox(width: 6),
                    ChoiceChip(
                      label: const Text('Attachment'),
                      selected: selectedType == 'attachment',
                      selectedColor: const Color(0xFF3525CD).withOpacity(0.15),
                      onSelected: (val) { if (val) setState(() => selectedType = 'attachment'); },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              if (selectedType == 'note') ...[
                TextField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Personal Note Details',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
              ] else if (selectedType == 'payment') ...[
                Text(
                  'Payment Status',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildStatusChip(
                      status: 'Paid',
                      color: const Color(0xFF10B981),
                      icon: Icons.check_circle_outline,
                      isSelected: selectedPaymentStatus == 'Paid',
                      onSelected: () => setState(() => selectedPaymentStatus = 'Paid'),
                    ),
                    _buildStatusChip(
                      status: 'Received',
                      color: const Color(0xFF0EA5E9),
                      icon: Icons.download_done,
                      isSelected: selectedPaymentStatus == 'Received',
                      onSelected: () => setState(() => selectedPaymentStatus = 'Received'),
                    ),
                    _buildStatusChip(
                      status: 'Owed to Me',
                      color: const Color(0xFFD97706),
                      icon: Icons.hourglass_empty,
                      isSelected: selectedPaymentStatus == 'Owed to Me',
                      onSelected: () => setState(() => selectedPaymentStatus = 'Owed to Me'),
                    ),
                    _buildStatusChip(
                      status: 'I owe',
                      color: const Color(0xFFEF4444),
                      icon: Icons.payment,
                      isSelected: selectedPaymentStatus == 'I owe',
                      onSelected: () => setState(() => selectedPaymentStatus = 'I owe'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: paymentAmtController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount (৳)',
                    prefixText: '৳ ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: paymentDescController,
                  decoration: const InputDecoration(
                    labelText: 'Payment Description',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
              ] else if (selectedType == 'promise') ...[
                TextField(
                  controller: promiseTitleController,
                  decoration: const InputDecoration(
                    labelText: 'Task Title',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Due Date: ${DateFormat('yMMMd').format(promiseDueDate)}',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF374151)),
                    ),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: promiseDueDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() {
                            promiseDueDate = picked;
                          });
                        }
                      },
                      child: const Text('Select Date', style: TextStyle(color: Color(0xFF3525CD), fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: Text(
                    'Set Alarm Reminder',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: const Color(0xFF374151)),
                  ),
                  value: setPromiseAlarm,
                  activeColor: const Color(0xFF3525CD),
                  contentPadding: EdgeInsets.zero,
                  onChanged: (bool value) async {
                    if (value) {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        if (!context.mounted) return;
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() {
                            promiseReminderTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                            setPromiseAlarm = true;
                          });
                        } else {
                          setState(() {
                            setPromiseAlarm = false;
                          });
                        }
                      } else {
                        setState(() {
                          setPromiseAlarm = false;
                        });
                      }
                    } else {
                      setState(() {
                        promiseReminderTime = null;
                        setPromiseAlarm = false;
                      });
                    }
                  },
                ),
                if (setPromiseAlarm && promiseReminderTime != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        const Icon(Icons.notifications_active, color: Colors.amber, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Reminder: ${DateFormat('yMMMd').add_jm().format(promiseReminderTime!)}',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.amber[800]),
                        ),
                      ],
                    ),
                  ),
              ] else if (selectedType == 'sms') ...[
                Text(
                  'Recipient Type',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF4B5563)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Single Contact'),
                      selected: smsRecipientType == 'single',
                      selectedColor: const Color(0xFF3525CD).withOpacity(0.15),
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            smsRecipientType = 'single';
                          });
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Contact List'),
                      selected: smsRecipientType == 'list',
                      selectedColor: const Color(0xFF3525CD).withOpacity(0.15),
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            smsRecipientType = 'list';
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (smsRecipientType == 'list') ...[
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Select Contact List',
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    value: selectedSmsListId,
                    items: [
                      DropdownMenuItem<int>(
                        value: -1,
                        child: Row(
                          children: const [
                            Icon(Icons.star, color: Colors.amber, size: 18),
                            SizedBox(width: 8),
                            Text('Starred Contacts'),
                          ],
                        ),
                      ),
                      ...widget.contactLists.map((list) {
                        final id = list['id'] as int;
                        return DropdownMenuItem<int>(
                          value: id,
                          child: Row(
                            children: [
                              const Icon(Icons.folder_shared_outlined, color: Color(0xFF3525CD), size: 18),
                              const SizedBox(width: 8),
                              Text(list['name']),
                            ],
                          ),
                        );
                      }),
                    ],
                    onChanged: (val) {
                      setState(() {
                        selectedSmsListId = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: smsController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'SMS Message Body',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Send: ${DateFormat('jm').format(smsScheduledTime)}',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF374151)),
                    ),
                    TextButton(
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(smsScheduledTime),
                        );
                        if (time != null) {
                          final now = DateTime.now();
                          setState(() {
                            smsScheduledTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
                            if (smsScheduledTime.isBefore(now)) {
                              smsScheduledTime = smsScheduledTime.add(const Duration(days: 1));
                            }
                          });
                        }
                      },
                      child: const Text('Set Time', style: TextStyle(color: Color(0xFF3525CD), fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ] else if (selectedType == 'attachment') ...[
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: attachFilenameController,
                        decoration: const InputDecoration(
                          labelText: 'File Path / File Name',
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 58,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.any,
                          );
                          if (result != null && result.files.single.path != null) {
                            final file = result.files.single;
                            setState(() {
                              pickedPath = file.path;
                              attachFilenameController.text = file.name;
                            });
                          }
                        },
                        icon: const Icon(Icons.folder_open, size: 20),
                        label: const Text('Browse'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3525CD).withOpacity(0.1),
                          foregroundColor: const Color(0xFF3525CD),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: attachDescController,
                  decoration: const InputDecoration(
                    labelText: 'Short Description',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    final isBulkSms = selectedType == 'sms' && smsRecipientType == 'list';

                    if (!isBulkSms && selectedContact == null && !isNewContact) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select or write-in a target contact.'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    if (!isBulkSms && isNewContact && newPhoneController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a phone number for the new contact.'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    if (isBulkSms && selectedSmsListId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a target contact list.'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    final db = await DatabaseHelper.instance.database;
                    int finalContactId = 0;

                    if (!isBulkSms) {
                      if (isNewContact) {
                        final colors = ['#3525CD', '#6366F1', '#4F46E5', '#10B981', '#F59E0B', '#EF4444', '#EC4899', '#8B5CF6'];
                        final avatarColor = (colors..shuffle()).first;

                        finalContactId = await db.insert('contacts', {
                          'display_name': newContactName.trim(),
                          'phone_number': newPhoneController.text.trim(),
                          'avatar_color': avatarColor,
                          'last_sync_time': DateTime.now().millisecondsSinceEpoch,
                        });
                      } else {
                        finalContactId = selectedContact!['id'] as int;
                      }
                    }

                    if (selectedType == 'note') {
                      if (noteController.text.trim().isEmpty) return;
                      final text = noteController.text.trim();
                      await db.insert('timeline', {
                        'contact_id': finalContactId,
                        'type': 'note',
                        'timestamp': DateTime.now().millisecondsSinceEpoch,
                        'content': text,
                      });

                      // Auto-extract task if keyword present
                      if (text.toLowerCase().contains('#promise') || text.toLowerCase().contains('promised') || text.toLowerCase().contains('#task')) {
                        final title = text
                            .replaceAll(RegExp(r'#promise', caseSensitive: false), '')
                            .replaceAll(RegExp(r'#task', caseSensitive: false), '')
                            .trim();
                        await db.insert('tasks', {
                          'contact_id': finalContactId,
                          'title': title.length > 50 ? title.substring(0, 50) + '...' : title,
                          'due_date': DateTime.now().add(const Duration(days: 2)).millisecondsSinceEpoch,
                          'is_completed': 0,
                          'reminder_time': null,
                        });
                      }
                    } else if (selectedType == 'payment') {
                      final amt = double.tryParse(paymentAmtController.text) ?? 0.0;
                      if (amt <= 0) return;
                      final rawDesc = paymentDescController.text.trim();
                      final prefix = '[$selectedPaymentStatus] ';
                      final fullContent = rawDesc.isNotEmpty ? '$prefix$rawDesc' : '${prefix}Logged payment';
                      await db.insert('timeline', {
                        'contact_id': finalContactId,
                        'type': 'payment',
                        'timestamp': DateTime.now().millisecondsSinceEpoch,
                        'content': fullContent,
                        'amount': amt,
                      });
                    } else if (selectedType == 'promise') {
                      if (promiseTitleController.text.trim().isEmpty) return;
                      await db.insert('tasks', {
                        'contact_id': finalContactId,
                        'title': promiseTitleController.text.trim(),
                        'due_date': promiseDueDate.millisecondsSinceEpoch,
                        'is_completed': 0,
                        'reminder_time': promiseReminderTime?.millisecondsSinceEpoch,
                      });
                      
                      String content = 'Task Created: "${promiseTitleController.text.trim()}" (Due ${DateFormat('yMMMd').format(promiseDueDate)})';
                      if (promiseReminderTime != null) {
                        content += '\nReminder set for ${DateFormat('yMMMd').add_jm().format(promiseReminderTime!)}';
                      }

                      await db.insert('timeline', {
                        'contact_id': finalContactId,
                        'type': 'promise', // UPGRADED from 'note'
                        'timestamp': DateTime.now().millisecondsSinceEpoch,
                        'content': content,
                      });
                    } else if (selectedType == 'sms') {
                      if (smsController.text.trim().isEmpty) return;

                      if (isBulkSms) {
                        final listId = selectedSmsListId!;
                        String listName = "";
                        if (listId == -1) {
                          listName = 'Starred Contacts';
                        } else {
                          final listMap = widget.contactLists.firstWhere((element) => element['id'] == listId);
                          listName = listMap['name'] as String;
                        }
                        List<int> memberIds = [];

                        if (listId == -1) {
                          // Starred Contacts
                          memberIds = widget.starredContacts.map((c) => c['id'] as int).toList();
                        } else {
                          // Custom contact list
                          final membersList = await DatabaseHelper.instance.getContactsInList(listId);
                          memberIds = membersList.map((c) => c['id'] as int).toList();
                        }

                        if (memberIds.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('The list "$listName" currently has 0 contacts.'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                          return;
                        }

                        await DatabaseHelper.instance.createBulkSmsJob(
                          listName,
                          smsController.text.trim(),
                          smsScheduledTime.millisecondsSinceEpoch,
                          memberIds,
                        );
                      } else {
                        final phone = isNewContact
                            ? newPhoneController.text.trim()
                            : selectedContact!['phone_number'];

                        await db.insert('scheduled_sms', {
                          'contact_id': finalContactId,
                          'phone_number': phone,
                          'message': smsController.text.trim(),
                          'scheduled_time': smsScheduledTime.millisecondsSinceEpoch,
                          'is_sent': 0,
                        });

                        await db.insert('timeline', {
                          'contact_id': finalContactId,
                          'type': 'sms_scheduled', // UPGRADED from 'note'
                          'timestamp': DateTime.now().millisecondsSinceEpoch,
                          'content': 'Outbound SMS Scheduled: "${smsController.text.trim()}" at ${DateFormat('jm').format(smsScheduledTime)}',
                        });
                      }
                    } else if (selectedType == 'attachment') {
                      String fName = attachFilenameController.text.trim();
                      if (fName.isEmpty) fName = 'document.pdf';
                      final desc = attachDescController.text.trim().isNotEmpty
                          ? attachDescController.text.trim()
                          : 'Attached manual media';

                      String finalType = 'attachment';
                      final ext = fName.split('.').last.toLowerCase();
                      if (['png', 'jpg', 'jpeg', 'gif', 'webp', 'bmp'].contains(ext)) {
                        finalType = 'screenshot';
                      }

                      String replicatedPath = '';
                      if (pickedPath != null) {
                        replicatedPath = await DatabaseHelper.instance.replicateAttachment(pickedPath);
                      } else {
                        replicatedPath = '/mock_storage/pocket_crm/$fName';
                      }

                      await db.insert('timeline', {
                        'contact_id': finalContactId,
                        'type': finalType,
                        'timestamp': DateTime.now().millisecondsSinceEpoch,
                        'content': '$desc\nFile: $fName',
                        'attachment_path': replicatedPath,
                      });
                    }

                    if (context.mounted) {
                      Navigator.pop(context);
                      widget.onEventLogged();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Event successfully logged!'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Color(0xFF10B981),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3525CD),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('Log Event', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip({
    required String status,
    required Color color,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.06),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 6),
            Text(
              status,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



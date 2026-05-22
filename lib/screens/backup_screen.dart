import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import '../database_helper.dart';
import '../sync_engine.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({Key? key}) : super(key: key);

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  // Selective export/import filters
  bool _exportContacts = true;
  bool _exportTimeline = true;
  bool _exportTasks = true;
  bool _exportScheduled = true;

  bool _isMergeStrategy = true; // true = Merge, false = Overwrite (Wipe)
  
  final TextEditingController _importJsonController = TextEditingController();
  bool _isWorking = false;
  String _statusMessage = "";
  String _backupPath = "";

  @override
  void initState() {
    super.initState();
    _checkBackupDirectory();
  }

  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      final downloadDir = Directory('/storage/emulated/0/Download');
      if (await downloadDir.exists()) {
        try {
          // Perform a fast write test to verify scoped storage accessibility
          final testFile = File('${downloadDir.path}/.pocket_crm_test');
          await testFile.writeAsString('test');
          await testFile.delete();
          return downloadDir;
        } catch (_) {
          // scoped storage write failed, fallback
        }
      }
      
      try {
        final status = await Permission.storage.request();
        if (status.isGranted && await downloadDir.exists()) {
          return downloadDir;
        }
      } catch (_) {}

      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        return externalDir;
      }
    } else if (Platform.isWindows) {
      final downloads = await getDownloadsDirectory();
      if (downloads != null) {
        return downloads;
      }
      final userProfile = Platform.environment['USERPROFILE'];
      if (userProfile != null) {
        final downloadDir = Directory('$userProfile\\Downloads');
        if (await downloadDir.exists()) {
          return downloadDir;
        }
      }
    } else {
      final downloads = await getDownloadsDirectory();
      if (downloads != null) {
        return downloads;
      }
    }
    return await getApplicationDocumentsDirectory();
  }

  Future<void> _checkBackupDirectory() async {
    final directory = await _getDownloadDirectory();
    setState(() {
      _backupPath = "${directory.path}/pocket_crm_backup.json";
    });
  }

  // Export tables to JSON file
  Future<void> _exportData({bool useFilePicker = false}) async {
    setState(() {
      _isWorking = true;
      _statusMessage = "Exporting tables...";
    });

    try {
      final db = await DatabaseHelper.instance.database;
      final Map<String, dynamic> backupData = {
        'version': 1,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      if (_exportContacts) {
        final contacts = await db.query('contacts');
        backupData['contacts'] = contacts;
      }
      if (_exportTimeline) {
        final timeline = await db.query('timeline');
        backupData['timeline'] = timeline;
      }
      if (_exportTasks) {
        final tasks = await db.query('tasks');
        backupData['tasks'] = tasks;
      }
      if (_exportScheduled) {
        final scheduled = await db.query('scheduled_sms');
        backupData['scheduled_sms'] = scheduled;
      }

      final jsonStr = jsonEncode(backupData);
      
      String targetPath = "";
      bool isCustomFolder = false;

      if (useFilePicker) {
        setState(() {
          _statusMessage = "Select destination folder using File Picker...";
        });
        final selectedDirectory = await FilePicker.platform.getDirectoryPath();
        if (selectedDirectory == null) {
          // User cancelled the directory picker
          setState(() {
            _statusMessage = "Export cancelled. No folder was selected.";
          });
          return;
        }
        targetPath = "$selectedDirectory/pocket_crm_backup.json";
        isCustomFolder = true;
      } else {
        // Save to local file in Download folder
        final directory = await _getDownloadDirectory();
        targetPath = "${directory.path}/pocket_crm_backup.json";
      }

      setState(() {
        _backupPath = targetPath;
      });
      
      final file = File(targetPath);
      await file.writeAsString(jsonStr);

      final bool isPublicDownload = !isCustomFolder && 
          (targetPath.contains('/Download') || targetPath.toLowerCase().contains('download'));

      setState(() {
        _statusMessage = isCustomFolder
            ? "Backup file exported successfully to custom location!\nLocation: $_backupPath"
            : (isPublicDownload
                ? "Backup file exported successfully to your shared Downloads folder!\nLocation: $_backupPath"
                : "Backup file exported successfully!\nLocation: $_backupPath");
      });

      // Show dialog with option to copy raw JSON (highly convenient for emulator debugging)
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Export Completed', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF3525CD))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isCustomFolder ? 'Backup written to custom folder:' : 'Backup written to local file system:', style: GoogleFonts.inter(fontSize: 13)),
              const SizedBox(height: 8),
              SelectableText(
                _backupPath,
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey),
              ),
              const SizedBox(height: 16),
              Text('You can also copy the raw JSON string to migrate devices manually:', style: GoogleFonts.inter(fontSize: 13)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: jsonStr));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Raw JSON copied to clipboard!')),
                );
              },
              child: const Text('Copy JSON String'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _statusMessage = "Export failed: ${e.toString()}";
      });
    } finally {
      setState(() => _isWorking = false);
    }
  }

  // Import tables from JSON string
  Future<void> _importData() async {
    final rawText = _importJsonController.text.trim();
    if (rawText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please paste a valid JSON string or read from backup file.')),
      );
      return;
    }

    setState(() {
      _isWorking = true;
      _statusMessage = "Validating backup payload...";
    });

    try {
      final Map<String, dynamic> backupData = jsonDecode(rawText);
      final db = await DatabaseHelper.instance.database;

      int contactsImported = 0;
      int timelineImported = 0;
      int tasksImported = 0;
      int scheduledImported = 0;

      if (_isMergeStrategy) {
        // --- MERGE STRATEGY (Non-destructive) ---
        _statusMessage = "Executing Merge conflict resolution strategy...";
        
        // Map from old contact ID (in backup) to resolved SQLite ID
        final Map<int, int> oldToNewContactIdMap = {};

        // 1. Process contacts
        if (backupData.containsKey('contacts') && _exportContacts) {
          final List<dynamic> contactsList = backupData['contacts'];
          
          for (var item in contactsList) {
            final contact = item as Map<String, dynamic>;
            final oldId = contact['id'] as int;
            final rawPhone = contact['phone_number'] ?? '';
            final normalized = SyncEngine.normalizePhone(rawPhone);

            // Check if phone number already exists in SQLite
            final existing = await db.query(
              'contacts',
              where: 'phone_number = ?',
              whereArgs: [normalized],
            );

            if (existing.isNotEmpty) {
              // Contact exists! Update manual enrichments if missing in SQLite but present in backup
              final existingContact = existing.first;
              final existingId = existingContact['id'] as int;
              oldToNewContactIdMap[oldId] = existingId;

              // Merge fields if existing is empty
              final updates = <String, dynamic>{};
              if ((existingContact['facebook_url'] ?? '').toString().isEmpty && (contact['facebook_url'] ?? '').toString().isNotEmpty) {
                updates['facebook_url'] = contact['facebook_url'];
              }
              if ((existingContact['linkedin_url'] ?? '').toString().isEmpty && (contact['linkedin_url'] ?? '').toString().isNotEmpty) {
                updates['linkedin_url'] = contact['linkedin_url'];
              }
              if ((existingContact['gmail_address'] ?? '').toString().isEmpty && (contact['gmail_address'] ?? '').toString().isNotEmpty) {
                updates['gmail_address'] = contact['gmail_address'];
              }
              if ((existingContact['pinned_note'] ?? '').toString().isEmpty && (contact['pinned_note'] ?? '').toString().isNotEmpty) {
                updates['pinned_note'] = contact['pinned_note'];
              }
              // If starred in backup, make it starred here
              if (existingContact['is_starred'] == 0 && contact['is_starred'] == 1) {
                updates['is_starred'] = 1;
              }

              if (updates.isNotEmpty) {
                await db.update('contacts', updates, where: 'id = ?', whereArgs: [existingId]);
              }
            } else {
              // New contact! Insert it and let SQLite assign a new auto-incremented ID
              final insertedId = await db.insert('contacts', {
                'phone_number': normalized,
                'display_name': contact['display_name'] ?? 'Imported Contact',
                'avatar_color': contact['avatar_color'] ?? SyncEngine.getRandomIndigoColor(),
                'is_starred': contact['is_starred'] ?? 0,
                'facebook_url': contact['facebook_url'] ?? '',
                'linkedin_url': contact['linkedin_url'] ?? '',
                'gmail_address': contact['gmail_address'] ?? '',
                'pinned_note': contact['pinned_note'] ?? '',
                'last_sync_time': contact['last_sync_time'] ?? 0,
              });
              oldToNewContactIdMap[oldId] = insertedId;
              contactsImported++;
            }
          }
        }

        // 2. Process timeline (chronological events)
        if (backupData.containsKey('timeline') && _exportTimeline) {
          final List<dynamic> timelineList = backupData['timeline'];
          
          await db.transaction((txn) async {
            for (var item in timelineList) {
              final event = item as Map<String, dynamic>;
              final oldContactId = event['contact_id'] as int?;
              
              if (oldContactId == null || !oldToNewContactIdMap.containsKey(oldContactId)) continue;
              final newContactId = oldToNewContactIdMap[oldContactId]!;

              // Avoid duplicates: check if this event exists
              // We check by native SMS message ID, or contact_id + type + timestamp
              final nativeId = event['native_message_id'] as String?;
              List<Map<String, dynamic>> check = [];
              
              if (nativeId != null && nativeId.isNotEmpty) {
                check = await txn.query(
                  'timeline',
                  where: 'native_message_id = ?',
                  whereArgs: [nativeId],
                );
              } else {
                check = await txn.query(
                  'timeline',
                  where: 'contact_id = ? AND type = ? AND timestamp = ?',
                  whereArgs: [newContactId, event['type'], event['timestamp']],
                );
              }

              if (check.isEmpty) {
                await txn.insert('timeline', {
                  'contact_id': newContactId,
                  'type': event['type'] ?? 'note',
                  'timestamp': event['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
                  'content': event['content'] ?? '',
                  'amount': event['amount'],
                  'attachment_path': event['attachment_path'],
                  'native_message_id': nativeId,
                  'is_pinned': event['is_pinned'] ?? 0,
                });
                timelineImported++;
              }
            }
          });
        }

        // 3. Process tasks (promises)
        if (backupData.containsKey('tasks') && _exportTasks) {
          final List<dynamic> tasksList = backupData['tasks'];
          
          await db.transaction((txn) async {
            for (var item in tasksList) {
              final task = item as Map<String, dynamic>;
              final oldContactId = task['contact_id'] as int?;
              
              if (oldContactId == null || !oldToNewContactIdMap.containsKey(oldContactId)) continue;
              final newContactId = oldToNewContactIdMap[oldContactId]!;

              // Avoid duplicate tasks (match title + contact_id + due_date)
              final check = await txn.query(
                'tasks',
                where: 'contact_id = ? AND title = ? AND due_date = ?',
                whereArgs: [newContactId, task['title'], task['due_date']],
              );

              if (check.isEmpty) {
                await txn.insert('tasks', {
                  'contact_id': newContactId,
                  'title': task['title'] ?? '',
                  'due_date': task['due_date'] ?? DateTime.now().millisecondsSinceEpoch,
                  'is_completed': task['is_completed'] ?? 0,
                });
                tasksImported++;
              }
            }
          });
        }

        // 4. Process scheduled outbound SMS
        if (backupData.containsKey('scheduled_sms') && _exportScheduled) {
          final List<dynamic> scheduledList = backupData['scheduled_sms'];
          
          await db.transaction((txn) async {
            for (var item in scheduledList) {
              final sms = item as Map<String, dynamic>;
              final oldContactId = sms['contact_id'] as int?;
              
              if (oldContactId == null || !oldToNewContactIdMap.containsKey(oldContactId)) continue;
              final newContactId = oldToNewContactIdMap[oldContactId]!;

              final check = await txn.query(
                'scheduled_sms',
                where: 'contact_id = ? AND message = ? AND scheduled_time = ?',
                whereArgs: [newContactId, sms['message'], sms['scheduled_time']],
              );

              if (check.isEmpty) {
                await txn.insert('scheduled_sms', {
                  'contact_id': newContactId,
                  'phone_number': sms['phone_number'] ?? '',
                  'message': sms['message'] ?? '',
                  'scheduled_time': sms['scheduled_time'] ?? DateTime.now().millisecondsSinceEpoch,
                  'is_sent': sms['is_sent'] ?? 0,
                });
                scheduledImported++;
              }
            }
          });
        }

      } else {
        // --- OVERWRITE STRATEGY (Wipe everything) ---
        _statusMessage = "Executing Overwrite strategy: Wiping local tables...";
        await DatabaseHelper.instance.clearAllTables();

        // 1. Insert contacts
        if (backupData.containsKey('contacts') && _exportContacts) {
          final List<dynamic> contactsList = backupData['contacts'];
          for (var item in contactsList) {
            final contact = item as Map<String, dynamic>;
            await db.insert('contacts', contact);
            contactsImported++;
          }
        }

        // 2. Insert timeline
        if (backupData.containsKey('timeline') && _exportTimeline) {
          final List<dynamic> timelineList = backupData['timeline'];
          for (var item in timelineList) {
            final event = item as Map<String, dynamic>;
            await db.insert('timeline', event);
            timelineImported++;
          }
        }

        // 3. Insert tasks
        if (backupData.containsKey('tasks') && _exportTasks) {
          final List<dynamic> tasksList = backupData['tasks'];
          for (var item in tasksList) {
            final task = item as Map<String, dynamic>;
            await db.insert('tasks', task);
            tasksImported++;
          }
        }

        // 4. Insert scheduled sms
        if (backupData.containsKey('scheduled_sms') && _exportScheduled) {
          final List<dynamic> scheduledList = backupData['scheduled_sms'];
          for (var item in scheduledList) {
            final sms = item as Map<String, dynamic>;
            await db.insert('scheduled_sms', sms);
            scheduledImported++;
          }
        }
      }

      setState(() {
        _importJsonController.clear();
        _statusMessage = "Import Completed Successfully!\n"
            "• Synced $contactsImported contacts\n"
            "• Synced $timelineImported interaction logs\n"
            "• Synced $tasksImported relationship tasks\n"
            "• Synced $scheduledImported scheduled SMS";
      });
    } catch (e) {
      setState(() {
        _statusMessage = "Import failed: ${e.toString()}";
      });
    } finally {
      setState(() => _isWorking = false);
    }
  }

  // Load from local file and populate text field
  Future<void> _readBackupFile({bool useFilePicker = false}) async {
    String fileToReadPath = "";

    if (useFilePicker) {
      setState(() {
        _isWorking = true;
        _statusMessage = "Select backup JSON file...";
      });
      try {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['json'],
        );
        if (result == null || result.files.single.path == null) {
          setState(() {
            _statusMessage = "Import cancelled. No backup file was selected.";
          });
          return;
        }
        fileToReadPath = result.files.single.path!;
      } catch (e) {
        setState(() {
          _statusMessage = "File selection failed: ${e.toString()}";
        });
        return;
      } finally {
        setState(() => _isWorking = false);
      }
    } else {
      fileToReadPath = _backupPath;
    }

    final file = File(fileToReadPath);
    if (!await file.exists()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No backup file found at: $fileToReadPath')),
      );
      return;
    }

    setState(() {
      _isWorking = true;
      _statusMessage = "Reading JSON backup file...";
    });

    try {
      final jsonStr = await file.readAsString();
      setState(() {
        _importJsonController.text = jsonStr;
        _statusMessage = "JSON loaded from: $fileToReadPath\nPress 'Run Selective Import' below to apply.";
      });
    } catch (e) {
      setState(() {
        _statusMessage = "Read failed: ${e.toString()}";
      });
    } finally {
      setState(() => _isWorking = false);
    }
  }

  void _showExportOptionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Choose Export Destination',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select where you want to save the backup package.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Option 1: Default Downloads Folder
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    _exportData(useFilePicker: false);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.download,
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
                                'Default Downloads Folder',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Automatically save in system Downloads directory',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Option 2: Choose Custom Location
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    _exportData(useFilePicker: true);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.folder_open,
                            color: Color(0xFF16A34A),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Choose Custom Location...',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Select a folder using the native file selector',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showImportOptionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Load Backup File',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose how you want to load the JSON backup file.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Option 1: Load Default Backup
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    _readBackupFile(useFilePicker: false);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.history,
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
                                'Load Default Location',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Read pocket_crm_backup.json from Downloads',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Option 2: Choose Custom File
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    _readBackupFile(useFilePicker: true);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.file_open,
                            color: Color(0xFFEA580C),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select Custom Backup File...',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Pick any backup .json file using file picker',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF3525CD);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3525CD)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Migration Console',
          style: GoogleFonts.outfit(
            color: const Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: SafeArea(
        child: _isWorking
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Color(0xFF3525CD)),
                    const SizedBox(height: 16),
                    Text(
                      _statusMessage,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF4B5563)),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 100.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Checklist of tables
                    Text(
                      'Selective Data Migration',
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937)),
                    ),
                    const SizedBox(height: 8),
                    Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      children: [
                        CheckboxListTile(
                          activeColor: primaryColor,
                          title: Text('Contacts & Social Profiles', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                          value: _exportContacts,
                          onChanged: (val) => setState(() => _exportContacts = val ?? true),
                        ),
                        CheckboxListTile(
                          activeColor: primaryColor,
                          title: Text('Relationship Timelines & Payments', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                          value: _exportTimeline,
                          onChanged: (val) => setState(() => _exportTimeline = val ?? true),
                        ),
                        CheckboxListTile(
                          activeColor: primaryColor,
                          title: Text('Tasks & Deadlines', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                          value: _exportTasks,
                          onChanged: (val) => setState(() => _exportTasks = val ?? true),
                        ),
                        CheckboxListTile(
                          activeColor: primaryColor,
                          title: Text('Scheduled Outbound Queues', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                          value: _exportScheduled,
                          onChanged: (val) => setState(() => _exportScheduled = val ?? true),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Export Panel
                  Text(
                    'Database Export',
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Export selective SQLite tables into a standardized JSON package.',
                          style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF4B5563)),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _showExportOptionsSheet,
                            icon: const Icon(Icons.download, color: Colors.white),
                            label: const Text('Export JSON Backup File'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Import Panel
                  Text(
                    'Database Import & Sync',
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Strategy Selection
                        Text(
                          'Conflict Resolution Strategy:',
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF374151)),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<bool>(
                                activeColor: primaryColor,
                                contentPadding: EdgeInsets.zero,
                                title: Text('Merge', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold)),
                                subtitle: Text('Preserves data, avoids duplicates', style: GoogleFonts.inter(fontSize: 11)),
                                value: true,
                                groupValue: _isMergeStrategy,
                                onChanged: (val) => setState(() => _isMergeStrategy = val ?? true),
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<bool>(
                                activeColor: primaryColor,
                                contentPadding: EdgeInsets.zero,
                                title: Text('Overwrite', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                                subtitle: Text('Wipes database, clean load', style: GoogleFonts.inter(fontSize: 11)),
                                value: false,
                                groupValue: _isMergeStrategy,
                                onChanged: (val) => setState(() => _isMergeStrategy = val ?? false),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        
                        // Import Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _showImportOptionsSheet,
                                icon: const Icon(Icons.folder_open),
                                label: const Text('Read Backup File'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: primaryColor,
                                  side: BorderSide(color: primaryColor),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Raw JSON Paste
                        TextField(
                          controller: _importJsonController,
                          maxLines: 6,
                          style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                          decoration: const InputDecoration(
                            hintText: 'Or paste raw JSON backup payload here...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _importData,
                            icon: const Icon(Icons.upload, color: Colors.white),
                            label: const Text('Run Selective Import'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Result display status message
                  if (_statusMessage.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blueGrey.withOpacity(0.2)),
                      ),
                      child: Text(
                        _statusMessage,
                        style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF374151), height: 1.4),
                      ),
                    ),
                  ],
                ],
              ),
            ),
      ),
    );
  }
}

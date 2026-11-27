// legacy: deleted in spec 10
// ignore_for_file: deprecated_member_use, prefer_const_constructors, prefer_final_locals, unawaited_futures, use_build_context_synchronously, use_super_parameters, prefer_const_literals_to_create_immutables, avoid_print, unnecessary_brace_in_string_interps, prefer_interpolation_to_compose_strings, unused_local_variable, sized_box_for_whitespace, unnecessary_to_list_in_spreads
import 'dart:async';
import 'dart:io';
import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_filex/open_filex.dart';
import '../database_helper.dart';
import '../sms_processor.dart';
import 'package:file_picker/file_picker.dart';

class ThreadScreen extends StatefulWidget {
  final int contactId;
  const ThreadScreen({Key? key, required this.contactId}) : super(key: key);

  @override
  State<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  Map<String, dynamic> _contact = {};
  List<Map<String, dynamic>> _timeline = [];
  List<Map<String, dynamic>> _activeTasks = [];
  List<Map<String, dynamic>> _scheduledSms = [];
  bool _isLoading = true;
  Timer? _refreshTimer;
  final ScrollController _scrollController = ScrollController();
  bool _isHeaderCollapsed = false;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<String> _selectedCategories = {'Calls', 'SMS', 'Notes', 'Payments', 'Tasks', 'Files'};
  final Map<String, bool> _expandedMonths = {};

  @override
  void initState() {
    super.initState();
    _loadAllContactData(showLoading: true);
    _startAutoRefresh();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final offset = _scrollController.offset;
      if (offset > 40 && !_isHeaderCollapsed) {
        setState(() {
          _isHeaderCollapsed = true;
        });
      } else if (offset <= 40 && _isHeaderCollapsed) {
        setState(() {
          _isHeaderCollapsed = false;
        });
      }
    }
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (mounted) {
        _loadAllContactData(showLoading: false);
        await SmsProcessor.processDueSms(context, () {
          if (mounted) {
            _loadAllContactData(showLoading: false);
          }
        });
      }
    });
  }

  Future<void> _loadAllContactData({bool showLoading = false}) async {
    if (showLoading || _contact.isEmpty) {
      setState(() => _isLoading = true);
    }
    final db = await DatabaseHelper.instance.database;

    // Load contact info
    final contactRows = await db.query(
      'contacts',
      where: 'id = ?',
      whereArgs: [widget.contactId],
    );
    if (contactRows.isEmpty) return;

    // Load chronological timeline interactions
    final timelineRows = await db.query(
      'timeline',
      where: 'contact_id = ?',
      whereArgs: [widget.contactId],
      orderBy: 'timestamp DESC',
    );

    // Load contact's tasks/promises
    final taskRows = await db.query(
      'tasks',
      where: 'contact_id = ?',
      whereArgs: [widget.contactId],
      orderBy: 'due_date ASC',
    );

    // Load contact's scheduled SMS
    final scheduledSmsRows = await db.query(
      'scheduled_sms',
      where: 'contact_id = ? AND is_sent = 0',
      whereArgs: [widget.contactId],
      orderBy: 'scheduled_time ASC',
    );

    if (mounted) {
      setState(() {
        _contact = contactRows.first;
        _timeline = timelineRows;
        _activeTasks = taskRows;
        _scheduledSms = scheduledSmsRows;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleTaskCompletion(int taskId, int currentVal) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'tasks',
      {'is_completed': currentVal == 0 ? 1 : 0},
      where: 'id = ?',
      whereArgs: [taskId],
    );
    _loadAllContactData();
  }

  Future<void> _deleteTask(int taskId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [taskId]);
    _loadAllContactData();
  }

  Future<void> _deleteScheduledSms(int smsId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('scheduled_sms', where: 'id = ?', whereArgs: [smsId]);
    _loadAllContactData();
  }

  Future<void> _toggleStar() async {
    final db = await DatabaseHelper.instance.database;
    final current = _contact['is_starred'] as int;
    await db.update(
      'contacts',
      {'is_starred': current == 0 ? 1 : 0},
      where: 'id = ?',
      whereArgs: [widget.contactId],
    );
    _loadAllContactData();
  }

  // Launch manual links enriched by user
  Future<void> _launchURL(String type, String value) async {
    if (value.trim().isEmpty) return;
    Uri? uri;
    if (type == 'facebook') {
      final cleaned = value.trim();
      if (cleaned.startsWith('http://') || cleaned.startsWith('https://')) {
        uri = Uri.parse(cleaned);
      } else {
        uri = Uri.parse('https://facebook.com/$cleaned');
      }
    } else if (type == 'linkedin') {
      final cleaned = value.trim();
      if (cleaned.startsWith('http://') || cleaned.startsWith('https://')) {
        uri = Uri.parse(cleaned);
      } else {
        uri = Uri.parse('https://linkedin.com/in/$cleaned');
      }
    } else if (type == 'gmail') {
      final cleaned = value.trim();
      if (cleaned.contains('@')) {
        uri = Uri.parse('mailto:$cleaned');
      } else {
        uri = Uri.parse('mailto:$cleaned@gmail.com');
      }
    } else if (type == 'tel') {
      final cleaned = value.replaceAll(RegExp(r'[^\d+]'), '');
      uri = Uri.parse('tel:$cleaned');
    }

    if (uri != null) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open link: $value ($e)'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _openFile(String path) async {
    if (path.isEmpty) return;
    
    if (path.startsWith('/mock_storage/')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot open mock file: $path'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    try {
      final file = File(path);
      if (!await file.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File does not exist: $path'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      
      final result = await OpenFilex.open(path);
      if (result.type != ResultType.done) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open file: ${result.message}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening file: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _launchWhatsApp(String cleanedPhone) async {
    if (cleanedPhone.isEmpty) return;
    final uri = Uri.parse('https://wa.me/$cleanedPhone');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open WhatsApp: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _launchMessenger(String fbUsername) async {
    if (fbUsername.isEmpty) return;
    final uri = Uri.parse('https://m.me/$fbUsername');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open Messenger: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Open Sliding Bottom Card to edit manual profile details
  void _openEnrichmentDialog() {
    final nameController = TextEditingController(text: _contact['display_name'] ?? '');
    final phoneController = TextEditingController(text: _contact['phone_number'] ?? '');
    final fbController = TextEditingController(text: _contact['facebook_url'] ?? '');
    final liController = TextEditingController(text: _contact['linkedin_url'] ?? '');
    final gmController = TextEditingController(text: _contact['gmail_address'] ?? '');
    final noteController = TextEditingController(text: _contact['pinned_note'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
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
                  'Enrich Profile Data',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3525CD),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Contact Name',
                    prefixIcon: Icon(Icons.person_outline, color: Color(0xFF3525CD)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone_outlined, color: Color(0xFF3525CD)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: fbController,
                  decoration: const InputDecoration(
                    labelText: 'Facebook Username or URL',
                    prefixIcon: Icon(Icons.link, color: Colors.blue),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: liController,
                  decoration: const InputDecoration(
                    labelText: 'LinkedIn Username or URL',
                    prefixIcon: Icon(Icons.link, color: Color(0xFF0A66C2)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: gmController,
                  decoration: const InputDecoration(
                    labelText: 'Gmail Address',
                    prefixIcon: Icon(Icons.email_outlined, color: Colors.redAccent),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Pinned Reminder Note',
                    prefixIcon: Icon(Icons.note_alt_outlined, color: Colors.amber),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final name = nameController.text.trim();
                      if (name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Contact name cannot be empty'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }
                      final db = await DatabaseHelper.instance.database;
                      await db.update(
                        'contacts',
                        {
                          'display_name': name,
                          'phone_number': phoneController.text.trim(),
                          'facebook_url': fbController.text.trim(),
                          'linkedin_url': liController.text.trim(),
                          'gmail_address': gmController.text.trim(),
                          'pinned_note': noteController.text.trim(),
                        },
                        where: 'id = ?',
                        whereArgs: [widget.contactId],
                      );
                      Navigator.pop(context);
                      _loadAllContactData();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3525CD),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Save Enrichments', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Note slide-up bottom sheet
  void _openAddNoteDialog() {
    final noteController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 16,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
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
                'Log Personal Note',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF3525CD),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Type details about meetings or notes. Tip: Use #task to auto-generate a task.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (noteController.text.trim().isEmpty) return;
                    final text = noteController.text.trim();
                    final db = await DatabaseHelper.instance.database;
                    await db.insert('timeline', {
                      'contact_id': widget.contactId,
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
                        'contact_id': widget.contactId,
                        'title': title.length > 50 ? title.substring(0, 50) + '...' : title,
                        'due_date': DateTime.now().add(const Duration(days: 2)).millisecondsSinceEpoch,
                        'is_completed': 0,
                        'reminder_time': null,
                      });
                    }

                    Navigator.pop(context);
                    _loadAllContactData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3525CD),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Log Note', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Payment slide-up bottom sheet
  void _openAddPaymentDialog() {
    final amtController = TextEditingController();
    final descController = TextEditingController();
    String selectedStatus = 'Paid'; // Default status

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 16,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
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
                  'Log Payment (৳)',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3525CD),
                  ),
                ),
                const SizedBox(height: 16),
                // Premium Payment Status Selectors
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
                      isSelected: selectedStatus == 'Paid',
                      onSelected: () => setDialogState(() => selectedStatus = 'Paid'),
                    ),
                    _buildStatusChip(
                      status: 'Received',
                      color: const Color(0xFF0EA5E9),
                      icon: Icons.download_done,
                      isSelected: selectedStatus == 'Received',
                      onSelected: () => setDialogState(() => selectedStatus = 'Received'),
                    ),
                    _buildStatusChip(
                      status: 'Owed to Me',
                      color: const Color(0xFFD97706),
                      icon: Icons.hourglass_empty,
                      isSelected: selectedStatus == 'Owed to Me',
                      onSelected: () => setDialogState(() => selectedStatus = 'Owed to Me'),
                    ),
                    _buildStatusChip(
                      status: 'I owe',
                      color: const Color(0xFFEF4444),
                      icon: Icons.payment,
                      isSelected: selectedStatus == 'I owe',
                      onSelected: () => setDialogState(() => selectedStatus = 'I owe'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amtController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount (৳)',
                    prefixText: '৳ ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description (e.g. AC Repair service fee)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final amt = double.tryParse(amtController.text) ?? 0.0;
                      if (amt <= 0) return;
                      final db = await DatabaseHelper.instance.database;
                      final rawDesc = descController.text.trim();
                      final prefix = '[$selectedStatus] ';
                      final fullContent = rawDesc.isNotEmpty ? '$prefix$rawDesc' : '${prefix}Logged payment';
                      await db.insert('timeline', {
                        'contact_id': widget.contactId,
                        'type': 'payment',
                        'timestamp': DateTime.now().millisecondsSinceEpoch,
                        'content': fullContent,
                        'amount': amt,
                      });
                      Navigator.pop(context);
                      _loadAllContactData();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3525CD),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Log Payment', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openAddTaskDialog() {
    final taskController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    bool setAlarm = false;
    DateTime? reminderTime;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 16,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
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
                  'Schedule Task',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3525CD),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: taskController,
                  decoration: const InputDecoration(
                    labelText: 'Task Title',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Due Date: ${DateFormat('yMMMd').format(selectedDate)}',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF374151)),
                    ),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            selectedDate = picked;
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
                  value: setAlarm,
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
                          setDialogState(() {
                            reminderTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                            setAlarm = true;
                          });
                        } else {
                          setDialogState(() {
                            setAlarm = false;
                          });
                        }
                      } else {
                        setDialogState(() {
                          setAlarm = false;
                        });
                      }
                    } else {
                      setDialogState(() {
                        reminderTime = null;
                        setAlarm = false;
                      });
                    }
                  },
                ),
                if (setAlarm && reminderTime != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        const Icon(Icons.notifications_active, color: Colors.amber, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Reminder: ${DateFormat('yMMMd').add_jm().format(reminderTime!)}',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.amber[800]),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (taskController.text.trim().isEmpty) return;
                      final db = await DatabaseHelper.instance.database;
                      await db.insert('tasks', {
                        'contact_id': widget.contactId,
                        'title': taskController.text.trim(),
                        'due_date': selectedDate.millisecondsSinceEpoch,
                        'is_completed': 0,
                        'reminder_time': reminderTime?.millisecondsSinceEpoch,
                      });
                      
                      String content = 'Task Created: "${taskController.text.trim()}" (Due ${DateFormat('yMMMd').format(selectedDate)})';
                      if (reminderTime != null) {
                        content += '\nReminder set for ${DateFormat('yMMMd').add_jm().format(reminderTime!)}';
                      }

                      await db.insert('timeline', {
                        'contact_id': widget.contactId,
                        'type': 'promise',
                        'timestamp': DateTime.now().millisecondsSinceEpoch,
                        'content': content,
                      });
                      Navigator.pop(context);
                      _loadAllContactData();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3525CD),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Schedule Task', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Schedule SMS slide-up bottom sheet
  void _openScheduleSMSDialog() {
    final smsController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(hours: 1));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 16,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
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
                  'Schedule Outbound SMS',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3525CD),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: smsController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'SMS Message Body',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Send: ${DateFormat('jm').format(selectedDate)}',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF374151)),
                    ),
                    TextButton(
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(selectedDate),
                        );
                        if (time != null) {
                          final now = DateTime.now();
                          setDialogState(() {
                            selectedDate = DateTime(now.year, now.month, now.day, time.hour, time.minute);
                            if (selectedDate.isBefore(now)) {
                              selectedDate = selectedDate.add(const Duration(days: 1));
                            }
                          });
                        }
                      },
                      child: const Text('Set Time', style: TextStyle(color: Color(0xFF3525CD), fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (smsController.text.trim().isEmpty) return;
                      final db = await DatabaseHelper.instance.database;
                      
                      await db.insert('scheduled_sms', {
                        'contact_id': widget.contactId,
                        'phone_number': _contact['phone_number'],
                        'message': smsController.text.trim(),
                        'scheduled_time': selectedDate.millisecondsSinceEpoch,
                        'is_sent': 0,
                      });

                      await db.insert('timeline', {
                        'contact_id': widget.contactId,
                        'type': 'sms_scheduled',
                        'timestamp': DateTime.now().millisecondsSinceEpoch,
                        'content': 'Outbound SMS Scheduled: "${smsController.text.trim()}" at ${DateFormat('jm').format(selectedDate)}',
                      });

                      Navigator.pop(context);
                      _loadAllContactData();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3525CD),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Schedule SMS', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Attach Media slide-up bottom sheet
  void _openAttachMediaDialog() {
    String mediaType = 'attachment'; // 'attachment' or 'screenshot'
    final customNameController = TextEditingController();
    final descController = TextEditingController();
    String? pickedPath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
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
                      'Attach File / Screenshot',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3525CD),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Select Media Type',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF4B5563)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('File/Document'),
                          selected: mediaType == 'attachment',
                          selectedColor: const Color(0xFF3525CD).withOpacity(0.15),
                          onSelected: (selected) {
                            if (selected) {
                              setDialogState(() {
                                mediaType = 'attachment';
                              });
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Screenshot/Image'),
                          selected: mediaType == 'screenshot',
                          selectedColor: const Color(0xFF3525CD).withOpacity(0.15),
                          onSelected: (selected) {
                            if (selected) {
                              setDialogState(() {
                                mediaType = 'screenshot';
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: customNameController,
                            decoration: const InputDecoration(
                                labelText: 'File Name / Picked File',
                                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                                hintText: 'Enter name of your file with extension',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 58,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final result = await FilePicker.pickFiles(
                                type: mediaType == 'screenshot' ? FileType.image : FileType.any,
                              );
                              if (result.isNotEmpty && result.single.path != null) {
                                final file = result.single;
                                setDialogState(() {
                                  pickedPath = file.path;
                                  customNameController.text = file.name;
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
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: 'Short Description / Context',
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                        hintText: 'e.g. Final signed contract copy...',
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          String fileName = customNameController.text.trim();
                          if (fileName.isEmpty) {
                            fileName = mediaType == 'screenshot' ? 'screenshot.png' : 'document.dat';
                          }
                          
                          final desc = descController.text.trim().isNotEmpty
                              ? descController.text.trim()
                              : 'Attached manual media';

                          String replicatedPath = '';
                          if (pickedPath != null) {
                            replicatedPath = await DatabaseHelper.instance.replicateAttachment(pickedPath);
                          } else {
                            replicatedPath = '/mock_storage/pocket_crm/$fileName';
                          }

                          final db = await DatabaseHelper.instance.database;
                          await db.insert('timeline', {
                            'contact_id': widget.contactId,
                            'type': mediaType, // 'attachment' or 'screenshot'
                            'timestamp': DateTime.now().millisecondsSinceEpoch,
                            'content': '$desc\nFile: $fileName',
                            'attachment_path': replicatedPath,
                          });

                          Navigator.pop(context);
                          _loadAllContactData();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3525CD),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Attach Media', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _togglePinEvent(int eventId, int currentPin) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'timeline',
      {'is_pinned': currentPin == 1 ? 0 : 1},
      where: 'id = ?',
      whereArgs: [eventId],
    );
    _loadAllContactData();
  }

  List<dynamic> _buildFlatTimelineList() {
    final List<dynamic> flatList = [];

    // Filter by category first
    final filteredByCategory = _timeline.where((event) {
      final type = event['type'] ?? 'note';
      if (type == 'call_incoming' || type == 'call_outgoing' || type == 'call_missed') {
        return _selectedCategories.contains('Calls');
      }
      if (type == 'sms_incoming' || type == 'sms_outgoing' || type == 'sms_scheduled') {
        return _selectedCategories.contains('SMS');
      }
      if (type == 'note') {
        return _selectedCategories.contains('Notes');
      }
      if (type == 'payment') {
        return _selectedCategories.contains('Payments');
      }
      if (type == 'promise') {
        return _selectedCategories.contains('Tasks');
      }
      if (type == 'screenshot' || type == 'attachment') {
        return _selectedCategories.contains('Files');
      }
      return true;
    }).toList();

    // Filter by search query
    final filtered = filteredByCategory.where((event) {
      if (_searchQuery.isEmpty) return true;
      final content = (event['content'] ?? '').toString().toLowerCase();
      final typeLabel = _getTimelineLabel(event['type'] ?? '').toLowerCase();
      final amount = event['amount'] != null ? '৳ ${event['amount']}' : '';
      return content.contains(_searchQuery.toLowerCase()) || 
             typeLabel.contains(_searchQuery.toLowerCase()) ||
             amount.contains(_searchQuery.toLowerCase());
    }).toList();

    // Split into pinned and regular
    final pinnedList = filtered.where((event) => (event['is_pinned'] ?? 0) == 1).toList();
    final regularList = filtered.where((event) => (event['is_pinned'] ?? 0) == 0).toList();

    // 1. Pinned Section
    if (pinnedList.isNotEmpty) {
      flatList.add(TimelineSectionHeader('📌 Pinned Interactions'));
      flatList.addAll(pinnedList);
    }

    // 2. Regular Section grouped by month
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var event in regularList) {
      final timestamp = event['timestamp'] as int;
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final monthKey = DateFormat('MMMM yyyy').format(date);
      grouped.putIfAbsent(monthKey, () => []).add(event);
    }

    if (grouped.isNotEmpty) {
      // If _expandedMonths is completely empty, default expand the latest (first) month
      if (_expandedMonths.isEmpty) {
        _expandedMonths[grouped.keys.first] = true;
      }

      for (var monthKey in grouped.keys) {
        final events = grouped[monthKey]!;
        flatList.add(TimelineMonthHeader(monthKey, events.length));
        if (_expandedMonths[monthKey] == true) {
          flatList.addAll(events);
        }
      }
    }

    return flatList;
  }

  Widget _buildControls() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: _isHeaderCollapsed ? 6 : 12,
      ),
      child: Column(
        children: [
          // Search box
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: _isHeaderCollapsed ? 30 : 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(_isHeaderCollapsed ? 15 : 19),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: _isHeaderCollapsed ? 10 : 12,
                    right: _isHeaderCollapsed ? 6 : 8,
                  ),
                  child: Icon(
                    Icons.search,
                    size: _isHeaderCollapsed ? 16 : 18,
                    color: Colors.grey[500],
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.trim();
                      });
                    },
                    textAlignVertical: TextAlignVertical.center,
                    style: GoogleFonts.inter(
                      fontSize: _isHeaderCollapsed ? 13 : 14,
                      color: const Color(0xFF1F2937),
                    ),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      hintText: 'Search interactions...',
                      hintStyle: GoogleFonts.inter(
                        color: Colors.grey[500],
                        fontSize: _isHeaderCollapsed ? 12 : 13,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: _isHeaderCollapsed ? 6 : 8,
                        right: _isHeaderCollapsed ? 10 : 12,
                      ),
                      child: Icon(
                        Icons.clear,
                        size: _isHeaderCollapsed ? 16 : 18,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Category chips (Collapsible on scroll)
          AnimatedCrossFade(
            firstChild: Column(
              children: [
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('📞 Calls', 'Calls'),
                      const SizedBox(width: 6),
                      _buildFilterChip('💬 SMS', 'SMS'),
                      const SizedBox(width: 6),
                      _buildFilterChip('📝 Notes', 'Notes'),
                      const SizedBox(width: 6),
                      _buildFilterChip('৳ Payments', 'Payments'),
                      const SizedBox(width: 6),
                      _buildFilterChip('📋 Tasks', 'Tasks'),
                      const SizedBox(width: 6),
                      _buildFilterChip('📁 Files', 'Files'),
                    ],
                  ),
                ),
              ],
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: _isHeaderCollapsed
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String category) {
    final isSelected = _selectedCategories.contains(category);
    return ChoiceChip(
      label: Text(
        label, 
        style: GoogleFonts.inter(
          fontSize: 12, 
          fontWeight: FontWeight.w600, 
          color: isSelected ? const Color(0xFF3525CD) : Colors.grey[700],
        ),
      ),
      selected: isSelected,
      selectedColor: const Color(0xFF3525CD).withOpacity(0.12),
      backgroundColor: const Color(0xFFF3F4F6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), 
        side: BorderSide(
          color: isSelected ? const Color(0xFF3525CD).withOpacity(0.3) : Colors.transparent,
        ),
      ),
      onSelected: (val) {
        setState(() {
          if (val) {
            _selectedCategories.add(category);
          } else {
            _selectedCategories.remove(category);
          }
        });
      },
    );
  }

  Future<void> _deleteTimelineEvent(int eventId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('timeline', where: 'id = ?', whereArgs: [eventId]);
    _loadAllContactData();
  }

  String _getFileName(String path) {
    if (path.isEmpty) return '';
    return path.replaceAll('\\', '/').split('/').last;
  }

  String _getFileExtension(String path) {
    if (path.isEmpty) return '';
    final name = _getFileName(path);
    if (name.contains('.')) {
      return name.split('.').last.toLowerCase();
    }
    return '';
  }

  bool _isImageFile(String path) {
    final ext = _getFileExtension(path);
    return ['png', 'jpg', 'jpeg', 'gif', 'webp', 'bmp'].contains(ext);
  }

  IconData _getAttachmentIconData(String path) {
    final ext = _getFileExtension(path);
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'zip':
      case 'rar':
      case 'tar':
      case 'gz':
      case '7z':
        return Icons.archive_outlined;
      case 'doc':
      case 'docx':
        return Icons.description_outlined;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart_outlined;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow_outlined;
      case 'mp3':
      case 'wav':
      case 'm4a':
      case 'ogg':
        return Icons.audiotrack_outlined;
      case 'mp4':
      case 'avi':
      case 'mkv':
      case 'mov':
        return Icons.video_file_outlined;
      case 'txt':
      case 'json':
      case 'xml':
      case 'yaml':
        return Icons.article_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  String _getAttachmentTypeLabelText(String path) {
    final ext = _getFileExtension(path);
    if (ext.isEmpty) return 'File Document';
    return '${ext.toUpperCase()} File';
  }

  Widget _buildCollapsedHeader(Color avatarColor) {
    return const SizedBox.shrink();
  }

  Widget _buildExpandedHeader(Color avatarColor) {
    return Container(
      key: const ValueKey('expanded'),
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: avatarColor.withOpacity(0.1),
                child: Text(
                  _contact['display_name'] != null && _contact['display_name'].isNotEmpty
                      ? _contact['display_name'][0].toUpperCase()
                      : '',
                  style: GoogleFonts.outfit(color: avatarColor, fontWeight: FontWeight.bold, fontSize: 26),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _contact['display_name'] ?? '',
                      style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937)),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          _contact['phone_number'] ?? '',
                          style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF4B5563)),
                        ),
                        if ((_contact['phone_number'] ?? '').toString().isNotEmpty) ...[
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => _launchURL('tel', _contact['phone_number'] ?? ''),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.phone,
                                color: Color(0xFF10B981),
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
          
          // Manual Social enrichment list
          const SizedBox(height: 16),
          _buildSocialPanel(),

          // Pinned Note Card
          if ((_contact['pinned_note'] ?? '').toString().trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.push_pin, color: Colors.amber, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _contact['pinned_note'],
                      style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF4B5563), fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF3525CD))),
      );
    }

    final colorHex = _contact['avatar_color'] ?? '#3525CD';
    final intColor = int.tryParse(colorHex.replaceFirst('#', '0xFF')) ?? 0xFF3525CD;
    final avatarColor = Color(intColor);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3525CD)),
          onPressed: () => Navigator.pop(context),
        ),
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _isHeaderCollapsed
              ? Row(
                  key: const ValueKey('appbar_collapsed_title'),
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: avatarColor.withOpacity(0.1),
                      child: Text(
                        _contact['display_name'] != null && _contact['display_name'].isNotEmpty
                            ? _contact['display_name'][0].toUpperCase()
                            : '',
                        style: GoogleFonts.outfit(color: avatarColor, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _contact['display_name'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(color: const Color(0xFF1F2937), fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                )
              : Text(
                  'Relationship Thread',
                  key: const ValueKey('appbar_expanded_title'),
                  style: GoogleFonts.outfit(color: const Color(0xFF1F2937), fontWeight: FontWeight.bold, fontSize: 20),
                ),
        ),
        actions: [
          if (_isHeaderCollapsed) ...[
            if ((_contact['phone_number'] ?? '').toString().isNotEmpty) ...[
              InkWell(
                onTap: () => _launchURL('tel', _contact['phone_number'] ?? ''),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.phone,
                    color: Color(0xFF10B981),
                    size: 14,
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
            InkWell(
              onTap: _toggleStar,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _contact['is_starred'] == 1 ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 14,
                ),
              ),
            ),
            const SizedBox(width: 6),
            InkWell(
              onTap: _openEnrichmentDialog,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF3525CD).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit_note,
                  color: Color(0xFF3525CD),
                  size: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ] else ...[
            IconButton(
              icon: Icon(
                _contact['is_starred'] == 1 ? Icons.star : Icons.star_border,
                color: _contact['is_starred'] == 1 ? Colors.amber : const Color(0xFF3525CD),
              ),
              onPressed: _toggleStar,
            ),
            IconButton(
              icon: const Icon(Icons.edit_note, color: Color(0xFF3525CD)),
              onPressed: _openEnrichmentDialog,
            )
          ]
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
          // Contact profile card (Collapsible)
          AnimatedCrossFade(
            firstChild: _buildExpandedHeader(avatarColor),
            secondChild: _buildCollapsedHeader(avatarColor),
            crossFadeState: _isHeaderCollapsed ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),

          // Active Promises & Scheduled SMS Widget Section
          if (_activeTasks.any((t) => t['is_completed'] == 0) || _scheduledSms.isNotEmpty) ...[
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_activeTasks.any((t) => t['is_completed'] == 0)) ...[
                    Row(
                      children: [
                        const Icon(Icons.task_alt_outlined, color: Color(0xFF3525CD), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Tasks Checklist',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF1F2937)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ..._activeTasks.where((t) => t['is_completed'] == 0).map((task) {
                      final dueDate = DateTime.fromMillisecondsSinceEpoch(task['due_date']);
                      final formattedDue = DateFormat('yMMMd').format(dueDate);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3525CD).withOpacity(0.04),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF3525CD).withOpacity(0.1)),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Checkbox(
                                  value: task['is_completed'] == 1,
                                  activeColor: const Color(0xFF3525CD),
                                  onChanged: (val) {
                                    _toggleTaskCompletion(task['id'], task['is_completed']);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      task['title'],
                                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF374151)),
                                    ),
                                    if (task['reminder_time'] != null && task['reminder_time'] > 0) ...[
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          const Icon(Icons.notifications_active, color: Colors.amber, size: 12),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Alert: ${DateFormat('yMMMd').add_jm().format(DateTime.fromMillisecondsSinceEpoch(task['reminder_time']))}',
                                            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.amber[800]),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Text(
                                'Due: $formattedDue',
                                style: GoogleFonts.inter(fontSize: 10, color: Colors.grey[500]),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => _deleteTask(task['id']),
                                child: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                  if (_scheduledSms.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.sms_outlined, color: Color(0xFF4F46E5), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Scheduled SMS Queue',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF1F2937)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ..._scheduledSms.map((sms) {
                      final scheduledDate = DateTime.fromMillisecondsSinceEpoch(sms['scheduled_time']);
                      final formattedTime = DateFormat('jm').format(scheduledDate);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4F46E5).withOpacity(0.04),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF4F46E5).withOpacity(0.1)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.schedule, size: 14, color: Color(0xFF4F46E5)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  sms['message'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF374151)),
                                ),
                              ),
                              Text(
                                'Send: $formattedTime',
                                style: GoogleFonts.inter(fontSize: 10, color: Colors.grey[500]),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => _deleteScheduledSms(sms['id']),
                                child: const Icon(Icons.cancel_outlined, size: 16, color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1),
          ],

          // Action Logging Toolbelt
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: 8,
              vertical: _isHeaderCollapsed ? 4 : 8,
            ),
            color: const Color(0xFFE5E7EB).withValues(alpha: 0.3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildToolbeltButton('Note', Icons.note_add_outlined, _openAddNoteDialog),
                SizedBox(width: _isHeaderCollapsed ? 12 : 20),
                _buildToolbeltButton('Payment', Icons.payments_outlined, _openAddPaymentDialog),
                SizedBox(width: _isHeaderCollapsed ? 12 : 20),
                _buildToolbeltButton('Task', Icons.task_alt_outlined, _openAddTaskDialog),
                SizedBox(width: _isHeaderCollapsed ? 12 : 20),
                _buildToolbeltButton('Schedule', Icons.sms_outlined, _openScheduleSMSDialog),
                SizedBox(width: _isHeaderCollapsed ? 12 : 20),
                _buildToolbeltButton('Attach', Icons.attach_file, _openAttachMediaDialog),
              ],
            ),
          ),

          // Controls (Search & Filters)
          _buildControls(),

          // Timeline sheet
          Expanded(
            child: () {
              final flatList = _buildFlatTimelineList();
              if (flatList.isEmpty) {
                return _buildEmptyTimeline();
              }
              return ListView.separated(
                controller: _scrollController,
                itemCount: flatList.length,
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
                separatorBuilder: (c, i) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = flatList[index];

                  if (item is TimelineSectionHeader) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 4),
                      child: Text(
                        item.title,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: const Color(0xFF3525CD),
                        ),
                      ),
                    );
                  }

                  if (item is TimelineMonthHeader) {
                    final isExpanded = _expandedMonths[item.monthKey] == true;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _expandedMonths[item.monthKey] = !isExpanded;
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isExpanded ? Icons.calendar_today_outlined : Icons.calendar_today,
                              color: const Color(0xFF3525CD),
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              item.monthKey,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3525CD).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${item.count} events',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF3525CD),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              isExpanded ? Icons.expand_less : Icons.expand_more,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final event = item as Map<String, dynamic>;
                  final type = event['type'] ?? 'note';
                  final timestamp = event['timestamp'] as int;
                  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
                  final timeStr = DateFormat('yMMMd').add_jm().format(date);

                  return Dismissible(
                    key: Key('event_${event['id']}'),
                    background: Container(
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.red),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      _deleteTimelineEvent(event['id']);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: (event['is_pinned'] ?? 0) == 1
                            ? const Color(0xFF3525CD).withOpacity(0.03)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: (event['is_pinned'] ?? 0) == 1
                              ? const Color(0xFF3525CD).withOpacity(0.3)
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _getTimelineIcon(type, content: event['content']),
                              const SizedBox(width: 8),
                              Text(
                                _getTimelineLabel(type, content: event['content']),
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: _getTimelineLabelColor(type, content: event['content']),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                timeStr,
                                style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[500]),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => _togglePinEvent(event['id'], event['is_pinned'] ?? 0),
                                child: Icon(
                                  (event['is_pinned'] ?? 0) == 1 ? Icons.push_pin : Icons.push_pin_outlined,
                                  color: (event['is_pinned'] ?? 0) == 1 ? const Color(0xFF3525CD) : Colors.grey[400],
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Builder(
                            builder: (context) {
                              final isPayment = event['type'] == 'payment';
                              String contentText = event['content'] ?? '';
                              if (isPayment) {
                                final parsed = _parsePaymentContent(contentText);
                                contentText = parsed['content'];
                              }
                              return Text(
                                contentText,
                                style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF374151)),
                              );
                            },
                          ),
                          // Prominent dynamic status badges
                          if (event['amount'] != null) ...[
                            const SizedBox(height: 8),
                            Builder(
                              builder: (context) {
                                final parsed = _parsePaymentContent(event['content'] ?? '');
                                final status = parsed['status'];
                                
                                Color statusColor;
                                IconData statusIcon;
                                
                                switch (status) {
                                  case 'Paid':
                                    statusColor = const Color(0xFF10B981); // Emerald Green
                                    statusIcon = Icons.check_circle_outline;
                                    break;
                                  case 'Received':
                                    statusColor = const Color(0xFF0EA5E9); // Sky Blue
                                    statusIcon = Icons.download_done;
                                    break;
                                  case 'Owed to Me':
                                  case 'To Collect':
                                    statusColor = const Color(0xFFD97706); // Amber/Orange
                                    statusIcon = Icons.hourglass_empty;
                                    break;
                                  case 'I owe':
                                  case 'To Pay':
                                    statusColor = const Color(0xFFEF4444); // Crimson Red
                                    statusIcon = Icons.payment;
                                    break;
                                  default:
                                    statusColor = const Color(0xFF10B981);
                                    statusIcon = Icons.check_circle_outline;
                                }

                                return Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '৳ ${event['amount']}',
                                        style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: statusColor,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.06),
                                        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(statusIcon, size: 14, color: statusColor),
                                          const SizedBox(width: 4),
                                          Text(
                                            status,
                                            style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: statusColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                          // Render Attachments and Screenshots
                          if (event['attachment_path'] != null) ...[
                            const SizedBox(height: 12),
                            if (type == 'screenshot' || _isImageFile(event['attachment_path'] ?? '')) ...[
                              // Beautiful screenshot visual thumbnail card
                              Builder(
                                builder: (context) {
                                  final path = event['attachment_path'] ?? '';
                                  final fileExists = path.isNotEmpty && !path.startsWith('/mock_storage/') && File(path).existsSync();
                                  return GestureDetector(
                                    onTap: () => _openFile(path),
                                    child: Container(
                                      width: double.infinity,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF818CF8), Color(0xFFC084FC)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Stack(
                                          children: [
                                            if (fileExists)
                                              Positioned.fill(
                                                child: Image.file(
                                                  File(path),
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            else
                                              Positioned.fill(
                                                child: Icon(
                                                  Icons.image,
                                                  size: 80,
                                                  color: Colors.white.withValues(alpha: 0.15),
                                                ),
                                              ),
                                            // Gradient overlay to ensure text contrast
                                            Positioned.fill(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.black.withOpacity(0.0),
                                                      Colors.black.withOpacity(0.55),
                                                    ],
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              left: 16,
                                              bottom: 16,
                                              right: 16,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.photo_library, color: Colors.white, size: 16),
                                                      const SizedBox(width: 6),
                                                      Expanded(
                                                        child: Text(
                                                          _getFileName(path),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: GoogleFonts.outfit(
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'Tap to preview image/screenshot',
                                                    style: GoogleFonts.inter(
                                                      color: Colors.white.withValues(alpha: 0.8),
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Positioned(
                                              top: 16,
                                              right: 16,
                                              child: CircleAvatar(
                                                radius: 16,
                                                backgroundColor: Colors.black26,
                                                child: Icon(Icons.fullscreen, color: Colors.white, size: 18),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              ),
                            ] else ...[
                              // Beautiful file attachment card
                              GestureDetector(
                                onTap: () => _openFile(event['attachment_path'] ?? ''),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFFE5E7EB)),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF3525CD).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          _getAttachmentIconData(event['attachment_path'] ?? ''),
                                          color: const Color(0xFF3525CD),
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _getFileName(event['attachment_path'] ?? ''),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.inter(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: const Color(0xFF1F2937),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              _getAttachmentTypeLabelText(event['attachment_path'] ?? ''),
                                              style: GoogleFonts.inter(
                                                color: Colors.grey[500],
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.open_in_new, color: Color(0xFF3525CD), size: 20),
                                        onPressed: () => _openFile(event['attachment_path'] ?? ''),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            }(),
          )
        ],
      ),
    ),
  );
}

  Widget _buildToolbeltButton(String label, IconData icon, VoidCallback onTap) {
    Color buttonColor;
    switch (label.toLowerCase()) {
      case 'note':
        buttonColor = const Color(0xFFD97706); // Amber
        break;
      case 'payment':
        buttonColor = const Color(0xFF10B981); // Emerald/Green
        break;
      case 'task':
        buttonColor = const Color(0xFF3525CD); // Indigo
        break;
      case 'schedule':
        buttonColor = const Color(0xFF4F46E5); // Purple/Royal Blue
        break;
      case 'attach':
        buttonColor = const Color(0xFF0EA5E9); // Sky Blue
        break;
      default:
        buttonColor = const Color(0xFF3525CD);
    }

    if (_isHeaderCollapsed) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: buttonColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: buttonColor,
            size: 14,
          ),
        ),
      );
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: buttonColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: buttonColor,
                  size: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF4B5563),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialPanel() {
    final fb = _contact['facebook_url'] as String? ?? '';
    final li = _contact['linkedin_url'] as String? ?? '';
    final gm = _contact['gmail_address'] as String? ?? '';
    final phone = _contact['phone_number'] as String? ?? '';

    // Extract Facebook username for Messenger link
    String getFacebookUsername(String url) {
      final cleaned = url.trim();
      if (cleaned.isEmpty) return '';
      if (cleaned.startsWith('http://') || cleaned.startsWith('https://')) {
        try {
          final uri = Uri.parse(cleaned);
          final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
          if (segments.isNotEmpty) return segments.first;
        } catch (_) {}
      }
      return cleaned;
    }

    final fbUsername = getFacebookUsername(fb);

    if (fb.isEmpty && li.isEmpty && gm.isEmpty && phone.isEmpty) {
      return Container(
        width: double.infinity,
        alignment: Alignment.centerLeft,
        child: Text(
          'No social links enriched yet. Tap edit above to add.',
          style: GoogleFonts.inter(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Call (always generated from phone if phone is present)
            if (phone.isNotEmpty) ...[
              GestureDetector(
                onTap: () => _launchURL('tel', phone),
                child: _buildSocialChip('Call', Icons.phone, const Color(0xFF10B981)),
              ),
              const SizedBox(width: 8),
            ],
            // WhatsApp (always generated from phone if phone is present)
            if (phone.isNotEmpty) ...[
              GestureDetector(
                onTap: () {
                  final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
                  _launchWhatsApp(cleaned);
                },
                child: _buildSocialChip('WhatsApp', Icons.chat_bubble_outline, const Color(0xFF25D366)),
              ),
              const SizedBox(width: 8),
            ],
            // Messenger (generated if Facebook is present)
            if (fb.isNotEmpty && fbUsername.isNotEmpty) ...[
              GestureDetector(
                onTap: () => _launchMessenger(fbUsername),
                child: _buildSocialChip('Messenger', Icons.messenger_outline, const Color(0xFF0078FF)),
              ),
              const SizedBox(width: 8),
            ],
            // Facebook
            if (fb.isNotEmpty) ...[
              GestureDetector(
                onTap: () => _launchURL('facebook', fb),
                child: _buildSocialChip('Facebook', Icons.link, Colors.blue),
              ),
              const SizedBox(width: 8),
            ],
            // LinkedIn
            if (li.isNotEmpty) ...[
              GestureDetector(
                onTap: () => _launchURL('linkedin', li),
                child: _buildSocialChip('LinkedIn', Icons.link, const Color(0xFF0A66C2)),
              ),
              const SizedBox(width: 8),
            ],
            // Gmail
            if (gm.isNotEmpty) ...[
              GestureDetector(
                onTap: () => _launchURL('gmail', gm),
                child: _buildSocialChip('Gmail', Icons.email_outlined, Colors.redAccent),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSocialChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: color),
          )
        ],
      ),
    );
  }

  Map<String, dynamic> _parsePaymentContent(String content) {
    String status = 'Received';
    String cleanContent = content;
    if (content.startsWith('[Paid]')) {
      status = 'Paid';
      cleanContent = content.substring('[Paid]'.length).trim();
    } else if (content.startsWith('[Received]')) {
      status = 'Received';
      cleanContent = content.substring('[Received]'.length).trim();
    } else if (content.startsWith('[To Collect]')) {
      status = 'Owed to Me';
      cleanContent = content.substring('[To Collect]'.length).trim();
    } else if (content.startsWith('[To Pay]')) {
      status = 'I owe';
      cleanContent = content.substring('[To Pay]'.length).trim();
    } else if (content.startsWith('[Owed to Me]')) {
      status = 'Owed to Me';
      cleanContent = content.substring('[Owed to Me]'.length).trim();
    } else if (content.startsWith('[I owe]')) {
      status = 'I owe';
      cleanContent = content.substring('[I owe]'.length).trim();
    } else if (content.startsWith('[I Owe]')) {
      status = 'I owe';
      cleanContent = content.substring('[I Owe]'.length).trim();
    }
    return {
      'status': status,
      'content': cleanContent,
    };
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

  Icon _getTimelineIcon(String type, {String? content}) {
    if (type == 'payment' && content != null) {
      final parsed = _parsePaymentContent(content);
      switch (parsed['status']) {
        case 'Paid':
          return const Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 16);
        case 'Received':
          return const Icon(Icons.download_done, color: Color(0xFF0EA5E9), size: 16);
        case 'Owed to Me':
        case 'To Collect':
          return const Icon(Icons.hourglass_empty, color: Color(0xFFD97706), size: 16);
        case 'I owe':
        case 'To Pay':
          return const Icon(Icons.payment, color: Color(0xFFEF4444), size: 16);
      }
    }
    switch (type) {
      case 'call_incoming':
        return const Icon(Icons.call_received, color: Colors.green, size: 16);
      case 'call_outgoing':
        return const Icon(Icons.call_made, color: Colors.blue, size: 16);
      case 'call_missed':
        return const Icon(Icons.phone_missed, color: Colors.red, size: 16);
      case 'sms_incoming':
        return const Icon(Icons.sms, color: Colors.indigo, size: 16);
      case 'sms_outgoing':
        return const Icon(Icons.send, color: Colors.teal, size: 16);
      case 'note':
        return const Icon(Icons.note_alt, color: Colors.amber, size: 16);
      case 'payment':
        return const Icon(Icons.payments, color: Color(0xFF10B981), size: 16);
      case 'screenshot':
        return const Icon(Icons.screenshot, color: Colors.purple, size: 16);
      case 'attachment':
        return const Icon(Icons.insert_drive_file, color: Colors.blueGrey, size: 16);
      case 'promise':
        return const Icon(Icons.task_alt, color: Color(0xFFD97706), size: 16);
      case 'sms_scheduled':
        return const Icon(Icons.watch_later_outlined, color: Color(0xFF4F46E5), size: 16);
      default:
        return const Icon(Icons.info_outline, color: Colors.grey, size: 16);
    }
  }

  String _getTimelineLabel(String type, {String? content}) {
    if (type == 'payment' && content != null) {
      final parsed = _parsePaymentContent(content);
      return 'Payment: ${parsed['status']}';
    }
    switch (type) {
      case 'call_incoming':
        return 'Incoming Call';
      case 'call_outgoing':
        return 'Outgoing Call';
      case 'call_missed':
        return 'Missed Call';
      case 'sms_incoming':
        return 'SMS Received';
      case 'sms_outgoing':
        return 'SMS Sent';
      case 'note':
        return 'Personal Note';
      case 'payment':
        return 'bKash Transaction';
      case 'screenshot':
        return 'Screenshot Attached';
      case 'attachment':
        return 'File Attached';
      case 'promise':
        return 'Task Scheduled';
      case 'sms_scheduled':
        return 'SMS Scheduled';
      default:
        return 'Interaction';
    }
  }

  Color _getTimelineLabelColor(String type, {String? content}) {
    if (type == 'payment' && content != null) {
      final parsed = _parsePaymentContent(content);
      switch (parsed['status']) {
        case 'Paid':
          return const Color(0xFF047857);
        case 'Received':
          return const Color(0xFF0284C7);
        case 'Owed to Me':
        case 'To Collect':
          return const Color(0xFFB45309);
        case 'I owe':
        case 'To Pay':
          return const Color(0xFFB91C1C);
      }
    }
    switch (type) {
      case 'call_incoming':
      case 'call_outgoing':
      case 'call_missed':
        return const Color(0xFF1F2937);
      case 'sms_incoming':
      case 'sms_outgoing':
        return const Color(0xFF4F46E5);
      case 'note':
        return const Color(0xFFB45309);
      case 'payment':
        return const Color(0xFF047857);
      case 'screenshot':
        return Colors.purple[700]!;
      case 'attachment':
        return Colors.blueGrey[700]!;
      case 'promise':
        return const Color(0xFFD97706);
      case 'sms_scheduled':
        return const Color(0xFF4F46E5);
      default:
        return Colors.grey;
    }
  }

  Widget _buildEmptyTimeline() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            'Timeline Empty',
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF374151)),
          ),
          const SizedBox(height: 4),
          Text(
            'Add manual notes, payments, or trigger a device sync to fetch histories.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}

class TimelineMonthHeader {
  final String monthKey;
  final int count;
  TimelineMonthHeader(this.monthKey, this.count);
}

class TimelineSectionHeader {
  final String title;
  TimelineSectionHeader(this.title);
}

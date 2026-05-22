import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database_helper.dart';
import '../sync_engine.dart';
import 'thread_screen.dart';

class DirectoryScreen extends StatefulWidget {
  final bool isEmbedded;
  final VoidCallback? onCreateContact;
  const DirectoryScreen({Key? key, this.isEmbedded = false, this.onCreateContact}) : super(key: key);

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  List<Map<String, dynamic>> _contacts = [];
  List<Map<String, dynamic>> _filteredContacts = [];
  String _searchQuery = "";
  String _activeFilter = "All"; // "All", "Starred", "Has Notes"
  bool _isLoading = true;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts({bool isSilent = false}) async {
    if (!isSilent && _contacts.isEmpty) {
      setState(() => _isLoading = true);
    }
    final db = await DatabaseHelper.instance.database;

    // Fetch contacts with latest timeline event timestamps if available
    final contactsData = await db.rawQuery('''
      SELECT c.*, MAX(t.timestamp) as last_interaction 
      FROM contacts c
      LEFT JOIN timeline t ON c.id = t.contact_id
      GROUP BY c.id
      ORDER BY last_interaction DESC, c.display_name ASC
    ''');

    if (mounted) {
      setState(() {
        _contacts = contactsData;
        _isLoading = false;
        _applyFilters();
      });
    }
  }

  void _applyFilters() {
    List<Map<String, dynamic>> results = _contacts;

    // Search query matching
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      results = results.where((c) {
        final name = (c['display_name'] ?? '').toLowerCase();
        final phone = (c['phone_number'] ?? '').toLowerCase();
        final note = (c['pinned_note'] ?? '').toLowerCase();
        return name.contains(q) || phone.contains(q) || note.contains(q);
      }).toList();
    }

    // Category filter matching
    if (_activeFilter == "Starred") {
      results = results.where((c) => c['is_starred'] == 1).toList();
    } else if (_activeFilter == "Has Notes") {
      results = results.where((c) {
        final note = c['pinned_note'] as String? ?? '';
        return note.trim().isNotEmpty;
      }).toList();
    }

    setState(() {
      _filteredContacts = results;
    });
  }

  Future<void> _startNativeSync() async {
    setState(() => _isSyncing = true);

    try {
      final results = await SyncEngine.syncAll();
      if (!mounted) return;

      // Show summary Dialog
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

      _loadContacts();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sync failed: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
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

  Future<void> _toggleStar(int contactId, int currentVal) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'contacts',
      {'is_starred': currentVal == 0 ? 1 : 0},
      where: 'id = ?',
      whereArgs: [contactId],
    );
    _loadContacts(isSilent: true);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF3525CD);

    final Widget bodyContent = Column(
      children: [
          // Search & Filter header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                TextField(
                  onChanged: (val) {
                    setState(() => _searchQuery = val);
                    _applyFilters();
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by name, phone, or manual notes...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildFilterChip('All'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Starred'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Has Notes'),
                  ],
                ),
              ],
            ),
          ),
          
          // Directory Roster
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF3525CD)))
                : _filteredContacts.isEmpty
                    ? _buildEmptyDirectory()
                    : ListView.separated(
                        key: const PageStorageKey('contacts_directory_list'),
                        itemCount: _filteredContacts.length,
                        padding: const EdgeInsets.all(16),
                        separatorBuilder: (c, i) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final contact = _filteredContacts[index];
                          final colorHex = contact['avatar_color'] ?? '#3525CD';
                          final intColor = int.tryParse(colorHex.replaceFirst('#', '0xFF')) ?? 0xFF3525CD;
                          final color = Color(intColor);

                          final lastTs = contact['last_interaction'] as int?;
                          String relativeInteraction = 'No registered interaction';
                          if (lastTs != null && lastTs > 0) {
                            final date = DateTime.fromMillisecondsSinceEpoch(lastTs);
                            final diff = DateTime.now().difference(date);
                            if (diff.inDays == 0) {
                              relativeInteraction = 'Interacted today';
                            } else if (diff.inDays == 1) {
                              relativeInteraction = 'Interacted yesterday';
                            } else {
                              relativeInteraction = 'Interacted ${diff.inDays} days ago';
                            }
                          }

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                radius: 24,
                                backgroundColor: color.withOpacity(0.1),
                                child: Text(
                                  contact['display_name'][0].toUpperCase(),
                                  style: GoogleFonts.outfit(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      contact['display_name'],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: const Color(0xFF1F2937),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _toggleStar(contact['id'], contact['is_starred']),
                                    child: Icon(
                                      contact['is_starred'] == 1 ? Icons.star : Icons.star_border,
                                      color: contact['is_starred'] == 1 ? Colors.amber : Colors.grey[400],
                                      size: 20,
                                    ),
                                  )
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    contact['phone_number'] ?? '',
                                    style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF4B5563)),
                                  ),
                                  if ((contact['pinned_note'] ?? '').toString().trim().isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      contact['pinned_note'],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                        color: const Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 6),
                                  Text(
                                    relativeInteraction,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ThreadScreen(contactId: contact['id']),
                                  ),
                                );
                                _loadContacts(isSilent: true);
                              },
                            ),
                          );
                        },
                      ),
          )
      ],
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'Contacts Directory',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: !widget.isEmbedded,
        leading: widget.isEmbedded 
            ? null 
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
                onPressed: () => Navigator.pop(context),
              ),
        actions: [
          if (widget.onCreateContact != null)
            IconButton(
              icon: const Icon(Icons.person_add, color: Color(0xFF3525CD)),
              tooltip: 'Create Contact Manually',
              onPressed: widget.onCreateContact,
            ),
          if (_isSyncing)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF3525CD)),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.sync, color: Color(0xFF3525CD)),
              onPressed: _startNativeSync,
            ),
        ],
      ),
      body: bodyContent,
    );
  }

  Widget _buildFilterChip(String label) {
    final active = _activeFilter == label;
    final primaryColor = const Color(0xFF3525CD);

    return ChoiceChip(
      label: Text(label),
      selected: active,
      onSelected: (bool selected) {
        if (selected) {
          setState(() => _activeFilter = label);
          _applyFilters();
        }
      },
      selectedColor: primaryColor.withOpacity(0.1),
      labelStyle: GoogleFonts.inter(
        fontWeight: active ? FontWeight.bold : FontWeight.normal,
        color: active ? primaryColor : const Color(0xFF4B5563),
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: active ? primaryColor.withOpacity(0.2) : const Color(0xFFE5E7EB)),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildEmptyDirectory() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_outlined, size: 54, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'No Contacts Found',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _searchQuery.isNotEmpty 
                  ? 'Try modifying your query terms.' 
                  : 'Sync native contacts on your phone to populate the offline CRM.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

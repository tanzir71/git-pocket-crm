import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';

import '../../../core/db/app_database.dart';
import '../../../core/format/app_formatters.dart';
import '../../../core/l10n_ext.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../../people/ui/person_picker_sheet.dart';
import '../data/capture_service.dart';

/// Opens the unified Add / Edit sheet (`handover/03-screens.md` section 05).
/// Returns the [CaptureUndoToken] if saved, or `null` if dismissed.
Future<CaptureUndoToken?> showAddSheet(
  BuildContext context, {
  Contact? fixedPerson,
  AddEntryType? initialType,
  TimelineEntry? editingEntry,
}) async {
  final token = await showCustomAppSheet<CaptureUndoToken>(
    context: context,
    builder: (ctx) => AddSheetBody(
      fixedPerson: fixedPerson,
      initialType: initialType,
      editingEntry: editingEntry,
    ),
  );
  return token;
}

/// Shows the 5-second "Saved" snackbar with Undo hooked to [CaptureService.undo].
void showCaptureSavedSnackBar(
  BuildContext context,
  WidgetRef ref,
  CaptureUndoToken token,
) {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: AppTokens.undoSnackBarDuration,
        content: Text(l10n.savedMessage),
        action: SnackBarAction(
          label: l10n.undoAction,
          onPressed: () {
            unawaited(ref.read(captureServiceProvider).undo(token));
          },
        ),
      ),
    );
}

enum _FollowUpPreset { none, tomorrow, threeDays, nextWeek, custom }

/// Public body widget so golden tests can render the sheet directly inside a surface.
class AddSheetBody extends ConsumerStatefulWidget {
  const AddSheetBody({
    super.key,
    this.fixedPerson,
    this.initialType,
    this.editingEntry,
    this.initialPhotos = const [],
    this.initialFollowUpPreset,
    this.onSaved,
  });

  final Contact? fixedPerson;
  final AddEntryType? initialType;
  final TimelineEntry? editingEntry;
  final List<String> initialPhotos;
  final int? initialFollowUpPreset; // 1=tomorrow, 3=3days, 7=week (for deterministic goldens)
  final void Function(CaptureUndoToken token)? onSaved;

  @override
  ConsumerState<AddSheetBody> createState() => _AddSheetBodyState();
}

class _AddSheetBodyState extends ConsumerState<AddSheetBody> {
  Contact? _person;
  PersonSuggestionReason? _suggestionReason;
  int? _suggestionFollowUpDueMs;
  bool _suggestionLoaded = false;

  late AddEntryType _type;
  late DateTime _entryDateTime;

  // Shared note text (preserved when switching types per Spec 07 step 1)
  late final TextEditingController _noteController;

  // Call fields
  String _callDirection = 'call_outgoing';
  String _callOutcome = 'spoke';
  late final TextEditingController _durationMinController;

  // Visit fields
  late final TextEditingController _placeController;
  double? _lat;
  double? _lng;
  bool _loadingLocation = false;
  bool _locationFailed = false;
  late final List<String> _photoPaths;

  // Task fields
  late final TextEditingController _taskTitleController;
  DateTime? _taskDueDateTime;

  // Payment fields
  late final TextEditingController _amountController;
  String _paymentStatus = 'received';

  // File fields
  String? _filePath;

  // Follow-up chips (all types except Task)
  _FollowUpPreset _followUpPreset = _FollowUpPreset.none;
  DateTime? _followUpCustomDateTime;
  late final TextEditingController _followUpTitleController;
  bool _followUpTitleManuallyEdited = false;

  bool _saving = false;
  bool _attemptedSave = false;

  bool get _isEdit => widget.editingEntry != null;
  bool get _isPersonFixed => widget.fixedPerson != null || _isEdit;

  @override
  void initState() {
    super.initState();
    final now = ref.read(clockProvider)();
    final defaultHour = ref.read(defaultFollowUpHourProvider).value ?? 9;

    _person = widget.fixedPerson;
    final edit = widget.editingEntry;

    if (edit != null) {
      _type = _entryTypeFromTimeline(edit.type);
      _entryDateTime = DateTime.fromMillisecondsSinceEpoch(edit.timestamp);
      _noteController = TextEditingController(text: edit.note ?? edit.content ?? '');
      _callDirection = edit.type == 'call_incoming' ? 'call_incoming' : 'call_outgoing';
      _callOutcome = edit.outcome ?? 'spoke';
      final mins = (edit.durationSeconds ?? 0) > 0 ? ((edit.durationSeconds! / 60).round()) : 0;
      _durationMinController = TextEditingController(text: mins > 0 ? '$mins' : '');
      _placeController = TextEditingController(text: edit.placeName ?? '');
      _lat = edit.lat;
      _lng = edit.lng;
      _photoPaths = List<String>.from(widget.initialPhotos);
      _taskTitleController = TextEditingController();
      _amountController = TextEditingController(
        text: edit.amount != null ? _formatEditableAmount(edit.amount!) : '',
      );
      _paymentStatus = edit.paymentStatus ?? 'received';
      _filePath = edit.attachmentPath;
      _followUpTitleController = TextEditingController();
      _suggestionLoaded = true;
    } else {
      _type = widget.initialType ?? ref.read(lastAddEntryTypeProvider);
      _entryDateTime = now;
      _noteController = TextEditingController();
      _durationMinController = TextEditingController();
      _placeController = TextEditingController(text: _defaultPlaceFor(_person));
      _photoPaths = List<String>.from(widget.initialPhotos);
      _taskTitleController = TextEditingController();
      _taskDueDateTime = DateTime(now.year, now.month, now.day + 1, defaultHour, 0);
      _amountController = TextEditingController();
      _followUpTitleController = TextEditingController();

      if (widget.initialFollowUpPreset == 1) {
        _followUpPreset = _FollowUpPreset.tomorrow;
      } else if (widget.initialFollowUpPreset == 3) {
        _followUpPreset = _FollowUpPreset.threeDays;
      } else if (widget.initialFollowUpPreset == 7) {
        _followUpPreset = _FollowUpPreset.nextWeek;
      }

      if (_person == null) {
        unawaited(_loadPersonSuggestion());
      } else {
        _suggestionLoaded = true;
      }
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _durationMinController.dispose();
    _placeController.dispose();
    _taskTitleController.dispose();
    _amountController.dispose();
    _followUpTitleController.dispose();
    super.dispose();
  }

  AddEntryType _entryTypeFromTimeline(String type) {
    if (type.startsWith('call_')) return AddEntryType.call;
    if (type == 'visit') return AddEntryType.visit;
    if (type == 'payment') return AddEntryType.payment;
    if (type == 'attachment') return AddEntryType.file;
    return AddEntryType.note;
  }

  String _formatEditableAmount(double v) {
    return (v - v.roundToDouble()).abs() < 0.005 ? v.round().toString() : v.toStringAsFixed(2);
  }

  String _defaultPlaceFor(Contact? person) {
    if (person == null) return '';
    return [
      if (person.company != null && person.company!.trim().isNotEmpty) person.company!.trim(),
      if (person.city != null && person.city!.trim().isNotEmpty) person.city!.trim(),
    ].join(', ');
  }

  String _firstName(Contact? person) {
    if (person == null) return '';
    return person.displayName.trim().split(RegExp(r'\s+')).first;
  }

  Future<void> _loadPersonSuggestion() async {
    final suggestion = await ref.read(captureServiceProvider).suggestPerson();
    if (!mounted) return;
    setState(() {
      _suggestionLoaded = true;
      if (suggestion != null) {
        _person = suggestion.contact;
        _suggestionReason = suggestion.reason;
        _suggestionFollowUpDueMs = suggestion.followUpDueMs;
        if (_placeController.text.isEmpty) {
          _placeController.text = _defaultPlaceFor(_person);
        }
      }
    });
  }

  void _selectType(AddEntryType type) {
    if (_isEdit) return;
    setState(() {
      _type = type;
      if (type == AddEntryType.visit && _placeController.text.isEmpty) {
        _placeController.text = _defaultPlaceFor(_person);
      }
    });
    ref.read(lastAddEntryTypeProvider.notifier).select(type);
  }

  Future<void> _pickPerson() async {
    if (_isPersonFixed) return;
    final picked = await showPersonPickerSheet(context);
    if (picked != null && mounted) {
      setState(() {
        _person = picked;
        _suggestionReason = null;
        _suggestionFollowUpDueMs = null;
        if (_placeController.text.isEmpty) {
          _placeController.text = _defaultPlaceFor(picked);
        }
        if (_followUpPreset != _FollowUpPreset.none && !_followUpTitleManuallyEdited) {
          _prefillFollowUpTitle();
        }
      });
    }
  }

  void _prefillFollowUpTitle() {
    final l10n = context.l10n;
    final first = _firstName(_person);
    if (first.isEmpty) return;
    final title = l10n.followUpDefaultTitle(first);
    _followUpTitleController.text = title;
    _followUpTitleController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: title.length,
    );
  }

  DateTime? _computedFollowUpDateTime() {
    final now = ref.read(clockProvider)();
    final hour = ref.read(defaultFollowUpHourProvider).value ?? 9;
    return switch (_followUpPreset) {
      _FollowUpPreset.none => null,
      _FollowUpPreset.tomorrow => DateTime(now.year, now.month, now.day + 1, hour, 0),
      _FollowUpPreset.threeDays => DateTime(now.year, now.month, now.day + 3, hour, 0),
      _FollowUpPreset.nextWeek => DateTime(now.year, now.month, now.day + 7, hour, 0),
      _FollowUpPreset.custom => _followUpCustomDateTime,
    };
  }

  Future<void> _selectFollowUpPreset(_FollowUpPreset preset) async {
    if (preset == _followUpPreset && preset != _FollowUpPreset.custom) {
      setState(() => _followUpPreset = _FollowUpPreset.none);
      return;
    }

    if (preset == _FollowUpPreset.custom) {
      final picked = await _pickDateAndTime(_followUpCustomDateTime ?? _entryDateTime);
      if (picked == null || !mounted) return;
      setState(() {
        _followUpPreset = _FollowUpPreset.custom;
        _followUpCustomDateTime = picked;
        if (!_followUpTitleManuallyEdited && _followUpTitleController.text.trim().isEmpty) {
          _prefillFollowUpTitle();
        }
      });
      return;
    }

    setState(() {
      _followUpPreset = preset;
      if (!_followUpTitleManuallyEdited) {
        _prefillFollowUpTitle();
      }
    });
  }

  Future<DateTime?> _pickDateAndTime(DateTime initial) async {
    final now = ref.read(clockProvider)();
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (date == null || !mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) {
      return DateTime(date.year, date.month, date.day, initial.hour, initial.minute);
    }
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _attachCurrentLocation() async {
    setState(() {
      _loadingLocation = true;
      _locationFailed = false;
    });

    try {
      final status = await Permission.locationWhenInUse.request();
      if (!status.isGranted) {
        if (mounted) {
          setState(() {
            _loadingLocation = false;
            _locationFailed = true;
          });
        }
        return;
      }
    } catch (_) {
      // In unit/widget tests where permission_handler has no platform channel,
      // fall through directly to the injected CapturePlatformAdapter.
    }

    final point = await ref.read(capturePlatformAdapterProvider).currentLocation();
    if (!mounted) return;
    setState(() {
      _loadingLocation = false;
      if (point != null) {
        _lat = point.lat;
        _lng = point.lng;
        _locationFailed = false;
      } else {
        _locationFailed = true;
      }
    });
  }

  Future<void> _addPhoto({required bool fromCamera}) async {
    final path = await ref.read(capturePlatformAdapterProvider).pickImage(fromCamera: fromCamera);
    if (path != null && path.isNotEmpty && mounted) {
      setState(() => _photoPaths.add(path));
    }
  }

  Future<void> _pickFile() async {
    final path = await ref.read(capturePlatformAdapterProvider).pickFile();
    if (path != null && path.isNotEmpty && mounted) {
      setState(() => _filePath = path);
    }
  }

  String? _validationError(BuildContext context) {
    final l10n = context.l10n;
    if (_person == null) return l10n.validationChoosePerson;
    switch (_type) {
      case AddEntryType.note:
        if (_noteController.text.trim().isEmpty) return l10n.validationAddNote;
      case AddEntryType.call:
        return null;
      case AddEntryType.visit:
        if (_placeController.text.trim().isEmpty && _noteController.text.trim().isEmpty) {
          return l10n.validationAddNote;
        }
      case AddEntryType.task:
        if (_taskTitleController.text.trim().isEmpty) return l10n.validationAddTitle;
      case AddEntryType.payment:
        final amt = double.tryParse(_amountController.text.replaceAll(',', '').trim());
        if (amt == null || amt <= 0) return l10n.validationAddAmount;
      case AddEntryType.file:
        if (_filePath == null || _filePath!.trim().isEmpty) return l10n.validationPickFile;
    }
    return null;
  }

  String _primaryButtonLabel(BuildContext context) {
    final l10n = context.l10n;
    if (_isEdit) return l10n.saveChangesAction;
    return switch (_type) {
      AddEntryType.note => l10n.saveNoteAction,
      AddEntryType.call => l10n.saveCallAction,
      AddEntryType.visit => l10n.saveVisitAction,
      AddEntryType.task => l10n.saveTaskAction,
      AddEntryType.payment => l10n.savePaymentAction,
      AddEntryType.file => l10n.saveFileAction,
    };
  }

  Future<void> _save() async {
    setState(() => _attemptedSave = true);
    if (_saving || _validationError(context) != null || _person == null) return;
    setState(() => _saving = true);

    final service = ref.read(captureServiceProvider);
    final currency = ref.read(currencyCodeProvider).value ?? 'USD';
    final followUpDt = _type == AddEntryType.task ? null : _computedFollowUpDateTime();
    final followUpTitle = _followUpTitleController.text.trim().isNotEmpty
        ? _followUpTitleController.text.trim()
        : (_person != null
            ? context.l10n.followUpDefaultTitle(_firstName(_person))
            : '');
    final followUpDraft = (followUpDt != null && followUpTitle.isNotEmpty)
        ? FollowUpDraft(title: followUpTitle, dueDateMs: followUpDt.millisecondsSinceEpoch)
        : null;

    final CaptureUndoToken token;
    if (_isEdit) {
      final parsedAmount = double.tryParse(_amountController.text.replaceAll(',', '').trim());
      token = await service.saveEdit(
        existing: widget.editingEntry!,
        note: _noteController.text,
        outcome: _type == AddEntryType.call ? _callOutcome : null,
        placeName: _type == AddEntryType.visit ? _placeController.text : null,
        lat: _lat,
        lng: _lng,
        amount: _type == AddEntryType.payment ? parsedAmount : null,
        currencyCode: _type == AddEntryType.payment ? currency : null,
        paymentStatus: _type == AddEntryType.payment ? _paymentStatus : null,
        timestampMs: _entryDateTime.millisecondsSinceEpoch,
        addedPhotoSourcePaths: _photoPaths,
        followUp: followUpDraft,
      );
    } else {
      final mins = int.tryParse(_durationMinController.text.trim());
      final parsedAmount = double.tryParse(_amountController.text.replaceAll(',', '').trim());
      token = await service.saveNew(
        contactId: _person!.id,
        type: _type,
        timestampMs: _entryDateTime.millisecondsSinceEpoch,
        note: _noteController.text,
        callDirectionType: _callDirection,
        durationSeconds: mins != null && mins > 0 ? mins * 60 : null,
        outcome: _callOutcome,
        placeName: _placeController.text,
        lat: _lat,
        lng: _lng,
        photoSourcePaths: _photoPaths,
        taskTitle: _taskTitleController.text,
        taskDueDateMs: _taskDueDateTime?.millisecondsSinceEpoch,
        amount: parsedAmount,
        currencyCode: currency,
        paymentStatus: _paymentStatus,
        fileSourcePath: _filePath,
        followUp: followUpDraft,
      );
    }

    if (!mounted) return;
    if (widget.onSaved != null) {
      widget.onSaved!(token);
    }
    Navigator.of(context).pop(token);
  }

  Future<void> _deleteEditingEntry() async {
    final edit = widget.editingEntry;
    if (edit == null) return;
    final isDevice =
        edit.source == 'device' || edit.type.startsWith('call_') || edit.type.startsWith('sms_');
    final repo = ref.read(historyRepositoryProvider);
    if (isDevice) {
      await repo.hideEntry(edit.id);
    } else {
      await repo.deleteEntry(edit.id);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final currency = ref.watch(currencyCodeProvider).value ?? 'USD';
    final locale = Localizations.localeOf(context).toLanguageTag();
    final fmt = AppFormatters(
      clock: ref.watch(clockProvider),
      localeName: locale,
      currencyCode: currency,
      use24Hour: MediaQuery.alwaysUse24HourFormatOf(context),
    );

    final validationMsg = _validationError(context);
    final canSave = !_saving && validationMsg == null;
    final maxSheetHeight = MediaQuery.sizeOf(context).height * 0.9;

    // Ensure follow-up default title is filled when preset is active (e.g. golden prefill)
    if (_followUpPreset != _FollowUpPreset.none &&
        !_followUpTitleManuallyEdited &&
        _followUpTitleController.text.isEmpty &&
        _person != null) {
      _followUpTitleController.text = l10n.followUpDefaultTitle(_firstName(_person));
    }

    String? suggestionCaption;
    if (_suggestionReason == PersonSuggestionReason.lastCall) {
      suggestionCaption = l10n.suggestedLastCall;
    } else if (_suggestionReason == PersonSuggestionReason.upcomingFollowUp &&
        _suggestionFollowUpDueMs != null) {
      final dt = DateTime.fromMillisecondsSinceEpoch(_suggestionFollowUpDueMs!);
      suggestionCaption = l10n.suggestedFollowUpAt(fmt.formatTime(dt));
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppTokens.screenPadding,
                AppTokens.space8,
                AppTokens.screenPadding,
                AppTokens.space8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _isEdit ? l10n.editEntryTitle : l10n.addSheetTitle,
                      style: tt.titleMedium!.copyWith(color: c.textPrimary),
                    ),
                  ),
                  if (_isEdit)
                    AppButton(
                      label: l10n.deleteAction,
                      variant: AppButtonVariant.quiet,
                      size: AppButtonSize.small,
                      onPressed: _deleteEditingEntry,
                    ),
                ],
              ),
            ),

            // Scrollable form body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppTokens.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Person field
                    InkWell(
                      onTap: _isPersonFixed ? null : _pickPerson,
                      borderRadius: BorderRadius.circular(AppTokens.radiusControl),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTokens.space12,
                          vertical: AppTokens.space8,
                        ),
                        decoration: BoxDecoration(
                          color: c.bgSubtle,
                          borderRadius: BorderRadius.circular(AppTokens.radiusControl),
                        ),
                        child: Row(
                          children: [
                            if (_person != null)
                              Avatar(name: _person!.displayName, toneIndex: _person!.id, size: 36)
                            else
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: c.bgSurface,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.person_outline, size: 18, color: c.textTertiary),
                              ),
                            const SizedBox(width: AppTokens.space12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _person?.displayName ?? l10n.choosePersonLabel,
                                    style: tt.labelLarge!.copyWith(
                                      color: _person != null ? c.textPrimary : c.textTertiary,
                                    ),
                                  ),
                                  if (suggestionCaption != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      suggestionCaption,
                                      style: tt.bodySmall!.copyWith(color: c.textSecondary),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (!_isPersonFixed)
                              Icon(Icons.chevron_right, size: 20, color: c.textTertiary),
                          ],
                        ),
                      ),
                    ),
                    if (_attemptedSave && _person == null && _suggestionLoaded) ...[
                      const SizedBox(height: AppTokens.space4),
                      Text(
                        l10n.validationChoosePerson,
                        style: tt.bodySmall!.copyWith(color: c.statusDanger),
                      ),
                    ],
                    const SizedBox(height: AppTokens.space12),

                    // Type chips (hidden in edit mode)
                    if (!_isEdit) ...[
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final (t, label) in [
                              (AddEntryType.note, l10n.typeNote),
                              (AddEntryType.call, l10n.typeCall),
                              (AddEntryType.visit, l10n.typeVisit),
                              (AddEntryType.task, l10n.typeTask),
                              (AddEntryType.payment, l10n.typePayment),
                              (AddEntryType.file, l10n.typeFile),
                            ]) ...[
                              AppChip(
                                label: label,
                                selected: _type == t,
                                onTap: () => _selectType(t),
                              ),
                              const SizedBox(width: AppTokens.space8),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTokens.space12),
                    ],

                    // Type-specific fields
                    ..._buildTypeFields(context, fmt, currency),

                    // Follow-up chips (for every type except Task)
                    if (_type != AddEntryType.task) ...[
                      const SizedBox(height: AppTokens.space16),
                      Text(
                        l10n.followUpSectionLabel,
                        style: tt.labelMedium!.copyWith(color: c.textSecondary),
                      ),
                      const SizedBox(height: AppTokens.space8),
                      Wrap(
                        spacing: AppTokens.space8,
                        runSpacing: AppTokens.space4,
                        children: [
                          AppChip(
                            label: l10n.dueTomorrow,
                            selected: _followUpPreset == _FollowUpPreset.tomorrow,
                            onTap: () => _selectFollowUpPreset(_FollowUpPreset.tomorrow),
                          ),
                          AppChip(
                            label: l10n.dueInThreeDays,
                            selected: _followUpPreset == _FollowUpPreset.threeDays,
                            onTap: () => _selectFollowUpPreset(_FollowUpPreset.threeDays),
                          ),
                          AppChip(
                            label: l10n.dueNextWeek,
                            selected: _followUpPreset == _FollowUpPreset.nextWeek,
                            onTap: () => _selectFollowUpPreset(_FollowUpPreset.nextWeek),
                          ),
                          AppChip(
                            label: _followUpPreset == _FollowUpPreset.custom &&
                                    _followUpCustomDateTime != null
                                ? fmt.formatRelativeDateTime(
                                    _followUpCustomDateTime!.millisecondsSinceEpoch,
                                    l10n,
                                  )
                                : l10n.pickDateAction,
                            selected: _followUpPreset == _FollowUpPreset.custom,
                            onTap: () => _selectFollowUpPreset(_FollowUpPreset.custom),
                          ),
                        ],
                      ),
                      if (_followUpPreset != _FollowUpPreset.none) ...[
                        const SizedBox(height: AppTokens.space8),
                        AppField(
                          controller: _followUpTitleController,
                          hintText: l10n.followUpTitleHint,
                          onChanged: (_) {
                            _followUpTitleManuallyEdited = true;
                            setState(() {});
                          },
                        ),
                      ],
                    ],

                    const SizedBox(height: AppTokens.space16),
                  ],
                ),
              ),
            ),

            // Pinned primary Save button
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppTokens.screenPadding,
                AppTokens.space8,
                AppTokens.screenPadding,
                AppTokens.space16,
              ),
              child: AppButton(
                label: _primaryButtonLabel(context),
                variant: AppButtonVariant.primary,
                fullWidth: true,
                onPressed: canSave ? _save : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTypeFields(BuildContext context, AppFormatters fmt, String currency) {
    final l10n = context.l10n;
    final c = context.colors;
    final tt = Theme.of(context).textTheme;

    switch (_type) {
      case AddEntryType.note:
        return [
          AppField(
            controller: _noteController,
            hintText: l10n.quickNoteHint,
            minLines: 3,
            maxLines: 8,
            autofocus: _person != null,
            onChanged: (_) => setState(() {}),
          ),
        ];

      case AddEntryType.call:
        return [
          Wrap(
            spacing: AppTokens.space8,
            children: [
              AppChip(
                label: l10n.directionOutgoing,
                selected: _callDirection == 'call_outgoing',
                onTap: () => setState(() => _callDirection = 'call_outgoing'),
              ),
              AppChip(
                label: l10n.directionIncoming,
                selected: _callDirection == 'call_incoming',
                onTap: () => setState(() => _callDirection = 'call_incoming'),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space12),
          SettingRow(
            label: l10n.fieldTime,
            value: fmt.formatRelativeDateTime(_entryDateTime.millisecondsSinceEpoch, l10n),
            onTap: () async {
              final dt = await _pickDateAndTime(_entryDateTime);
              if (dt != null && mounted) setState(() => _entryDateTime = dt);
            },
          ),
          const SizedBox(height: AppTokens.space8),
          AppField(
            label: l10n.fieldDurationMin,
            controller: _durationMinController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppTokens.space12),
          Text(
            l10n.outcomeQuestion,
            style: tt.labelMedium!.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: AppTokens.space8),
          Wrap(
            spacing: AppTokens.space8,
            children: [
              AppChip(
                label: l10n.outcomeSpoke,
                selected: _callOutcome == 'spoke',
                onTap: () => setState(() => _callOutcome = 'spoke'),
              ),
              AppChip(
                label: l10n.outcomeNoAnswer,
                selected: _callOutcome == 'no_answer',
                onTap: () => setState(() => _callOutcome = 'no_answer'),
              ),
              AppChip(
                label: l10n.outcomeLeftMessage,
                selected: _callOutcome == 'left_message',
                onTap: () => setState(() => _callOutcome = 'left_message'),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space12),
          AppField(
            controller: _noteController,
            hintText: l10n.quickNoteHint,
            minLines: 3,
            maxLines: 8,
            onChanged: (_) => setState(() {}),
          ),
        ];

      case AddEntryType.visit:
        return [
          AppField(
            label: l10n.fieldPlace,
            controller: _placeController,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppTokens.space8),
          Row(
            children: [
              AppButton(
                label: _lat != null ? l10n.locationAttached : l10n.currentLocationAction,
                variant: AppButtonVariant.secondary,
                size: AppButtonSize.small,
                onPressed: _loadingLocation ? null : _attachCurrentLocation,
              ),
              if (_locationFailed) ...[
                const SizedBox(width: AppTokens.space8),
                Text(
                  l10n.locationUnavailable,
                  style: tt.bodySmall!.copyWith(color: c.textTertiary),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppTokens.space12),
          SettingRow(
            label: l10n.fieldTime,
            value: fmt.formatRelativeDateTime(_entryDateTime.millisecondsSinceEpoch, l10n),
            onTap: () async {
              final dt = await _pickDateAndTime(_entryDateTime);
              if (dt != null && mounted) setState(() => _entryDateTime = dt);
            },
          ),
          const SizedBox(height: AppTokens.space12),
          AppField(
            controller: _noteController,
            hintText: l10n.quickNoteHint,
            minLines: 3,
            maxLines: 8,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppTokens.space12),
          Row(
            children: [
              Text(
                l10n.fieldPhotos,
                style: tt.labelMedium!.copyWith(color: c.textSecondary),
              ),
              const SizedBox(width: AppTokens.space8),
              if (_photoPaths.isNotEmpty)
                Text(
                  l10n.photoCount(_photoPaths.length),
                  style: tt.bodySmall!.copyWith(color: c.textTertiary),
                ),
            ],
          ),
          const SizedBox(height: AppTokens.space8),
          Row(
            children: [
              AppButton(
                label: l10n.photoCamera,
                variant: AppButtonVariant.secondary,
                size: AppButtonSize.small,
                onPressed: () => _addPhoto(fromCamera: true),
              ),
              const SizedBox(width: AppTokens.space8),
              AppButton(
                label: l10n.photoGallery,
                variant: AppButtonVariant.secondary,
                size: AppButtonSize.small,
                onPressed: () => _addPhoto(fromCamera: false),
              ),
            ],
          ),
        ];

      case AddEntryType.task:
        final now = ref.read(clockProvider)();
        final hour = ref.read(defaultFollowUpHourProvider).value ?? 9;
        return [
          AppField(
            label: l10n.typeTask,
            controller: _taskTitleController,
            hintText: l10n.followUpTitleHint,
            autofocus: _person != null,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppTokens.space12),
          Wrap(
            spacing: AppTokens.space8,
            children: [
              AppChip(
                label: l10n.dueTomorrow,
                onTap: () => setState(() {
                  _taskDueDateTime = DateTime(now.year, now.month, now.day + 1, hour, 0);
                }),
              ),
              AppChip(
                label: l10n.dueInThreeDays,
                onTap: () => setState(() {
                  _taskDueDateTime = DateTime(now.year, now.month, now.day + 3, hour, 0);
                }),
              ),
              AppChip(
                label: l10n.dueNextWeek,
                onTap: () => setState(() {
                  _taskDueDateTime = DateTime(now.year, now.month, now.day + 7, hour, 0);
                }),
              ),
              AppChip(
                label: l10n.pickDateAction,
                onTap: () async {
                  final dt = await _pickDateAndTime(_taskDueDateTime ?? now);
                  if (dt != null && mounted) setState(() => _taskDueDateTime = dt);
                },
              ),
            ],
          ),
          if (_taskDueDateTime != null) ...[
            const SizedBox(height: AppTokens.space8),
            Text(
              fmt.formatRelativeDateTime(_taskDueDateTime!.millisecondsSinceEpoch, l10n),
              style: tt.bodySmall!.copyWith(color: c.textSecondary),
            ),
          ],
          const SizedBox(height: AppTokens.space12),
          AppField(
            controller: _noteController,
            hintText: l10n.quickNoteHint,
            minLines: 2,
            maxLines: 5,
            onChanged: (_) => setState(() {}),
          ),
        ];

      case AddEntryType.payment:
        final symbol = AppFormatters.symbolForCurrency(currency);
        final amtValid =
            (double.tryParse(_amountController.text.replaceAll(',', '').trim()) ?? 0) > 0;
        return [
          AppField(
            label: l10n.fieldAmount,
            controller: _amountController,
            prefixText: symbol,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
          ),
          if (_attemptedSave && !amtValid) ...[
            const SizedBox(height: AppTokens.space4),
            Text(
              l10n.validationAddAmount,
              style: tt.bodySmall!.copyWith(color: c.statusDanger),
            ),
          ],
          const SizedBox(height: AppTokens.space12),
          Wrap(
            spacing: AppTokens.space8,
            runSpacing: AppTokens.space4,
            children: [
              for (final (code, label) in [
                ('received', l10n.paymentStatusReceived),
                ('paid', l10n.paymentStatusPaid),
                ('owed_to_me', l10n.paymentStatusOwesMe),
                ('i_owe', l10n.paymentStatusIOwe),
              ])
                AppChip(
                  label: label,
                  selected: _paymentStatus == code,
                  onTap: () => setState(() => _paymentStatus = code),
                ),
            ],
          ),
          const SizedBox(height: AppTokens.space12),
          AppField(
            label: l10n.fieldDescription,
            controller: _noteController,
            minLines: 2,
            maxLines: 4,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppTokens.space8),
          SettingRow(
            label: l10n.fieldDate,
            value: fmt.formatRelativeDateTime(_entryDateTime.millisecondsSinceEpoch, l10n),
            onTap: () async {
              final dt = await _pickDateAndTime(_entryDateTime);
              if (dt != null && mounted) setState(() => _entryDateTime = dt);
            },
          ),
        ];

      case AddEntryType.file:
        return [
          Row(
            children: [
              AppButton(
                label: l10n.chooseFileAction,
                variant: AppButtonVariant.secondary,
                size: AppButtonSize.small,
                onPressed: _pickFile,
              ),
              const SizedBox(width: AppTokens.space12),
              if (_filePath != null && _filePath!.isNotEmpty)
                Expanded(
                  child: Text(
                    p.basename(_filePath!),
                    style: tt.bodyMedium!.copyWith(color: c.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppTokens.space12),
          AppField(
            label: l10n.fieldDescription,
            controller: _noteController,
            minLines: 2,
            maxLines: 4,
            onChanged: (_) => setState(() {}),
          ),
        ];
    }
  }
}

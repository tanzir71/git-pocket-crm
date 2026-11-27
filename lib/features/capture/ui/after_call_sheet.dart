import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/db/app_database.dart';
import '../../../core/format/app_formatters.dart';
import '../../../core/l10n_ext.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../data/capture_service.dart';

/// Opens the After-call note sheet (`handover/03-screens.md` section 02, Figma `7:132`).
/// Always edits the existing [callEntry] in place and never creates a duplicate row.
Future<CaptureUndoToken?> showAfterCallSheet(
  BuildContext context, {
  required Contact contact,
  required TimelineEntry callEntry,
  bool focusFollowUp = false,
}) {
  return showCustomAppSheet<CaptureUndoToken>(
    context: context,
    builder: (ctx) => AfterCallSheetBody(
      contact: contact,
      callEntry: callEntry,
      focusFollowUp: focusFollowUp,
    ),
  );
}

enum _AfterCallFollowUpPreset { none, tomorrow, threeDays, nextWeek, custom }

/// Public body widget so golden tests can render the sheet directly inside a surface.
class AfterCallSheetBody extends ConsumerStatefulWidget {
  const AfterCallSheetBody({
    super.key,
    required this.contact,
    required this.callEntry,
    this.focusFollowUp = false,
    this.onSaved,
  });

  final Contact contact;
  final TimelineEntry callEntry;
  final bool focusFollowUp;
  final void Function(CaptureUndoToken token)? onSaved;

  @override
  ConsumerState<AfterCallSheetBody> createState() => _AfterCallSheetBodyState();
}

class _AfterCallSheetBodyState extends ConsumerState<AfterCallSheetBody> {
  late String _initialOutcome;
  late String _outcome;
  late final TextEditingController _noteController;
  late final TextEditingController _followUpTitleController;
  late final FocusNode _followUpFocusNode;

  _AfterCallFollowUpPreset _followUpPreset = _AfterCallFollowUpPreset.none;
  DateTime? _customFollowUpDateTime;
  bool _followUpTitleManuallyEdited = false;
  bool _saving = false;

  String get _firstName => widget.contact.displayName.trim().split(RegExp(r'\s+')).first;

  @override
  void initState() {
    super.initState();
    final dur = widget.callEntry.durationSeconds ?? 0;
    final defaultOutcome =
        widget.callEntry.outcome ?? (dur > 10 ? 'spoke' : 'no_answer');
    _initialOutcome = widget.callEntry.outcome ?? '';
    _outcome = defaultOutcome;
    _noteController = TextEditingController(text: widget.callEntry.note ?? '');
    _followUpTitleController = TextEditingController();
    _followUpFocusNode = FocusNode();

    if (widget.focusFollowUp || _outcome == 'no_answer') {
      _followUpPreset = _AfterCallFollowUpPreset.tomorrow;
    }

    if (widget.focusFollowUp) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _followUpFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _followUpTitleController.dispose();
    _followUpFocusNode.dispose();
    super.dispose();
  }

  String _defaultFollowUpTitle(BuildContext context, String outcome) {
    final l10n = context.l10n;
    return outcome == 'no_answer'
        ? l10n.callBackDefaultTitle(_firstName)
        : l10n.followUpDefaultTitle(_firstName);
  }

  void _selectOutcome(String nextOutcome) {
    setState(() {
      _outcome = nextOutcome;
      if (nextOutcome == 'no_answer') {
        _followUpPreset = _AfterCallFollowUpPreset.tomorrow;
        if (!_followUpTitleManuallyEdited) {
          final title = _defaultFollowUpTitle(context, nextOutcome);
          _followUpTitleController.text = title;
          _followUpTitleController.selection = TextSelection(
            baseOffset: 0,
            extentOffset: title.length,
          );
        }
      } else if (!_followUpTitleManuallyEdited &&
          _followUpPreset != _AfterCallFollowUpPreset.none) {
        final title = _defaultFollowUpTitle(context, nextOutcome);
        _followUpTitleController.text = title;
      }
    });
  }

  Future<void> _selectFollowUpPreset(_AfterCallFollowUpPreset preset) async {
    if (preset == _followUpPreset && preset != _AfterCallFollowUpPreset.custom) {
      setState(() => _followUpPreset = _AfterCallFollowUpPreset.none);
      return;
    }

    if (preset == _AfterCallFollowUpPreset.custom) {
      final now = ref.read(clockProvider)();
      final hour = ref.read(defaultFollowUpHourProvider).value ?? 9;
      final date = await showDatePicker(
        context: context,
        initialDate: _customFollowUpDateTime ?? DateTime(now.year, now.month, now.day + 1),
        firstDate: DateTime(now.year - 1),
        lastDate: DateTime(now.year + 5),
      );
      if (date == null || !mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: hour, minute: 0),
      );
      final dt = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? hour,
        time?.minute ?? 0,
      );
      setState(() {
        _followUpPreset = _AfterCallFollowUpPreset.custom;
        _customFollowUpDateTime = dt;
        if (!_followUpTitleManuallyEdited) {
          final title = _defaultFollowUpTitle(context, _outcome);
          _followUpTitleController.text = title;
        }
      });
      return;
    }

    setState(() {
      _followUpPreset = preset;
      if (!_followUpTitleManuallyEdited) {
        final title = _defaultFollowUpTitle(context, _outcome);
        _followUpTitleController.text = title;
        _followUpTitleController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: title.length,
        );
      }
    });
  }

  DateTime? _computedFollowUpDateTime() {
    final now = ref.read(clockProvider)();
    final hour = ref.read(defaultFollowUpHourProvider).value ?? 9;
    return switch (_followUpPreset) {
      _AfterCallFollowUpPreset.none => null,
      _AfterCallFollowUpPreset.tomorrow => DateTime(now.year, now.month, now.day + 1, hour, 0),
      _AfterCallFollowUpPreset.threeDays => DateTime(now.year, now.month, now.day + 3, hour, 0),
      _AfterCallFollowUpPreset.nextWeek => DateTime(now.year, now.month, now.day + 7, hour, 0),
      _AfterCallFollowUpPreset.custom => _customFollowUpDateTime,
    };
  }

  bool get _canSave {
    if (_saving) return false;
    final hasNote = _noteController.text.trim().isNotEmpty;
    final outcomeChanged = _outcome != _initialOutcome;
    final hasFollowUp = _followUpPreset != _AfterCallFollowUpPreset.none;
    return hasNote || outcomeChanged || hasFollowUp;
  }

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _saving = true);

    final followUpDt = _computedFollowUpDateTime();
    final title = _followUpTitleController.text.trim().isNotEmpty
        ? _followUpTitleController.text.trim()
        : _defaultFollowUpTitle(context, _outcome);

    final followUpDraft = (followUpDt != null && title.isNotEmpty)
        ? FollowUpDraft(title: title, dueDateMs: followUpDt.millisecondsSinceEpoch)
        : null;

    final token = await ref.read(captureServiceProvider).saveEdit(
          existing: widget.callEntry,
          note: _noteController.text,
          outcome: _outcome,
          markReviewed: true,
          followUp: followUpDraft,
        );

    if (!mounted) return;
    widget.onSaved?.call(token);
    Navigator.of(context).pop(token);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final clock = ref.watch(clockProvider);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final fmt = AppFormatters(
      clock: clock,
      localeName: locale,
      use24Hour: MediaQuery.alwaysUse24HourFormatOf(context),
    );

    if (_followUpPreset != _AfterCallFollowUpPreset.none &&
        !_followUpTitleManuallyEdited &&
        _followUpTitleController.text.isEmpty) {
      _followUpTitleController.text = _defaultFollowUpTitle(context, _outcome);
    }

    final directionLabel = switch (widget.callEntry.type) {
      'call_outgoing' => l10n.directionOutgoing,
      'call_missed' => l10n.callMissed,
      _ => l10n.directionIncoming,
    };
    final durStr = fmt.formatDuration(widget.callEntry.durationSeconds, l10n);
    final diffMin = clock()
        .difference(DateTime.fromMillisecondsSinceEpoch(widget.callEntry.timestamp))
        .inMinutes
        .abs();
    final timeStr = diffMin < 5
        ? l10n.justNowLabel
        : fmt.formatRelativeDateTime(widget.callEntry.timestamp, l10n);

    final subtitleParts = [
      directionLabel,
      if (durStr.isNotEmpty && widget.callEntry.type != 'call_missed') durStr,
      timeStr,
    ];

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppTokens.screenPadding,
                  AppTokens.space8,
                  AppTokens.screenPadding,
                  AppTokens.space12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Identity header
                    Row(
                      children: [
                        Avatar(
                          name: widget.contact.displayName,
                          toneIndex: widget.contact.id,
                        ),
                        const SizedBox(width: AppTokens.space12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.callWithTitle(widget.contact.displayName),
                                style: tt.titleMedium!.copyWith(color: c.textPrimary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                subtitleParts.join(' · '),
                                style: tt.bodySmall!.copyWith(color: c.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTokens.space16),

                    // Outcome chips
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
                          selected: _outcome == 'spoke',
                          onTap: () => _selectOutcome('spoke'),
                        ),
                        AppChip(
                          label: l10n.outcomeNoAnswer,
                          selected: _outcome == 'no_answer',
                          onTap: () => _selectOutcome('no_answer'),
                        ),
                        AppChip(
                          label: l10n.outcomeLeftMessage,
                          selected: _outcome == 'left_message',
                          onTap: () => _selectOutcome('left_message'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTokens.space16),

                    // Note field (relies on keyboard voice typing; no INTERNET mic plugin)
                    AppField(
                      controller: _noteController,
                      hintText: l10n.quickNoteHint,
                      minLines: 3,
                      maxLines: 8,
                      autofocus: !widget.focusFollowUp,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: AppTokens.space16),

                    // Follow-up chips
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
                          selected: _followUpPreset == _AfterCallFollowUpPreset.tomorrow,
                          onTap: () => _selectFollowUpPreset(_AfterCallFollowUpPreset.tomorrow),
                        ),
                        AppChip(
                          label: l10n.dueInThreeDays,
                          selected: _followUpPreset == _AfterCallFollowUpPreset.threeDays,
                          onTap: () => _selectFollowUpPreset(_AfterCallFollowUpPreset.threeDays),
                        ),
                        AppChip(
                          label: l10n.dueNextWeek,
                          selected: _followUpPreset == _AfterCallFollowUpPreset.nextWeek,
                          onTap: () => _selectFollowUpPreset(_AfterCallFollowUpPreset.nextWeek),
                        ),
                        AppChip(
                          label: _followUpPreset == _AfterCallFollowUpPreset.custom &&
                                  _customFollowUpDateTime != null
                              ? fmt.formatRelativeDateTime(
                                  _customFollowUpDateTime!.millisecondsSinceEpoch,
                                  l10n,
                                )
                              : l10n.pickDateAction,
                          selected: _followUpPreset == _AfterCallFollowUpPreset.custom,
                          onTap: () => _selectFollowUpPreset(_AfterCallFollowUpPreset.custom),
                        ),
                      ],
                    ),
                    if (_followUpPreset != _AfterCallFollowUpPreset.none) ...[
                      const SizedBox(height: AppTokens.space8),
                      AppField(
                        controller: _followUpTitleController,
                        focusNode: _followUpFocusNode,
                        hintText: l10n.followUpTitleHint,
                        onChanged: (_) {
                          _followUpTitleManuallyEdited = true;
                          setState(() {});
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Pinned Save button
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.screenPadding,
                AppTokens.space8,
                AppTokens.screenPadding,
                AppTokens.space16,
              ),
              child: AppButton(
                label: l10n.saveAction,
                variant: AppButtonVariant.primary,
                fullWidth: true,
                onPressed: _canSave ? _save : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

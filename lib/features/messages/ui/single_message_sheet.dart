import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/db/app_database.dart';
import '../../../core/format/app_formatters.dart';
import '../../../core/l10n_ext.dart';
import '../../../core/messages/sms_counter.dart';
import '../../../core/native/outbox_api.g.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';

/// Opens the single-message composer sheet for [contact] (Spec 09 step 5).
Future<bool> showSingleMessageSheet(
  BuildContext context, {
  required Contact contact,
  required String address,
  String? initialBody,
  Future<bool> Function(Uri uri)? onLaunchUri,
}) async {
  final result = await showCustomAppSheet<bool>(
    context: context,
    builder: (ctx) => _SingleMessageSheet(
      contact: contact,
      address: address,
      initialBody: initialBody,
      onLaunchUri: onLaunchUri,
    ),
  );
  return result == true;
}

class _SingleMessageSheet extends ConsumerStatefulWidget {
  const _SingleMessageSheet({
    required this.contact,
    required this.address,
    this.initialBody,
    this.onLaunchUri,
  });

  final Contact contact;
  final String address;
  final String? initialBody;
  final Future<bool> Function(Uri uri)? onLaunchUri;

  @override
  ConsumerState<_SingleMessageSheet> createState() => _SingleMessageSheetState();
}

class _SingleMessageSheetState extends ConsumerState<_SingleMessageSheet> {
  late final TextEditingController _bodyController;
  bool _sendNow = true;
  late DateTime _scheduledAt;
  List<SimInfo> _sims = const [];
  int? _selectedSubId;
  bool _exactAlarms = true;
  bool _hasSmsPermission = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _bodyController = TextEditingController(text: widget.initialBody ?? '');
    final now = ref.read(clockProvider)();
    _scheduledAt = now.add(const Duration(hours: 1));
    unawaited(_loadPlatformInfo());
  }

  Future<void> _loadPlatformInfo() async {
    final repo = ref.read(outboxRepositoryProvider);
    final sims = await repo.sims();
    final caps = await repo.capabilities();
    if (!mounted) return;
    setState(() {
      _sims = sims;
      if (sims.length >= 2) {
        final def = sims.firstWhere((s) => s.isDefault, orElse: () => sims.first);
        _selectedSubId = def.subId;
      }
      _exactAlarms = caps.exactAlarms;
      _hasSmsPermission = caps.smsPermission;
    });
  }

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _pickScheduleTime() async {
    final now = ref.read(clockProvider)();
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt.isAfter(now) ? _scheduledAt : now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledAt),
    );
    if (time == null || !mounted) return;
    setState(() {
      _scheduledAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      _sendNow = false;
    });
  }

  Future<void> _pickSim() async {
    if (_sims.length < 2) return;
    final chosen = await showAppSheet<int>(
      context: context,
      bodyBuilder: (ctx) {
        final c = ctx.colors;
        final tt = Theme.of(ctx).textTheme;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              ctx.l10n.fromSimLabel,
              style: tt.titleMedium!.copyWith(color: c.textPrimary),
            ),
            const SizedBox(height: AppTokens.space8),
            for (final sim in _sims)
              InkWell(
                onTap: () => Navigator.of(ctx).pop(sim.subId),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: AppTokens.minTouchTarget),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'SIM ${sim.slot + 1} · ${sim.displayName}',
                          style: tt.bodyLarge!.copyWith(color: c.textPrimary),
                        ),
                      ),
                      if (sim.subId == _selectedSubId)
                        Icon(Icons.check, size: 20, color: c.accentDefault),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
    if (chosen != null && mounted) {
      setState(() => _selectedSubId = chosen);
    }
  }

  Future<void> _submit() async {
    final body = _bodyController.text.trim();
    if (body.isEmpty || _submitting) return;

    if (!_hasSmsPermission) {
      final uri = Uri(
        scheme: 'sms',
        path: widget.address.trim(),
        queryParameters: {'body': body},
      );
      if (widget.onLaunchUri != null) {
        await widget.onLaunchUri!(uri);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      if (mounted) Navigator.of(context).pop(true);
      return;
    }

    setState(() => _submitting = true);
    try {
      final now = ref.read(clockProvider)();
      final dueAtMs = _sendNow
          ? now.millisecondsSinceEpoch
          : _scheduledAt.millisecondsSinceEpoch;
      await ref.read(outboxRepositoryProvider).scheduleSingle(
            contactId: widget.contact.id,
            address: widget.address.trim(),
            recipientName: widget.contact.displayName,
            body: body,
            dueAtMs: dueAtMs,
            subId: _selectedSubId,
          );
      if (mounted) Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final clock = ref.watch(clockProvider);
    final fmt = AppFormatters(
      clock: clock,
      localeName: Localizations.localeOf(context).toLanguageTag(),
      use24Hour: MediaQuery.alwaysUse24HourFormatOf(context),
    );

    final count = countSms(_bodyController.text);
    final counterText = l10n.smsCounterLabel(
      count.units,
      count.perSegmentLimit,
      count.segments == 0 ? 1 : count.segments,
    );

    final selectedSim = _sims.length >= 2
        ? _sims.firstWhere(
            (s) => s.subId == _selectedSubId,
            orElse: () => _sims.first,
          )
        : null;

    final canSend = _bodyController.text.trim().isNotEmpty && !_submitting;
    final primaryLabel = !_hasSmsPermission
        ? l10n.openInSmsAppAction
        : (_sendNow ? l10n.sendNowAction : l10n.scheduleMessageAction);

    return Padding(
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
                  Text(
                    l10n.messagePersonTitle(widget.contact.displayName),
                    style: tt.titleMedium!.copyWith(color: c.textPrimary),
                  ),
                  const SizedBox(height: AppTokens.space12),
                  AppField(
                    controller: _bodyController,
                    hintText: l10n.messageFieldHint,
                    maxLines: 5,
                    minLines: 3,
                    autofocus: true,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: AppTokens.space4),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Text(
                      counterText,
                      style: tt.bodySmall!.copyWith(color: c.textTertiary),
                    ),
                  ),
                  const SizedBox(height: AppTokens.space12),
                  Wrap(
                    spacing: AppTokens.space8,
                    runSpacing: AppTokens.space8,
                    children: [
                      AppChip(
                        label: l10n.sendNowOption,
                        selected: _sendNow,
                        onTap: () => setState(() => _sendNow = true),
                      ),
                      AppChip(
                        label: _sendNow
                            ? l10n.scheduleOption
                            : fmt.formatRelativeDateTime(
                                _scheduledAt.millisecondsSinceEpoch,
                                l10n,
                              ),
                        selected: !_sendNow,
                        leadingIcon: Icons.schedule_outlined,
                        onTap: _pickScheduleTime,
                      ),
                    ],
                  ),
                  if (!_sendNow && !_exactAlarms) ...[
                    const SizedBox(height: AppTokens.space8),
                    Text(
                      l10n.mayBeMinutesLateNotice,
                      style: tt.bodySmall!.copyWith(color: c.textSecondary),
                    ),
                  ],
                  if (selectedSim != null) ...[
                    const SizedBox(height: AppTokens.space12),
                    SettingRow(
                      label: l10n.fromSimLabel,
                      value: 'SIM ${selectedSim.slot + 1} · ${selectedSim.displayName}',
                      onTap: _pickSim,
                    ),
                  ],
                ],
              ),
            ),
          ),
          Divider(height: 1, color: c.borderHairline),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.screenPadding,
              AppTokens.space12,
              AppTokens.screenPadding,
              AppTokens.space16,
            ),
            child: AppButton(
              label: primaryLabel,
              variant: AppButtonVariant.primary,
              fullWidth: true,
              onPressed: canSend ? _submit : null,
            ),
          ),
        ],
      ),
    );
  }
}

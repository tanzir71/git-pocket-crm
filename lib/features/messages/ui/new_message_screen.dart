import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/db/app_database.dart';
import '../../../core/format/app_formatters.dart';
import '../../people/data/lists_repository.dart';
import '../../../core/l10n_ext.dart';
import '../../../core/messages/sms_counter.dart';
import '../../../core/messages/template_renderer.dart';
import '../../../core/native/outbox_api.g.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../data/campaigns_repository.dart';
import 'merge_field_controller.dart';

/// Composer for one or many recipients (Figma frame `10:498`, route `/messages/new`).
class NewMessageScreen extends ConsumerStatefulWidget {
  const NewMessageScreen({
    super.key,
    this.initialContactIds = const {},
    this.initialListIds = const {},
    this.initialTemplateName,
    this.initialBody,
    this.initialCampaignName,
    this.initialScheduledAt,
    this.onLaunchUri,
    this.onScheduled,
  });

  final Set<int> initialContactIds;
  final Set<int> initialListIds;
  final String? initialTemplateName;
  final String? initialBody;
  final String? initialCampaignName;
  final DateTime? initialScheduledAt;
  final Future<bool> Function(Uri uri)? onLaunchUri;
  final void Function(String? campaignId)? onScheduled;

  @override
  ConsumerState<NewMessageScreen> createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends ConsumerState<NewMessageScreen> {
  late final MergeFieldTextController _bodyController;
  final Set<int> _selectedListIds = <int>{};
  final Set<int> _selectedContactIds = <int>{};
  final Map<int, ContactListSummary> _listSummariesById = <int, ContactListSummary>{};
  final Map<int, Contact> _contactsById = <int, Contact>{};

  RecipientResolution _resolution = const RecipientResolution(
    recipients: [],
    skipped: [],
  );
  int _previewIndex = 0;

  bool _sendNow = true;
  late DateTime _scheduledAt;
  CampaignPace _pace = CampaignPace.fast;
  List<SimInfo> _sims = const [];
  int? _selectedSubId;
  bool _hasSmsPermission = true;
  bool _exactAlarms = true;
  String _myName = '';
  int _windowStartMin = 9 * 60;
  int _windowEndMin = 21 * 60;
  String? _campaignTitle;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _selectedListIds.addAll(widget.initialListIds);
    _selectedContactIds.addAll(widget.initialContactIds);
    _campaignTitle = widget.initialCampaignName ?? widget.initialTemplateName;
    _bodyController = MergeFieldTextController(text: widget.initialBody ?? '');

    final now = ref.read(clockProvider)();
    if (widget.initialScheduledAt != null) {
      _sendNow = false;
      _scheduledAt = widget.initialScheduledAt!;
    } else {
      _scheduledAt = DateTime(now.year, now.month, now.day, 18, 0);
      if (!_scheduledAt.isAfter(now)) {
        _scheduledAt = now.add(const Duration(hours: 1));
      }
    }

    unawaited(_initData());
  }

  Future<void> _initData() async {
    final settingsRepo = ref.read(settingsRepositoryProvider);
    final outboxRepo = ref.read(outboxRepositoryProvider);
    final templatesRepo = ref.read(templatesRepositoryProvider);
    await templatesRepo.seedDefaultsIfEmpty();

    final myName = (await settingsRepo.get('my_name')) ?? '';
    final defaultPace = CampaignPace.fromSetting(await settingsRepo.get('default_pace'));
    final ws = int.tryParse((await settingsRepo.get('send_window_start_min')) ?? '') ?? 9 * 60;
    final we = int.tryParse((await settingsRepo.get('send_window_end_min')) ?? '') ?? 21 * 60;
    final sims = await outboxRepo.sims();
    final caps = await outboxRepo.capabilities();

    String? loadedTemplateBody;
    if (widget.initialBody == null && widget.initialTemplateName != null) {
      final tpl = await templatesRepo.getByName(widget.initialTemplateName!);
      if (tpl != null) {
        loadedTemplateBody = tpl.body;
      }
    }

    final lists = await ref.read(listsRepositoryProvider).watchLists().first;
    final contacts = await ref.read(peopleRepositoryProvider).watchAll().first;

    if (!mounted) return;
    setState(() {
      _myName = myName;
      _pace = defaultPace;
      _windowStartMin = ws;
      _windowEndMin = we;
      _sims = sims;
      if (sims.isNotEmpty) {
        final def = sims.firstWhere((s) => s.isDefault, orElse: () => sims.first);
        _selectedSubId = def.subId;
      }
      _hasSmsPermission = caps.smsPermission;
      _exactAlarms = caps.exactAlarms;
      for (final l in lists) {
        _listSummariesById[l.list.id] = l;
      }
      for (final c in contacts) {
        _contactsById[c.id] = c;
      }
      if (loadedTemplateBody != null) {
        _bodyController.text = loadedTemplateBody;
      }
    });

    await _resolveRecipients();
  }

  Future<void> _resolveRecipients() async {
    final region = ref.read(phoneRegionProvider).value ?? 'US';
    final res = await ref.read(campaignsRepositoryProvider).resolveRecipients(
          listIds: _selectedListIds,
          contactIds: _selectedContactIds,
          defaultRegion: region,
        );
    if (!mounted) return;
    setState(() {
      _resolution = res;
      if (_previewIndex >= res.recipients.length) {
        _previewIndex = 0;
      }
    });
  }

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  TemplateSettings _templateSettings(BuildContext context) {
    final currency = ref.read(currencyCodeProvider).value ?? 'USD';
    return TemplateSettings(
      myName: _myName,
      currencyCode: currency,
      localeName: Localizations.localeOf(context).toLanguageTag(),
    );
  }

  Future<void> _handleClose() async {
    if (_bodyController.text.trim().isEmpty) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/messages');
      }
      return;
    }
    final l10n = context.l10n;
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.discardDraftTitle),
        content: Text(l10n.discardDraftBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.keepEditingAction),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l10n.discardAction,
              style: TextStyle(color: ctx.colors.statusDanger),
            ),
          ),
        ],
      ),
    );
    if (discard == true && mounted) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/messages');
      }
    }
  }

  Future<void> _openTemplatesPicker() async {
    final repo = ref.read(templatesRepositoryProvider);
    await repo.seedDefaultsIfEmpty();
    final templates = await repo.getAll();
    if (!mounted) return;

    final chosen = await showAppSheet<Template>(
      context: context,
      bodyBuilder: (ctx) {
        final c = ctx.colors;
        final tt = Theme.of(ctx).textTheme;
        final l10n = ctx.l10n;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.messagesViewTemplates,
              style: tt.titleMedium!.copyWith(color: c.textPrimary),
            ),
            const SizedBox(height: AppTokens.space8),
            for (final tpl in templates)
              InkWell(
                onTap: () => Navigator.of(ctx).pop(tpl),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppTokens.space12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tpl.name,
                        style: tt.bodyLarge!.copyWith(
                          color: c.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tpl.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: tt.bodyMedium!.copyWith(color: c.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );

    if (chosen != null && mounted) {
      setState(() {
        _bodyController.text = chosen.body;
        _campaignTitle = chosen.name;
      });
    }
  }

  Future<void> _openRecipientPicker() async {
    final lists = await ref.read(listsRepositoryProvider).watchLists().first;
    final contacts = await ref.read(peopleRepositoryProvider).watchAll().first;
    if (!mounted) return;

    final tempLists = <int>{..._selectedListIds};
    final tempContacts = <int>{..._selectedContactIds};
    String query = '';

    final confirmed = await showCustomAppSheet<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final c = ctx.colors;
            final tt = Theme.of(ctx).textTheme;
            final l10n = ctx.l10n;
            final q = query.trim().toLowerCase();
            final filteredLists = lists
                .where((l) => q.isEmpty || l.list.name.toLowerCase().contains(q))
                .toList();
            final filteredContacts = contacts
                .where((p) =>
                    q.isEmpty ||
                    p.displayName.toLowerCase().contains(q) ||
                    (p.company ?? '').toLowerCase().contains(q))
                .toList();
            final totalPicked = tempLists.length + tempContacts.length;

            return SizedBox(
              height: MediaQuery.sizeOf(ctx).height * 0.78,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      AppTokens.screenPadding,
                      AppTokens.space8,
                      AppTokens.screenPadding,
                      AppTokens.space12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.recipientPickerTitle,
                          style: tt.titleMedium!.copyWith(color: c.textPrimary),
                        ),
                        const SizedBox(height: AppTokens.space12),
                        AppField(
                          hintText: l10n.searchPeopleHint,
                          leadingIcon: Icons.search,
                          onChanged: (v) => setModalState(() => query = v),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        if (filteredLists.isNotEmpty) ...[
                          SectionHeader(
                            title: l10n.personPickerLists,
                            count: filteredLists.length,
                          ),
                          for (final l in filteredLists)
                            InkWell(
                              onTap: () => setModalState(() {
                                if (!tempLists.remove(l.list.id)) {
                                  tempLists.add(l.list.id);
                                }
                              }),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minHeight: AppTokens.minTouchTarget,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppTokens.screenPadding,
                                    vertical: AppTokens.space8,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        tempLists.contains(l.list.id)
                                            ? Icons.check_box
                                            : Icons.check_box_outline_blank,
                                        color: tempLists.contains(l.list.id)
                                            ? c.accentDefault
                                            : c.textSecondary,
                                      ),
                                      const SizedBox(width: AppTokens.space12),
                                      Expanded(
                                        child: Text(
                                          l.list.name,
                                          style: tt.bodyLarge!.copyWith(color: c.textPrimary),
                                        ),
                                      ),
                                      Text(
                                        '${l.memberCount}',
                                        style: tt.bodyMedium!.copyWith(color: c.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                        SectionHeader(
                          title: l10n.personPickerAll,
                          count: filteredContacts.length,
                        ),
                        for (final person in filteredContacts)
                          InkWell(
                            onTap: () => setModalState(() {
                              if (!tempContacts.remove(person.id)) {
                                tempContacts.add(person.id);
                              }
                            }),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                minHeight: AppTokens.minTouchTarget,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTokens.screenPadding,
                                  vertical: AppTokens.space8,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      tempContacts.contains(person.id)
                                          ? Icons.check_box
                                          : Icons.check_box_outline_blank,
                                      color: tempContacts.contains(person.id)
                                          ? c.accentDefault
                                          : c.textSecondary,
                                    ),
                                    const SizedBox(width: AppTokens.space12),
                                    Avatar(name: person.displayName, toneIndex: person.id),
                                    const SizedBox(width: AppTokens.space12),
                                    Expanded(
                                      child: Text(
                                        person.displayName,
                                        style: tt.bodyLarge!.copyWith(color: c.textPrimary),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: c.borderHairline),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      AppTokens.screenPadding,
                      AppTokens.space12,
                      AppTokens.screenPadding,
                      AppTokens.space16,
                    ),
                    child: AppButton(
                      label: l10n.recipientPickerDone(totalPicked),
                      variant: AppButtonVariant.primary,
                      fullWidth: true,
                      onPressed: () => Navigator.of(ctx).pop(true),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (confirmed == true && mounted) {
      setState(() {
        _selectedListIds
          ..clear()
          ..addAll(tempLists);
        _selectedContactIds
          ..clear()
          ..addAll(tempContacts);
        for (final l in lists) {
          _listSummariesById[l.list.id] = l;
        }
        for (final p in contacts) {
          _contactsById[p.id] = p;
        }
      });
      await _resolveRecipients();
    }
  }

  Future<void> _pickSendTime() async {
    final l10n = context.l10n;
    final choice = await showAppSheet<String>(
      context: context,
      bodyBuilder: (ctx) {
        final c = ctx.colors;
        final tt = Theme.of(ctx).textTheme;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.composerSendLabel,
              style: tt.titleMedium!.copyWith(color: c.textPrimary),
            ),
            const SizedBox(height: AppTokens.space8),
            InkWell(
              onTap: () => Navigator.of(ctx).pop('now'),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: AppTokens.minTouchTarget),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.sendNowOption,
                        style: tt.bodyLarge!.copyWith(color: c.textPrimary),
                      ),
                    ),
                    if (_sendNow) Icon(Icons.check, size: 20, color: c.accentDefault),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () => Navigator.of(ctx).pop('schedule'),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: AppTokens.minTouchTarget),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.pickDateAction,
                        style: tt.bodyLarge!.copyWith(color: c.textPrimary),
                      ),
                    ),
                    if (!_sendNow) Icon(Icons.check, size: 20, color: c.accentDefault),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );

    if (choice == 'now' && mounted) {
      setState(() => _sendNow = true);
      return;
    }
    if (choice != 'schedule' || !mounted) return;

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

  Future<void> _pickPace() async {
    final count = _resolution.recipients.length;
    final chosen = await showAppSheet<CampaignPace>(
      context: context,
      bodyBuilder: (ctx) {
        final c = ctx.colors;
        final tt = Theme.of(ctx).textTheme;
        final l10n = ctx.l10n;
        final options = <(CampaignPace, String)>[
          (CampaignPace.fast, l10n.paceFastTitle),
          (CampaignPace.steady, l10n.paceSteadyTitle),
          (CampaignPace.careful, l10n.paceCarefulTitle),
        ];
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.composerPaceLabel,
              style: tt.titleMedium!.copyWith(color: c.textPrimary),
            ),
            const SizedBox(height: AppTokens.space8),
            for (final (pace, title) in options)
              InkWell(
                onTap: () => Navigator.of(ctx).pop(pace),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: AppTokens.minTouchTarget),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppTokens.space8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: tt.bodyLarge!.copyWith(color: c.textPrimary),
                              ),
                              Text(
                                _formatPaceValue(pace, count, l10n),
                                style: tt.bodyMedium!.copyWith(color: c.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        if (pace == _pace)
                          Icon(Icons.check, size: 20, color: c.accentDefault),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
    if (chosen != null && mounted) {
      setState(() => _pace = chosen);
    }
  }

  String _formatPaceShort(CampaignPace pace, dynamic l10n) {
    if (pace == CampaignPace.careful) return l10n.paceOnePerMinute as String;
    return l10n.paceEveryNSeconds(pace.seconds) as String;
  }

  String _formatDurationEstimate(int seconds, dynamic l10n) {
    if (seconds < 60) {
      return l10n.aboutSeconds(seconds.clamp(1, 59)) as String;
    }
    final mins = (seconds / 60).ceil();
    return l10n.aboutMinutes(mins) as String;
  }

  String _formatPaceValue(CampaignPace pace, int recipientCount, dynamic l10n) {
    final short = _formatPaceShort(pace, l10n);
    if (recipientCount <= 1) return short;
    final totalSeconds = recipientCount * pace.seconds;
    final est = _formatDurationEstimate(totalSeconds, l10n);
    return l10n.paceWithEstimate(short, est) as String;
  }

  String _formatMinutesOfDay(int minOfDay) {
    final h = (minOfDay ~/ 60).toString().padLeft(2, '0');
    final m = (minOfDay % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _defaultCampaignName() {
    if (_campaignTitle != null && _campaignTitle!.trim().isNotEmpty) {
      return _campaignTitle!.trim();
    }
    if (_selectedListIds.length == 1) {
      final list = _listSummariesById[_selectedListIds.first];
      if (list != null) return list.list.name;
    }
    final firstLine = _bodyController.text.trim().split('\n').first;
    if (firstLine.length <= 28) return firstLine;
    return '${firstLine.substring(0, 28)}...';
  }

  Future<void> _submit() async {
    final template = _bodyController.text.trim();
    final recipients = _resolution.recipients;
    if (template.isEmpty || recipients.isEmpty || _submitting) return;

    final l10n = context.l10n;
    final settings = _templateSettings(context);

    // Without SMS permission, open system SMS app (Spec 11 degraded mode)
    if (!_hasSmsPermission) {
      final first = recipients.first;
      final rendered = renderTemplate(
        template,
        first.toTemplatePerson(currencyCode: settings.currencyCode),
        settings,
      );
      final uri = Uri(
        scheme: 'sms',
        path: first.address,
        queryParameters: {'body': rendered.text},
      );
      if (widget.onLaunchUri != null) {
        await widget.onLaunchUri!(uri);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      if (mounted && (GoRouter.maybeOf(context)?.canPop() ?? false)) {
        context.pop();
      }
      return;
    }

    // Sending now to > 10 people asks confirmation once (03-screens.md line 111)
    if (_sendNow && recipients.length > 10) {
      final simLabel = _sims.isNotEmpty
          ? 'SIM ${(_sims.firstWhere((s) => s.subId == _selectedSubId, orElse: () => _sims.first).slot) + 1}'
          : l10n.defaultSimLabel;
      final est = _formatDurationEstimate(recipients.length * _pace.seconds, l10n);
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.confirmBulkSendTitle(recipients.length, simLabel)),
          content: Text(l10n.confirmBulkSendBody(est)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.cancelAction),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.sendAction),
            ),
          ],
        ),
      );
      if (ok != true || !mounted) return;
    }

    setState(() => _submitting = true);
    try {
      final now = ref.read(clockProvider)();
      final dueAtMs = _sendNow
          ? now.millisecondsSinceEpoch
          : _scheduledAt.millisecondsSinceEpoch;
      final campaignId = await ref.read(campaignsRepositoryProvider).scheduleMessageOrCampaign(
            name: _defaultCampaignName(),
            templateBody: template,
            recipients: recipients,
            dueAtMs: dueAtMs,
            settings: settings,
            subId: _selectedSubId,
            paceSeconds: _pace.seconds,
            windowStartMin: _windowStartMin,
            windowEndMin: _windowEndMin,
          );
      if (!mounted) return;
      if (widget.onScheduled != null) {
        widget.onScheduled!(campaignId);
        return;
      }
      if (campaignId != null) {
        context.pushReplacement('/messages/campaign/$campaignId');
      } else {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/messages');
        }
      }
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

    final recipients = _resolution.recipients;
    final isBulk = recipients.length > 1;
    final template = _bodyController.text;
    final settings = _templateSettings(context);

    // Render every recipient to compute worst-case SMS counter, unknown fields, and "Check these"
    final renderedAll = <RenderedTemplate>[
      for (final r in recipients)
        renderTemplate(
          template,
          r.toTemplatePerson(currencyCode: settings.currencyCode),
          settings,
        ),
    ];

    final unknownFields = <String>{};
    final missingRecipients = <(ResolvedRecipient, List<String>)>[];
    int minSegments = 999;
    int maxSegments = 0;
    SmsCount maxCount = countSms(template);

    if (renderedAll.isNotEmpty) {
      for (var i = 0; i < renderedAll.length; i++) {
        final rt = renderedAll[i];
        unknownFields.addAll(rt.unknownFields);
        if (rt.emptyFieldsWithoutFallback.isNotEmpty) {
          missingRecipients.add((recipients[i], rt.emptyFieldsWithoutFallback));
        }
        final sc = countSms(rt.text);
        final seg = sc.segments == 0 ? 1 : sc.segments;
        if (seg < minSegments) minSegments = seg;
        if (seg > maxSegments) {
          maxSegments = seg;
          maxCount = sc;
        } else if (seg == maxSegments && sc.units > maxCount.units) {
          maxCount = sc;
        }
      }
    } else {
      final probe = renderTemplate(
        template,
        const TemplatePerson(displayName: 'Amara Okafor', company: 'Okafor Textiles', amountDue: 240),
        settings,
      );
      unknownFields.addAll(probe.unknownFields);
      maxCount = countSms(template);
      minSegments = maxCount.segments == 0 ? 1 : maxCount.segments;
      maxSegments = minSegments;
    }

    final counterLabel = (renderedAll.length > 1 && minSegments != maxSegments)
        ? l10n.composerCounterRange(minSegments, maxSegments)
        : l10n.composerCounterSingle(
            maxCount.segments == 0 ? 1 : maxCount.segments,
            maxCount.units,
            maxCount.perSegmentLimit,
          );

    // Skipped captions
    final skippedParts = <String>[];
    final noMobile = _resolution.countSkipped(SkipReason.noMobile);
    final optedOut = _resolution.countSkipped(SkipReason.optedOut);
    final dup = _resolution.countSkipped(SkipReason.duplicate);
    if (noMobile > 0) skippedParts.add(l10n.skippedNoMobile(noMobile));
    if (optedOut > 0) skippedParts.add(l10n.skippedOptedOut(optedOut));
    if (dup > 0) skippedParts.add(l10n.skippedDuplicate(dup));

    // Preview recipient
    final currentRecipient = recipients.isNotEmpty
        ? recipients[_previewIndex.clamp(0, recipients.length - 1)]
        : null;
    final currentRendered = renderedAll.isNotEmpty
        ? renderedAll[_previewIndex.clamp(0, renderedAll.length - 1)]
        : null;

    final selectedSim = _sims.isNotEmpty
        ? _sims.firstWhere((s) => s.subId == _selectedSubId, orElse: () => _sims.first)
        : null;

    final sendValue = _sendNow
        ? l10n.sendNowOption
        : fmt.formatRelativeDateTime(_scheduledAt.millisecondsSinceEpoch, l10n);

    final primaryLabel = !_hasSmsPermission
        ? l10n.openInSmsAppAction
        : (_sendNow
            ? l10n.composerSendNMessages(recipients.isEmpty ? 1 : recipients.length)
            : l10n.composerScheduleNMessages(recipients.isEmpty ? 1 : recipients.length));

    final canSubmit = template.trim().isNotEmpty && recipients.isNotEmpty && !_submitting;

    return Scaffold(
      backgroundColor: c.bgCanvas,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar: Close, "New message", Templates
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppTokens.space8,
                AppTokens.space8,
                AppTokens.space12,
                AppTokens.space4,
              ),
              child: Row(
                children: [
                  IconButton(
                    tooltip: l10n.cancelAction,
                    icon: Icon(Icons.close, color: c.textPrimary),
                    onPressed: _handleClose,
                  ),
                  const SizedBox(width: AppTokens.space4),
                  Expanded(
                    child: Text(
                      l10n.newMessageTitle,
                      style: tt.titleMedium!.copyWith(color: c.textPrimary),
                    ),
                  ),
                  AppButton(
                    label: l10n.composerTemplatesAction,
                    variant: AppButtonVariant.quiet,
                    size: AppButtonSize.small,
                    onPressed: _openTemplatesPicker,
                  ),
                ],
              ),
            ),

            // Scrollable form body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  top: AppTokens.space8,
                  bottom: AppTokens.space16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTokens.screenPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                    // To
                    Text(
                      l10n.composerToLabel,
                      style: tt.labelLarge!.copyWith(color: c.textSecondary),
                    ),
                    const SizedBox(height: AppTokens.space8),
                    Wrap(
                      spacing: AppTokens.space8,
                      runSpacing: AppTokens.space8,
                      children: [
                        for (final listId in _selectedListIds)
                          AppChip(
                            label: () {
                              final sum = _listSummariesById[listId];
                              final name = sum?.list.name ?? 'List';
                              final count = sum != null ? sum.memberCount : recipients.length;
                              return '$name · $count';
                            }(),
                            selected: true,
                            onTap: () {
                              setState(() => _selectedListIds.remove(listId));
                              unawaited(_resolveRecipients());
                            },
                          ),
                        for (final cid in _selectedContactIds)
                          AppChip(
                            label: _contactsById[cid]?.displayName ?? '#$cid',
                            selected: true,
                            onTap: () {
                              setState(() => _selectedContactIds.remove(cid));
                              unawaited(_resolveRecipients());
                            },
                          ),
                        AppChip(
                          label: l10n.composerAddPeople,
                          onTap: _openRecipientPicker,
                        ),
                      ],
                    ),
                    if (skippedParts.isNotEmpty) ...[
                      const SizedBox(height: AppTokens.space8),
                      Text(
                        skippedParts.join(' · '),
                        style: tt.bodySmall!.copyWith(color: c.textSecondary),
                      ),
                    ],

                    const SizedBox(height: AppTokens.space20),

                    // Message bordered surface box
                    Text(
                      l10n.composerMessageLabel,
                      style: tt.labelLarge!.copyWith(color: c.textSecondary),
                    ),
                    const SizedBox(height: AppTokens.space8),
                    Container(
                      decoration: BoxDecoration(
                        color: c.bgSurface,
                        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
                        border: Border.all(color: c.borderHairline),
                      ),
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        AppTokens.space16,
                        AppTokens.space12,
                        AppTokens.space16,
                        AppTokens.space12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _bodyController,
                            maxLines: 6,
                            minLines: 3,
                            style: tt.bodyLarge!.copyWith(color: c.textPrimary),
                            decoration: InputDecoration(
                              hintText: l10n.messageFieldHint,
                              hintStyle: tt.bodyLarge!.copyWith(color: c.textTertiary),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: AppTokens.space12),
                          if (MediaQuery.textScalerOf(context).scale(14) > 20) ...[
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  AppChip(
                                    label: l10n.mergeChipFirstName,
                                    onTap: () {
                                      _bodyController.insertMergeField('first name');
                                      setState(() {});
                                    },
                                  ),
                                  const SizedBox(width: AppTokens.space8),
                                  AppChip(
                                    label: l10n.mergeChipAmountDue,
                                    onTap: () {
                                      _bodyController.insertMergeField('amount due');
                                      setState(() {});
                                    },
                                  ),
                                  const SizedBox(width: AppTokens.space8),
                                  AppChip(
                                    label: l10n.mergeChipCompany,
                                    onTap: () {
                                      _bodyController.insertMergeField('company');
                                      setState(() {});
                                    },
                                  ),
                                  const SizedBox(width: AppTokens.space8),
                                  AppChip(
                                    label: l10n.mergeChipName,
                                    onTap: () {
                                      _bodyController.insertMergeField('name');
                                      setState(() {});
                                    },
                                  ),
                                  const SizedBox(width: AppTokens.space8),
                                  AppChip(
                                    label: l10n.mergeChipMyName,
                                    onTap: () {
                                      _bodyController.insertMergeField('my name');
                                      setState(() {});
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppTokens.space8),
                            Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: Text(
                                counterLabel,
                                style: tt.bodySmall!.copyWith(color: c.textSecondary),
                              ),
                            ),
                          ] else
                          Row(
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      AppChip(
                                        label: l10n.mergeChipFirstName,
                                        onTap: () {
                                          _bodyController.insertMergeField('first name');
                                          setState(() {});
                                        },
                                      ),
                                      const SizedBox(width: AppTokens.space8),
                                      AppChip(
                                        label: l10n.mergeChipAmountDue,
                                        onTap: () {
                                          _bodyController.insertMergeField('amount due');
                                          setState(() {});
                                        },
                                      ),
                                      const SizedBox(width: AppTokens.space8),
                                      AppChip(
                                        label: l10n.mergeChipCompany,
                                        onTap: () {
                                          _bodyController.insertMergeField('company');
                                          setState(() {});
                                        },
                                      ),
                                      const SizedBox(width: AppTokens.space8),
                                      AppChip(
                                        label: l10n.mergeChipName,
                                        onTap: () {
                                          _bodyController.insertMergeField('name');
                                          setState(() {});
                                        },
                                      ),
                                      const SizedBox(width: AppTokens.space8),
                                      AppChip(
                                        label: l10n.mergeChipMyName,
                                        onTap: () {
                                          _bodyController.insertMergeField('my name');
                                          setState(() {});
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppTokens.space8),
                              Text(
                                counterLabel,
                                style: tt.bodySmall!.copyWith(color: c.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    if (unknownFields.isNotEmpty) ...[
                      const SizedBox(height: AppTokens.space8),
                      Text(
                        l10n.unknownMergeFieldsWarning(unknownFields.join(', ')),
                        style: tt.bodySmall!.copyWith(color: c.statusDanger),
                      ),
                    ],

                    // Preview block (shown for 2+ recipients, or when merge fields are present)
                    if (currentRecipient != null &&
                        currentRendered != null &&
                        (isBulk || template.contains('{'))) ...[
                      const SizedBox(height: AppTokens.space20),
                      Row(
                        children: [
                          Text(
                            l10n.composerPreviewLabel,
                            style: tt.labelLarge!.copyWith(color: c.textPrimary),
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: recipients.length > 1
                                ? () => setState(() {
                                      _previewIndex = (_previewIndex + 1) % recipients.length;
                                    })
                                : null,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: AppTokens.space4),
                              child: Text(
                                l10n.composerPreviewCounter(
                                  currentRecipient.contact.displayName,
                                  _previewIndex + 1,
                                  recipients.length,
                                ),
                                style: tt.bodySmall!.copyWith(color: c.textSecondary),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTokens.space8),
                      GestureDetector(
                        onHorizontalDragEnd: recipients.length > 1
                            ? (details) {
                                final v = details.primaryVelocity ?? 0;
                                if (v < 0) {
                                  setState(() {
                                    _previewIndex = (_previewIndex + 1) % recipients.length;
                                  });
                                } else if (v > 0) {
                                  setState(() {
                                    _previewIndex = (_previewIndex - 1 + recipients.length) %
                                        recipients.length;
                                  });
                                }
                              }
                            : null,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppTokens.space16),
                          decoration: BoxDecoration(
                            color: c.bgSubtle,
                            borderRadius: BorderRadius.circular(AppTokens.radiusCard),
                          ),
                          child: Text(
                            currentRendered.text,
                            style: tt.bodyLarge!.copyWith(color: c.textPrimary),
                          ),
                        ),
                      ),
                      if (currentRendered.emptyFieldsWithoutFallback.isNotEmpty) ...[
                        const SizedBox(height: AppTokens.space4),
                        Text(
                          l10n.previewMissingFieldWarning(
                            currentRendered.emptyFieldsWithoutFallback.join(', '),
                          ),
                          style: tt.bodySmall!.copyWith(color: c.statusWarning),
                        ),
                      ],
                    ],

                    if (missingRecipients.isNotEmpty) ...[
                      const SizedBox(height: AppTokens.space8),
                      Text(
                        l10n.checkTheseRecipients(
                          missingRecipients.length,
                          missingRecipients
                              .expand((e) => e.$2)
                              .toSet()
                              .join(', '),
                        ),
                        style: tt.bodySmall!.copyWith(color: c.statusWarning),
                      ),
                    ],

                    const SizedBox(height: AppTokens.space16),
                        ],
                      ),
                    ),

                    // Send / From / Pace setting rows (SettingRow provides its own horizontal padding)
                    SettingRow(
                      label: l10n.composerSendLabel,
                      value: sendValue,
                      onTap: _pickSendTime,
                    ),
                    if (!_sendNow && !_exactAlarms)
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          AppTokens.screenPadding,
                          0,
                          AppTokens.screenPadding,
                          AppTokens.space8,
                        ),
                        child: Text(
                          l10n.mayBeMinutesLateNotice,
                          style: tt.bodySmall!.copyWith(color: c.textSecondary),
                        ),
                      ),
                    if (selectedSim != null && _sims.length >= 2)
                      SettingRow(
                        label: l10n.fromSimLabel,
                        value: 'SIM ${selectedSim.slot + 1}',
                        onTap: _pickSim,
                      ),
                    if (isBulk)
                      SettingRow(
                        label: l10n.composerPaceLabel,
                        value: _formatPaceValue(_pace, recipients.length, l10n),
                        onTap: _pickPace,
                      ),
                  ],
                ),
              ),
            ),

            // Pinned primary action & send window caption
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppTokens.screenPadding,
                AppTokens.space8,
                AppTokens.screenPadding,
                AppTokens.space12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppButton(
                    label: primaryLabel,
                    variant: AppButtonVariant.primary,
                    fullWidth: true,
                    onPressed: canSubmit ? _submit : null,
                  ),
                  const SizedBox(height: AppTokens.space8),
                  Center(
                    child: InkWell(
                      onTap: () => context.push('/settings'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppTokens.space4),
                        child: Text(
                          l10n.composerSendWindowCaption(
                            _formatMinutesOfDay(_windowStartMin),
                            _formatMinutesOfDay(_windowEndMin),
                          ),
                          style: tt.bodySmall!.copyWith(color: c.textSecondary),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

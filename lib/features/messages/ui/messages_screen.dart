import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/db/app_database.dart';
import '../../../core/format/app_formatters.dart';
import '../../../core/l10n_ext.dart';
import '../../../core/messages/sms_counter.dart';
import '../../../core/messages/template_renderer.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../data/campaigns_repository.dart';
import '../data/outbox_repository.dart';
import 'merge_field_controller.dart';

enum _MessagesView { outbox, campaigns, templates }

final _needsAttentionOutboxProvider =
    StreamProvider.autoDispose<List<OutboxWithPersonRow>>((ref) {
  return ref.watch(todayRepositoryProvider).watchNeedsAttention();
});

final _queuedSinglesProvider =
    StreamProvider.autoDispose<List<OutboxWithPersonRow>>((ref) {
  return ref.watch(campaignsRepositoryProvider).watchQueuedSingles();
});

final _campaignsListProvider =
    StreamProvider.autoDispose<List<CampaignSummaryRow>>((ref) {
  return ref.watch(campaignsRepositoryProvider).watchCampaignSummaries();
});

final _templatesListProvider = StreamProvider.autoDispose<List<Template>>((ref) {
  return ref.watch(templatesRepositoryProvider).watchAll();
});

final _sentThisWeekCountProvider = StreamProvider.autoDispose<int>((ref) {
  final now = ref.watch(clockProvider)();
  return ref.watch(campaignsRepositoryProvider).watchSentThisWeekCount(now: now);
});

final _sentListProvider =
    StreamProvider.autoDispose.family<List<OutboxWithPersonRow>, String?>((ref, filter) {
  return ref.watch(campaignsRepositoryProvider).watchSentMessages(statusFilter: filter);
});

/// Messages tab (Figma frame `9:471`, route `/messages`).
class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({
    super.key,
    this.onNewMessage,
    this.onOpenCampaign,
    this.onOpenSent,
    this.onOpenTemplate,
  });

  final VoidCallback? onNewMessage;
  final void Function(String campaignId)? onOpenCampaign;
  final VoidCallback? onOpenSent;
  final void Function(String templateId)? onOpenTemplate;

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  _MessagesView _view = _MessagesView.outbox;
  bool _searching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    unawaited(ref.read(templatesRepositoryProvider).seedDefaultsIfEmpty());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openNewMessage() {
    if (widget.onNewMessage != null) {
      widget.onNewMessage!();
    } else {
      context.push('/messages/new');
    }
  }

  void _openCampaign(String id) {
    if (widget.onOpenCampaign != null) {
      widget.onOpenCampaign!(id);
    } else {
      context.push('/messages/campaign/$id');
    }
  }

  void _openSent() {
    if (widget.onOpenSent != null) {
      widget.onOpenSent!();
    } else {
      context.push('/messages/sent');
    }
  }

  void _openTemplate(String id) {
    if (widget.onOpenTemplate != null) {
      widget.onOpenTemplate!(id);
    } else {
      context.push('/messages/templates/$id');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final clock = ref.watch(clockProvider);
    final now = clock();
    final fmt = AppFormatters(
      clock: clock,
      localeName: Localizations.localeOf(context).toLanguageTag(),
      use24Hour: MediaQuery.alwaysUse24HourFormatOf(context),
    );

    final attention = ref.watch(_needsAttentionOutboxProvider).value ?? const [];
    final singles = ref.watch(_queuedSinglesProvider).value ?? const [];
    final campaigns = ref.watch(_campaignsListProvider).value ?? const [];
    final templates = ref.watch(_templatesListProvider).value ?? const [];
    final sentThisWeek = ref.watch(_sentThisWeekCountProvider).value ?? 0;

    final query = _searchController.text.trim().toLowerCase();

    final scheduledCampaigns = campaigns
        .where((cs) =>
            cs.campaign.status == 'scheduled' ||
            cs.campaign.status == 'sending' ||
            cs.campaign.status == 'paused')
        .toList();

    final totalScheduledItems = singles.length + scheduledCampaigns.length;
    final summaryParts = <String>[
      if (totalScheduledItems > 0) l10n.messagesSummaryScheduled(totalScheduledItems),
      if (attention.isNotEmpty) l10n.messagesSummaryAttention(attention.length),
    ];

    return Scaffold(
      backgroundColor: c.bgCanvas,
      floatingActionButton: AppFab(
        icon: Icons.edit_outlined,
        semanticLabel: l10n.newMessageFabTooltip,
        onPressed: _openNewMessage,
      ),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  AppTokens.screenPadding,
                  AppTokens.space16,
                  AppTokens.space12,
                  AppTokens.space8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.navMessages,
                                style: tt.headlineMedium!.copyWith(color: c.textPrimary),
                              ),
                              if (summaryParts.isNotEmpty) ...[
                                const SizedBox(height: AppTokens.space4),
                                Text(
                                  summaryParts.join(' · '),
                                  style: tt.bodyMedium!.copyWith(color: c.textSecondary),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: l10n.messagesSearchTooltip,
                          icon: Icon(
                            _searching ? Icons.close : Icons.search,
                            color: c.textPrimary,
                          ),
                          onPressed: () {
                            setState(() {
                              _searching = !_searching;
                              if (!_searching) _searchController.clear();
                            });
                          },
                        ),
                      ],
                    ),
                    if (_searching) ...[
                      const SizedBox(height: AppTokens.space12),
                      AppField(
                        controller: _searchController,
                        hintText: l10n.messagesSearchTooltip,
                        leadingIcon: Icons.search,
                        autofocus: true,
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                    const SizedBox(height: AppTokens.space12),
                    Wrap(
                      spacing: AppTokens.space8,
                      children: [
                        AppChip(
                          label: l10n.messagesViewOutbox,
                          selected: _view == _MessagesView.outbox,
                          onTap: () => setState(() => _view = _MessagesView.outbox),
                        ),
                        AppChip(
                          label: l10n.messagesViewCampaigns,
                          selected: _view == _MessagesView.campaigns,
                          onTap: () => setState(() => _view = _MessagesView.campaigns),
                        ),
                        AppChip(
                          label: l10n.messagesViewTemplates,
                          selected: _view == _MessagesView.templates,
                          onTap: () => setState(() => _view = _MessagesView.templates),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // View body
            if (_view == _MessagesView.outbox)
              ..._buildOutboxSlivers(
                context: context,
                now: now,
                fmt: fmt,
                attention: attention,
                singles: singles,
                scheduledCampaigns: scheduledCampaigns,
                sentThisWeek: sentThisWeek,
                query: query,
              )
            else if (_view == _MessagesView.campaigns)
              ..._buildCampaignsSlivers(
                context: context,
                fmt: fmt,
                campaigns: campaigns,
                query: query,
              )
            else
              ..._buildTemplatesSlivers(
                context: context,
                templates: templates,
                query: query,
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 88)),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOutboxSlivers({
    required BuildContext context,
    required DateTime now,
    required AppFormatters fmt,
    required List<OutboxWithPersonRow> attention,
    required List<OutboxWithPersonRow> singles,
    required List<CampaignSummaryRow> scheduledCampaigns,
    required int sentThisWeek,
    required String query,
  }) {
    final l10n = context.l10n;
    final outboxRepo = ref.read(outboxRepositoryProvider);

    bool matches(String a, String b) =>
        query.isEmpty || a.toLowerCase().contains(query) || b.toLowerCase().contains(query);

    final filteredAttention =
        attention.where((i) => matches(i.personName, i.message.body)).toList();

    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrowStart = todayStart.add(const Duration(days: 1));
    final dayAfterStart = todayStart.add(const Duration(days: 2));

    final todayItems = <_OutboxBucketItem>[];
    final tomorrowItems = <_OutboxBucketItem>[];
    final laterItems = <_OutboxBucketItem>[];

    void addToBucket(int dueAt, _OutboxBucketItem item) {
      final dt = DateTime.fromMillisecondsSinceEpoch(dueAt);
      if (dt.isBefore(tomorrowStart)) {
        todayItems.add(item);
      } else if (dt.isBefore(dayAfterStart)) {
        tomorrowItems.add(item);
      } else {
        laterItems.add(item);
      }
    }

    for (final cs in scheduledCampaigns) {
      if (!matches(cs.campaign.name, cs.campaign.bodyTemplate)) continue;
      final dueAt = cs.campaign.scheduledAt ?? cs.campaign.createdAt ?? now.millisecondsSinceEpoch;
      addToBucket(dueAt, _OutboxBucketItem.campaign(cs, dueAt));
    }
    for (final s in singles) {
      if (!matches(s.personName, s.message.body)) continue;
      addToBucket(s.message.dueAt, _OutboxBucketItem.single(s, s.message.dueAt));
    }

    todayItems.sort((a, b) => a.dueAt.compareTo(b.dueAt));
    tomorrowItems.sort((a, b) => a.dueAt.compareTo(b.dueAt));
    laterItems.sort((a, b) => a.dueAt.compareTo(b.dueAt));

    final isEmpty = filteredAttention.isEmpty &&
        todayItems.isEmpty &&
        tomorrowItems.isEmpty &&
        laterItems.isEmpty &&
        sentThisWeek == 0;

    if (isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            title: l10n.emptyOutboxTitle,
            message: l10n.emptyOutboxMessage,
          ),
        ),
      ];
    }

    Widget buildBucketRow(_OutboxBucketItem item) {
      if (item.campaign != null) {
        final cs = item.campaign!;
        final timeStr = fmt.formatTime(DateTime.fromMillisecondsSinceEpoch(item.dueAt));
        final simPart = cs.campaign.subId != null ? ' · SIM ${cs.campaign.subId}' : '';
        return EventRow(
          icon: Icons.people_outline,
          title: l10n.campaignToNPeople(cs.campaign.name, cs.totalCount),
          body: cs.campaign.bodyTemplate,
          timeLine: '$timeStr$simPart',
          onTap: () => _openCampaign(cs.campaign.id),
        );
      }
      final s = item.single!;
      final timeStr = fmt.formatTime(DateTime.fromMillisecondsSinceEpoch(item.dueAt));
      return EventRow(
        icon: Icons.schedule_outlined,
        title: s.personName,
        body: s.message.body,
        timeLine: timeStr,
        onTap: s.message.contactId != null
            ? () => context.push('/people/${s.message.contactId}')
            : null,
      );
    }

    return [
      if (filteredAttention.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: SectionHeader(
            title: l10n.sectionNeedsAttention,
            count: filteredAttention.length,
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = filteredAttention[index];
              final isMissed = item.message.status == 'missed';
              final reason = isMissed
                  ? l10n.statusMissed
                  : (item.message.errorCode != null
                      ? smsErrorReasonLabel(item.message.errorCode, l10n)
                      : (item.message.errorLabel ?? l10n.statusNotSent));
              final timeStr = fmt.formatRelativeDateTime(item.message.dueAt, l10n);
              return EventRow(
                icon: Icons.error_outline,
                title: isMissed
                    ? l10n.missedMessageTo(item.personName)
                    : l10n.notSentTo(item.personName),
                body: '$reason · $timeStr',
                isError: true,
                trailing: AppButton(
                  label: isMissed ? l10n.sendNowAction : l10n.retryAction,
                  variant: AppButtonVariant.secondary,
                  size: AppButtonSize.small,
                  onPressed: () => unawaited(outboxRepo.retry([item.message.clientId])),
                ),
                onLongPress: () => unawaited(outboxRepo.cancel([item.message.clientId])),
                onTap: item.message.campaignId != null
                    ? () => _openCampaign(item.message.campaignId!)
                    : (item.message.contactId != null
                        ? () => context.push('/people/${item.message.contactId}')
                        : null),
              );
            },
            childCount: filteredAttention.length,
          ),
        ),
      ],
      if (todayItems.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: SectionHeader(title: l10n.todayLabel, count: todayItems.length),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) => buildBucketRow(todayItems[i]),
            childCount: todayItems.length,
          ),
        ),
      ],
      if (tomorrowItems.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: SectionHeader(title: l10n.sectionTomorrow, count: tomorrowItems.length),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) => buildBucketRow(tomorrowItems[i]),
            childCount: tomorrowItems.length,
          ),
        ),
      ],
      if (laterItems.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: SectionHeader(title: l10n.sectionLater, count: laterItems.length),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) => buildBucketRow(laterItems[i]),
            childCount: laterItems.length,
          ),
        ),
      ],
      SliverToBoxAdapter(child: SectionHeader(title: l10n.sectionEarlier)),
      SliverToBoxAdapter(
        child: SettingRow(
          label: l10n.sentThisWeekLabel,
          value: '$sentThisWeek',
          onTap: _openSent,
        ),
      ),
    ];
  }

  List<Widget> _buildCampaignsSlivers({
    required BuildContext context,
    required AppFormatters fmt,
    required List<CampaignSummaryRow> campaigns,
    required String query,
  }) {
    final l10n = context.l10n;
    final filtered = campaigns
        .where((c) =>
            query.isEmpty ||
            c.campaign.name.toLowerCase().contains(query) ||
            c.campaign.bodyTemplate.toLowerCase().contains(query))
        .toList();

    if (filtered.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            title: l10n.emptyCampaignsTitle,
            message: l10n.emptyCampaignsMessage,
          ),
        ),
      ];
    }

    return [
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final cs = filtered[index];
            final stateText = switch (cs.campaign.status) {
              'scheduled' => cs.campaign.scheduledAt != null
                  ? l10n.campaignStateScheduled(
                      fmt.formatRelativeDateTime(cs.campaign.scheduledAt!, l10n),
                    )
                  : l10n.statusScheduled,
              'paused' => l10n.campaignStatePaused(cs.completedCount, cs.totalCount),
              'stopped' => l10n.campaignStateStopped(cs.completedCount, cs.totalCount),
              'done' => cs.failedCount > 0
                  ? l10n.campaignStateDoneWithFailed(cs.deliveredOrSentCount, cs.failedCount)
                  : l10n.campaignStateDone(cs.deliveredOrSentCount),
              _ => l10n.campaignStateSending(cs.completedCount, cs.totalCount),
            };
            return EventRow(
              icon: Icons.people_outline,
              title: l10n.campaignToNPeople(cs.campaign.name, cs.totalCount),
              body: cs.campaign.bodyTemplate,
              timeLine: stateText,
              onTap: () => _openCampaign(cs.campaign.id),
            );
          },
          childCount: filtered.length,
        ),
      ),
    ];
  }

  List<Widget> _buildTemplatesSlivers({
    required BuildContext context,
    required List<Template> templates,
    required String query,
  }) {
    final l10n = context.l10n;
    final filtered = templates
        .where((t) =>
            query.isEmpty ||
            t.name.toLowerCase().contains(query) ||
            t.body.toLowerCase().contains(query))
        .toList();

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppTokens.screenPadding,
            AppTokens.space8,
            AppTokens.screenPadding,
            AppTokens.space4,
          ),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: AppButton(
              label: l10n.newTemplateAction,
              variant: AppButtonVariant.secondary,
              size: AppButtonSize.small,
              onPressed: () => _openTemplate('new'),
            ),
          ),
        ),
      ),
      if (filtered.isEmpty)
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            title: l10n.emptyTemplatesTitle,
            message: l10n.emptyTemplatesMessage,
          ),
        )
      else
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final tpl = filtered[index];
              return EventRow(
                icon: Icons.description_outlined,
                title: tpl.name,
                body: tpl.body,
                onTap: () => _openTemplate('${tpl.id}'),
              );
            },
            childCount: filtered.length,
          ),
        ),
    ];
  }
}

class _OutboxBucketItem {
  const _OutboxBucketItem._({required this.dueAt, this.single, this.campaign});

  factory _OutboxBucketItem.single(OutboxWithPersonRow row, int dueAt) =>
      _OutboxBucketItem._(dueAt: dueAt, single: row);

  factory _OutboxBucketItem.campaign(CampaignSummaryRow row, int dueAt) =>
      _OutboxBucketItem._(dueAt: dueAt, campaign: row);

  final int dueAt;
  final OutboxWithPersonRow? single;
  final CampaignSummaryRow? campaign;
}

/// Sent messages screen (`/messages/sent`).
class SentMessagesScreen extends ConsumerStatefulWidget {
  const SentMessagesScreen({super.key});

  @override
  ConsumerState<SentMessagesScreen> createState() => _SentMessagesScreenState();
}

class _SentMessagesScreenState extends ConsumerState<SentMessagesScreen> {
  String? _filter;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final clock = ref.watch(clockProvider);
    final fmt = AppFormatters(
      clock: clock,
      localeName: Localizations.localeOf(context).toLanguageTag(),
      use24Hour: MediaQuery.alwaysUse24HourFormatOf(context),
    );
    final rows = ref.watch(_sentListProvider(_filter)).value ?? const [];

    return Scaffold(
      backgroundColor: c.bgCanvas,
      appBar: AppBar(
        backgroundColor: c.bgCanvas,
        title: Text(l10n.sentMessagesTitle),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppTokens.screenPadding,
              vertical: AppTokens.space8,
            ),
            child: Row(
              children: [
                AppChip(
                  label: l10n.sentFilterAll,
                  selected: _filter == null,
                  onTap: () => setState(() => _filter = null),
                ),
                const SizedBox(width: AppTokens.space8),
                AppChip(
                  label: l10n.sentFilterDelivered,
                  selected: _filter == 'delivered',
                  onTap: () => setState(() => _filter = 'delivered'),
                ),
                const SizedBox(width: AppTokens.space8),
                AppChip(
                  label: l10n.sentFilterSent,
                  selected: _filter == 'sent',
                  onTap: () => setState(() => _filter = 'sent'),
                ),
                const SizedBox(width: AppTokens.space8),
                AppChip(
                  label: l10n.sentFilterNotSent,
                  selected: _filter == 'failed',
                  onTap: () => setState(() => _filter = 'failed'),
                ),
              ],
            ),
          ),
          Expanded(
            child: rows.isEmpty
                ? EmptyState(title: l10n.sentListEmpty, message: '')
                : ListView.builder(
                    itemCount: rows.length,
                    itemBuilder: (context, index) {
                      final item = rows[index];
                      final m = item.message;
                      final ts = m.deliveredAt ?? m.sentAt ?? m.dueAt;
                      final statusText = switch (m.status) {
                        'delivered' => l10n.statusDelivered,
                        'sent' => l10n.statusSent,
                        'missed' => l10n.statusMissed,
                        _ => l10n.statusNotSent,
                      };
                      final isErr = m.status == 'failed' || m.status == 'missed';
                      return EventRow(
                        icon: isErr ? Icons.error_outline : Icons.sms_outlined,
                        title: item.personName,
                        body: m.body,
                        timeLine: '${fmt.formatRelativeDateTime(ts, l10n)} · $statusText',
                        isError: isErr,
                        onTap: m.contactId != null
                            ? () => context.push('/people/${m.contactId}')
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Template editor screen (`/messages/templates/:id`).
class TemplateEditorScreen extends ConsumerStatefulWidget {
  const TemplateEditorScreen({super.key, required this.templateId});

  final String templateId;

  @override
  ConsumerState<TemplateEditorScreen> createState() => _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends ConsumerState<TemplateEditorScreen> {
  final TextEditingController _nameController = TextEditingController();
  final MergeFieldTextController _bodyController = MergeFieldTextController();
  int? _editingId;
  String? _errorText;
  String _myName = '';

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final myName = (await ref.read(settingsRepositoryProvider).get('my_name')) ?? '';
    final parsedId = int.tryParse(widget.templateId);
    Template? existing;
    if (parsedId != null) {
      existing = await ref.read(templatesRepositoryProvider).getById(parsedId);
    }
    if (!mounted) return;
    setState(() {
      _myName = myName;
      if (existing != null) {
        _editingId = existing.id;
        _nameController.text = existing.name;
        _bodyController.text = existing.body;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final name = _nameController.text.trim();
    final body = _bodyController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorText = l10n.templateValidationName);
      return;
    }
    if (body.isEmpty) {
      setState(() => _errorText = l10n.templateValidationBody);
      return;
    }
    await ref.read(templatesRepositoryProvider).upsertTemplate(
          id: _editingId,
          name: name,
          body: body,
        );
    if (mounted) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/messages');
      }
    }
  }

  Future<void> _delete() async {
    final id = _editingId;
    if (id == null) return;
    await ref.read(templatesRepositoryProvider).deleteTemplate(id);
    if (mounted) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/messages');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final currency = ref.watch(currencyCodeProvider).value ?? 'USD';

    final sample = renderTemplate(
      _bodyController.text,
      const TemplatePerson(
        displayName: 'Amara Okafor',
        company: 'Okafor Textiles',
        amountDue: 240,
      ),
      TemplateSettings(
        myName: _myName,
        currencyCode: currency,
        localeName: Localizations.localeOf(context).toLanguageTag(),
      ),
    );
    final smsCount = countSms(sample.text);

    return Scaffold(
      backgroundColor: c.bgCanvas,
      appBar: AppBar(
        backgroundColor: c.bgCanvas,
        title: Text(l10n.templateTitle),
        actions: [
          if (_editingId != null)
            IconButton(
              tooltip: l10n.templateDeleteAction,
              icon: Icon(Icons.delete_outline, color: c.statusDanger),
              onPressed: _delete,
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTokens.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.templateNameLabel,
                      style: tt.labelLarge!.copyWith(color: c.textSecondary),
                    ),
                    const SizedBox(height: AppTokens.space8),
                    AppField(
                      controller: _nameController,
                      hintText: l10n.templateNameHint,
                      onChanged: (_) => setState(() => _errorText = null),
                    ),
                    const SizedBox(height: AppTokens.space16),
                    Text(
                      l10n.templateBodyLabel,
                      style: tt.labelLarge!.copyWith(color: c.textSecondary),
                    ),
                    const SizedBox(height: AppTokens.space8),
                    Container(
                      decoration: BoxDecoration(
                        color: c.bgSurface,
                        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
                        border: Border.all(color: c.borderHairline),
                      ),
                      padding: const EdgeInsets.all(AppTokens.space16),
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
                            onChanged: (_) => setState(() => _errorText = null),
                          ),
                          const SizedBox(height: AppTokens.space12),
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
                                l10n.composerCounterSingle(
                                  smsCount.segments == 0 ? 1 : smsCount.segments,
                                  smsCount.units,
                                  smsCount.perSegmentLimit,
                                ),
                                style: tt.bodySmall!.copyWith(color: c.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (_errorText != null) ...[
                      const SizedBox(height: AppTokens.space8),
                      Text(
                        _errorText!,
                        style: tt.bodySmall!.copyWith(color: c.statusDanger),
                      ),
                    ],
                    if (_bodyController.text.trim().isNotEmpty) ...[
                      const SizedBox(height: AppTokens.space20),
                      Text(
                        l10n.templateSamplePreview,
                        style: tt.labelLarge!.copyWith(color: c.textSecondary),
                      ),
                      const SizedBox(height: AppTokens.space8),
                      Container(
                        padding: const EdgeInsets.all(AppTokens.space16),
                        decoration: BoxDecoration(
                          color: c.bgSubtle,
                          borderRadius: BorderRadius.circular(AppTokens.radiusCard),
                        ),
                        child: Text(
                          sample.text,
                          style: tt.bodyLarge!.copyWith(color: c.textPrimary),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppTokens.screenPadding,
                AppTokens.space8,
                AppTokens.screenPadding,
                AppTokens.space16,
              ),
              child: AppButton(
                label: l10n.templateSaveAction,
                variant: AppButtonVariant.primary,
                fullWidth: true,
                onPressed: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

import '../../../core/db/app_database.dart';
import '../../../core/format/app_formatters.dart';
import '../../../core/l10n_ext.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../../capture/data/capture_service.dart';
import '../../capture/ui/add_sheet.dart';
import '../../capture/ui/after_call_sheet.dart';
import '../../messages/ui/single_message_sheet.dart';
import '../../payments/data/payments_repository.dart';
import 'add_edit_person_sheet.dart';
import 'cadence_picker_sheet.dart';
import 'list_sheets.dart';

enum HistoryFilter {
  all,
  calls,
  messages,
  notes,
  visits,
  payments,
  files;

  Set<String>? get dbTypes => switch (this) {
        HistoryFilter.all => null,
        HistoryFilter.calls => const {'call_incoming', 'call_outgoing', 'call_missed'},
        HistoryFilter.messages => const {'sms_incoming', 'sms_outgoing'},
        HistoryFilter.notes => const {'note'},
        HistoryFilter.visits => const {'visit'},
        HistoryFilter.payments => const {'payment'},
        HistoryFilter.files => const {'attachment'},
      };
}

final _personProvider = StreamProvider.autoDispose.family<Contact?, int>((ref, id) {
  return ref.watch(peopleRepositoryProvider).watchById(id);
});

final _personPhonesProvider = StreamProvider.autoDispose.family<List<ContactPhone>, int>((ref, id) {
  return ref.watch(peopleRepositoryProvider).watchPhones(id);
});

final _personListsProvider = StreamProvider.autoDispose.family<List<ContactList>, int>((ref, id) {
  return ref.watch(listsRepositoryProvider).watchListsForPerson(id);
});

final _personFollowUpsProvider = StreamProvider.autoDispose.family<List<Task>, int>((ref, id) {
  return ref.watch(followUpsRepositoryProvider).watchOpenForPerson(id);
});

final _personScheduledOutboxProvider =
    StreamProvider.autoDispose.family<List<OutboxMessage>, int>((ref, id) {
  return ref.watch(historyRepositoryProvider).watchScheduledOutboxForPerson(id);
});

final _personBalancesProvider =
    StreamProvider.autoDispose.family<List<PersonBalance>, int>((ref, id) {
  final defaultCurrency = ref.watch(currencyCodeProvider).value ?? 'USD';
  return ref
      .watch(paymentsRepositoryProvider)
      .watchBalancesByCurrency(id, defaultCurrency: defaultCurrency);
});

final _personAttachmentsProvider =
    StreamProvider.autoDispose.family<Map<int, int>, int>((ref, id) {
  return ref.watch(historyRepositoryProvider).watchAttachmentCountsForPerson(id);
});

typedef _HistoryQueryKey = ({int contactId, HistoryFilter filter, int limit});

final _personHistoryProvider = StreamProvider.autoDispose
    .family<List<TimelineEntry>, _HistoryQueryKey>((ref, key) {
  return ref.watch(historyRepositoryProvider).watchForPerson(
        key.contactId,
        types: key.filter.dbTypes,
        limit: key.limit,
      );
});

class PersonScreen extends ConsumerStatefulWidget {
  const PersonScreen({
    super.key,
    required this.contactId,
    this.onLaunchUri,
  });

  final int contactId;

  /// Optional URI launcher override for tests.
  final Future<bool> Function(Uri uri)? onLaunchUri;

  @override
  ConsumerState<PersonScreen> createState() => _PersonScreenState();
}

class _PersonScreenState extends ConsumerState<PersonScreen> {
  static const int _pageSize = 50;

  HistoryFilter _historyFilter = HistoryFilter.all;
  int _historyLimit = _pageSize;
  final Set<int> _expandedMessages = <int>{};
  final Set<int> _completingTaskIds = <int>{};

  Future<void> _launch(Uri uri) async {
    if (widget.onLaunchUri != null) {
      await widget.onLaunchUri!(uri);
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  ContactPhone? _primaryPhone(Contact contact, List<ContactPhone> phones) {
    if (phones.isEmpty) return null;
    return phones.firstWhere(
      (p) => p.isPrimary == 1,
      orElse: () => phones.first,
    );
  }

  String _bestNumber(Contact contact, List<ContactPhone> phones) {
    final primary = _primaryPhone(contact, phones);
    return primary?.e164 ?? primary?.raw ?? contact.phoneNumber ?? '';
  }

  bool _isPrimaryMobile(Contact contact, List<ContactPhone> phones) {
    final primary = _primaryPhone(contact, phones);
    if (primary != null) {
      return primary.isMobile == 1;
    }
    final num = contact.phoneNumber ?? '';
    if (num.isEmpty) return false;
    return ref.read(phoneServiceProvider).isMobile(num);
  }

  Future<void> _callPerson(Contact contact, List<ContactPhone> phones, {bool pickNumber = false}) async {
    String? number;
    if (pickNumber && phones.length > 1) {
      number = await _pickNumberSheet(phones);
    } else {
      number = _bestNumber(contact, phones);
    }
    if (number == null || number.trim().isEmpty) return;
    await _launch(Uri(scheme: 'tel', path: number.trim()));
  }

  Future<void> _messagePerson(Contact contact, List<ContactPhone> phones, {String? body}) async {
    final number = _bestNumber(contact, phones);
    if (number.trim().isEmpty) return;
    await showSingleMessageSheet(
      context,
      contact: contact,
      address: number.trim(),
      initialBody: body,
      onLaunchUri: widget.onLaunchUri,
    );
  }

  Future<void> _whatsappPerson(Contact contact, List<ContactPhone> phones) async {
    final number = _bestNumber(contact, phones);
    final digits = number.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;
    await _launch(Uri.parse('https://wa.me/$digits'));
  }

  Future<String?> _pickNumberSheet(List<ContactPhone> phones) {
    return showAppSheet<String>(
      context: context,
      bodyBuilder: (ctx) {
        final l10n = ctx.l10n;
        final c = ctx.colors;
        final tt = Theme.of(ctx).textTheme;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppTokens.screenPadding,
                AppTokens.space8,
                AppTokens.screenPadding,
                AppTokens.space8,
              ),
              child: Text(
                l10n.pickNumberTitle,
                style: tt.titleMedium!.copyWith(color: c.textPrimary),
              ),
            ),
            for (final ph in phones)
              InkWell(
                onTap: () => Navigator.of(ctx).pop(ph.e164 ?? ph.raw ?? ''),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: AppTokens.minTouchTarget),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTokens.screenPadding,
                      vertical: AppTokens.space12,
                    ),
                    child: Text(
                      ph.e164 ?? ph.raw ?? '',
                      style: tt.bodyLarge!.copyWith(color: c.textPrimary),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: AppTokens.space12),
          ],
        );
      },
    );
  }

  Future<void> _completeFollowUp(Task task) async {
    if (_completingTaskIds.contains(task.id)) return;
    setState(() => _completingTaskIds.add(task.id));
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    if (!disableAnimations) {
      await Future<void>.delayed(AppTokens.taskCompleteDelay);
    }
    if (!mounted) return;
    await ref.read(followUpsRepositoryProvider).completeFollowUp(task.id);
    if (!mounted) return;
    setState(() => _completingTaskIds.remove(task.id));

    final l10n = context.l10n;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: AppTokens.undoSnackBarDuration,
          content: Text(l10n.followUpCompletedMessage),
          action: SnackBarAction(
            label: l10n.undoAction,
            onPressed: () {
              unawaited(ref.read(followUpsRepositoryProvider).uncompleteFollowUp(task.id));
            },
          ),
        ),
      );
  }

  Future<void> _openAddSheetForPerson(
    Contact contact, {
    AddEntryType? initialType,
    TimelineEntry? editingEntry,
  }) async {
    final token = await showAddSheet(
      context,
      fixedPerson: contact,
      initialType: initialType,
      editingEntry: editingEntry,
    );
    if (token != null && mounted) {
      showCaptureSavedSnackBar(context, ref, token);
    }
  }

  Future<void> _openAfterCallForEntry(Contact contact, TimelineEntry entry) async {
    final token = await showAfterCallSheet(
      context,
      contact: contact,
      callEntry: entry,
    );
    if (token != null && mounted) {
      showCaptureSavedSnackBar(context, ref, token);
    }
  }

  Future<void> _showQuickFollowUpSheet(Contact contact, {int? sourceTimelineId}) async {
    final controller = TextEditingController();
    int offsetDays = 1;
    await showAppSheet<void>(
      context: context,
      bodyBuilder: (ctx) {
        final l10n = ctx.l10n;
        final c = ctx.colors;
        final tt = Theme.of(ctx).textTheme;
        return StatefulBuilder(
          builder: (ctx, setState) {
            final canSave = controller.text.trim().isNotEmpty;
            return Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                AppTokens.screenPadding,
                AppTokens.space8,
                AppTokens.screenPadding,
                MediaQuery.viewInsetsOf(ctx).bottom + AppTokens.space16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.quickFollowUpTitle,
                    style: tt.titleMedium!.copyWith(color: c.textPrimary),
                  ),
                  const SizedBox(height: AppTokens.space12),
                  AppField(
                    controller: controller,
                    hintText: l10n.followUpTitleHint,
                    autofocus: true,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: AppTokens.space12),
                  Wrap(
                    spacing: AppTokens.space8,
                    children: [
                      AppChip(
                        label: l10n.dueTomorrow,
                        selected: offsetDays == 1,
                        onTap: () => setState(() => offsetDays = 1),
                      ),
                      AppChip(
                        label: l10n.dueInThreeDays,
                        selected: offsetDays == 3,
                        onTap: () => setState(() => offsetDays = 3),
                      ),
                      AppChip(
                        label: l10n.dueNextWeek,
                        selected: offsetDays == 7,
                        onTap: () => setState(() => offsetDays = 7),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTokens.space16),
                  AppButton(
                    label: l10n.saveFollowUpAction,
                    variant: AppButtonVariant.primary,
                    fullWidth: true,
                    onPressed: canSave
                        ? () async {
                            final now = ref.read(clockProvider)();
                            final due = DateTime(now.year, now.month, now.day + offsetDays, 9, 0);
                            await ref.read(followUpsRepositoryProvider).createFollowUp(
                                  contactId: contact.id,
                                  title: controller.text.trim(),
                                  dueDateMs: due.millisecondsSinceEpoch,
                                  sourceTimelineId: sourceTimelineId,
                                );
                            if (ctx.mounted) Navigator.of(ctx).pop();
                          }
                        : null,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showConfirmPaymentSheet(TimelineEntry entry, {required bool isLegacyUnconfirmed}) async {
    final currency = ref.read(currencyCodeProvider).value ?? 'USD';
    final amount = isLegacyUnconfirmed ? (entry.amount ?? 0) : (entry.suggestedAmount ?? 0);
    final chosenStatus = await showAppSheet<String>(
      context: context,
      bodyBuilder: (ctx) {
        final l10n = ctx.l10n;
        final c = ctx.colors;
        final tt = Theme.of(ctx).textTheme;
        final options = <(String, String)>[
          ('received', l10n.paymentStatusReceived),
          ('paid', l10n.paymentStatusPaid),
          ('owed_to_me', l10n.paymentStatusOwesMe),
          ('i_owe', l10n.paymentStatusIOwe),
        ];
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppTokens.screenPadding,
                AppTokens.space8,
                AppTokens.screenPadding,
                AppTokens.space8,
              ),
              child: Text(
                l10n.confirmPaymentTitle,
                style: tt.titleMedium!.copyWith(color: c.textPrimary),
              ),
            ),
            for (final (code, label) in options)
              InkWell(
                onTap: () => Navigator.of(ctx).pop(code),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: AppTokens.minTouchTarget),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTokens.screenPadding,
                      vertical: AppTokens.space12,
                    ),
                    child: Text(
                      label,
                      style: tt.bodyLarge!.copyWith(color: c.textPrimary),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: AppTokens.space12),
          ],
        );
      },
    );

    if (chosenStatus == null) return;
    final repo = ref.read(paymentsRepositoryProvider);
    if (isLegacyUnconfirmed) {
      await repo.confirmLegacyUnconfirmedPayment(
        timelineId: entry.id,
        paymentStatus: chosenStatus,
        currency: entry.currency ?? currency,
      );
    } else {
      await repo.confirmSuggestedPayment(
        timelineId: entry.id,
        amount: amount,
        paymentStatus: chosenStatus,
        currency: entry.currency ?? currency,
      );
    }
  }

  Future<void> _showEntryActionsSheet(Contact contact, TimelineEntry entry) async {
    final isDevice = entry.source == 'device' ||
        entry.type.startsWith('call_') ||
        entry.type.startsWith('sms_');
    await showAppSheet<void>(
      context: context,
      bodyBuilder: (ctx) {
        final l10n = ctx.l10n;
        final c = ctx.colors;
        final tt = Theme.of(ctx).textTheme;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () async {
                Navigator.of(ctx).pop();
                await _showQuickFollowUpSheet(contact, sourceTimelineId: entry.id);
              },
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: AppTokens.minTouchTarget),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTokens.screenPadding,
                    vertical: AppTokens.space12,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.add_task, size: 20, color: c.textPrimary),
                      const SizedBox(width: AppTokens.space12),
                      Text(
                        l10n.addFollowUpAction,
                        style: tt.bodyLarge!.copyWith(color: c.textPrimary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                Navigator.of(ctx).pop();
                final repo = ref.read(historyRepositoryProvider);
                if (isDevice) {
                  await repo.hideEntry(entry.id);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        duration: AppTokens.undoSnackBarDuration,
                        content: Text(l10n.entryHiddenMessage),
                        action: SnackBarAction(
                          label: l10n.undoAction,
                          onPressed: () => unawaited(repo.unhideEntry(entry.id)),
                        ),
                      ),
                    );
                } else {
                  final deleted = await repo.deleteEntry(entry.id);
                  if (!mounted || deleted == null) return;
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        duration: AppTokens.undoSnackBarDuration,
                        content: Text(l10n.entryDeletedMessage),
                        action: SnackBarAction(
                          label: l10n.undoAction,
                          onPressed: () => unawaited(repo.restoreEntry(deleted)),
                        ),
                      ),
                    );
                }
              },
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: AppTokens.minTouchTarget),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTokens.screenPadding,
                    vertical: AppTokens.space12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isDevice ? Icons.visibility_off_outlined : Icons.delete_outline,
                        size: 20,
                        color: c.statusDanger,
                      ),
                      const SizedBox(width: AppTokens.space12),
                      Text(
                        isDevice ? l10n.hideFromHistoryAction : l10n.deleteEntryAction,
                        style: tt.bodyLarge!.copyWith(color: c.statusDanger),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTokens.space12),
          ],
        );
      },
    );
  }

  Future<void> _confirmDeletePerson(Contact contact) async {
    final l10n = context.l10n;
    final repo = ref.read(peopleRepositoryProvider);
    final entryCount = await repo.countTimelineForPerson(contact.id);
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: Text(l10n.deletePersonTitle(contact.displayName)),
        content: Text(l10n.deletePersonConfirm(entryCount)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dCtx).pop(false),
            child: Text(l10n.cancelAction),
          ),
          TextButton(
            onPressed: () => Navigator.of(dCtx).pop(true),
            child: Text(
              l10n.deleteAction,
              style: TextStyle(color: dCtx.colors.statusDanger),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await repo.deletePerson(contact.id);
      if (mounted) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/people');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;

    final contactAsync = ref.watch(_personProvider(widget.contactId));
    final contact = contactAsync.value;
    if (contactAsync.hasValue && contact == null) {
      return Scaffold(
        backgroundColor: c.bgCanvas,
        appBar: AppBar(backgroundColor: c.bgCanvas),
        body: EmptyState(title: l10n.personNotFound, message: ''),
      );
    }
    if (contact == null) {
      return Scaffold(backgroundColor: c.bgCanvas);
    }

    final phones = ref.watch(_personPhonesProvider(contact.id)).value ?? const <ContactPhone>[];
    final lists = ref.watch(_personListsProvider(contact.id)).value ?? const <ContactList>[];
    final followUps = ref.watch(_personFollowUpsProvider(contact.id)).value ?? const <Task>[];
    final scheduledOutbox =
        ref.watch(_personScheduledOutboxProvider(contact.id)).value ?? const <OutboxMessage>[];
    final balances = ref.watch(_personBalancesProvider(contact.id)).value ?? const <PersonBalance>[];
    final attachmentCounts =
        ref.watch(_personAttachmentsProvider(contact.id)).value ?? const <int, int>{};
    final history = ref
            .watch(
              _personHistoryProvider(
                (contactId: contact.id, filter: _historyFilter, limit: _historyLimit),
              ),
            )
            .value ??
        const <TimelineEntry>[];

    final currency = ref.watch(currencyCodeProvider).value ?? 'USD';
    final locale = Localizations.localeOf(context).toLanguageTag();
    final clock = ref.watch(clockProvider);
    final fmt = AppFormatters(
      clock: clock,
      localeName: locale,
      currencyCode: currency,
      use24Hour: MediaQuery.alwaysUse24HourFormatOf(context),
    );

    final subtitleParts = [
      if (contact.company != null && contact.company!.trim().isNotEmpty) contact.company!.trim(),
      if (contact.city != null && contact.city!.trim().isNotEmpty) contact.city!.trim(),
    ];
    final subtitle = subtitleParts.join(' · ');
    final showWhatsApp = _isPrimaryMobile(contact, phones);
    final nextCount =
        followUps.length + scheduledOutbox.length + balances.length;

    return Scaffold(
      backgroundColor: c.bgCanvas,
      floatingActionButton: AppFab(
        icon: Icons.add,
        semanticLabel: l10n.addSheetTitle,
        onPressed: () => _openAddSheetForPerson(contact),
      ),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // Top bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  AppTokens.space8,
                  AppTokens.space8,
                  AppTokens.space8,
                  0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: l10n.backTooltip,
                      icon: Icon(Icons.arrow_back, color: c.textPrimary),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/people');
                        }
                      },
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: contact.isStarred == 1 ? l10n.unstarTooltip : l10n.starTooltip,
                      icon: Icon(
                        contact.isStarred == 1 ? Icons.star : Icons.star_border,
                        color: c.textPrimary,
                      ),
                      onPressed: () => ref.read(peopleRepositoryProvider).toggleStar(contact.id),
                    ),
                    PopupMenuButton<String>(
                      tooltip: l10n.moreTooltip,
                      icon: Icon(Icons.more_vert, color: c.textPrimary),
                      onSelected: (value) async {
                        switch (value) {
                          case 'edit':
                            await showAddEditPersonSheet(context, existing: contact);
                          case 'lists':
                            await showManageListsSheet(
                              context,
                              ref,
                              contactIds: {contact.id},
                              initialListIds: lists.map((l) => l.id).toSet(),
                              replaceExistingForSinglePerson: true,
                            );
                          case 'cadence':
                            final picked = await showCadencePickerSheet(
                              context,
                              currentDays: contact.cadenceDays,
                            );
                            if (picked != null) {
                              await ref
                                  .read(peopleRepositoryProvider)
                                  .setCadence(contact.id, picked.days);
                            }
                          case 'dnm':
                            await ref
                                .read(peopleRepositoryProvider)
                                .setDoNotMessage(contact.id, contact.doNotMessage != 1);
                          case 'export_csv':
                            await ref.read(exportServiceProvider).exportPersonHistoryCsv(contact);
                          case 'delete':
                            await _confirmDeletePerson(contact);
                        }
                      },
                      itemBuilder: (ctx) => [
                        PopupMenuItem(value: 'edit', child: Text(l10n.editPersonTitle)),
                        PopupMenuItem(value: 'lists', child: Text(l10n.actionAddToList)),
                        PopupMenuItem(value: 'cadence', child: Text(l10n.actionSetReconnect)),
                        PopupMenuItem(
                          value: 'dnm',
                          child: Row(
                            children: [
                              Expanded(child: Text(l10n.doNotMessageLabel)),
                              if (contact.doNotMessage == 1)
                                Icon(Icons.check, size: 18, color: ctx.colors.textPrimary),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'export_csv',
                          child: Text(l10n.exportHistoryCsvMenu),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            l10n.deletePersonMenu,
                            style: TextStyle(color: ctx.colors.statusDanger),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Identity block
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  AppTokens.screenPadding,
                  AppTokens.space8,
                  AppTokens.screenPadding,
                  AppTokens.space12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Avatar(
                          name: contact.displayName,
                          toneIndex: contact.id,
                          size: AppTokens.avatarLargeSize,
                        ),
                        const SizedBox(width: AppTokens.space16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                contact.displayName,
                                style: tt.titleLarge!.copyWith(color: c.textPrimary),
                              ),
                              if (subtitle.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  subtitle,
                                  style: tt.bodyMedium!.copyWith(color: c.textSecondary),
                                ),
                              ],
                              if (contact.doNotMessage == 1) ...[
                                const SizedBox(height: AppTokens.space4),
                                Text(
                                  l10n.askedNotToBeMessaged,
                                  style: tt.bodySmall!.copyWith(color: c.textTertiary),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTokens.space12),

                    // Attribute chips: reconnect + lists
                    Wrap(
                      spacing: AppTokens.space8,
                      runSpacing: AppTokens.space4,
                      children: [
                        AppChip(
                          label: contact.cadenceDays != null
                              ? l10n.reconnectEvery(
                                  fmt.formatCadence(contact.cadenceDays, l10n).toLowerCase(),
                                )
                              : l10n.setReconnectChip,
                          leadingIcon: Icons.schedule_outlined,
                          onTap: () async {
                            final picked = await showCadencePickerSheet(
                              context,
                              currentDays: contact.cadenceDays,
                            );
                            if (picked != null) {
                              await ref
                                  .read(peopleRepositoryProvider)
                                  .setCadence(contact.id, picked.days);
                            }
                          },
                        ),
                        for (final list in lists)
                          AppChip(
                            label: list.name,
                            onTap: () => showManageListsSheet(
                              context,
                              ref,
                              contactIds: {contact.id},
                              initialListIds: lists.map((l) => l.id).toSet(),
                              replaceExistingForSinglePerson: true,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppTokens.space16),

                    // Four action tiles
                    Row(
                      children: [
                        Expanded(
                          child: _PersonActionTile(
                            icon: Icons.call_outlined,
                            label: l10n.actionCall,
                            onTap: () => _callPerson(contact, phones),
                            onLongPress: phones.length > 1
                                ? () => _callPerson(contact, phones, pickNumber: true)
                                : null,
                          ),
                        ),
                        const SizedBox(width: AppTokens.space8),
                        Expanded(
                          child: _PersonActionTile(
                            icon: Icons.chat_bubble_outline,
                            label: l10n.actionMessage,
                            onTap: () => _messagePerson(contact, phones),
                          ),
                        ),
                        if (showWhatsApp) ...[
                          const SizedBox(width: AppTokens.space8),
                          Expanded(
                            child: _PersonActionTile(
                              icon: Icons.forum_outlined,
                              label: l10n.actionWhatsApp,
                              onTap: () => _whatsappPerson(contact, phones),
                            ),
                          ),
                        ],
                        const SizedBox(width: AppTokens.space8),
                        Expanded(
                          child: _PersonActionTile(
                            icon: Icons.edit_note_outlined,
                            label: l10n.actionNote,
                            onTap: () => _openAddSheetForPerson(
                              contact,
                              initialType: AddEntryType.note,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Next section (hidden if empty)
            if (nextCount > 0) ...[
              SliverToBoxAdapter(
                child: SectionHeader(title: l10n.sectionNext, count: nextCount),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  for (final task in followUps)
                    Builder(
                      builder: (context) {
                        final due = fmt.formatFollowUpDue(task.dueDate, l10n);
                        return TaskRow(
                          title: task.title,
                          meta: due.text,
                          isOverdue: due.isOverdue,
                          completed: _completingTaskIds.contains(task.id),
                          onToggle: () => _completeFollowUp(task),
                        );
                      },
                    ),
                  for (final msg in scheduledOutbox)
                    EventRow(
                      icon: Icons.schedule_outlined,
                      title: l10n.statusScheduled,
                      body: msg.body,
                      timeLine: fmt.formatRelativeDateTime(msg.dueAt, l10n),
                    ),
                  for (final balance in balances)
                    EventRow(
                      icon: Icons.account_balance_wallet_outlined,
                      title: balance.owesYou
                          ? l10n.owesYouAmount(
                              fmt.formatCurrency(
                                balance.absoluteAmount,
                                overrideCurrencyCode: balance.currency,
                              ),
                            )
                          : l10n.youOweAmount(
                              fmt.formatCurrency(
                                balance.absoluteAmount,
                                overrideCurrencyCode: balance.currency,
                              ),
                            ),
                      body: balance.latestUnpaidNote,
                      onTap: () => _showBalanceReminderSheet(contact, phones, balance, fmt),
                    ),
                ]),
              ),
            ],

            // History header + filter menu
            SliverToBoxAdapter(
              child: SectionHeader(
                title: l10n.sectionHistory,
                trailing: PopupMenuButton<HistoryFilter>(
                  tooltip: l10n.historyFilterTooltip,
                  initialValue: _historyFilter,
                  onSelected: (f) => setState(() {
                    _historyFilter = f;
                    _historyLimit = _pageSize;
                  }),
                  itemBuilder: (ctx) => [
                    PopupMenuItem(value: HistoryFilter.all, child: Text(l10n.historyFilterAll)),
                    PopupMenuItem(value: HistoryFilter.calls, child: Text(l10n.historyFilterCalls)),
                    PopupMenuItem(
                      value: HistoryFilter.messages,
                      child: Text(l10n.historyFilterMessages),
                    ),
                    PopupMenuItem(value: HistoryFilter.notes, child: Text(l10n.historyFilterNotes)),
                    PopupMenuItem(
                      value: HistoryFilter.visits,
                      child: Text(l10n.historyFilterVisits),
                    ),
                    PopupMenuItem(
                      value: HistoryFilter.payments,
                      child: Text(l10n.historyFilterPayments),
                    ),
                    PopupMenuItem(value: HistoryFilter.files, child: Text(l10n.historyFilterFiles)),
                  ],
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: AppTokens.minTouchTarget,
                      minHeight: AppTokens.minTouchTarget,
                    ),
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Icon(
                        Icons.filter_list,
                        size: 20,
                        color: _historyFilter == HistoryFilter.all
                            ? c.textSecondary
                            : c.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // History entries (grouped by month past current month)
            if (history.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTokens.screenPadding,
                    vertical: AppTokens.space24,
                  ),
                  child: Text(
                    _historyFilter == HistoryFilter.all
                        ? l10n.historyEmpty
                        : l10n.historyEmptyFiltered,
                    style: tt.bodyMedium!.copyWith(color: c.textTertiary),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildListDelegate(
                  _buildGroupedHistoryWidgets(
                    context: context,
                    contact: contact,
                    entries: history,
                    attachmentCounts: attachmentCounts,
                    fmt: fmt,
                  ),
                ),
              ),

            if (history.length >= _historyLimit)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTokens.screenPadding,
                    vertical: AppTokens.space12,
                  ),
                  child: Center(
                    child: AppButton(
                      label: l10n.loadMoreAction,
                      variant: AppButtonVariant.secondary,
                      size: AppButtonSize.small,
                      onPressed: () => setState(() => _historyLimit += _pageSize),
                    ),
                  ),
                ),
              ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 88),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showBalanceReminderSheet(
    Contact contact,
    List<ContactPhone> phones,
    PersonBalance balance,
    AppFormatters fmt,
  ) async {
    final amountText = fmt.formatCurrency(
      balance.absoluteAmount,
      overrideCurrencyCode: balance.currency,
    );
    await showAppSheet<void>(
      context: context,
      bodyBuilder: (ctx) {
        final l10n = ctx.l10n;
        final c = ctx.colors;
        final tt = Theme.of(ctx).textTheme;
        return Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppTokens.screenPadding,
            AppTokens.space8,
            AppTokens.screenPadding,
            AppTokens.space16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                balance.owesYou
                    ? l10n.owesYouAmount(amountText)
                    : l10n.youOweAmount(amountText),
                style: tt.titleMedium!.copyWith(color: c.textPrimary),
              ),
              if (balance.latestUnpaidNote != null &&
                  balance.latestUnpaidNote!.trim().isNotEmpty) ...[
                const SizedBox(height: AppTokens.space4),
                Text(
                  balance.latestUnpaidNote!,
                  style: tt.bodyMedium!.copyWith(color: c.textSecondary),
                ),
              ],
              const SizedBox(height: AppTokens.space16),
              AppButton(
                label: l10n.sendReminderAction,
                variant: AppButtonVariant.secondary,
                fullWidth: true,
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.push(
                    '/messages/new?contactId=${contact.id}&template=${Uri.encodeQueryComponent('Payment reminder')}',
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildGroupedHistoryWidgets({
    required BuildContext context,
    required Contact contact,
    required List<TimelineEntry> entries,
    required Map<int, int> attachmentCounts,
    required AppFormatters fmt,
  }) {
    final now = fmt.now;
    final widgets = <Widget>[];
    String? lastMonthKey;

    for (final entry in entries) {
      final dt = DateTime.fromMillisecondsSinceEpoch(entry.timestamp);
      final isCurrentMonth = dt.year == now.year && dt.month == now.month;
      if (!isCurrentMonth) {
        final monthKey = '${dt.year}-${dt.month}';
        if (monthKey != lastMonthKey) {
          lastMonthKey = monthKey;
          widgets.add(SectionHeader(title: fmt.formatMonthHeader(dt)));
        }
      }
      widgets.add(
        _buildHistoryRow(
          context: context,
          contact: contact,
          entry: entry,
          attachmentCount: attachmentCounts[entry.id] ?? 0,
          fmt: fmt,
        ),
      );
    }
    return widgets;
  }

  Widget _buildHistoryRow({
    required BuildContext context,
    required Contact contact,
    required TimelineEntry entry,
    required int attachmentCount,
    required AppFormatters fmt,
  }) {
    final l10n = context.l10n;
    final timeStr = fmt.formatRelativeDateTime(entry.timestamp, l10n);

    // Suggested payment on an SMS row
    if (entry.suggestionState == 'open' && entry.suggestedAmount != null) {
      final amountStr = fmt.formatCurrency(
        entry.suggestedAmount!,
        overrideCurrencyCode: entry.currency,
      );
      return EventRow(
        icon: Icons.payments_outlined,
        title: l10n.suggestedPaymentTitle(amountStr),
        body: entry.content,
        timeLine: timeStr,
        footer: Row(
          children: [
            AppButton(
              label: l10n.confirmAction,
              variant: AppButtonVariant.secondary,
              size: AppButtonSize.small,
              onPressed: () => _showConfirmPaymentSheet(entry, isLegacyUnconfirmed: false),
            ),
            const SizedBox(width: AppTokens.space8),
            AppButton(
              label: l10n.dismissAction,
              variant: AppButtonVariant.quiet,
              size: AppButtonSize.small,
              onPressed: () => ref.read(paymentsRepositoryProvider).dismissSuggestedPayment(entry.id),
            ),
          ],
        ),
        onLongPress: () => _showEntryActionsSheet(contact, entry),
      );
    }

    // Legacy unconfirmed payment row
    if (entry.type == 'payment' && entry.paymentStatus == 'unconfirmed') {
      final amountStr = fmt.formatCurrency(
        entry.amount ?? 0,
        overrideCurrencyCode: entry.currency,
      );
      return EventRow(
        icon: Icons.payments_outlined,
        title: l10n.suggestedPaymentTitle(amountStr),
        body: entry.note ?? entry.content,
        timeLine: timeStr,
        footer: Row(
          children: [
            AppButton(
              label: l10n.confirmAction,
              variant: AppButtonVariant.secondary,
              size: AppButtonSize.small,
              onPressed: () => _showConfirmPaymentSheet(entry, isLegacyUnconfirmed: true),
            ),
            const SizedBox(width: AppTokens.space8),
            AppButton(
              label: l10n.dismissAction,
              variant: AppButtonVariant.quiet,
              size: AppButtonSize.small,
              onPressed: () =>
                  ref.read(paymentsRepositoryProvider).dismissLegacyUnconfirmedPayment(entry.id),
            ),
          ],
        ),
        onLongPress: () => _showEntryActionsSheet(contact, entry),
      );
    }

    switch (entry.type) {
      case 'call_outgoing':
      case 'call_incoming':
      case 'call_missed':
        final baseLabel = switch (entry.type) {
          'call_outgoing' => l10n.callOutgoing,
          'call_missed' => l10n.callMissed,
          _ => l10n.callIncoming,
        };
        final dur = fmt.formatDuration(entry.durationSeconds, l10n);
        final title = (dur.isNotEmpty && entry.type != 'call_missed')
            ? '$baseLabel · $dur'
            : baseLabel;
        final icon = switch (entry.type) {
          'call_outgoing' => Icons.call_made,
          'call_missed' => Icons.call_missed,
          _ => Icons.call_received,
        };
        return EventRow(
          icon: icon,
          title: title,
          body: (entry.note != null && entry.note!.trim().isNotEmpty) ? entry.note : null,
          timeLine: timeStr,
          onTap: () => _openAfterCallForEntry(contact, entry),
          onLongPress: () => _showEntryActionsSheet(contact, entry),
        );

      case 'sms_incoming':
      case 'sms_outgoing':
        final isExpanded = _expandedMessages.contains(entry.id);
        final title =
            entry.type == 'sms_outgoing' ? l10n.messageSent : l10n.messageReceived;
        final isOptOut = entry.type == 'sms_incoming' && entry.outcome == 'opt_out';
        return EventRow(
          icon: Icons.chat_bubble_outline,
          title: title,
          body: entry.content,
          maxBodyLines: isExpanded ? 100 : 3,
          timeLine: isOptOut ? '$timeStr · ${l10n.askedNotToBeMessaged}' : timeStr,
          onTap: () => setState(() {
            if (isExpanded) {
              _expandedMessages.remove(entry.id);
            } else {
              _expandedMessages.add(entry.id);
            }
          }),
          onLongPress: () => _showEntryActionsSheet(contact, entry),
        );

      case 'visit':
        final place = entry.placeName?.trim();
        final title =
            (place != null && place.isNotEmpty) ? l10n.entryVisitPlace(place) : l10n.entryVisit;
        final metaTime = attachmentCount > 0
            ? '$timeStr · ${l10n.photoCount(attachmentCount)}'
            : timeStr;
        return EventRow(
          icon: Icons.location_on_outlined,
          title: title,
          body: (entry.note != null && entry.note!.trim().isNotEmpty) ? entry.note : null,
          timeLine: metaTime,
          onTap: () => _openAddSheetForPerson(contact, editingEntry: entry),
          onLongPress: () => _showEntryActionsSheet(contact, entry),
        );

      case 'payment':
        final amountStr = fmt.formatCurrency(
          entry.amount ?? 0,
          overrideCurrencyCode: entry.currency,
        );
        final title = switch (entry.paymentStatus) {
          'received' => l10n.paymentReceivedTitle(amountStr),
          'paid' => l10n.paymentPaidTitle(amountStr),
          'owed_to_me' => l10n.paymentOwedToMeTitle(amountStr),
          'i_owe' => l10n.paymentIOweTitle(amountStr),
          _ => l10n.paymentReceivedTitle(amountStr),
        };
        final body = (entry.note != null && entry.note!.trim().isNotEmpty)
            ? entry.note
            : ((entry.content != null && entry.content!.trim().isNotEmpty)
                ? entry.content
                : null);
        return EventRow(
          icon: Icons.payments_outlined,
          title: title,
          body: body,
          timeLine: timeStr,
          onTap: () => _openAddSheetForPerson(contact, editingEntry: entry),
          onLongPress: () => _showEntryActionsSheet(contact, entry),
        );

      case 'attachment':
        final fileName = (entry.attachmentPath != null && entry.attachmentPath!.isNotEmpty)
            ? p.basename(entry.attachmentPath!)
            : l10n.historyFilterFiles;
        return EventRow(
          icon: Icons.attach_file,
          title: fileName,
          body: (entry.note != null && entry.note!.trim().isNotEmpty) ? entry.note : null,
          timeLine: timeStr,
          onTap: () => _openAddSheetForPerson(contact, editingEntry: entry),
          onLongPress: () => _showEntryActionsSheet(contact, entry),
        );

      default:
        return EventRow(
          icon: Icons.edit_note_outlined,
          title: l10n.entryNote,
          body: entry.note ?? entry.content,
          timeLine: timeStr,
          onTap: () => _openAddSheetForPerson(contact, editingEntry: entry),
          onLongPress: () => _showEntryActionsSheet(contact, entry),
        );
    }
  }
}

class _PersonActionTile extends StatelessWidget {
  const _PersonActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.onLongPress,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: c.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusControl),
          side: BorderSide(color: c.borderHairline),
        ),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(AppTokens.radiusControl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.space4,
                vertical: AppTokens.space8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20, color: c.textPrimary),
                  const SizedBox(height: AppTokens.space4),
                  Text(
                    label,
                    style: tt.labelMedium!.copyWith(color: c.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

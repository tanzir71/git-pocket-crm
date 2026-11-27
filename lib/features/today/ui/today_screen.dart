import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/db/app_database.dart';
import '../../../core/format/app_formatters.dart';
import '../../../core/l10n_ext.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../../capture/ui/add_sheet.dart';
import '../../capture/ui/after_call_sheet.dart';
import '../../followups/data/followups_repository.dart';
import '../../messages/data/outbox_repository.dart';
import '../../people/ui/cadence_picker_sheet.dart';
import '../data/cadence_calculator.dart';
import '../data/today_repository.dart';

final _promptCallProvider = StreamProvider.autoDispose<PromptCallRow?>((ref) {
  final repo = ref.watch(todayRepositoryProvider);
  final now = ref.watch(clockProvider)();
  final mode = ref.watch(afterCallModeProvider).value ?? 'all';
  return repo.watchPromptCall(now: now, afterCallMode: mode);
});

final _needsAttentionProvider = StreamProvider.autoDispose<List<OutboxWithPersonRow>>((ref) {
  return ref.watch(todayRepositoryProvider).watchNeedsAttention();
});

final _dueFollowUpsProvider = StreamProvider.autoDispose<List<FollowUpWithPerson>>((ref) {
  final now = ref.watch(clockProvider)();
  final endOfTodayMs =
      DateTime(now.year, now.month, now.day, 23, 59, 59, 999).millisecondsSinceEpoch;
  return ref.watch(followUpsRepositoryProvider).watchDueAndOverdue(endOfTodayMs);
});

final _reconnectProvider = StreamProvider.autoDispose<List<DueReconnectItem>>((ref) {
  final now = ref.watch(clockProvider)();
  return ref.watch(todayRepositoryProvider).watchDueToReconnect(now: now);
});

final _goingOutTodayProvider = StreamProvider.autoDispose<List<OutboxWithPersonRow>>((ref) {
  final now = ref.watch(clockProvider)();
  return ref.watch(todayRepositoryProvider).watchGoingOutToday(now: now);
});

final _birthdaysProvider = StreamProvider.autoDispose<List<UpcomingBirthdayItem>>((ref) {
  final now = ref.watch(clockProvider)();
  return ref.watch(todayRepositoryProvider).watchUpcomingBirthdays(now: now);
});

final _hasAnyCadenceProvider = StreamProvider.autoDispose<bool>((ref) {
  return ref.watch(todayRepositoryProvider).watchHasAnyCadence();
});

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({
    super.key,
    this.afterCallNumber,
    this.afterCallFocus,
    this.onOpenPerson,
    this.onOpenSearch,
    this.onOpenSettings,
    this.onChoosePeopleForCadence,
  });

  final String? afterCallNumber;
  final String? afterCallFocus;
  final void Function(int contactId)? onOpenPerson;
  final VoidCallback? onOpenSearch;
  final VoidCallback? onOpenSettings;
  final VoidCallback? onChoosePeopleForCadence;

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  static const int _followUpLimit = 6;
  static const int _reconnectLimit = 5;
  static const int _birthdayLimit = 5;

  String? _handledAfterCallNumber;
  bool _showAllFollowUps = false;
  bool _showAllReconnect = false;
  final Set<int> _completingTaskIds = <int>{};

  @override
  void initState() {
    super.initState();
    _maybeHandleAfterCallDeepLink();
  }

  @override
  void didUpdateWidget(covariant TodayScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.afterCallNumber != oldWidget.afterCallNumber) {
      _maybeHandleAfterCallDeepLink();
    }
  }

  void _maybeHandleAfterCallDeepLink() {
    final number = widget.afterCallNumber?.trim();
    if (number == null || number.isEmpty || number == _handledAfterCallNumber) {
      return;
    }
    _handledAfterCallNumber = number;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        _openAfterCallForNumber(number, focusFollowUp: widget.afterCallFocus == 'followup'),
      );
    });
  }

  Future<void> _openAfterCallForNumber(String rawNumber, {required bool focusFollowUp}) async {
    try {
      await ref.read(syncServiceProvider).syncAll(syncContacts: false);
    } catch (_) {
      // Proceed with local data
    }
    if (!mounted) return;

    final region = ref.read(phoneRegionProvider).value ?? 'US';
    final phoneService = ref.read(phoneServiceProvider);
    final e164 = phoneService.normalise(rawNumber, region) ?? rawNumber;
    final peopleRepo = ref.read(peopleRepositoryProvider);
    final contact = await peopleRepo.findByPhone(e164) ?? await peopleRepo.findByPhone(rawNumber);
    if (contact == null || !mounted) return;

    final calls = await ref
        .read(historyRepositoryProvider)
        .watchForPerson(
          contact.id,
          types: const {'call_incoming', 'call_outgoing', 'call_missed'},
          limit: 1,
        )
        .first;
    if (calls.isEmpty || !mounted) return;

    await _openAfterCallSheet(contact, calls.first, focusFollowUp: focusFollowUp);
  }

  void _openPerson(int contactId) {
    if (widget.onOpenPerson != null) {
      widget.onOpenPerson!(contactId);
    } else {
      context.push('/people/$contactId');
    }
  }

  Future<void> _openAfterCallSheet(
    Contact contact,
    TimelineEntry callEntry, {
    bool focusFollowUp = false,
  }) async {
    final token = await showAfterCallSheet(
      context,
      contact: contact,
      callEntry: callEntry,
      focusFollowUp: focusFollowUp,
    );
    if (token != null && mounted) {
      showCaptureSavedSnackBar(context, ref, token);
      unawaited(ref.read(notificationsServiceProvider).rescheduleAll());
    }
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
    unawaited(ref.read(notificationsServiceProvider).cancelFollowUp(task.id));
    unawaited(ref.read(notificationsServiceProvider).rescheduleAll());
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
              unawaited(
                ref.read(followUpsRepositoryProvider).uncompleteFollowUp(task.id).then(
                      (_) => ref.read(notificationsServiceProvider).rescheduleAll(),
                    ),
              );
            },
          ),
        ),
      );
  }

  Future<void> _showReconnectActions(DueReconnectItem item) async {
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
            Text(
              item.contact.displayName,
              style: tt.titleMedium!.copyWith(color: c.textPrimary),
            ),
            const SizedBox(height: AppTokens.space12),
            InkWell(
              onTap: () async {
                Navigator.of(ctx).pop();
                final until = ref
                    .read(clockProvider)()
                    .add(const Duration(days: 7))
                    .millisecondsSinceEpoch;
                await ref
                    .read(peopleRepositoryProvider)
                    .snoozeReconnect(item.contact.id, until);
                unawaited(ref.read(notificationsServiceProvider).rescheduleAll());
              },
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: AppTokens.minTouchTarget),
                child: Row(
                  children: [
                    Icon(Icons.snooze_outlined, size: 20, color: c.textPrimary),
                    const SizedBox(width: AppTokens.space12),
                    Text(
                      l10n.snoozeOneWeek,
                      style: tt.bodyLarge!.copyWith(color: c.textPrimary),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                Navigator.of(ctx).pop();
                final picked = await showCadencePickerSheet(
                  context,
                  currentDays: item.contact.cadenceDays,
                );
                if (picked != null) {
                  await ref
                      .read(peopleRepositoryProvider)
                      .setCadence(item.contact.id, picked.days);
                  unawaited(ref.read(notificationsServiceProvider).rescheduleAll());
                }
              },
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: AppTokens.minTouchTarget),
                child: Row(
                  children: [
                    Icon(Icons.schedule_outlined, size: 20, color: c.textPrimary),
                    const SizedBox(width: AppTokens.space12),
                    Text(
                      l10n.changeHowOften,
                      style: tt.bodyLarge!.copyWith(color: c.textPrimary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final clock = ref.watch(clockProvider);
    final now = clock();
    final currency = ref.watch(currencyCodeProvider).value ?? 'USD';
    final locale = Localizations.localeOf(context).toLanguageTag();
    final fmt = AppFormatters(
      clock: clock,
      localeName: locale,
      currencyCode: currency,
      use24Hour: MediaQuery.alwaysUse24HourFormatOf(context),
    );

    final promptAsync = ref.watch(_promptCallProvider);
    final needsAttentionAsync = ref.watch(_needsAttentionProvider);
    final followUpsAsync = ref.watch(_dueFollowUpsProvider);
    final reconnectAsync = ref.watch(_reconnectProvider);
    final goingOutAsync = ref.watch(_goingOutTodayProvider);
    final birthdaysAsync = ref.watch(_birthdaysProvider);
    final hasAnyCadence = ref.watch(_hasAnyCadenceProvider).value ?? false;
    final setupState = ref.watch(setupCapabilityProvider).value;
    final showFinishSetup = setupState?.needsFinishSetupBanner ?? false;

    final promptCall = promptAsync.value;
    final needsAttention = needsAttentionAsync.value ?? const <OutboxWithPersonRow>[];
    final followUps = followUpsAsync.value ?? const <FollowUpWithPerson>[];
    final reconnects = reconnectAsync.value ?? const <DueReconnectItem>[];
    final goingOut = goingOutAsync.value ?? const <OutboxWithPersonRow>[];
    final birthdays = birthdaysAsync.value ?? const <UpcomingBirthdayItem>[];

    final allLoaded = !followUpsAsync.isLoading ||
        followUpsAsync.hasValue ||
        !reconnectAsync.isLoading ||
        reconnectAsync.hasValue;
    final isEverythingEmpty = allLoaded &&
        promptCall == null &&
        needsAttention.isEmpty &&
        followUps.isEmpty &&
        reconnects.isEmpty &&
        goingOut.isEmpty &&
        birthdays.isEmpty;

    final visibleFollowUps = _showAllFollowUps
        ? followUps
        : followUps.take(_followUpLimit).toList();
    final visibleReconnects = _showAllReconnect
        ? reconnects
        : reconnects.take(_reconnectLimit).toList();
    final visibleBirthdays = birthdays.take(_birthdayLimit).toList();

    return Scaffold(
      backgroundColor: c.bgCanvas,
      floatingActionButton: AppFab(
        icon: Icons.add,
        semanticLabel: l10n.addSheetTitle,
        onPressed: () async {
          final token = await showAddSheet(context);
          if (token != null && context.mounted) {
            showCaptureSavedSnackBar(context, ref, token);
            unawaited(ref.read(notificationsServiceProvider).rescheduleAll());
          }
        },
      ),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // Header: "Today" + date + search & settings
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTokens.screenPadding,
                  AppTokens.space16,
                  AppTokens.space12,
                  AppTokens.space8,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.navToday,
                            style: tt.headlineMedium!.copyWith(color: c.textPrimary),
                          ),
                          const SizedBox(height: AppTokens.space4),
                          Text(
                            fmt.formatHeaderDate(now),
                            style: tt.bodyMedium!.copyWith(color: c.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.todaySearchTooltip,
                      icon: Icon(Icons.search, color: c.textPrimary),
                      constraints: const BoxConstraints(
                        minWidth: AppTokens.minTouchTarget,
                        minHeight: AppTokens.minTouchTarget,
                      ),
                      onPressed: () {
                        if (widget.onOpenSearch != null) {
                          widget.onOpenSearch!();
                        } else {
                          context.go('/people?focusSearch=1');
                        }
                      },
                    ),
                    IconButton(
                      tooltip: l10n.todaySettingsTooltip,
                      icon: Icon(Icons.settings_outlined, color: c.textPrimary),
                      constraints: const BoxConstraints(
                        minWidth: AppTokens.minTouchTarget,
                        minHeight: AppTokens.minTouchTarget,
                      ),
                      onPressed: () {
                        if (widget.onOpenSettings != null) {
                          widget.onOpenSettings!();
                        } else {
                          context.push('/settings');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            if (showFinishSetup)
              SliverToBoxAdapter(
                child: SettingRow(
                  label: l10n.finishSetupBannerTitle,
                  value: l10n.setupAllowAction,
                  onTap: () => context.push('/setup'),
                ),
              ),

            if (isEverythingEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  title: l10n.allCaughtUpTitle,
                  message: l10n.allCaughtUpMessage,
                  actionLabel: hasAnyCadence ? null : l10n.choosePeopleToStayInTouch,
                  onAction: hasAnyCadence
                      ? null
                      : () {
                          if (widget.onChoosePeopleForCadence != null) {
                            widget.onChoosePeopleForCadence!();
                          } else {
                            context.go('/people?selectForCadence=1');
                          }
                        },
                ),
              )
            else ...[
              // 1. After-call prompt card (no section header)
              if (promptCall != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppTokens.space8),
                    child: _buildPromptCard(context, promptCall, fmt),
                  ),
                ),

              // 2. Needs attention
              if (needsAttention.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: l10n.sectionNeedsAttention,
                    count: needsAttention.length,
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = needsAttention[index];
                      final isMissed = item.message.status == 'missed';
                      final reason = isMissed
                          ? l10n.statusMissed
                          : (item.message.errorCode != null
                              ? smsErrorReasonLabel(item.message.errorCode, l10n)
                              : (item.message.errorLabel ?? l10n.statusNotSent));
                      final timeStr =
                          fmt.formatRelativeDateTime(item.message.dueAt, l10n);
                      final outboxRepo = ref.read(outboxRepositoryProvider);
                      return EventRow(
                        icon: Icons.error_outline,
                        title: isMissed
                            ? l10n.missedMessageTo(item.personName)
                            : l10n.notSentTo(item.personName),
                        body: '$reason · $timeStr',
                        isError: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppButton(
                              label: isMissed ? l10n.sendNowAction : l10n.retryAction,
                              variant: AppButtonVariant.secondary,
                              size: AppButtonSize.small,
                              onPressed: () =>
                                  unawaited(outboxRepo.retry([item.message.clientId])),
                            ),
                            const SizedBox(width: AppTokens.space4),
                            AppButton(
                              label: l10n.dismissAction,
                              variant: AppButtonVariant.quiet,
                              size: AppButtonSize.small,
                              onPressed: () =>
                                  unawaited(outboxRepo.cancel([item.message.clientId])),
                            ),
                          ],
                        ),
                        onTap: item.message.contactId != null
                            ? () => _openPerson(item.message.contactId!)
                            : null,
                      );
                    },
                    childCount: needsAttention.length,
                  ),
                ),
              ],

              // 3. Follow-ups
              if (followUps.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: l10n.sectionFollowUps,
                    count: followUps.length,
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = visibleFollowUps[index];
                      final due = fmt.formatFollowUpDue(item.task.dueDate, l10n);
                      final meta = item.personName.isNotEmpty
                          ? '${item.personName} · ${due.text}'
                          : due.text;
                      return TaskRow(
                        title: item.task.title,
                        meta: meta,
                        isOverdue: due.isOverdue,
                        completed: _completingTaskIds.contains(item.task.id),
                        onToggle: () => _completeFollowUp(item.task),
                        onTap: item.task.contactId != null
                            ? () => _openPerson(item.task.contactId!)
                            : null,
                      );
                    },
                    childCount: visibleFollowUps.length,
                  ),
                ),
                if (!_showAllFollowUps && followUps.length > _followUpLimit)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTokens.screenPadding,
                        vertical: AppTokens.space4,
                      ),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: AppButton(
                          label: l10n.showAllAction,
                          variant: AppButtonVariant.quiet,
                          size: AppButtonSize.small,
                          onPressed: () => setState(() => _showAllFollowUps = true),
                        ),
                      ),
                    ),
                  ),
              ],

              // 4. Reconnect
              if (reconnects.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: l10n.sectionReconnect,
                    count: reconnects.length,
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = visibleReconnects[index];
                      final cadenceText = fmt.formatCadence(item.effectiveCadenceDays, l10n);
                      final lastWords = fmt.formatLastInteractionWords(
                        item.contact.lastInteractionAt,
                        item.lastInteractionType,
                        l10n,
                      );
                      return PersonRow(
                        name: item.contact.displayName,
                        toneIndex: item.contact.id,
                        meta: '$cadenceText · $lastWords',
                        trailing: fmt.formatShortAge(item.contact.lastInteractionAt, l10n),
                        onTap: () => _openPerson(item.contact.id),
                        onLongPress: () => _showReconnectActions(item),
                      );
                    },
                    childCount: visibleReconnects.length,
                  ),
                ),
                if (!_showAllReconnect && reconnects.length > _reconnectLimit)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTokens.screenPadding,
                        vertical: AppTokens.space4,
                      ),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: AppButton(
                          label: l10n.showAllAction,
                          variant: AppButtonVariant.quiet,
                          size: AppButtonSize.small,
                          onPressed: () => setState(() => _showAllReconnect = true),
                        ),
                      ),
                    ),
                  ),
              ],

              // 5. Going out today
              if (goingOut.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: l10n.sectionGoingOutToday,
                    count: goingOut.length,
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = goingOut[index];
                      return EventRow(
                        icon: Icons.schedule_outlined,
                        title: item.personName,
                        body: item.message.body,
                        timeLine: fmt.formatTime(
                          DateTime.fromMillisecondsSinceEpoch(item.message.dueAt),
                        ),
                        onTap: item.message.contactId != null
                            ? () => _openPerson(item.message.contactId!)
                            : null,
                      );
                    },
                    childCount: goingOut.length,
                  ),
                ),
              ],

              // 6. Coming up (birthdays in next 7 days)
              if (visibleBirthdays.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: l10n.sectionComingUp,
                    count: birthdays.length,
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = visibleBirthdays[index];
                      final meta = item.daysUntil == 0
                          ? l10n.birthdayToday
                          : l10n.birthdayOnDay(
                              DateFormat('EEEE', locale).format(item.nextBirthdayDate),
                            );
                      return PersonRow(
                        name: item.contact.displayName,
                        toneIndex: item.contact.id,
                        meta: meta,
                        onTap: () => _openPerson(item.contact.id),
                      );
                    },
                    childCount: visibleBirthdays.length,
                  ),
                ),
              ],

              const SliverToBoxAdapter(child: SizedBox(height: 88)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPromptCard(
    BuildContext context,
    PromptCallRow prompt,
    AppFormatters fmt,
  ) {
    final l10n = context.l10n;
    final dirLabel = switch (prompt.entry.type) {
      'call_outgoing' => l10n.callOutgoing,
      'call_missed' => l10n.callMissed,
      _ => l10n.callIncoming,
    };
    final dur = fmt.formatDuration(prompt.entry.durationSeconds, l10n);
    final timeStr = fmt.formatTime(
      DateTime.fromMillisecondsSinceEpoch(prompt.entry.timestamp),
    );
    final metaParts = [
      dirLabel,
      if (dur.isNotEmpty && prompt.entry.type != 'call_missed') dur,
      timeStr,
    ];

    return PromptCard(
      title: l10n.promptSpokeWith(prompt.contact.displayName),
      subtitle: metaParts.join(' · '),
      avatarName: prompt.contact.displayName,
      toneIndex: prompt.contact.id,
      actions: [
        AppButton(
          label: l10n.promptAddNote,
          variant: AppButtonVariant.primary,
          size: AppButtonSize.small,
          onPressed: () => _openAfterCallSheet(prompt.contact, prompt.entry),
        ),
        AppButton(
          label: l10n.promptFollowUp,
          variant: AppButtonVariant.secondary,
          size: AppButtonSize.small,
          onPressed: () => _openAfterCallSheet(
            prompt.contact,
            prompt.entry,
            focusFollowUp: true,
          ),
        ),
        AppButton(
          label: l10n.promptSkip,
          variant: AppButtonVariant.quiet,
          size: AppButtonSize.small,
          onPressed: () => ref.read(historyRepositoryProvider).markCallReviewed(prompt.entry.id),
        ),
      ],
    );
  }
}

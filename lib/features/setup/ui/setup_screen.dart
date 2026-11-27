import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/format/app_formatters.dart';
import '../../../core/l10n_ext.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../../sync/data/sync_service.dart';
import '../data/setup_controller.dart';

/// Setup screen (Figma frame `10:648`, route `/setup`) and Settings "Check setup"
/// reliability screen (`/setup?mode=check`).
class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({
    super.key,
    this.checkMode = false,
    this.onFinishedToPeople,
    this.onDeferToToday,
  });

  final bool checkMode;
  final VoidCallback? onFinishedToPeople;
  final VoidCallback? onDeferToToday;

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen>
    with WidgetsBindingObserver {
  SetupCapabilityState _state = SetupCapabilityState.allDenied;
  bool _loaded = false;
  int _contactsDenials = 0;
  bool _syncing = false;
  SyncStatus _syncProgress = SyncStatus.initial;
  StreamSubscription<SyncStatus>? _syncSub;

  // Reliability check state (shown in checkMode)
  final TextEditingController _ownNumberController = TextEditingController();
  ReliabilityCheckOutcome _reliabilityOutcome = ReliabilityCheckOutcome.none;
  bool _schedulingTest = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_refresh());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_syncSub?.cancel());
    _ownNumberController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refresh());
    }
  }

  Future<void> _refresh() async {
    final bridge = ref.read(setupPlatformBridgeProvider);
    final next = await bridge.readState();
    ReliabilityCheckOutcome outcome = _reliabilityOutcome;
    if (widget.checkMode) {
      await ref.read(outboxRepositoryProvider).reconcile();
      outcome = await ref.read(reliabilityCheckServiceProvider).evaluate();
    }
    if (!mounted) return;
    setState(() {
      _state = next;
      _loaded = true;
      _reliabilityOutcome = outcome;
      if (_ownNumberController.text.isEmpty &&
          next.ownPhoneNumber != null &&
          next.ownPhoneNumber!.isNotEmpty) {
        _ownNumberController.text = next.ownPhoneNumber!;
      }
    });
    ref.invalidate(setupCapabilityProvider);
  }

  Future<void> _onAllowContacts() async {
    final bridge = ref.read(setupPlatformBridgeProvider);
    if (_contactsDenials >= 2) {
      await bridge.openAppDetailsSettings();
      return;
    }
    final granted = await bridge.requestContacts();
    if (!granted) {
      _contactsDenials++;
    }
    await _refresh();
  }

  Future<void> _onAllowCallsAndMessages() async {
    final bridge = ref.read(setupPlatformBridgeProvider);
    final res = await bridge.requestCallsAndMessages();
    await _refresh();
    if (!mounted) return;
    if (res.isRestrictedSettingsBlocked(
      sdkInt: _state.sdkInt,
      installedFromStore: _state.installedFromStore,
    )) {
      await _showRestrictedSettingsGuide();
    }
  }

  Future<void> _showRestrictedSettingsGuide() async {
    final bridge = ref.read(setupPlatformBridgeProvider);
    await showAppSheet<void>(
      context: context,
      bodyBuilder: (ctx) {
        final c = ctx.colors;
        final tt = Theme.of(ctx).textTheme;
        final l10n = ctx.l10n;
        return Padding(
          padding: const EdgeInsets.fromLTRB(
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
                l10n.restrictedSettingsTitle,
                style: tt.titleMedium!.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: AppTokens.space12),
              Text(
                l10n.restrictedSettingsStep1,
                style: tt.bodyMedium!.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: AppTokens.space8),
              Text(
                l10n.restrictedSettingsStep2,
                style: tt.bodyMedium!.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: AppTokens.space8),
              Text(
                l10n.restrictedSettingsStep3,
                style: tt.bodyMedium!.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: AppTokens.space12),
              Text(
                l10n.restrictedSettingsFallback,
                style: tt.bodySmall!.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: AppTokens.space16),
              AppButton(
                label: l10n.restrictedSettingsOpenAppInfo,
                variant: AppButtonVariant.primary,
                fullWidth: true,
                onPressed: () {
                  Navigator.of(ctx).pop();
                  unawaited(bridge.openAppDetailsSettings());
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onContinue() async {
    if (_syncing) return;
    setState(() => _syncing = true);
    final sync = ref.read(syncServiceProvider);
    unawaited(_syncSub?.cancel());
    _syncSub = sync.statusStream.listen((st) {
      if (mounted) setState(() => _syncProgress = st);
    });
    try {
      await sync.syncAll();
      await ref.read(notificationsServiceProvider).rescheduleAll();
    } catch (_) {
      // Proceed even if a permission is partial.
    } finally {
      await _syncSub?.cancel();
      _syncSub = null;
    }
    if (!mounted) return;
    ref.read(setupDeferredProvider.notifier).defer();
    if (widget.onFinishedToPeople != null) {
      widget.onFinishedToPeople!();
    } else {
      context.go('/people');
    }
  }

  void _onDefer() {
    ref.read(setupDeferredProvider.notifier).defer();
    if (widget.onDeferToToday != null) {
      widget.onDeferToToday!();
    } else {
      context.go('/today');
    }
  }

  Future<void> _scheduleReliabilityTest() async {
    final number = _ownNumberController.text.trim();
    if (number.isEmpty || _schedulingTest) return;
    setState(() => _schedulingTest = true);
    try {
      final l10n = context.l10n;
      final clock = ref.read(clockProvider);
      final dueAt = clock().add(const Duration(minutes: 2));
      final fmt = AppFormatters(
        clock: clock,
        localeName: Localizations.localeOf(context).toLanguageTag(),
        use24Hour: MediaQuery.alwaysUse24HourFormatOf(context),
      );
      final timeStr = fmt.formatTime(dueAt);
      final body = l10n.reliabilityTestMessageBody(timeStr);
      final scheduled = await ref.read(reliabilityCheckServiceProvider).scheduleTestMessage(
            ownNumber: number,
            formattedTime: timeStr,
            body: body,
          );
      if (!mounted) return;
      setState(() {
        _reliabilityOutcome = ReliabilityCheckOutcome(
          kind: ReliabilityOutcomeKind.pending,
          dueAtMs: scheduled.dueAtMs,
        );
      });
    } finally {
      if (mounted) setState(() => _schedulingTest = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final bridge = ref.read(setupPlatformBridgeProvider);
    final clock = ref.watch(clockProvider);
    final fmt = AppFormatters(
      clock: clock,
      localeName: Localizations.localeOf(context).toLanguageTag(),
      use24Hour: MediaQuery.alwaysUse24HourFormatOf(context),
    );

    final oemVendor = _state.oemVendor;
    final showOemLine = _state.batteryGranted && oemVendor != null;

    final alarmsSubtitle = _loaded && !_state.exactAlarmsGranted
        ? l10n.setupRowAlarmsSubtitle
        : l10n.setupRowAlarmsSubtitle;

    return Scaffold(
      backgroundColor: c.bgCanvas,
      appBar: widget.checkMode
          ? AppBar(
              backgroundColor: c.bgCanvas,
              title: Text(l10n.settingsCheckSetup),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppTokens.screenPadding,
                  AppTokens.space16,
                  AppTokens.screenPadding,
                  AppTokens.space16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!widget.checkMode) ...[
                      Text(
                        l10n.setupTitle,
                        style: tt.headlineMedium!.copyWith(color: c.textPrimary),
                      ),
                      const SizedBox(height: AppTokens.space8),
                      Text(
                        l10n.setupSubtitle,
                        style: tt.bodyMedium!.copyWith(color: c.textSecondary),
                      ),
                      const SizedBox(height: AppTokens.space24),
                    ],

                    // 1. Contacts
                    _SetupPermissionRow(
                      title: l10n.setupRowContactsTitle,
                      subtitle: l10n.setupRowContactsSubtitle,
                      allowed: _state.contactsGranted,
                      actionLabel: _contactsDenials >= 2
                          ? l10n.setupOpenSettingsAction
                          : l10n.setupAllowAction,
                      onAllow: _onAllowContacts,
                    ),

                    // 2. Calls and messages
                    _SetupPermissionRow(
                      title: l10n.setupRowCallsSmsTitle,
                      subtitle: l10n.setupRowCallsSmsSubtitle,
                      allowed: _state.callsAndMessagesGranted,
                      actionLabel: l10n.setupAllowAction,
                      onAllow: _onAllowCallsAndMessages,
                    ),

                    // 3. Alarms and reminders
                    _SetupPermissionRow(
                      title: l10n.setupRowAlarmsTitle,
                      subtitle: widget.checkMode && !_state.exactAlarmsGranted
                          ? l10n.setupRowAlarmsFallback
                          : alarmsSubtitle,
                      allowed: _state.exactAlarmsGranted,
                      actionLabel: l10n.setupAllowAction,
                      onAllow: () async {
                        await bridge.openExactAlarmSettings();
                        await _refresh();
                      },
                    ),

                    // 4. Battery
                    _SetupPermissionRow(
                      title: l10n.setupRowBatteryTitle,
                      subtitle: showOemLine
                          ? oemBatteryGuidance(oemVendor, l10n)
                          : l10n.setupRowBatterySubtitle,
                      allowed: _state.batteryGranted && !showOemLine,
                      forceShowAction: showOemLine,
                      actionLabel: showOemLine
                          ? l10n.setupOpenSettingsAction
                          : l10n.setupAllowAction,
                      onAllow: () async {
                        if (showOemLine) {
                          await bridge.openAppDetailsSettings();
                        } else {
                          await bridge.requestIgnoreBatteryOptimisations();
                        }
                        await _refresh();
                      },
                    ),

                    // 5. Notifications
                    _SetupPermissionRow(
                      title: l10n.setupRowNotificationsTitle,
                      subtitle: l10n.setupRowNotificationsSubtitle,
                      allowed: _state.notificationsGranted,
                      actionLabel: l10n.setupAllowAction,
                      onAllow: () async {
                        await bridge.requestNotifications();
                        await _refresh();
                      },
                    ),

                    const SizedBox(height: AppTokens.space16),

                    // Privacy note box (matches Figma 10:648)
                    Container(
                      padding: const EdgeInsets.all(AppTokens.space16),
                      decoration: BoxDecoration(
                        color: c.bgSurface,
                        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
                        border: Border.all(color: c.borderHairline),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lock_outline, size: 20, color: c.textSecondary),
                          const SizedBox(width: AppTokens.space12),
                          Expanded(
                            child: Text(
                              l10n.setupPrivacyNote,
                              style: tt.bodyMedium!.copyWith(color: c.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_syncing) ...[
                      const SizedBox(height: AppTokens.space16),
                      Text(
                        _syncProgress.contactsSynced == 0 &&
                                _syncProgress.callsSynced == 0 &&
                                _syncProgress.smsSynced == 0
                            ? l10n.setupSyncingHistory
                            : l10n.setupSyncProgressCounts(
                                _syncProgress.contactsSynced,
                                _syncProgress.callsSynced,
                                _syncProgress.smsSynced,
                              ),
                        style: tt.bodySmall!.copyWith(color: c.textSecondary),
                      ),
                    ],

                    // Reliability self-test card (shown when opened from Settings -> Check setup)
                    if (widget.checkMode) ...[
                      const SizedBox(height: AppTokens.space24),
                      Text(
                        l10n.reliabilitySectionTitle,
                        style: tt.titleMedium!.copyWith(color: c.textPrimary),
                      ),
                      const SizedBox(height: AppTokens.space12),
                      AppField(
                        controller: _ownNumberController,
                        label: l10n.reliabilityPhoneLabel,
                        hintText: l10n.reliabilityPhoneHint,
                        keyboardType: TextInputType.phone,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: AppTokens.space12),
                      AppButton(
                        label: l10n.reliabilitySendTestAction,
                        variant: AppButtonVariant.primary,
                        fullWidth: true,
                        onPressed: _ownNumberController.text.trim().isNotEmpty &&
                                !_schedulingTest
                            ? _scheduleReliabilityTest
                            : null,
                      ),
                      if (_reliabilityOutcome.kind != ReliabilityOutcomeKind.none) ...[
                        const SizedBox(height: AppTokens.space12),
                        Container(
                          padding: const EdgeInsets.all(AppTokens.space16),
                          decoration: BoxDecoration(
                            color: c.bgSubtle,
                            borderRadius: BorderRadius.circular(AppTokens.radiusCard),
                          ),
                          child: Text(
                            _reliabilityOutcome.formatMessage(l10n, fmt),
                            style: tt.bodyMedium!.copyWith(
                              color: _reliabilityOutcome.kind == ReliabilityOutcomeKind.failed
                                  ? c.statusDanger
                                  : (_reliabilityOutcome.kind == ReliabilityOutcomeKind.onTime
                                      ? c.statusSuccess
                                      : c.textPrimary),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),

            if (!widget.checkMode)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTokens.screenPadding,
                  AppTokens.space8,
                  AppTokens.screenPadding,
                  AppTokens.space16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppButton(
                      label: l10n.continueLabel,
                      variant: AppButtonVariant.primary,
                      fullWidth: true,
                      onPressed: _state.contactsGranted && !_syncing ? _onContinue : null,
                    ),
                    const SizedBox(height: AppTokens.space8),
                    AppButton(
                      label: l10n.doThisLater,
                      variant: AppButtonVariant.quiet,
                      fullWidth: true,
                      onPressed: _syncing ? null : _onDefer,
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

class _SetupPermissionRow extends StatelessWidget {
  const _SetupPermissionRow({
    required this.title,
    required this.subtitle,
    required this.allowed,
    required this.actionLabel,
    required this.onAllow,
    this.forceShowAction = false,
  });

  final String title;
  final String subtitle;
  final bool allowed;
  final String actionLabel;
  final VoidCallback onAllow;
  final bool forceShowAction;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTokens.space12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: allowed || forceShowAction ? c.statusSuccessSoft : c.bgSubtle,
            ),
            child: (allowed || forceShowAction)
                ? Icon(Icons.check, size: 16, color: c.statusSuccess)
                : null,
          ),
          const SizedBox(width: AppTokens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: tt.labelLarge!.copyWith(color: c.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: tt.bodySmall!.copyWith(color: c.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTokens.space12),
          if (allowed && !forceShowAction)
            Text(
              l10n.setupAllowedLabel,
              style: tt.bodySmall!.copyWith(color: c.textSecondary),
            )
          else
            AppButton(
              label: actionLabel,
              variant: AppButtonVariant.secondary,
              size: AppButtonSize.small,
              onPressed: onAllow,
            ),
        ],
      ),
    );
  }
}

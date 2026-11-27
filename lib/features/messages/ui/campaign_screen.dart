import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/db/app_database.dart';
import '../../../core/format/app_formatters.dart';
import '../../../core/l10n_ext.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../data/campaigns_repository.dart';
import '../data/outbox_repository.dart';

final _campaignProvider = StreamProvider.autoDispose.family<Campaign?, String>((ref, id) {
  return ref.watch(campaignsRepositoryProvider).watchCampaign(id);
});

final _campaignRecipientsProvider =
    StreamProvider.autoDispose.family<List<CampaignRecipientRow>, String>((ref, id) {
  return ref.watch(campaignsRepositoryProvider).watchCampaignRecipients(id);
});

/// Campaign progress screen (Figma frame `10:556`, route `/messages/campaign/:id`).
class CampaignScreen extends ConsumerWidget {
  const CampaignScreen({
    super.key,
    required this.campaignId,
    this.onDuplicate,
  });

  final String campaignId;
  final void Function(Campaign campaign)? onDuplicate;

  Future<void> _confirmStop(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.campaignStopConfirmTitle),
        content: Text(l10n.campaignStopConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancelAction),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l10n.campaignStopAction,
              style: TextStyle(color: ctx.colors.statusDanger),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(outboxRepositoryProvider).stopCampaign(campaignId);
    }
  }

  Future<void> _exportCsv(
    BuildContext context,
    WidgetRef ref,
    Campaign campaign,
    List<CampaignRecipientRow> recipients,
  ) async {
    final repo = ref.read(campaignsRepositoryProvider);
    final path = await repo.writeCampaignCsvFile(campaign.name, recipients);
    await ref.read(outboxRepositoryProvider).shareFile(path, 'text/csv', campaign.name);
    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(context.l10n.campaignExportedSnack)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final clock = ref.watch(clockProvider);
    final fmt = AppFormatters(
      clock: clock,
      localeName: Localizations.localeOf(context).toLanguageTag(),
      use24Hour: MediaQuery.alwaysUse24HourFormatOf(context),
    );

    final campaign = ref.watch(_campaignProvider(campaignId)).value;
    final recipients =
        ref.watch(_campaignRecipientsProvider(campaignId)).value ?? const <CampaignRecipientRow>[];

    if (campaign == null) {
      return Scaffold(
        backgroundColor: c.bgCanvas,
        appBar: AppBar(backgroundColor: c.bgCanvas),
      );
    }

    final total = recipients.length;
    final sentCount = recipients
        .where((r) => r.message.status == 'sent' || r.message.status == 'delivered')
        .length;
    final failedRows = recipients
        .where((r) => r.message.status == 'failed' || r.message.status == 'missed')
        .toList();
    final failedCount = failedRows.length;
    final sendingCount = recipients.where((r) => r.message.status == 'sending').length;
    final waitingCount = recipients.where((r) => r.message.status == 'queued').length;
    final doneCount = sentCount + failedCount + sendingCount;
    final progress = total > 0 ? (doneCount / total).clamp(0.0, 1.0) : 0.0;

    final paceSec = campaign.paceSeconds ?? 4;
    final remainingSec = waitingCount * paceSec;
    final remainingLabel = remainingSec <= 0
        ? ''
        : (remainingSec < 60
            ? l10n.aboutSecondsLeft(remainingSec)
            : l10n.aboutMinutesLeft((remainingSec / 60).ceil()));
    final paceLabel = paceSec >= 60 ? l10n.paceOnePerMinute : l10n.paceEveryNSeconds(paceSec);

    final isPaused = campaign.status == 'paused';
    final isStopped = campaign.status == 'stopped';
    final isDone = campaign.status == 'done' || (waitingCount == 0 && sendingCount == 0 && total > 0);
    final isScheduled = campaign.status == 'scheduled' && sentCount == 0 && sendingCount == 0 && failedCount == 0;

    final stateLine = () {
      if (isStopped) return l10n.campaignStateStopped(sentCount + failedCount, total);
      if (isPaused) return l10n.campaignStatePaused(doneCount, total);
      if (isDone) {
        return failedCount > 0
            ? l10n.campaignStateDoneWithFailed(sentCount, failedCount)
            : l10n.campaignStateDone(sentCount);
      }
      if (isScheduled && campaign.scheduledAt != null) {
        return l10n.campaignStateScheduled(
          fmt.formatRelativeDateTime(campaign.scheduledAt!, l10n),
        );
      }
      return l10n.campaignStateSending(doneCount, total);
    }();

    final outbox = ref.read(outboxRepositoryProvider);

    return Scaffold(
      backgroundColor: c.bgCanvas,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // Top bar: back + more menu
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
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
                          context.go('/messages');
                        }
                      },
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      tooltip: l10n.moreTooltip,
                      icon: Icon(Icons.more_vert, color: c.textPrimary),
                      onSelected: (value) async {
                        switch (value) {
                          case 'duplicate':
                            if (onDuplicate != null) {
                              onDuplicate!(campaign);
                            } else {
                              unawaited(
                                context.push(
                                  '/messages/new?body=${Uri.encodeQueryComponent(campaign.bodyTemplate)}&name=${Uri.encodeQueryComponent(campaign.name)}',
                                ),
                              );
                            }
                          case 'export':
                            await _exportCsv(context, ref, campaign, recipients);
                          case 'delete':
                            await ref.read(campaignsRepositoryProvider).deleteCampaign(campaign.id);
                            if (context.mounted) {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/messages');
                              }
                            }
                        }
                      },
                      itemBuilder: (ctx) => [
                        PopupMenuItem(
                          value: 'duplicate',
                          child: Text(l10n.campaignMenuDuplicate),
                        ),
                        PopupMenuItem(
                          value: 'export',
                          child: Text(l10n.campaignMenuExport),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            l10n.campaignMenuDelete,
                            style: TextStyle(color: ctx.colors.statusDanger),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Title, state line, progress bar, controls, 4-number summary
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTokens.screenPadding,
                  AppTokens.space8,
                  AppTokens.screenPadding,
                  AppTokens.space12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      campaign.name,
                      style: tt.titleLarge!.copyWith(color: c.textPrimary),
                    ),
                    const SizedBox(height: AppTokens.space4),
                    Text(
                      stateLine,
                      style: tt.bodyMedium!.copyWith(color: c.textSecondary),
                    ),
                    const SizedBox(height: AppTokens.space16),
                    // Progress bar: 6 high, bgSubtle track, accentDefault fill
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: SizedBox(
                        height: 6,
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: c.bgSubtle,
                          valueColor: AlwaysStoppedAnimation<Color>(c.accentDefault),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTokens.space8),
                    Row(
                      children: [
                        Text(
                          remainingLabel,
                          style: tt.bodySmall!.copyWith(color: c.textSecondary),
                        ),
                        const Spacer(),
                        Text(
                          paceLabel,
                          style: tt.bodySmall!.copyWith(color: c.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTokens.space16),

                    // Controls
                    Row(
                      children: [
                        if (!isDone && !isStopped) ...[
                          AppButton(
                            label: isPaused
                                ? l10n.campaignResumeAction
                                : l10n.campaignPauseAction,
                            variant: AppButtonVariant.secondary,
                            size: AppButtonSize.small,
                            onPressed: () {
                              if (isPaused) {
                                unawaited(outbox.resumeCampaign(campaign.id));
                              } else {
                                unawaited(outbox.pauseCampaign(campaign.id));
                              }
                            },
                          ),
                          const SizedBox(width: AppTokens.space8),
                          AppButton(
                            label: l10n.campaignStopAction,
                            variant: AppButtonVariant.quiet,
                            size: AppButtonSize.small,
                            onPressed: () => _confirmStop(context, ref),
                          ),
                        ] else if (failedCount > 0) ...[
                          AppButton(
                            label: l10n.campaignRetryNNotSent(failedCount),
                            variant: AppButtonVariant.secondary,
                            size: AppButtonSize.small,
                            onPressed: () => unawaited(
                              outbox.retry(failedRows.map((r) => r.message.clientId).toList()),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: AppTokens.space24),

                    // 4-number summary
                    Row(
                      children: [
                        _StatColumn(
                          value: sentCount,
                          label: l10n.campaignStatSent,
                          color: c.textPrimary,
                        ),
                        _StatColumn(
                          value: failedCount,
                          label: l10n.campaignStatFailed,
                          color: failedCount > 0 ? c.statusDanger : c.textPrimary,
                        ),
                        _StatColumn(
                          value: sendingCount,
                          label: l10n.campaignStatSending,
                          color: c.textPrimary,
                        ),
                        _StatColumn(
                          value: waitingCount,
                          label: l10n.campaignStatWaiting,
                          color: c.textPrimary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Recipients section
            SliverToBoxAdapter(
              child: SectionHeader(title: l10n.campaignSectionRecipients),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = recipients[index];
                  final msg = item.message;
                  final isFailed = msg.status == 'failed' || msg.status == 'missed';
                  final reason = msg.status == 'missed'
                      ? l10n.statusMissed
                      : (msg.errorCode != null
                          ? smsErrorReasonLabel(msg.errorCode, l10n)
                          : (msg.errorLabel ?? l10n.statusNotSent));

                  final meta = isFailed
                      ? l10n.tapToRetryMeta(reason)
                      : (msg.mergeSummary ?? msg.address);

                  final statusLabel = switch (msg.status) {
                    'delivered' => l10n.statusDelivered,
                    'sent' => l10n.statusSent,
                    'sending' => l10n.statusSending,
                    'failed' => l10n.statusFailed,
                    'missed' => l10n.statusMissed,
                    'cancelled' => l10n.statusCancelled,
                    'skipped' => l10n.statusSkipped,
                    _ => l10n.statusWaiting,
                  };

                  return PersonRow(
                    name: item.personName,
                    toneIndex: item.toneIndex,
                    meta: meta,
                    trailingWidget: StatusText(
                      status: parseMessageStatus(msg.status),
                      labelOverride: statusLabel,
                    ),
                    onTap: isFailed
                        ? () => unawaited(outbox.retry([msg.clientId]))
                        : (msg.contactId != null
                            ? () => context.push('/people/${msg.contactId}')
                            : null),
                  );
                },
                childCount: recipients.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppTokens.space32)),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.value,
    required this.label,
    required this.color,
  });

  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final c = context.colors;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$value',
            style: tt.headlineSmall!.copyWith(
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: tt.bodySmall!.copyWith(color: c.textSecondary),
          ),
        ],
      ),
    );
  }
}

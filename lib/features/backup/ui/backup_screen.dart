import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/format/app_formatters.dart';
import '../../../core/l10n_ext.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../data/backup_crypto.dart';
import '../data/backup_service.dart';

final _backupSettingProvider =
    StreamProvider.autoDispose.family<String?, String>((ref, key) {
  return ref.watch(settingsRepositoryProvider).watch(key);
});

final _autoBackupsCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final files = await ref.watch(backupServiceProvider).listAutoBackups();
  return files.length;
});

/// Backup & Restore settings screen (`/settings/backup`, Spec 12).
class BackupSettingsScreen extends ConsumerStatefulWidget {
  const BackupSettingsScreen({super.key});

  @override
  ConsumerState<BackupSettingsScreen> createState() => _BackupSettingsScreenState();
}

class _BackupSettingsScreenState extends ConsumerState<BackupSettingsScreen> {
  bool _includeAttachments = true;
  bool _protectWithPassphrase = false;
  final TextEditingController _passphraseController = TextEditingController();
  final TextEditingController _confirmPassphraseController = TextEditingController();

  bool _busy = false;
  BackupStage? _stage;
  String? _inlineError;

  @override
  void dispose() {
    _passphraseController.dispose();
    _confirmPassphraseController.dispose();
    super.dispose();
  }

  String _stageText(BuildContext context, BackupStage stage) {
    final l10n = context.l10n;
    return switch (stage) {
      BackupStage.preparingDatabase => l10n.backupStagePreparing,
      BackupStage.readingOutbox => l10n.backupStageReadingOutbox,
      BackupStage.packingFiles => l10n.backupStagePacking,
      BackupStage.encrypting => l10n.backupStageEncrypting,
      BackupStage.saving => l10n.backupStageSaving,
      BackupStage.decrypting => l10n.backupStageDecrypting,
      BackupStage.verifying => l10n.backupStageVerifying,
      BackupStage.restoring => l10n.backupStageRestoring,
      BackupStage.done => l10n.backupSavedSnack,
    };
  }

  Future<void> _onBackupNow() async {
    if (_busy) return;
    final l10n = context.l10n;
    String? passphrase;
    if (_protectWithPassphrase) {
      final p1 = _passphraseController.text;
      final p2 = _confirmPassphraseController.text;
      if (p1.isEmpty) {
        setState(() => _inlineError = l10n.backupPassphraseRequired);
        return;
      }
      if (p1 != p2) {
        setState(() => _inlineError = l10n.backupPassphraseMismatch);
        return;
      }
      passphrase = p1;
    }

    setState(() {
      _busy = true;
      _inlineError = null;
      _stage = BackupStage.preparingDatabase;
    });

    try {
      final manifest = await ref.read(backupServiceProvider).createAndSaveWithSaf(
            includeAttachments: _includeAttachments,
            passphrase: passphrase,
            onStage: (s) {
              if (mounted) setState(() => _stage = s);
            },
          );
      if (!mounted) return;
      if (manifest != null) {
        _passphraseController.clear();
        _confirmPassphraseController.clear();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.backupSavedSnack)));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _inlineError = l10n.exportFailedSnack);
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _stage = null;
        });
      }
    }
  }

  Future<String?> _askPassphraseDialog({String? errorText}) async {
    final controller = TextEditingController();
    final result = await showAppSheet<String>(
      context: context,
      bodyBuilder: (ctx) {
        final c = ctx.colors;
        final tt = Theme.of(ctx).textTheme;
        final l10n = ctx.l10n;
        return Padding(
          padding: EdgeInsets.fromLTRB(
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
                l10n.backupEnterPassphraseTitle,
                style: tt.titleMedium!.copyWith(color: c.textPrimary),
              ),
              if (errorText != null) ...[
                const SizedBox(height: AppTokens.space8),
                Text(
                  errorText,
                  style: tt.bodySmall!.copyWith(color: c.statusDanger),
                ),
              ],
              const SizedBox(height: AppTokens.space12),
              TextField(
                controller: controller,
                obscureText: true,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.backupPassphraseHint,
                ),
              ),
              const SizedBox(height: AppTokens.space16),
              AppButton(
                label: l10n.backupOpenAction,
                variant: AppButtonVariant.primary,
                fullWidth: true,
                onPressed: () => Navigator.of(ctx).pop(controller.text),
              ),
            ],
          ),
        );
      },
    );
    controller.dispose();
    return result;
  }

  Future<void> _onRestoreFromBackup() async {
    if (_busy) return;
    final l10n = context.l10n;
    final service = ref.read(backupServiceProvider);

    final pickedPath = await service.pickBackupFile();
    if (pickedPath == null || pickedPath.isEmpty || !mounted) return;

    try {
      BackupInspection inspection = await service.inspectBackup(pickedPath);
      String? passphrase;

      while (inspection.needsPassphrase) {
        if (!mounted) return;
        passphrase = await _askPassphraseDialog();
        if (passphrase == null || passphrase.isEmpty || !mounted) return;
        try {
          inspection = await service.inspectBackup(pickedPath, passphrase: passphrase);
        } on WrongPassphraseException {
          if (!mounted) return;
          passphrase = await _askPassphraseDialog(errorText: l10n.backupWrongPassphrase);
          if (passphrase == null || passphrase.isEmpty || !mounted) return;
          try {
            inspection = await service.inspectBackup(pickedPath, passphrase: passphrase);
          } on WrongPassphraseException {
            if (mounted) {
              setState(() => _inlineError = l10n.backupWrongPassphrase);
            }
            return;
          }
        }
      }

      if (!mounted) return;
      final numFmt = NumberFormat.decimalPattern(
        Localizations.localeOf(context).toLanguageTag(),
      );

      if (inspection.format == BackupFormat.v1Json) {
        final counts = inspection.v1Counts ?? const <String, int>{};
        final summary = l10n.backupV1Summary(
          numFmt.format(counts['contacts'] ?? 0),
          numFmt.format(counts['timeline'] ?? 0),
          numFmt.format(counts['tasks'] ?? 0),
        );
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dCtx) => AlertDialog(
            title: Text(l10n.backupMergeV1ConfirmTitle),
            content: Text(summary),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dCtx).pop(false),
                child: Text(l10n.cancelAction),
              ),
              TextButton(
                onPressed: () => Navigator.of(dCtx).pop(true),
                child: Text(l10n.backupMergeV1ConfirmAction),
              ),
            ],
          ),
        );
        if (confirmed != true || !mounted) return;

        setState(() {
          _busy = true;
          _inlineError = null;
          _stage = BackupStage.restoring;
        });
        final rawJson = await File(pickedPath).readAsString();
        final imported = await service.importV1Json(rawJson);
        if (mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  l10n.backupV1ImportedSnack(
                    imported.contactsImported,
                    imported.timelineImported,
                  ),
                ),
              ),
            );
        }
        return;
      }

      final manifest = inspection.manifest;
      if (manifest == null) {
        setState(() => _inlineError = l10n.backupCorruptError);
        return;
      }
      final dateStr = DateFormat('d MMMM', Localizations.localeOf(context).toLanguageTag())
          .format(DateTime.fromMillisecondsSinceEpoch(manifest.createdAtMs));
      final summary = l10n.backupManifestSummary(
        numFmt.format(manifest.contactsCount),
        numFmt.format(manifest.timelineCount),
        numFmt.format(manifest.filesCount),
        dateStr,
      );

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dCtx) => AlertDialog(
          title: Text(l10n.backupReplaceConfirmTitle),
          content: Text(summary),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dCtx).pop(false),
              child: Text(l10n.cancelAction),
            ),
            TextButton(
              onPressed: () => Navigator.of(dCtx).pop(true),
              child: Text(
                l10n.backupReplaceConfirmAction,
                style: TextStyle(color: dCtx.colors.statusDanger),
              ),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;

      setState(() {
        _busy = true;
        _inlineError = null;
        _stage = BackupStage.verifying;
      });

      await service.restorePcrmBackup(
        filePath: pickedPath,
        passphrase: passphrase,
        closeDb: () async {
          await ref.read(appDatabaseProvider).close();
        },
        reopenDb: () async {
          ref.read(dbRevisionProvider.notifier).bump();
          return ref.read(appDatabaseProvider);
        },
        onStage: (s) {
          if (mounted) setState(() => _stage = s);
        },
      );

      unawaited(ref.read(notificationsServiceProvider).rescheduleAll());
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.backupRestoredSnack)));
      }
    } on WrongPassphraseException {
      if (mounted) {
        setState(() => _inlineError = l10n.backupWrongPassphrase);
      }
    } on CorruptBackupException {
      if (mounted) {
        setState(() => _inlineError = l10n.backupCorruptError);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _inlineError = l10n.backupCorruptError);
      }
    } finally {
      try {
        final f = File(pickedPath);
        if (await f.exists()) await f.delete();
      } catch (_) {}
      if (mounted) {
        setState(() {
          _busy = false;
          _stage = null;
        });
      }
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

    final lastBackupMs = int.tryParse(ref.watch(_backupSettingProvider('last_backup_at')).value ?? '');
    final autoEnabled = (ref.watch(_backupSettingProvider('auto_backup_enabled')).value) != '0';
    final autoCount = ref.watch(_autoBackupsCountProvider).value ?? 0;

    return Scaffold(
      backgroundColor: c.bgCanvas,
      appBar: AppBar(
        backgroundColor: c.bgCanvas,
        title: Text(l10n.backupTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppTokens.space32),
        children: [
          SettingRow(
            label: l10n.backupLastTime,
            value: lastBackupMs != null
                ? fmt.formatRelativeDateTime(lastBackupMs, l10n)
                : l10n.backupNever,
          ),
          Divider(height: 1, color: c.borderHairline),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.screenPadding,
              AppTokens.space16,
              AppTokens.screenPadding,
              AppTokens.space12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    l10n.backupIncludeFiles,
                    style: tt.bodyLarge!.copyWith(color: c.textPrimary),
                  ),
                  value: _includeAttachments,
                  onChanged: _busy ? null : (v) => setState(() => _includeAttachments = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    l10n.backupProtectPassphrase,
                    style: tt.bodyLarge!.copyWith(color: c.textPrimary),
                  ),
                  value: _protectWithPassphrase,
                  onChanged: _busy
                      ? null
                      : (v) => setState(() {
                            _protectWithPassphrase = v;
                            _inlineError = null;
                          }),
                ),
                if (_protectWithPassphrase) ...[
                  const SizedBox(height: AppTokens.space8),
                  TextField(
                    controller: _passphraseController,
                    obscureText: true,
                    enabled: !_busy,
                    decoration: InputDecoration(
                      hintText: l10n.backupPassphraseHint,
                    ),
                  ),
                  const SizedBox(height: AppTokens.space8),
                  TextField(
                    controller: _confirmPassphraseController,
                    obscureText: true,
                    enabled: !_busy,
                    decoration: InputDecoration(
                      hintText: l10n.backupPassphraseConfirmHint,
                    ),
                  ),
                  const SizedBox(height: AppTokens.space8),
                  Text(
                    l10n.backupPassphraseWarning,
                    style: tt.bodySmall!.copyWith(color: c.textSecondary),
                  ),
                ],
                if (_inlineError != null) ...[
                  const SizedBox(height: AppTokens.space12),
                  Text(
                    _inlineError!,
                    style: tt.bodySmall!.copyWith(color: c.statusDanger),
                  ),
                ],
                if (_busy && _stage != null) ...[
                  const SizedBox(height: AppTokens.space12),
                  Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: c.accentDefault,
                        ),
                      ),
                      const SizedBox(width: AppTokens.space8),
                      Expanded(
                        child: Text(
                          _stageText(context, _stage!),
                          style: tt.bodySmall!.copyWith(color: c.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppTokens.space16),
                AppButton(
                  label: l10n.backupNowAction,
                  variant: AppButtonVariant.primary,
                  fullWidth: true,
                  onPressed: _busy ? null : _onBackupNow,
                ),
                const SizedBox(height: AppTokens.space8),
                AppButton(
                  label: l10n.backupRestoreAction,
                  variant: AppButtonVariant.secondary,
                  fullWidth: true,
                  onPressed: _busy ? null : _onRestoreFromBackup,
                ),
              ],
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    l10n.backupAutoTitle,
                    style: tt.bodyLarge!.copyWith(color: c.textPrimary),
                  ),
                  subtitle: Text(
                    autoCount > 0
                        ? '${l10n.backupAutoSubtitle} · ${l10n.backupAutoCount(autoCount)}'
                        : l10n.backupAutoSubtitle,
                    style: tt.bodySmall!.copyWith(color: c.textSecondary),
                  ),
                  value: autoEnabled,
                  onChanged: _busy
                      ? null
                      : (v) async {
                          await ref
                              .read(settingsRepositoryProvider)
                              .set('auto_backup_enabled', v ? '1' : '0');
                        },
                ),
                const SizedBox(height: AppTokens.space4),
                Text(
                  l10n.backupAutoExplanation,
                  style: tt.bodySmall!.copyWith(color: c.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

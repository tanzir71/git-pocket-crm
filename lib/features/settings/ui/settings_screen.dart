import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/format/app_formatters.dart';
import '../../../core/l10n_ext.dart';
import '../../../core/native/device_api.g.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../../messages/data/campaigns_repository.dart';

final _settingStreamProvider =
    StreamProvider.autoDispose.family<String?, String>((ref, key) {
  return ref.watch(settingsRepositoryProvider).watch(key);
});

final _lastSyncAtProvider = FutureProvider.autoDispose<int?>((ref) {
  return ref.watch(syncStateRepositoryProvider).getInt('last_sync_success_at');
});

/// Complete Settings screen matching `handover/03-screens.md`.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _syncing = false;

  Future<void> _editTextSetting({
    required String title,
    required String key,
    required String currentValue,
    String? hint,
  }) async {
    final controller = TextEditingController(text: currentValue);
    final saved = await showAppSheet<String>(
      context: context,
      bodyBuilder: (ctx) {
        final l10n = ctx.l10n;
        final c = ctx.colors;
        final tt = Theme.of(ctx).textTheme;
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
              Text(title, style: tt.titleMedium!.copyWith(color: c.textPrimary)),
              const SizedBox(height: AppTokens.space12),
              AppField(
                controller: controller,
                hintText: hint,
                autofocus: true,
              ),
              const SizedBox(height: AppTokens.space16),
              AppButton(
                label: l10n.saveAction,
                variant: AppButtonVariant.primary,
                fullWidth: true,
                onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
              ),
            ],
          ),
        );
      },
    );
    controller.dispose();
    if (saved != null) {
      await ref.read(settingsRepositoryProvider).set(key, saved);
    }
  }

  Future<void> _pickOption({
    required String title,
    required List<(String value, String label)> options,
    required String current,
    required Future<void> Function(String chosen) onChosen,
    bool searchable = false,
    String? searchHint,
  }) async {
    final searchController = TextEditingController();
    final picked = await showAppSheet<String>(
      context: context,
      bodyBuilder: (ctx) {
        final c = ctx.colors;
        final tt = Theme.of(ctx).textTheme;
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final query = searchController.text.trim().toLowerCase();
            final filtered = query.isEmpty
                ? options
                : options
                    .where(
                      (o) =>
                          o.$1.toLowerCase().contains(query) ||
                          o.$2.toLowerCase().contains(query),
                    )
                    .toList();
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(title, style: tt.titleMedium!.copyWith(color: c.textPrimary)),
                if (searchable) ...[
                  const SizedBox(height: AppTokens.space12),
                  AppField(
                    controller: searchController,
                    hintText: searchHint,
                    onChanged: (_) => setSheetState(() {}),
                  ),
                ],
                const SizedBox(height: AppTokens.space8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 360),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final (value, label) in filtered)
                          InkWell(
                            onTap: () => Navigator.of(ctx).pop(value),
                            child: ConstrainedBox(
                              constraints:
                                  const BoxConstraints(minHeight: AppTokens.minTouchTarget),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      label,
                                      style: tt.bodyLarge!.copyWith(color: c.textPrimary),
                                    ),
                                  ),
                                  if (value == current)
                                    Icon(Icons.check, size: 20, color: c.accentDefault),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
    searchController.dispose();
    if (picked != null) {
      await onChosen(picked);
    }
  }

  Future<void> _pickMorningSummary(bool enabled, int hour, int minute) async {
    final l10n = context.l10n;
    await _pickOption(
      title: l10n.settingsMorningSummary,
      options: [
        ('off', l10n.settingsOff),
        ('time', '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}'),
      ],
      current: enabled ? 'time' : 'off',
      onChosen: (v) async {
        final settings = ref.read(settingsRepositoryProvider);
        if (v == 'off') {
          await settings.set('morning_summary_enabled', '0');
          await ref.read(notificationsServiceProvider).rescheduleAll();
          return;
        }
        if (!mounted) return;
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: hour, minute: minute),
        );
        await settings.set('morning_summary_enabled', '1');
        if (picked != null) {
          await settings.set('morning_summary_hour', '${picked.hour}');
          await settings.set('morning_summary_minute', '${picked.minute}');
        }
        await ref.read(notificationsServiceProvider).rescheduleAll();
      },
    );
  }

  Future<void> _pickSendWindow(int startMin, int endMin) async {
    final start = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: startMin ~/ 60, minute: startMin % 60),
    );
    if (start == null || !mounted) return;
    final end = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: endMin ~/ 60, minute: endMin % 60),
    );
    if (end == null) return;
    final sMin = start.hour * 60 + start.minute;
    final eMin = end.hour * 60 + end.minute;
    if (eMin > sMin) {
      final settings = ref.read(settingsRepositoryProvider);
      await settings.set('send_window_start_min', '$sMin');
      await settings.set('send_window_end_min', '$eMin');
    }
  }

  Future<void> _syncNow() async {
    if (_syncing) return;
    setState(() => _syncing = true);
    try {
      await ref.read(syncServiceProvider).syncAll();
      await ref.read(outboxRepositoryProvider).reconcile();
      ref.invalidate(_lastSyncAtProvider);
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(context.l10n.settingsSyncComplete)));
      }
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  Future<void> _runExport(Future<bool> Function() action) async {
    try {
      final saved = await action();
      if (saved && mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(context.l10n.exportSavedSnack)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(context.l10n.exportFailedSnack)));
      }
    }
  }

  String _fmtMin(int min) {
    final h = (min ~/ 60).toString().padLeft(2, '0');
    final m = (min % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final settings = ref.read(settingsRepositoryProvider);
    final clock = ref.watch(clockProvider);
    final fmt = AppFormatters(
      clock: clock,
      localeName: Localizations.localeOf(context).toLanguageTag(),
      use24Hour: MediaQuery.alwaysUse24HourFormatOf(context),
    );

    final myName = ref.watch(_settingStreamProvider('my_name')).value ?? '';
    final currency = ref.watch(currencyCodeProvider).value ?? 'USD';
    final phoneRegion = ref.watch(phoneRegionProvider).value ?? 'US';
    final themeMode = ref.watch(_settingStreamProvider('theme_mode')).value ?? 'system';
    final language = ref.watch(_settingStreamProvider('language')).value ?? 'system';
    final afterCallMode = ref.watch(afterCallModeProvider).value ?? 'all';
    final summaryEnabled =
        (ref.watch(_settingStreamProvider('morning_summary_enabled')).value) != '0';
    final summaryHour =
        int.tryParse(ref.watch(_settingStreamProvider('morning_summary_hour')).value ?? '') ?? 9;
    final summaryMin =
        int.tryParse(ref.watch(_settingStreamProvider('morning_summary_minute')).value ?? '') ?? 0;
    final reconnectNudges =
        (ref.watch(_settingStreamProvider('reconnect_nudges_enabled')).value) != '0';
    final paceSetting = ref.watch(_settingStreamProvider('default_pace')).value ?? 'fast';
    final wsMin =
        int.tryParse(ref.watch(_settingStreamProvider('send_window_start_min')).value ?? '') ??
            9 * 60;
    final weMin =
        int.tryParse(ref.watch(_settingStreamProvider('send_window_end_min')).value ?? '') ??
            21 * 60;
    final optOutWords =
        ref.watch(_settingStreamProvider('opt_out_words')).value ?? 'STOP, UNSUBSCRIBE, বন্ধ';
    final lastSyncMs = ref.watch(_lastSyncAtProvider).value;

    final themeLabel = switch (themeMode) {
      'light' => l10n.settingsThemeLight,
      'dark' => l10n.settingsThemeDark,
      _ => l10n.settingsThemeSystem,
    };
    final languageLabel = switch (language) {
      'en' => l10n.settingsLanguageEnglish,
      'bn' => l10n.settingsLanguageBengali,
      _ => l10n.settingsLanguageSystem,
    };
    final afterCallLabel = switch (afterCallMode) {
      'starred' => l10n.settingsAfterCallStarred,
      'never' => l10n.settingsAfterCallNever,
      _ => l10n.settingsAfterCallAll,
    };
    final paceLabel = switch (CampaignPace.fromSetting(paceSetting)) {
      CampaignPace.fast => l10n.paceFastTitle,
      CampaignPace.steady => l10n.paceSteadyTitle,
      CampaignPace.careful => l10n.paceCarefulTitle,
    };

    return Scaffold(
      backgroundColor: c.bgCanvas,
      appBar: AppBar(
        backgroundColor: c.bgCanvas,
        title: Text(l10n.settingsTitle),
      ),
      body: ListView(
        children: [
          SectionHeader(title: l10n.settingsSectionGeneral),
          SettingRow(
            label: l10n.settingsYourName,
            value: myName.isEmpty ? l10n.settingsNotSet : myName,
            onTap: () => _editTextSetting(
              title: l10n.settingsYourName,
              key: 'my_name',
              currentValue: myName,
            ),
          ),
          SettingRow(
            label: l10n.settingsCurrency,
            value: currency,
            onTap: () => _pickOption(
              title: l10n.settingsCurrency,
              searchable: true,
              searchHint: l10n.settingsCurrencySearchHint,
              options: [
                for (final code in AppFormatters.currencySymbols.keys)
                  (code, '$code (${AppFormatters.symbolForCurrency(code).trim()})'),
              ],
              current: currency,
              onChosen: (v) => settings.set('currency_code', v),
            ),
          ),
          SettingRow(
            label: l10n.settingsPhoneRegion,
            value: phoneRegion,
            onTap: () => _pickOption(
              title: l10n.settingsPhoneRegion,
              options: const [
                ('US', 'US (+1)'),
                ('BD', 'BD (+880)'),
                ('GB', 'GB (+44)'),
                ('IN', 'IN (+91)'),
                ('NG', 'NG (+234)'),
                ('CA', 'CA (+1)'),
                ('AU', 'AU (+61)'),
                ('AE', 'AE (+971)'),
                ('PK', 'PK (+92)'),
                ('KE', 'KE (+254)'),
                ('ZA', 'ZA (+27)'),
              ],
              current: phoneRegion,
              onChosen: (v) => settings.set('phone_region', v),
            ),
          ),
          SettingRow(
            label: l10n.settingsTheme,
            value: themeLabel,
            onTap: () => _pickOption(
              title: l10n.settingsTheme,
              options: [
                ('system', l10n.settingsThemeSystem),
                ('light', l10n.settingsThemeLight),
                ('dark', l10n.settingsThemeDark),
              ],
              current: themeMode,
              onChosen: (v) => settings.set('theme_mode', v),
            ),
          ),
          SettingRow(
            label: l10n.settingsLanguage,
            value: languageLabel,
            onTap: () => _pickOption(
              title: l10n.settingsLanguage,
              options: [
                ('system', l10n.settingsLanguageSystem),
                ('en', l10n.settingsLanguageEnglish),
                ('bn', l10n.settingsLanguageBengali),
              ],
              current: language,
              onChosen: (v) => settings.set('language', v),
            ),
          ),

          SectionHeader(title: l10n.settingsSectionAfterCalls),
          SettingRow(
            label: l10n.settingsAfterCallPrompt,
            value: afterCallLabel,
            onTap: () => _pickOption(
              title: l10n.settingsAfterCallPrompt,
              options: [
                ('all', l10n.settingsAfterCallAll),
                ('starred', l10n.settingsAfterCallStarred),
                ('never', l10n.settingsAfterCallNever),
              ],
              current: afterCallMode,
              onChosen: (v) async {
                await settings.set('after_call_mode', v);
                try {
                  await DeviceApi().setAfterCallMode(v);
                } catch (_) {}
              },
            ),
          ),

          SectionHeader(title: l10n.settingsSectionReminders),
          SettingRow(
            label: l10n.settingsMorningSummary,
            value: summaryEnabled
                ? _fmtMin(summaryHour * 60 + summaryMin)
                : l10n.settingsOff,
            onTap: () => _pickMorningSummary(summaryEnabled, summaryHour, summaryMin),
          ),
          SettingRow(
            label: l10n.settingsReconnectNudges,
            value: reconnectNudges ? l10n.settingsOn : l10n.settingsOff,
            onTap: () async {
              await settings.set(
                'reconnect_nudges_enabled',
                reconnectNudges ? '0' : '1',
              );
              await ref.read(notificationsServiceProvider).rescheduleAll();
            },
          ),

          SectionHeader(title: l10n.settingsSectionMessages),
          SettingRow(
            label: l10n.settingsDefaultPace,
            value: paceLabel,
            onTap: () => _pickOption(
              title: l10n.settingsDefaultPace,
              options: [
                ('fast', '${l10n.paceFastTitle} · ${l10n.paceEveryNSeconds(4)}'),
                ('steady', '${l10n.paceSteadyTitle} · ${l10n.paceEveryNSeconds(15)}'),
                ('careful', '${l10n.paceCarefulTitle} · ${l10n.paceOnePerMinute}'),
              ],
              current: paceSetting,
              onChosen: (v) => settings.set('default_pace', v),
            ),
          ),
          SettingRow(
            label: l10n.settingsSendWindow,
            value: '${_fmtMin(wsMin)} – ${_fmtMin(weMin)}',
            onTap: () => _pickSendWindow(wsMin, weMin),
          ),
          SettingRow(
            label: l10n.settingsOptOutWords,
            value: optOutWords,
            onTap: () => _editTextSetting(
              title: l10n.settingsOptOutWords,
              key: 'opt_out_words',
              currentValue: optOutWords,
            ),
          ),

          SectionHeader(title: l10n.settingsSectionData),
          SettingRow(
            label: l10n.settingsSyncNow,
            value: _syncing
                ? l10n.setupSyncingHistory
                : (lastSyncMs != null
                    ? fmt.formatRelativeDateTime(lastSyncMs, l10n)
                    : l10n.settingsSyncNever),
            onTap: _syncNow,
          ),
          SettingRow(
            label: l10n.backupTitle,
            onTap: () => context.push('/settings/backup'),
          ),
          SettingRow(
            label: l10n.settingsExportPeopleCsv,
            onTap: () => _runExport(() => ref.read(exportServiceProvider).exportPeopleCsvToSaf()),
          ),
          SettingRow(
            label: l10n.settingsExportPeopleVcard,
            onTap: () => _runExport(() => ref.read(exportServiceProvider).exportPeopleVcardToSaf()),
          ),
          SettingRow(
            label: l10n.settingsCheckSetup,
            onTap: () => context.push('/setup?mode=check'),
          ),

          SectionHeader(title: l10n.settingsSectionAbout),
          SettingRow(
            label: l10n.settingsVersion,
            value: '2.0.0',
          ),
          SettingRow(
            label: l10n.settingsLicences,
            onTap: () => showLicensePage(
              context: context,
              applicationName: l10n.appTitle,
              applicationVersion: '2.0.0',
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppTokens.screenPadding,
              AppTokens.space12,
              AppTokens.screenPadding,
              AppTokens.space32,
            ),
            child: Text(
              l10n.settingsNoInternetStatement,
              style: tt.bodySmall!.copyWith(color: c.textTertiary),
            ),
          ),
        ],
      ),
    );
  }
}

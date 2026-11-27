import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: c.bgCanvas,
      appBar: AppBar(
        backgroundColor: c.bgCanvas,
        title: Text(l10n.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppTokens.screenPadding),
        children: [
          SettingRow(
            label: l10n.backupTitle,
            onTap: () => context.push('/settings/backup'),
          ),
          SettingRow(
            label: l10n.setupTitle,
            onTap: () => context.push('/setup'),
          ),
        ],
      ),
    );
  }
}

class BackupSettingsScreen extends StatelessWidget {
  const BackupSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: c.bgCanvas,
      appBar: AppBar(
        backgroundColor: c.bgCanvas,
        title: Text(l10n.backupTitle),
      ),
      body: const SizedBox.shrink(),
    );
  }
}

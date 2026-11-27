import 'package:material_ui/material_ui.dart';

import '../../../core/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: context.colors.bgCanvas,
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: EmptyState(
        title: l10n.settingsTitle,
        message: l10n.settingsPlaceholder,
      ),
    );
  }
}

class BackupSettingsScreen extends StatelessWidget {
  const BackupSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: context.colors.bgCanvas,
      appBar: AppBar(title: Text(l10n.backupTitle)),
      body: EmptyState(
        title: l10n.backupTitle,
        message: l10n.backupPlaceholder,
      ),
    );
  }
}

import 'package:material_ui/material_ui.dart';

import '../../../core/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

class PersonScreen extends StatelessWidget {
  const PersonScreen({super.key, required this.contactId});

  final int contactId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: context.colors.bgCanvas,
      appBar: AppBar(title: Text(l10n.personTitle)),
      body: EmptyState(
        title: l10n.personTitle,
        message: l10n.tabPeoplePlaceholder,
      ),
    );
  }
}

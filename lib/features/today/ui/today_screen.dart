import 'package:material_ui/material_ui.dart';

import '../../../core/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: c.bgCanvas,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.screenPadding,
                AppTokens.space16,
                AppTokens.screenPadding,
                AppTokens.space8,
              ),
              child: Text(l10n.navToday, style: tt.headlineMedium),
            ),
            Expanded(
              child: EmptyState(
                title: l10n.placeholderTitle,
                message: l10n.tabTodayPlaceholder,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

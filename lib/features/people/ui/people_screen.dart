import 'package:material_ui/material_ui.dart';

import '../../../core/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: c.bgCanvas,
      body: SafeArea(
        child: ListView(
          controller: _scrollController,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.screenPadding,
                AppTokens.space16,
                AppTokens.screenPadding,
                AppTokens.space8,
              ),
              child: Text(l10n.navPeople, style: tt.headlineMedium),
            ),
            EmptyState(
              title: l10n.placeholderTitle,
              message: l10n.tabPeoplePlaceholder,
            ),
          ],
        ),
      ),
    );
  }
}

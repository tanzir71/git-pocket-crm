import 'package:material_ui/material_ui.dart';

import '../../../core/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

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
              child: Text(l10n.navMessages, style: tt.headlineMedium),
            ),
            Expanded(
              child: EmptyState(
                title: l10n.placeholderTitle,
                message: l10n.tabMessagesPlaceholder,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewMessageScreen extends StatelessWidget {
  const NewMessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: context.colors.bgCanvas,
      appBar: AppBar(title: Text(l10n.newMessageTitle)),
      body: EmptyState(
        title: l10n.newMessageTitle,
        message: l10n.tabMessagesPlaceholder,
      ),
    );
  }
}

class CampaignScreen extends StatelessWidget {
  const CampaignScreen({super.key, required this.campaignId});

  final String campaignId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: context.colors.bgCanvas,
      appBar: AppBar(title: Text(l10n.campaignTitle)),
      body: EmptyState(
        title: l10n.campaignTitle,
        message: l10n.tabMessagesPlaceholder,
      ),
    );
  }
}

class SentMessagesScreen extends StatelessWidget {
  const SentMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: context.colors.bgCanvas,
      appBar: AppBar(title: Text(l10n.sentMessagesTitle)),
      body: EmptyState(
        title: l10n.sentMessagesTitle,
        message: l10n.tabMessagesPlaceholder,
      ),
    );
  }
}

class TemplateEditorScreen extends StatelessWidget {
  const TemplateEditorScreen({super.key, required this.templateId});

  final String templateId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: context.colors.bgCanvas,
      appBar: AppBar(title: Text(l10n.templateTitle)),
      body: EmptyState(
        title: l10n.templateTitle,
        message: l10n.tabMessagesPlaceholder,
      ),
    );
  }
}

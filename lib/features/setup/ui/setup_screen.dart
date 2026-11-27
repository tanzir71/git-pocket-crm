import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n_ext.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';

class SetupScreen extends ConsumerWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l10n = context.l10n;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: c.bgCanvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppTokens.space16),
              Text(
                l10n.setupTitle,
                style: tt.headlineMedium!.copyWith(color: c.textPrimary),
              ),
              const Spacer(),
              AppButton(
                label: l10n.continueLabel,
                variant: AppButtonVariant.primary,
                fullWidth: true,
                onPressed: () {
                  ref.read(setupDeferredProvider.notifier).defer();
                  context.go('/people');
                },
              ),
              const SizedBox(height: AppTokens.space8),
              AppButton(
                label: l10n.doThisLater,
                variant: AppButtonVariant.quiet,
                fullWidth: true,
                onPressed: () {
                  ref.read(setupDeferredProvider.notifier).defer();
                  context.go('/today');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

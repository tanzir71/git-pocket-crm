import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';
import 'avatar.dart';

class PromptCard extends StatelessWidget {
  const PromptCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.avatarName,
    this.toneIndex = 0,
    this.leadingIcon,
    this.actions = const [],
  });

  final String title;
  final String subtitle;
  final String? avatarName;
  final int toneIndex;
  final IconData? leadingIcon;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTokens.screenPadding),
      padding: const EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: c.bgSurface,
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        border: Border.all(color: c.borderHairline, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (avatarName != null) ...[
                Avatar(name: avatarName!, toneIndex: toneIndex),
                const SizedBox(width: AppTokens.space12),
              ] else if (leadingIcon != null) ...[
                Container(
                  width: AppTokens.avatarSize,
                  height: AppTokens.avatarSize,
                  decoration: BoxDecoration(
                    color: c.bgSubtle,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(leadingIcon, size: 20, color: c.textPrimary),
                ),
                const SizedBox(width: AppTokens.space12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium!.copyWith(color: c.textPrimary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall!.copyWith(color: c.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: AppTokens.space8,
              runSpacing: AppTokens.space4,
              children: actions,
            ),
          ],
        ],
      ),
    );
  }
}

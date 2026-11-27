import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';
import 'avatar.dart';

class PersonRow extends StatelessWidget {
  const PersonRow({
    super.key,
    required this.name,
    required this.toneIndex,
    this.meta,
    this.trailing,
    this.trailingWidget,
    this.metaIsDanger = false,
    this.selected = false,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
  });

  final String name;
  final int toneIndex;
  final String? meta;
  final String? trailing;
  final Widget? trailingWidget;
  final bool metaIsDanger;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      button: onTap != null,
      selected: selected,
      label: semanticLabel ?? [name, if (meta != null) meta, if (trailing != null) trailing].join(', '),
      child: Material(
        color: selected ? c.bgSubtle : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppTokens.minTouchTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.screenPadding,
                vertical: 10,
              ),
              child: Row(
                children: [
                  Avatar(name: name, toneIndex: toneIndex),
                  const SizedBox(width: AppTokens.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name,
                          style: textTheme.labelLarge!.copyWith(color: c.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (meta != null && meta!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            meta!,
                            style: textTheme.bodySmall!.copyWith(
                              color: metaIsDanger ? c.statusDanger : c.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailingWidget != null) ...[
                    const SizedBox(width: AppTokens.space12),
                    trailingWidget!,
                  ] else if (trailing != null && trailing!.isNotEmpty) ...[
                    const SizedBox(width: AppTokens.space12),
                    Text(
                      trailing!,
                      style: textTheme.bodySmall!.copyWith(color: c.textTertiary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

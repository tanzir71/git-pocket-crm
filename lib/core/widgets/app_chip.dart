import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';

class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.selected = false,
    this.leadingIcon,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
  });

  final String label;
  final bool selected;
  final IconData? leadingIcon;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textTheme = Theme.of(context).textTheme;

    final fg = selected ? c.textOnInverse : c.textSecondary;
    final bg = selected ? c.bgInverse : c.bgSurface;
    final border = selected ? null : Border.all(color: c.borderHairline, width: 1);

    final pill = Container(
      height: AppTokens.chipHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.space12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTokens.radiusFull),
        border: border,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingIcon != null) ...[
            Icon(leadingIcon, size: 15, color: fg),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: textTheme.labelMedium!.copyWith(color: fg),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    return Semantics(
      button: onTap != null,
      selected: selected,
      label: semanticLabel ?? label,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: AppTokens.minTouchTarget,
          minHeight: AppTokens.minTouchTarget,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            borderRadius: BorderRadius.circular(AppTokens.radiusFull),
            child: Center(
              widthFactor: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: (AppTokens.minTouchTarget - AppTokens.chipHeight) / 2,
                ),
                child: pill,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

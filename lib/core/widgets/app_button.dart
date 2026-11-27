import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';

enum AppButtonVariant { primary, secondary, quiet }

enum AppButtonSize { regular, small }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.regular,
    this.fullWidth = false,
    this.leadingIcon,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool fullWidth;
  final IconData? leadingIcon;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final isSmall = size == AppButtonSize.small;
    final height = isSmall ? AppTokens.buttonSmallHeight : AppTokens.buttonHeight;
    final radius = isSmall ? AppTokens.radiusButtonSmall : AppTokens.radiusControl;

    final Color bg = switch (variant) {
      AppButtonVariant.primary => c.accentDefault,
      AppButtonVariant.secondary => c.bgSubtle,
      AppButtonVariant.quiet => Colors.transparent,
    };

    final Color fg = switch (variant) {
      AppButtonVariant.primary => c.textOnAccent,
      AppButtonVariant.secondary => c.textPrimary,
      AppButtonVariant.quiet => c.textSecondary,
    };

    final double hPad = switch ((variant, size)) {
      (AppButtonVariant.quiet, AppButtonSize.small) => AppTokens.space8,
      (AppButtonVariant.quiet, AppButtonSize.regular) => AppTokens.space12,
      (_, AppButtonSize.small) => 14,
      (_, AppButtonSize.regular) => AppTokens.space20,
    };

    final TextStyle style = (isSmall ? textTheme.labelMedium! : textTheme.labelLarge!).copyWith(
      color: onPressed == null ? fg.withValues(alpha: 0.45) : fg,
    );

    final Color effectiveBg = onPressed == null && bg != Colors.transparent
        ? bg.withValues(alpha: 0.45)
        : bg;

    final Widget content = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon != null) ...[
          Icon(leadingIcon, size: isSmall ? 16 : 18, color: style.color),
          const SizedBox(width: AppTokens.space8),
        ],
        Flexible(
          child: Text(
            label,
            style: style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    final visibleBox = Ink(
      height: height,
      width: fullWidth ? double.infinity : null,
      padding: EdgeInsets.symmetric(horizontal: hPad),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Center(widthFactor: fullWidth ? null : 1, child: content),
    );

    // Ensure at least a 48x48 touch target even for 36-tall small buttons.
    return Semantics(
      button: true,
      enabled: onPressed != null,
      excludeSemantics: true,
      label: semanticLabel ?? label,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: AppTokens.minTouchTarget,
          minHeight: AppTokens.minTouchTarget,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(radius),
            child: Align(
              alignment: Alignment.center,
              widthFactor: fullWidth ? null : 1,
              heightFactor: 1,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: isSmall
                      ? (AppTokens.minTouchTarget - AppTokens.buttonSmallHeight) / 2
                      : 0,
                ),
                child: visibleBox,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

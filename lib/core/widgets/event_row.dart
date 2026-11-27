import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';

class EventRow extends StatelessWidget {
  const EventRow({
    super.key,
    required this.icon,
    required this.title,
    this.body,
    this.timeLine,
    this.isError = false,
    this.trailing,
    this.footer,
    this.maxBodyLines = 3,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
  });

  final IconData icon;
  final String title;
  final String? body;
  final String? timeLine;
  final bool isError;
  final Widget? trailing;
  final Widget? footer;
  final int maxBodyLines;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      button: onTap != null,
      label: semanticLabel ?? [title, if (body != null) body, if (timeLine != null) timeLine].join(', '),
      child: Material(
        color: Colors.transparent,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: AppTokens.eventCircleSize,
                    height: AppTokens.eventCircleSize,
                    decoration: BoxDecoration(
                      color: isError ? c.statusDangerSoft : c.bgSubtle,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      icon,
                      size: AppTokens.eventIconSize,
                      color: isError ? c.statusDanger : c.textPrimary,
                    ),
                  ),
                  const SizedBox(width: AppTokens.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: textTheme.labelLarge!.copyWith(color: c.textPrimary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (body != null && body!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            body!,
                            style: textTheme.bodyMedium!.copyWith(
                              color: isError ? c.statusDanger : c.textSecondary,
                            ),
                            maxLines: maxBodyLines,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (timeLine != null && timeLine!.isNotEmpty) ...[
                          const SizedBox(height: AppTokens.space4),
                          Text(
                            timeLine!,
                            style: textTheme.bodySmall!.copyWith(color: c.textTertiary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (footer != null) ...[
                          const SizedBox(height: AppTokens.space8),
                          footer!,
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: AppTokens.space8),
                    trailing!,
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

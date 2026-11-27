import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';

class SettingRow extends StatelessWidget {
  const SettingRow({
    super.key,
    required this.label,
    this.value,
    this.subtitle,
    this.showChevron = true,
    this.trailing,
    this.onTap,
    this.semanticLabel,
  });

  final String label;
  final String? value;
  final String? subtitle;
  final bool showChevron;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      button: onTap != null,
      label: semanticLabel ?? [label, if (value != null) value].join(', '),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppTokens.minTouchTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.screenPadding,
                vertical: 14,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: textTheme.bodyMedium!.copyWith(color: c.textPrimary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null && subtitle!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: textTheme.bodySmall!.copyWith(color: c.textSecondary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (value != null && value!.isNotEmpty) ...[
                    const SizedBox(width: AppTokens.space12),
                    Flexible(
                      child: Text(
                        value!,
                        style: textTheme.bodyMedium!.copyWith(color: c.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                  if (trailing != null) ...[
                    const SizedBox(width: AppTokens.space8),
                    trailing!,
                  ] else if (showChevron) ...[
                    const SizedBox(width: AppTokens.space8),
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: c.textTertiary,
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

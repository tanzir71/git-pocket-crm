import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';

class TaskRow extends StatelessWidget {
  const TaskRow({
    super.key,
    required this.title,
    this.meta,
    this.completed = false,
    this.isOverdue = false,
    this.onToggle,
    this.onTap,
    this.checkboxSemanticLabel,
  });

  final String title;
  final String? meta;
  final bool completed;
  final bool isOverdue;
  final VoidCallback? onToggle;
  final VoidCallback? onTap;
  final String? checkboxSemanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textTheme = Theme.of(context).textTheme;

    final circle = Semantics(
      button: true,
      checked: completed,
      label: checkboxSemanticLabel ?? title,
      child: InkResponse(
        onTap: onToggle,
        radius: 24,
        child: SizedBox(
          width: AppTokens.minTouchTarget,
          height: AppTokens.minTouchTarget,
          child: Center(
            child: AnimatedContainer(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 150),
              width: AppTokens.taskCircleSize,
              height: AppTokens.taskCircleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: completed ? c.bgInverse : Colors.transparent,
                border: Border.all(
                  color: completed ? c.bgInverse : c.borderStrong,
                  width: AppTokens.taskCircleStroke,
                ),
              ),
              child: completed
                  ? Icon(Icons.check, size: 14, color: c.textOnInverse)
                  : null,
            ),
          ),
        ),
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppTokens.minTouchTarget),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              // 20 screen padding minus the 13px extra touch target padding around the 22px circle
              7,
              4,
              AppTokens.screenPadding,
              4,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                circle,
                const SizedBox(width: 2),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: textTheme.bodyMedium!.copyWith(
                            color: completed ? c.textTertiary : c.textPrimary,
                            decoration: completed ? TextDecoration.lineThrough : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (meta != null && meta!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            meta!,
                            style: textTheme.bodySmall!.copyWith(
                              color: isOverdue && !completed
                                  ? c.statusDanger
                                  : c.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

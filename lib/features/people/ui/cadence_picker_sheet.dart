import 'package:material_ui/material_ui.dart';

import '../../../core/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';

/// Special sentinel distinguishing "user chose Never (null)" from "dismissed".
class CadencePickerResult {
  const CadencePickerResult(this.days);
  final int? days;
}

/// Shows the "How often to reconnect" sheet.
/// Returns `null` if dismissed, or `CadencePickerResult(days)` (`days == null` = Never).
Future<CadencePickerResult?> showCadencePickerSheet(
  BuildContext context, {
  int? currentDays,
  String? listName,
  int? affectedListMembersCount,
}) {
  final l10n = context.l10n;
  final options = <(int?, String)>[
    (7, l10n.cadenceWeekly),
    (14, l10n.cadenceBiweekly),
    (30, l10n.cadenceMonthly),
    (90, l10n.cadenceQuarterly),
    (180, l10n.cadenceHalfYearly),
    (365, l10n.cadenceYearly),
    (null, l10n.cadenceNever),
  ];

  return showAppSheet<CadencePickerResult>(
    context: context,
    bodyBuilder: (ctx) {
      final c = ctx.colors;
      final tt = Theme.of(ctx).textTheme;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.screenPadding,
              AppTokens.space8,
              AppTokens.screenPadding,
              AppTokens.space8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.cadencePickerTitle,
                  style: tt.titleMedium!.copyWith(color: c.textPrimary),
                ),
                if (listName != null && affectedListMembersCount != null) ...[
                  const SizedBox(height: AppTokens.space4),
                  Text(
                    l10n.cadenceListHint(affectedListMembersCount, listName),
                    style: tt.bodySmall!.copyWith(color: c.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          for (final (days, label) in options)
            InkWell(
              onTap: () => Navigator.of(ctx).pop(CadencePickerResult(days)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: AppTokens.minTouchTarget),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTokens.screenPadding,
                    vertical: AppTokens.space12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: tt.bodyLarge!.copyWith(color: c.textPrimary),
                        ),
                      ),
                      if (currentDays == days)
                        Icon(Icons.check, size: 20, color: c.textPrimary),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: AppTokens.space12),
        ],
      );
    },
  );
}

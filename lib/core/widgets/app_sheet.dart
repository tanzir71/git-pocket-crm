import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';

/// Shows a modal bottom sheet adhering to `02-design-system.md`:
/// - `bg/surface`, top radius 28, scrim black 45%
/// - 36x4 handle in `bg/subtle`
/// - padding 20 sides, 12 top, 28 bottom, 16 between blocks
/// - max height 90% of screen, scrollable body, pinned bottom button above keyboard
Future<T?> showAppSheet<T>({
  required BuildContext context,
  String? title,
  Widget? header,
  required WidgetBuilder bodyBuilder,
  WidgetBuilder? bottomActionBuilder,
  double maxHeightFraction = 0.9,
  bool isDismissible = true,
  bool enableDrag = true,
}) {
  final c = context.colors;
  final disableAnim = MediaQuery.disableAnimationsOf(context);

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    useSafeArea: true,
    backgroundColor: c.bgSurface,
    barrierColor: c.scrim,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppTokens.radiusSheetTop),
      ),
    ),
    sheetAnimationStyle: AnimationStyle(
      duration: disableAnim ? Duration.zero : AppTokens.sheetSlideDuration,
      reverseDuration: disableAnim ? Duration.zero : AppTokens.sheetSlideDuration,
      curve: Curves.decelerate,
    ),
    builder: (sheetContext) {
      return AppSheetContainer(
        title: title,
        header: header,
        maxHeightFraction: maxHeightFraction,
        body: bodyBuilder(sheetContext),
        bottomAction: bottomActionBuilder?.call(sheetContext),
      );
    },
  );
}

/// Shows a modal bottom sheet whose [builder] manages its own internal
/// scrolling and pinned bottom action (still applying the exact sheet chrome,
/// 90% height cap, handle, scrim, and 250ms decelerate motion).
Future<T?> showCustomAppSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  double maxHeightFraction = 0.9,
  bool isDismissible = true,
  bool enableDrag = true,
}) {
  final c = context.colors;
  final disableAnim = MediaQuery.disableAnimationsOf(context);

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    useSafeArea: true,
    backgroundColor: c.bgSurface,
    barrierColor: c.scrim,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppTokens.radiusSheetTop),
      ),
    ),
    sheetAnimationStyle: AnimationStyle(
      duration: disableAnim ? Duration.zero : AppTokens.sheetSlideDuration,
      reverseDuration: disableAnim ? Duration.zero : AppTokens.sheetSlideDuration,
      curve: Curves.decelerate,
    ),
    builder: (sheetContext) {
      final maxH = MediaQuery.sizeOf(sheetContext).height * maxHeightFraction;
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppTokens.space12),
            Center(
              child: Container(
                width: AppTokens.sheetHandleWidth,
                height: AppTokens.sheetHandleHeight,
                decoration: BoxDecoration(
                  color: c.bgSubtle,
                  borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                ),
              ),
            ),
            const SizedBox(height: AppTokens.space4),
            Flexible(child: builder(sheetContext)),
          ],
        ),
      );
    },
  );
}

class AppSheetContainer extends StatelessWidget {
  const AppSheetContainer({
    super.key,
    this.title,
    this.header,
    required this.body,
    this.bottomAction,
    this.maxHeightFraction = 0.9,
  });

  final String? title;
  final Widget? header;
  final Widget body;
  final Widget? bottomAction;
  final double maxHeightFraction;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final mq = MediaQuery.of(context);
    final maxH = mq.size.height * maxHeightFraction;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxH),
      child: Padding(
        padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppTokens.space12),
            Center(
              child: Container(
                width: AppTokens.sheetHandleWidth,
                height: AppTokens.sheetHandleHeight,
                decoration: BoxDecoration(
                  color: c.bgSubtle,
                  borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                ),
              ),
            ),
            if (header != null) ...[
              const SizedBox(height: AppTokens.space16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTokens.screenPadding),
                child: header!,
              ),
            ] else if (title != null && title!.isNotEmpty) ...[
              const SizedBox(height: AppTokens.space16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTokens.screenPadding),
                child: Text(
                  title!,
                  style: textTheme.titleLarge!.copyWith(color: c.textPrimary),
                ),
              ),
            ],
            const SizedBox(height: AppTokens.space16),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppTokens.screenPadding,
                  0,
                  AppTokens.screenPadding,
                  bottomAction == null ? 28 : AppTokens.space16,
                ),
                child: body,
              ),
            ),
            if (bottomAction != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTokens.screenPadding,
                  AppTokens.space8,
                  AppTokens.screenPadding,
                  28,
                ),
                child: bottomAction!,
              ),
          ],
        ),
      ),
    );
  }
}

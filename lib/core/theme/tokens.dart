/// Design system spatial, corner radius, sizing, and motion tokens.
/// Source of truth: `handover/02-design-system.md`.
abstract final class AppTokens {
  // Spacing scale
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double screenPadding = 20;

  // Radii
  static const double radiusSmall = 8;
  static const double radiusButtonSmall = 10;
  static const double radiusControl = 12;
  static const double radiusCard = 16;
  static const double radiusFab = 16;
  static const double radiusSheetTop = 28;
  static const double radiusFull = 999;

  // Component dimensions
  static const double minTouchTarget = 48;
  static const double buttonHeight = 48;
  static const double buttonSmallHeight = 36;
  static const double chipHeight = 32;
  static const double avatarSize = 40;
  static const double avatarLargeSize = 56;
  static const double fabSize = 56;
  static const double navBarHeight = 80;
  static const double navPillWidth = 56;
  static const double navPillHeight = 30;
  static const double fieldMinHeight = 48;
  static const double taskCircleSize = 22;
  static const double taskCircleStroke = 1.5;
  static const double eventCircleSize = 32;
  static const double eventIconSize = 16;
  static const double sheetHandleWidth = 36;
  static const double sheetHandleHeight = 4;

  // Motion
  static const Duration sheetSlideDuration = Duration(milliseconds: 250);
  static const Duration taskCompleteDelay = Duration(milliseconds: 600);
  static const Duration undoSnackBarDuration = Duration(seconds: 5);
}

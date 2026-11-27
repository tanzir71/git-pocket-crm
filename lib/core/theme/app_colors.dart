import 'package:material_ui/material_ui.dart';

/// Avatar background and ink pair.
@immutable
class AvatarTone {
  const AvatarTone({required this.bg, required this.ink});

  final Color bg;
  final Color ink;

  static AvatarTone lerp(AvatarTone a, AvatarTone b, double t) {
    return AvatarTone(
      bg: Color.lerp(a.bg, b.bg, t)!,
      ink: Color.lerp(a.ink, b.ink, t)!,
    );
  }
}

/// Complete colour token set from `handover/02-design-system.md`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.bgCanvas,
    required this.bgSurface,
    required this.bgSubtle,
    required this.bgInverse,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textOnAccent,
    required this.textOnInverse,
    required this.borderHairline,
    required this.borderStrong,
    required this.accentDefault,
    required this.accentSoft,
    required this.statusSuccess,
    required this.statusWarning,
    required this.statusDanger,
    required this.statusSuccessSoft,
    required this.statusWarningSoft,
    required this.statusDangerSoft,
    required this.scrim,
    required this.fabShadow,
    required this.avatarTones,
  });

  final Color bgCanvas;
  final Color bgSurface;
  final Color bgSubtle;
  final Color bgInverse;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textOnAccent;
  final Color textOnInverse;
  final Color borderHairline;
  final Color borderStrong;
  final Color accentDefault;
  final Color accentSoft;
  final Color statusSuccess;
  final Color statusWarning;
  final Color statusDanger;
  final Color statusSuccessSoft;
  final Color statusWarningSoft;
  final Color statusDangerSoft;
  final Color scrim;
  final Color fabShadow;
  final List<AvatarTone> avatarTones;

  AvatarTone avatarTone(int id) => avatarTones[id.abs() % avatarTones.length];

  static const light = AppColors(
    bgCanvas: Color(0xFFF7F7F5),
    bgSurface: Color(0xFFFFFFFF),
    bgSubtle: Color(0xFFEFEFEC),
    bgInverse: Color(0xFF17171A),
    textPrimary: Color(0xFF17171A),
    textSecondary: Color(0xFF4A4A54),
    textTertiary: Color(0xFF6B6B76),
    textOnAccent: Color(0xFFFFFFFF),
    textOnInverse: Color(0xFFFFFFFF),
    borderHairline: Color(0xFFE7E7E3),
    borderStrong: Color(0xFFCFCFCA),
    accentDefault: Color(0xFF3525CD),
    accentSoft: Color(0xFFEEEDFB),
    statusSuccess: Color(0xFF177A4C),
    statusWarning: Color(0xFF9A5B00),
    statusDanger: Color(0xFFC8372D),
    statusSuccessSoft: Color(0xFFE6F4EC),
    statusWarningSoft: Color(0xFFFBF0DC),
    statusDangerSoft: Color(0xFFFBEAE8),
    scrim: Color(0x73000000), // black 45%
    fabShadow: Color(0x2E000000), // black 18%
    avatarTones: [
      AvatarTone(bg: Color(0xFFEFE7DA), ink: Color(0xFF6B5A3C)), // sand
      AvatarTone(bg: Color(0xFFE1ECE4), ink: Color(0xFF3F6350)), // sage
      AvatarTone(bg: Color(0xFFE0EAF4), ink: Color(0xFF3C5A7A)), // sky
      AvatarTone(bg: Color(0xFFF4E3E3), ink: Color(0xFF84494B)), // rose
      AvatarTone(bg: Color(0xFFE8E4F6), ink: Color(0xFF55488F)), // lilac
    ],
  );

  static const dark = AppColors(
    bgCanvas: Color(0xFF0F0F11),
    bgSurface: Color(0xFF18181B),
    bgSubtle: Color(0xFF232327),
    bgInverse: Color(0xFFF4F4F2),
    textPrimary: Color(0xFFF4F4F2),
    textSecondary: Color(0xFFA9A9B2),
    textTertiary: Color(0xFF8A8A95),
    textOnAccent: Color(0xFF121018),
    textOnInverse: Color(0xFF17171A),
    borderHairline: Color(0xFF2A2A2F),
    borderStrong: Color(0xFF3A3A41),
    accentDefault: Color(0xFF8F84FF),
    accentSoft: Color(0xFF25224A),
    statusSuccess: Color(0xFF5CC592),
    statusWarning: Color(0xFFE2A93B),
    statusDanger: Color(0xFFF0786E),
    statusSuccessSoft: Color(0xFF15301F),
    statusWarningSoft: Color(0xFF33270E),
    statusDangerSoft: Color(0xFF3A1A17),
    scrim: Color(0x73000000), // black 45%
    fabShadow: Color(0x2E000000), // black 18%
    avatarTones: [
      AvatarTone(bg: Color(0xFF3A3226), ink: Color(0xFFE0CFAE)), // sand
      AvatarTone(bg: Color(0xFF24332A), ink: Color(0xFFB4D3C0)), // sage
      AvatarTone(bg: Color(0xFF22303F), ink: Color(0xFFB3CCE6)), // sky
      AvatarTone(bg: Color(0xFF3D2728), ink: Color(0xFFE6BDBE)), // rose
      AvatarTone(bg: Color(0xFF2C2843), ink: Color(0xFFC9C1EE)), // lilac
    ],
  );

  @override
  AppColors copyWith({
    Color? bgCanvas,
    Color? bgSurface,
    Color? bgSubtle,
    Color? bgInverse,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textOnAccent,
    Color? textOnInverse,
    Color? borderHairline,
    Color? borderStrong,
    Color? accentDefault,
    Color? accentSoft,
    Color? statusSuccess,
    Color? statusWarning,
    Color? statusDanger,
    Color? statusSuccessSoft,
    Color? statusWarningSoft,
    Color? statusDangerSoft,
    Color? scrim,
    Color? fabShadow,
    List<AvatarTone>? avatarTones,
  }) {
    return AppColors(
      bgCanvas: bgCanvas ?? this.bgCanvas,
      bgSurface: bgSurface ?? this.bgSurface,
      bgSubtle: bgSubtle ?? this.bgSubtle,
      bgInverse: bgInverse ?? this.bgInverse,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textOnAccent: textOnAccent ?? this.textOnAccent,
      textOnInverse: textOnInverse ?? this.textOnInverse,
      borderHairline: borderHairline ?? this.borderHairline,
      borderStrong: borderStrong ?? this.borderStrong,
      accentDefault: accentDefault ?? this.accentDefault,
      accentSoft: accentSoft ?? this.accentSoft,
      statusSuccess: statusSuccess ?? this.statusSuccess,
      statusWarning: statusWarning ?? this.statusWarning,
      statusDanger: statusDanger ?? this.statusDanger,
      statusSuccessSoft: statusSuccessSoft ?? this.statusSuccessSoft,
      statusWarningSoft: statusWarningSoft ?? this.statusWarningSoft,
      statusDangerSoft: statusDangerSoft ?? this.statusDangerSoft,
      scrim: scrim ?? this.scrim,
      fabShadow: fabShadow ?? this.fabShadow,
      avatarTones: avatarTones ?? this.avatarTones,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      bgCanvas: Color.lerp(bgCanvas, other.bgCanvas, t)!,
      bgSurface: Color.lerp(bgSurface, other.bgSurface, t)!,
      bgSubtle: Color.lerp(bgSubtle, other.bgSubtle, t)!,
      bgInverse: Color.lerp(bgInverse, other.bgInverse, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textOnAccent: Color.lerp(textOnAccent, other.textOnAccent, t)!,
      textOnInverse: Color.lerp(textOnInverse, other.textOnInverse, t)!,
      borderHairline: Color.lerp(borderHairline, other.borderHairline, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      accentDefault: Color.lerp(accentDefault, other.accentDefault, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      statusSuccess: Color.lerp(statusSuccess, other.statusSuccess, t)!,
      statusWarning: Color.lerp(statusWarning, other.statusWarning, t)!,
      statusDanger: Color.lerp(statusDanger, other.statusDanger, t)!,
      statusSuccessSoft: Color.lerp(statusSuccessSoft, other.statusSuccessSoft, t)!,
      statusWarningSoft: Color.lerp(statusWarningSoft, other.statusWarningSoft, t)!,
      statusDangerSoft: Color.lerp(statusDangerSoft, other.statusDangerSoft, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      fabShadow: Color.lerp(fabShadow, other.fabShadow, t)!,
      avatarTones: List.generate(
        avatarTones.length,
        (i) => AvatarTone.lerp(avatarTones[i], other.avatarTones[i], t),
      ),
    );
  }
}

extension AppColorsBuildContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>() ?? AppColors.light;
}

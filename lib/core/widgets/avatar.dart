import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';

class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.name,
    required this.toneIndex,
    this.size = AppTokens.avatarSize,
    this.semanticLabel,
  });

  final String name;
  final int toneIndex;
  final double size;
  final String? semanticLabel;

  static String initialsFor(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final first = parts.first;
      return first.substring(0, first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final tone = context.colors.avatarTone(toneIndex);
    final labelStyle = Theme.of(context).textTheme.labelMedium!;
    final isLarge = size >= AppTokens.avatarLargeSize;

    return Semantics(
      label: semanticLabel ?? name,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: tone.bg,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          initialsFor(name),
          style: isLarge
              ? Theme.of(context).textTheme.titleMedium!.copyWith(color: tone.ink)
              : labelStyle.copyWith(color: tone.ink),
          maxLines: 1,
        ),
      ),
    );
  }
}

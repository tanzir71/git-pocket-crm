import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';

class AppFab extends StatelessWidget {
  const AppFab({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Semantics(
      button: true,
      label: semanticLabel,
      child: Container(
        width: AppTokens.fabSize,
        height: AppTokens.fabSize,
        decoration: BoxDecoration(
          color: c.accentDefault,
          borderRadius: BorderRadius.circular(AppTokens.radiusFab),
          boxShadow: [
            BoxShadow(
              color: c.fabShadow,
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppTokens.radiusFab),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppTokens.radiusFab),
            child: Center(
              child: Icon(icon, size: 24, color: c.textOnAccent),
            ),
          ),
        ),
      ),
    );
  }
}

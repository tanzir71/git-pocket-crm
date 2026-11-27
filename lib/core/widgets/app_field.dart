import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';

class AppField extends StatelessWidget {
  const AppField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.focusNode,
    this.minLines = 1,
    this.maxLines = 1,
    this.leadingIcon,
    this.trailingIcon,
    this.trailingSemanticLabel,
    this.onTrailingTap,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.autofocus = false,
    this.readOnly = false,
    this.obscureText = false,
    this.bordered = false,
    this.prefixText,
  });

  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final int minLines;
  final int maxLines;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final String? trailingSemanticLabel;
  final VoidCallback? onTrailingTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool autofocus;
  final bool readOnly;
  final bool obscureText;
  final bool bordered;
  final String? prefixText;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textTheme = Theme.of(context).textTheme;

    final border = bordered
        ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusControl),
            borderSide: BorderSide(color: c.borderHairline, width: 1),
          )
        : OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusControl),
            borderSide: BorderSide.none,
          );

    final field = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppTokens.fieldMinHeight),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        minLines: minLines,
        maxLines: obscureText ? 1 : maxLines,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        autofocus: autofocus,
        readOnly: readOnly,
        obscureText: obscureText,
        style: textTheme.bodyMedium!.copyWith(color: c.textPrimary),
        decoration: InputDecoration(
          filled: true,
          fillColor: bordered ? c.bgSurface : c.bgSubtle,
          hintText: hintText,
          hintStyle: textTheme.bodyMedium!.copyWith(color: c.textTertiary),
          prefixText: prefixText,
          prefixStyle: textTheme.bodyMedium!.copyWith(color: c.textSecondary),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          border: border,
          enabledBorder: border,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusControl),
            borderSide: BorderSide(color: c.borderStrong, width: 1),
          ),
          prefixIcon: leadingIcon == null
              ? null
              : Icon(leadingIcon, size: 20, color: c.textTertiary),
          suffixIcon: trailingIcon == null
              ? null
              : Semantics(
                  button: true,
                  label: trailingSemanticLabel ?? '',
                  child: IconButton(
                    icon: Icon(trailingIcon, size: 20, color: c.textSecondary),
                    onPressed: onTrailingTap,
                    constraints: const BoxConstraints(
                      minWidth: AppTokens.minTouchTarget,
                      minHeight: AppTokens.minTouchTarget,
                    ),
                  ),
                ),
        ),
      ),
    );

    if (label == null || label!.isEmpty) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label!,
          style: textTheme.labelMedium!.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: AppTokens.space8),
        field,
      ],
    );
  }
}

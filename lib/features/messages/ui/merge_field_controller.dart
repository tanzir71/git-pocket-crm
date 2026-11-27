import 'package:material_ui/material_ui.dart';

import '../../../core/messages/template_renderer.dart';
import '../../../core/theme/app_colors.dart';

/// [TextEditingController] that styles known `{merge field}` tokens in
/// `accent/default` and unknown `{...}` tokens in `status/danger`, matching
/// Figma frame `10:498`.
class MergeFieldTextController extends TextEditingController {
  MergeFieldTextController({super.text});

  static final RegExp _tokenRegex = RegExp(r'\{[^{}]+\}');

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final c = context.colors;
    final src = text;
    if (src.isEmpty) {
      return TextSpan(style: style, text: '');
    }

    final spans = <InlineSpan>[];
    var cursor = 0;

    for (final match in _tokenRegex.allMatches(src)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: src.substring(cursor, match.start), style: style));
      }
      final token = match.group(0)!;
      final inner = token.substring(1, token.length - 1);
      final bar = inner.indexOf('|');
      final canonical = (bar >= 0 ? inner.substring(0, bar) : inner).trim().toLowerCase();
      final isKnown = kKnownMergeFields.contains(canonical);

      spans.add(
        TextSpan(
          text: token,
          style: (style ?? const TextStyle()).copyWith(
            color: isKnown ? c.accentDefault : c.statusDanger,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
      cursor = match.end;
    }

    if (cursor < src.length) {
      spans.add(TextSpan(text: src.substring(cursor), style: style));
    }

    return TextSpan(style: style, children: spans);
  }

  /// Inserts `{field}` at the current cursor position (or at the end).
  void insertMergeField(String fieldName) {
    final token = '{$fieldName}';
    final sel = selection;
    final current = text;
    if (!sel.isValid || sel.start < 0 || sel.end < 0) {
      final needsSpace = current.isNotEmpty && !current.endsWith(' ');
      final next = needsSpace ? '$current $token' : '$current$token';
      value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: next.length),
      );
      return;
    }
    final before = current.substring(0, sel.start);
    final after = current.substring(sel.end);
    final next = '$before$token$after';
    value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: before.length + token.length),
    );
  }
}

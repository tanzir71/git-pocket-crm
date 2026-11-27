import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lint guard: all of lib/ obeys design token rules', () {
    final root = Directory('lib');

    final forbidden = <(String name, RegExp pattern)>[
      ('hardcoded Color(0x...)', RegExp(r'Color\(\s*0x')),
      (
        'Colors.* other than Colors.transparent',
        RegExp(r'\bColors\.(?!transparent\b)[a-zA-Z0-9_]+'),
      ),
      ('FontStyle.italic', RegExp(r'\bFontStyle\.italic\b')),
      ('GoogleFonts.*', RegExp(r'\bGoogleFonts\.')),
      ('deprecated withOpacity(', RegExp(r'\.withOpacity\(')),
    ];

    final violations = <String>[];

    for (final entity in root.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final norm = entity.path.replaceAll('\\', '/');
      // Theme token definitions own the palette hex constants; generated files are excluded.
      if (norm.startsWith('lib/core/theme/')) continue;
      if (norm.endsWith('.g.dart')) continue;
      if (norm.startsWith('lib/l10n/')) continue;

      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        for (final (name, pattern) in forbidden) {
          if (pattern.hasMatch(line)) {
            violations.add('${entity.path}:${i + 1}: $name -> ${line.trim()}');
          }
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Design system lint guard violations found:\n${violations.join('\n')}',
    );
  });

  test('lint guard: no file in lib/features contains SQL', () {
    final dir = Directory('lib/features');
    if (!dir.existsSync()) return;

    final sqlPatterns = <(String name, RegExp pattern)>[
      ('customSelect/customStatement/customUpdate', RegExp(r'\bcustom(Select|Statement|Update)\b')),
      (
        'raw SQL statement',
        RegExp(r'\b(SELECT\s+.+\s+FROM|INSERT\s+INTO|UPDATE\s+\w+\s+SET|DELETE\s+FROM)\b'),
      ),
    ];

    final violations = <String>[];
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        for (final (name, pattern) in sqlPatterns) {
          if (pattern.hasMatch(line)) {
            violations.add('${entity.path}:${i + 1}: $name -> ${line.trim()}');
          }
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'SQL found in lib/features:\n${violations.join('\n')}',
    );
  });

  test('cut-over guard: no file in lib/ references legacy', () {
    final root = Directory('lib');
    final hits = <String>[];
    for (final entity in root.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].contains('legacy')) {
          hits.add('${entity.path}:${i + 1}: ${lines[i].trim()}');
        }
      }
    }
    expect(
      hits,
      isEmpty,
      reason: 'References to "legacy" remain in lib/:\n${hits.join('\n')}',
    );
  });
}

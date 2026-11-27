import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pocket_crm/core/theme/app_colors.dart';
import 'package:pocket_crm/core/theme/app_theme.dart';
import 'package:pocket_crm/core/theme/tokens.dart';
import 'package:pocket_crm/core/widgets/widgets.dart';

Widget _wrap(Widget child, {ThemeData? theme, double textScale = 1.0}) {
  return MaterialApp(
    theme: theme ?? AppTheme.light,
    home: MediaQuery(
      data: MediaQueryData(
        size: const Size(412, 917),
        textScaler: TextScaler.linear(textScale),
      ),
      child: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  group('Design system token & component measurements', () {
    testWidgets('AppButton primary regular & small match spec measurements', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(label: 'Save', fullWidth: true, onPressed: () {}),
              AppButton(
                label: 'Add note',
                size: AppButtonSize.small,
                onPressed: () {},
              ),
              AppButton(
                label: 'Follow up',
                variant: AppButtonVariant.secondary,
                size: AppButtonSize.small,
                onPressed: () {},
              ),
            ],
          ),
        ),
      );

      // Primary regular button: height 48, radius 12, accentDefault fill, min touch target 48
      final primaryInk = tester.widget<Ink>(find.byType(Ink).first);
      expect(primaryInk.height, 48);
      final primaryDec = primaryInk.decoration! as BoxDecoration;
      expect(primaryDec.color, AppColors.light.accentDefault);
      expect(primaryDec.borderRadius, BorderRadius.circular(12));
      expect(tester.getSize(find.byType(AppButton).first).height, greaterThanOrEqualTo(48));

      // Small button: visible height 36, radius 10, touch target >= 48
      final smallInk = tester.widget<Ink>(find.byType(Ink).at(1));
      expect(smallInk.height, 36);
      final smallDec = smallInk.decoration! as BoxDecoration;
      expect(smallDec.borderRadius, BorderRadius.circular(10));
      expect(tester.getSize(find.byType(AppButton).at(1)).height, greaterThanOrEqualTo(48));

      // Secondary small: bgSubtle fill
      final secInk = tester.widget<Ink>(find.byType(Ink).at(2));
      expect((secInk.decoration! as BoxDecoration).color, AppColors.light.bgSubtle);
    });

    testWidgets('AppChip default and selected match spec measurements', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppChip(label: 'Customers', onTap: () {}),
              AppChip(label: 'All', selected: true, onTap: () {}),
            ],
          ),
        ),
      );

      final containers = tester.widgetList<Container>(find.byType(Container)).toList();
      // Default chip: height 32, bgSurface, 1px borderHairline, pill radius
      final defDec = containers[0].decoration! as BoxDecoration;
      expect(containers[0].constraints?.minHeight, 32);
      expect(defDec.color, AppColors.light.bgSurface);
      expect(defDec.border, Border.all(color: AppColors.light.borderHairline, width: 1));
      expect(defDec.borderRadius, BorderRadius.circular(AppTokens.radiusFull));

      // Selected chip: bgInverse, no border, touch target >= 48
      final selDec = containers[1].decoration! as BoxDecoration;
      expect(selDec.color, AppColors.light.bgInverse);
      expect(selDec.border, isNull);
      expect(tester.getSize(find.byType(AppChip).first).height, greaterThanOrEqualTo(48));
    });

    testWidgets('Avatar sizes, initials, and deterministic tone match spec', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Avatar(name: 'Amara Okafor', toneIndex: 0),
              Avatar(name: 'Sofia Marin', toneIndex: 6, size: AppTokens.avatarLargeSize),
            ],
          ),
        ),
      );

      expect(find.text('AO'), findsOneWidget);
      expect(find.text('SM'), findsOneWidget);
      expect(tester.getSize(find.byType(Avatar).first), const Size(40, 40));
      expect(tester.getSize(find.byType(Avatar).last), const Size(56, 56));

      final firstContainer = tester.widget<Container>(find.byType(Container).first);
      final dec = firstContainer.decoration! as BoxDecoration;
      expect(dec.shape, BoxShape.circle);
      expect(dec.color, AppColors.light.avatarTone(0).bg);
    });

    testWidgets('AppFab, PromptCard, and rows match measurements and do not overflow at 1.3x',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          ListView(
            children: [
              const SectionHeader(title: 'Follow-ups', count: 3),
              PromptCard(
                avatarName: 'Amara Okafor',
                toneIndex: 0,
                title: 'You spoke with Amara Okafor',
                subtitle: 'Outgoing call · 4 min · 10:12',
                actions: [
                  AppButton(label: 'Add note', size: AppButtonSize.small, onPressed: () {}),
                  AppButton(
                    label: 'Follow up',
                    variant: AppButtonVariant.secondary,
                    size: AppButtonSize.small,
                    onPressed: () {},
                  ),
                ],
              ),
              PersonRow(
                name: 'Very Long Contact Display Name That Truncates Properly',
                toneIndex: 2,
                meta: 'Every month · last spoke 6 weeks ago in showroom',
                trailing: '6w',
                onTap: () {},
              ),
              TaskRow(
                title: 'Send revised pricing quote for bulk order before Friday afternoon',
                meta: 'Daniel Reyes · overdue by 1 day',
                isOverdue: true,
                onToggle: () {},
                onTap: () {},
              ),
              EventRow(
                icon: Icons.call_outlined,
                title: 'Outgoing call · 4 min',
                body: 'Wants 40 units by mid-December. Asked for revised pricing.',
                timeLine: 'Today 10:12',
                onTap: () {},
              ),
              SettingRow(label: 'Send window', value: '09:00 to 21:00', onTap: () {}),
              Center(
                child: AppFab(icon: Icons.add, semanticLabel: 'Add', onPressed: () {}),
              ),
            ],
          ),
          textScale: 1.3,
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Follow-ups · 3'), findsOneWidget);
      expect(tester.getSize(find.byType(AppFab)), const Size(56, 56));
      expect(tester.getSize(find.byType(PersonRow)).height, greaterThanOrEqualTo(48));
      expect(tester.getSize(find.byType(TaskRow)).height, greaterThanOrEqualTo(48));
      expect(tester.getSize(find.byType(SettingRow)).height, greaterThanOrEqualTo(48));
    });

    test('ThemeData uses explicit ColorScheme and Inter font with zero italics', () {
      for (final theme in [AppTheme.light, AppTheme.dark]) {
        final tt = theme.textTheme;
        final styles = [
          tt.headlineMedium!,
          tt.titleLarge!,
          tt.titleMedium!,
          tt.labelLarge!,
          tt.bodyLarge!,
          tt.bodyMedium!,
          tt.labelMedium!,
          tt.bodySmall!,
        ];
        for (final s in styles) {
          expect(s.fontFamily, 'Inter');
          expect(s.fontStyle, isNot(FontStyle.italic));
        }
        expect(tt.headlineMedium!.fontSize, 28);
        expect(tt.titleLarge!.fontSize, 20);
        expect(tt.titleMedium!.fontSize, 16);
        expect(tt.bodyMedium!.fontSize, 15);
        expect(tt.labelMedium!.fontSize, 13);
        expect(tt.bodySmall!.fontSize, 12);
      }
    });
  });
}

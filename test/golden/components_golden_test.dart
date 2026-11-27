import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pocket_crm/core/theme/app_colors.dart';
import 'package:pocket_crm/core/theme/app_theme.dart';
import 'package:pocket_crm/core/theme/tokens.dart';
import 'package:pocket_crm/core/widgets/widgets.dart';

Future<void> _loadBundledInter() async {
  final loader = FontLoader('Inter');
  for (final file in const [
    'assets/fonts/Inter-Regular.ttf',
    'assets/fonts/Inter-Medium.ttf',
    'assets/fonts/Inter-SemiBold.ttf',
  ]) {
    final bytes = await File(file).readAsBytes();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

Widget _buildShowcase({
  required ThemeData theme,
  required double textScale,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: theme,
    home: MediaQuery(
      data: MediaQueryData(
        size: const Size(412, 1350),
        textScaler: TextScaler.linear(textScale),
      ),
      child: Builder(
        builder: (context) {
          final c = context.colors;
          return Scaffold(
            backgroundColor: c.bgCanvas,
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Buttons & chips'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTokens.screenPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppButton(label: 'Save note', fullWidth: true, onPressed: () {}),
                        const SizedBox(height: AppTokens.space8),
                        Wrap(
                          spacing: AppTokens.space8,
                          children: [
                            AppButton(
                              label: 'Secondary',
                              variant: AppButtonVariant.secondary,
                              size: AppButtonSize.small,
                              onPressed: () {},
                            ),
                            AppButton(
                              label: 'Skip',
                              variant: AppButtonVariant.quiet,
                              size: AppButtonSize.small,
                              onPressed: () {},
                            ),
                            AppChip(label: 'All', selected: true, onTap: () {}),
                            AppChip(label: 'Customers', onTap: () {}),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SectionHeader(title: 'Prompt'),
                  PromptCard(
                    avatarName: 'Amara Okafor',
                    toneIndex: 0,
                    title: 'You spoke with Amara Okafor',
                    subtitle: 'Outgoing call · 4 min · 10:12',
                    actions: [
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
                      AppButton(
                        label: 'Skip',
                        variant: AppButtonVariant.quiet,
                        size: AppButtonSize.small,
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SectionHeader(title: 'Follow-ups', count: 2),
                  TaskRow(
                    title: 'Send revised quote',
                    meta: 'Daniel Reyes · overdue by 1 day',
                    isOverdue: true,
                    onToggle: () {},
                    onTap: () {},
                  ),
                  TaskRow(
                    title: 'Call back about delivery',
                    meta: 'Tanvir Hasan · today 17:30',
                    completed: true,
                    onToggle: () {},
                    onTap: () {},
                  ),
                  const SectionHeader(title: 'Reconnect', count: 2),
                  PersonRow(
                    name: 'Sofia Marin',
                    toneIndex: 1,
                    meta: 'Every month · last spoke 6 weeks ago',
                    trailing: '6w',
                    onTap: () {},
                  ),
                  PersonRow(
                    name: 'Kenji Watanabe',
                    toneIndex: 2,
                    meta: 'Every 3 months · last spoke 4 months ago',
                    trailing: '4mo',
                    onTap: () {},
                  ),
                  const SectionHeader(title: 'History'),
                  EventRow(
                    icon: Icons.call_outlined,
                    title: 'Outgoing call · 4 min',
                    body: 'Wants 40 units by mid-December. Asked for revised pricing.',
                    timeLine: 'Today 10:12',
                    onTap: () {},
                  ),
                  EventRow(
                    icon: Icons.error_outline,
                    title: 'Not sent to Daniel Reyes',
                    body: 'No service.',
                    timeLine: 'Today 09:40',
                    isError: true,
                    trailing: AppButton(
                      label: 'Retry',
                      variant: AppButtonVariant.secondary,
                      size: AppButtonSize.small,
                      onPressed: () {},
                    ),
                  ),
                  SettingRow(label: 'Send window', value: '09:00 to 21:00', onTap: () {}),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTokens.screenPadding,
                      vertical: AppTokens.space12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppField(
                          label: 'Note',
                          hintText: 'Add a note',
                          trailingIcon: Icons.mic_none,
                          trailingSemanticLabel: 'Voice input',
                        ),
                        SizedBox(height: AppTokens.space12),
                        Wrap(
                          spacing: AppTokens.space12,
                          children: [
                            StatusText(status: MessageDeliveryStatus.queued),
                            StatusText(status: MessageDeliveryStatus.sending),
                            StatusText(status: MessageDeliveryStatus.sent),
                            StatusText(status: MessageDeliveryStatus.delivered),
                            StatusText(status: MessageDeliveryStatus.failed),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const EmptyState(
                    title: 'All caught up',
                    message: 'Follow-ups and people to reconnect with will appear here.',
                  ),
                ],
              ),
            ),
            floatingActionButton: AppFab(
              icon: Icons.add,
              semanticLabel: 'Add',
              onPressed: () {},
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: c.borderHairline, width: 1)),
              ),
              child: NavigationBar(
                selectedIndex: 0,
                onDestinationSelected: (_) {},
                destinations: const [
                  NavigationDestination(icon: Icon(Icons.wb_sunny_outlined), label: 'Today'),
                  NavigationDestination(icon: Icon(Icons.people_outline), label: 'People'),
                  NavigationDestination(icon: Icon(Icons.send_outlined), label: 'Messages'),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await _loadBundledInter();
  });

  final variants = <(String name, ThemeData theme, double scale)>[
    ('components_light_1_0', AppTheme.light, 1.0),
    ('components_light_1_3', AppTheme.light, 1.3),
    ('components_dark_1_0', AppTheme.dark, 1.0),
    ('components_dark_1_3', AppTheme.dark, 1.3),
  ];

  for (final (name, theme, scale) in variants) {
    testWidgets('golden: $name', (tester) async {
      tester.view.physicalSize = const Size(412, 1350);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildShowcase(theme: theme, textScale: scale));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/$name.png'),
      );
    });
  }
}

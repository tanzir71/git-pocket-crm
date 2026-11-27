import 'package:material_ui/material_ui.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/tokens.dart';
import '../core/widgets/widgets.dart';

/// Debug-only gallery showing every design system component in Light and Dark mode.
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  bool _dark = false;
  bool _taskCompleted = false;
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _dark ? AppTheme.dark : AppTheme.light,
      child: Builder(
        builder: (ctx) {
          final c = ctx.colors;
          final tt = Theme.of(ctx).textTheme;
          return Scaffold(
            backgroundColor: c.bgCanvas,
            appBar: AppBar(
              title: const Text('Design system gallery'),
              actions: [
                AppChip(
                  label: _dark ? 'Dark' : 'Light',
                  selected: _dark,
                  onTap: () => setState(() => _dark = !_dark),
                ),
                const SizedBox(width: AppTokens.space12),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.only(bottom: 96),
              children: [
                const SectionHeader(title: 'Typography'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTokens.screenPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Display 28/34', style: tt.headlineMedium),
                      Text('Title 20/26', style: tt.titleLarge),
                      Text('Headline 16/22', style: tt.titleMedium),
                      Text('Body Strong 15/22', style: tt.labelLarge),
                      Text('Body 15/22', style: tt.bodyMedium),
                      Text('Label 13/18', style: tt.labelMedium),
                      Text('Caption 12/16', style: tt.bodySmall),
                    ],
                  ),
                ),
                const SectionHeader(title: 'Buttons'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTokens.screenPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppButton(label: 'Primary full width', fullWidth: true, onPressed: () {}),
                      const SizedBox(height: AppTokens.space8),
                      Wrap(
                        spacing: AppTokens.space8,
                        children: [
                          AppButton(
                            label: 'Secondary',
                            variant: AppButtonVariant.secondary,
                            onPressed: () {},
                          ),
                          AppButton(
                            label: 'Quiet',
                            variant: AppButtonVariant.quiet,
                            onPressed: () {},
                          ),
                          AppButton(
                            label: 'Small primary',
                            size: AppButtonSize.small,
                            onPressed: () {},
                          ),
                          AppButton(
                            label: 'Small secondary',
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
                    ],
                  ),
                ),
                const SectionHeader(title: 'Chips & Avatars'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTokens.screenPadding),
                  child: Wrap(
                    spacing: AppTokens.space8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      AppChip(label: 'All', selected: true, onTap: () {}),
                      AppChip(label: 'Starred', leadingIcon: Icons.star_border, onTap: () {}),
                      AppChip(label: 'Customers', onTap: () {}),
                      const Avatar(name: 'Amara Okafor', toneIndex: 0),
                      const Avatar(name: 'Sofia Marin', toneIndex: 1),
                      const Avatar(name: 'Kenji Watanabe', toneIndex: 2),
                      const Avatar(name: 'Priya Nair', toneIndex: 3),
                      const Avatar(name: 'Daniel Reyes', toneIndex: 4),
                    ],
                  ),
                ),
                const SectionHeader(title: 'Prompt card'),
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
                const SectionHeader(title: 'Rows', count: 4),
                PersonRow(
                  name: 'Sofia Marin',
                  toneIndex: 1,
                  meta: 'Every month · last spoke 6 weeks ago',
                  trailing: '6w',
                  onTap: () {},
                ),
                TaskRow(
                  title: 'Send revised quote',
                  meta: 'Daniel Reyes · overdue by 1 day',
                  completed: _taskCompleted,
                  isOverdue: true,
                  onToggle: () => setState(() => _taskCompleted = !_taskCompleted),
                  onTap: () {},
                ),
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
                SettingRow(
                  label: 'Send window',
                  value: '09:00 to 21:00',
                  onTap: () {},
                ),
                const SectionHeader(title: 'Fields & Status'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTokens.screenPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppField(
                        label: 'Note',
                        hintText: 'What was discussed?',
                        minLines: 3,
                        maxLines: 6,
                        trailingIcon: Icons.mic_none,
                        trailingSemanticLabel: 'Dictate note',
                      ),
                      const SizedBox(height: AppTokens.space12),
                      const Wrap(
                        spacing: AppTokens.space12,
                        children: [
                          StatusText(status: MessageDeliveryStatus.queued),
                          StatusText(status: MessageDeliveryStatus.sending),
                          StatusText(status: MessageDeliveryStatus.sent),
                          StatusText(status: MessageDeliveryStatus.delivered),
                          StatusText(status: MessageDeliveryStatus.failed),
                          StatusText(status: MessageDeliveryStatus.skipped),
                        ],
                      ),
                      const SizedBox(height: AppTokens.space12),
                      AppButton(
                        label: 'Open sample sheet',
                        variant: AppButtonVariant.secondary,
                        onPressed: () => showAppSheet<void>(
                          context: ctx,
                          title: 'Sample sheet',
                          bodyBuilder: (_) => const AppField(hintText: 'Type something'),
                          bottomActionBuilder: (sheetCtx) => AppButton(
                            label: 'Done',
                            fullWidth: true,
                            onPressed: () => Navigator.of(sheetCtx).pop(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                EmptyState(
                  title: 'All caught up',
                  message: 'Follow-ups and people to reconnect with will appear here.',
                  actionLabel: 'Choose people to stay in touch with',
                  onAction: () {},
                ),
              ],
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
                selectedIndex: _navIndex,
                onDestinationSelected: (i) => setState(() => _navIndex = i),
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.wb_sunny_outlined),
                    label: 'Today',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.people_outline),
                    label: 'People',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.send_outlined),
                    label: 'Messages',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

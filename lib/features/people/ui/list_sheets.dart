import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/db/app_database.dart';
import '../../../core/l10n_ext.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';
import 'cadence_picker_sheet.dart';

/// Shows a sheet to create a new list (when [existing] is null) or rename one.
Future<int?> showCreateOrRenameListSheet(
  BuildContext context,
  WidgetRef ref, {
  ContactList? existing,
}) {
  final controller = TextEditingController(text: existing?.name ?? '');
  return showAppSheet<int>(
    context: context,
    bodyBuilder: (ctx) {
      final l10n = ctx.l10n;
      final c = ctx.colors;
      final tt = Theme.of(ctx).textTheme;
      return StatefulBuilder(
        builder: (ctx, setState) {
          final canSave = controller.text.trim().isNotEmpty;
          return Padding(
            padding: EdgeInsets.fromLTRB(
              AppTokens.screenPadding,
              AppTokens.space8,
              AppTokens.screenPadding,
              MediaQuery.viewInsetsOf(ctx).bottom + AppTokens.space16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  existing == null ? l10n.createListTitle : l10n.renameListTitle,
                  style: tt.titleMedium!.copyWith(color: c.textPrimary),
                ),
                const SizedBox(height: AppTokens.space12),
                AppField(
                  label: l10n.listNameLabel,
                  controller: controller,
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: AppTokens.space16),
                AppButton(
                  label: l10n.saveAction,
                  variant: AppButtonVariant.primary,
                  fullWidth: true,
                  onPressed: canSave
                      ? () async {
                          final repo = ref.read(listsRepositoryProvider);
                          final name = controller.text.trim();
                          if (existing == null) {
                            final id = await repo.createList(name);
                            if (ctx.mounted) Navigator.of(ctx).pop(id);
                          } else {
                            await repo.renameList(existing.id, name);
                            if (ctx.mounted) Navigator.of(ctx).pop(existing.id);
                          }
                        }
                      : null,
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

/// Long-press menu for a list chip on People.
Future<void> showListActionsSheet(
  BuildContext context,
  WidgetRef ref, {
  required ContactList list,
  VoidCallback? onDeleted,
  VoidCallback? onMessageList,
}) {
  return showAppSheet<void>(
    context: context,
    bodyBuilder: (ctx) {
      final l10n = ctx.l10n;
      final c = ctx.colors;
      final tt = Theme.of(ctx).textTheme;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.screenPadding,
              AppTokens.space8,
              AppTokens.screenPadding,
              AppTokens.space8,
            ),
            child: Text(
              list.name,
              style: tt.titleMedium!.copyWith(color: c.textPrimary),
            ),
          ),
          _SheetActionTile(
            label: l10n.listRename,
            icon: Icons.edit_outlined,
            onTap: () async {
              Navigator.of(ctx).pop();
              await showCreateOrRenameListSheet(context, ref, existing: list);
            },
          ),
          _SheetActionTile(
            label: l10n.listSetReconnect,
            icon: Icons.schedule_outlined,
            onTap: () async {
              Navigator.of(ctx).pop();
              final repo = ref.read(listsRepositoryProvider);
              final count = await repo.countMembersWithoutOwnCadence(list.id);
              if (!context.mounted) return;
              final picked = await showCadencePickerSheet(
                context,
                currentDays: list.cadenceDays,
                listName: list.name,
                affectedListMembersCount: count,
              );
              if (picked != null) {
                await repo.setCadence(list.id, picked.days);
              }
            },
          ),
          _SheetActionTile(
            label: l10n.listMessage,
            icon: Icons.send_outlined,
            enabled: onMessageList != null,
            onTap: onMessageList == null
                ? null
                : () {
                    Navigator.of(ctx).pop();
                    onMessageList();
                  },
          ),
          _SheetActionTile(
            label: l10n.listDelete,
            icon: Icons.delete_outline,
            destructive: true,
            onTap: () async {
              Navigator.of(ctx).pop();
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dCtx) => AlertDialog(
                  title: Text(l10n.listDelete),
                  content: Text(l10n.deleteListConfirm(list.name)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dCtx).pop(false),
                      child: Text(l10n.cancelAction),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(dCtx).pop(true),
                      child: Text(
                        l10n.deleteAction,
                        style: TextStyle(color: dCtx.colors.statusDanger),
                      ),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await ref.read(listsRepositoryProvider).deleteList(list.id);
                onDeleted?.call();
              }
            },
          ),
          const SizedBox(height: AppTokens.space12),
        ],
      );
    },
  );
}

/// Sheet for adding/removing a single person (or adding multiple selected people) to lists.
Future<void> showManageListsSheet(
  BuildContext context,
  WidgetRef ref, {
  required Set<int> contactIds,
  Set<int> initialListIds = const {},
  bool replaceExistingForSinglePerson = false,
}) {
  final selected = Set<int>.from(initialListIds);
  return showAppSheet<void>(
    context: context,
    bodyBuilder: (ctx) => Consumer(
      builder: (ctx, cRef, _) {
        final l10n = ctx.l10n;
        final c = ctx.colors;
        final tt = Theme.of(ctx).textTheme;
        final listsAsync = cRef.watch(_allListsProvider);
        final lists = listsAsync.value ?? const [];

        return StatefulBuilder(
          builder: (ctx, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTokens.screenPadding,
                    AppTokens.space8,
                    AppTokens.screenPadding,
                    AppTokens.space8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.manageListsTitle,
                          style: tt.titleMedium!.copyWith(color: c.textPrimary),
                        ),
                      ),
                      AppButton(
                        label: l10n.newListChip,
                        variant: AppButtonVariant.quiet,
                        size: AppButtonSize.small,
                        onPressed: () async {
                          final newId = await showCreateOrRenameListSheet(ctx, cRef);
                          if (newId != null) {
                            setState(() => selected.add(newId));
                          }
                        },
                      ),
                    ],
                  ),
                ),
                for (final item in lists)
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (selected.contains(item.list.id)) {
                          selected.remove(item.list.id);
                        } else {
                          selected.add(item.list.id);
                        }
                      });
                    },
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: AppTokens.minTouchTarget),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTokens.screenPadding,
                          vertical: AppTokens.space12,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.list.name,
                                style: tt.bodyLarge!.copyWith(color: c.textPrimary),
                              ),
                            ),
                            Text(
                              '${item.memberCount}',
                              style: tt.bodySmall!.copyWith(color: c.textTertiary),
                            ),
                            const SizedBox(width: AppTokens.space12),
                            Icon(
                              selected.contains(item.list.id)
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              size: 22,
                              color: selected.contains(item.list.id)
                                  ? c.bgInverse
                                  : c.borderStrong,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTokens.screenPadding,
                    AppTokens.space12,
                    AppTokens.screenPadding,
                    AppTokens.space16,
                  ),
                  child: AppButton(
                    label: l10n.doneAction,
                    variant: AppButtonVariant.primary,
                    fullWidth: true,
                    onPressed: () async {
                      final repo = cRef.read(listsRepositoryProvider);
                      if (replaceExistingForSinglePerson && contactIds.length == 1) {
                        await repo.setListsForPerson(contactIds.first, selected);
                      } else {
                        for (final listId in selected) {
                          await repo.addMembers(listId, contactIds);
                        }
                      }
                      if (ctx.mounted) Navigator.of(ctx).pop();
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    ),
  );
}

final _allListsProvider = StreamProvider((ref) {
  return ref.watch(listsRepositoryProvider).watchLists();
});

class _SheetActionTile extends StatelessWidget {
  const _SheetActionTile({
    required this.label,
    required this.icon,
    this.onTap,
    this.destructive = false,
    this.enabled = true,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool destructive;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final color = !enabled
        ? c.textTertiary
        : (destructive ? c.statusDanger : c.textPrimary);
    return InkWell(
      onTap: enabled ? onTap : null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppTokens.minTouchTarget),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.screenPadding,
            vertical: AppTokens.space12,
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: AppTokens.space12),
              Expanded(
                child: Text(
                  label,
                  style: tt.bodyLarge!.copyWith(color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/format/app_formatters.dart';
import '../../../core/l10n_ext.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../data/lists_repository.dart';
import '../data/people_repository.dart';
import 'add_edit_person_sheet.dart';
import 'cadence_picker_sheet.dart';
import 'list_sheets.dart';

typedef _DirectoryQueryKey = ({
  String search,
  PeopleFilterKind filter,
  int? listId,
  PeopleSort sort,
});

final _peopleDirectoryProvider = StreamProvider.autoDispose
    .family<List<PersonDirectoryItem>, _DirectoryQueryKey>((ref, key) {
  final repo = ref.watch(peopleRepositoryProvider);
  final now = ref.watch(clockProvider)();
  return repo.watchDirectory(
    now: now,
    searchQuery: key.search,
    filter: key.filter,
    listId: key.listId,
    sort: key.sort,
  );
});

final _listsProvider = StreamProvider.autoDispose<List<ContactListSummary>>((ref) {
  return ref.watch(listsRepositoryProvider).watchLists();
});

final _mergeSuggestionProvider = StreamProvider.autoDispose<ResolvedMergeSuggestion?>((ref) {
  return ref.watch(peopleRepositoryProvider).watchFirstMergeSuggestion();
});

class PeopleScreen extends ConsumerStatefulWidget {
  const PeopleScreen({
    super.key,
    this.focusSearch = false,
    this.initialSelectionForCadence = false,
    this.onRowBuilt,
    this.onOpenPerson,
  });

  final bool focusSearch;
  final bool initialSelectionForCadence;

  /// Optional test hook called when each visible row builds in `ListView.builder`.
  final VoidCallback? onRowBuilt;

  /// Optional navigation override (defaults to `context.push('/people/$id')`).
  final void Function(int contactId)? onOpenPerson;

  @override
  ConsumerState<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends ConsumerState<PeopleScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  Timer? _debounce;

  String _debouncedSearch = '';
  PeopleFilterKind _filter = PeopleFilterKind.all;
  int? _selectedListId;

  bool _selectionMode = false;
  final Set<int> _selectedIds = <int>{};

  @override
  void initState() {
    super.initState();
    if (widget.initialSelectionForCadence) {
      _selectionMode = true;
    }
    if (widget.focusSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _searchFocus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 150), () {
      if (mounted && _debouncedSearch != value) {
        setState(() => _debouncedSearch = value);
      }
    });
    setState(() {}); // refresh clear icon immediately
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    setState(() => _debouncedSearch = '');
  }

  void _openPerson(int id) {
    if (widget.onOpenPerson != null) {
      widget.onOpenPerson!(id);
    } else {
      context.push('/people/$id');
    }
  }

  Future<void> _openAddPerson({String? initialName}) async {
    final savedId = await showAddEditPersonSheet(
      context,
      initialName: initialName,
      onOpenExisting: _openPerson,
    );
    if (savedId != null && mounted) {
      _openPerson(savedId);
    }
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty && !widget.initialSelectionForCadence) {
          _selectionMode = false;
        }
      } else {
        _selectionMode = true;
        _selectedIds.add(id);
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  Future<void> _setSort(PeopleSort sort) async {
    final value = switch (sort) {
      PeopleSort.recent => 'recent',
      PeopleSort.name => 'name',
      PeopleSort.longest => 'longest',
    };
    await ref.read(settingsRepositoryProvider).set('people_sort', value);
  }

  String _sortLabel(PeopleSort sort, BuildContext context) {
    final l10n = context.l10n;
    return switch (sort) {
      PeopleSort.recent => l10n.sortRecentlyContacted,
      PeopleSort.name => l10n.sortName,
      PeopleSort.longest => l10n.sortLongestSinceContact,
    };
  }

  String _metaFor(PersonDirectoryItem item, AppFormatters fmt, BuildContext context) {
    final l10n = context.l10n;
    final prefix = (item.contact.company != null && item.contact.company!.trim().isNotEmpty)
        ? item.contact.company!.trim()
        : (item.firstListName ?? '');

    if (item.hasOverdueFollowUp) {
      return prefix.isEmpty ? l10n.followUpOverdue : '$prefix · ${l10n.followUpOverdue}';
    }

    final words = fmt.formatLastInteractionWords(
      item.contact.lastInteractionAt,
      item.lastInteractionType,
      l10n,
    );
    return prefix.isEmpty ? words : '$prefix · $words';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;

    final sort = ref.watch(peopleSortProvider).value ?? PeopleSort.recent;
    final currency = ref.watch(currencyCodeProvider).value ?? 'USD';
    final locale = Localizations.localeOf(context).toLanguageTag();
    final fmt = AppFormatters(
      clock: ref.watch(clockProvider),
      localeName: locale,
      currencyCode: currency,
      use24Hour: MediaQuery.alwaysUse24HourFormatOf(context),
    );

    final queryKey = (
      search: _debouncedSearch,
      filter: _filter,
      listId: _selectedListId,
      sort: sort,
    );
    final directoryAsync = ref.watch(_peopleDirectoryProvider(queryKey));
    final lists = ref.watch(_listsProvider).value ?? const <ContactListSummary>[];
    final mergeSuggestion = ref.watch(_mergeSuggestionProvider).value;

    final items = directoryAsync.value;
    final count = items?.length ?? 0;

    return Scaffold(
      backgroundColor: c.bgCanvas,
      floatingActionButton: _selectionMode
          ? null
          : AppFab(
              icon: Icons.person_add_outlined,
              semanticLabel: l10n.addPersonTooltip,
              onPressed: () => _openAddPerson(),
            ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => ref.read(syncServiceProvider).syncAll(),
          child: CustomScrollView(
            slivers: [
              // Header or Selection bar
              SliverToBoxAdapter(
                child: _selectionMode
                    ? _buildSelectionHeader(context)
                    : _buildHeader(context, count),
              ),

              // Merge suggestion banner (Spec 05 -> Spec 06)
              if (!_selectionMode && mergeSuggestion != null)
                SliverToBoxAdapter(
                  child: _buildMergeSuggestionBanner(context, mergeSuggestion),
                ),

              // Search field
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTokens.screenPadding,
                    AppTokens.space12,
                    AppTokens.screenPadding,
                    AppTokens.space8,
                  ),
                  child: AppField(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    hintText: l10n.searchPeopleHint,
                    leadingIcon: Icons.search,
                    trailingIcon: _searchController.text.isNotEmpty ? Icons.close : null,
                    trailingSemanticLabel: l10n.clearSearchTooltip,
                    onTrailingTap: _clearSearch,
                    onChanged: _onSearchChanged,
                  ),
                ),
              ),

              // Filter chips row
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppTokens.screenPadding),
                  child: Row(
                    children: [
                      AppChip(
                        label: l10n.filterAll,
                        selected: _filter == PeopleFilterKind.all,
                        onTap: () => setState(() {
                          _filter = PeopleFilterKind.all;
                          _selectedListId = null;
                        }),
                      ),
                      const SizedBox(width: AppTokens.space8),
                      AppChip(
                        label: l10n.filterStarred,
                        selected: _filter == PeopleFilterKind.starred,
                        onTap: () => setState(() {
                          _filter = PeopleFilterKind.starred;
                          _selectedListId = null;
                        }),
                      ),
                      const SizedBox(width: AppTokens.space8),
                      AppChip(
                        label: l10n.filterDueToReconnect,
                        selected: _filter == PeopleFilterKind.dueToReconnect,
                        onTap: () => setState(() {
                          _filter = PeopleFilterKind.dueToReconnect;
                          _selectedListId = null;
                        }),
                      ),
                      const SizedBox(width: AppTokens.space8),
                      AppChip(
                        label: l10n.filterOwesMe,
                        selected: _filter == PeopleFilterKind.owesMe,
                        onTap: () => setState(() {
                          _filter = PeopleFilterKind.owesMe;
                          _selectedListId = null;
                        }),
                      ),
                      for (final summary in lists) ...[
                        const SizedBox(width: AppTokens.space8),
                        AppChip(
                          label: summary.list.name,
                          selected: _filter == PeopleFilterKind.list &&
                              _selectedListId == summary.list.id,
                          onTap: () => setState(() {
                            _filter = PeopleFilterKind.list;
                            _selectedListId = summary.list.id;
                          }),
                          onLongPress: () => showListActionsSheet(
                            context,
                            ref,
                            list: summary.list,
                            onDeleted: () {
                              if (_selectedListId == summary.list.id && mounted) {
                                setState(() {
                                  _filter = PeopleFilterKind.all;
                                  _selectedListId = null;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                      const SizedBox(width: AppTokens.space8),
                      AppChip(
                        label: l10n.newListChip,
                        leadingIcon: Icons.add,
                        onTap: () async {
                          final newId = await showCreateOrRenameListSheet(context, ref);
                          if (newId != null && mounted) {
                            setState(() {
                              _filter = PeopleFilterKind.list;
                              _selectedListId = newId;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Sort bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTokens.screenPadding,
                    AppTokens.space4,
                    AppTokens.space12,
                    AppTokens.space4,
                  ),
                  child: Row(
                    children: [
                      PopupMenuButton<PeopleSort>(
                        initialValue: sort,
                        onSelected: _setSort,
                        itemBuilder: (ctx) => [
                          PopupMenuItem(
                            value: PeopleSort.recent,
                            child: Text(l10n.sortRecentlyContacted),
                          ),
                          PopupMenuItem(
                            value: PeopleSort.name,
                            child: Text(l10n.sortName),
                          ),
                          PopupMenuItem(
                            value: PeopleSort.longest,
                            child: Text(l10n.sortLongestSinceContact),
                          ),
                        ],
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: AppTokens.minTouchTarget),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _sortLabel(sort, context),
                                style: tt.labelMedium!.copyWith(color: c.textSecondary),
                              ),
                              const SizedBox(width: AppTokens.space4),
                              Icon(
                                Icons.keyboard_arrow_down,
                                size: 18,
                                color: c.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // List body
              if (items == null)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _PlaceholderPersonRow(),
                    childCount: 3,
                  ),
                )
              else if (items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(context),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      widget.onRowBuilt?.call();
                      final item = items[index];
                      final isSelected = _selectedIds.contains(item.contact.id);
                      final meta = _metaFor(item, fmt, context);
                      final trailing = fmt.formatShortAge(item.contact.lastInteractionAt, l10n);

                      return PersonRow(
                        name: item.contact.displayName,
                        toneIndex: item.contact.id,
                        meta: meta,
                        metaIsDanger: item.hasOverdueFollowUp,
                        trailing: _selectionMode ? null : trailing,
                        trailingWidget: _selectionMode
                            ? Icon(
                                isSelected
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                size: 22,
                                color: isSelected ? c.bgInverse : c.borderStrong,
                              )
                            : null,
                        selected: isSelected,
                        onTap: () {
                          if (_selectionMode) {
                            _toggleSelection(item.contact.id);
                          } else {
                            _openPerson(item.contact.id);
                          }
                        },
                        onLongPress: () => _toggleSelection(item.contact.id),
                      );
                    },
                    childCount: items.length,
                  ),
                ),

              // Bottom breathing room for FAB
              const SliverToBoxAdapter(
                child: SizedBox(height: 88),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int count) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.screenPadding,
        AppTokens.space16,
        AppTokens.space12,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.peopleTitle,
                  style: tt.headlineMedium!.copyWith(color: c.textPrimary),
                ),
                const SizedBox(height: AppTokens.space4),
                Text(
                  l10n.peopleCount(count),
                  style: tt.bodyMedium!.copyWith(color: c.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: l10n.addPersonTooltip,
            icon: Icon(Icons.person_add_outlined, color: c.textPrimary),
            constraints: const BoxConstraints(
              minWidth: AppTokens.minTouchTarget,
              minHeight: AppTokens.minTouchTarget,
            ),
            onPressed: () => _openAddPerson(),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionHeader(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final hasSelection = _selectedIds.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.space8,
        AppTokens.space12,
        AppTokens.screenPadding,
        AppTokens.space4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: l10n.closeSelectionTooltip,
                icon: Icon(Icons.close, color: c.textPrimary),
                onPressed: _exitSelectionMode,
              ),
              const SizedBox(width: AppTokens.space4),
              Expanded(
                child: Text(
                  l10n.selectionCount(_selectedIds.length),
                  style: tt.titleMedium!.copyWith(color: c.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space8),
          Padding(
            padding: const EdgeInsets.only(left: AppTokens.space12),
            child: Wrap(
              spacing: AppTokens.space8,
              runSpacing: AppTokens.space8,
              children: [
                AppButton(
                  label: l10n.actionAddToList,
                  variant: AppButtonVariant.secondary,
                  size: AppButtonSize.small,
                  onPressed: hasSelection
                      ? () async {
                          await showManageListsSheet(
                            context,
                            ref,
                            contactIds: Set<int>.from(_selectedIds),
                          );
                          if (mounted) _exitSelectionMode();
                        }
                      : null,
                ),
                AppButton(
                  label: l10n.actionSetReconnect,
                  variant: AppButtonVariant.secondary,
                  size: AppButtonSize.small,
                  onPressed: hasSelection
                      ? () async {
                          final picked = await showCadencePickerSheet(context);
                          if (picked != null) {
                            await ref
                                .read(peopleRepositoryProvider)
                                .setCadenceForMany(_selectedIds, picked.days);
                            if (mounted) _exitSelectionMode();
                          }
                        }
                      : null,
                ),
                AppButton(
                  label: l10n.actionMessage,
                  variant: AppButtonVariant.secondary,
                  size: AppButtonSize.small,
                  // Enabled in spec 10
                  onPressed: null,
                ),
                AppButton(
                  label: l10n.actionStar,
                  variant: AppButtonVariant.secondary,
                  size: AppButtonSize.small,
                  onPressed: hasSelection
                      ? () async {
                          await ref
                              .read(peopleRepositoryProvider)
                              .setStarred(_selectedIds, true);
                          if (mounted) _exitSelectionMode();
                        }
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMergeSuggestionBanner(
    BuildContext context,
    ResolvedMergeSuggestion suggestion,
  ) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.screenPadding,
        AppTokens.space12,
        AppTokens.screenPadding,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppTokens.space16),
        decoration: BoxDecoration(
          color: c.bgSurface,
          borderRadius: BorderRadius.circular(AppTokens.radiusCard),
          border: Border.all(color: c.borderHairline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.mergeSuggestionTitle(
                suggestion.contactA.displayName,
                suggestion.contactB.displayName,
              ),
              style: tt.labelLarge!.copyWith(color: c.textPrimary),
            ),
            const SizedBox(height: AppTokens.space12),
            Row(
              children: [
                AppButton(
                  label: l10n.mergeAction,
                  variant: AppButtonVariant.secondary,
                  size: AppButtonSize.small,
                  onPressed: () async {
                    await ref.read(peopleRepositoryProvider).mergePeople(
                          suggestion.contactA.id,
                          suggestion.contactB.id,
                        );
                  },
                ),
                const SizedBox(width: AppTokens.space8),
                AppButton(
                  label: l10n.keepSeparateAction,
                  variant: AppButtonVariant.quiet,
                  size: AppButtonSize.small,
                  onPressed: () async {
                    await ref.read(peopleRepositoryProvider).dismissMergeSuggestion(
                          suggestion.contactA.id,
                          suggestion.contactB.id,
                        );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = context.l10n;
    final query = _debouncedSearch.trim();
    if (query.isNotEmpty) {
      return EmptyState(
        title: l10n.noMatchesTitle(query),
        message: '',
        actionLabel: l10n.addQueryAsPerson(query),
        onAction: () => _openAddPerson(initialName: query),
      );
    }
    if (_filter != PeopleFilterKind.all) {
      return EmptyState(
        title: l10n.noPeopleInFilter,
        message: '',
      );
    }
    return EmptyState(
      title: l10n.noPeopleYetTitle,
      message: l10n.noPeopleYetSubtitle,
    );
  }
}

class _PlaceholderPersonRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.screenPadding,
        vertical: AppTokens.space12,
      ),
      child: Row(
        children: [
          Container(
            width: AppTokens.avatarSize,
            height: AppTokens.avatarSize,
            decoration: BoxDecoration(color: c.bgSubtle, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppTokens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: 140,
                  decoration: BoxDecoration(
                    color: c.bgSubtle,
                    borderRadius: BorderRadius.circular(AppTokens.radiusSmall),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 12,
                  width: 200,
                  decoration: BoxDecoration(
                    color: c.bgSubtle,
                    borderRadius: BorderRadius.circular(AppTokens.radiusSmall),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

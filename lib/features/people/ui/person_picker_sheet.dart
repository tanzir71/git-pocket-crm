import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/db/app_database.dart';
import '../../../core/l10n_ext.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';

/// Reusable single-select person picker sheet (used by Add sheet in Spec 07 &
/// New message in Spec 10).
Future<Contact?> showPersonPickerSheet(BuildContext context) {
  return showAppSheet<Contact>(
    context: context,
    bodyBuilder: (ctx) => const _PersonPickerSheetBody(),
  );
}

class _PersonPickerSheetBody extends ConsumerStatefulWidget {
  const _PersonPickerSheetBody();

  @override
  ConsumerState<_PersonPickerSheetBody> createState() => _PersonPickerSheetBodyState();
}

class _PersonPickerSheetBodyState extends ConsumerState<_PersonPickerSheetBody> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final contacts = ref.watch(_allContactsProvider).value ?? const <Contact>[];

    final filtered = _query.trim().isEmpty
        ? contacts
        : contacts.where((person) {
            final q = _query.trim().toLowerCase();
            return person.displayName.toLowerCase().contains(q) ||
                (person.company ?? '').toLowerCase().contains(q) ||
                (person.phoneNumber ?? '').toLowerCase().contains(q);
          }).toList();

    final recent = _query.trim().isEmpty
        ? filtered.where((p) => p.lastInteractionAt != null).take(5).toList()
        : const <Contact>[];

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppTokens.screenPadding,
              AppTokens.space8,
              AppTokens.screenPadding,
              AppTokens.space12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.personPickerTitle,
                  style: tt.titleMedium!.copyWith(color: c.textPrimary),
                ),
                const SizedBox(height: AppTokens.space12),
                AppField(
                  controller: _searchController,
                  hintText: l10n.searchPeopleHint,
                  leadingIcon: Icons.search,
                  onChanged: (v) => setState(() => _query = v),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                if (recent.isNotEmpty) ...[
                  SectionHeader(title: l10n.personPickerRecent),
                  for (final person in recent)
                    PersonRow(
                      name: person.displayName,
                      toneIndex: person.id,
                      meta: person.company ?? person.phoneNumber,
                      onTap: () => Navigator.of(context).pop(person),
                    ),
                ],
                SectionHeader(title: l10n.personPickerAll),
                for (final person in filtered)
                  PersonRow(
                    name: person.displayName,
                    toneIndex: person.id,
                    meta: person.company ?? person.phoneNumber,
                    onTap: () => Navigator.of(context).pop(person),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final _allContactsProvider = StreamProvider<List<Contact>>((ref) {
  return ref.watch(peopleRepositoryProvider).watchAll();
});

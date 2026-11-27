import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/db/app_database.dart';
import '../../../core/l10n_ext.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../data/people_repository.dart';

/// Opens the Add person (when [existing] is null) or Edit person sheet.
/// Returns the saved contact ID, or null if dismissed.
Future<int?> showAddEditPersonSheet(
  BuildContext context, {
  Contact? existing,
  String? initialName,
  void Function(int contactId)? onOpenExisting,
}) {
  return showAppSheet<int>(
    context: context,
    bodyBuilder: (ctx) => _AddEditPersonSheetBody(
      existing: existing,
      initialName: initialName,
      onOpenExisting: onOpenExisting,
    ),
  );
}

class _PhoneFieldEntry {
  _PhoneFieldEntry({required String initialText, required this.isPrimary})
      : controller = TextEditingController(text: initialText);

  final TextEditingController controller;
  bool isPrimary;
  bool looksIncomplete = false;
  Contact? duplicateOwner;
}

class _AddEditPersonSheetBody extends ConsumerStatefulWidget {
  const _AddEditPersonSheetBody({
    this.existing,
    this.initialName,
    this.onOpenExisting,
  });

  final Contact? existing;
  final String? initialName;
  final void Function(int contactId)? onOpenExisting;

  @override
  ConsumerState<_AddEditPersonSheetBody> createState() => _AddEditPersonSheetBodyState();
}

class _AddEditPersonSheetBodyState extends ConsumerState<_AddEditPersonSheetBody> {
  late final TextEditingController _nameController;
  late final TextEditingController _companyController;
  late final TextEditingController _roleController;
  late final TextEditingController _cityController;
  late final TextEditingController _emailController;
  late final TextEditingController _birthdayController;
  late final TextEditingController _linkedinController;
  late final TextEditingController _facebookController;
  late final TextEditingController _aboutController;

  final List<_PhoneFieldEntry> _phones = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final c = widget.existing;
    _nameController = TextEditingController(text: c?.displayName ?? widget.initialName ?? '');
    _companyController = TextEditingController(text: c?.company ?? '');
    _roleController = TextEditingController(text: c?.role ?? '');
    _cityController = TextEditingController(text: c?.city ?? '');
    _emailController = TextEditingController(text: c?.email ?? c?.gmailAddress ?? '');
    _birthdayController = TextEditingController(text: c?.birthday ?? '');
    _linkedinController = TextEditingController(text: c?.linkedinUrl ?? '');
    _facebookController = TextEditingController(text: c?.facebookUrl ?? '');
    _aboutController = TextEditingController(text: c?.about ?? c?.pinnedNote ?? '');

    if (c == null) {
      _phones.add(_PhoneFieldEntry(initialText: '', isPrimary: true));
    } else {
      _loadExistingPhones(c);
    }
  }

  Future<void> _loadExistingPhones(Contact c) async {
    final rows = await ref.read(peopleRepositoryProvider).getPhones(c.id);
    if (!mounted) return;
    setState(() {
      _phones.clear();
      if (rows.isNotEmpty) {
        for (var i = 0; i < rows.length; i++) {
          final r = rows[i];
          _phones.add(
            _PhoneFieldEntry(
              initialText: r.raw ?? r.e164 ?? '',
              isPrimary: r.isPrimary == 1 || (i == 0 && !rows.any((x) => x.isPrimary == 1)),
            ),
          );
        }
      } else {
        _phones.add(_PhoneFieldEntry(initialText: c.phoneNumber ?? '', isPrimary: true));
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _roleController.dispose();
    _cityController.dispose();
    _emailController.dispose();
    _birthdayController.dispose();
    _linkedinController.dispose();
    _facebookController.dispose();
    _aboutController.dispose();
    for (final p in _phones) {
      p.controller.dispose();
    }
    super.dispose();
  }

  Future<void> _validatePhone(_PhoneFieldEntry entry) async {
    final raw = entry.controller.text.trim();
    if (raw.isEmpty) {
      if (mounted) {
        setState(() {
          entry.looksIncomplete = false;
          entry.duplicateOwner = null;
        });
      }
      return;
    }

    final region = ref.read(phoneRegionProvider).value ?? 'US';
    final phoneService = ref.read(phoneServiceProvider);
    final e164 = phoneService.normalise(raw, region);
    final incomplete = e164 == null;

    Contact? dup;
    if (widget.existing == null) {
      final repo = ref.read(peopleRepositoryProvider);
      dup = await repo.findByPhone(e164 ?? raw);
    }

    if (mounted) {
      setState(() {
        entry.looksIncomplete = incomplete;
        entry.duplicateOwner = dup;
      });
    }
  }

  bool get _canSave {
    if (_saving) return false;
    if (_nameController.text.trim().isEmpty) return false;
    return _phones.any((p) => p.controller.text.trim().isNotEmpty);
  }

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _saving = true);

    final repo = ref.read(peopleRepositoryProvider);
    final phoneService = ref.read(phoneServiceProvider);
    final region = ref.read(phoneRegionProvider).value ?? 'US';

    final drafts = <PhoneDraft>[];
    for (final entry in _phones) {
      final raw = entry.controller.text.trim();
      if (raw.isEmpty) continue;
      final e164 = phoneService.normalise(raw, region);
      final isMobile = e164 != null ? phoneService.isMobile(e164) : true;
      drafts.add(
        PhoneDraft(
          raw: raw,
          e164: e164,
          isPrimary: entry.isPrimary,
          isMobile: isMobile,
        ),
      );
    }
    if (drafts.isNotEmpty && !drafts.any((d) => d.isPrimary)) {
      final first = drafts.first;
      drafts[0] = PhoneDraft(
        raw: first.raw,
        e164: first.e164,
        isPrimary: true,
        isMobile: first.isMobile,
      );
    }

    // Check duplicate on new person one more time before creating
    if (widget.existing == null) {
      for (final d in drafts) {
        final dup = await repo.findByPhone(d.e164 ?? d.raw);
        if (dup != null) {
          if (mounted) {
            setState(() {
              _saving = false;
              for (final p in _phones) {
                if (p.controller.text.trim() == d.raw) {
                  p.duplicateOwner = dup;
                }
              }
            });
          }
          return;
        }
      }
    }

    final int savedId;
    if (widget.existing == null) {
      savedId = await repo.createPerson(
        displayName: _nameController.text.trim(),
        phoneNumber: drafts.first.e164 ?? drafts.first.raw,
        company: _companyController.text,
        role: _roleController.text,
        city: _cityController.text,
        email: _emailController.text,
        birthday: _birthdayController.text,
        linkedinUrl: _linkedinController.text,
        facebookUrl: _facebookController.text,
        about: _aboutController.text,
        phones: drafts,
      );
    } else {
      final id = widget.existing!.id;
      await repo.updatePerson(
        id,
        ContactsCompanion(
          displayName: Value(_nameController.text.trim()),
          company: Value(_nullIfEmpty(_companyController.text)),
          role: Value(_nullIfEmpty(_roleController.text)),
          city: Value(_nullIfEmpty(_cityController.text)),
          email: Value(_nullIfEmpty(_emailController.text)),
          gmailAddress: Value(_nullIfEmpty(_emailController.text)),
          birthday: Value(_nullIfEmpty(_birthdayController.text)),
          linkedinUrl: Value(_nullIfEmpty(_linkedinController.text)),
          facebookUrl: Value(_nullIfEmpty(_facebookController.text)),
          about: Value(_nullIfEmpty(_aboutController.text)),
          pinnedNote: Value(_nullIfEmpty(_aboutController.text)),
        ),
      );
      await repo.replacePhones(id, drafts);
      savedId = id;
    }

    if (mounted) {
      Navigator.of(context).pop(savedId);
    }
  }

  String? _nullIfEmpty(String s) {
    final t = s.trim();
    return t.isEmpty ? null : t;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final isEdit = widget.existing != null;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.screenPadding,
              AppTokens.space8,
              AppTokens.screenPadding,
              AppTokens.space12,
            ),
            child: Text(
              isEdit ? l10n.editPersonTitle : l10n.addPersonTitle,
              style: tt.titleMedium!.copyWith(color: c.textPrimary),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppTokens.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppField(
                    label: l10n.fieldName,
                    controller: _nameController,
                    autofocus: !isEdit,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: AppTokens.space12),
                  for (var i = 0; i < _phones.length; i++) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: AppField(
                            label: i == 0 ? l10n.fieldPhone : null,
                            hintText: l10n.fieldPhone,
                            controller: _phones[i].controller,
                            keyboardType: TextInputType.phone,
                            onChanged: (_) {
                              setState(() {});
                              _validatePhone(_phones[i]);
                            },
                          ),
                        ),
                        if (_phones.length > 1) ...[
                          const SizedBox(width: AppTokens.space8),
                          AppChip(
                            label: l10n.fieldPrimary,
                            selected: _phones[i].isPrimary,
                            onTap: () {
                              setState(() {
                                for (var j = 0; j < _phones.length; j++) {
                                  _phones[j].isPrimary = j == i;
                                }
                              });
                            },
                          ),
                          IconButton(
                            tooltip: l10n.deleteAction,
                            icon: Icon(Icons.close, size: 20, color: c.textSecondary),
                            onPressed: () {
                              setState(() {
                                final removed = _phones.removeAt(i);
                                removed.controller.dispose();
                                if (!_phones.any((p) => p.isPrimary) && _phones.isNotEmpty) {
                                  _phones.first.isPrimary = true;
                                }
                              });
                            },
                          ),
                        ],
                      ],
                    ),
                    if (_phones[i].looksIncomplete)
                      Padding(
                        padding: const EdgeInsets.only(top: AppTokens.space4),
                        child: Text(
                          l10n.phoneIncompleteWarning,
                          style: tt.bodySmall!.copyWith(color: c.statusWarning),
                        ),
                      ),
                    if (_phones[i].duplicateOwner != null)
                      Padding(
                        padding: const EdgeInsets.only(top: AppTokens.space8),
                        child: Container(
                          padding: const EdgeInsets.all(AppTokens.space12),
                          decoration: BoxDecoration(
                            color: c.bgSubtle,
                            borderRadius: BorderRadius.circular(AppTokens.radiusCard),
                            border: Border.all(color: c.borderHairline),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  l10n.duplicatePhoneNotice(_phones[i].duplicateOwner!.displayName),
                                  style: tt.bodySmall!.copyWith(color: c.textPrimary),
                                ),
                              ),
                              const SizedBox(width: AppTokens.space8),
                              AppButton(
                                label: l10n.openPersonAction(
                                  _phones[i].duplicateOwner!.displayName,
                                ),
                                variant: AppButtonVariant.secondary,
                                size: AppButtonSize.small,
                                onPressed: () {
                                  final targetId = _phones[i].duplicateOwner!.id;
                                  Navigator.of(context).pop();
                                  widget.onOpenExisting?.call(targetId);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: AppTokens.space8),
                  ],
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: AppButton(
                      label: l10n.fieldAddPhone,
                      variant: AppButtonVariant.quiet,
                      size: AppButtonSize.small,
                      onPressed: () {
                        setState(() {
                          _phones.add(_PhoneFieldEntry(initialText: '', isPrimary: false));
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: AppTokens.space12),
                  AppField(label: l10n.fieldCompany, controller: _companyController),
                  const SizedBox(height: AppTokens.space12),
                  if (isEdit) ...[
                    AppField(label: l10n.fieldRole, controller: _roleController),
                    const SizedBox(height: AppTokens.space12),
                    AppField(label: l10n.fieldCity, controller: _cityController),
                    const SizedBox(height: AppTokens.space12),
                  ],
                  AppField(
                    label: l10n.fieldEmail,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppTokens.space12),
                  if (isEdit) ...[
                    AppField(label: l10n.fieldBirthday, controller: _birthdayController),
                    const SizedBox(height: AppTokens.space12),
                    AppField(label: l10n.fieldLinkedin, controller: _linkedinController),
                    const SizedBox(height: AppTokens.space12),
                    AppField(label: l10n.fieldFacebook, controller: _facebookController),
                    const SizedBox(height: AppTokens.space12),
                  ],
                  AppField(
                    label: l10n.fieldAbout,
                    controller: _aboutController,
                    minLines: 2,
                    maxLines: 4,
                  ),
                  const SizedBox(height: AppTokens.space16),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.screenPadding,
              AppTokens.space8,
              AppTokens.screenPadding,
              AppTokens.space16,
            ),
            child: AppButton(
              label: l10n.saveAction,
              variant: AppButtonVariant.primary,
              fullWidth: true,
              onPressed: _canSave ? _save : null,
            ),
          ),
        ],
      ),
    );
  }
}

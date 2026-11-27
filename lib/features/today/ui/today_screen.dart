import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n_ext.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../../capture/ui/add_sheet.dart';
import '../../capture/ui/after_call_sheet.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({
    super.key,
    this.afterCallNumber,
    this.afterCallFocus,
  });

  final String? afterCallNumber;
  final String? afterCallFocus;

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  String? _handledAfterCallNumber;

  @override
  void initState() {
    super.initState();
    _maybeHandleAfterCallDeepLink();
  }

  @override
  void didUpdateWidget(covariant TodayScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.afterCallNumber != oldWidget.afterCallNumber) {
      _maybeHandleAfterCallDeepLink();
    }
  }

  void _maybeHandleAfterCallDeepLink() {
    final number = widget.afterCallNumber?.trim();
    if (number == null || number.isEmpty || number == _handledAfterCallNumber) {
      return;
    }
    _handledAfterCallNumber = number;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_openAfterCallForNumber(number, focusFollowUp: widget.afterCallFocus == 'followup'));
    });
  }

  Future<void> _openAfterCallForNumber(String rawNumber, {required bool focusFollowUp}) async {
    try {
      await ref.read(syncServiceProvider).syncAll(syncContacts: false);
    } catch (_) {
      // Proceed with whatever is already in DB
    }
    if (!mounted) return;

    final region = ref.read(phoneRegionProvider).value ?? 'US';
    final phoneService = ref.read(phoneServiceProvider);
    final e164 = phoneService.normalise(rawNumber, region) ?? rawNumber;
    final peopleRepo = ref.read(peopleRepositoryProvider);
    final contact = await peopleRepo.findByPhone(e164) ?? await peopleRepo.findByPhone(rawNumber);
    if (contact == null || !mounted) return;

    final calls = await ref
        .read(historyRepositoryProvider)
        .watchForPerson(
          contact.id,
          types: const {'call_incoming', 'call_outgoing', 'call_missed'},
          limit: 1,
        )
        .first;
    if (calls.isEmpty || !mounted) return;

    final token = await showAfterCallSheet(
      context,
      contact: contact,
      callEntry: calls.first,
      focusFollowUp: focusFollowUp,
    );
    if (token != null && mounted) {
      showCaptureSavedSnackBar(context, ref, token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: c.bgCanvas,
      floatingActionButton: AppFab(
        icon: Icons.add,
        semanticLabel: l10n.addSheetTitle,
        onPressed: () async {
          final token = await showAddSheet(context);
          if (token != null && context.mounted) {
            showCaptureSavedSnackBar(context, ref, token);
          }
        },
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.screenPadding,
                AppTokens.space16,
                AppTokens.screenPadding,
                AppTokens.space8,
              ),
              child: Text(l10n.navToday, style: tt.headlineMedium),
            ),
            Expanded(
              child: EmptyState(
                title: l10n.placeholderTitle,
                message: l10n.tabTodayPlaceholder,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

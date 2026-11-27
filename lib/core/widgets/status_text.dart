import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

enum MessageDeliveryStatus {
  queued,
  sending,
  sent,
  delivered,
  failed,
  cancelled,
  missed,
  skipped,
}

MessageDeliveryStatus parseMessageStatus(String raw) {
  return switch (raw.toLowerCase()) {
    'queued' => MessageDeliveryStatus.queued,
    'sending' => MessageDeliveryStatus.sending,
    'sent' => MessageDeliveryStatus.sent,
    'delivered' => MessageDeliveryStatus.delivered,
    'failed' => MessageDeliveryStatus.failed,
    'cancelled' => MessageDeliveryStatus.cancelled,
    'missed' => MessageDeliveryStatus.missed,
    'skipped' => MessageDeliveryStatus.skipped,
    _ => MessageDeliveryStatus.queued,
  };
}

class StatusText extends StatelessWidget {
  const StatusText({
    super.key,
    required this.status,
    this.labelOverride,
  });

  final MessageDeliveryStatus status;
  final String? labelOverride;

  static String defaultLabel(MessageDeliveryStatus status) {
    return switch (status) {
      MessageDeliveryStatus.queued => 'Waiting',
      MessageDeliveryStatus.sending => 'Sending',
      MessageDeliveryStatus.sent => 'Sent',
      MessageDeliveryStatus.delivered => 'Delivered',
      MessageDeliveryStatus.failed => 'Not sent',
      MessageDeliveryStatus.cancelled => 'Cancelled',
      MessageDeliveryStatus.missed => 'Missed',
      MessageDeliveryStatus.skipped => 'Skipped',
    };
  }

  static Color colorFor(MessageDeliveryStatus status, AppColors c) {
    return switch (status) {
      MessageDeliveryStatus.queued => c.textTertiary,
      MessageDeliveryStatus.sending => c.textPrimary,
      MessageDeliveryStatus.sent => c.textSecondary,
      MessageDeliveryStatus.delivered => c.statusSuccess,
      MessageDeliveryStatus.failed => c.statusDanger,
      MessageDeliveryStatus.cancelled => c.textTertiary,
      MessageDeliveryStatus.missed => c.statusDanger,
      MessageDeliveryStatus.skipped => c.textTertiary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final label = labelOverride ?? defaultLabel(status);
    return Text(
      label,
      style: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: colorFor(status, c),
          ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

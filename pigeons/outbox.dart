import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/core/native/outbox_api.g.dart',
    kotlinOut: 'android/app/src/main/kotlin/com/pocketcrm/pocket_crm/outbox/OutboxApi.g.kt',
    kotlinOptions: KotlinOptions(package: 'com.pocketcrm.pocket_crm.outbox'),
  ),
)
class OutboxItem {
  OutboxItem({
    required this.clientId,
    this.campaignId,
    required this.address,
    this.recipientName,
    required this.body,
    required this.dueAtMs,
    this.subId,
    this.status = 'queued',
    this.attempt = 0,
    this.partsTotal = 0,
    this.partsSent = 0,
    this.partsFailed = 0,
    this.partsDelivered = 0,
    this.errorCode,
    this.sentAtMs,
    this.deliveredAtMs,
    this.seq = 0,
  });

  String clientId;
  String? campaignId;
  String address;
  String? recipientName;
  String body;
  int dueAtMs;
  int? subId;
  String status;
  int attempt;
  int partsTotal;
  int partsSent;
  int partsFailed;
  int partsDelivered;
  int? errorCode;
  int? sentAtMs;
  int? deliveredAtMs;
  int seq;
}

class CampaignConfig {
  CampaignConfig({
    required this.id,
    required this.name,
    required this.paceSeconds,
    required this.windowStartMin,
    required this.windowEndMin,
    this.status = 'scheduled',
  });

  String id;
  String name;
  int paceSeconds;
  int windowStartMin;
  int windowEndMin;
  String status;
}

class ChangeSet {
  ChangeSet({
    required this.items,
    required this.latestSeq,
  });

  List<OutboxItem> items;
  int latestSeq;
}

class SimInfo {
  SimInfo({
    required this.subId,
    required this.slot,
    required this.carrierName,
    required this.displayName,
    required this.isDefault,
  });

  int subId;
  int slot;
  String carrierName;
  String displayName;
  bool isDefault;
}

class OutboxCapabilities {
  OutboxCapabilities({
    required this.exactAlarms,
    required this.ignoringBatteryOptimisation,
    required this.notifications,
    required this.smsPermission,
  });

  bool exactAlarms;
  bool ignoringBatteryOptimisation;
  bool notifications;
  bool smsPermission;
}

class SetupPlatformInfo {
  SetupPlatformInfo({
    required this.sdkInt,
    required this.manufacturer,
    required this.installedFromStore,
    this.ownPhoneNumber,
  });

  int sdkInt;
  String manufacturer;
  bool installedFromStore;
  String? ownPhoneNumber;
}

@HostApi()
abstract class OutboxApi {
  void enqueue(List<OutboxItem> items);

  void upsertCampaign(CampaignConfig config);

  void cancel(List<String> clientIds);

  void retry(List<String> clientIds);

  void pauseCampaign(String id);

  void resumeCampaign(String id);

  void stopCampaign(String id);

  ChangeSet changesSince(int seq);

  List<SimInfo> sims();

  OutboxCapabilities capabilities();

  void shareFile(String path, String mimeType, String subject);

  SetupPlatformInfo setupInfo();

  void openExactAlarmSettings();

  void requestIgnoreBatteryOptimisations();

  void openAppDetailsSettings();
}

@FlutterApi()
abstract class OutboxEvents {
  void onOutboxChanged(int latestSeq);
}

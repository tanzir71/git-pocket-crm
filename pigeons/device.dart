import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/core/native/device_api.g.dart',
    kotlinOut: 'android/app/src/main/kotlin/com/pocketcrm/pocket_crm/DeviceApi.g.kt',
    kotlinOptions: KotlinOptions(package: 'com.pocketcrm.pocket_crm'),
  ),
)
class CallRecord {
  CallRecord({
    required this.id,
    required this.number,
    required this.type,
    required this.dateMs,
    required this.durationSeconds,
  });

  int id;
  String number;
  String type; // 'incoming', 'outgoing', 'missed'
  int dateMs;
  int durationSeconds;
}

class SmsRecord {
  SmsRecord({
    required this.id,
    required this.address,
    required this.body,
    required this.dateMs,
    required this.box,
    this.subId,
  });

  int id;
  String address;
  String body;
  int dateMs;
  String box; // 'inbox' | 'sent'
  int? subId;
}

@HostApi()
abstract class DeviceApi {
  @async
  List<CallRecord> readCalls(int afterId, int limit);

  @async
  List<SmsRecord> readSms(int afterId, int limit);

  String? simCountryIso();

  void startObserving();

  void stopObserving();
}

@FlutterApi()
abstract class DeviceEvents {
  void onDeviceDataChanged(String kind); // 'calls' | 'sms'
}

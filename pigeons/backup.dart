import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/core/native/backup_api.g.dart',
    kotlinOut: 'android/app/src/main/kotlin/com/pocketcrm/pocket_crm/backup/BackupApi.g.kt',
    kotlinOptions: KotlinOptions(package: 'com.pocketcrm.pocket_crm.backup'),
  ),
)
@HostApi()
abstract class BackupSafApi {
  @async
  String? createDocument(String name, String mime);

  @async
  void copyFileToUri(String path, String uri);

  @async
  String? pickDocument(List<String> mimeTypes);
}

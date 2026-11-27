# Keep PocketCRM Pigeon classes, BroadcastReceivers, and WorkManager workers.
-keep class com.pocketcrm.pocket_crm.** { *; }

# Keep WorkManager and its Room-generated WorkDatabase_Impl constructor.
-keep class * extends androidx.work.WorkManager
-keep class * extends androidx.work.ListenableWorker {
    public <init>(android.content.Context, androidx.work.WorkerParameters);
}
-keep class * extends androidx.work.InputMerger
-keep class * extends androidx.room.RoomDatabase {
    public <init>();
}
-keep class androidx.work.impl.WorkDatabase_Impl { *; }
-keep class * extends androidx.startup.Initializer {
    public <init>();
}

# Keep flutter_local_notifications models for scheduled notification serialization.
-keep class com.dexterous.flutterlocalnotifications.** { *; }

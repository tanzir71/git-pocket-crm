package com.pocketcrm.pocket_crm

import android.content.Intent
import com.pocketcrm.pocket_crm.backup.BackupSafApi
import com.pocketcrm.pocket_crm.backup.BackupSafApiImpl
import com.pocketcrm.pocket_crm.outbox.OutboxApi
import com.pocketcrm.pocket_crm.outbox.OutboxApiImpl
import com.pocketcrm.pocket_crm.outbox.OutboxEvents
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var deviceApiImpl: DeviceApiImpl? = null
    private var outboxApiImpl: OutboxApiImpl? = null
    private var backupSafApiImpl: BackupSafApiImpl? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val messenger = flutterEngine.dartExecutor.binaryMessenger
        val deviceEvents = DeviceEvents(messenger)
        val impl = DeviceApiImpl(applicationContext, deviceEvents)
        deviceApiImpl = impl
        DeviceApi.setUp(messenger, impl)

        val outboxEvents = OutboxEvents(messenger)
        val outboxImpl = OutboxApiImpl(applicationContext, outboxEvents)
        outboxApiImpl = outboxImpl
        OutboxApi.setUp(messenger, outboxImpl)

        val backupImpl = BackupSafApiImpl(this)
        backupSafApiImpl = backupImpl
        BackupSafApi.setUp(messenger, backupImpl)
    }

    @Suppress("DEPRECATION")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (backupSafApiImpl?.handleActivityResult(requestCode, resultCode, data) == true) {
            return
        }
        super.onActivityResult(requestCode, resultCode, data)
    }

    override fun onDestroy() {
        deviceApiImpl?.dispose()
        deviceApiImpl = null
        outboxApiImpl?.dispose()
        outboxApiImpl = null
        backupSafApiImpl?.dispose()
        backupSafApiImpl = null
        super.onDestroy()
    }
}

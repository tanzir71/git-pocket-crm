package com.pocketcrm.pocket_crm

import com.pocketcrm.pocket_crm.outbox.OutboxApi
import com.pocketcrm.pocket_crm.outbox.OutboxApiImpl
import com.pocketcrm.pocket_crm.outbox.OutboxEvents
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var deviceApiImpl: DeviceApiImpl? = null
    private var outboxApiImpl: OutboxApiImpl? = null

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
    }

    override fun onDestroy() {
        deviceApiImpl?.dispose()
        deviceApiImpl = null
        outboxApiImpl?.dispose()
        outboxApiImpl = null
        super.onDestroy()
    }
}

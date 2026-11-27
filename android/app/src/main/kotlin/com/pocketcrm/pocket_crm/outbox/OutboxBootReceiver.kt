package com.pocketcrm.pocket_crm.outbox

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Re-arms outbox alarms after device reboot, app update, clock/timezone changes,
 * or exact-alarm permission changes, and marks overdue single messages as missed.
 */
class OutboxBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        val db = OutboxDb.getInstance(context)
        val missed = db.markOverdueSingleMessagesMissed(System.currentTimeMillis())
        if (missed > 0) {
            OutboxApiImpl.notifyChanged(db.currentSeq())
        }
        OutboxScheduler.scheduleNext(context)
    }
}

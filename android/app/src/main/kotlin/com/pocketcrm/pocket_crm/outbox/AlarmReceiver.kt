package com.pocketcrm.pocket_crm.outbox

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Triggered by [OutboxScheduler]'s `AlarmManager` alarm; hands off immediately
 * to the unique expedited [OutboxDrainWorker].
 */
class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        OutboxScheduler.enqueueDrainNow(context)
    }

    companion object {
        const val ACTION_OUTBOX_ALARM = "com.pocketcrm.pocket_crm.outbox.ACTION_OUTBOX_ALARM"
    }
}

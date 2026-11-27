package com.pocketcrm.pocket_crm.outbox

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.OutOfQuotaPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import java.util.concurrent.TimeUnit

/**
 * Schedules the next outbox drain using `AlarmManager.setExactAndAllowWhileIdle`
 * (or `setAndAllowWhileIdle` when exact alarms are not granted) plus a 15-minute
 * WorkManager periodic safety net.
 */
object OutboxScheduler {

    private const val TAG = "OutboxScheduler"
    private const val ALARM_REQUEST_CODE = 7401
    const val UNIQUE_DRAIN_WORK = "outbox-drain"
    const val UNIQUE_PERIODIC_WORK = "outbox-periodic"

    fun scheduleNext(context: Context) {
        val appCtx = context.applicationContext
        ensurePeriodicSafetyNet(appCtx)

        val db = OutboxDb.getInstance(appCtx)
        val earliestDue = db.earliestQueuedDueAt()
        val alarmManager = appCtx.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val pi = alarmPendingIntent(appCtx)

        if (earliestDue == null) {
            alarmManager.cancel(pi)
            return
        }

        val now = System.currentTimeMillis()
        if (earliestDue <= now + 2_000L) {
            alarmManager.cancel(pi)
            enqueueDrainNow(appCtx)
            return
        }

        val canExact = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            alarmManager.canScheduleExactAlarms()
        } else {
            true
        }

        try {
            if (canExact) {
                alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, earliestDue, pi)
            } else {
                alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, earliestDue, pi)
            }
        } catch (se: SecurityException) {
            Log.w(TAG, "Exact alarm denied, falling back to inexact: ${se.message}")
            alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, earliestDue, pi)
        }
    }

    fun enqueueDrainNow(context: Context) {
        val appCtx = context.applicationContext
        val request = OneTimeWorkRequestBuilder<OutboxDrainWorker>()
            .setExpedited(OutOfQuotaPolicy.RUN_AS_NON_EXPEDITED_WORK_REQUEST)
            .build()
        WorkManager.getInstance(appCtx).enqueueUniqueWork(
            UNIQUE_DRAIN_WORK,
            ExistingWorkPolicy.KEEP,
            request,
        )
    }

    fun ensurePeriodicSafetyNet(context: Context) {
        val periodic = PeriodicWorkRequestBuilder<OutboxDrainWorker>(
            15L,
            TimeUnit.MINUTES,
        ).build()
        WorkManager.getInstance(context.applicationContext).enqueueUniquePeriodicWork(
            UNIQUE_PERIODIC_WORK,
            ExistingPeriodicWorkPolicy.KEEP,
            periodic,
        )
    }

    private fun alarmPendingIntent(context: Context): PendingIntent {
        val intent = Intent(context, AlarmReceiver::class.java).apply {
            action = AlarmReceiver.ACTION_OUTBOX_ALARM
        }
        return PendingIntent.getBroadcast(
            context,
            ALARM_REQUEST_CODE,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }
}

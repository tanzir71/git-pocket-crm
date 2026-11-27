package com.pocketcrm.pocket_crm.outbox

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ServiceInfo
import android.os.Build
import android.telephony.SmsManager
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import androidx.work.ForegroundInfo
import com.pocketcrm.pocket_crm.MainActivity
import com.pocketcrm.pocket_crm.R

/**
 * Posts Messages-channel notifications directly from Kotlin so they appear
 * reliably even when the Flutter engine is closed.
 */
object OutboxNotifications {

    const val CHANNEL_MESSAGES = "messages"
    const val FG_NOTIFICATION_ID = 7200
    private const val LIMIT_PAUSED_NOTIFICATION_ID = 7201

    fun ensureChannel(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channel = NotificationChannel(
            CHANNEL_MESSAGES,
            "Messages",
            NotificationManager.IMPORTANCE_DEFAULT,
        ).apply {
            description = "Scheduled message status and campaign progress"
        }
        manager.createNotificationChannel(channel)
    }

    private fun canPost(context: Context): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            return ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.POST_NOTIFICATIONS,
            ) == PackageManager.PERMISSION_GRANTED
        }
        return true
    }

    fun buildForegroundInfo(
        context: Context,
        title: String,
        body: String,
        progress: Int = 0,
        max: Int = 0,
    ): ForegroundInfo {
        ensureChannel(context)
        val openIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val pi = PendingIntent.getActivity(
            context,
            FG_NOTIFICATION_ID,
            openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val builder = NotificationCompat.Builder(context, CHANNEL_MESSAGES)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(body)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setContentIntent(pi)
        if (max > 0) {
            builder.setProgress(max, progress.coerceIn(0, max), false)
        }
        val notification = builder.build()
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            ForegroundInfo(
                FG_NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC,
            )
        } else {
            ForegroundInfo(FG_NOTIFICATION_ID, notification)
        }
    }

    fun notifySingleSent(context: Context, clientId: String, recipientLabel: String) {
        if (!canPost(context)) return
        ensureChannel(context)
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val openIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val notifId = notificationIdFor(clientId)
        val contentPi = PendingIntent.getActivity(
            context,
            notifId,
            openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val notification = NotificationCompat.Builder(context, CHANNEL_MESSAGES)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("Sent to $recipientLabel")
            .setAutoCancel(true)
            .setContentIntent(contentPi)
            .build()
        manager.notify(notifId, notification)
    }

    fun notifySingleFailed(
        context: Context,
        clientId: String,
        recipientLabel: String,
        errorCode: Int?,
    ) {
        if (!canPost(context)) return
        ensureChannel(context)
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val notifId = notificationIdFor(clientId)
        val reason = reasonForErrorCode(errorCode)

        val openIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val contentPi = PendingIntent.getActivity(
            context,
            notifId,
            openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val retryIntent = Intent(context, SmsResultReceiver::class.java).apply {
            action = SmsResultReceiver.ACTION_RETRY_MESSAGE
            putExtra(SmsResultReceiver.EXTRA_CLIENT_ID, clientId)
            putExtra(SmsResultReceiver.EXTRA_NOTIFICATION_ID, notifId)
        }
        val retryPi = PendingIntent.getBroadcast(
            context,
            notifId + 1,
            retryIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val notification = NotificationCompat.Builder(context, CHANNEL_MESSAGES)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("Not sent to $recipientLabel. $reason.")
            .setAutoCancel(true)
            .setContentIntent(contentPi)
            .addAction(0, "Retry", retryPi)
            .build()
        manager.notify(notifId, notification)
    }

    fun notifyCampaignLimitPaused(context: Context, campaignName: String?) {
        if (!canPost(context)) return
        ensureChannel(context)
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val openIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val contentPi = PendingIntent.getActivity(
            context,
            LIMIT_PAUSED_NOTIFICATION_ID,
            openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val notification = NotificationCompat.Builder(context, CHANNEL_MESSAGES)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(campaignName ?: "PocketCRM")
            .setContentText("Android paused sending. Resume in a few minutes, or choose a slower pace.")
            .setStyle(
                NotificationCompat.BigTextStyle()
                    .bigText("Android paused sending. Resume in a few minutes, or choose a slower pace."),
            )
            .setAutoCancel(true)
            .setContentIntent(contentPi)
            .build()
        manager.notify(LIMIT_PAUSED_NOTIFICATION_ID, notification)
    }

    fun cancelNotification(context: Context, notifId: Int) {
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.cancel(notifId)
    }

    fun notificationIdFor(clientId: String): Int = 7300 + (clientId.hashCode() and 0x0FFF)

    fun mapErrorKind(resultCode: Int): OutboxStateMachine.SendErrorKind {
        return when (resultCode) {
            SmsManager.RESULT_ERROR_NO_SERVICE -> OutboxStateMachine.SendErrorKind.NO_SERVICE
            SmsManager.RESULT_ERROR_RADIO_OFF -> OutboxStateMachine.SendErrorKind.RADIO_OFF
            SmsManager.RESULT_ERROR_LIMIT_EXCEEDED -> OutboxStateMachine.SendErrorKind.LIMIT_EXCEEDED
            else -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R &&
                    resultCode == SmsManager.RESULT_RADIO_NOT_AVAILABLE
                ) {
                    OutboxStateMachine.SendErrorKind.RADIO_OFF
                } else {
                    OutboxStateMachine.SendErrorKind.OTHER
                }
            }
        }
    }

    fun reasonForErrorCode(errorCode: Int?): String {
        if (errorCode == null) return "Unknown error"
        return when (errorCode) {
            SmsManager.RESULT_ERROR_NO_SERVICE -> "No service"
            SmsManager.RESULT_ERROR_RADIO_OFF -> "Airplane mode or radio off"
            SmsManager.RESULT_ERROR_LIMIT_EXCEEDED -> "Sending limit reached"
            SmsManager.RESULT_ERROR_SHORT_CODE_NOT_ALLOWED,
            SmsManager.RESULT_ERROR_SHORT_CODE_NEVER_ALLOWED,
            -> "Not allowed by the network"
            else -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R &&
                    errorCode == SmsManager.RESULT_RADIO_NOT_AVAILABLE
                ) {
                    "Airplane mode or radio off"
                } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R &&
                    errorCode == SmsManager.RESULT_NETWORK_REJECT
                ) {
                    "Not allowed by the network"
                } else {
                    "Unknown error ($errorCode)"
                }
            }
        }
    }
}

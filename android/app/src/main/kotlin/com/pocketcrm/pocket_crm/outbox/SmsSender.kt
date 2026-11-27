package com.pocketcrm.pocket_crm.outbox

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.telephony.SmsManager
import android.util.Log

/**
 * Dispatches a claimed SMS via Android's [SmsManager] with per-part explicit
 * sent and delivery [PendingIntent]s targeting [SmsResultReceiver].
 */
object SmsSender {

    private const val TAG = "SmsSender"

    fun send(context: Context, db: OutboxDb, msg: OutboxDb.ClaimedMessage) {
        val airplaneModeOn = Settings.Global.getInt(
            context.contentResolver,
            Settings.Global.AIRPLANE_MODE_ON,
            0,
        ) != 0
        if (airplaneModeOn) {
            Log.i(TAG, "Airplane mode ON; recording RADIO_OFF for ${msg.clientId}")
            db.setPartsTotal(msg.clientId, 1)
            SmsResultReceiver.recordSyntheticFailure(
                context = context,
                db = db,
                clientId = msg.clientId,
                errorCode = SmsManager.RESULT_ERROR_RADIO_OFF,
            )
            return
        }

        try {
            val base: SmsManager = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                context.getSystemService(SmsManager::class.java)
            } else {
                @Suppress("DEPRECATION")
                SmsManager.getDefault()
            }
            val manager: SmsManager = when {
                msg.subId == null -> base
                Build.VERSION.SDK_INT >= Build.VERSION_CODES.S ->
                    base.createForSubscriptionId(msg.subId)
                else -> @Suppress("DEPRECATION") SmsManager.getSmsManagerForSubscriptionId(msg.subId)
            }

            val parts: ArrayList<String> = manager.divideMessage(msg.body)
            val totalParts = parts.size.coerceAtLeast(1)
            db.setPartsTotal(msg.clientId, totalParts)

            val sentIntents = ArrayList<PendingIntent>(totalParts)
            val deliveryIntents = ArrayList<PendingIntent>(totalParts)

            for (i in 0 until totalParts) {
                val sentUri = Uri.parse("pocketcrm://sms/${msg.clientId}/$i/sent")
                val sentIntent = Intent(context, SmsResultReceiver::class.java).apply {
                    action = SmsResultReceiver.ACTION_SMS_SENT
                    data = sentUri
                    putExtra(SmsResultReceiver.EXTRA_CLIENT_ID, msg.clientId)
                    putExtra(SmsResultReceiver.EXTRA_PART_INDEX, i)
                }
                sentIntents.add(
                    PendingIntent.getBroadcast(
                        context,
                        0,
                        sentIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                    ),
                )

                val deliveredUri = Uri.parse("pocketcrm://sms/${msg.clientId}/$i/delivered")
                val deliveredIntent = Intent(context, SmsResultReceiver::class.java).apply {
                    action = SmsResultReceiver.ACTION_SMS_DELIVERED
                    data = deliveredUri
                    putExtra(SmsResultReceiver.EXTRA_CLIENT_ID, msg.clientId)
                    putExtra(SmsResultReceiver.EXTRA_PART_INDEX, i)
                }
                deliveryIntents.add(
                    PendingIntent.getBroadcast(
                        context,
                        0,
                        deliveredIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE,
                    ),
                )
            }

            manager.sendMultipartTextMessage(
                msg.address,
                null,
                parts,
                sentIntents,
                deliveryIntents,
            )
        } catch (e: Exception) {
            Log.e(TAG, "Failed to dispatch SMS ${msg.clientId}: ${e.message}", e)
            val seq = db.markFailed(msg.clientId, SmsManager.RESULT_ERROR_GENERIC_FAILURE)
            if (msg.campaignId == null) {
                val label = msg.recipientName?.takeIf { it.isNotBlank() } ?: msg.address
                OutboxNotifications.notifySingleFailed(
                    context,
                    msg.clientId,
                    label,
                    SmsManager.RESULT_ERROR_GENERIC_FAILURE,
                )
            } else {
                db.markCampaignDoneIfFinished(msg.campaignId)
            }
            OutboxApiImpl.notifyChanged(seq)
        }
    }
}

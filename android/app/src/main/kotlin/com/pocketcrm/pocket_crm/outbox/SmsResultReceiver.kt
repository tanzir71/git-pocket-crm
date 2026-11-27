package com.pocketcrm.pocket_crm.outbox

import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.telephony.SmsManager
import android.util.Log

/**
 * Receives per-part SMS sent & delivery callbacks and Retry notification actions.
 * Declared in AndroidManifest with `android:exported="false"`.
 */
class SmsResultReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent?) {
        if (intent == null) return
        val db = OutboxDb.getInstance(context)

        when (intent.action) {
            ACTION_SMS_SENT -> handleSent(context, db, intent)
            ACTION_SMS_DELIVERED -> handleDelivered(db, intent)
            ACTION_RETRY_MESSAGE -> handleRetryAction(context, db, intent)
            ACTION_PAUSE_CAMPAIGN -> {
                val cid = intent.getStringExtra(EXTRA_CAMPAIGN_ID) ?: return
                val seq = db.pauseCampaign(cid)
                OutboxApiImpl.notifyChanged(seq)
                OutboxScheduler.scheduleNext(context)
            }
            ACTION_STOP_CAMPAIGN -> {
                val cid = intent.getStringExtra(EXTRA_CAMPAIGN_ID) ?: return
                val seq = db.stopCampaign(cid)
                OutboxApiImpl.notifyChanged(seq)
                OutboxScheduler.scheduleNext(context)
            }
        }
    }

    private fun handleSent(context: Context, db: OutboxDb, intent: Intent) {
        val clientId = intent.getStringExtra(EXTRA_CLIENT_ID)
            ?: parseClientIdFromUri(intent)
            ?: return
        val ok = resultCode == Activity.RESULT_OK
        val errorCode = if (ok) null else resultCode
        processSentOutcome(context, db, clientId, ok, errorCode)
    }

    private fun handleDelivered(db: OutboxDb, intent: Intent) {
        val clientId = intent.getStringExtra(EXTRA_CLIENT_ID)
            ?: parseClientIdFromUri(intent)
            ?: return
        val seq = db.recordPartDelivered(clientId) ?: return
        OutboxApiImpl.notifyChanged(seq)
    }

    private fun handleRetryAction(context: Context, db: OutboxDb, intent: Intent) {
        val clientId = intent.getStringExtra(EXTRA_CLIENT_ID) ?: return
        val notifId = intent.getIntExtra(EXTRA_NOTIFICATION_ID, -1)
        if (notifId != -1) {
            OutboxNotifications.cancelNotification(context, notifId)
        }
        val seq = db.retry(listOf(clientId))
        OutboxApiImpl.notifyChanged(seq)
        OutboxScheduler.enqueueDrainNow(context)
    }

    private fun parseClientIdFromUri(intent: Intent): String? {
        val segments = intent.data?.pathSegments ?: return null
        return segments.firstOrNull()
    }

    companion object {
        const val ACTION_SMS_SENT = "com.pocketcrm.pocket_crm.outbox.ACTION_SMS_SENT"
        const val ACTION_SMS_DELIVERED = "com.pocketcrm.pocket_crm.outbox.ACTION_SMS_DELIVERED"
        const val ACTION_RETRY_MESSAGE = "com.pocketcrm.pocket_crm.outbox.ACTION_RETRY_MESSAGE"
        const val ACTION_PAUSE_CAMPAIGN = "com.pocketcrm.pocket_crm.outbox.ACTION_PAUSE_CAMPAIGN"
        const val ACTION_STOP_CAMPAIGN = "com.pocketcrm.pocket_crm.outbox.ACTION_STOP_CAMPAIGN"
        const val EXTRA_CLIENT_ID = "client_id"
        const val EXTRA_CAMPAIGN_ID = "campaign_id"
        const val EXTRA_PART_INDEX = "part_index"
        const val EXTRA_NOTIFICATION_ID = "notification_id"
        private const val TAG = "SmsResultReceiver"

        fun recordSyntheticFailure(
            context: Context,
            db: OutboxDb,
            clientId: String,
            errorCode: Int,
        ) {
            processSentOutcome(context, db, clientId, ok = false, errorCode = errorCode)
        }

        private fun processSentOutcome(
            context: Context,
            db: OutboxDb,
            clientId: String,
            ok: Boolean,
            errorCode: Int?,
        ) {
            val res = db.recordPartSent(clientId = clientId, ok = ok, errorCode = errorCode) ?: return
            var latestSeq = res.latestSeq

            if (!res.allPartsReported) {
                OutboxApiImpl.notifyChanged(latestSeq)
                return
            }

            val recipientLabel = res.recipientName?.takeIf { it.isNotBlank() } ?: res.address

            if (res.allSucceeded) {
                if (res.campaignId == null) {
                    OutboxNotifications.notifySingleSent(context, clientId, recipientLabel)
                } else {
                    db.markCampaignDoneIfFinished(res.campaignId)
                }
                OutboxApiImpl.notifyChanged(latestSeq)
                OutboxScheduler.scheduleNext(context)
                return
            }

            val finalErrorCode = res.errorCode ?: SmsManager.RESULT_ERROR_GENERIC_FAILURE
            val errorKind = OutboxNotifications.mapErrorKind(finalErrorCode)
            val decision = OutboxStateMachine.decideAfterFailure(
                errorKind = errorKind,
                attempt = res.attempt,
                nowMs = System.currentTimeMillis(),
                isCampaignMessage = res.campaignId != null,
                windowStartMin = res.windowStartMin,
                windowEndMin = res.windowEndMin,
            )

            if (decision.shouldRetry && decision.nextDueAtMs != null) {
                latestSeq = db.rescheduleTo(
                    clientId = clientId,
                    newDueAtMs = decision.nextDueAtMs,
                    incrementAttempt = true,
                    errorCode = finalErrorCode,
                )
                Log.i(TAG, "Scheduled retry #${res.attempt + 1} for $clientId at ${decision.nextDueAtMs}")
            } else {
                latestSeq = db.markFailed(clientId, finalErrorCode)
                if (decision.shouldPauseCampaign && res.campaignId != null) {
                    latestSeq = db.pauseCampaign(res.campaignId)
                    OutboxNotifications.notifyCampaignLimitPaused(context, res.campaignName)
                } else if (res.campaignId == null) {
                    OutboxNotifications.notifySingleFailed(
                        context,
                        clientId,
                        recipientLabel,
                        finalErrorCode,
                    )
                } else {
                    db.markCampaignDoneIfFinished(res.campaignId)
                }
            }

            OutboxApiImpl.notifyChanged(latestSeq)
            OutboxScheduler.scheduleNext(context)
        }
    }
}

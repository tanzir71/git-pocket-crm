package com.pocketcrm.pocket_crm.outbox

import android.content.Context
import android.util.Log
import androidx.work.CoroutineWorker
import androidx.work.ForegroundInfo
import androidx.work.WorkerParameters
import kotlinx.coroutines.delay

/**
 * Drains due messages from `outbox.db`, enforcing the missed rule, send window,
 * campaign pacing, and foreground-service promotion for long runs.
 */
class OutboxDrainWorker(
    appContext: Context,
    params: WorkerParameters,
) : CoroutineWorker(appContext, params) {

    override suspend fun getForegroundInfo(): ForegroundInfo {
        return OutboxNotifications.buildForegroundInfo(
            context = applicationContext,
            title = "PocketCRM",
            body = "Sending messages",
        )
    }

    override suspend fun doWork(): Result {
        val db = OutboxDb.getInstance(applicationContext)
        var inForeground = false

        try {
            val initialNow = System.currentTimeMillis()
            val needsForeground = db.hasActiveCampaignDue(initialNow) ||
                db.countQueuedDue(initialNow) > 3
            if (needsForeground) {
                inForeground = tryPromoteForeground("PocketCRM", "Sending messages", 0, 0)
            }

            while (!isStopped) {
                val now = System.currentTimeMillis()
                val msg = db.claimNextDue(now) ?: break
                val isCampaign = msg.campaignId != null

                if (OutboxStateMachine.isSingleMessageMissed(msg.dueAtMs, now, isCampaign)) {
                    val seq = db.markMissed(msg.clientId)
                    OutboxApiImpl.notifyChanged(seq)
                    continue
                }

                val adjusted = OutboxStateMachine.adjustToSendWindow(
                    dueAtMs = now,
                    windowStartMin = msg.windowStartMin,
                    windowEndMin = msg.windowEndMin,
                )
                if (adjusted > now) {
                    val seq = db.rescheduleTo(msg.clientId, adjusted)
                    OutboxApiImpl.notifyChanged(seq)
                    continue
                }

                if (isCampaign && !inForeground) {
                    inForeground = tryPromoteForeground(
                        msg.campaignName ?: "PocketCRM",
                        "Sending messages",
                        0,
                        0,
                    )
                }

                val campaignId = msg.campaignId
                if (campaignId != null && inForeground) {
                    val prog = db.getCampaignProgress(campaignId)
                    if (prog != null) {
                        tryPromoteForeground(
                            "${prog.name} · ${prog.finished + 1} of ${prog.total}",
                            "Sending messages",
                            prog.finished,
                            prog.total,
                            campaignId = campaignId,
                        )
                    }
                }

                SmsSender.send(applicationContext, db, msg)

                if (campaignId != null && msg.paceSeconds > 0) {
                    if (db.hasMoreQueuedForCampaign(campaignId, System.currentTimeMillis())) {
                        delay(msg.paceSeconds * 1000L)
                    }
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "OutboxDrainWorker error: ${e.message}", e)
            return Result.retry()
        } finally {
            if (isStopped) {
                val reset = db.resetStuckSending()
                if (reset > 0) {
                    OutboxApiImpl.notifyChanged(db.currentSeq())
                }
            }
            OutboxScheduler.scheduleNext(applicationContext)
        }

        return Result.success()
    }

    private suspend fun tryPromoteForeground(
        title: String,
        body: String,
        progress: Int,
        max: Int,
        campaignId: String? = null,
    ): Boolean {
        return try {
            setForeground(
                OutboxNotifications.buildForegroundInfo(
                    context = applicationContext,
                    title = title,
                    body = body,
                    progress = progress,
                    max = max,
                    campaignId = campaignId,
                ),
            )
            true
        } catch (e: Exception) {
            Log.w(TAG, "Could not promote to foreground service: ${e.message}")
            false
        }
    }

    companion object {
        private const val TAG = "OutboxDrainWorker"
    }
}

package com.pocketcrm.pocket_crm.outbox

import java.time.Instant
import java.time.LocalDate
import java.time.LocalTime
import java.time.ZoneId
import java.time.ZonedDateTime

/**
 * Pure Kotlin state machine & rules for the native SMS outbox.
 * Holds ZERO Android imports so every rule can be verified with plain JUnit.
 */
object OutboxStateMachine {

    const val STATUS_QUEUED = "queued"
    const val STATUS_SENDING = "sending"
    const val STATUS_SENT = "sent"
    const val STATUS_DELIVERED = "delivered"
    const val STATUS_FAILED = "failed"
    const val STATUS_CANCELLED = "cancelled"
    const val STATUS_MISSED = "missed"
    const val STATUS_SKIPPED = "skipped"

    const val CAMPAIGN_SCHEDULED = "scheduled"
    const val CAMPAIGN_SENDING = "sending"
    const val CAMPAIGN_PAUSED = "paused"
    const val CAMPAIGN_DONE = "done"
    const val CAMPAIGN_STOPPED = "stopped"

    const val DEFAULT_WINDOW_START_MIN = 9 * 60  // 09:00
    const val DEFAULT_WINDOW_END_MIN = 21 * 60   // 21:00
    const val SINGLE_MESSAGE_MISSED_AFTER_MS = 30L * 60L * 1000L // 30 minutes
    const val MAX_RETRY_ATTEMPTS = 3

    val RETRY_DELAYS_MS: LongArray = longArrayOf(
        1L * 60L * 1000L,   // attempt 1 -> +1 min
        5L * 60L * 1000L,   // attempt 2 -> +5 min
        15L * 60L * 1000L,  // attempt 3 -> +15 min
    )

    enum class SendErrorKind {
        NONE,
        NO_SERVICE,
        RADIO_OFF,
        LIMIT_EXCEEDED,
        OTHER,
    }

    data class RetryDecision(
        val shouldRetry: Boolean,
        val nextDueAtMs: Long? = null,
        val shouldPauseCampaign: Boolean = false,
    )

    private val allowedTransitions: Map<String, Set<String>> = mapOf(
        STATUS_QUEUED to setOf(STATUS_SENDING, STATUS_CANCELLED, STATUS_MISSED, STATUS_SKIPPED),
        STATUS_SENDING to setOf(STATUS_SENT, STATUS_FAILED, STATUS_QUEUED), // QUEUED allowed on worker stop w/ 0 parts
        STATUS_SENT to setOf(STATUS_DELIVERED),
        STATUS_FAILED to setOf(STATUS_QUEUED),
        STATUS_MISSED to setOf(STATUS_QUEUED),
        STATUS_DELIVERED to emptySet(),
        STATUS_CANCELLED to emptySet(),
        STATUS_SKIPPED to emptySet(),
    )

    fun canTransition(from: String, to: String): Boolean {
        return allowedTransitions[from]?.contains(to) == true
    }

    /**
     * A single (non-campaign) message whose scheduled time passed more than
     * 30 minutes ago becomes `missed` and waits for the user.
     * Campaign messages never become missed automatically.
     */
    fun isSingleMessageMissed(
        dueAtMs: Long,
        nowMs: Long,
        isCampaignMessage: Boolean,
    ): Boolean {
        if (isCampaignMessage) return false
        return (nowMs - dueAtMs) > SINGLE_MESSAGE_MISSED_AFTER_MS
    }

    /**
     * If [dueAtMs] falls inside `[windowStartMin, windowEndMin)` in [zoneId],
     * returns [dueAtMs] unchanged. Otherwise returns the next window opening
     * timestamp (same day if before start, next day if at or after end).
     */
    fun adjustToSendWindow(
        dueAtMs: Long,
        windowStartMin: Int = DEFAULT_WINDOW_START_MIN,
        windowEndMin: Int = DEFAULT_WINDOW_END_MIN,
        zoneId: ZoneId = ZoneId.systemDefault(),
    ): Long {
        if (windowStartMin >= windowEndMin) {
            // Degenerate/disabled window -> send as-is
            return dueAtMs
        }
        val zdt = Instant.ofEpochMilli(dueAtMs).atZone(zoneId)
        val minuteOfDay = zdt.hour * 60 + zdt.minute
        if (minuteOfDay in windowStartMin until windowEndMin) {
            return dueAtMs
        }
        val startHour = windowStartMin / 60
        val startMinute = windowStartMin % 60
        val targetDate: LocalDate = if (minuteOfDay < windowStartMin) {
            zdt.toLocalDate()
        } else {
            zdt.toLocalDate().plusDays(1)
        }
        val nextOpen = ZonedDateTime.of(
            targetDate,
            LocalTime.of(startHour, startMinute, 0),
            zoneId,
        )
        return nextOpen.toInstant().toEpochMilli()
    }

    /**
     * Computes retry & campaign-pause decision after a failed send result.
     * - Only NO_SERVICE and RADIO_OFF retry, up to 3 attempts (1m, 5m, 15m),
     *   clamped into the active send window.
     * - LIMIT_EXCEEDED never retries on its own and pauses the campaign.
     */
    fun decideAfterFailure(
        errorKind: SendErrorKind,
        attempt: Int,
        nowMs: Long,
        isCampaignMessage: Boolean,
        windowStartMin: Int = DEFAULT_WINDOW_START_MIN,
        windowEndMin: Int = DEFAULT_WINDOW_END_MIN,
        zoneId: ZoneId = ZoneId.systemDefault(),
    ): RetryDecision {
        if (errorKind == SendErrorKind.LIMIT_EXCEEDED) {
            return RetryDecision(
                shouldRetry = false,
                nextDueAtMs = null,
                shouldPauseCampaign = isCampaignMessage,
            )
        }

        val retryable = errorKind == SendErrorKind.NO_SERVICE ||
            errorKind == SendErrorKind.RADIO_OFF
        if (!retryable) {
            return RetryDecision(shouldRetry = false)
        }

        if (attempt >= MAX_RETRY_ATTEMPTS) {
            return RetryDecision(shouldRetry = false)
        }

        val delayIdx = attempt.coerceIn(0, RETRY_DELAYS_MS.lastIndex)
        val rawNext = nowMs + RETRY_DELAYS_MS[delayIdx]
        val windowedNext = adjustToSendWindow(
            dueAtMs = rawNext,
            windowStartMin = windowStartMin,
            windowEndMin = windowEndMin,
            zoneId = zoneId,
        )
        return RetryDecision(
            shouldRetry = true,
            nextDueAtMs = windowedNext,
            shouldPauseCampaign = false,
        )
    }

    /**
     * Pure concurrency-safe drain loop over an abstract [DrainStore] so two
     * concurrent drain loops can be verified in JUnit to send every message
     * at most once.
     */
    interface DrainStore {
        fun claimNextDue(nowMs: Long): DrainItem?
    }

    data class DrainItem(
        val clientId: String,
        val campaignId: String?,
        val address: String,
        val body: String,
        val dueAtMs: Long,
        val subId: Int?,
        val windowStartMin: Int,
        val windowEndMin: Int,
    )

    fun drainLoop(
        store: DrainStore,
        nowProvider: () -> Long,
        onMissed: (DrainItem) -> Unit,
        onReschedule: (DrainItem, Long) -> Unit,
        onSend: (DrainItem) -> Unit,
        zoneId: ZoneId = ZoneId.systemDefault(),
    ): Int {
        var processed = 0
        while (true) {
            val nowMs = nowProvider()
            val item = store.claimNextDue(nowMs) ?: break
            val isCampaign = item.campaignId != null

            if (isSingleMessageMissed(item.dueAtMs, nowMs, isCampaign)) {
                onMissed(item)
                processed++
                continue
            }

            val adjusted = adjustToSendWindow(
                dueAtMs = nowMs,
                windowStartMin = item.windowStartMin,
                windowEndMin = item.windowEndMin,
                zoneId = zoneId,
            )
            if (adjusted > nowMs) {
                onReschedule(item, adjusted)
                processed++
                continue
            }

            onSend(item)
            processed++
        }
        return processed
    }
}

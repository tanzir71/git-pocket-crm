package com.pocketcrm.pocket_crm.outbox

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import java.time.LocalDateTime
import java.time.ZoneId
import java.util.Collections
import java.util.concurrent.CountDownLatch
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit

class OutboxStateMachineTest {

    @Test
    fun transitions_allowValidAndRefuseInvalid() {
        assertTrue(OutboxStateMachine.canTransition("queued", "sending"))
        assertTrue(OutboxStateMachine.canTransition("sending", "sent"))
        assertTrue(OutboxStateMachine.canTransition("sending", "failed"))
        assertTrue(OutboxStateMachine.canTransition("sent", "delivered"))
        assertTrue(OutboxStateMachine.canTransition("queued", "cancelled"))
        assertTrue(OutboxStateMachine.canTransition("queued", "missed"))
        assertTrue(OutboxStateMachine.canTransition("queued", "skipped"))
        assertTrue(OutboxStateMachine.canTransition("failed", "queued"))
        assertTrue(OutboxStateMachine.canTransition("missed", "queued"))

        assertFalse(OutboxStateMachine.canTransition("sent", "failed"))
        assertFalse(OutboxStateMachine.canTransition("sent", "queued"))
        assertFalse(OutboxStateMachine.canTransition("delivered", "sent"))
        assertFalse(OutboxStateMachine.canTransition("cancelled", "sending"))
        assertFalse(OutboxStateMachine.canTransition("cancelled", "queued"))
        assertFalse(OutboxStateMachine.canTransition("skipped", "sending"))
        assertFalse(OutboxStateMachine.canTransition("queued", "delivered"))
    }

    @Test
    fun retryPolicy_retriesOnlyNoServiceAndRadioOffWith1m5m15mDelays() {
        val zone = ZoneId.of("UTC")
        val nowMs = LocalDateTime.of(2026, 11, 26, 12, 0)
            .atZone(zone).toInstant().toEpochMilli()

        val r0 = OutboxStateMachine.decideAfterFailure(
            errorKind = OutboxStateMachine.SendErrorKind.NO_SERVICE,
            attempt = 0,
            nowMs = nowMs,
            isCampaignMessage = false,
            zoneId = zone,
        )
        assertTrue(r0.shouldRetry)
        assertEquals(nowMs + 1 * 60_000L, r0.nextDueAtMs)
        assertFalse(r0.shouldPauseCampaign)

        val r1 = OutboxStateMachine.decideAfterFailure(
            errorKind = OutboxStateMachine.SendErrorKind.RADIO_OFF,
            attempt = 1,
            nowMs = nowMs,
            isCampaignMessage = false,
            zoneId = zone,
        )
        assertTrue(r1.shouldRetry)
        assertEquals(nowMs + 5 * 60_000L, r1.nextDueAtMs)

        val r2 = OutboxStateMachine.decideAfterFailure(
            errorKind = OutboxStateMachine.SendErrorKind.NO_SERVICE,
            attempt = 2,
            nowMs = nowMs,
            isCampaignMessage = false,
            zoneId = zone,
        )
        assertTrue(r2.shouldRetry)
        assertEquals(nowMs + 15 * 60_000L, r2.nextDueAtMs)

        // 4th failure (attempt == 3) stops retrying
        val r3 = OutboxStateMachine.decideAfterFailure(
            errorKind = OutboxStateMachine.SendErrorKind.NO_SERVICE,
            attempt = 3,
            nowMs = nowMs,
            isCampaignMessage = false,
            zoneId = zone,
        )
        assertFalse(r3.shouldRetry)

        // Non-retryable error fails immediately
        val rOther = OutboxStateMachine.decideAfterFailure(
            errorKind = OutboxStateMachine.SendErrorKind.OTHER,
            attempt = 0,
            nowMs = nowMs,
            isCampaignMessage = false,
            zoneId = zone,
        )
        assertFalse(rOther.shouldRetry)
    }

    @Test
    fun limitExceeded_pausesCampaignAndDoesNotAutoRetry() {
        val zone = ZoneId.of("UTC")
        val nowMs = LocalDateTime.of(2026, 11, 26, 12, 0)
            .atZone(zone).toInstant().toEpochMilli()

        val decision = OutboxStateMachine.decideAfterFailure(
            errorKind = OutboxStateMachine.SendErrorKind.LIMIT_EXCEEDED,
            attempt = 0,
            nowMs = nowMs,
            isCampaignMessage = true,
            zoneId = zone,
        )
        assertFalse(decision.shouldRetry)
        assertTrue(decision.shouldPauseCampaign)
    }

    @Test
    fun sendWindow_2230ReschedulesTo0900NextDay() {
        val zone = ZoneId.of("UTC")
        val at2230 = LocalDateTime.of(2026, 11, 26, 22, 30)
            .atZone(zone).toInstant().toEpochMilli()
        val expected0900NextDay = LocalDateTime.of(2026, 11, 27, 9, 0)
            .atZone(zone).toInstant().toEpochMilli()

        val adjusted = OutboxStateMachine.adjustToSendWindow(
            dueAtMs = at2230,
            windowStartMin = 9 * 60,
            windowEndMin = 21 * 60,
            zoneId = zone,
        )
        assertEquals(expected0900NextDay, adjusted)

        // 07:15 -> 09:00 same day
        val at0715 = LocalDateTime.of(2026, 11, 26, 7, 15)
            .atZone(zone).toInstant().toEpochMilli()
        val expected0900SameDay = LocalDateTime.of(2026, 11, 26, 9, 0)
            .atZone(zone).toInstant().toEpochMilli()
        assertEquals(
            expected0900SameDay,
            OutboxStateMachine.adjustToSendWindow(at0715, 9 * 60, 21 * 60, zone),
        )

        // 14:00 -> unchanged
        val at1400 = LocalDateTime.of(2026, 11, 26, 14, 0)
            .atZone(zone).toInstant().toEpochMilli()
        assertEquals(
            at1400,
            OutboxStateMachine.adjustToSendWindow(at1400, 9 * 60, 21 * 60, zone),
        )
    }

    @Test
    fun singleMessage31MinutesLate_becomesMissed_campaignDoesNot() {
        val dueAt = 1_000_000_000L
        val now31MinLater = dueAt + 31L * 60L * 1000L
        val now29MinLater = dueAt + 29L * 60L * 1000L

        assertTrue(OutboxStateMachine.isSingleMessageMissed(dueAt, now31MinLater, isCampaignMessage = false))
        assertFalse(OutboxStateMachine.isSingleMessageMissed(dueAt, now29MinLater, isCampaignMessage = false))
        assertFalse(OutboxStateMachine.isSingleMessageMissed(dueAt, now31MinLater, isCampaignMessage = true))
    }

    @Test
    fun twoConcurrentDrainLoops_over50Messages_sendEachExactlyOnce() {
        val zone = ZoneId.of("UTC")
        val nowMs = LocalDateTime.of(2026, 11, 26, 12, 0)
            .atZone(zone).toInstant().toEpochMilli()

        data class FakeRow(val item: OutboxStateMachine.DrainItem, var status: String = "queued")

        val rows = (1..50).map { i ->
            FakeRow(
                OutboxStateMachine.DrainItem(
                    clientId = "msg-$i",
                    campaignId = "camp-1",
                    address = "+14155550100",
                    body = "Hello $i",
                    dueAtMs = nowMs - 1000L,
                    subId = null,
                    windowStartMin = 9 * 60,
                    windowEndMin = 21 * 60,
                ),
            )
        }

        // Atomic synchronized claim matching SQLite `UPDATE ... WHERE status='queued'`
        val store = object : OutboxStateMachine.DrainStore {
            override fun claimNextDue(nowMs: Long): OutboxStateMachine.DrainItem? {
                synchronized(rows) {
                    val row = rows.firstOrNull { it.status == "queued" && it.item.dueAtMs <= nowMs }
                        ?: return null
                    row.status = "sending"
                    return row.item
                }
            }
        }

        val sentIds = Collections.synchronizedList(mutableListOf<String>())
        val startGate = CountDownLatch(1)
        val doneGate = CountDownLatch(2)
        val pool = Executors.newFixedThreadPool(2)

        repeat(2) {
            pool.submit {
                startGate.await()
                OutboxStateMachine.drainLoop(
                    store = store,
                    nowProvider = { nowMs },
                    onMissed = {},
                    onReschedule = { _, _ -> },
                    onSend = { item ->
                        Thread.sleep(1) // encourage interleaving between the two loops
                        sentIds.add(item.clientId)
                    },
                    zoneId = zone,
                )
                doneGate.countDown()
            }
        }

        startGate.countDown()
        assertTrue(doneGate.await(15, TimeUnit.SECONDS))
        pool.shutdownNow()

        assertEquals(50, sentIds.size)
        assertEquals(50, sentIds.toSet().size)
    }
}

package com.pocketcrm.pocket_crm.outbox

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

/**
 * Native-owned SQLite database (`outbox.db`) for the Kotlin SMS send pipeline.
 * Strictly isolated from `pocket_crm.db` (one owner per SQLite file).
 */
class OutboxDb private constructor(context: Context) :
    SQLiteOpenHelper(context.applicationContext, DB_NAME, null, DB_VERSION) {

    data class ClaimedMessage(
        val clientId: String,
        val campaignId: String?,
        val address: String,
        val recipientName: String?,
        val body: String,
        val dueAtMs: Long,
        val subId: Int?,
        val attempt: Int,
        val paceSeconds: Int,
        val windowStartMin: Int,
        val windowEndMin: Int,
        val campaignName: String?,
    )

    data class PartSentResult(
        val clientId: String,
        val campaignId: String?,
        val address: String,
        val recipientName: String?,
        val attempt: Int,
        val allPartsReported: Boolean,
        val allSucceeded: Boolean,
        val errorCode: Int?,
        val windowStartMin: Int,
        val windowEndMin: Int,
        val campaignName: String?,
        val latestSeq: Long,
    )

    data class CampaignProgress(
        val name: String,
        val total: Int,
        val finished: Int,
        val status: String,
    )

    override fun onCreate(db: SQLiteDatabase) {
        db.execSQL(
            """
            CREATE TABLE IF NOT EXISTS messages (
                client_id TEXT PRIMARY KEY,
                campaign_id TEXT,
                address TEXT NOT NULL,
                recipient_name TEXT,
                body TEXT NOT NULL,
                due_at INTEGER NOT NULL,
                sub_id INTEGER,
                status TEXT NOT NULL,
                attempt INTEGER NOT NULL DEFAULT 0,
                parts_total INTEGER NOT NULL DEFAULT 0,
                parts_sent INTEGER NOT NULL DEFAULT 0,
                parts_failed INTEGER NOT NULL DEFAULT 0,
                parts_delivered INTEGER NOT NULL DEFAULT 0,
                error_code INTEGER,
                sent_at INTEGER,
                delivered_at INTEGER,
                seq INTEGER NOT NULL DEFAULT 0
            )
            """.trimIndent(),
        )
        db.execSQL(
            """
            CREATE TABLE IF NOT EXISTS campaigns (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                pace_seconds INTEGER NOT NULL DEFAULT 15,
                window_start_min INTEGER NOT NULL DEFAULT ${OutboxStateMachine.DEFAULT_WINDOW_START_MIN},
                window_end_min INTEGER NOT NULL DEFAULT ${OutboxStateMachine.DEFAULT_WINDOW_END_MIN},
                status TEXT NOT NULL DEFAULT '${OutboxStateMachine.CAMPAIGN_SCHEDULED}',
                seq INTEGER NOT NULL DEFAULT 0
            )
            """.trimIndent(),
        )
        db.execSQL(
            """
            CREATE TABLE IF NOT EXISTS seq_counter (
                id INTEGER PRIMARY KEY CHECK (id = 1),
                val INTEGER NOT NULL DEFAULT 0
            )
            """.trimIndent(),
        )
        db.execSQL("INSERT OR IGNORE INTO seq_counter (id, val) VALUES (1, 0)")
        db.execSQL("CREATE INDEX IF NOT EXISTS idx_outbox_msg_seq ON messages(seq)")
        db.execSQL("CREATE INDEX IF NOT EXISTS idx_outbox_msg_status_due ON messages(status, due_at)")
        db.execSQL("CREATE INDEX IF NOT EXISTS idx_outbox_msg_campaign ON messages(campaign_id)")
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        onCreate(db)
    }

    private fun nextSeq(db: SQLiteDatabase): Long {
        db.execSQL("UPDATE seq_counter SET val = val + 1 WHERE id = 1")
        db.rawQuery("SELECT val FROM seq_counter WHERE id = 1", null).use { c ->
            return if (c.moveToFirst()) c.getLong(0) else 1L
        }
    }

    fun currentSeq(): Long {
        val db = readableDatabase
        db.rawQuery("SELECT val FROM seq_counter WHERE id = 1", null).use { c ->
            return if (c.moveToFirst()) c.getLong(0) else 0L
        }
    }

    /** Idempotent enqueue by `clientId`. */
    fun enqueue(items: List<OutboxItem>): Long {
        if (items.isEmpty()) return currentSeq()
        val db = writableDatabase
        var latest = currentSeq()
        db.beginTransaction()
        try {
            for (item in items) {
                val seq = nextSeq(db)
                val cv = ContentValues().apply {
                    put("client_id", item.clientId)
                    put("campaign_id", item.campaignId)
                    put("address", item.address)
                    put("recipient_name", item.recipientName)
                    put("body", item.body)
                    put("due_at", item.dueAtMs)
                    if (item.subId != null) put("sub_id", item.subId.toInt()) else putNull("sub_id")
                    put("status", OutboxStateMachine.STATUS_QUEUED)
                    put("attempt", 0)
                    put("parts_total", 0)
                    put("parts_sent", 0)
                    put("parts_failed", 0)
                    put("parts_delivered", 0)
                    putNull("error_code")
                    putNull("sent_at")
                    putNull("delivered_at")
                    put("seq", seq)
                }
                val rowId = db.insertWithOnConflict(
                    "messages",
                    null,
                    cv,
                    SQLiteDatabase.CONFLICT_IGNORE,
                )
                if (rowId != -1L) {
                    latest = seq
                }
            }
            db.setTransactionSuccessful()
        } finally {
            db.endTransaction()
        }
        return latest
    }

    fun upsertCampaign(config: CampaignConfig): Long {
        val db = writableDatabase
        var latest = 0L
        db.beginTransaction()
        try {
            val seq = nextSeq(db)
            val cv = ContentValues().apply {
                put("id", config.id)
                put("name", config.name)
                put("pace_seconds", config.paceSeconds.toInt())
                put("window_start_min", config.windowStartMin.toInt())
                put("window_end_min", config.windowEndMin.toInt())
                put("status", config.status)
                put("seq", seq)
            }
            db.insertWithOnConflict("campaigns", null, cv, SQLiteDatabase.CONFLICT_REPLACE)
            latest = seq
            db.setTransactionSuccessful()
        } finally {
            db.endTransaction()
        }
        return latest
    }

    fun cancel(clientIds: List<String>): Long {
        if (clientIds.isEmpty()) return currentSeq()
        val db = writableDatabase
        var latest = currentSeq()
        db.beginTransaction()
        try {
            for (id in clientIds) {
                val seq = nextSeq(db)
                val cv = ContentValues().apply {
                    put("status", OutboxStateMachine.STATUS_CANCELLED)
                    put("seq", seq)
                }
                val updated = db.update(
                    "messages",
                    cv,
                    "client_id = ? AND status IN (?, ?, ?)",
                    arrayOf(
                        id,
                        OutboxStateMachine.STATUS_QUEUED,
                        OutboxStateMachine.STATUS_FAILED,
                        OutboxStateMachine.STATUS_MISSED,
                    ),
                )
                if (updated > 0) latest = seq
            }
            db.setTransactionSuccessful()
        } finally {
            db.endTransaction()
        }
        return latest
    }

    fun retry(clientIds: List<String>, nowMs: Long = System.currentTimeMillis()): Long {
        if (clientIds.isEmpty()) return currentSeq()
        val db = writableDatabase
        var latest = currentSeq()
        db.beginTransaction()
        try {
            for (id in clientIds) {
                val seq = nextSeq(db)
                val cv = ContentValues().apply {
                    put("status", OutboxStateMachine.STATUS_QUEUED)
                    put("due_at", nowMs)
                    put("attempt", 0)
                    put("parts_total", 0)
                    put("parts_sent", 0)
                    put("parts_failed", 0)
                    put("parts_delivered", 0)
                    putNull("error_code")
                    put("seq", seq)
                }
                val updated = db.update(
                    "messages",
                    cv,
                    "client_id = ? AND status IN (?, ?)",
                    arrayOf(id, OutboxStateMachine.STATUS_FAILED, OutboxStateMachine.STATUS_MISSED),
                )
                if (updated > 0) latest = seq
            }
            db.setTransactionSuccessful()
        } finally {
            db.endTransaction()
        }
        return latest
    }

    fun pauseCampaign(campaignId: String): Long = updateCampaignStatus(campaignId, OutboxStateMachine.CAMPAIGN_PAUSED)

    fun resumeCampaign(campaignId: String): Long = updateCampaignStatus(campaignId, OutboxStateMachine.CAMPAIGN_SENDING)

    fun stopCampaign(campaignId: String): Long {
        val db = writableDatabase
        var latest = currentSeq()
        db.beginTransaction()
        try {
            val cSeq = nextSeq(db)
            val cCv = ContentValues().apply {
                put("status", OutboxStateMachine.CAMPAIGN_STOPPED)
                put("seq", cSeq)
            }
            db.update("campaigns", cCv, "id = ?", arrayOf(campaignId))

            val mSeq = nextSeq(db)
            val mCv = ContentValues().apply {
                put("status", OutboxStateMachine.STATUS_CANCELLED)
                put("seq", mSeq)
            }
            db.update(
                "messages",
                mCv,
                "campaign_id = ? AND status = ?",
                arrayOf(campaignId, OutboxStateMachine.STATUS_QUEUED),
            )
            latest = mSeq
            db.setTransactionSuccessful()
        } finally {
            db.endTransaction()
        }
        return latest
    }

    private fun updateCampaignStatus(campaignId: String, status: String): Long {
        val db = writableDatabase
        var latest = currentSeq()
        db.beginTransaction()
        try {
            val seq = nextSeq(db)
            val cv = ContentValues().apply {
                put("status", status)
                put("seq", seq)
            }
            db.update("campaigns", cv, "id = ?", arrayOf(campaignId))
            latest = seq
            db.setTransactionSuccessful()
        } finally {
            db.endTransaction()
        }
        return latest
    }

    fun changesSince(sinceSeq: Long): ChangeSet {
        val db = readableDatabase
        val items = mutableListOf<OutboxItem>()
        val latest = currentSeq()
        db.rawQuery(
            """
            SELECT client_id, campaign_id, address, recipient_name, body, due_at, sub_id,
                   status, attempt, parts_total, parts_sent, parts_failed, parts_delivered,
                   error_code, sent_at, delivered_at, seq
            FROM messages
            WHERE seq > ?
            ORDER BY seq ASC
            """.trimIndent(),
            arrayOf(sinceSeq.toString()),
        ).use { c ->
            while (c.moveToNext()) {
                items.add(
                    OutboxItem(
                        clientId = c.getString(0),
                        campaignId = if (c.isNull(1)) null else c.getString(1),
                        address = c.getString(2),
                        recipientName = if (c.isNull(3)) null else c.getString(3),
                        body = c.getString(4),
                        dueAtMs = c.getLong(5),
                        subId = if (c.isNull(6)) null else c.getLong(6),
                        status = c.getString(7),
                        attempt = c.getLong(8),
                        partsTotal = c.getLong(9),
                        partsSent = c.getLong(10),
                        partsFailed = c.getLong(11),
                        partsDelivered = c.getLong(12),
                        errorCode = if (c.isNull(13)) null else c.getLong(13),
                        sentAtMs = if (c.isNull(14)) null else c.getLong(14),
                        deliveredAtMs = if (c.isNull(15)) null else c.getLong(15),
                        seq = c.getLong(16),
                    ),
                )
            }
        }
        return ChangeSet(items = items, latestSeq = latest)
    }

    /**
     * Earliest due timestamp among `queued` messages whose campaign (if any) is
     * neither paused nor stopped.
     */
    fun earliestQueuedDueAt(): Long? {
        val db = readableDatabase
        db.rawQuery(
            """
            SELECT MIN(m.due_at)
            FROM messages m
            LEFT JOIN campaigns c ON c.id = m.campaign_id
            WHERE m.status = ?
              AND (m.campaign_id IS NULL OR COALESCE(c.status, '') NOT IN (?, ?))
            """.trimIndent(),
            arrayOf(
                OutboxStateMachine.STATUS_QUEUED,
                OutboxStateMachine.CAMPAIGN_PAUSED,
                OutboxStateMachine.CAMPAIGN_STOPPED,
            ),
        ).use { c ->
            return if (c.moveToFirst() && !c.isNull(0)) c.getLong(0) else null
        }
    }

    fun countQueuedDue(nowMs: Long): Int {
        val db = readableDatabase
        db.rawQuery(
            """
            SELECT COUNT(*)
            FROM messages m
            LEFT JOIN campaigns c ON c.id = m.campaign_id
            WHERE m.status = ?
              AND m.due_at <= ?
              AND (m.campaign_id IS NULL OR COALESCE(c.status, '') NOT IN (?, ?))
            """.trimIndent(),
            arrayOf(
                OutboxStateMachine.STATUS_QUEUED,
                nowMs.toString(),
                OutboxStateMachine.CAMPAIGN_PAUSED,
                OutboxStateMachine.CAMPAIGN_STOPPED,
            ),
        ).use { c ->
            return if (c.moveToFirst()) c.getInt(0) else 0
        }
    }

    fun hasActiveCampaignDue(nowMs: Long): Boolean {
        val db = readableDatabase
        db.rawQuery(
            """
            SELECT 1
            FROM messages m
            JOIN campaigns c ON c.id = m.campaign_id
            WHERE m.status = ?
              AND m.due_at <= ?
              AND c.status NOT IN (?, ?)
            LIMIT 1
            """.trimIndent(),
            arrayOf(
                OutboxStateMachine.STATUS_QUEUED,
                nowMs.toString(),
                OutboxStateMachine.CAMPAIGN_PAUSED,
                OutboxStateMachine.CAMPAIGN_STOPPED,
            ),
        ).use { c ->
            return c.moveToFirst()
        }
    }

    fun hasMoreQueuedForCampaign(campaignId: String, nowMs: Long): Boolean {
        val db = readableDatabase
        db.rawQuery(
            """
            SELECT 1
            FROM messages m
            JOIN campaigns c ON c.id = m.campaign_id
            WHERE m.campaign_id = ?
              AND m.status = ?
              AND m.due_at <= ?
              AND c.status NOT IN (?, ?)
            LIMIT 1
            """.trimIndent(),
            arrayOf(
                campaignId,
                OutboxStateMachine.STATUS_QUEUED,
                nowMs.toString(),
                OutboxStateMachine.CAMPAIGN_PAUSED,
                OutboxStateMachine.CAMPAIGN_STOPPED,
            ),
        ).use { c ->
            return c.moveToFirst()
        }
    }

    /**
     * Atomically claims the earliest due `queued` message by updating
     * `WHERE client_id = ? AND status = 'queued'` and returning it only if
     * exactly 1 row was updated.
     */
    fun claimNextDue(nowMs: Long): ClaimedMessage? {
        val db = writableDatabase
        db.beginTransaction()
        try {
            var candidate: ClaimedMessage? = null
            db.rawQuery(
                """
                SELECT m.client_id, m.campaign_id, m.address, m.recipient_name, m.body,
                       m.due_at, m.sub_id, m.attempt,
                       COALESCE(c.pace_seconds, 0),
                       COALESCE(c.window_start_min, ${OutboxStateMachine.DEFAULT_WINDOW_START_MIN}),
                       COALESCE(c.window_end_min, ${OutboxStateMachine.DEFAULT_WINDOW_END_MIN}),
                       c.name
                FROM messages m
                LEFT JOIN campaigns c ON c.id = m.campaign_id
                WHERE m.status = ?
                  AND m.due_at <= ?
                  AND (m.campaign_id IS NULL OR COALESCE(c.status, '') NOT IN (?, ?))
                ORDER BY m.due_at ASC, m.seq ASC
                LIMIT 1
                """.trimIndent(),
                arrayOf(
                    OutboxStateMachine.STATUS_QUEUED,
                    nowMs.toString(),
                    OutboxStateMachine.CAMPAIGN_PAUSED,
                    OutboxStateMachine.CAMPAIGN_STOPPED,
                ),
            ).use { c ->
                if (c.moveToFirst()) {
                    candidate = ClaimedMessage(
                        clientId = c.getString(0),
                        campaignId = if (c.isNull(1)) null else c.getString(1),
                        address = c.getString(2),
                        recipientName = if (c.isNull(3)) null else c.getString(3),
                        body = c.getString(4),
                        dueAtMs = c.getLong(5),
                        subId = if (c.isNull(6)) null else c.getInt(6),
                        attempt = c.getInt(7),
                        paceSeconds = c.getInt(8),
                        windowStartMin = c.getInt(9),
                        windowEndMin = c.getInt(10),
                        campaignName = if (c.isNull(11)) null else c.getString(11),
                    )
                }
            }

            val chosen = candidate ?: return null
            val seq = nextSeq(db)
            val cv = ContentValues().apply {
                put("status", OutboxStateMachine.STATUS_SENDING)
                put("parts_total", 0)
                put("parts_sent", 0)
                put("parts_failed", 0)
                put("parts_delivered", 0)
                put("seq", seq)
            }
            val changed = db.update(
                "messages",
                cv,
                "client_id = ? AND status = ?",
                arrayOf(chosen.clientId, OutboxStateMachine.STATUS_QUEUED),
            )
            if (changed != 1) return null

            if (chosen.campaignId != null) {
                val campCv = ContentValues().apply {
                    put("status", OutboxStateMachine.CAMPAIGN_SENDING)
                    put("seq", seq)
                }
                db.update(
                    "campaigns",
                    campCv,
                    "id = ? AND status = ?",
                    arrayOf(chosen.campaignId, OutboxStateMachine.CAMPAIGN_SCHEDULED),
                )
            }

            db.setTransactionSuccessful()
            return chosen
        } finally {
            db.endTransaction()
        }
    }

    fun setPartsTotal(clientId: String, partsTotal: Int) {
        val db = writableDatabase
        val cv = ContentValues().apply {
            put("parts_total", partsTotal)
        }
        db.update("messages", cv, "client_id = ?", arrayOf(clientId))
    }

    fun markMissed(clientId: String): Long {
        val db = writableDatabase
        var seq = currentSeq()
        db.beginTransaction()
        try {
            seq = nextSeq(db)
            val cv = ContentValues().apply {
                put("status", OutboxStateMachine.STATUS_MISSED)
                put("seq", seq)
            }
            db.update("messages", cv, "client_id = ?", arrayOf(clientId))
            db.setTransactionSuccessful()
        } finally {
            db.endTransaction()
        }
        return seq
    }

    fun markOverdueSingleMessagesMissed(nowMs: Long = System.currentTimeMillis()): Int {
        val cutoff = nowMs - OutboxStateMachine.SINGLE_MESSAGE_MISSED_AFTER_MS
        val db = writableDatabase
        var count = 0
        db.beginTransaction()
        try {
            val ids = mutableListOf<String>()
            db.rawQuery(
                "SELECT client_id FROM messages WHERE status = ? AND campaign_id IS NULL AND due_at < ?",
                arrayOf(OutboxStateMachine.STATUS_QUEUED, cutoff.toString()),
            ).use { c ->
                while (c.moveToNext()) ids.add(c.getString(0))
            }
            for (id in ids) {
                val seq = nextSeq(db)
                val cv = ContentValues().apply {
                    put("status", OutboxStateMachine.STATUS_MISSED)
                    put("seq", seq)
                }
                count += db.update("messages", cv, "client_id = ?", arrayOf(id))
            }
            db.setTransactionSuccessful()
        } finally {
            db.endTransaction()
        }
        return count
    }

    fun rescheduleTo(
        clientId: String,
        newDueAtMs: Long,
        incrementAttempt: Boolean = false,
        errorCode: Int? = null,
    ): Long {
        val db = writableDatabase
        var seq = currentSeq()
        db.beginTransaction()
        try {
            seq = nextSeq(db)
            if (incrementAttempt) {
                db.execSQL(
                    """
                    UPDATE messages
                    SET status = ?, due_at = ?, attempt = attempt + 1,
                        parts_total = 0, parts_sent = 0, parts_failed = 0, parts_delivered = 0,
                        error_code = ?, seq = ?
                    WHERE client_id = ?
                    """.trimIndent(),
                    arrayOf<Any?>(
                        OutboxStateMachine.STATUS_QUEUED,
                        newDueAtMs,
                        errorCode,
                        seq,
                        clientId,
                    ),
                )
            } else {
                val cv = ContentValues().apply {
                    put("status", OutboxStateMachine.STATUS_QUEUED)
                    put("due_at", newDueAtMs)
                    put("parts_total", 0)
                    put("parts_sent", 0)
                    put("parts_failed", 0)
                    put("parts_delivered", 0)
                    put("seq", seq)
                }
                db.update("messages", cv, "client_id = ?", arrayOf(clientId))
            }
            db.setTransactionSuccessful()
        } finally {
            db.endTransaction()
        }
        return seq
    }

    fun markFailed(clientId: String, errorCode: Int?): Long {
        val db = writableDatabase
        var seq = currentSeq()
        db.beginTransaction()
        try {
            seq = nextSeq(db)
            val cv = ContentValues().apply {
                put("status", OutboxStateMachine.STATUS_FAILED)
                if (errorCode != null) put("error_code", errorCode) else putNull("error_code")
                put("seq", seq)
            }
            db.update("messages", cv, "client_id = ?", arrayOf(clientId))
            db.setTransactionSuccessful()
        } finally {
            db.endTransaction()
        }
        return seq
    }

    /**
     * Called on worker stop: returns any `sending` message with zero parts
     * reported back to `queued` so it will be picked up on the next drain.
     */
    fun resetStuckSending(): Int {
        val db = writableDatabase
        var count = 0
        db.beginTransaction()
        try {
            val ids = mutableListOf<String>()
            db.rawQuery(
                "SELECT client_id FROM messages WHERE status = ? AND parts_sent = 0 AND parts_failed = 0",
                arrayOf(OutboxStateMachine.STATUS_SENDING),
            ).use { c ->
                while (c.moveToNext()) ids.add(c.getString(0))
            }
            for (id in ids) {
                val seq = nextSeq(db)
                val cv = ContentValues().apply {
                    put("status", OutboxStateMachine.STATUS_QUEUED)
                    put("seq", seq)
                }
                count += db.update("messages", cv, "client_id = ?", arrayOf(id))
            }
            db.setTransactionSuccessful()
        } finally {
            db.endTransaction()
        }
        return count
    }

    fun recordPartSent(
        clientId: String,
        ok: Boolean,
        errorCode: Int?,
        nowMs: Long = System.currentTimeMillis(),
    ): PartSentResult? {
        val db = writableDatabase
        db.beginTransaction()
        try {
            var campaignId: String? = null
            var address = ""
            var recipientName: String? = null
            var attempt = 0
            var partsTotal = 1
            var partsSent = 0
            var partsFailed = 0
            var storedErrorCode: Int? = null
            var windowStartMin = OutboxStateMachine.DEFAULT_WINDOW_START_MIN
            var windowEndMin = OutboxStateMachine.DEFAULT_WINDOW_END_MIN
            var campaignName: String? = null

            db.rawQuery(
                """
                SELECT m.campaign_id, m.address, m.recipient_name, m.attempt,
                       m.parts_total, m.parts_sent, m.parts_failed, m.error_code,
                       COALESCE(c.window_start_min, ${OutboxStateMachine.DEFAULT_WINDOW_START_MIN}),
                       COALESCE(c.window_end_min, ${OutboxStateMachine.DEFAULT_WINDOW_END_MIN}),
                       c.name
                FROM messages m
                LEFT JOIN campaigns c ON c.id = m.campaign_id
                WHERE m.client_id = ?
                """.trimIndent(),
                arrayOf(clientId),
            ).use { c ->
                if (!c.moveToFirst()) return null
                campaignId = if (c.isNull(0)) null else c.getString(0)
                address = c.getString(1)
                recipientName = if (c.isNull(2)) null else c.getString(2)
                attempt = c.getInt(3)
                partsTotal = c.getInt(4).coerceAtLeast(1)
                partsSent = c.getInt(5)
                partsFailed = c.getInt(6)
                storedErrorCode = if (c.isNull(7)) null else c.getInt(7)
                windowStartMin = c.getInt(8)
                windowEndMin = c.getInt(9)
                campaignName = if (c.isNull(10)) null else c.getString(10)
            }

            if (ok) {
                partsSent++
            } else {
                partsFailed++
                if (errorCode != null) storedErrorCode = errorCode
            }

            val allReported = (partsSent + partsFailed) >= partsTotal
            val allSucceeded = allReported && partsFailed == 0
            val seq = nextSeq(db)

            val cv = ContentValues().apply {
                put("parts_sent", partsSent)
                put("parts_failed", partsFailed)
                if (storedErrorCode != null) put("error_code", storedErrorCode)
                put("seq", seq)
                if (allSucceeded) {
                    put("status", OutboxStateMachine.STATUS_SENT)
                    put("sent_at", nowMs)
                }
            }
            db.update("messages", cv, "client_id = ?", arrayOf(clientId))
            db.setTransactionSuccessful()

            return PartSentResult(
                clientId = clientId,
                campaignId = campaignId,
                address = address,
                recipientName = recipientName,
                attempt = attempt,
                allPartsReported = allReported,
                allSucceeded = allSucceeded,
                errorCode = storedErrorCode,
                windowStartMin = windowStartMin,
                windowEndMin = windowEndMin,
                campaignName = campaignName,
                latestSeq = seq,
            )
        } finally {
            db.endTransaction()
        }
    }

    fun recordPartDelivered(
        clientId: String,
        nowMs: Long = System.currentTimeMillis(),
    ): Long? {
        val db = writableDatabase
        db.beginTransaction()
        try {
            var status = ""
            var partsTotal = 1
            var partsDelivered = 0
            db.rawQuery(
                "SELECT status, parts_total, parts_delivered FROM messages WHERE client_id = ?",
                arrayOf(clientId),
            ).use { c ->
                if (!c.moveToFirst()) return null
                status = c.getString(0)
                partsTotal = c.getInt(1).coerceAtLeast(1)
                partsDelivered = c.getInt(2)
            }
            partsDelivered++
            val seq = nextSeq(db)
            val cv = ContentValues().apply {
                put("parts_delivered", partsDelivered)
                put("seq", seq)
                if (partsDelivered >= partsTotal && status == OutboxStateMachine.STATUS_SENT) {
                    put("status", OutboxStateMachine.STATUS_DELIVERED)
                    put("delivered_at", nowMs)
                }
            }
            db.update("messages", cv, "client_id = ?", arrayOf(clientId))
            db.setTransactionSuccessful()
            return seq
        } finally {
            db.endTransaction()
        }
    }

    fun getCampaignProgress(campaignId: String): CampaignProgress? {
        val db = readableDatabase
        var name = ""
        var status = ""
        db.rawQuery("SELECT name, status FROM campaigns WHERE id = ?", arrayOf(campaignId)).use { c ->
            if (!c.moveToFirst()) return null
            name = c.getString(0)
            status = c.getString(1)
        }
        var total = 0
        var finished = 0
        db.rawQuery(
            """
            SELECT COUNT(*),
                   SUM(CASE WHEN status IN ('sent', 'delivered', 'failed', 'cancelled', 'skipped') THEN 1 ELSE 0 END)
            FROM messages
            WHERE campaign_id = ?
            """.trimIndent(),
            arrayOf(campaignId),
        ).use { c ->
            if (c.moveToFirst()) {
                total = c.getInt(0)
                finished = c.getInt(1)
            }
        }
        return CampaignProgress(name = name, total = total, finished = finished, status = status)
    }

    fun markCampaignDoneIfFinished(campaignId: String) {
        val db = writableDatabase
        db.beginTransaction()
        try {
            var remaining = 0
            db.rawQuery(
                "SELECT COUNT(*) FROM messages WHERE campaign_id = ? AND status IN (?, ?)",
                arrayOf(
                    campaignId,
                    OutboxStateMachine.STATUS_QUEUED,
                    OutboxStateMachine.STATUS_SENDING,
                ),
            ).use { c ->
                if (c.moveToFirst()) remaining = c.getInt(0)
            }
            if (remaining == 0) {
                val seq = nextSeq(db)
                val cv = ContentValues().apply {
                    put("status", OutboxStateMachine.CAMPAIGN_DONE)
                    put("seq", seq)
                }
                db.update(
                    "campaigns",
                    cv,
                    "id = ? AND status IN (?, ?)",
                    arrayOf(
                        campaignId,
                        OutboxStateMachine.CAMPAIGN_SCHEDULED,
                        OutboxStateMachine.CAMPAIGN_SENDING,
                    ),
                )
            }
            db.setTransactionSuccessful()
        } finally {
            db.endTransaction()
        }
    }

    companion object {
        const val DB_NAME = "outbox.db"
        private const val DB_VERSION = 1

        @Volatile
        private var instance: OutboxDb? = null

        fun getInstance(context: Context): OutboxDb {
            return instance ?: synchronized(this) {
                instance ?: OutboxDb(context.applicationContext).also { instance = it }
            }
        }
    }
}

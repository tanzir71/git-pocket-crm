package com.pocketcrm.pocket_crm

import android.Manifest
import android.content.ContentResolver
import android.content.Context
import android.content.pm.PackageManager
import android.database.ContentObserver
import android.database.Cursor
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.CancellationSignal
import android.os.Handler
import android.os.Looper
import android.provider.CallLog
import android.provider.Telephony
import android.telephony.TelephonyManager
import android.util.Log
import androidx.core.content.ContextCompat
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.withContext
import kotlinx.coroutines.withTimeoutOrNull
import kotlin.coroutines.resume

class DeviceApiImpl(
    private val context: Context,
    private val events: DeviceEvents,
) : DeviceApi {

    private val mainHandler = Handler(Looper.getMainLooper())
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)

    private var callsObserver: ContentObserver? = null
    private var smsObserver: ContentObserver? = null
    private var pendingCallsRunnable: Runnable? = null
    private var pendingSmsRunnable: Runnable? = null

    override suspend fun readCalls(afterId: Long, limit: Long): List<CallRecord> =
        withContext(Dispatchers.IO) {
            val safeLimit = limit.coerceIn(1L, 2000L).toInt()
            val projection = arrayOf(
                CallLog.Calls._ID,
                CallLog.Calls.NUMBER,
                CallLog.Calls.TYPE,
                CallLog.Calls.DATE,
                CallLog.Calls.DURATION,
            )
            val result = ArrayList<CallRecord>()
            try {
                queryBatched(
                    uri = CallLog.Calls.CONTENT_URI,
                    projection = projection,
                    afterId = afterId,
                    limit = safeLimit,
                )?.use { cursor ->
                    val idIdx = cursor.getColumnIndex(CallLog.Calls._ID)
                    val numIdx = cursor.getColumnIndex(CallLog.Calls.NUMBER)
                    val typeIdx = cursor.getColumnIndex(CallLog.Calls.TYPE)
                    val dateIdx = cursor.getColumnIndex(CallLog.Calls.DATE)
                    val durIdx = cursor.getColumnIndex(CallLog.Calls.DURATION)
                    while (cursor.moveToNext() && result.size < safeLimit) {
                        val id = if (idIdx >= 0) cursor.getLong(idIdx) else continue
                        val number = if (numIdx >= 0) cursor.getString(numIdx) ?: "" else ""
                        val rawType = if (typeIdx >= 0) cursor.getInt(typeIdx) else CallLog.Calls.INCOMING_TYPE
                        val typeStr = when (rawType) {
                            CallLog.Calls.OUTGOING_TYPE -> "outgoing"
                            CallLog.Calls.MISSED_TYPE,
                            CallLog.Calls.REJECTED_TYPE,
                            -> "missed"
                            else -> "incoming"
                        }
                        val dateMs = if (dateIdx >= 0) cursor.getLong(dateIdx) else 0L
                        val duration = if (durIdx >= 0) cursor.getLong(durIdx) else 0L
                        result.add(
                            CallRecord(
                                id = id,
                                number = number,
                                type = typeStr,
                                dateMs = dateMs,
                                durationSeconds = duration,
                            )
                        )
                    }
                }
            } catch (se: SecurityException) {
                Log.w(TAG, "Missing READ_CALL_LOG permission: ${se.message}")
            } catch (e: Exception) {
                Log.e(TAG, "Error reading call log", e)
            }
            result
        }

    override suspend fun readSms(afterId: Long, limit: Long): List<SmsRecord> =
        withContext(Dispatchers.IO) {
            val safeLimit = limit.coerceIn(1L, 2000L).toInt()
            val projection = arrayOf(
                Telephony.Sms._ID,
                Telephony.Sms.ADDRESS,
                Telephony.Sms.BODY,
                Telephony.Sms.DATE,
                Telephony.Sms.TYPE,
                Telephony.Sms.SUBSCRIPTION_ID,
            )
            val result = ArrayList<SmsRecord>()
            try {
                queryBatched(
                    uri = Telephony.Sms.CONTENT_URI,
                    projection = projection,
                    afterId = afterId,
                    limit = safeLimit,
                )?.use { cursor ->
                    val idIdx = cursor.getColumnIndex(Telephony.Sms._ID)
                    val addrIdx = cursor.getColumnIndex(Telephony.Sms.ADDRESS)
                    val bodyIdx = cursor.getColumnIndex(Telephony.Sms.BODY)
                    val dateIdx = cursor.getColumnIndex(Telephony.Sms.DATE)
                    val typeIdx = cursor.getColumnIndex(Telephony.Sms.TYPE)
                    val subIdx = cursor.getColumnIndex(Telephony.Sms.SUBSCRIPTION_ID)
                    while (cursor.moveToNext() && result.size < safeLimit) {
                        val id = if (idIdx >= 0) cursor.getLong(idIdx) else continue
                        val rawType = if (typeIdx >= 0) cursor.getInt(typeIdx) else Telephony.Sms.MESSAGE_TYPE_INBOX
                        // Keep only inbox (1) and sent (2)
                        val box = when (rawType) {
                            Telephony.Sms.MESSAGE_TYPE_INBOX -> "inbox"
                            Telephony.Sms.MESSAGE_TYPE_SENT -> "sent"
                            else -> continue
                        }
                        val address = if (addrIdx >= 0) cursor.getString(addrIdx) ?: "" else ""
                        val body = if (bodyIdx >= 0) cursor.getString(bodyIdx) ?: "" else ""
                        val dateMs = if (dateIdx >= 0) cursor.getLong(dateIdx) else 0L
                        val subId = if (subIdx >= 0 && !cursor.isNull(subIdx)) {
                            cursor.getLong(subIdx)
                        } else {
                            null
                        }
                        result.add(
                            SmsRecord(
                                id = id,
                                address = address,
                                body = body,
                                dateMs = dateMs,
                                box = box,
                                subId = subId,
                            )
                        )
                    }
                }
            } catch (se: SecurityException) {
                Log.w(TAG, "Missing READ_SMS permission: ${se.message}")
            } catch (e: Exception) {
                Log.e(TAG, "Error reading SMS", e)
            }
            result
        }

    private fun queryBatched(
        uri: Uri,
        projection: Array<String>,
        afterId: Long,
        limit: Int,
    ): Cursor? {
        val resolver = context.contentResolver
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val args = Bundle().apply {
                putString(ContentResolver.QUERY_ARG_SQL_SELECTION, "_id > ?")
                putStringArray(ContentResolver.QUERY_ARG_SQL_SELECTION_ARGS, arrayOf(afterId.toString()))
                putString(ContentResolver.QUERY_ARG_SQL_SORT_ORDER, "_id ASC")
                putInt(ContentResolver.QUERY_ARG_LIMIT, limit)
            }
            resolver.query(uri, projection, args, null)
        } else {
            resolver.query(
                uri,
                projection,
                "_id > ?",
                arrayOf(afterId.toString()),
                "_id ASC",
            )
        }
    }

    override fun simCountryIso(): String? {
        return try {
            val tm = context.getSystemService(Context.TELEPHONY_SERVICE) as? TelephonyManager
            val iso = tm?.simCountryIso?.takeIf { it.length == 2 }
                ?: tm?.networkCountryIso?.takeIf { it.length == 2 }
            iso?.uppercase()
        } catch (_: Exception) {
            null
        }
    }

    override fun startObserving() {
        stopObserving()
        val resolver = context.contentResolver
        try {
            val cObs = object : ContentObserver(mainHandler) {
                override fun onChange(selfChange: Boolean) {
                    scheduleDebouncedEvent("calls")
                }
            }
            resolver.registerContentObserver(CallLog.Calls.CONTENT_URI, true, cObs)
            callsObserver = cObs
        } catch (e: Exception) {
            Log.w(TAG, "Could not observe CallLog: ${e.message}")
        }

        try {
            val sObs = object : ContentObserver(mainHandler) {
                override fun onChange(selfChange: Boolean) {
                    scheduleDebouncedEvent("sms")
                }
            }
            resolver.registerContentObserver(Telephony.Sms.CONTENT_URI, true, sObs)
            smsObserver = sObs
        } catch (e: Exception) {
            Log.w(TAG, "Could not observe SMS: ${e.message}")
        }
    }

    override fun stopObserving() {
        val resolver = context.contentResolver
        callsObserver?.let {
            try {
                resolver.unregisterContentObserver(it)
            } catch (_: Exception) {
            }
        }
        callsObserver = null

        smsObserver?.let {
            try {
                resolver.unregisterContentObserver(it)
            } catch (_: Exception) {
            }
        }
        smsObserver = null

        pendingCallsRunnable?.let { mainHandler.removeCallbacks(it) }
        pendingCallsRunnable = null
        pendingSmsRunnable?.let { mainHandler.removeCallbacks(it) }
        pendingSmsRunnable = null
    }

    override suspend fun currentLocation(): LocationPoint? = withContext(Dispatchers.Main) {
        val hasCoarse = ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.ACCESS_COARSE_LOCATION,
        ) == PackageManager.PERMISSION_GRANTED
        val hasFine = ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.ACCESS_FINE_LOCATION,
        ) == PackageManager.PERMISSION_GRANTED
        if (!hasCoarse && !hasFine) return@withContext null

        val lm = context.getSystemService(Context.LOCATION_SERVICE) as? LocationManager
            ?: return@withContext null

        val provider = when {
            lm.isProviderEnabled(LocationManager.NETWORK_PROVIDER) -> LocationManager.NETWORK_PROVIDER
            lm.isProviderEnabled(LocationManager.GPS_PROVIDER) -> LocationManager.GPS_PROVIDER
            else -> LocationManager.PASSIVE_PROVIDER
        }

        // Try a fresh fix within 5 seconds, falling back to lastKnownLocation
        val fresh = withTimeoutOrNull(5_000L) {
            suspendCancellableCoroutine<Location?> { cont ->
                try {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                        val signal = CancellationSignal()
                        cont.invokeOnCancellation { signal.cancel() }
                        lm.getCurrentLocation(
                            provider,
                            signal,
                            context.mainExecutor,
                        ) { loc ->
                            if (cont.isActive) cont.resume(loc)
                        }
                    } else {
                        val listener = object : LocationListener {
                            override fun onLocationChanged(location: Location) {
                                lm.removeUpdates(this)
                                if (cont.isActive) cont.resume(location)
                            }
                            @Deprecated("Deprecated in API 29")
                            override fun onStatusChanged(p: String?, s: Int, e: Bundle?) {}
                            override fun onProviderEnabled(p: String) {}
                            override fun onProviderDisabled(p: String) {}
                        }
                        cont.invokeOnCancellation { lm.removeUpdates(listener) }
                        @Suppress("DEPRECATION")
                        lm.requestSingleUpdate(provider, listener, Looper.getMainLooper())
                    }
                } catch (e: Exception) {
                    Log.w(TAG, "currentLocation error: ${e.message}")
                    if (cont.isActive) cont.resume(null)
                }
            }
        }

        val loc = fresh ?: try {
            lm.getLastKnownLocation(provider)
                ?: lm.getLastKnownLocation(LocationManager.PASSIVE_PROVIDER)
        } catch (_: Exception) {
            null
        }

        loc?.let { LocationPoint(lat = it.latitude, lng = it.longitude) }
    }

    override fun setAfterCallMode(mode: String) {
        val prefs = context.getSharedPreferences(PhoneStateReceiver.PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit().putString(PhoneStateReceiver.KEY_AFTER_CALL_MODE, mode).apply()
    }

    fun dispose() {
        stopObserving()
        scope.cancel()
    }

    private fun scheduleDebouncedEvent(kind: String) {
        val runnable = Runnable {
            scope.launch {
                try {
                    events.onDeviceDataChanged(kind)
                } catch (e: Exception) {
                    Log.w(TAG, "Failed to dispatch onDeviceDataChanged($kind): ${e.message}")
                }
            }
        }
        if (kind == "calls") {
            pendingCallsRunnable?.let { mainHandler.removeCallbacks(it) }
            pendingCallsRunnable = runnable
        } else {
            pendingSmsRunnable?.let { mainHandler.removeCallbacks(it) }
            pendingSmsRunnable = runnable
        }
        mainHandler.postDelayed(runnable, DEBOUNCE_MS)
    }

    companion object {
        private const val TAG = "DeviceApiImpl"
        private const val DEBOUNCE_MS = 2000L
    }
}

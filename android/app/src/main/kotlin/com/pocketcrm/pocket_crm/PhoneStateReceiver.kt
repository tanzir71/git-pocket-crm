package com.pocketcrm.pocket_crm

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.CallLog
import android.provider.ContactsContract
import android.telephony.TelephonyManager
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat

/**
 * Lightweight manifest-declared receiver that posts an after-call notification
 * when a call with a saved contact returns to IDLE. Holds no database.
 */
class PhoneStateReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent?) {
        if (intent?.action != TelephonyManager.ACTION_PHONE_STATE_CHANGED) return

        val stateStr = intent.getStringExtra(TelephonyManager.EXTRA_STATE) ?: return
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val prevState = prefs.getString(KEY_LAST_STATE, TelephonyManager.EXTRA_STATE_IDLE)

        @Suppress("DEPRECATION")
        val extraNumber = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER)
        if (!extraNumber.isNullOrBlank()) {
            prefs.edit().putString(KEY_LAST_NUMBER, extraNumber).apply()
        }

        val wasInCall = prevState == TelephonyManager.EXTRA_STATE_RINGING ||
            prevState == TelephonyManager.EXTRA_STATE_OFFHOOK
        val isNowIdle = stateStr == TelephonyManager.EXTRA_STATE_IDLE

        prefs.edit().putString(KEY_LAST_STATE, stateStr).apply()

        if (!wasInCall || !isNowIdle) return

        val mode = prefs.getString(KEY_AFTER_CALL_MODE, "all") ?: "all"
        if (mode == "never") return

        // Avoid duplicate notifications for back-to-back IDLE broadcasts
        val now = System.currentTimeMillis()
        val lastPostedAt = prefs.getLong(KEY_LAST_POSTED_AT, 0L)
        if (now - lastPostedAt < 3000L) return

        val number = extraNumber?.takeIf { it.isNotBlank() }
            ?: prefs.getString(KEY_LAST_NUMBER, null)?.takeIf { it.isNotBlank() }
            ?: readMostRecentCallNumber(context)
            ?: return

        prefs.edit().remove(KEY_LAST_NUMBER).apply()

        val contact = lookupSavedContact(context, number) ?: return
        if (mode == "starred" && !contact.starred) return

        prefs.edit().putLong(KEY_LAST_POSTED_AT, now).apply()
        postAfterCallNotification(context, contact.displayName, number)
    }

    private data class LookupContact(val displayName: String, val starred: Boolean)

    private fun lookupSavedContact(context: Context, rawNumber: String): LookupContact? {
        if (ContextCompat.checkSelfPermission(context, Manifest.permission.READ_CONTACTS)
            != PackageManager.PERMISSION_GRANTED
        ) {
            return null
        }
        return try {
            val uri = Uri.withAppendedPath(
                ContactsContract.PhoneLookup.CONTENT_FILTER_URI,
                Uri.encode(rawNumber),
            )
            val projection = arrayOf(
                ContactsContract.PhoneLookup.DISPLAY_NAME,
                ContactsContract.PhoneLookup.STARRED,
            )
            context.contentResolver.query(uri, projection, null, null, null)?.use { cursor ->
                if (cursor.moveToFirst()) {
                    val name = cursor.getString(0)?.takeIf { it.isNotBlank() } ?: return null
                    val starred = cursor.getInt(1) == 1
                    LookupContact(displayName = name, starred = starred)
                } else {
                    null
                }
            }
        } catch (e: Exception) {
            Log.w(TAG, "PhoneLookup failed: ${e.message}")
            null
        }
    }

    private fun readMostRecentCallNumber(context: Context): String? {
        if (ContextCompat.checkSelfPermission(context, Manifest.permission.READ_CALL_LOG)
            != PackageManager.PERMISSION_GRANTED
        ) {
            return null
        }
        return try {
            val cutoff = System.currentTimeMillis() - 60_000L
            val projection = arrayOf(CallLog.Calls.NUMBER, CallLog.Calls.DATE)
            context.contentResolver.query(
                CallLog.Calls.CONTENT_URI,
                projection,
                "${CallLog.Calls.DATE} >= ?",
                arrayOf(cutoff.toString()),
                "${CallLog.Calls.DATE} DESC",
            )?.use { cursor ->
                if (cursor.moveToFirst()) cursor.getString(0)?.takeIf { it.isNotBlank() } else null
            }
        } catch (e: Exception) {
            Log.w(TAG, "CallLog fallback lookup failed: ${e.message}")
            null
        }
    }

    private fun postAfterCallNotification(context: Context, name: String, number: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            ContextCompat.checkSelfPermission(context, Manifest.permission.POST_NOTIFICATIONS)
            != PackageManager.PERMISSION_GRANTED
        ) {
            return
        }

        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_AFTER_CALLS,
                "After calls",
                NotificationManager.IMPORTANCE_HIGH,
            ).apply {
                description = "Prompts to add a note after calls with saved contacts"
            }
            manager.createNotificationChannel(channel)
        }

        val encoded = Uri.encode(number)
        val noteUri = Uri.parse("pocketcrm://after-call?number=$encoded")
        val followUpUri = Uri.parse("pocketcrm://after-call?number=$encoded&focus=followup")

        val openNoteIntent = Intent(Intent.ACTION_VIEW, noteUri, context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val followUpIntent = Intent(Intent.ACTION_VIEW, followUpUri, context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }

        val piFlags = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        val contentPi = PendingIntent.getActivity(context, 7001, openNoteIntent, piFlags)
        val addNotePi = PendingIntent.getActivity(context, 7002, openNoteIntent, piFlags)
        val followUpPi = PendingIntent.getActivity(context, 7003, followUpIntent, piFlags)

        val notification = NotificationCompat.Builder(context, CHANNEL_AFTER_CALLS)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("Add a note about your call with $name")
            .setAutoCancel(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setContentIntent(contentPi)
            .addAction(0, "Add note", addNotePi)
            .addAction(0, "Follow up", followUpPi)
            .build()

        manager.notify(NOTIFICATION_ID, notification)
    }

    companion object {
        const val PREFS_NAME = "pocketcrm_prefs"
        const val KEY_AFTER_CALL_MODE = "after_call_mode"
        private const val KEY_LAST_STATE = "phone_last_state"
        private const val KEY_LAST_NUMBER = "phone_last_number"
        private const val KEY_LAST_POSTED_AT = "after_call_last_posted_at"
        const val CHANNEL_AFTER_CALLS = "after_calls"
        private const val NOTIFICATION_ID = 7100
        private const val TAG = "PhoneStateReceiver"
    }
}

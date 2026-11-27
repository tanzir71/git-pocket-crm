package com.pocketcrm.pocket_crm.outbox

import android.Manifest
import android.annotation.SuppressLint
import android.app.AlarmManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import android.telephony.SubscriptionManager
import android.telephony.TelephonyManager
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import java.io.File
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

/**
 * Pigeon host implementation for [OutboxApi].
 */
class OutboxApiImpl(
    private val context: Context,
    events: OutboxEvents,
) : OutboxApi {

    private val db = OutboxDb.getInstance(context)

    init {
        activeEvents = events
    }

    fun dispose() {
        activeEvents = null
    }

    override fun enqueue(items: List<OutboxItem>) {
        val seq = db.enqueue(items)
        OutboxScheduler.scheduleNext(context)
        notifyChanged(seq)
    }

    override fun upsertCampaign(config: CampaignConfig) {
        val seq = db.upsertCampaign(config)
        OutboxScheduler.scheduleNext(context)
        notifyChanged(seq)
    }

    override fun cancel(clientIds: List<String>) {
        val seq = db.cancel(clientIds)
        OutboxScheduler.scheduleNext(context)
        notifyChanged(seq)
    }

    override fun retry(clientIds: List<String>) {
        val seq = db.retry(clientIds)
        OutboxScheduler.enqueueDrainNow(context)
        notifyChanged(seq)
    }

    override fun pauseCampaign(id: String) {
        val seq = db.pauseCampaign(id)
        OutboxScheduler.scheduleNext(context)
        notifyChanged(seq)
    }

    override fun resumeCampaign(id: String) {
        val seq = db.resumeCampaign(id)
        OutboxScheduler.scheduleNext(context)
        notifyChanged(seq)
    }

    override fun stopCampaign(id: String) {
        val seq = db.stopCampaign(id)
        OutboxScheduler.scheduleNext(context)
        notifyChanged(seq)
    }

    override fun changesSince(seq: Long): ChangeSet {
        return db.changesSince(seq)
    }

    override fun sims(): List<SimInfo> {
        if (ContextCompat.checkSelfPermission(context, Manifest.permission.READ_PHONE_STATE)
            != PackageManager.PERMISSION_GRANTED
        ) {
            return emptyList()
        }
        return try {
            val subMgr = context.getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE)
                as? SubscriptionManager ?: return emptyList()
            val defaultSubId = SubscriptionManager.getDefaultSmsSubscriptionId()
            @Suppress("DEPRECATION")
            val list = subMgr.activeSubscriptionInfoList ?: emptyList()
            list.map { info ->
                SimInfo(
                    subId = info.subscriptionId.toLong(),
                    slot = info.simSlotIndex.toLong(),
                    carrierName = info.carrierName?.toString() ?: "",
                    displayName = info.displayName?.toString()
                        ?: info.carrierName?.toString()
                        ?: "SIM ${info.simSlotIndex + 1}",
                    isDefault = info.subscriptionId == defaultSubId,
                )
            }
        } catch (_: Exception) {
            emptyList()
        }
    }

    override fun capabilities(): OutboxCapabilities {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val exactAlarms = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            alarmManager.canScheduleExactAlarms()
        } else {
            true
        }

        val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        val ignoringBattery = powerManager.isIgnoringBatteryOptimizations(context.packageName)

        val notifications = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            ContextCompat.checkSelfPermission(context, Manifest.permission.POST_NOTIFICATIONS) ==
                PackageManager.PERMISSION_GRANTED &&
                NotificationManagerCompat.from(context).areNotificationsEnabled()
        } else {
            NotificationManagerCompat.from(context).areNotificationsEnabled()
        }

        val smsPermission = ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.SEND_SMS,
        ) == PackageManager.PERMISSION_GRANTED

        return OutboxCapabilities(
            exactAlarms = exactAlarms,
            ignoringBatteryOptimisation = ignoringBattery,
            notifications = notifications,
            smsPermission = smsPermission,
        )
    }

    override fun shareFile(path: String, mimeType: String, subject: String) {
        try {
            val file = File(path)
            if (!file.exists()) return
            val uri = FileProvider.getUriForFile(
                context,
                "${context.packageName}.fileprovider",
                file,
            )
            val sendIntent = Intent(Intent.ACTION_SEND).apply {
                type = mimeType
                putExtra(Intent.EXTRA_STREAM, uri)
                putExtra(Intent.EXTRA_SUBJECT, subject)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            val chooser = Intent.createChooser(sendIntent, subject).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            context.startActivity(chooser)
        } catch (_: Exception) {
            // Safe no-op if no share target is available.
        }
    }

    @SuppressLint("HardwareIds")
    override fun setupInfo(): SetupPlatformInfo {
        val installer = try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                context.packageManager.getInstallSourceInfo(context.packageName).installingPackageName
            } else {
                @Suppress("DEPRECATION")
                context.packageManager.getInstallerPackageName(context.packageName)
            }
        } catch (_: Exception) {
            null
        }
        val knownStores = setOf(
            "com.android.vending",
            "com.amazon.venezia",
            "com.sec.android.app.samsungapps",
            "com.huawei.appmarket",
        )
        val installedFromStore = installer != null && knownStores.contains(installer)

        var ownNumber: String? = null
        if (ContextCompat.checkSelfPermission(context, Manifest.permission.READ_PHONE_STATE)
            == PackageManager.PERMISSION_GRANTED
        ) {
            try {
                val subMgr = context.getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE)
                    as? SubscriptionManager
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU && subMgr != null) {
                    val defSubId = SubscriptionManager.getDefaultSmsSubscriptionId()
                    if (defSubId != SubscriptionManager.INVALID_SUBSCRIPTION_ID) {
                        ownNumber = subMgr.getPhoneNumber(defSubId).takeIf { it.isNotBlank() }
                    }
                }
                if (ownNumber.isNullOrBlank()) {
                    val tm = context.getSystemService(Context.TELEPHONY_SERVICE) as? TelephonyManager
                    @Suppress("DEPRECATION")
                    ownNumber = tm?.line1Number?.takeIf { it.isNotBlank() }
                }
            } catch (_: Exception) {
                ownNumber = null
            }
        }

        return SetupPlatformInfo(
            sdkInt = Build.VERSION.SDK_INT.toLong(),
            manufacturer = Build.MANUFACTURER ?: "",
            installedFromStore = installedFromStore,
            ownPhoneNumber = ownNumber,
        )
    }

    override fun openExactAlarmSettings() {
        val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                data = Uri.parse("package:${context.packageName}")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
        } else {
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.parse("package:${context.packageName}")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
        }
        try {
            context.startActivity(intent)
        } catch (_: Exception) {
            openAppDetailsSettings()
        }
    }

    @SuppressLint("BatteryLife")
    override fun requestIgnoreBatteryOptimisations() {
        val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
            data = Uri.parse("package:${context.packageName}")
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        try {
            context.startActivity(intent)
        } catch (_: Exception) {
            try {
                val fallback = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                context.startActivity(fallback)
            } catch (_: Exception) {
                openAppDetailsSettings()
            }
        }
    }

    override fun openAppDetailsSettings() {
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
            data = Uri.parse("package:${context.packageName}")
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        try {
            context.startActivity(intent)
        } catch (_: Exception) {}
    }

    companion object {
        @Volatile
        private var activeEvents: OutboxEvents? = null
        private val mainScope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)

        fun notifyChanged(latestSeq: Long) {
            val events = activeEvents ?: return
            mainScope.launch {
                try {
                    events.onOutboxChanged(latestSeq)
                } catch (_: Exception) {
                    // Engine may have detached between check and dispatch.
                }
            }
        }
    }
}

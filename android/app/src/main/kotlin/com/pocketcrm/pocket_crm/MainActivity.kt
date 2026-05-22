package com.pocketcrm.pocket_crm

import android.telephony.SmsManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.pocketcrm.pocket_crm/sms"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "sendSms") {
                val phoneNumber = call.argument<String>("phoneNumber")
                val message = call.argument<String>("message")

                if (phoneNumber != null && message != null) {
                    try {
                        val smsManager: SmsManager = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            context.getSystemService(SmsManager::class.java)
                        } else {
                            @Suppress("DEPRECATION")
                            SmsManager.getDefault()
                        }

                        val parts = smsManager.divideMessage(message)
                        if (parts.size > 1) {
                            smsManager.sendMultipartTextMessage(phoneNumber, null, parts, null, null)
                        } else {
                            smsManager.sendTextMessage(phoneNumber, null, message, null, null)
                        }
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("SMS_SEND_FAILED", e.localizedMessage, null)
                    }
                } else {
                    result.error("INVALID_ARGUMENTS", "Phone number or message was null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}

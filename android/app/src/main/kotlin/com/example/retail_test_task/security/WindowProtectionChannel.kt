package com.example.retail_test_task.security

import android.app.Activity
import android.os.Build
import android.util.Log
import android.view.WindowManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

internal class WindowProtectionChannel(
    messenger: BinaryMessenger,
    private val activity: Activity,
) : MethodChannel.MethodCallHandler {
    private val channel = MethodChannel(messenger, CHANNEL_NAME)

    init {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != SET_SECURE_METHOD) {
            result.notImplemented()
            return
        }

        val enabled = call.arguments as? Boolean
        if (enabled == null) {
            result.error(ERROR_CODE, ERROR_MESSAGE, null)
            return
        }

        activity.runOnUiThread {
            try {
                if (enabled) {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        activity.setRecentsScreenshotEnabled(false)
                    }
                    activity.window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                } else {
                    activity.window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        activity.setRecentsScreenshotEnabled(true)
                    }
                }
                Log.d(LOG_TAG, "secure=$enabled")
                result.success(null)
            } catch (error: RuntimeException) {
                Log.e(LOG_TAG, "update failed", error)
                result.error(ERROR_CODE, ERROR_MESSAGE, null)
            }
        }
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
    }

    private companion object {
        const val CHANNEL_NAME =
            "com.example.retail_test_task/payment_window_protection"
        const val SET_SECURE_METHOD = "setSecure"
        const val ERROR_CODE = "window_protection_failed"
        const val ERROR_MESSAGE = "Screen protection could not be updated."
        const val LOG_TAG = "WindowProtection"
    }
}

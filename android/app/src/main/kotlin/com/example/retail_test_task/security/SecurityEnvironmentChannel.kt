package com.example.retail_test_task.security

import android.content.Context
import android.util.Log
import com.scottyab.rootbeer.RootBeer
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMethodCodec

internal enum class SecuritySignalValue(val wireValue: String) {
    CLEAR("clear"),
    DETECTED("detected"),
    UNSUPPORTED("unsupported"),
}

private fun interface RootDetector {
    fun isRooted(): Boolean
}

private class RootBeerDetector(context: Context) : RootDetector {
    private val rootBeer = RootBeer(context.applicationContext)

    override fun isRooted(): Boolean = rootBeer.isRooted()
}

internal class SecurityEnvironmentChannel(
    messenger: BinaryMessenger,
    context: Context,
    private val screenRecordingStatus: ScreenRecordingStatus,
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
    private val rootDetector: RootDetector = RootBeerDetector(context)
    private val channel = MethodChannel(
        messenger,
        CHANNEL_NAME,
        StandardMethodCodec.INSTANCE,
        messenger.makeBackgroundTaskQueue(),
    )
    private val recordingEvents = EventChannel(messenger, RECORDING_EVENTS_CHANNEL_NAME)
    private var recordingEventSink: EventChannel.EventSink? = null

    init {
        channel.setMethodCallHandler(this)
        recordingEvents.setStreamHandler(this)
        Log.d(LOG_TAG, "channel attached")
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.d(LOG_TAG, "method call: ${call.method}")
        if (call.method != CHECK_SECURITY_STATUS_METHOD) {
            Log.d(LOG_TAG, "method not implemented")
            result.notImplemented()
            return
        }

        if (call.arguments != null) {
            Log.e(LOG_TAG, "check rejected: unexpected arguments")
            result.error(ERROR_CODE, ERROR_MESSAGE, null)
            return
        }

        try {
            val root = if (rootDetector.isRooted()) {
                SecuritySignalValue.DETECTED
            } else {
                SecuritySignalValue.CLEAR
            }
            val screenRecording = screenRecordingStatus.currentStatus()
            Log.d(
                LOG_TAG,
                "check result: root=${root.wireValue} " +
                    "screenRecording=${screenRecording.wireValue}",
            )

            result.success(
                mapOf(
                    ROOT_KEY to root.wireValue,
                    SCREEN_RECORDING_KEY to screenRecording.wireValue,
                ),
            )
        } catch (error: Throwable) {
            if (error is VirtualMachineError || error is ThreadDeath) {
                throw error
            }
            Log.e(LOG_TAG, "check failed: ${error.javaClass.simpleName}")
            result.error(ERROR_CODE, ERROR_MESSAGE, null)
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        Log.d(LOG_TAG, "recording events: listener attached")
        recordingEventSink = events
        screenRecordingStatus.setListener { status ->
            if (recordingEventSink === events) {
                Log.d(LOG_TAG, "recording event: ${status.wireValue}")
                events.success(status.wireValue)
            }
        }
    }

    override fun onCancel(arguments: Any?) {
        Log.d(LOG_TAG, "recording events: listener detached")
        screenRecordingStatus.setListener(null)
        recordingEventSink = null
    }

    fun dispose() {
        Log.d(LOG_TAG, "channel detached")
        screenRecordingStatus.setListener(null)
        recordingEventSink = null
        recordingEvents.setStreamHandler(null)
        channel.setMethodCallHandler(null)
    }

    private companion object {
        const val CHANNEL_NAME = "com.example.retail_test_task/security_environment"
        const val RECORDING_EVENTS_CHANNEL_NAME =
            "com.example.retail_test_task/screen_recording_events"
        const val CHECK_SECURITY_STATUS_METHOD = "checkSecurityStatus"
        const val ROOT_KEY = "root"
        const val SCREEN_RECORDING_KEY = "screenRecording"
        const val ERROR_CODE = "security_check_failed"
        const val ERROR_MESSAGE = "The device security status could not be checked."
        const val LOG_TAG = "SecurityEnvironment"
    }
}

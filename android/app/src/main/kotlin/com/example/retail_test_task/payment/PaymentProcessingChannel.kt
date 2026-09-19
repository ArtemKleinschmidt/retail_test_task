package com.example.retail_test_task.payment

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

internal class PaymentProcessingChannel(
    messenger: BinaryMessenger,
    private val activity: Activity,
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
    private val methodChannel = MethodChannel(messenger, METHOD_CHANNEL_NAME)
    private val eventChannel = EventChannel(messenger, EVENT_CHANNEL_NAME)
    private val channelScope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)

    private var pendingStart: PendingStart? = null
    private var eventListener: ((PaymentProcessingEvent) -> Unit)? = null

    init {
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != START_PROCESSING_METHOD) {
            result.notImplemented()
            return
        }

        val arguments = call.arguments as? Map<*, *>
        val reference = (arguments?.get(REFERENCE_KEY) as? String)?.trim()
        if (reference.isNullOrEmpty()) {
            result.error(START_ERROR_CODE, START_ERROR_MESSAGE, null)
            return
        }

        channelScope.launch {
            if (!PaymentProcessingCoordinator.reserve(reference)) {
                result.error(START_ERROR_CODE, PROCESSING_ALREADY_ACTIVE_MESSAGE, null)
                return@launch
            }

            if (
                Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
                activity.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) !=
                PackageManager.PERMISSION_GRANTED
            ) {
                pendingStart = PendingStart(reference, result)
                try {
                    activity.requestPermissions(
                        arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                        NOTIFICATION_PERMISSION_REQUEST_CODE,
                    )
                } catch (error: RuntimeException) {
                    Log.w(LOG_TAG, "notification permission request failed", error)
                    pendingStart = null
                    launchService(reference, result)
                }
                return@launch
            }

            launchService(reference, result)
        }
    }

    fun onRequestPermissionsResult(requestCode: Int): Boolean {
        if (requestCode != NOTIFICATION_PERMISSION_REQUEST_CODE) {
            return false
        }

        val start = pendingStart ?: return true
        pendingStart = null
        channelScope.launch {
            launchService(start.reference, start.result)
        }
        return true
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        val listener: (PaymentProcessingEvent) -> Unit = { event ->
            when (event) {
                is PaymentProcessingEvent.Progress -> events.success(
                    mapOf(
                        REFERENCE_KEY to event.reference,
                        TYPE_KEY to PROGRESS_TYPE,
                        PERCENTAGE_KEY to event.percentage,
                    ),
                )
                is PaymentProcessingEvent.Result -> events.success(
                    mapOf(
                        REFERENCE_KEY to event.reference,
                        TYPE_KEY to RESULT_TYPE,
                        OUTCOME_KEY to event.outcome,
                    ),
                )
                is PaymentProcessingEvent.Failure -> events.error(
                    PROCESSING_ERROR_CODE,
                    event.message,
                    null,
                )
            }
        }
        eventListener = listener
        channelScope.launch {
            PaymentProcessingCoordinator.setListener(listener)
        }
    }

    override fun onCancel(arguments: Any?) {
        clearEventListener()
    }

    fun dispose() {
        val start = pendingStart
        val listener = eventListener
        pendingStart = null
        eventListener = null
        eventChannel.setStreamHandler(null)
        methodChannel.setMethodCallHandler(null)

        channelScope.launch {
            start?.let {
                PaymentProcessingCoordinator.fail(it.reference, START_ERROR_MESSAGE)
                it.result.error(START_ERROR_CODE, START_ERROR_MESSAGE, null)
            }
            if (listener != null) {
                PaymentProcessingCoordinator.clearListener(listener)
            }
        }.invokeOnCompletion {
            channelScope.cancel()
        }
    }

    private suspend fun launchService(reference: String, result: MethodChannel.Result) {
        try {
            val intent = Intent(activity, PaymentProcessingService::class.java)
                .putExtra(PaymentProcessingService.REFERENCE_EXTRA, reference)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                activity.startForegroundService(intent)
            } else {
                activity.startService(intent)
            }
            result.success(null)
        } catch (error: RuntimeException) {
            Log.e(LOG_TAG, "service start failed", error)
            PaymentProcessingCoordinator.fail(reference, START_ERROR_MESSAGE)
            result.error(START_ERROR_CODE, START_ERROR_MESSAGE, null)
        }
    }

    private fun clearEventListener() {
        val listener = eventListener
        eventListener = null
        if (listener != null) {
            channelScope.launch {
                PaymentProcessingCoordinator.clearListener(listener)
            }
        }
    }

    private data class PendingStart(
        val reference: String,
        val result: MethodChannel.Result,
    )

    private companion object {
        const val METHOD_CHANNEL_NAME =
            "com.example.retail_test_task/payment_processing"
        const val EVENT_CHANNEL_NAME =
            "com.example.retail_test_task/payment_processing_events"
        const val START_PROCESSING_METHOD = "startProcessing"
        const val REFERENCE_KEY = "reference"
        const val TYPE_KEY = "type"
        const val PERCENTAGE_KEY = "percentage"
        const val OUTCOME_KEY = "outcome"
        const val PROGRESS_TYPE = "progress"
        const val RESULT_TYPE = "result"
        const val START_ERROR_CODE = "payment_start_failed"
        const val PROCESSING_ERROR_CODE = "payment_processing_failed"
        const val START_ERROR_MESSAGE = "Payment processing could not start."
        const val PROCESSING_ALREADY_ACTIVE_MESSAGE =
            "Another payment is already processing."
        const val NOTIFICATION_PERMISSION_REQUEST_CODE = 9042
        const val LOG_TAG = "PaymentProcessing"
    }
}

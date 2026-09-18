package com.example.retail_test_task.security

import android.os.Build
import android.util.Log
import android.view.WindowManager
import androidx.annotation.RequiresApi
import java.util.concurrent.Executor
import java.util.concurrent.atomic.AtomicReference
import java.util.function.Consumer

internal interface ScreenRecordingStatus {
    fun currentStatus(): SecuritySignalValue

    fun setListener(listener: ((SecuritySignalValue) -> Unit)?)
}

internal class ScreenRecordingMonitor(
    private val windowManager: WindowManager,
    private val callbackExecutor: Executor,
) : ScreenRecordingStatus {
    private val currentValue = AtomicReference<SecuritySignalValue?>(
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.VANILLA_ICE_CREAM) {
            SecuritySignalValue.UNSUPPORTED
        } else {
            null
        },
    )

    private var callback: Consumer<Int>? = null
    private var callbackGeneration = 0
    private val statusListener =
        AtomicReference<((SecuritySignalValue) -> Unit)?>(null)

    fun start() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.VANILLA_ICE_CREAM) {
            Log.d(LOG_TAG, "start: unsupported sdk=${Build.VERSION.SDK_INT}")
            return
        }
        if (callback != null) {
            Log.d(LOG_TAG, "start: callback already registered")
            return
        }

        Log.d(LOG_TAG, "start: registering callback")
        startSupported()
    }

    fun stop() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.VANILLA_ICE_CREAM) {
            Log.d(LOG_TAG, "stop: unsupported sdk=${Build.VERSION.SDK_INT}")
            return
        }

        Log.d(LOG_TAG, "stop: unregistering callback")
        stopSupported()
    }

    override fun currentStatus(): SecuritySignalValue {
        val status = currentValue.get()
            ?: error("Screen-recording detection is unavailable.")
        Log.d(LOG_TAG, "read: status=${status.wireValue}")
        return status
    }

    override fun setListener(listener: ((SecuritySignalValue) -> Unit)?) {
        statusListener.set(listener)
        Log.d(LOG_TAG, "listener: ${if (listener == null) "detached" else "attached"}")
        if (listener != null) {
            currentValue.get()?.let(listener)
        }
    }

    @RequiresApi(Build.VERSION_CODES.VANILLA_ICE_CREAM)
    private fun startSupported() {
        val generation = ++callbackGeneration
        val newCallback = Consumer<Int> { state ->
            val mappedState = state.toSecuritySignalValue()
            Log.d(
                LOG_TAG,
                "callback: raw=$state mapped=${mappedState.wireValue} " +
                    "accepted=${callbackGeneration == generation}",
            )
            if (callbackGeneration == generation) {
                publish(mappedState)
            }
        }

        callback = newCallback
        try {
            val initialState = windowManager.addScreenRecordingCallback(
                callbackExecutor,
                newCallback,
            )
            val mappedState = initialState.toSecuritySignalValue()
            publish(mappedState)
            Log.d(
                LOG_TAG,
                "registered: initialRaw=$initialState initial=${mappedState.wireValue}",
            )
        } catch (error: Throwable) {
            callback = null
            currentValue.set(null)
            Log.e(LOG_TAG, "registration failed: ${error.javaClass.simpleName}")
        }
    }

    @RequiresApi(Build.VERSION_CODES.VANILLA_ICE_CREAM)
    private fun stopSupported() {
        val registeredCallback = callback
        if (registeredCallback == null) {
            Log.d(LOG_TAG, "stop: no callback registered")
            return
        }
        callbackGeneration += 1
        callback = null
        currentValue.set(null)
        val result = runCatching {
            windowManager.removeScreenRecordingCallback(registeredCallback)
        }
        result.fold(
            onSuccess = { Log.d(LOG_TAG, "stop: callback unregistered") },
            onFailure = { error ->
                Log.e(LOG_TAG, "unregistration failed: ${error.javaClass.simpleName}")
            },
        )
    }

    private fun publish(status: SecuritySignalValue) {
        currentValue.set(status)
        runCatching { statusListener.get()?.invoke(status) }
            .onFailure { error ->
                Log.e(LOG_TAG, "listener failed: ${error.javaClass.simpleName}")
            }
    }

    @RequiresApi(Build.VERSION_CODES.VANILLA_ICE_CREAM)
    private fun Int.toSecuritySignalValue(): SecuritySignalValue {
        return when (this) {
            WindowManager.SCREEN_RECORDING_STATE_VISIBLE -> SecuritySignalValue.DETECTED
            WindowManager.SCREEN_RECORDING_STATE_NOT_VISIBLE -> SecuritySignalValue.CLEAR
            else -> error("Unexpected screen-recording state.")
        }
    }

    private companion object {
        const val LOG_TAG = "SecurityRecording"
    }
}

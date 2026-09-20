package com.example.retail_test_task.payment

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.content.pm.ServiceInfo
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Build
import android.os.IBinder
import android.util.Log
import com.example.retail_test_task.R
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

internal class PaymentProcessingService : Service() {
    private lateinit var notificationManager: NotificationManager

    private val serviceJob = SupervisorJob()
    private val serviceScope = CoroutineScope(serviceJob + Dispatchers.Main.immediate)
    private val notificationAccentColor: Int by lazy { getColor(R.color.payment_notification_accent) }
    private val notificationLargeIcon: Bitmap by lazy {
        BitmapFactory.decodeResource(resources, R.mipmap.ic_launcher)
    }

    private var processingJob: Job? = null
    private var terminated = false
    private var activeReference: String? = null

    override fun onCreate() {
        super.onCreate()
        notificationManager = getSystemService(NotificationManager::class.java)
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val reference = intent?.getStringExtra(REFERENCE_EXTRA)?.trim()
        val debugProcessingBehavior =
            intent?.getStringExtra(DEBUG_PROCESSING_BEHAVIOR_EXTRA)?.trim()
        if (reference.isNullOrEmpty()) {
            stopSelf(startId)
            return START_NOT_STICKY
        }

        if (processingJob?.isActive == true) {
            Log.w(LOG_TAG, "duplicate start ignored reference=$reference")
            return START_NOT_STICKY
        }

        processingJob = serviceScope.launch {
            if (!PaymentProcessingCoordinator.isReservedFor(reference)) {
                stopSelf(startId)
                return@launch
            }

            activeReference = reference
            try {
                promoteToForeground(reference)
                processPayment(reference, startId, debugProcessingBehavior)
            } catch (error: CancellationException) {
                throw error
            } catch (error: RuntimeException) {
                Log.e(LOG_TAG, "processing failed", error)
                fail(reference, startId, START_FAILURE_MESSAGE)
            }
        }

        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onTimeout(startId: Int) {
        activeReference?.let { reference ->
            processingJob?.cancel()
            serviceScope.launch {
                fail(reference, startId, TIMEOUT_MESSAGE)
            }
        }
    }

    override fun onDestroy() {
        processingJob?.cancel()
        val reference = activeReference
        if (reference != null && !terminated) {
            terminated = true
            serviceScope.launch {
                PaymentProcessingCoordinator.fail(reference, INTERRUPTED_MESSAGE)
            }.invokeOnCompletion {
                serviceScope.cancel()
            }
        } else {
            serviceScope.cancel()
        }
        activeReference = null
        super.onDestroy()
    }

    private fun promoteToForeground(reference: String) {
        val notification = buildNotification(reference, percentage = 0)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_SHORT_SERVICE,
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    private suspend fun processPayment(
        reference: String,
        startId: Int,
        debugProcessingBehavior: String?,
    ) {
        Log.d(LOG_TAG, "started reference=$reference")

        for (percentage in PROGRESS_MILESTONES) {
            delay(PROGRESS_INTERVAL_MILLIS)
            notificationManager.notify(
                NOTIFICATION_ID,
                buildNotification(reference, percentage),
            )
            PaymentProcessingCoordinator.publishProgress(reference, percentage)

            if (
                debugProcessingBehavior == DEBUG_PROGRESS_FAILURE &&
                percentage == DEBUG_PROGRESS_FAILURE_PERCENTAGE
            ) {
                fail(reference, startId, PROCESSING_FAILURE_MESSAGE)
                return
            }
        }

        complete(
            reference,
            startId,
            isApproved = debugProcessingBehavior != DEBUG_DECLINED,
        )
    }

    private suspend fun complete(reference: String, startId: Int, isApproved: Boolean) {
        if (terminated) {
            return
        }
        terminated = true

        Log.d(LOG_TAG, "completed reference=$reference")
        PaymentProcessingCoordinator.complete(reference, isApproved)
        stopProcessing(startId)
    }

    private suspend fun fail(reference: String, startId: Int, message: String) {
        if (terminated) {
            return
        }
        terminated = true

        Log.e(LOG_TAG, "failed reference=$reference message=$message")
        PaymentProcessingCoordinator.fail(reference, message)
        stopProcessing(startId)
    }

    private fun stopProcessing(startId: Int) {
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf(startId)
    }

    private fun buildNotification(reference: String, percentage: Int): Notification {
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, NOTIFICATION_CHANNEL_ID)
        } else {
            Notification.Builder(this)
        }

        builder
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(getString(R.string.payment_notification_title))
            .setContentText(
                getString(
                    R.string.payment_notification_progress,
                    reference,
                    percentage,
                ),
            )
            .setCategory(Notification.CATEGORY_PROGRESS)
            .setColor(notificationAccentColor)
            .setLargeIcon(notificationLargeIcon)
            .setOngoing(true)
            .setAutoCancel(false)
            .setOnlyAlertOnce(true)
            .setPriority(Notification.PRIORITY_HIGH)
            .setProgress(100, percentage, false)
            .setShowWhen(false)
            .setSubText(getString(R.string.app_name))

        createContentIntent()?.let(builder::setContentIntent)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            builder.setForegroundServiceBehavior(Notification.FOREGROUND_SERVICE_IMMEDIATE)
        }

        return builder.build().apply {
            flags = flags or Notification.FLAG_ONGOING_EVENT or Notification.FLAG_NO_CLEAR
        }
    }

    private fun createContentIntent(): PendingIntent? {
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName) ?: return null
        launchIntent.flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        return PendingIntent.getActivity(
            this,
            CONTENT_INTENT_REQUEST_CODE,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return
        }

        val channel = NotificationChannel(
            NOTIFICATION_CHANNEL_ID,
            getString(R.string.payment_notification_channel_name),
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            description = getString(R.string.payment_notification_channel_description)
            enableVibration(true)
            lightColor = notificationAccentColor
            setShowBadge(false)
        }
        notificationManager.createNotificationChannel(channel)
    }

    companion object {
        const val REFERENCE_EXTRA = "paymentReference"
        const val DEBUG_PROCESSING_BEHAVIOR_EXTRA = "debugProcessingBehavior"

        private const val NOTIFICATION_CHANNEL_ID = "payment_processing"
        private const val NOTIFICATION_ID = 9010
        private const val CONTENT_INTENT_REQUEST_CODE = 9011
        private const val PROGRESS_INTERVAL_MILLIS = 1_500L
        private val PROGRESS_MILESTONES = listOf(20, 45, 70, 100)
        private const val DEBUG_PROGRESS_FAILURE_PERCENTAGE = 45

        private const val DEBUG_DECLINED = "declined"
        private const val DEBUG_PROGRESS_FAILURE = "progressFailure"

        private const val START_FAILURE_MESSAGE = "Payment processing could not start."
        private const val PROCESSING_FAILURE_MESSAGE = "Payment progress was interrupted."
        private const val TIMEOUT_MESSAGE = "Payment processing timed out."
        private const val INTERRUPTED_MESSAGE = "Payment processing was interrupted."
        private const val LOG_TAG = "PaymentProcessing"
    }
}

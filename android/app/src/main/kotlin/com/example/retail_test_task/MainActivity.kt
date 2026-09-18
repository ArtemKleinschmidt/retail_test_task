package com.example.retail_test_task

import android.view.WindowManager
import com.example.retail_test_task.security.ScreenRecordingMonitor
import com.example.retail_test_task.security.SecurityEnvironmentChannel
import com.example.retail_test_task.security.WindowProtectionChannel
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import java.util.concurrent.Executor

class MainActivity : FlutterActivity() {
    private var securityEnvironmentChannel: SecurityEnvironmentChannel? = null
    private var screenRecordingMonitor: ScreenRecordingMonitor? = null
    private var windowProtectionChannel: WindowProtectionChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val monitor = ScreenRecordingMonitor(
            windowManager = getSystemService(WindowManager::class.java),
            callbackExecutor = Executor(::runOnUiThread),
        )
        screenRecordingMonitor = monitor
        securityEnvironmentChannel = SecurityEnvironmentChannel(
            messenger = flutterEngine.dartExecutor.binaryMessenger,
            context = applicationContext,
            screenRecordingStatus = monitor,
        )
        windowProtectionChannel = WindowProtectionChannel(
            messenger = flutterEngine.dartExecutor.binaryMessenger,
            activity = this,
        )
    }

    override fun onStart() {
        super.onStart()
        screenRecordingMonitor?.start()
    }

    override fun onStop() {
        screenRecordingMonitor?.stop()
        super.onStop()
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        screenRecordingMonitor?.stop()
        securityEnvironmentChannel?.dispose()
        windowProtectionChannel?.dispose()
        securityEnvironmentChannel = null
        windowProtectionChannel = null
        screenRecordingMonitor = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}

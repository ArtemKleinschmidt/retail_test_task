package com.example.retail_test_task

import android.view.WindowManager
import com.example.retail_test_task.security.ScreenRecordingMonitor
import com.example.retail_test_task.security.SecurityEnvironmentChannel
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import java.util.concurrent.Executor

class MainActivity : FlutterActivity() {
    private var securityEnvironmentChannel: SecurityEnvironmentChannel? = null
    private var screenRecordingMonitor: ScreenRecordingMonitor? = null

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
        securityEnvironmentChannel = null
        screenRecordingMonitor = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}

package com.pira.x2local

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private lateinit var downloadManagerHelper: DownloadManagerHelper
    private val CHANNEL = "x2local/download_manager"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        downloadManagerHelper = DownloadManagerHelper(this)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            when (call.method) {
                "downloadFile" -> downloadManagerHelper.downloadFile(call, result)
                "checkDownloadStatus" -> downloadManagerHelper.checkDownloadStatus(call, result)
                else -> result.notImplemented()
            }
        }
    }
}
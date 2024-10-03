package com.crb.gzb.biling.carabaobillingapps

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.crb.gzb.biling.carabaobillingapps/channel"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Ensure that flutterEngine and binaryMessenger are not null
        flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
            MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result ->
                when (call.method) {
                    "launchApp" -> {
                        launchApp()
                        result.success(null)
                    }
                    "startForegroundService" -> {
                        val intent = Intent(this, ForegroundService::class.java)
                        startService(intent)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        } ?: run {
            // Handle the case where flutterEngine or binaryMessenger is null if necessary
            println("Error: flutterEngine or binaryMessenger is null")
        }
    }

    private fun launchApp() {
        val intent = Intent(this, MainActivity::class.java)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }
}

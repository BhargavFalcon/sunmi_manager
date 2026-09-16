package com.dinemetrics.manager

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.dinemetrics.manager/bluetooth"
    private val REQUEST_ENABLE_BT = 1
    private val NOTIFICATION_PERMISSION_REQ_CODE = 9989
    private var permissionResult: MethodChannel.Result? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannel()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "Dinemetrics Printer Service"
            val descriptionText = "Listening for new orders in background"
            val importance = android.app.NotificationManager.IMPORTANCE_LOW
            val channel = android.app.NotificationChannel("dinematrics_bg_service_channel", name, importance).apply {
                description = descriptionText
            }
            val notificationManager: android.app.NotificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as android.app.NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.dinemetrics.manager/battery").setMethodCallHandler { call, result ->
            if (call.method == "isIgnoringBatteryOptimizations") {
                val pm = getSystemService(Context.POWER_SERVICE) as android.os.PowerManager
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    result.success(pm.isIgnoringBatteryOptimizations(packageName))
                } else {
                    result.success(true)
                }
            } else if (call.method == "requestIgnoreBatteryOptimizations") {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    val intent = Intent(android.provider.Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                        data = Uri.parse("package:$packageName")
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    }
                    try {
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                } else {
                    result.success(true)
                }
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.dinemetrics.manager/notifications").setMethodCallHandler { call, result ->
            if (call.method == "requestNotificationPermission") {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    val hasPermission = checkSelfPermission(android.Manifest.permission.POST_NOTIFICATIONS) == android.content.pm.PackageManager.PERMISSION_GRANTED
                    if (hasPermission) {
                        result.success(true)
                    } else {
                        permissionResult = result
                        requestPermissions(
                            arrayOf(android.Manifest.permission.POST_NOTIFICATIONS),
                            NOTIFICATION_PERMISSION_REQ_CODE
                        )
                    }
                } else {
                    result.success(true)
                }
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "enableBluetooth") {
                enableBluetooth(result)
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == NOTIFICATION_PERMISSION_REQ_CODE) {
            val allGranted = grantResults.isNotEmpty() && grantResults.all { it == android.content.pm.PackageManager.PERMISSION_GRANTED }
            permissionResult?.success(allGranted)
            permissionResult = null
        }
    }

    private fun enableBluetooth(result: MethodChannel.Result) {
        try {
            val bluetoothAdapter: BluetoothAdapter? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val bluetoothManager = getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
                bluetoothManager.adapter
            } else {
                @Suppress("DEPRECATION")
                BluetoothAdapter.getDefaultAdapter()
            }

            if (bluetoothAdapter == null) {
                result.success(false)
                return
            }

            if (bluetoothAdapter.isEnabled) {
                result.success(true)
                return
            }

            // Try to enable Bluetooth
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                // Android 12+ - Always use Intent for better compatibility
                val enableBtIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
                enableBtIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                try {
                    startActivity(enableBtIntent)
                    result.success(false) // Will be enabled by user action via dialog
                } catch (e: Exception) {
                    e.printStackTrace()
                    result.success(false)
                }
            } else {
                // Android 11 and below - Try enable() first, fallback to Intent
                try {
                    @Suppress("DEPRECATION")
                    val enableResult = bluetoothAdapter.enable()
                    if (enableResult) {
                        Thread.sleep(500)
                        result.success(bluetoothAdapter.isEnabled)
                    } else {
                        // Use Intent as fallback
                        val enableBtIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
                        enableBtIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(enableBtIntent)
                        result.success(false) // Will be enabled by user action
                    }
                } catch (e: Exception) {
                    // Use Intent as fallback
                    val enableBtIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
                    enableBtIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    try {
                        startActivity(enableBtIntent)
                        result.success(false)
                    } catch (ex: Exception) {
                        ex.printStackTrace()
                        result.success(false)
                    }
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
            result.success(false)
        }
    }
}

package com.dinemetrics.manager

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.dinemetrics.manager/bluetooth"
    private val REQUEST_ENABLE_BT = 1

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "enableBluetooth") {
                enableBluetooth(result)
            } else {
                result.notImplemented()
            }
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

package com.example.receiptvault.receiptvault_flutter

import android.content.Intent
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.receiptvault/camera"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "openCamera") {
                try {
                    val takePictureIntent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
                    startActivity(takePictureIntent)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("CAMERA_ERROR", "Could not launch hardware camera: ${e.message}", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}

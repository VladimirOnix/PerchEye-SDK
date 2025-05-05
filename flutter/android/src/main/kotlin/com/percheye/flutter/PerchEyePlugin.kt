package com.percheye.flutter

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.util.Base64
import android.util.Log
import androidx.annotation.NonNull
import com.onix.faceauth.sdk.ImageResult
import com.onix.faceauth.sdk.PerchEye
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class PerchEyePlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var perchEye: PerchEye

    companion object {
        private const val TAG = "PerchEyePlugin"
    }

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "perch_eye_method_channel")
        channel.setMethodCallHandler(this)
        perchEye = PerchEye(binding.applicationContext)
        perchEye.init()
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "compareFaces" -> {
                val img1 = call.argument<String>("img1")
                val img2 = call.argument<String>("img2")
                val sim = compare(img1, img2)
                result.success(sim)
            }
            else -> result.notImplemented()
        }
    }

    private fun compare(img1: String?, img2: String?): Double {
        if (img1.isNullOrEmpty() || img2.isNullOrEmpty()) {
            Log.d(TAG, "One of images is null or empty")
            return 0.0
        }

        fun decode(b64: String): Bitmap? {
            return try {
                val bytes = Base64.decode(b64, Base64.DEFAULT)
                BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
            } catch (e: Exception) {
                Log.e(TAG, "Failed to decode image", e)
                null
            }
        }

        val bmp1 = decode(img1) ?: return 0.0
        val bmp2 = decode(img2) ?: return 0.0

        perchEye.openTransaction()
        val add1 = perchEye.addImage(bmp1)
        Log.d(TAG, "addImage1 result: $add1")
        if (add1 != ImageResult.SUCCESS) return 0.0
        val hash = perchEye.enroll()
        Log.d(TAG, "enroll hash: $hash")

        perchEye.openTransaction()
        val add2 = perchEye.addImage(bmp2)
        Log.d(TAG, "addImage2 result: $add2")
        if (add2 != ImageResult.SUCCESS) return 0.0
        val sim = perchEye.verify(hash)
        Log.d(TAG, "verify similarity: $sim")
        return sim.toDouble()
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        perchEye.destroy()
    }
}
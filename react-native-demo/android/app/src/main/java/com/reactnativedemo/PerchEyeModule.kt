package com.reactnativedemo

import com.facebook.react.bridge.LifecycleEventListener
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.onix.faceauth.sdk.ImageResult
import com.onix.faceauth.sdk.PerchEye
import com.reactnativedemo.util.convertToBitmap

class PerchEyeModule(reactContext: ReactApplicationContext) :
    ReactContextBaseJavaModule(reactContext), LifecycleEventListener {
    override fun getName() = "PerchEyeModule"

    private var perchEye: PerchEye = PerchEye(reactContext)

    init {
        perchEye.init()
    }

    override fun onHostDestroy() {
        perchEye.destroy()
    }

    override fun onHostPause() {
        return
    }

    override fun onHostResume() {
        return
    }


    @ReactMethod
    fun compare(img1: String, img2: String, promise: Promise) {
        val bitmap1 = convertToBitmap(img1)
        val bitmap2 = convertToBitmap(img2)

        if (bitmap1 == null || bitmap2 == null) {
            promise.resolve(0f)
            return
        }

        perchEye.openTransaction()

        if (perchEye.addImage(bitmap1) == ImageResult.SUCCESS) {
            val hash = perchEye.enroll()
            perchEye.openTransaction()
            if (perchEye.addImage(bitmap2) == ImageResult.SUCCESS) {
                val similarity = perchEye.verify(hash)
                promise.resolve(similarity)
            } else {
                promise.resolve(0f)
            }
        } else {
            promise.resolve(0f)
        }
    }

}
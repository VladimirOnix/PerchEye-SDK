package com.percheye

import android.graphics.Bitmap
import android.util.Log
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Callback
import com.facebook.react.bridge.LifecycleEventListener
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReadableArray
import com.onix.faceauth.sdk.PerchEye
import com.percheye.util.convertToBitmap
import com.percheye.util.descriptorToHash
import com.percheye.util.hashToDescriptor
import java.util.LinkedList
import java.util.Queue

class PerchEyeModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext), LifecycleEventListener {

  private var perchEye: PerchEye? = null
  private val gallery: HashMap<String, List<String>> = HashMap() // name -> List of hashes
  private val requestQueue: Queue<Pair<String, Callback>> = LinkedList()
  private var isProcessing = false


  init {
    reactContext.addLifecycleEventListener(this)

    perchEye = PerchEye(reactContext)
    perchEye?.init()
  }

  override fun getName(): String {
    return NAME
  }

  override fun onHostDestroy() {
    perchEye?.destroy()
  }

  override fun onHostPause() {
    return
  }

  override fun onHostResume() {
    return
  }

  @ReactMethod
  fun extractDescriptor(images: ReadableArray, promise: Promise) {
    val descriptors = mutableListOf<List<Short>>()

    for (i in 0 until images.size()) {
      try {
        val base64String = images.getString(i) ?: throw NullPointerException()
        val bitmap = convertToBitmap(base64String)

        if (bitmap != null) {
          val hash = perchEye?.evaluate(listOf(bitmap)) ?: throw NullPointerException()
          val descriptor = hashToDescriptor(hash)

          descriptors.add(descriptor)

          bitmap.recycle()
        } else {
          descriptors.add(listOf())
        }

      } catch (e: Exception) {
        descriptors.add(listOf())
      }
    }

    promise.resolve(Arguments.makeNativeArray(descriptors))
  }

  @ReactMethod
  fun setGallery(galleryArray: ReadableArray) {
    gallery.clear()

    for (i in 0 until galleryArray.size()) {
      try {
        val item = galleryArray.getMap(i) ?: continue

        val name = item.getString("name") ?: ""
        val descriptorArray = item.getArray("descriptor")?.toArrayList()?.mapNotNull {
          (it as? Double)?.toInt()?.toShort()
        }?.toShortArray() ?: shortArrayOf()

        val hash = descriptorToHash(descriptorArray.toList())

        if (gallery.containsKey(name)) {
          gallery[name] = gallery[name]?.plus(hash) ?: listOf(hash)
        } else {
          gallery[name] = listOf(hash)
        }

      } catch (e: Exception) {
        Log.d(this::class.simpleName, e.message.toString())
      }
    }
  }

  @ReactMethod
  fun recognize(image: String, callback: Callback) {
    if (isProcessing) {
      requestQueue.add(image to callback)
      return
    }
    isProcessing = true

    processRecognition(image, callback)
  }

  private fun processRecognition(image: String, callback: Callback) {
    try {
      val bitmap = convertToBitmap(image)
      if (bitmap != null) {
        var bestMatchName = ""
        var highestSimilarity = 0f

        for ((name, storedHashes) in gallery) {
          for (storedHash in storedHashes) {
            val similarity = perchEye?.compare(listOf(bitmap), storedHash) ?: 0f
            if (similarity > highestSimilarity) {
              highestSimilarity = similarity
              bestMatchName = name
            }
          }
        }

        if (highestSimilarity != 0f && bestMatchName != "") {
          callback.invoke(bestMatchName, highestSimilarity)
        }

        bitmap.recycle()
      }
    } catch (e: Exception) {
      Log.d(this::class.simpleName, e.message.toString())
    } finally {
      val nextRequest = requestQueue.poll()

      if (nextRequest != null) {
        val (nextImage, nextCallback) = nextRequest
        processRecognition(nextImage, nextCallback)
      } else {
        isProcessing = false
      }
    }
  }

  companion object {
    const val NAME = "PerchEyeModule"
  }
}

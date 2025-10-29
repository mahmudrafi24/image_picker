package com.example.image_picker

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Environment
import android.provider.MediaStore
import android.util.Log
import java.io.File
import java.io.IOException
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import androidx.core.content.FileProvider

class MainActivity : FlutterActivity() {
  private val PICKER_CHANNEL = "custom_picker_channel"
  private val PATH_CHANNEL = "custom_path_channel"
  private val PICK_IMAGE_REQUEST = 1
  private val CAPTURE_IMAGE_REQUEST = 2
  private var currentChannelResult: MethodChannel.Result? = null
  private var currentPhotoPath: String? = null

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    
    // Image picker channel
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PICKER_CHANNEL).setMethodCallHandler { call, result ->
      if (call.method == "pickImage") {
        val source = call.argument<String>("source")
        currentChannelResult = result
        when (source) {
          "gallery" -> openGallery()
          "camera" -> openCamera()
          else -> result.notImplemented()
        }
      } else {
        result.notImplemented()
      }
    }
    
    // Path provider channel
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PATH_CHANNEL).setMethodCallHandler { call, result ->
      when (call.method) {
        "getTempDir" -> {
          result.success(cacheDir.absolutePath)
        }
        "getAppDocsDir" -> {
          result.success(filesDir.absolutePath)
        }
        else -> result.notImplemented()
      }
    }
  }

  private fun openGallery() {
    val intent = Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI)
    intent.type = "image/*"
    startActivityForResult(intent, PICK_IMAGE_REQUEST)
  }

  private fun openCamera() {
    val takePictureIntent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
    if (takePictureIntent.resolveActivity(packageManager) != null) {
      val photoFile: File? = try {
        createImageFile()
      } catch (ex: IOException) {
        Log.e("MainActivity", "Error creating file", ex)
        null
      }
      
      if (photoFile != null) {
        currentPhotoPath = photoFile.absolutePath
        val photoURI: Uri = FileProvider.getUriForFile(
          this,
          "${packageName}.fileprovider",
          photoFile
        )
        takePictureIntent.putExtra(MediaStore.EXTRA_OUTPUT, photoURI)
        startActivityForResult(takePictureIntent, CAPTURE_IMAGE_REQUEST)
      } else {
        currentChannelResult?.error("FILE_ERROR", "Failed to create image file", null)
        currentChannelResult = null
      }
    } else {
      currentChannelResult?.error("CAMERA_ERROR", "No camera app available", null)
      currentChannelResult = null
    }
  }

  private fun createImageFile(): File {
    val timeStamp: String = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.US).format(Date())
    val storageDir: File? = getExternalFilesDir(Environment.DIRECTORY_PICTURES)
    return File.createTempFile("JPEG_${timeStamp}_", ".jpg", storageDir)
  }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
    super.onActivityResult(requestCode, resultCode, data)
    val result = currentChannelResult
    
    if (resultCode == Activity.RESULT_OK) {
      when (requestCode) {
        PICK_IMAGE_REQUEST -> {
          val imageUri: Uri? = data?.data
          if (imageUri != null) {
            val filePathColumn = arrayOf(MediaStore.Images.Media.DATA)
            val cursor = contentResolver.query(imageUri, filePathColumn, null, null, null)
            cursor?.use {
              if (it.moveToFirst()) {
                val columnIndex = it.getColumnIndex(filePathColumn[0])
                if (columnIndex >= 0) {
                  val picturePath = it.getString(columnIndex)
                  result?.success(picturePath)
                } else {
                  // Fallback: use URI path
                  result?.success(imageUri.path)
                }
              } else {
                result?.success(null)
              }
            } ?: result?.success(imageUri.path)
          } else {
            result?.success(null)
          }
        }
        CAPTURE_IMAGE_REQUEST -> {
          result?.success(currentPhotoPath)
          currentPhotoPath = null
        }
      }
    } else {
      result?.success(null)
    }
    currentChannelResult = null
  }
}

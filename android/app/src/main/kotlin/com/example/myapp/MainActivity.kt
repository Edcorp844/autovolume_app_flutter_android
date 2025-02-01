package com.example.myapp

import android.Manifest
import android.content.ContentResolver
import android.content.Context
import android.content.pm.PackageManager
import android.database.Cursor
import android.media.AudioManager
import android.net.Uri
import android.util.Log
import android.provider.MediaStore
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.myapp/audio"
    private val REQUEST_CODE_PERMISSIONS = 1001

 override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAudioFiles" -> {
                     val audioFiles = getAudioFiles(this)
                      result.success(audioFiles)
                }
                
                "getCurrentVolume" -> result.success(getCurrentVolume())
                
                "setVolume" -> {
                    val volume = call.arguments as Double
                    setVolume(volume)
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }

     private fun getCurrentVolume(): Double {
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        val currentVolume = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC).toDouble()
        val maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC).toDouble()
        return currentVolume / maxVolume  // Normalize to 0.0 - 1.0
    }

    private fun setVolume(volume: Double) {
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        val maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
        val newVolume = (volume * maxVolume).toInt()  // Scale to actual system volume
        audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, newVolume, AudioManager.FLAG_SHOW_UI)
    }


    private fun checkPermissions(): Boolean {
        return ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.READ_EXTERNAL_STORAGE
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun requestPermissions() {
        ActivityCompat.requestPermissions(
            this,
            arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE),
            REQUEST_CODE_PERMISSIONS
        )
    }

   override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_CODE_PERMISSIONS) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                // Permissions granted, you can now fetch audio files
                val audioFiles = getAudioFiles(this)
                // Send the result back to Flutter
                MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("onAudioFilesFetched", audioFiles)
            } else {
                // Permissions denied
                MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("onPermissionsDenied", null)
            }
        }
    }

    
   private fun getAudioFiles(context: Context): String {
        val audioList = JSONArray()
        val contentResolver: ContentResolver = context.contentResolver
        val uri: Uri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
        Log.d("AudioFiles", "URI: $uri")

        val projection = arrayOf(
            MediaStore.Audio.Media.TITLE,
            MediaStore.Audio.Media.DATA,
            MediaStore.Audio.Media.ARTIST,
            MediaStore.Audio.Media.DURATION,
            MediaStore.Audio.Media.ALBUM,
            MediaStore.Audio.Media.ALBUM_ID
        )
        val cursor: Cursor? = contentResolver.query(uri, projection, null, null, null)

        if (cursor == null) {
            Log.e("AudioFiles", "Cursor is null. No audio files found.")
        } else {
            cursor.use {
                if (it.count == 0) {
                    Log.e("AudioFiles", "No audio files found in MediaStore.")
                }
                while (it.moveToNext()) {
                    val title = it.getString(it.getColumnIndexOrThrow(MediaStore.Audio.Media.TITLE))
                    val path = it.getString(it.getColumnIndexOrThrow(MediaStore.Audio.Media.DATA))
                    val artist = it.getString(it.getColumnIndexOrThrow(MediaStore.Audio.Media.ARTIST))
                    val duration = it.getLong(it.getColumnIndexOrThrow(MediaStore.Audio.Media.DURATION))
                    val album = it.getString(it.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM))
                    val albumId = it.getLong(it.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM_ID))

                    // Get the album art file path (if available)
                    val albumArtPath = getAlbumArtFilePath(context, albumId)

                    val audioObject = JSONObject().apply {
                        put("title", title)
                        put("path", path)
                        put("artist", artist)
                        put("duration", duration)
                        put("album", album)
                        put("albumArtPath", albumArtPath ?: "no_album_art") // Provide a fallback if no album art is found
                    }
                    audioList.put(audioObject)
                }
            }
        }

        return audioList.toString()
    }

// Helper function to get the album art file path
    fun getAlbumArtFilePath(context: Context, albumId: Long): String? {
        val contentResolver: ContentResolver = context.contentResolver
        val albumArtUri = Uri.parse("content://media/external/audio/albumart")
        val artUri = Uri.withAppendedPath(albumArtUri, albumId.toString())

        // Query the content provider to get the album art file path
        val cursor: Cursor? = contentResolver.query(artUri, arrayOf(MediaStore.Images.Media.DATA), null, null, null)

        var albumArtPath: String? = null
        cursor?.use {
            if (it.moveToFirst()) {
                // Get the file path of the album art
                albumArtPath = it.getString(it.getColumnIndexOrThrow(MediaStore.Images.Media.DATA))
            }
        }

        return albumArtPath  // Return the file path or null if no album art is found
    }

}
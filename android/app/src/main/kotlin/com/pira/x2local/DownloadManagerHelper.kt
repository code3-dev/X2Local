package com.pira.x2local

import android.app.DownloadManager
import android.content.Context
import android.net.Uri
import android.os.Environment
import androidx.core.content.getSystemService
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class DownloadManagerHelper(private val context: Context) {
    fun downloadFile(call: MethodCall, result: MethodChannel.Result) {
        try {
            val url = call.argument<String>("url") ?: return result.error("MISSING_URL", "URL is required", null)
            val fileName = call.argument<String>("fileName") ?: return result.error("MISSING_FILENAME", "FileName is required", null)
            
            val downloadManager = context.getSystemService(Context.DOWNLOAD_SERVICE) as DownloadManager
            
            val request = DownloadManager.Request(Uri.parse(url)).apply {
                setTitle(fileName)
                setDescription("Downloading file...")
                setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED)
                setDestinationInExternalPublicDir(Environment.DIRECTORY_DOWNLOADS, fileName)
            }
            
            val downloadId = downloadManager.enqueue(request)
            result.success(downloadId.toString())
        } catch (e: Exception) {
            result.error("DOWNLOAD_ERROR", e.message, e.toString())
        }
    }
    
    fun checkDownloadStatus(call: MethodCall, result: MethodChannel.Result) {
        try {
            val downloadId = call.argument<String>("downloadId")?.toLong() ?: return result.error("MISSING_ID", "Download ID is required", null)
            
            val downloadManager = context.getSystemService(Context.DOWNLOAD_SERVICE) as DownloadManager
            val query = DownloadManager.Query().setFilterById(downloadId)
            val cursor = downloadManager.query(query)
            
            if (cursor.moveToFirst()) {
                val statusIndex = cursor.getColumnIndex(DownloadManager.COLUMN_STATUS)
                val status = cursor.getInt(statusIndex)
                
                when (status) {
                    DownloadManager.STATUS_SUCCESSFUL -> result.success("completed")
                    DownloadManager.STATUS_FAILED -> result.success("failed")
                    DownloadManager.STATUS_RUNNING -> result.success("running")
                    DownloadManager.STATUS_PENDING -> result.success("pending")
                    DownloadManager.STATUS_PAUSED -> result.success("paused")
                    else -> result.success("unknown")
                }
            } else {
                result.success("not_found")
            }
            cursor.close()
        } catch (e: Exception) {
            result.error("STATUS_ERROR", e.message, e.toString())
        }
    }
}
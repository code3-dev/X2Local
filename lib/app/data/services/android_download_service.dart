import 'package:flutter/services.dart';
import 'dart:io' show Platform;

class AndroidDownloadService {
  static const platform = MethodChannel('x2local/download_manager');

  /// Download a file using Android's native DownloadManager
  static Future<String?> downloadFile({
    required String url,
    required String fileName,
  }) async {
    if (!Platform.isAndroid) {
      throw UnsupportedError('This method is only available on Android');
    }

    try {
      final String downloadId = await platform.invokeMethod('downloadFile', {
        'url': url,
        'fileName': fileName,
      });
      return downloadId;
    } on PlatformException catch (e) {
      throw Exception('Failed to download file: ${e.message}');
    }
  }

  /// Check the status of a download
  static Future<String?> checkDownloadStatus(String downloadId) async {
    if (!Platform.isAndroid) {
      throw UnsupportedError('This method is only available on Android');
    }

    try {
      final String status = await platform.invokeMethod('checkDownloadStatus', {
        'downloadId': downloadId,
      });
      return status;
    } on PlatformException catch (e) {
      throw Exception('Failed to check download status: ${e.message}');
    }
  }
}
import 'package:get/get.dart';
import 'package:x2local/app/data/models/x_downloader_response.dart';
import 'package:x2local/app/data/repositories/x_downloader_repository.dart';
import 'package:x2local/app/data/providers/x_downloader_provider.dart';
import 'package:dio/dio.dart' as dio;
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

// Import Android download service for native downloads
import 'package:x2local/app/data/services/android_download_service.dart';

class HomeController extends GetxController {
  final XDownloaderRepository repository = XDownloaderRepository(
    provider: XDownloaderProvider(),
  );

  late RxString url;
  late RxString selectedType;
  late RxBool isLoading;
  late RxString downloadStatus;
  late RxDouble downloadProgress;
  late RxString downloadedFilePath;
  late RxBool showResult;
  late RxBool showFormats;
  late Rx<XDownloaderResponse?> response;

  StreamSubscription? _intentDataStreamSubscription;

  @override
  void onInit() {
    super.onInit();
    url = ''.obs;
    selectedType = '.mp4'.obs;
    isLoading = false.obs;
    downloadStatus = ''.obs;
    downloadProgress = 0.0.obs;
    downloadedFilePath = ''.obs;
    showResult = false.obs;
    showFormats = false.obs;
    response = (null as XDownloaderResponse?).obs;

    // Check clipboard for URL when app starts
    _checkClipboardForUrl();

    // Listen for shared intents
    _listenForSharedIntents();
  }

  Future<void> _checkClipboardForUrl() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      final clipboardText = clipboardData?.text ?? '';

      // Check if clipboard content is a valid X/Twitter URL
      if ((clipboardText.startsWith('https://x.com/') ||
          clipboardText.startsWith('http://x.com/') ||
          clipboardText.startsWith('https://twitter.com/') ||
          clipboardText.startsWith('http://twitter.com/'))) {
        url.value = clipboardText;
      }
    } catch (e) {
      // Silently ignore clipboard errors
    }
  }

  void _listenForSharedIntents() {
    // Listen for shared intents
    _intentDataStreamSubscription = ReceiveSharingIntent.instance
        .getMediaStream()
        .listen(
          (List<SharedMediaFile> value) {
            // Process shared media files
            for (var file in value) {
              // Check if shared content is a valid X/Twitter URL
              if ((file.type == SharedMediaType.url ||
                      file.type == SharedMediaType.text) &&
                  (file.path.startsWith('https://x.com/') ||
                      file.path.startsWith('http://x.com/') ||
                      file.path.startsWith('https://twitter.com/') ||
                      file.path.startsWith('http://twitter.com/'))) {
                url.value = file.path;

                // Show confirmation dialog
                _showShareConfirmationDialog(file.path);
              }
            }
          },
          onError: (err) {
            // Handle error
          },
        );

    // Get the initial shared text if app was started from a share intent
    ReceiveSharingIntent.instance.getInitialMedia().then((
      List<SharedMediaFile> value,
    ) {
      // Process initial shared media files
      for (var file in value) {
        // Check if shared content is a valid X/Twitter URL
        if ((file.type == SharedMediaType.url ||
                file.type == SharedMediaType.text) &&
            (file.path.startsWith('https://x.com/') ||
                file.path.startsWith('http://x.com/') ||
                file.path.startsWith('https://twitter.com/') ||
                file.path.startsWith('http://twitter.com/'))) {
          url.value = file.path;

          // Show confirmation dialog
          _showShareConfirmationDialog(file.path);
        }
      }
    });
  }

  void _showShareConfirmationDialog(String sharedUrl) {
    Get.defaultDialog(
      title: "Shared Link Detected",
      middleText:
          "Would you like to download content from this link?\n\n$sharedUrl",
      confirm: ElevatedButton(
        onPressed: () {
          Get.back();
          if (sharedUrl.contains('/photo/') || sharedUrl.contains('/video/')) {
            selectedType.value = '.mp4';
          }
          Future.delayed(const Duration(milliseconds: 500), () {
            requestDownload();
          });
        },
        child: const Text("Yes, Download"),
      ),
      cancel: ElevatedButton(
        onPressed: () {
          Get.back();
        },
        child: const Text("Cancel"),
      ),
    );
  }

  void updateUrl(String value) {
    url.value = value;
  }

  void updateType(String type) {
    selectedType.value = type;
  }

  Future<void> requestDownload() async {
    if (url.isEmpty) {
      Get.snackbar('Error', 'Please enter a valid X (Twitter) URL');
      return;
    }

    isLoading.value = true;
    downloadStatus.value = 'Requesting download...';
    showResult.value = false;
    showFormats.value = false;
    response.value = null;

    try {
      final result = await repository.requestDownload(
        url.value,
        selectedType.value,
      );
      response.value = result;

      if (result.status == 'finished' || result.status == 'starting') {
        downloadStatus.value = 'Ready to download';
        showFormats.value = true;
      } else {
        downloadStatus.value = 'Download preparation failed';
      }
    } catch (e) {
      downloadStatus.value = 'Error: ${e.toString()}';
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> downloadInBrowser(String downloadUrl) async {
    try {
      final uri = Uri.parse(downloadUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('Error', 'Could not launch URL');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to open browser: ${e.toString()}');
    }
  }

  Future<String> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      try {
        // Try to get the external storage directory
        final directory = await getExternalStorageDirectory();
        if (directory != null) {
          // For Android 10+, we should use the app-specific directory or Downloads
          if (Platform.version.startsWith('10') ||
              Platform.version.startsWith('11') ||
              Platform.version.startsWith('12') ||
              Platform.version.startsWith('13') ||
              (Platform.version.length > 0 &&
                  int.tryParse(Platform.version.split('.').first) != null &&
                  int.tryParse(Platform.version.split('.').first)! >= 10)) {
            // Use a subdirectory in the app's external storage
            final downloadDir = Directory('${directory.path}/Download');
            if (!(await downloadDir.exists())) {
              await downloadDir.create(recursive: true);
            }
            return downloadDir.path;
          } else {
            // For older Android versions, navigate to the Downloads folder
            final downloadDir = Directory('${directory.path}/../Download');
            if (await downloadDir.exists()) {
              return downloadDir.path;
            }
          }
        }
      } catch (e) {
        // If there's an error, fall back to the app documents directory
        print('Error getting external storage directory: $e');
      }

      // Fallback to app documents directory
      final appDocDir = await getApplicationDocumentsDirectory();
      return appDocDir.path;
    } else if (Platform.isIOS) {
      final appDocDir = await getApplicationDocumentsDirectory();
      return appDocDir.path;
    } else if (Platform.isWindows) {
      // For Windows, use the user's Downloads folder
      final homeDir = Platform.environment['USERPROFILE'] ?? '.';
      return '$homeDir\\Downloads';
    } else {
      final appDocDir = await getApplicationDocumentsDirectory();
      return appDocDir.path;
    }
  }

  Future<void> downloadInAppForSingleFormat() async {
    if (response.value == null) {
      Get.snackbar('Error', 'No download data available');
      return;
    }

    try {
      if (Platform.isAndroid) {
        final downloadUrl =
            'https://${response.value!.host}/${response.value!.filename}';
        final fileName = response.value!.filename.split('/').last;

        try {
          final downloadId = await AndroidDownloadService.downloadFile(
            url: downloadUrl,
            fileName: fileName,
          );

          if (downloadId != null) {
            downloadedFilePath.value = "Download started with ID: $downloadId";
            downloadStatus.value = 'Download started!';
            showResult.value = true;
            Get.snackbar('Success', 'Download started in the background');
          } else {
            throw Exception('Failed to start download');
          }
        } catch (e) {
          Get.snackbar('Info', 'Using fallback download method');
          await _downloadInAppForSingleFormatFallback();
        }
      } else {
        await _downloadInAppForSingleFormatFallback();
      }
    } catch (e) {
      downloadStatus.value = 'Download error: ${e.toString()}';
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> _downloadInAppForSingleFormatFallback() async {
    if (Platform.isAndroid) {
      final storageStatus = await Permission.storage.request();
      if (!storageStatus.isGranted) {
        Get.snackbar(
          'Permission Denied',
          'Storage permission is required to download files',
        );
        return;
      }
    } else if (Platform.isIOS) {
      // ...
    }

    final downloadUrl =
        'https://${response.value!.host}/${response.value!.filename}';
    downloadStatus.value = 'Downloading...';
    final downloadPath = await _getDownloadDirectory();
    final downloadDir = Directory(downloadPath);
    if (!(await downloadDir.exists())) {
      await downloadDir.create(recursive: true);
    }
    final fileName = response.value!.filename.split('/').last;
    final filePath =
        '${downloadDir.path}${Platform.isWindows ? '\\' : '/'}$fileName';

    dio.Dio dioClient = dio.Dio();
    dio.Response dioResponse = await dioClient.download(
      downloadUrl,
      filePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          downloadProgress.value = (received / total) * 100;
        }
      },
    );

    if (dioResponse.statusCode == 200) {
      downloadedFilePath.value = filePath;
      downloadStatus.value = 'Download completed!';
      showResult.value = true;
      Get.snackbar('Success', 'File downloaded successfully');
    } else {
      downloadStatus.value = 'Download failed';
      Get.snackbar('Error', 'Failed to download file');
    }
  }

  Future<void> downloadInApp(Format format) async {
    try {
      // Use native Android download manager for Android
      if (Platform.isAndroid) {
        final downloadUrl = 'https://${format.host}/${format.filename}';

        // Extract filename from the URL
        final fileName = format.filename.split('/').last;

        try {
          final downloadId = await AndroidDownloadService.downloadFile(
            url: downloadUrl,
            fileName: fileName,
          );

          if (downloadId != null) {
            downloadedFilePath.value = "Download started with ID: $downloadId";
            downloadStatus.value = 'Download started!';
            showResult.value = true;
            Get.snackbar('Success', 'Download started in the background');
          } else {
            throw Exception('Failed to start download');
          }
        } catch (e) {
          // Fallback to the original method if native download fails
          Get.snackbar('Info', 'Using fallback download method');
          await _downloadInAppFallback(format);
        }
      } else {
        // For non-Android platforms, use the original method
        await _downloadInAppFallback(format);
      }
    } catch (e) {
      downloadStatus.value = 'Download error: ${e.toString()}';
      Get.snackbar('Error', e.toString());
    }
  }

  // Original download method as fallback
  Future<void> _downloadInAppFallback(Format format) async {
    // Request appropriate permissions based on platform
    if (Platform.isAndroid) {
      // Request storage permissions for all Android versions
      final storageStatus = await Permission.storage.request();
      if (!storageStatus.isGranted) {
        Get.snackbar(
          'Permission Denied',
          'Storage permission is required to download files',
        );
        return;
      }
    } else if (Platform.isIOS) {
      // iOS doesn't need special permissions for saving to app documents
    }

    final downloadUrl = 'https://${format.host}/${format.filename}';
    downloadStatus.value = 'Downloading...';

    // Get download directory based on platform
    final downloadPath = await _getDownloadDirectory();
    final downloadDir = Directory(downloadPath);

    // Ensure directory exists
    if (!(await downloadDir.exists())) {
      await downloadDir.create(recursive: true);
    }

    // Create filename
    final fileName = format.filename.split('/').last;
    final filePath =
        '${downloadDir.path}${Platform.isWindows ? '\\' : '/'}$fileName';

    // Download with progress tracking
    dio.Dio dioClient = dio.Dio();
    dio.Response dioResponse = await dioClient.download(
      downloadUrl,
      filePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          downloadProgress.value = (received / total) * 100;
        }
      },
    );

    if (dioResponse.statusCode == 200) {
      downloadedFilePath.value = filePath;
      downloadStatus.value = 'Download completed!';
      showResult.value = true;
      Get.snackbar('Success', 'File downloaded successfully');

      // On iOS, we might want to show a dialog with the file path
      if (Platform.isIOS) {
        Get.defaultDialog(
          title: "Download Complete",
          middleText: "File saved to: $filePath",
          textConfirm: "OK",
          onConfirm: () => Get.back(),
        );
      }
    } else {
      downloadStatus.value = 'Download failed';
      Get.snackbar('Error', 'Failed to download file');
    }
  }

  Future<void> copyLink(String downloadUrl) async {
    await Clipboard.setData(ClipboardData(text: downloadUrl));
    Get.snackbar('Success', 'Link copied to clipboard');
  }

  @override
  void onClose() {
    _intentDataStreamSubscription?.cancel();
    super.onClose();
  }

  void resetForm() {
    url.value = '';
    selectedType.value = '.mp4';
    downloadStatus.value = '';
    downloadProgress.value = 0.0;
    downloadedFilePath.value = '';
    showResult.value = false;
    showFormats.value = false;
    response.value = null;
  }

  /// Processes format label to make it more user-friendly (e.g., "720p" instead of "720x1280")
  String processFormatLabel(String label) {
    // Handle common resolution formats
    if (label.contains('x')) {
      final parts = label.split('x');
      if (parts.length == 2) {
        // Extract the height (second part) and add 'p'
        final height = parts[1];
        return '${height}p';
      }
    }
    // Return original label if it doesn't match expected pattern
    return label;
  }

  /// Sorts formats by quality (higher resolutions first)
  List<Format> sortFormatsByQuality(List<Format> formats) {
    // Create a copy of the list to avoid modifying the original
    final sortedFormats = List<Format>.from(formats);

    sortedFormats.sort((a, b) {
      // Extract numeric values from labels for comparison
      final aResolution = _extractResolution(a.label);
      final bResolution = _extractResolution(b.label);

      // Sort in descending order (higher resolution first)
      return bResolution.compareTo(aResolution);
    });

    return sortedFormats;
  }

  /// Extracts numeric resolution value from label for sorting
  int _extractResolution(String label) {
    // Try to extract resolution value from formats like "720x1280" or "720p"
    if (label.contains('x')) {
      final parts = label.split('x');
      if (parts.length == 2) {
        // Return the height (second part) as integer
        return int.tryParse(parts[1]) ?? 0;
      }
    } else if (label.contains('p')) {
      // For formats like "720p", extract the numeric part
      final numericPart = label.replaceAll(RegExp(r'[^0-9]'), '');
      return int.tryParse(numericPart) ?? 0;
    }
    // Return 0 if unable to extract resolution
    return 0;
  }
}

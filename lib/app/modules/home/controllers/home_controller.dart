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
          Get.back(); // Close dialog
          // Auto-select the download type based on content (simplified logic)
          if (sharedUrl.contains('/photo/') || sharedUrl.contains('/video/')) {
            selectedType.value = '.mp4'; // Assume video
          }
          // Trigger download automatically
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
        await launchUrl(uri);
      } else {
        Get.snackbar('Error', 'Could not launch URL');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to open browser: ${e.toString()}');
    }
  }

  Future<void> downloadInAppForSingleFormat() async {
    if (response.value == null) {
      Get.snackbar('Error', 'No download data available');
      return;
    }

    try {
      // Request storage permission
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          Get.snackbar(
            'Permission Denied',
            'Storage permission is required to download files',
          );
          return;
        }
      }

      final downloadUrl =
          'https://${response.value!.host}/${response.value!.filename}';
      downloadStatus.value = 'Downloading...';

      // Get download directory based on platform
      Directory? downloadDir;
      if (Platform.isAndroid) {
        downloadDir = Directory('/storage/emulated/0/Download');
      } else if (Platform.isWindows) {
        // For Windows, use the user's Downloads folder
        final homeDir = Platform.environment['USERPROFILE'] ?? '.';
        downloadDir = Directory('$homeDir\\Downloads');
      } else {
        downloadDir = await getApplicationDocumentsDirectory();
      }

      // Ensure directory exists
      if (!(await downloadDir.exists())) {
        await downloadDir.create(recursive: true);
      }

      // Create filename
      final fileName = response.value!.filename.split('/').last;
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
      } else {
        downloadStatus.value = 'Download failed';
        Get.snackbar('Error', 'Failed to download file');
      }
    } catch (e) {
      downloadStatus.value = 'Download error: ${e.toString()}';
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> downloadInApp(Format format) async {
    try {
      // Request storage permission
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          Get.snackbar(
            'Permission Denied',
            'Storage permission is required to download files',
          );
          return;
        }
      }

      final downloadUrl = 'https://${format.host}/${format.filename}';
      downloadStatus.value = 'Downloading...';

      // Get download directory based on platform
      Directory? downloadDir;
      if (Platform.isAndroid) {
        downloadDir = Directory('/storage/emulated/0/Download');
      } else if (Platform.isWindows) {
        // For Windows, use the user's Downloads folder
        final homeDir = Platform.environment['USERPROFILE'] ?? '.';
        downloadDir = Directory('$homeDir\\Downloads');
      } else {
        downloadDir = await getApplicationDocumentsDirectory();
      }

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
      } else {
        downloadStatus.value = 'Download failed';
        Get.snackbar('Error', 'Failed to download file');
      }
    } catch (e) {
      downloadStatus.value = 'Download error: ${e.toString()}';
      Get.snackbar('Error', e.toString());
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
}

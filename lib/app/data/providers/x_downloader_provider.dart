import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:x2local/app/data/models/x_downloader_response.dart';

class XDownloaderProvider {
  static const String baseUrl = 'https://api.x-downloader.com';
  static const String requestEndpoint = '/request';

  Future<XDownloaderResponse> requestDownload(String url, String type) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$requestEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'url': url, 'type': type}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return XDownloaderResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to request download: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error requesting download: $e');
    }
  }

  Future<String> getDownloadUrl(XDownloaderResponse response) async {
    // For video downloads
    if (response.type == '.mp4') {
      return 'https://${response.host}/${response.filename}';
    }
    // For audio downloads
    else if (response.type == '.mp3') {
      return 'https://${response.host}/${response.filename}';
    }
    // For other formats, use the first available format
    else if (response.formats.isNotEmpty) {
      final format = response.formats.first;
      return 'https://${format.host}/${format.filename}';
    } else {
      throw Exception('No download URL available');
    }
  }
}

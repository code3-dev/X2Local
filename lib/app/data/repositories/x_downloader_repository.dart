import 'package:x2local/app/data/models/x_downloader_response.dart';
import 'package:x2local/app/data/providers/x_downloader_provider.dart';

class XDownloaderRepository {
  final XDownloaderProvider provider;

  XDownloaderRepository({required this.provider});

  Future<XDownloaderResponse> requestDownload(String url, String type) async {
    return await provider.requestDownload(url, type);
  }

  Future<String> getDownloadUrl(XDownloaderResponse response) async {
    return await provider.getDownloadUrl(response);
  }
}

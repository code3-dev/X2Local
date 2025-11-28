class XDownloaderResponse {
  final String id;
  final String url;
  final String urlHash;
  final String originalUrl;
  final String? author;
  final String platform;
  final String type;
  final String status;
  final String host;
  final String filename;
  final String prefix;
  final String thumbnail;
  final int timestamp;
  final String title;
  final String titleFilename;
  final String description;
  final List<Format> formats;

  XDownloaderResponse({
    required this.id,
    required this.url,
    required this.urlHash,
    required this.originalUrl,
    this.author,
    required this.platform,
    required this.type,
    required this.status,
    required this.host,
    required this.filename,
    required this.prefix,
    required this.thumbnail,
    required this.timestamp,
    required this.title,
    required this.titleFilename,
    required this.description,
    required this.formats,
  });

  factory XDownloaderResponse.fromJson(Map<String, dynamic> json) {
    // Handle formats field which might be null
    List<Format> formats = [];
    if (json['formats'] != null) {
      var formatsList = json['formats'] as List;
      formats = formatsList.map((i) => Format.fromJson(i)).toList();
    }

    return XDownloaderResponse(
      id: json['_id'] ?? '',
      url: json['url'] ?? '',
      urlHash: json['urlHash'] ?? '',
      originalUrl: json['originalUrl'] ?? '',
      author: json['author'],
      platform: json['platform'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      host: json['host'] ?? '',
      filename: json['filename'] ?? '',
      prefix: json['prefix'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      timestamp: json['timestamp'] ?? 0,
      title: json['title'] ?? '',
      titleFilename: json['titleFilename'] ?? '',
      description: json['description'] ?? '',
      formats: formats,
    );
  }

  factory XDownloaderResponse.empty() {
    return XDownloaderResponse(
      id: '',
      url: '',
      urlHash: '',
      originalUrl: '',
      platform: '',
      type: '',
      status: '',
      host: '',
      filename: '',
      prefix: '',
      thumbnail: '',
      timestamp: 0,
      title: '',
      titleFilename: '',
      description: '',
      formats: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'url': url,
      'urlHash': urlHash,
      'originalUrl': originalUrl,
      'author': author,
      'platform': platform,
      'type': type,
      'status': status,
      'host': host,
      'filename': filename,
      'prefix': prefix,
      'thumbnail': thumbnail,
      'timestamp': timestamp,
      'title': title,
      'titleFilename': titleFilename,
      'description': description,
      'formats': formats.map((format) => format.toJson()).toList(),
    };
  }
}

class Format {
  final String label;
  final String filename;
  final String host;

  Format({required this.label, required this.filename, required this.host});

  factory Format.fromJson(Map<String, dynamic> json) {
    return Format(
      label: json['label'] ?? '',
      filename: json['filename'] ?? '',
      host: json['host'] ?? '',
    );
  }

  factory Format.empty() {
    return Format(label: '', filename: '', host: '');
  }

  Map<String, dynamic> toJson() {
    return {'label': label, 'filename': filename, 'host': host};
  }
}

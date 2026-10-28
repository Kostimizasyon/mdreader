class MarkdownDocument {
  final String path;
  final String name;
  final int sizeBytes;
  final String? content;
  final bool isCached;
  final DateTime? cachedAt;

  const MarkdownDocument({
    required this.path,
    required this.name,
    required this.sizeBytes,
    this.content,
    this.isCached = false,
    this.cachedAt,
  });

  double get sizeInKb => sizeBytes / 1024.0;

  String get formattedSize {
    if (sizeBytes < 1024) {
      return '$sizeBytes B';
    }
    return '${sizeInKb.toStringAsFixed(1)} KB';
  }

  MarkdownDocument copyWith({
    String? path,
    String? name,
    int? sizeBytes,
    String? content,
    bool? isCached,
    DateTime? cachedAt,
  }) {
    return MarkdownDocument(
      path: path ?? this.path,
      name: name ?? this.name,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      content: content ?? this.content,
      isCached: isCached ?? this.isCached,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'name': name,
      'sizeBytes': sizeBytes,
      'content': content,
      'isCached': isCached,
      'cachedAt': cachedAt?.toIso8601String(),
    };
  }

  factory MarkdownDocument.fromJson(Map<String, dynamic> json) {
    return MarkdownDocument(
      path: json['path'] as String,
      name: json['name'] as String,
      sizeBytes: json['sizeBytes'] as int? ?? 0,
      content: json['content'] as String?,
      isCached: json['isCached'] as bool? ?? false,
      cachedAt: json['cachedAt'] != null
          ? DateTime.parse(json['cachedAt'] as String)
          : null,
    );
  }
}
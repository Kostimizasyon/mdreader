enum RepoNodeType { directory, file }

class RepoNode {
  final String name;
  final String path;
  final RepoNodeType type;
  final int sizeBytes;
  final String? sha;
  final List<RepoNode> children;

  RepoNode({
    required this.name,
    required this.path,
    required this.type,
    this.sizeBytes = 0,
    this.sha,
    List<RepoNode>? children,
  }) : children = children ?? [];

  bool get isDirectory => type == RepoNodeType.directory;
  bool get isFile => type == RepoNodeType.file;

  int get childCount => children.length;

  String get formattedSize {
    if (isDirectory) return '$childCount items';
    if (sizeBytes < 1024) return '$sizeBytes B';
    return '${(sizeBytes / 1024.0).toStringAsFixed(1)} KB';
  }

  void sortChildren() {
    children.sort((a, b) {
      if (a.isDirectory && !b.isDirectory) return -1;
      if (!a.isDirectory && b.isDirectory) return 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    for (final child in children) {
      if (child.isDirectory) {
        child.sortChildren();
      }
    }
  }
}
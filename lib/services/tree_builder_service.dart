import '../data_models/repo_node.dart';
import 'github_service.dart';

class TreeBuilderService {
  RepoNode buildMarkdownTree(List<GithubTreeEntry> entries) {
    final root = RepoNode(
      name: 'root',
      path: '',
      type: RepoNodeType.directory,
    );

    final markdownBlobs = entries.where((entry) {
      return entry.type == 'blob' && entry.path.toLowerCase().endsWith('.md');
    }).toList();

    for (final blob in markdownBlobs) {
      final segments = blob.path.split('/').where((s) => s.isNotEmpty).toList();
      if (segments.isEmpty) continue;

      RepoNode currentNode = root;
      String currentPath = '';

      for (int i = 0; i < segments.length; i++) {
        final segment = segments[i];
        currentPath = currentPath.isEmpty ? segment : '$currentPath/$segment';
        final isLast = i == segments.length - 1;

        if (isLast) {
          currentNode.children.add(
            RepoNode(
              name: segment,
              path: currentPath,
              type: RepoNodeType.file,
              sizeBytes: blob.size,
              sha: blob.sha,
            ),
          );
        } else {
          RepoNode? existingDir;
          for (final child in currentNode.children) {
            if (child.isDirectory && child.name == segment) {
              existingDir = child;
              break;
            }
          }

          if (existingDir == null) {
            existingDir = RepoNode(
              name: segment,
              path: currentPath,
              type: RepoNodeType.directory,
            );
            currentNode.children.add(existingDir);
          }
          currentNode = existingDir;
        }
      }
    }

    root.sortChildren();
    return root;
  }

  RepoNode? findNodeByPath(RepoNode root, String targetPath) {
    if (targetPath.isEmpty) return root;
    final segments = targetPath.split('/').where((s) => s.isNotEmpty).toList();

    RepoNode current = root;
    for (final segment in segments) {
      RepoNode? match;
      for (final child in current.children) {
        if (child.name == segment) {
          match = child;
          break;
        }
      }
      if (match == null) return null;
      current = match;
    }
    return current;
  }

  int countMarkdownFiles(RepoNode node) {
    if (node.isFile) return 1;
    int total = 0;
    for (final child in node.children) {
      total += countMarkdownFiles(child);
    }
    return total;
  }
}
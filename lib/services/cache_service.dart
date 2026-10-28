import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../data_models/github_repo.dart';
import 'github_service.dart';

class CacheService {
  Future<Directory> _getRepoCacheDir(GithubRepo repo) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final repoDir = Directory('${docsDir.path}/repo_cache/${repo.cacheKey}');
    if (!await repoDir.exists()) {
      await repoDir.create(recursive: true);
    }
    return repoDir;
  }

  Future<File> _getMarkdownFile(GithubRepo repo, String relativePath) async {
    final repoDir = await _getRepoCacheDir(repo);
    final sanitizedPath = relativePath.replaceAll('..', '');
    final file = File('${repoDir.path}/files/$sanitizedPath');
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }
    return file;
  }

  Future<bool> isMarkdownCached(GithubRepo repo, String relativePath) async {
    final file = await _getMarkdownFile(repo, relativePath);
    return file.exists();
  }

  Future<String?> getCachedMarkdown(GithubRepo repo, String relativePath) async {
    final file = await _getMarkdownFile(repo, relativePath);
    if (await file.exists()) {
      return file.readAsString();
    }
    return null;
  }

  Future<void> cacheMarkdown(
      GithubRepo repo,
      String relativePath,
      String content,
      ) async {
    final file = await _getMarkdownFile(repo, relativePath);
    await file.writeAsString(content, flush: true);
  }

  Future<void> cacheTreeEntries(
      GithubRepo repo,
      List<GithubTreeEntry> entries,
      ) async {
    final repoDir = await _getRepoCacheDir(repo);
    final treeFile = File('${repoDir.path}/tree_manifest.json');
    final serialized = entries
        .map((e) => {
      'path': e.path,
      'type': e.type,
      'size': e.size,
      'sha': e.sha,
    })
        .toList();
    await treeFile.writeAsString(jsonEncode(serialized), flush: true);
  }

  Future<List<GithubTreeEntry>?> getCachedTreeEntries(GithubRepo repo) async {
    final repoDir = await _getRepoCacheDir(repo);
    final treeFile = File('${repoDir.path}/tree_manifest.json');
    if (!await treeFile.exists()) return null;

    final raw = await treeFile.readAsString();
    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => GithubTreeEntry.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> clearRepoCache(GithubRepo repo) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final repoDir = Directory('${docsDir.path}/repo_cache/${repo.cacheKey}');
    if (await repoDir.exists()) {
      await repoDir.delete(recursive: true);
    }
  }
}
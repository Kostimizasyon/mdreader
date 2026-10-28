import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data_models/github_repo.dart';

class GithubApiException implements Exception {
  final String message;
  final int? statusCode;

  GithubApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class GithubTreeEntry {
  final String path;
  final String type;
  final int size;
  final String sha;

  const GithubTreeEntry({
    required this.path,
    required this.type,
    required this.size,
    required this.sha,
  });

  factory GithubTreeEntry.fromJson(Map<String, dynamic> json) {
    return GithubTreeEntry(
      path: json['path'] as String? ?? '',
      type: json['type'] as String? ?? 'blob',
      size: json['size'] as int? ?? 0,
      sha: json['sha'] as String? ?? '',
    );
  }
}

class GithubService {
  static const String privateRepoWarning =
      'This repository is private or does not exist. Cannot fetch private repositories.';

  final http.Client _client;

  GithubService({http.Client? client}) : _client = client ?? http.Client();

  ({String owner, String repo}) parseRepoInput(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      throw GithubApiException('Repository input cannot be empty.');
    }

    String cleaned = trimmed;
    if (cleaned.startsWith('http://') || cleaned.startsWith('https://')) {
      final uri = Uri.tryParse(cleaned);
      if (uri == null || !uri.host.contains('github.com')) {
        throw GithubApiException('Invalid GitHub URL provided.');
      }
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segments.length < 2) {
        throw GithubApiException('URL must include both owner and repository name.');
      }
      final owner = segments[0];
      var repo = segments[1];
      if (repo.endsWith('.git')) {
        repo = repo.substring(0, repo.length - 4);
      }
      return (owner: owner, repo: repo);
    }

    final parts = cleaned.split('/').where((s) => s.isNotEmpty).toList();
    if (parts.length != 2) {
      throw GithubApiException('Use the format "owner/repo" or a full GitHub URL.');
    }

    var repoName = parts[1];
    if (repoName.endsWith('.git')) {
      repoName = repoName.substring(0, repoName.length - 4);
    }

    return (owner: parts[0], repo: repoName);
  }

  Future<GithubRepo> verifyAndFetchRepo(String rawInput) async {
    final parsed = parseRepoInput(rawInput);
    final uri = Uri.parse('https://api.github.com/repos/${parsed.owner}/${parsed.repo}');

    final response = await _client.get(uri, headers: _defaultHeaders);
    _inspectResponseErrors(response);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final isPrivate = data['private'] as bool? ?? false;
    if (isPrivate) {
      throw GithubApiException(privateRepoWarning, statusCode: 404);
    }

    final defaultBranch = data['default_branch'] as String? ?? 'main';
    final ownerLogin = (data['owner'] as Map<String, dynamic>?)?['login'] as String? ?? parsed.owner;
    final repoName = data['name'] as String? ?? parsed.repo;

    return GithubRepo(
      owner: ownerLogin,
      name: repoName,
      defaultBranch: defaultBranch,
      isActive: true,
      lastSyncedAt: DateTime.now(),
    );
  }

  Future<List<GithubTreeEntry>> fetchRecursiveTree(GithubRepo repo) async {
    final uri = Uri.parse(
      'https://api.github.com/repos/${repo.owner}/${repo.name}/git/trees/${repo.defaultBranch}?recursive=1',
    );

    final response = await _client.get(uri, headers: _defaultHeaders);
    _inspectResponseErrors(response);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final treeList = data['tree'] as List<dynamic>? ?? [];

    return treeList
        .map((item) => GithubTreeEntry.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<String> fetchRawMarkdown({
    required GithubRepo repo,
    required String filePath,
  }) async {
    final encodedPath = filePath.split('/').map(Uri.encodeComponent).join('/');
    final uri = Uri.parse(
      'https://raw.githubusercontent.com/${repo.owner}/${repo.name}/${repo.defaultBranch}/$encodedPath',
    );

    final response = await _client.get(uri);
    if (response.statusCode == 404 || response.statusCode == 403) {
      throw GithubApiException(privateRepoWarning, statusCode: response.statusCode);
    }
    if (response.statusCode != 200) {
      throw GithubApiException(
        'Failed to load raw Markdown content (HTTP ${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }

    return utf8.decode(response.bodyBytes);
  }

  void _inspectResponseErrors(http.Response response) {
    final remaining = response.headers['x-ratelimit-remaining'];
    if (remaining == '0') {
      final resetEpoch = int.tryParse(response.headers['x-ratelimit-reset'] ?? '');
      String resetInfo = '';
      if (resetEpoch != null) {
        final resetTime = DateTime.fromMillisecondsSinceEpoch(resetEpoch * 1000);
        final minutes = resetTime.difference(DateTime.now()).inMinutes;
        if (minutes > 0) {
          resetInfo = ' Try again in $minutes minutes.';
        }
      }
      throw GithubApiException(
        'GitHub API rate limit exceeded.$resetInfo',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode == 404 || response.statusCode == 403) {
      throw GithubApiException(privateRepoWarning, statusCode: response.statusCode);
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw GithubApiException(
        'GitHub API error (HTTP ${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }
  }

  Map<String, String> get _defaultHeaders => {
    'Accept': 'application/vnd.github.v3+json',
    'User-Agent': 'GithubMarkdownExplorerFlutterApp',
  };
}
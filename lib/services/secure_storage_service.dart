import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data_models/github_repo.dart';

class MaxRepoLimitException implements Exception {
  final String message;
  MaxRepoLimitException([
    this.message = 'Maximum limit of 3 repositories reached. Please remove an existing repository first.',
  ]);

  @override
  String toString() => message;
}

class SecureStorageService {
  static const String _reposKey = 'saved_github_repos';
  static const int maxRepos = 3;

  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
      const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      );

  Future<List<GithubRepo>> getSavedRepos() async {
    final rawJson = await _storage.read(key: _reposKey);
    if (rawJson == null || rawJson.isEmpty) {
      return [];
    }
    final List<dynamic> decoded = jsonDecode(rawJson) as List<dynamic>;
    return decoded
        .map((item) => GithubRepo.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<GithubRepo?> getActiveRepo() async {
    final repos = await getSavedRepos();
    if (repos.isEmpty) return null;
    for (final repo in repos) {
      if (repo.isActive) return repo;
    }
    return repos.first;
  }

  Future<List<GithubRepo>> saveRepo(GithubRepo newRepo) async {
    final repos = await getSavedRepos();
    final existingIndex = repos.indexWhere((r) => r == newRepo);

    if (existingIndex == -1 && repos.length >= maxRepos) {
      throw MaxRepoLimitException();
    }

    final updatedList = repos
        .map((r) => r.copyWith(isActive: false))
        .toList();

    final activeNewRepo = newRepo.copyWith(isActive: true);

    if (existingIndex != -1) {
      updatedList[existingIndex] = activeNewRepo;
    } else {
      updatedList.add(activeNewRepo);
    }

    await _persistRepos(updatedList);
    return updatedList;
  }

  Future<List<GithubRepo>> setActiveRepo(GithubRepo targetRepo) async {
    final repos = await getSavedRepos();
    final updatedList = repos.map((r) {
      return r.copyWith(isActive: r == targetRepo);
    }).toList();

    await _persistRepos(updatedList);
    return updatedList;
  }

  Future<List<GithubRepo>> removeRepo(GithubRepo targetRepo) async {
    final repos = await getSavedRepos();
    repos.removeWhere((r) => r == targetRepo);

    if (repos.isNotEmpty && !repos.any((r) => r.isActive)) {
      repos[0] = repos[0].copyWith(isActive: true);
    }

    await _persistRepos(repos);
    return repos;
  }

  Future<void> _persistRepos(List<GithubRepo> repos) async {
    final encoded = jsonEncode(repos.map((r) => r.toJson()).toList());
    await _storage.write(key: _reposKey, value: encoded);
  }
}
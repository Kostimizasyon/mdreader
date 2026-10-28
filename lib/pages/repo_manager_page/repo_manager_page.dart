import 'package:flutter/material.dart';
import '../../data_models/github_repo.dart';
import '../../services/secure_storage_service.dart';
import 'util/add_repo_dialog.dart';
import 'util/repo_list_card.dart';

class RepoManagerPage extends StatelessWidget {
  final List<GithubRepo> savedRepos;
  final bool isSyncing;
  final Future<void> Function(String rawInput) onAddRepo;
  final Future<void> Function(GithubRepo repo) onSelectRepo;
  final Future<void> Function(GithubRepo repo) onRefreshRepo;
  final Future<void> Function(GithubRepo repo) onRemoveRepo;

  const RepoManagerPage({
    super.key,
    required this.savedRepos,
    required this.isSyncing,
    required this.onAddRepo,
    required this.onSelectRepo,
    required this.onRefreshRepo,
    required this.onRemoveRepo,
  });

  void _openAddDialog(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (_) => AddRepoDialog(
        currentRepoCount: savedRepos.length,
        maxRepos: SecureStorageService.maxRepos,
        onAddRepository: onAddRepo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Saved Repositories', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 2),
                  Text(
                    '${savedRepos.length} of ${SecureStorageService.maxRepos} slots used',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _openAddDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Repo'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          if (savedRepos.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.folder_copy_outlined,
                      size: 48,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No repositories saved yet',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Add up to 3 public GitHub repositories to browse and read their Markdown documentation offline.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => _openAddDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add First Repository'),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: savedRepos.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final repo = savedRepos[index];
                  return RepoListCard(
                    repo: repo,
                    isSyncing: isSyncing && repo.isActive,
                    onSelect: () => onSelectRepo(repo),
                    onRefresh: () => onRefreshRepo(repo),
                    onDelete: () => onRemoveRepo(repo),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
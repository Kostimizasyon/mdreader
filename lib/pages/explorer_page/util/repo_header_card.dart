import 'package:flutter/material.dart';
import '../../../data_models/github_repo.dart';

class RepoHeaderCard extends StatelessWidget {
  final GithubRepo activeRepo;
  final List<GithubRepo> savedRepos;
  final int totalMarkdownCount;
  final bool isRefreshing;
  final VoidCallback onRefresh;
  final ValueChanged<GithubRepo> onSwitchRepo;

  const RepoHeaderCard({
    super.key,
    required this.activeRepo,
    required this.savedRepos,
    required this.totalMarkdownCount,
    required this.isRefreshing,
    required this.onRefresh,
    required this.onSwitchRepo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outline, width: 1),
        ),
      ),
      child: Row(
        children: [
          PopupMenuButton<GithubRepo>(
            tooltip: 'Switch active repository',
            onSelected: onSwitchRepo,
            itemBuilder: (context) {
              return savedRepos.map((repo) {
                return PopupMenuItem<GithubRepo>(
                  value: repo,
                  child: Row(
                    children: [
                      Icon(
                        repo.isActive
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        size: 16,
                        color: repo.isActive
                            ? theme.colorScheme.primary
                            : theme.textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          repo.fullName,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.book_outlined, size: 15, color: theme.colorScheme.primary),
                  const SizedBox(width: 6),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 160),
                    child: Text(
                      activeRepo.fullName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.call_split,
                  size: 13,
                  color: theme.textTheme.bodySmall?.color,
                ),
                const SizedBox(width: 4),
                Text(
                  activeRepo.defaultBranch,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            '$totalMarkdownCount .md',
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
          ),
          const SizedBox(width: 6),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Refresh repository tree & cache',
            onPressed: isRefreshing ? null : onRefresh,
            icon: isRefreshing
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.refresh, size: 20),
          ),
        ],
      ),
    );
  }
}
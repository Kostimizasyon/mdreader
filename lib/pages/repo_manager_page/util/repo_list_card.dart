import 'package:flutter/material.dart';
import '../../../data_models/github_repo.dart';
import '../../../theme/app_colors.dart';

class RepoListCard extends StatelessWidget {
  final GithubRepo repo;
  final VoidCallback onSelect;
  final VoidCallback onRefresh;
  final VoidCallback onDelete;
  final bool isSyncing;

  const RepoListCard({
    super.key,
    required this.repo,
    required this.onSelect,
    required this.onRefresh,
    required this.onDelete,
    this.isSyncing = false,
  });

  String _formatSyncTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeGreen = isDark ? AppColors.darkSuccessGreen : AppColors.lightSuccessGreen;
    final dangerRed = isDark ? AppColors.darkErrorRed : AppColors.lightErrorRed;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(
          color: repo.isActive ? theme.colorScheme.primary : theme.colorScheme.outline,
          width: repo.isActive ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onSelect,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      repo.fullName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (repo.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: activeGreen.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: activeGreen),
                      ),
                      child: Text(
                        'Active',
                        style: TextStyle(
                          color: activeGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(4),
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
                          repo.defaultBranch,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.history,
                    size: 14,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Synced ${_formatSyncTime(repo.lastSyncedAt)}',
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Sync repository',
                    onPressed: isSyncing ? null : onRefresh,
                    icon: isSyncing
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.sync, size: 18),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Remove repository',
                    onPressed: isSyncing ? null : onDelete,
                    icon: Icon(Icons.delete_outline, size: 18, color: dangerRed),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
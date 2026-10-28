import 'package:flutter/material.dart';
import '../../data_models/github_repo.dart';
import '../../data_models/repo_node.dart';
import '../../services/cache_service.dart';
import '../../services/github_service.dart';
import '../../services/tree_builder_service.dart';
import '../../theme/app_colors.dart';
import '../reader_page/reader_page.dart';
import 'util/breadcrumb_bar.dart';
import 'util/file_tree_item.dart';
import 'util/repo_header_card.dart';

class ExplorerPage extends StatefulWidget {
  final GithubRepo? activeRepo;
  final List<GithubRepo> savedRepos;
  final RepoNode? treeRoot;
  final bool isLoading;
  final String? errorMessage;
  final GithubService githubService;
  final CacheService cacheService;
  final TreeBuilderService treeBuilderService;
  final Future<void> Function() onRefresh;
  final ValueChanged<GithubRepo> onSwitchRepo;
  final VoidCallback onOpenRepoManager;

  const ExplorerPage({
    super.key,
    required this.activeRepo,
    required this.savedRepos,
    required this.treeRoot,
    required this.isLoading,
    required this.errorMessage,
    required this.githubService,
    required this.cacheService,
    required this.treeBuilderService,
    required this.onRefresh,
    required this.onSwitchRepo,
    required this.onOpenRepoManager,
  });

  @override
  State<ExplorerPage> createState() => _ExplorerPageState();
}

class _ExplorerPageState extends State<ExplorerPage> {
  String _currentPath = '';

  @override
  void didUpdateWidget(covariant ExplorerPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeRepo != widget.activeRepo) {
      _currentPath = '';
    }
  }

  void _navigateUp() {
    if (_currentPath.isEmpty) return;
    final segments = _currentPath.split('/')..removeLast();
    setState(() {
      _currentPath = segments.join('/');
    });
  }

  void _openMarkdownFile(RepoNode fileNode) {
    final repo = widget.activeRepo;
    if (repo == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReaderPage(
          repo: repo,
          fileNode: fileNode,
          githubService: widget.githubService,
          cacheService: widget.cacheService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final errorColor = isDark ? AppColors.darkErrorRed : AppColors.lightErrorRed;

    if (widget.activeRepo == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.explore_outlined,
                size: 52,
                color: theme.textTheme.bodySmall?.color,
              ),
              const SizedBox(height: 12),
              Text(
                'No Active Repository Selected',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Add a GitHub repository in the Repositories tab to explore its Markdown documentation.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: widget.onOpenRepoManager,
                icon: const Icon(Icons.storage_outlined, size: 18),
                label: const Text('Go to Repository Manager'),
              ),
            ],
          ),
        ),
      );
    }

    final root = widget.treeRoot;
    final currentNode = root != null
        ? (widget.treeBuilderService.findNodeByPath(root, _currentPath) ?? root)
        : null;
    final totalMdFiles =
    root != null ? widget.treeBuilderService.countMarkdownFiles(root) : 0;

    return PopScope(
      canPop: _currentPath.isEmpty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentPath.isNotEmpty) {
          _navigateUp();
        }
      },
      child: Column(
        children: [
          RepoHeaderCard(
            activeRepo: widget.activeRepo!,
            savedRepos: widget.savedRepos,
            totalMarkdownCount: totalMdFiles,
            isRefreshing: widget.isLoading,
            onRefresh: widget.onRefresh,
            onSwitchRepo: widget.onSwitchRepo,
          ),
          BreadcrumbBar(
            repoName: widget.activeRepo!.name,
            currentPath: _currentPath,
            onPathSelected: (newPath) => setState(() => _currentPath = newPath),
          ),
          if (widget.errorMessage != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: errorColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: errorColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: errorColor, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.errorMessage!,
                      style: TextStyle(color: errorColor, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: widget.isLoading && currentNode == null
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
              onRefresh: widget.onRefresh,
              child: _buildDirectoryList(theme, currentNode),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectoryList(ThemeData theme, RepoNode? currentNode) {
    if (currentNode == null || currentNode.children.isEmpty) {
      return ListView(
        children: [
          SizedBox(
            height: 300,
            child: Center(
              child: Text(
                'No Markdown (.md) files found in this repository.',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
        ],
      );
    }

    final items = currentNode.children;
    final showParentRow = _currentPath.isNotEmpty;
    final totalCount = items.length + (showParentRow ? 1 : 0);

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: totalCount,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        if (showParentRow && index == 0) {
          return InkWell(
            onTap: _navigateUp,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.drive_folder_upload_outlined,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '..',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final node = items[showParentRow ? index - 1 : index];
        return FileTreeItem(
          node: node,
          onTap: () {
            if (node.isDirectory) {
              setState(() => _currentPath = node.path);
            } else {
              _openMarkdownFile(node);
            }
          },
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import '../../data_models/github_repo.dart';
import '../../data_models/repo_node.dart';
import '../../services/cache_service.dart';
import '../../services/github_service.dart';
import '../../services/secure_storage_service.dart';
import '../../services/tree_builder_service.dart';
import '../explorer_page/explorer_page.dart';
import '../repo_manager_page/repo_manager_page.dart';
import '../../pages/util/custom_app_bar.dart';

class NavigationShell extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const NavigationShell({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  final SecureStorageService _storageService = SecureStorageService();
  final GithubService _githubService = GithubService();
  final TreeBuilderService _treeBuilderService = TreeBuilderService();
  final CacheService _cacheService = CacheService();

  int _selectedIndex = 0;
  List<GithubRepo> _savedRepos = [];
  GithubRepo? _activeRepo;
  RepoNode? _activeTreeRoot;
  bool _isLoadingTree = false;
  String? _errorBannerMessage;

  @override
  void initState() {
    super.initState();
    _initializeRepos();
  }

  Future<void> _initializeRepos() async {
    setState(() => _isLoadingTree = true);
    try {
      final repos = await _storageService.getSavedRepos();
      final active = await _storageService.getActiveRepo();
      setState(() {
        _savedRepos = repos;
        _activeRepo = active;
      });
      if (active != null) {
        await _loadRepoTree(active, forceRefresh: false);
      }
    } catch (e) {
      setState(() => _errorBannerMessage = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoadingTree = false);
      }
    }
  }

  Future<void> _loadRepoTree(GithubRepo repo, {required bool forceRefresh}) async {
    setState(() {
      _isLoadingTree = true;
      _errorBannerMessage = null;
    });

    try {
      List<GithubTreeEntry>? entries;
      if (!forceRefresh) {
        entries = await _cacheService.getCachedTreeEntries(repo);
      }

      if (entries == null) {
        entries = await _githubService.fetchRecursiveTree(repo);
        await _cacheService.cacheTreeEntries(repo, entries);
      }

      final treeRoot = _treeBuilderService.buildMarkdownTree(entries);
      final updatedRepo = repo.copyWith(lastSyncedAt: DateTime.now());
      final updatedList = await _storageService.saveRepo(updatedRepo);

      if (mounted) {
        setState(() {
          _savedRepos = updatedList;
          _activeRepo = updatedRepo;
          _activeTreeRoot = treeRoot;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorBannerMessage = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingTree = false);
      }
    }
  }

  Future<void> _handleAddRepo(String rawInput) async {
    if (_savedRepos.length >= SecureStorageService.maxRepos) {
      throw MaxRepoLimitException();
    }
    final verifiedRepo = await _githubService.verifyAndFetchRepo(rawInput);
    final entries = await _githubService.fetchRecursiveTree(verifiedRepo);
    await _cacheService.cacheTreeEntries(verifiedRepo, entries);
    final treeRoot = _treeBuilderService.buildMarkdownTree(entries);
    final updatedRepos = await _storageService.saveRepo(verifiedRepo);

    if (mounted) {
      setState(() {
        _savedRepos = updatedRepos;
        _activeRepo = verifiedRepo;
        _activeTreeRoot = treeRoot;
        _errorBannerMessage = null;
        _selectedIndex = 0;
      });
    }
  }

  Future<void> _handleSelectRepo(GithubRepo repo) async {
    final updated = await _storageService.setActiveRepo(repo);
    setState(() {
      _savedRepos = updated;
      _activeRepo = repo.copyWith(isActive: true);
      _selectedIndex = 0;
    });
    await _loadRepoTree(repo, forceRefresh: false);
  }

  Future<void> _handleRefreshRepo(GithubRepo repo) async {
    await _cacheService.clearRepoCache(repo);
    await _loadRepoTree(repo, forceRefresh: true);
  }

  Future<void> _handleRemoveRepo(GithubRepo repo) async {
    await _cacheService.clearRepoCache(repo);
    final remaining = await _storageService.removeRepo(repo);
    final nextActive = await _storageService.getActiveRepo();

    setState(() {
      _savedRepos = remaining;
      _activeRepo = nextActive;
      _activeTreeRoot = null;
      _errorBannerMessage = null;
    });

    if (nextActive != null) {
      await _loadRepoTree(nextActive, forceRefresh: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: _selectedIndex == 0
            ? (_activeRepo?.fullName ?? 'GitHub Markdown Explorer')
            : 'Repository Manager',
        subtitle: _selectedIndex == 0 && _activeRepo != null
            ? 'Branch: ${_activeRepo!.defaultBranch}'
            : null,
        isDarkMode: widget.isDarkMode,
        onToggleTheme: widget.onToggleTheme,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          ExplorerPage(
            activeRepo: _activeRepo,
            savedRepos: _savedRepos,
            treeRoot: _activeTreeRoot,
            isLoading: _isLoadingTree,
            errorMessage: _errorBannerMessage,
            githubService: _githubService,
            cacheService: _cacheService,
            treeBuilderService: _treeBuilderService,
            onRefresh: () {
              if (_activeRepo != null) {
                return _handleRefreshRepo(_activeRepo!);
              }
              return Future.value();
            },
            onSwitchRepo: _handleSelectRepo,
            onOpenRepoManager: () => setState(() => _selectedIndex = 1),
          ),
          RepoManagerPage(
            savedRepos: _savedRepos,
            isSyncing: _isLoadingTree,
            onAddRepo: _handleAddRepo,
            onSelectRepo: _handleSelectRepo,
            onRefreshRepo: _handleRefreshRepo,
            onRemoveRepo: _handleRemoveRepo,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: theme.colorScheme.outline, width: 1),
          ),
        ),
        child: NavigationBar(
          height: 62,
          backgroundColor: theme.colorScheme.surface,
          indicatorColor: theme.colorScheme.primary.withOpacity(0.15),
          selectedIndex: _selectedIndex,
          onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.folder_outlined),
              selectedIcon: Icon(Icons.folder),
              label: 'Explorer',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: _savedRepos.isNotEmpty,
                label: Text('${_savedRepos.length}'),
                child: const Icon(Icons.storage_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: _savedRepos.isNotEmpty,
                label: Text('${_savedRepos.length}'),
                child: const Icon(Icons.storage),
              ),
              label: 'Repositories',
            ),
          ],
        ),
      ),
    );
  }
}
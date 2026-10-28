import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/vs2015.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import '../../data_models/github_repo.dart';
import '../../data_models/repo_node.dart';
import '../../services/cache_service.dart';
import '../../services/github_service.dart';
import '../../theme/app_colors.dart';
import 'util/markdown_toolbar.dart';
import 'util/reader_toc_sheet.dart';

class CodeElementBuilder extends MarkdownElementBuilder {
  final bool isDark;
  final Color borderColor;
  final Color blockBgColor;

  CodeElementBuilder({
    required this.isDark,
    required this.borderColor,
    required this.blockBgColor,
  });

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final textContent = element.textContent;
    final isBlock = textContent.contains('\n') ||
        (element.attributes['class']?.startsWith('language-') ?? false);

    if (!isBlock) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: blockBgColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          textContent,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: (preferredStyle?.fontSize ?? 14) * 0.9,
          ),
        ),
      );
    }

    String language = 'plaintext';
    final classAttr = element.attributes['class'];
    if (classAttr != null && classAttr.startsWith('language-')) {
      language = classAttr.substring('language-'.length).trim();
    }

    final themeMap = Map<String, TextStyle>.from(
      isDark ? vs2015Theme : githubTheme,
    );
    themeMap['root'] = TextStyle(
      backgroundColor: Colors.transparent,
      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: blockBgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(12),
        child: HighlightView(
          textContent.trimRight(),
          language: language,
          theme: themeMap,
          textStyle: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            height: 1.45,
          ),
        ),
      ),
    );
  }
}

class ReaderPage extends StatefulWidget {
  final GithubRepo repo;
  final RepoNode fileNode;
  final GithubService githubService;
  final CacheService cacheService;

  const ReaderPage({
    super.key,
    required this.repo,
    required this.fileNode,
    required this.githubService,
    required this.cacheService,
  });

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  final ScrollController _scrollController = ScrollController();

  String? _content;
  bool _isLoading = true;
  bool _isCached = false;
  bool _isRawView = false;
  double _fontScale = 1.0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDocument(forceRefresh: false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadDocument({required bool forceRefresh}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String? markdown;
      bool fromCache = false;

      if (!forceRefresh) {
        markdown = await widget.cacheService.getCachedMarkdown(
          widget.repo,
          widget.fileNode.path,
        );
        if (markdown != null) {
          fromCache = true;
        }
      }

      if (markdown == null) {
        markdown = await widget.githubService.fetchRawMarkdown(
          repo: widget.repo,
          filePath: widget.fileNode.path,
        );
        await widget.cacheService.cacheMarkdown(
          widget.repo,
          widget.fileNode.path,
          markdown,
        );
        fromCache = false;
      }

      if (mounted) {
        setState(() {
          _content = markdown;
          _isCached = fromCache;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _resolveImageUrl(String uriString) {
    if (uriString.startsWith('http://') || uriString.startsWith('https://')) {
      return uriString;
    }
    final segments = widget.fileNode.path.split('/');
    segments.removeLast();
    final dirPrefix = segments.isEmpty ? '' : '${segments.join('/')}/';
    final cleanRelative = uriString.startsWith('./')
        ? uriString.substring(2)
        : uriString.replaceFirst(RegExp(r'^/'), '');
    const baseUrl = 'https://raw.githubusercontent.com';
    return '$baseUrl/${widget.repo.owner}/${widget.repo.name}/${widget.repo.defaultBranch}/$dirPrefix$cleanRelative';
  }

  void _openTocSheet() {
    if (_content == null) return;
    final headings = ReaderTocSheet.parseHeadings(_content!);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ReaderTocSheet(
        headings: headings,
        onSelectHeading: (heading) {
          final index = _content!.indexOf(heading.text);
          if (index != -1 &&
              _scrollController.hasClients &&
              _content!.isNotEmpty) {
            final ratio = index / _content!.length;
            final targetOffset =
                _scrollController.position.maxScrollExtent * ratio;

            _scrollController.animateTo(
              targetOffset.clamp(
                0.0,
                _scrollController.position.maxScrollExtent,
              ),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
            );
          }
        },
      ),
    );
  }

  void _copyGithubUrl() {
    const baseUrl = 'https://github.com';
    final url =
        '$baseUrl/${widget.repo.owner}/${widget.repo.name}/blob/${widget.repo.defaultBranch}/${widget.fileNode.path}';
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('GitHub link copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final surfaceColor =
    isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final secondaryText =
    isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.fileNode.name,
              style: theme.textTheme.titleMedium?.copyWith(fontSize: 15),
            ),
            Text(
              widget.fileNode.path,
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          MarkdownToolbar(
            fontScale: _fontScale,
            isRawView: _isRawView,
            isCached: _isCached,
            onDecreaseFont: () {
              setState(() => _fontScale = (_fontScale - 0.1).clamp(0.7, 1.6));
            },
            onIncreaseFont: () {
              setState(() => _fontScale = (_fontScale + 0.1).clamp(0.7, 1.6));
            },
            onToggleRaw: () => setState(() => _isRawView = !_isRawView),
            onOpenToc: _openTocSheet,
            onCopyUrl: _copyGithubUrl,
            onForceRefresh: () => _loadDocument(forceRefresh: true),
          ),
          Expanded(
            child: _buildBody(
              theme,
              isDark,
              borderColor,
              surfaceColor,
              secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
      ThemeData theme,
      bool isDark,
      Color borderColor,
      Color surfaceColor,
      Color secondaryText,
      ) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      final errorColor =
      isDark ? AppColors.darkErrorRed : AppColors.lightErrorRed;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: errorColor, size: 42),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: errorColor),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _loadDocument(forceRefresh: true),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final rawText = _content ?? '';
    if (_isRawView) {
      return SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: SelectableText(
          rawText,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 13 * _fontScale,
            height: 1.5,
          ),
        ),
      );
    }

    return Markdown(
      controller: _scrollController,
      data: rawText,
      selectable: true,
      padding: const EdgeInsets.all(16),
      extensionSet: md.ExtensionSet.gitHubFlavored,
      builders: {
        'code': CodeElementBuilder(
          isDark: isDark,
          borderColor: borderColor,
          blockBgColor: surfaceColor,
        ),
      },
      sizedImageBuilder: (config) {
        final resolvedUrl = _resolveImageUrl(config.uri.toString());
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              resolvedUrl,
              width: config.width,
              height: config.height,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  height: 120,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: borderColor),
                  ),
                  child: const CircularProgressIndicator(strokeWidth: 2),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.broken_image_outlined,
                        size: 18,
                        color: secondaryText,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          config.alt ?? 'Unable to load image',
                          style: TextStyle(color: secondaryText, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
        textScaler: TextScaler.linear(_fontScale),
        p: theme.textTheme.bodyMedium?.copyWith(height: 1.55, fontSize: 15),
        h1: theme.textTheme.titleLarge?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 1.4,
        ),
        h1Padding: const EdgeInsets.only(bottom: 8, top: 16),
        h2: theme.textTheme.titleLarge?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        h2Padding: const EdgeInsets.only(bottom: 6, top: 14),
        h3: theme.textTheme.titleMedium?.copyWith(
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        blockquote: TextStyle(color: secondaryText, height: 1.5),
        blockquoteDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: borderColor, width: 4),
          ),
        ),
        blockquotePadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 4,
        ),
        tableBorder: TableBorder.all(color: borderColor, width: 1),
        tableHead: const TextStyle(fontWeight: FontWeight.w600),
        tableCellsPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        tableCellsDecoration: BoxDecoration(color: theme.cardTheme.color),
        horizontalRuleDecoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: borderColor, width: 1.5),
          ),
        ),
      ),
    );
  }
}
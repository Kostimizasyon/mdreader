import 'package:flutter/material.dart';

class MarkdownToolbar extends StatelessWidget {
  final double fontScale;
  final bool isRawView;
  final bool isCached;
  final VoidCallback onDecreaseFont;
  final VoidCallback onIncreaseFont;
  final VoidCallback onToggleRaw;
  final VoidCallback onOpenToc;
  final VoidCallback onCopyUrl;
  final VoidCallback onForceRefresh;

  const MarkdownToolbar({
    super.key,
    required this.fontScale,
    required this.isRawView,
    required this.isCached,
    required this.onDecreaseFont,
    required this.onIncreaseFont,
    required this.onToggleRaw,
    required this.onOpenToc,
    required this.onCopyUrl,
    required this.onForceRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outline, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCached ? Icons.offline_pin_outlined : Icons.cloud_done_outlined,
                  size: 13,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  isCached ? 'Cached' : 'Live',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          const Spacer(),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Decrease font size',
            onPressed: onDecreaseFont,
            icon: const Icon(Icons.text_decrease, size: 18),
          ),
          Text(
            '${(fontScale * 100).round()}%',
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Increase font size',
            onPressed: onIncreaseFont,
            icon: const Icon(Icons.text_increase, size: 18),
          ),
          const SizedBox(width: 4),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Table of Contents',
            onPressed: onOpenToc,
            icon: const Icon(Icons.toc, size: 20),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: isRawView ? 'Show Rendered Markdown' : 'Show Raw Markdown',
            onPressed: onToggleRaw,
            icon: Icon(
              isRawView ? Icons.visibility_outlined : Icons.code,
              size: 19,
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Copy GitHub file URL',
            onPressed: onCopyUrl,
            icon: const Icon(Icons.link, size: 19),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Re-fetch from GitHub',
            onPressed: onForceRefresh,
            icon: const Icon(Icons.refresh, size: 19),
          ),
        ],
      ),
    );
  }
}